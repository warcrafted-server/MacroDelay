-- Amplía el límite de 255 caracteres de la ventana nativa de macros. El texto largo se guarda en
-- MacroDelayDB (macros generales) o MacroDelayCharDB (de personaje), indexado por el índice
-- absoluto de la macro (1-36 generales, 37-72 de personaje), y la macro real solo contiene
-- "/click MacroDelayProxy<índice>", un botón secure que ejecuta el texto completo.

local MCD = MacroDelay

local function proxyText(index)
	return "/click MacroDelayProxy" .. index
end

local function setProxy(index, body)
	local button = _G["MacroDelayProxy" .. index] or CreateFrame("Button", "MacroDelayProxy" .. index, nil, "SecureActionButtonTemplate")
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", body)
end

-- Tiene que ir al cargar el addon, no al abrir la ventana de macros: si no, tras entrar al juego
-- el "/click" de cada macro larga apunta a un botón que todavía no existe.
function MCD:RestoreProxies()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	for index, body in pairs(self.db.macroBodies) do setProxy(index, body) end
	for index, body in pairs(self.charDb.macroBodies) do setProxy(index, body) end
end

function MCD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:RestoreProxies()
end

MCD:OnDbReady(function() MCD:RestoreProxies() end)

local function storedBodies()
	return MacroFrame.macroBase == 0 and MCD.db.macroBodies or MCD.charDb.macroBodies
end

local function newMacro()
	if InCombatLockdown() then return end

	local index = 1
	if MacroPopupFrame.mode == "new" then
		index = CreateMacro(MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon, nil, MacroFrame.macroBase > 0)
		local global, perchar = GetNumMacros()
		local bodies = storedBodies()
		local last = MacroFrame.macroBase == 0 and global - 1 or perchar + 36 - 1
		for i = last, index, -1 do bodies[i + 1] = bodies[i] end
		bodies[index] = nil
	elseif MacroPopupFrame.mode == "edit" then
		index = EditMacro(MacroFrame.selectedMacro, MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon)
	end
	MacroPopupFrame:Hide()
	MacroFrame_SelectMacro(index)
	MacroFrame_Update()
end

local function saveMacro()
	if not MCD:IsEnabled() then return MCD.nativeSave() end
	if InCombatLockdown() then return end

	local index = MacroFrame.selectedMacro
	if not (MacroFrame.textChanged and index) then return end

	local body = MacroFrameText:GetText()
	local bodies = storedBodies()
	if body:len() < 256 then
		bodies[index] = nil
		EditMacro(index, nil, nil, body)
	else
		bodies[index] = body
		EditMacro(index, nil, nil, proxyText(index))
		setProxy(index, body)
	end
	MacroFrame.textChanged = nil
end

local function deleteMacro()
	if not MCD:IsEnabled() then return MCD.nativeDelete() end
	if InCombatLockdown() then return end

	local selectedMacro = MacroFrame.selectedMacro
	local global, perchar = GetNumMacros()
	local bodies = storedBodies()

	DeleteMacro(selectedMacro)

	local last = MacroFrame.macroBase == 0 and 35 or 71
	for i = selectedMacro, last do
		bodies[i] = bodies[i + 1]
		if bodies[i] then
			EditMacro(i, nil, nil, proxyText(i))
			setProxy(i, bodies[i])
		end
	end
	bodies[MacroFrame.macroBase == 0 and global or perchar + 36] = nil

	local numMacros = select(PanelTemplates_GetSelectedTab(MacroFrame), GetNumMacros())
	if selectedMacro > numMacros + MacroFrame.macroBase then
		selectedMacro = selectedMacro - 1
	end
	MacroFrame.selectedMacro = selectedMacro > MacroFrame.macroBase and selectedMacro or nil
	MacroFrame_Update()
	MacroFrameText:ClearFocus()
end

local function updateFrame()
	if not MCD:IsEnabled() then return MCD.nativeUpdate() end

	local numAccountMacros, numCharacterMacros = GetNumMacros()
	local numMacros = MacroFrame.macroBase == 0 and numAccountMacros or numCharacterMacros
	local bodies = storedBodies()

	for i = 1, max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS) do
		local macroButton = _G["MacroButton" .. i]
		local macroIcon = _G["MacroButton" .. i .. "Icon"]
		local macroName = _G["MacroButton" .. i .. "Name"]

		if i <= MacroFrame.macroMax then
			if i <= numMacros then
				local index = MacroFrame.macroBase + i
				local name, texture, body = GetMacroInfo(index)
				-- solo si la macro sigue apuntando a su proxy: si se editó con el addon
				-- desactivado, el texto guardado ya no es el bueno
				if bodies[index] and body == proxyText(index) then
					body = bodies[index]
				end
				macroIcon:SetTexture(texture)
				macroName:SetText(name)
				macroButton:Enable()
				if MacroFrame.selectedMacro and i == MacroFrame.selectedMacro - MacroFrame.macroBase then
					macroButton:SetChecked(1)
					MacroFrameSelectedMacroName:SetText(name)
					MacroFrameText:SetText(body)
					MacroFrameSelectedMacroButton:SetID(i)
					MacroFrameSelectedMacroButtonIcon:SetTexture(texture)
					MacroPopupFrame.selectedIconTexture = texture
				else
					macroButton:SetChecked(0)
				end
			else
				macroButton:SetChecked(0)
				macroIcon:SetTexture("")
				macroName:SetText("")
				macroButton:Disable()
			end
			macroButton:Show()
		else
			macroButton:Hide()
		end
	end

	if MacroFrame.selectedMacro ~= nil then
		MacroFrame_ShowDetails()
		MacroDeleteButton:Enable()
	else
		MacroFrame_HideDetails()
		MacroDeleteButton:Disable()
	end

	if numMacros < MacroFrame.macroMax then
		MacroNewButton:Enable()
	else
		MacroNewButton:Disable()
	end

	if MacroPopupFrame:IsShown() then
		MacroEditButton:Disable()
		MacroDeleteButton:Disable()
	else
		MacroEditButton:Enable()
		MacroDeleteButton:Enable()
	end

	if not MacroFrame.selectedMacro then
		MacroDeleteButton:Disable()
	end
end

function MCD:ApplyCharLimit()
	if not MacroFrameText then return end
	local limit = self:IsEnabled() and self.db.charLimit or 255
	MacroFrameText:SetMaxLetters(limit)
	if self.nativeCharLimitText then
		MACROFRAME_CHAR_LIMIT = self.nativeCharLimitText:gsub("%d+", tostring(limit))
	end
end

-- Las funciones nativas se sustituyen una sola vez; con el addon desactivado, las nuestras
-- delegan en las originales.
function MCD:HookMacroUI()
	if self.nativeSave then return end

	self.nativeSave = MacroFrame_SaveMacro
	self.nativeDelete = MacroFrame_DeleteMacro
	self.nativeUpdate = MacroFrame_Update
	self.nativeNew = MacroPopupOkayButton_OnClick
	self.nativeCharLimitText = MACROFRAME_CHAR_LIMIT

	MacroFrame_SaveMacro = saveMacro
	MacroFrame_DeleteMacro = deleteMacro
	MacroFrame_Update = updateFrame
	MacroPopupOkayButton_OnClick = function(...)
		if MCD:IsEnabled() then return newMacro() end
		return MCD.nativeNew(...)
	end

	self:ApplyCharLimit()
end
