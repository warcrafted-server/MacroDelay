-- Botón para barras LibDataBroker como wcdpanel. MacroDelay no incluye la librería: usa la que
-- cargue la barra, así que el objeto se crea en PLAYER_LOGIN, cuando ya han cargado todos los addons.

local MCD = MacroDelay

local function createDataObject()
	local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
	if not LDB or LDB:GetDataObjectByName("MacroDelay") then return end

	LDB:NewDataObject("MacroDelay", {
		type = "launcher",
		label = "MacroDelay",
		icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
		OnClick = function(_, button)
			if button == "RightButton" then
				MCD:SetEnabled(not MCD:IsEnabled())
				MCD:Print(MCD:IsEnabled() and "activado" or "desactivado")
			else
				MCD:OpenOptions()
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("MacroDelay")
			tooltip:AddLine(MCD:IsEnabled() and "Estado: activado" or "Estado: desactivado", 1, 1, 1)
			tooltip:AddLine("Clic izquierdo: abrir opciones", 1, 1, 1)
			tooltip:AddLine("Clic derecho: activar/desactivar", 1, 1, 1)
		end,
	})
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	createDataObject()
end)
