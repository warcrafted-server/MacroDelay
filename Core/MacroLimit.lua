-- Amplía el límite de 255 caracteres de la ventana nativa de macros. Los cuerpos largos se
-- guardan en MacroDelayDB.macroBodies (globales) / .macroBodiesChar (por personaje) y la macro
-- real solo contiene "/click MacroDelayProxy<n>", un botón secure que lleva el texto completo.

local MCD = MacroDelay

local function proxyButton(index, body)
	if InCombatLockdown() then return end

	local button = _G["MacroDelayProxy" .. index] or CreateFrame("Button", "MacroDelayProxy" .. index, nil, "SecureActionButtonTemplate")
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", body)
end

local function charLimit()
	return (MCD.db and MCD.db.charLimit) or 1024
end

local function storedBodies()
	if MacroFrame.macroBase == 0 then
		return MCD.db.macroBodies
	end
	return MCD.db.macroBodiesChar
end

local function newMacro()
	if InCombatLockdown() then return end

	local index = 1
	if MacroPopupFrame.mode == "new" then
		index = CreateMacro(MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon, nil, MacroFrame.macroBase > 0)
		local global, perchar = GetNumMacros()
		local bodies = storedBodies()
		if MacroFrame.macroBase == 0 then
			for i = global - 1, index, -1 do bodies[i + 1] = bodies[i] end
		else
			for i = perchar + 36 - 1, index, -1 do bodies[i + 1] = bodies[i] end
		end
		bodies[index] = nil
	elseif MacroPopupFrame.mode == "edit" then
		index = EditMacro(MacroFrame.selectedMacro, MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon)
	end
	MacroPopupFrame:Hide()
	MacroFrame_SelectMacro(index)
	MacroFrame_Update()
end

local function saveMacro()
	if InCombatLockdown() then return end
	if not MCD:IsEnabled() then return MCD._nativeSave() end

	if MacroFrame.textChanged and MacroFrame.selectedMacro then
		local body = MacroFrameText:GetText()
		local bodies = storedBodies()

		if body:len() < 256 then
			bodies[MacroFrame.selectedMacro] = nil
			EditMacro(MacroFrame.selectedMacro, nil, nil, body)
		else
			bodies[MacroFrame.selectedMacro] = body
			EditMacro(MacroFrame.selectedMacro, nil, nil, "/click MacroDelayProxy" .. MacroFrame.selectedMacro)
			proxyButton(MacroFrame.selectedMacro, body)
		end

		MacroFrame.textChanged = nil
	end
end

local function deleteMacro()
	if InCombatLockdown() then return end
	if not MCD:IsEnabled() then return MCD._nativeDelete() end

	local selectedMacro = MacroFrame.selectedMacro
	local global, perchar = GetNumMacros()
	local bodies = storedBodies()

	DeleteMacro(selectedMacro)

	local last = MacroFrame.macroBase == 0 and 35 or 71
	for i = selectedMacro, last do
		bodies[i] = bodies[i + 1]
		if bodies[i] then
			EditMacro(i, nil, nil, "/click MacroDelayProxy" .. i)
		end
	end
	bodies[MacroFrame.macroBase == 0 and global or perchar] = nil

	local numMacros = select(PanelTemplates_GetSelectedTab(MacroFrame), GetNumMacros())
	if selectedMacro > numMacros + MacroFrame.macroBase then
		selectedMacro = selectedMacro - 1
	end

	MacroFrame.selectedMacro = selectedMacro > MacroFrame.macroBase and selectedMacro or nil
	MacroFrame_Update()
	MacroFrameText:ClearFocus()
end

local function updateFrame()
	if not MCD:IsEnabled() then return MCD._nativeUpdate() end

	local numAccountMacros, numCharacterMacros = GetNumMacros()
	local numMacros = MacroFrame.macroBase == 0 and numAccountMacros or numCharacterMacros
	local bodies = storedBodies()

	local maxMacroButtons = max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS)
	for i = 1, maxMacroButtons do
		local macroButtonName = "MacroButton" .. i
		local macroButton = _G[macroButtonName]
		local macroIcon = _G[macroButtonName .. "Icon"]
		local macroName = _G[macroButtonName .. "Name"]

		if i <= MacroFrame.macroMax then
			if i <= numMacros then
				local name, texture, body = GetMacroInfo(MacroFrame.macroBase + i)
				body = bodies[i] or body
				macroIcon:SetTexture(texture)
				macroName:SetText(name)
				macroButton:Enable()
				if MacroFrame.selectedMacro and i == (MacroFrame.selectedMacro - MacroFrame.macroBase) then
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
	local limit = self:IsEnabled() and charLimit() or 255
	MacroFrameText:SetMaxLetters(limit)
	if MACROFRAME_CHAR_LIMIT then
		MACROFRAME_CHAR_LIMIT = MACROFRAME_CHAR_LIMIT:gsub("%d+", tostring(limit))
	end
end

function MCD:RestoreProxies()
	for index, body in pairs(self.db.macroBodies) do proxyButton(index, body) end
	for index, body in pairs(self.db.macroBodiesChar) do proxyButton(index, body) end
end

MCD:RegisterEvent("ADDON_LOADED")
local hooked = false
MCD:HookScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_MacroUI" and not hooked then
		hooked = true

		self._nativeSave = MacroFrame_SaveMacro
		self._nativeDelete = MacroFrame_DeleteMacro
		self._nativeUpdate = MacroFrame_Update

		MacroFrame_SaveMacro = saveMacro
		MacroFrame_DeleteMacro = deleteMacro
		MacroFrame_Update = updateFrame
		MacroPopupOkayButton_OnClick = newMacro

		self:OnDbReady(function()
			self.db.macroBodies = self.db.macroBodies or {}
			self.db.macroBodiesChar = self.db.macroBodiesChar or {}
			self:RestoreProxies()
			self:ApplyCharLimit()
		end)
	end
end)
