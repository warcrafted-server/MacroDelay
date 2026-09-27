-- Macros de más de 255 caracteres en la ventana nativa de macros.
-- El cuerpo real de una macro larga es "/click <botón>", y el botón seguro ejecuta el texto
-- completo. El texto se guarda por id estable (no por hueco), así que reordenar macros no mueve datos.

local MCD = MacroDelay

local NATIVE_LIMIT = 255
local ACCOUNT_SLOTS = 36
local LEGACY_PREFIX = "MacroDelayProxy"

local scopes = {
	account = { prefix = "MacroDelayA", first = 1 },
	char = { prefix = "MacroDelayC", first = ACCOUNT_SLOTS + 1 },
}

local baseLabel = MACROFRAME_CHAR_LIMIT
local hooked, nativeSave, lastEnabled
local pendingSync, busy = false, false

local function scopeOf(slot)
	return slot > ACCOUNT_SLOTS and "char" or "account"
end

local function ownerOf(scope)
	return scope == "char" and MCD.charDb or MCD.db
end

local function storeOf(scope)
	return ownerOf(scope).longMacros
end

local function buttonName(scope, id)
	return scopes[scope].prefix .. id
end

-- Máximo para la línea #show/#showtooltip que se copia a la macro real: el resto lo ocupa el
-- "/click <botón>" y hay que dejar margen para el nombre del botón (el id crece con el tiempo).
local SHOW_LINE_LIMIT = NATIVE_LIMIT - 40

local function rawShowLine(text)
	return text and text:match("^%s*(#show[^\r\n]*)")
end

local function showLine(text)
	local line = rawShowLine(text)
	if line and #line <= SHOW_LINE_LIMIT then return line end
end

local function stubFor(scope, id, text)
	local stub = "/click " .. buttonName(scope, id)
	local show = text and showLine(text)
	return show and (show .. "\n" .. stub) or stub
end

local function stubId(body, scope)
	local id = body and body:match("/click " .. scopes[scope].prefix .. "(%d+)%s*$")
	return tonumber(id)
end

-- Solo cuenta como stub si el cuerpo es exactamente el nuestro (con o sin línea #show delante)
-- y el id tiene texto guardado.
local function knownId(body, scope)
	if not body then return end
	local prefix = scopes[scope].prefix
	if not (body:match("^/click " .. prefix .. "%d+%s*$")
		or body:match("^#show[^\r\n]*\r?\n/click " .. prefix .. "%d+%s*$")) then
		return
	end
	local id = stubId(body, scope)
	if id and storeOf(scope)[id] then return id end
end

local function macroCount(scope)
	local numAccount, numChar = GetNumMacros()
	return (scope == "char" and numChar or numAccount) or 0
end

local function macroBodies(scope)
	local first = scopes[scope].first
	local bodies = {}
	for i = 0, macroCount(scope) - 1 do
		local _, _, body = GetMacroInfo(first + i)
		bodies[first + i] = body
	end
	return bodies
end

local function setButton(name, text)
	if InCombatLockdown() then
		pendingSync = true
		return
	end
	local button = _G[name]
	if not button then
		if not text then return end
		button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
		button:Hide()
		button:SetAttribute("type", "macro")
	end
	button:SetAttribute("macrotext", text)
end

local function syncButtons()
	pendingSync = false
	for scope in pairs(scopes) do
		for id, text in pairs(storeOf(scope)) do
			setButton(buttonName(scope, id), text)
		end
		for slot, text in pairs(ownerOf(scope).macroBodies or {}) do
			setButton(LEGACY_PREFIX .. slot, text)
		end
	end
end

-- Nunca reutiliza un id al que aún apunte alguna macro, aunque su texto se haya perdido.
local function allocateId(scope)
	local used = {}
	for _, body in pairs(macroBodies(scope)) do
		local id = stubId(body, scope)
		if id then used[id] = true end
	end
	local store = storeOf(scope)
	local id = 1
	while store[id] or used[id] do id = id + 1 end
	return id
end

local function migrateLegacy(scope)
	local owner = ownerOf(scope)
	local legacy = owner.macroBodies
	if not legacy then return end
	local converted = {}
	for slot, body in pairs(macroBodies(scope)) do
		local old = tonumber(body and body:match("^/click " .. LEGACY_PREFIX .. "(%d+)$"))
		local text = old and legacy[old]
		if text then
			if not converted[old] then
				converted[old] = allocateId(scope)
				storeOf(scope)[converted[old]] = text
				setButton(buttonName(scope, converted[old]), text)
			end
			EditMacro(slot, nil, nil, stubFor(scope, converted[old], text))
		end
	end
	for old in pairs(legacy) do
		setButton(LEGACY_PREFIX .. old, nil)
	end
	owner.macroBodies = nil
end

-- Una sola vez por macro y sesión: si el cliente retocara el cuerpo al guardarlo, no entramos en bucle
-- con UPDATE_MACROS.
local refreshed = {}

local function refreshStubs(scope)
	local store = storeOf(scope)
	for slot, body in pairs(macroBodies(scope)) do
		local id = knownId(body, scope)
		if id then
			local expected = stubFor(scope, id, store[id])
			local key = scope .. id
			if body ~= expected and not refreshed[key] then
				refreshed[key] = true
				EditMacro(slot, nil, nil, expected)
			end
		end
	end
end

local function prune(scope)
	local referenced = {}
	for _, body in pairs(macroBodies(scope)) do
		local id = stubId(body, scope)
		if id then referenced[id] = true end
	end
	local store = storeOf(scope)
	for id in pairs(store) do
		if not referenced[id] then
			store[id] = nil
			setButton(buttonName(scope, id), nil)
		end
	end
end

-- GetNumMacros da 0 hasta que el cliente carga las macros: con 0 no se toca nada de ese ámbito.
local function maintain()
	if not MCD.db or busy then return end
	if InCombatLockdown() then
		pendingSync = true
		return
	end
	busy = true
	if pendingSync then syncButtons() end
	for scope in pairs(scopes) do
		if macroCount(scope) > 0 then
			migrateLegacy(scope)
			refreshStubs(scope)
			prune(scope)
		end
	end
	busy = false
end

local function currentLimit()
	return MCD:IsEnabled() and MCD.db.charLimit or NATIVE_LIMIT
end

local function applyLimit()
	if not MacroFrameText then return end
	MacroFrameText:SetMaxLetters(currentLimit())
	if MacroFrameCharLimitText then
		MacroFrameCharLimitText:SetFormattedText(MACROFRAME_CHAR_LIMIT, MacroFrameText:GetNumLetters())
	end
end

local function saveLong(slot, text)
	local scope = scopeOf(slot)
	local store = storeOf(scope)
	local _, _, body = GetMacroInfo(slot)
	local id = knownId(body, scope)
	if id and store[id] == text and body == stubFor(scope, id, text) then return end
	if InCombatLockdown() then
		MCD:Print("No se puede guardar una macro de más de " .. NATIVE_LIMIT .. " caracteres en combate.")
		return
	end
	id = id or allocateId(scope)
	store[id] = text
	setButton(buttonName(scope, id), text)
	EditMacro(slot, nil, nil, stubFor(scope, id, text))
	if rawShowLine(text) and not showLine(text) then
		MCD:Print("La línea #showtooltip pasa de " .. SHOW_LINE_LIMIT .. " caracteres y no cabe en la macro: el icono no cambiará solo. Acórtala para que funcione.")
	end
end

local function save(enabled)
	local slot = MacroFrame.selectedMacro
	if not enabled or not (slot and MacroFrame.textChanged) then
		return nativeSave()
	end
	local text = MacroFrameText:GetText() or ""
	if #text > NATIVE_LIMIT then
		MacroFrame.textChanged = nil
		return saveLong(slot, text)
	end
	local scope = scopeOf(slot)
	local _, _, body = GetMacroInfo(slot)
	local id = knownId(body, scope)
	if id then
		storeOf(scope)[id] = nil
		setButton(buttonName(scope, id), nil)
	end
	nativeSave()
end

local function showFullText()
	applyLimit()
	local slot = MacroFrame.selectedMacro
	if not (slot and MCD:IsEnabled()) then return end
	local scope = scopeOf(slot)
	local _, _, body = GetMacroInfo(slot)
	local id = knownId(body, scope)
	if id then
		MacroFrameText:SetText(storeOf(scope)[id])
	end
end

-- Red de seguridad por si algo cierra la ventana sin pasar por MacroFrame_SaveMacro.
local function saveOnClose()
	local slot = MacroFrame.selectedMacro
	local text = MacroFrameText:GetText() or ""
	if slot and MCD:IsEnabled() and #text > NATIVE_LIMIT then
		saveLong(slot, text)
	end
end

function MCD:ApplyCharLimit()
	if baseLabel then
		MACROFRAME_CHAR_LIMIT = baseLabel:gsub(tostring(NATIVE_LIMIT), tostring(currentLimit()))
	end
	local enabled = self:IsEnabled() and true or false
	if hooked and lastEnabled ~= enabled and MacroFrame:IsShown() then
		-- guarda con las reglas del modo anterior antes de volver a pintar la ventana
		save(lastEnabled)
		MacroFrame_Update()
	end
	lastEnabled = enabled
	applyLimit()
end

function MCD:HookMacroUI()
	if hooked or not (MacroFrame and MacroFrame_SaveMacro and MacroFrame_Update) then return end
	hooked = true
	nativeSave = MacroFrame_SaveMacro
	MacroFrame_SaveMacro = function() save(MCD:IsEnabled()) end
	hooksecurefunc("MacroFrame_Update", showFullText)
	MacroFrame:HookScript("OnShow", applyLimit)
	MacroFrame:HookScript("OnHide", saveOnClose)
	self:ApplyCharLimit()
end

local events = CreateFrame("Frame")
events:SetScript("OnEvent", maintain)

MCD:OnDbReady(function()
	MCD.db.longMacros = MCD.db.longMacros or {}
	MCD.charDb.longMacros = MCD.charDb.longMacros or {}
	lastEnabled = MCD:IsEnabled() and true or false
	syncButtons()
	MCD:ApplyCharLimit()
	events:RegisterEvent("UPDATE_MACROS")
	events:RegisterEvent("PLAYER_ENTERING_WORLD")
	events:RegisterEvent("PLAYER_REGEN_ENABLED")
end)
