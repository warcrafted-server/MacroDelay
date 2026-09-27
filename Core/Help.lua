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

-- SetScrollChild exige un Frame, no un FontString suelto: el texto va dentro de uno.
local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(500, 1)
scrollFrame:SetScrollChild(scrollChild)

local text = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
text:SetPoint("TOPLEFT")
text:SetWidth(500)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")

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
	"Para comandos de GM (\".\"):\n" ..
	"  /in 4 /run RunGMCommand('gh teleport')\n\n" ..
	"Se pueden encadenar varias líneas /in dentro de la misma macro para crear una secuencia " ..
	"completa de avisos, emotes o acciones.\n\n" ..
	"Limitaciones\n" ..
	"Lo que ejecuta /in lo lanza el addon, no una pulsación tuya, así que Blizzard bloquea todo " ..
	"lo protegido: /cast, /use, cambiar de objetivo, etc., dentro y fuera de combate. Usa /in " ..
	"para chat, emotes, /run y otros comandos no protegidos; lo protegido ponlo en líneas sin /in.\n\n" ..
	"Las macros largas no se pueden guardar en combate.\n\n" ..
	"wcdpanel\n" ..
	"Si MacroDelay está en la barra de wcdpanel, wcdpanel oculta el icono del minimapa. Para " ..
	"recuperarlo, quita MacroDelay de su barra."
)

scrollChild:SetHeight(text:GetStringHeight())
