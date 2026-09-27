-- Botón de minimapa arrastrable, con icono nativo (reloj de arena). Clic izquierdo abre las
-- opciones; clic derecho activa/desactiva el addon sin pasar por el panel.

local MCD = MacroDelay

local RADIUS = 80
local ICON = "Interface\\Icons\\INV_Misc_PocketWatch_01"

local function applyPosition(button)
	local angle = math.rad(MCD.db.minimapAngle or 200)
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * RADIUS, math.sin(angle) * RADIUS)
end

local function onDragUpdate(button)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	MCD.db.minimapAngle = math.deg(math.atan2(py - my, px - mx))
	applyPosition(button)
end

local function onClick(self, mouseButton)
	if mouseButton == "LeftButton" then
		MCD:OpenOptions()
	elseif mouseButton == "RightButton" then
		MCD:SetEnabled(not MCD:IsEnabled())
		MCD:Print(MCD:IsEnabled() and "activado" or "desactivado")
	end
end

local function onEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText("MacroDelay")
	GameTooltip:AddLine(MCD:IsEnabled() and "Estado: activado" or "Estado: desactivado", 1, 1, 1)
	GameTooltip:AddLine("Clic izquierdo: abrir opciones", 1, 1, 1)
	GameTooltip:AddLine("Clic derecho: activar/desactivar", 1, 1, 1)
	GameTooltip:AddLine("Arrastrar: mover el icono", 1, 1, 1)
	GameTooltip:Show()
end

-- wcdpanel, con MacroDelay en su barra, oculta este botón y le anula Show para que nadie lo
-- vuelva a enseñar; en ese caso manda wcdpanel.
function MCD:IsMinimapButtonTakenOver()
	return self.minimapButton ~= nil and rawget(self.minimapButton, "Show") ~= nil
end

function MCD:ApplyMinimapVisibility()
	if not self.minimapButton or self:IsMinimapButtonTakenOver() then return end
	if self.db.minimapHidden then
		self.minimapButton:Hide()
	else
		self.minimapButton:Show()
	end
end

MCD:OnDbReady(function()
	local button = CreateFrame("Button", "MacroDelayMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetTexture(ICON)
	icon:SetSize(20, 20)
	icon:SetPoint("CENTER", 0, 1)

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(54, 54)
	border:SetPoint("TOPLEFT", 0, 0)

	button:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", onDragUpdate) end)
	button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)

	MCD.minimapButton = button
	applyPosition(button)
	MCD:ApplyMinimapVisibility()
end)
