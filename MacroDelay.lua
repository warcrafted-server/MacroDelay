MacroDelay = CreateFrame("Frame")
local MCD = MacroDelay

MCD.name = "MacroDelay"
MCD.version = GetAddOnMetadata and GetAddOnMetadata("MacroDelay", "Version") or "?"

local DEFAULTS = {
	enabled = true,
	charLimit = 1024,
	minimapAngle = 200,
	minimapHidden = false,
}

function MCD:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MacroDelay|r: " .. tostring(msg))
end

local callbacks = {}

function MCD:OnDbReady(fn)
	if self.db then
		fn()
	else
		table.insert(callbacks, fn)
	end
end

local function initDb()
	MacroDelayDB = MacroDelayDB or {}
	for key, value in pairs(DEFAULTS) do
		if MacroDelayDB[key] == nil then
			MacroDelayDB[key] = value
		end
	end
	MacroDelayDB.macroBodies = MacroDelayDB.macroBodies or {}

	-- las macros de personaje cambian de un personaje a otro: su texto no puede ir en la DB de cuenta
	MacroDelayCharDB = MacroDelayCharDB or {}
	MacroDelayCharDB.macroBodies = MacroDelayCharDB.macroBodies or {}

	MCD.db = MacroDelayDB
	MCD.charDb = MacroDelayCharDB
end

-- Un solo despachador: ADDON_LOADED no se desregistra nunca, porque Blizzard_MacroUI se carga
-- bajo demanda (al abrir la ventana de macros), mucho después que este addon.
MCD:SetScript("OnEvent", function(self, event, ...)
	if self[event] then self[event](self, ...) end
end)
MCD:RegisterEvent("ADDON_LOADED")

function MCD:ADDON_LOADED(addon)
	if addon == "MacroDelay" then
		initDb()
		for _, fn in ipairs(callbacks) do fn() end
		callbacks = nil
		if IsAddOnLoaded("Blizzard_MacroUI") then self:HookMacroUI() end
	elseif addon == "Blizzard_MacroUI" and self.db then
		self:HookMacroUI()
	end
end

function MCD:SetEnabled(value)
	self.db.enabled = value and true or false
	self:ApplyCharLimit()
end

function MCD:IsEnabled()
	return self.db and self.db.enabled
end
