-- Publica un data object LibDataBroker-1.1 para que barras como wcdpanel (plugin LDB) puedan
-- mostrar MacroDelay como un botón más, sin que este addon dependa de wcdpanel para nada.

local MCD = MacroDelay
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)

if not LDB then return end

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
