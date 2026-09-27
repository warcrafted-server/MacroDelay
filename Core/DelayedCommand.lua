-- /in <segundos> <comando> (alias /md): ejecuta un comando pasado un tiempo.

local MCD = MacroDelay

-- En 3.3.5 los tipos de chat y los emotes no están en SlashCmdList: los resuelve
-- ChatEdit_ParseText a partir de las cadenas SLASH_<TIPO>n y EMOTEn_CMDm.
local CHAT_TYPES = { "SAY", "YELL", "PARTY", "RAID", "RAID_WARNING", "BATTLEGROUND", "GUILD",
	"OFFICER", "EMOTE", "WHISPER", "REPLY" }
local MAX_EMOTE_INDEX = 600

local function isAlias(key, command)
	local i = 1
	local alias = _G["SLASH_" .. key .. i]
	while alias do
		if alias:upper() == command then return true end
		i = i + 1
		alias = _G["SLASH_" .. key .. i]
	end
	return false
end

local emoteTokens
local function emoteToken(command)
	if not emoteTokens then
		emoteTokens = {}
		-- la numeración de EMOTEn tiene huecos: no se puede parar en el primero que falte
		for i = 1, MAX_EMOTE_INDEX do
			local token = _G["EMOTE" .. i .. "_TOKEN"]
			local j = 1
			local alias = _G["EMOTE" .. i .. "_CMD" .. j]
			while token and alias do
				emoteTokens[alias:upper()] = token
				j = j + 1
				alias = _G["EMOTE" .. i .. "_CMD" .. j]
			end
		end
	end
	return emoteTokens[command]
end

local function sendChat(chatType, msg)
	if not msg:find("%S") then return end
	if chatType == "WHISPER" then
		local target, text = msg:match("^(%S+)%s+(.+)$")
		if not target then
			MCD:Print("Falta el destinatario o el mensaje del susurro.")
			return
		end
		SendChatMessage(text, "WHISPER", nil, target)
	elseif chatType == "REPLY" then
		local target = ChatEdit_GetLastTellTarget and ChatEdit_GetLastTellTarget()
		if target and target ~= "" then
			SendChatMessage(msg, "WHISPER", nil, target)
		end
	else
		SendChatMessage(msg, chatType)
	end
end

local function findSlashHandler(command)
	local handler = hash_SlashCmdList and hash_SlashCmdList[command]
	if handler then return handler end
	for key, fn in pairs(SlashCmdList) do
		if isAlias(key, command) then return fn end
	end
end

local function isSecureCommand(command)
	for key in pairs(SecureCmdList or {}) do
		if isAlias(key, command) then return true end
	end
	return false
end

local function execute(line)
	local command, msg = line:match("^(/%S+)%s*(.-)%s*$")
	if not command then return end
	local upper = command:upper()

	local channel = tonumber(upper:match("^/(%d+)$"))
	if channel then
		if GetChannelName(channel) > 0 and msg:find("%S") then
			SendChatMessage(msg, "CHANNEL", nil, channel)
		end
		return
	end

	for _, chatType in ipairs(CHAT_TYPES) do
		if isAlias(chatType, upper) then return sendChat(chatType, msg) end
	end

	if isSecureCommand(upper) then
		MCD:Print(command .. " es un comando protegido: Blizzard no deja lanzarlo desde /in.")
		return
	end

	local handler = findSlashHandler(upper)
	if handler then
		return handler(msg, DEFAULT_CHAT_FRAME.editBox)
	end

	local token = emoteToken(upper)
	if token then
		return DoEmote(token, msg)
	end

	MCD:Print("Comando desconocido: " .. command)
end

local queue, clock, sequence = {}, 0, 0
local timer = CreateFrame("Frame")
timer:Hide()

timer:SetScript("OnUpdate", function(self, elapsed)
	clock = clock + elapsed
	local due = {}
	for i = #queue, 1, -1 do
		if queue[i].at <= clock then
			table.insert(due, table.remove(queue, i))
		end
	end
	table.sort(due, function(a, b)
		if a.at ~= b.at then return a.at < b.at end
		return a.seq < b.seq
	end)
	for _, job in ipairs(due) do
		local ok, err = pcall(execute, job.command)
		if not ok then geterrorhandler()(err) end
	end
	if #queue == 0 then self:Hide() end
end)

local function schedule(delay, command)
	sequence = sequence + 1
	table.insert(queue, { at = clock + delay, seq = sequence, command = command })
	timer:Show()
end

local function parseDelay(text)
	text = text:gsub(",", ".")
	if text:match("^%d+%.?%d*$") or text:match("^%.%d+$") then
		return tonumber(text)
	end
end

local function slashIn(msg)
	local delayText, command = (msg or ""):match("^%s*(%S+)%s+(/.-)%s*$")
	local delay = delayText and parseDelay(delayText)
	if not delay then
		MCD:Print("Uso: /in <segundos> <comando>   (también /md)")
		MCD:Print("Ejemplo: /in 1.5 /s ¡Por la Horda!")
		return
	end
	if not MCD:IsEnabled() then
		MCD:Print("El addon está desactivado: no se programa nada.")
		return
	end
	schedule(delay, command)
end

-- Algunos clientes modificados registran su propio /in después de cargar los addons.
local function claimSlash()
	SLASH_MACRODELAY_IN1 = "/in"
	SLASH_MACRODELAY_IN2 = "/md"
	SlashCmdList.MACRODELAY_IN = slashIn
	if hash_SlashCmdList then
		hash_SlashCmdList["/IN"] = slashIn
		hash_SlashCmdList["/MD"] = slashIn
	end
end

claimSlash()

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", claimSlash)

-- El servidor trata como comando cualquier "." seguido de letras que haya en el texto de la
-- macro al pulsarla; por eso el punto se añade aquí, al ejecutar, y no en la macro.
function RunGMCommand(cmd)
	cmd = tostring(cmd or ""):gsub("^[%s%.]+", "")
	if cmd == "" then return end
	SendChatMessage("." .. cmd, "SAY")
end
