MacroDelay = CreateFrame("Frame")
local MCD = MacroDelay

MCD.name = "MacroDelay"
MCD.version = GetAddOnMetadata and GetAddOnMetadata("MacroDelay", "Version") or "1.0.0"

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
	MCD.db = MacroDelayDB
end

MCD:RegisterEvent("ADDON_LOADED")
MCD:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "MacroDelay" then
		initDb()
		for _, fn in ipairs(callbacks) do fn() end
		callbacks = nil
		self:UnregisterEvent("ADDON_LOADED")
	end
end)

function MCD:SetEnabled(value)
	self.db.enabled = value and true or false
	if self.OnEnabledChanged then self:OnEnabledChanged(self.db.enabled) end
end

function MCD:IsEnabled()
	return self.db and self.db.enabled
end
