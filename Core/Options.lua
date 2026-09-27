-- Panel nativo (InterfaceOptions_AddCategory), sin dependencia de AceConfig.

local MCD = MacroDelay

local panel = CreateFrame("Frame", "MacroDelayOptionsPanel", UIParent)
panel.name = "MacroDelay"
panel:Hide()

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("MacroDelay")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetWidth(500)
subtitle:SetJustifyH("LEFT")
subtitle:SetText("Macros sin límite de 255 caracteres y ejecución retardada de comandos con /in.")

local enabledCheck = CreateFrame("CheckButton", "MacroDelayEnabledCheck", panel, "InterfaceOptionsCheckButtonTemplate")
enabledCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -20)
MacroDelayEnabledCheckText:SetText("Addon activado")

local limitLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
limitLabel:SetPoint("TOPLEFT", enabledCheck, "BOTTOMLEFT", 2, -20)
limitLabel:SetText("Límite de caracteres de macro")

local limit1024 = CreateFrame("CheckButton", "MacroDelayLimit1024", panel, "UIRadioButtonTemplate")
limit1024:SetPoint("TOPLEFT", limitLabel, "BOTTOMLEFT", 0, -8)
_G[limit1024:GetName() .. "Text"]:SetText("1024 caracteres")

local limit2048 = CreateFrame("CheckButton", "MacroDelayLimit2048", panel, "UIRadioButtonTemplate")
limit2048:SetPoint("TOPLEFT", limit1024, "BOTTOMLEFT", 0, -4)
_G[limit2048:GetName() .. "Text"]:SetText("2048 caracteres")

local minimapCheck = CreateFrame("CheckButton", "MacroDelayMinimapCheck", panel, "InterfaceOptionsCheckButtonTemplate")
minimapCheck:SetPoint("TOPLEFT", limit2048, "BOTTOMLEFT", -2, -20)
MacroDelayMinimapCheckText:SetText("Mostrar botón en el minimapa")

local takenOverNote = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
takenOverNote:SetPoint("TOPLEFT", minimapCheck, "BOTTOMLEFT", 26, -2)
takenOverNote:SetWidth(460)
takenOverNote:SetJustifyH("LEFT")
takenOverNote:SetText("MacroDelay está en la barra de wcdpanel, que oculta este icono mientras tanto. " ..
	"Para recuperarlo, quita MacroDelay de la barra de wcdpanel.")

local function refresh()
	enabledCheck:SetChecked(MCD:IsEnabled())
	limit1024:SetChecked(MCD.db.charLimit == 1024)
	limit2048:SetChecked(MCD.db.charLimit == 2048)
	minimapCheck:SetChecked(not MCD.db.minimapHidden)
	if MCD:IsMinimapButtonTakenOver() then
		minimapCheck:Disable()
		MacroDelayMinimapCheckText:SetFontObject("GameFontDisable")
		takenOverNote:Show()
	else
		minimapCheck:Enable()
		MacroDelayMinimapCheckText:SetFontObject("GameFontHighlight")
		takenOverNote:Hide()
	end
end

enabledCheck:SetScript("OnClick", function(self)
	MCD:SetEnabled(self:GetChecked())
end)

limit1024:SetScript("OnClick", function()
	MCD.db.charLimit = 1024
	MCD:ApplyCharLimit()
	refresh()
end)

limit2048:SetScript("OnClick", function()
	MCD.db.charLimit = 2048
	MCD:ApplyCharLimit()
	refresh()
end)

minimapCheck:SetScript("OnClick", function(self)
	MCD.db.minimapHidden = not self:GetChecked()
	MCD:ApplyMinimapVisibility()
end)

panel:SetScript("OnShow", refresh)

MCD:OnDbReady(function()
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
end)

function MCD:OpenOptions()
	if InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(panel)
		InterfaceOptionsFrame_OpenToCategory(panel) -- doble llamada: bug conocido de Blizzard con el primer clic
	end
end
