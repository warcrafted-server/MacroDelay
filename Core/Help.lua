-- Subcategoría de ayuda dentro del panel de opciones, con la sintaxis y las limitaciones del addon.

local MCD = MacroDelay

local panel = CreateFrame("Frame", "MacroDelayHelpPanel", UIParent)
panel.name = "Ayuda"
panel.parent = "MacroDelay"
panel:Hide()

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("MacroDelay - Ayuda")

local scrollFrame = CreateFrame("ScrollFrame", "MacroDelayHelpScroll", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -32, 16)

local text = scrollFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
text:SetWidth(500)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")
scrollFrame:SetScrollChild(text)

MCD:OnDbReady(function()
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
end)

text:SetText(
	"Macros sin límite de 255 caracteres\n" ..
	"Escribe en la ventana de macros normal (tecla Escape > Macros, o /macro). Al superar 255 " ..
	"caracteres, MacroDelay guarda el texto completo y la macro pasa a llamar a un botón interno " ..
	"que lo ejecuta entero; para el resto del juego se ve y funciona como una macro normal.\n\n" ..
	"Ejecución retardada: /in y /md\n" ..
	"  /in <segundos> <comando>\n" ..
	"  /md <segundos> <comando>\n\n" ..
	"Ejemplos:\n" ..
	"  /in 4 /s Quedan 4 segundos de Himno de Esperanza.\n" ..
	"  /in 1.5 /y ¡Por la Horda!\n\n" ..
	"Se pueden encadenar varias líneas /in dentro de la misma macro para crear una secuencia " ..
	"completa de avisos, emotes o acciones.\n\n" ..
	"Limitaciones importantes\n" ..
	"La API de Blizzard impide saltarse el Global Cooldown (GCD) o forzar habilidades protegidas " ..
	"en combate mediante código, por diseño (anti-automatización). /in funciona siempre para " ..
	"comandos de chat, emotes y macros de rol; en combate, solo es fiable para acciones no " ..
	"protegidas (texto, objetos cosméticos, algunas habilidades sin GCD activo)."
)
