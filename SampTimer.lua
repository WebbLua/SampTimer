script_name('Samp Timer')
script_author("Lavrentiy_Beria | Telegram: @Imykhailovich")
local moonloader = require "moonloader"
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local sounds

local font = renderCreateFont("times", 40, 12)

local time_ini
local config = {timer = {time = 0, brauchenmsg = false}}

if time_ini == nil then -- загружаем конфиг
	time_ini = inicfg.load(config, "SampTimer")
	inicfg.save(time_ini, "SampTimer")
end

local UmWieVieleSek = tonumber(time_ini.timer.time)
local brauchenmsg = time_ini.timer.brauchenmsg
local zustand = false

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sounds.loadSound("alarm")
	sampRegisterChatCommand('timer', cmd_timer)
	sampRegisterChatCommand('alarm', cmd_alarm)
	while true do 
		wait(0)
		if UmWieVieleSek == os.time() then
			zustand = true
		end
		if zustand then
			if brauchenmsg then 
				sampAddChatMessage("ВНИМАНИЕ, СРАБОТАЛ ТАЙМЕР! ВСТАВАЙ БЛЯТЬ БЫСТРЕЕ! ОТКЛЮЧИТЬ СИГНАЛ - /ALARM", 0xFF800000) 
				sampAddChatMessage("ВНИМАНИЕ, СРАБОТАЛ ТАЙМЕР! ВСТАВАЙ БЛЯТЬ БЫСТРЕЕ! ОТКЛЮЧИТЬ СИГНАЛ - /ALARM", 0xFF800000)
				sampAddChatMessage("ВНИМАНИЕ, СРАБОТАЛ ТАЙМЕР! ВСТАВАЙ БЛЯТЬ БЫСТРЕЕ! ОТКЛЮЧИТЬ СИГНАЛ - /ALARM", 0xFF800000)
				sounds.play("alarm") 
				brauchenmsg = false 
			end
			local w, h = getScreenResolution()
			local sizeX, sizeY = 500, 200
			renderDrawBox(w/2 - sizeX/2, h/2 - sizeY/2, sizeX, sizeY, 0xFF800000)
			local text = "Пропиши /ALARM"
			renderFontDrawText(font, text, w/2 - renderGetFontDrawTextLength(font, text)/2, h/2 - renderGetFontDrawHeight(font, text)/2, -1)
		end
	end
end

function cmd_timer(t)
	local h, m
	h, m = t:match("^(%d+):(%d+)$")
	m = m == nil and t:match("^(%d+)$") or m
	if m == nil then sampAddChatMessage("Неправильно установлено время! Пропишите /time [через min] или [hh:mm]", -1) return end
	if h == nil then
		local min = m:match("^0(%d)$") and tonumber(m:match("^0(%d)$")) or tonumber(m)
		UmWieVieleSek = (os.time() + min * 60) - os.date("%S", os.time())
		time_ini.timer.time = UmWieVieleSek
		brauchenmsg = true
		time_ini.timer.brauchenmsg = brauchenmsg
		inicfg.save(time_ini, "SampTimer")
		sampAddChatMessage("Таймер сработает в " .. os.date("%H:%M", UmWieVieleSek) .. " по времени вашего ПК", -1)
		else
		local hour = h:match("^0(%d)$") and tonumber(h:match("^0(%d)$")) or tonumber(h)
		local min = m:match("^0(%d)$") and tonumber(m:match("^0(%d)$")) or tonumber(m)
		local datum = {}
		datum.year, datum.month, datum.day, datum.hour, datum.min = os.date("%Y", os.time()), os.date("%m", os.time()), os.date("%d", os.time()), tostring(hour), tostring(min)
		UmWieVieleSek = os.time(datum)
		if os.difftime(UmWieVieleSek, os.time()) <= 0 then sampAddChatMessage("Установленное время меньше чем текущее!", -1) return end
		time_ini.timer.time = UmWieVieleSek
		brauchenmsg = true
		time_ini.timer.brauchenmsg = brauchenmsg
		inicfg.save(time_ini, "SampTimer")
		sampAddChatMessage("Таймер сработает в " .. os.date("%H:%M", UmWieVieleSek) .. " по времени вашего ПК", -1)
	end
end

function cmd_alarm()
	if not zustand then sampAddChatMessage("Таймер/будильник неактивен!", -1) return end
	zustand = false
	setAudioStreamState(sounds.list["alarm"], moonloader.audiostream_state.STOP)
	sampAddChatMessage("Таймер/будильник был выключен!", -1)
end

sounds = {list = {}}
function sounds.loadSound(soundName)
	sounds.list[soundName] = loadAudioStream(getWorkingDirectory() .. "/SampTimer/" .. soundName ..".mp3")
end

function sounds.play(soundName) 
	if sounds.list[soundName] then
		setAudioStreamVolume(sounds.list[soundName], 1)
		setAudioStreamState(sounds.list[soundName], moonloader.audiostream_state.PLAY)
	end
end