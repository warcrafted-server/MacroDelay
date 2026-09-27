-- /in y /md: ejecuta un comando de barra tras un retraso, sin depender de AceTimer. La cola vive
-- en un solo frame con OnUpdate, como wcdpanel/Core/Scheduler.lua.

local MCD = MacroDelay

local queue = {}

local ticker = CreateFrame("Frame")
ticker:SetScript("OnUpdate", function(self, elapsed)
	if #queue == 0 then return end

	local i = 1
	while i <= #queue do
		local entry = queue[i]
		entry.remaining = entry.remaining - elapsed
		if entry.remaining <= 0 then
			table.remove(queue, i)
			entry.fn()
		else
			i = i + 1
		end
	end
end)

local function findSlashHandler(slash)
	slash = slash:lower()
	for name in pairs(SlashCmdList) do
		local i = 1
		while true do
			local candidate = _G["SLASH_" .. name .. i]
			if not candidate then break end
			if candidate:lower() == slash then
				return SlashCmdList[name]
			end
			i = i + 1
		end
	end
end

-- El servidor intercepta comandos de GM (".") en cuanto ve un "." seguido de letras en el texto
-- de la macro, en el instante en que se pulsa el botón, antes de que /in llegue a procesarlo. Por
-- eso un "." literal en la macro (incluso escapado) dispara el comando de golpe. La única forma
-- de evitarlo es no tener nunca un "." + letras en el texto de la macro: se pide como
-- /run RunGMCommand('comando') y el punto se añade aquí, cuando la macro ya se ha ejecutado.
function RunGMCommand(gmCommand)
	local editBox = ChatFrame1EditBox
	local wasShown = editBox:IsShown()
	local previousText = editBox:GetText()
	editBox:SetText("." .. gmCommand)
	ChatEdit_SendText(editBox, 0)
	if wasShown then
		editBox:SetText(previousText)
	end
end

local function runCommand(command)
	local slash, rest = command:match("^(/%S+)%s*(.*)$")
	if not slash then
		MCD:Print("comando retrasado no reconocido (debe empezar por '/'): " .. command)
		return
	end
	local handler = findSlashHandler(slash)
	if handler then
		handler(rest)
	else
		MCD:Print("comando desconocido: " .. slash)
	end
end

local function scheduleCommand(seconds, command)
	table.insert(queue, { remaining = seconds, fn = function() runCommand(command) end })
end

local function delayedCommand(msg)
	if not MCD:IsEnabled() then
		MCD:Print("addon desactivado (revisa las opciones)")
		return
	end

	local secs, command = msg:match("^%s*([%d%.]+)%s+(.+)$")
	secs = tonumber(secs)
	if not secs or not command or #command == 0 then
		MCD:Print("uso: /in <segundos> <comando>")
		MCD:Print("ejemplo: /in 1.5 /say hola")
		return
	end

	scheduleCommand(secs, command)
end

SLASH_MACRODELAY_IN1 = "/in"
SLASH_MACRODELAY_IN2 = "/md"
SlashCmdList.MACRODELAY_IN = delayedCommand

-- Algunos clientes modificados registran su propio "/in" tras cargar los addons y nos lo pisan.
-- Se reafirma tras entrar al mundo para que gane el nuestro, sea cual sea el orden de carga.
local reassert = CreateFrame("Frame")
reassert:RegisterEvent("PLAYER_ENTERING_WORLD")
reassert:SetScript("OnEvent", function(self)
	SLASH_MACRODELAY_IN1 = "/in"
	SlashCmdList.MACRODELAY_IN = delayedCommand
	self:UnregisterAllEvents()
end)
