script_author("1NS")
script_name("Absolute Events Helper")
script_description("Assistant for mappers and event makers on Absolute DM")
script_dependencies('imgui', 'lib.samp.events', 'vkeys', 'memory')
script_properties("work-in-pause")
script_url("https://github.com/ins1x/AbsEventHelper")
script_version("0.6")

require 'lib.moonloader'
local keys = require 'vkeys'
local tag = "{00BFFF}Absolute {FFD700}Events {FFFFFF}Helper"
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local memory = require 'memory'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
font = renderCreateFont("Arial", 8, 5)

------------------------[ cfg ] -------------------
local inicfg = require 'inicfg'
local configIni = "AbsEventHelper.ini"
local ini = inicfg.load({
   settings =
   {
      antiafk = true,
      chatfilter = true,
      keybinds = true
   },
   binds =
   {
      textbuffer1 = " ",
	  textbuffer2 = " ",
	  textbuffer3 = " ",
	  textbuffer4 = " ",
	  textbuffer5 = " ",
	  textbuffer6 = " ",
	  textbuffer7 = " ",
	  adtextbuffer = " "
   }
}, configIni)
inicfg.save(ini, configIni)

function save()
    inicfg.save(ini, configIni)
end
---------------------------------------------------------

local sizeX, sizeY = getScreenResolution()
local main_window_state = imgui.ImBool(false)
local moonloaderVersion = getMoonloaderVersion()
local v = nil
local tab = 1

local show_favorites = imgui.ImBool(false)
local show_credits = imgui.ImBool(false)
local show_hotkeys = imgui.ImBool(false)
local show_settings = imgui.ImBool(false)
local show_colors = imgui.ImBool(false)
local show_worldlimits = imgui.ImBool(false)
local show_info = imgui.ImBool(false)
local show_chatfucns = imgui.ImBool(false)
local show_vehs = imgui.ImBool(false)
local show_notepad = imgui.ImBool(false)

--local checkbox_antiafk = imgui.ImBool(true)
local checkbox_antiafk = imgui.ImBool(ini.settings.antiafk)
local checkbox_chatfilter = imgui.ImBool(ini.settings.chatfilter)
local checkbox_keybinds = imgui.ImBool(ini.settings.keybinds)
local checkbox_showobjects = imgui.ImBool(false)
local checkbox_objectcollision = imgui.ImBool(false)

local color = imgui.ImFloat4(1, 0, 0, 1)
local sliderdrawdist = imgui.ImInt(450)
local sliderfog = imgui.ImInt(200)
local vehiclename_buffer = imgui.ImBuffer(128)
local bind_textbuffer1 = imgui.ImBuffer(256)
local bind_textbuffer2 = imgui.ImBuffer(256)
local bind_textbuffer3 = imgui.ImBuffer(256)
local bind_textbuffer4 = imgui.ImBuffer(256)
local bind_textbuffer5 = imgui.ImBuffer(256)
local bind_textbuffer6 = imgui.ImBuffer(256)
local bind_textbuffer7 = imgui.ImBuffer(256)
local bind_adtextbuffer = imgui.ImBuffer(256)
local note_textbuffer = imgui.ImBuffer(1024)

bind_textbuffer1.v = u8(ini.binds.textbuffer1)
bind_textbuffer2.v = u8(ini.binds.textbuffer2)
bind_textbuffer3.v = u8(ini.binds.textbuffer3)
bind_textbuffer4.v = u8(ini.binds.textbuffer4)
bind_textbuffer5.v = u8(ini.binds.textbuffer5)
bind_textbuffer6.v = u8(ini.binds.textbuffer6)
bind_textbuffer7.v = u8(ini.binds.textbuffer7)
bind_adtextbuffer.v = u8(ini.binds.adtextbuffer)
--bind_adtextbuffer.v = u8'Заходите на МП "Название МП" в мир , приз ничего'
--bind_textbuffer2.v = u8"Кто будет мешать проведени и драться - кикну"
--bind_textbuffer3.v = u8"Не тупим разбегаемся по карте"
--bind_textbuffer4.v = u8"Запрещено использовать текстурыне баги"
--bind_textbuffer5.v = u8"Запрещено объеденяться больше двух игроков"

-- If the server changes IP, change it here
local hostip = "193.84.90.23"
local effects = true
local disablealleffects = false
local disableObjectCollision = false
local fps = 0
local fps_counter = 0
local showobjects = false
local tpposX, tpposY, tpposZ
local vehinfomodelid = 0 

VehicleNames = {
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Pereniel", "Sentinel", "Dumper",
	"Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus", "Voodoo", "Pony",
	"Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi",
	"Washington", "Bobcat", "Mr Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
	"Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer",
	"Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit","Romero",
	"Packer", "Monster Truck", "Admiral", "Squalo", "Seasparrow","Pizzaboy",
	"Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic","Flatbed", "Yankee",
	"Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway",
	"RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot",
	"Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
	"Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer",
	"Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax",
	"Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville",
	"Benson", "Mesa", "RC Goblin", "Hotring Racer", "Hotring Racer", "Bloodring Banger",
	"Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle",
	"Cropdust", "Stunt", "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer",
	"Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
	"Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine",
	"Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex",
	"Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
	"Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
	"Yosemite", "Windsor", "Monster Truck", "Monster Truck", "Uranus", "Jester",
	"Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma",
	"Savanna", "Bandito", "Freight", "Trailer", "Kart", "Mower", "Duneride",
	"Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford","BF-400",
	"Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Trailer", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LS)",
	"Police Car (SF)", "Police Car (LV)", "Police Ranger", "Picador", "S.W.A.T. Van",
	"Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer", "Luggage Trailer",
	"Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
}

function imgui.OnDrawFrame()
   if main_window_state.v then
      imgui.SetNextWindowSize(imgui.ImVec2(330, 490), imgui.Cond.FirstUseEver)
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin("Absolute Events Helper", main_window_state)
	
	  if imgui.Button(u8"Настройки") then
		 show_settings.v = not show_settings.v
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"Скрыть все окна") then
	     show_favorites.v = false
		 show_credits.v = false
		 show_hotkeys.v = false
		 show_settings.v = false
		 show_colors.v = false
	     show_worldlimits.v = false
		 show_info.v = false
		 show_chatfucns.v = false
		 show_vehs.v = false
		 show_notepad.v = false
      end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"Свернуть") then
		 main_window_state.v = not main_window_state.v 
      end	  
	  
	  _, pID = sampGetPlayerIdByCharHandle(playerPed)
	  local name = sampGetPlayerNickname(pID)
      local score = sampGetPlayerScore(pID)
	  local ucolor = sampGetPlayerColor(pID)
	  
	  imgui.TextColoredRGB(string.format("Логин: {%0.6x}%s (%d)",
	  bit.band(ucolor,0xffffff), name, pID))
	  
	  -- local servername = sampGetCurrentServerName()
	  -- imgui.TextColoredRGB(string.format("Сервер: {007DFF}%s", servername))
	
	  local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)
	  imgui.Text(string.format(u8"Позиция x: %.1f, y: %.1f, z: %.1f Интерьер: %i",
	  positionX, positionY, positionZ, getActiveInterior()))
	  
	  imgui.Text(string.format(u8"Направление: %s", direction()))
	  
	  local streamedplayers = sampGetPlayerCount(true) - 1
	  imgui.Text(string.format(u8"Игроков в стриме: %i Транспорта: %i FPS: %i",
	  streamedplayers, getVehicleInStream(), fps))
	  
	  if imgui.Checkbox(u8("Отключить коллизию у объектов рядом"), checkbox_objectcollision) then 
	     if checkbox_objectcollision.v then
            disableObjectCollision = true
         else
            disableObjectCollision = false
         end
	  end
	  
	  if imgui.Checkbox(u8("Показывать ID объектов рядом"), checkbox_showobjects) then 
		 if checkbox_showobjects.v  then
            showobjects = true
         else
            showobjects = false
         end
	  end
	  
	  --imgui.Separator()
	  
	  imgui.Text(" ")
	  
	  if imgui.Button(u8"Информация", imgui.ImVec2(250, 25)) then
		 show_info.v = not show_info.v
	  end
	  
	  if imgui.Button(u8"Чат-Бинд", imgui.ImVec2(250, 25)) then
	     show_chatfucns.v = not show_chatfucns.v
	  end
	  
	  if imgui.Button(u8"Транспорт", imgui.ImVec2(250, 25)) then
		 show_vehs.v = not show_vehs.v
	  end
	  
	  if imgui.Button(u8"Получить координаты", imgui.ImVec2(250, 25)) then
	     if not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
		    sampSendChat("/коорд")
			tpposX, tpposY, tpposZ = getCharCoordinates(PLAYER_PED)
			setClipboardText(math.floor(tpposX) .. ' ' .. math.floor(tpposY) .. ' ' .. math.floor(tpposZ))
			sampAddChatMessage("Координаты сохранены в буфер", 0x0FFFFFF)
		 end
	  end
	  
	  if imgui.Button(u8"Телепорт по кординатам", imgui.ImVec2(250, 25)) then
	     --sampSendChat("/тпк " .. tpposX, tpposY, tpposZ, 0x0FFFFFF)
		 if tpposX then
	        sampSendChat(string.format("/ngr %f %f %f", tpposX, tpposY, tpposZ), 0x0FFFFFF)
		    sampAddChatMessage(string.format("Вы были телепортированны на сохранненые координаты %f %f %f"
			,tpposX, tpposY, tpposZ), 0x0FFFFFF)
		 else
		    sampAddChatMessage("Координаты не были сохранены. Нажмите коорд", 0x0FFFFFF)
		 end
	  end
	  
	  if imgui.Button(u8"Прыгнуть вперед", imgui.ImVec2(250, 25)) then
		 if not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/ghsu") end
	  end
	  
	  if imgui.Button(u8"Заметки", imgui.ImVec2(250, 25)) then
		 show_notepad.v = not show_notepad.v
	  end
	  
	  local ip, port = sampGetCurrentServerAddress()
	  if not ip:find(hostip) then
	     imgui.TextColoredRGB("{FF0000}Некоторые функции будут недоступны")
	     imgui.TextColoredRGB("{FF0000}Скрипт предназначен для работы на Absolute Play DM")
	  end
	  
      imgui.End()
   end
   
   if show_info.v then
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 6),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"Информация", show_info)
	  
	  if imgui.Button(u8"Лимиты", imgui.ImVec2(200, 25)) then
		 show_worldlimits.v = not show_worldlimits.v
	  end
	  
	  if imgui.Button(u8"Цвета", imgui.ImVec2(200, 25)) then
		 show_colors.v = not show_colors.v
	  end
	  
	  if imgui.Button(u8"Горячие клавиши", imgui.ImVec2(200, 25)) then
		 show_hotkeys.v = not show_hotkeys.v
	  end
	  
	  if imgui.Button(u8"Избранные объекты", imgui.ImVec2(200, 25)) then
		 show_favorites.v = not show_favorites.v
	  end
	  
	  if imgui.Button(u8"О скрипте", imgui.ImVec2(200, 25)) then
		 show_credits.v = not show_credits.v
	  end
	  
      imgui.End()
   end
	
   if show_favorites.v then
      imgui.SetNextWindowSize(imgui.ImVec2(530, 510), imgui.Cond.FirstUseEver)
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8, sizeY / 4),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"Объекты", show_favorites)
	  
	  if imgui.Button(u8"Основные") then tab = 1 end 
	  imgui.SameLine()
	  if imgui.Button(u8"Специальные") then tab = 2 end
	  imgui.SameLine()
	  if imgui.Button(u8"Эффекты") then tab = 3 end
	  
	  if tab == 1 then
	     imgui.Text(u8"Большие прозрачные объекты для текста: 19481, 19480, 19482, 19477")
         imgui.Text(u8"Маленькие объекты для текста: 19476, 2662")
         imgui.Text(u8"Бетонные блоки: 18766, 18765, 18764, 18763, 18762")
         imgui.Text(u8"Горы: вулкан 18752, песочница 18751, песочные горы ландшафт 19548")
         imgui.Text(u8"Платформы: тонкая платформа 19552, 19538, решетчатая 18753, 18754")
         imgui.Text(u8"Поверхности: 19531, 4242, 4247, 8171, 5004, 16685")
         imgui.Text(u8"Стены: 19355, 19435(маленькая), 19447(длинная), 19391(дверь), 19408(окно)")
	     imgui.Separator()
	     imgui.TextColoredRGB("Не нашли нужный объект? посмотрите на {007DFF}dev.prineside.com")
	  elseif tab == 2 then
		 imgui.Text(u8"Коровка 19833, Веревка 19087, Веревка длин. 19089")
         imgui.Text(u8"Стекло (Разрушаемое) 3858, стекло от травы 3261, сено 3374")
         imgui.Text(u8"Факел с черепом 3524, факел 3461, красный стоп сигнал 3877")
         imgui.Text(u8"Попуг 19079, восточная лампа 3534")
         imgui.Text(u8"Водяная бочка 1554, ржавая бочка 1217, взрыв. бочка 1225")
         imgui.Text(u8"Черная бездна 13656, стеклянный блок 18887")
         imgui.Text(u8"Партикл воды с колизией 19603, большой 19604")
         imgui.Text(u8"Финиш гонки 18761")
	  elseif tab == 3 then
	     imgui.Text(u8"Огонь большой 18691, средний огонь 18692, пламя+дым (исчезает) 18723")
	     imgui.Text(u8"Огонь от огнемета 18694, огонь от машины 18690")
	     imgui.Text(u8"Пар от вентиляции 18736, дым от сигареты 18673, дым с фабрики 18748")
	     imgui.Text(u8"Белый дым 18725, черный дым 18726, большой серый дым 18727")
	     imgui.Text(u8"Большой взрыв 18682, средний взрыв 18683, маленький взрыв 18686")
	     imgui.Text(u8"Спрей 18729, кровь 18668, огнетушитель 18687, слезоточивый 18732")
	     imgui.Text(u8"Рябь на воде 18741, брызги воды 18744")
	     imgui.Text(u8"Фонтан 18739, гидрант 18740, водопад 19841, вода 19842")
         imgui.Text(u8"Искры 18717, горящие дрова 19632")
         imgui.Text(u8"Неон красный 18647, синий 18648, зеленый 18649")
	     imgui.Text(u8"Неон желтый 18650, розовый 18651, белый 18652")
	     imgui.Text(u8"Свет.шар (не моргает) белый 19281, красн. 19282, зел. 19283, синий 19284")
	     imgui.Text(u8"Свет.шар (моргает быстро) белый 19285, красн. 19286, зел. 19287, син. 19288")
	     imgui.Text(u8"Свет.шар (моргает медленно) белый 19289, красн. 19290, зел. 19291, син. 19292")
	     imgui.Text(u8"Свет.шар (моргает медленно) фиолетовый 19293, желтый 19294")
	     imgui.Text(u8"Свет.шар (большой не моргает) бел. 19295, красн. 19296, зел. 19297, син. 19298")
         imgui.Text(u8"Сигнальный огонь 18728, лазер 18643, нитро 18702, флейм 18693")
	  
	     imgui.Separator()
	     if imgui.Button(u8"Отключить дым из труб и прочие эффекты факелов и дыма",
	     imgui.ImVec2(450, 25)) then
		    effects = not effects
		    if effects then
               memory.hex2bin('8B4E08E88B900000', 0x4A125D, 8)
		    else 
 		       memory.fill(0x4A125D, 0x90, 8, true)
		    end
	     end 
	  
	     -- nop all effects render
	     if imgui.Button(u8"Отключить все эффекты (вернуть обратно только релогом)",
	     imgui.ImVec2(450, 25)) then
		    if not disablealleffects then
	           memory.fill(0x53EAD3, 0x90, 5, true)
			   disablealleffects = true
		    end
	     end
		 
	  end
      imgui.End()
   end
	
	if show_colors.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 6, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	   
       imgui.Begin(u8"Цветовая палитра", show_colors)
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
	   imgui.Button("{FF0000}  RED    ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 0.5, 0.0, 1.0))
	   imgui.Button("{008000}  GREEN ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 0.0, 1.0, 1.0))
	   imgui.Button("{0000FF}  BLUE  ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
	   imgui.Button("{FFFF00}  YELLOW", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.0, 1.0, 1.0))
	   imgui.Button("{FF00FF}  PINK  ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 1.0, 1.0))
	   imgui.Button("{00FFFF}  AQUA  ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 0.0, 1.0))
	   imgui.Button("{00FF00}  LIME  ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.0, 0.5, 1.0))
	   imgui.Button("{800080}  PURPLE", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.0, 0.0, 1.0))
	   imgui.Button("{800000}  MAROON", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.5, 0.0, 1.0))
	   imgui.Button("{808000}  OLIVE ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 0.5, 0.5, 1.0))
	   imgui.Button("{008080}  TEAL  ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.6, 0.0, 1.0))
	   imgui.Button("{FF9900}  ORANGE", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.89, 0.76, 1.0))
	   imgui.Button("{FFE4C4}  BISQUE", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
	   imgui.Button("{FFFFFF}  WHITE ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.5, 0.5, 1.0))
	   imgui.Button("{000000}  GREY  ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 0.0, 0.0, 1.0))
	   imgui.Button("{000000}  BLACK ", imgui.ImVec2(300, 20))
	   imgui.PopStyleColor()
	   
	   imgui.TextColoredRGB("Другие цвета {007DFF}https://encycolorpedia.ru/websafe")
	   
	   imgui.Text(u8"RR — красная часть цвета, GG — зеленая, BB — синяя, AA — альфа")
	   imgui.ColorEdit4("", color)
	   imgui.SameLine()
	   imgui.Text("HEX: " ..intToHex(join_argb(color.v[4] * 255, color.v[1] * 255,
	   color.v[2] * 255, color.v[3] * 255)))
	   
	   imgui.End()
	end
    
	if show_chatfucns.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 6, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	   imgui.SetNextWindowSize(imgui.ImVec2(490, 510), imgui.Cond.FirstUseEver)
	   imgui.Begin(u8"Чат", show_chatfucns)
	   
	   imgui.Text(u8"Здесь вы можете настроить чат-бинды для мероприятия")
	   imgui.TextColoredRGB("{00FF00}@ номер игрока - {bababa}заменит id на никнейм игрока")
	   
	   if imgui.InputText("##Bind1", bind_textbuffer1) then 
		  --bind_textbuffer1 = u8:decode(bind_textbuffer1.v)
		  --u8:decode(bind_textbuffer1.v)
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [1]") then
	      u8:decode(bind_textbuffer1.v)
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer1.v)))
	   end
	   
	   if imgui.InputText("##Bind2", bind_textbuffer2) then 
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [2]") then
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer2.v)))
	   end
	   
	   if imgui.InputText("##Bind3", bind_textbuffer3) then 
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [3]") then
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer3.v)))
	   end
	   
	   if imgui.InputText("##Bind4", bind_textbuffer4) then 
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [4]") then
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer4.v)))
	   end
	   
	   if imgui.InputText("##Bind5", bind_textbuffer5) then 
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [5]") then
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer5.v)))
	   end
	   
	   if imgui.InputText("##Bind6", bind_textbuffer6) then 
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [6]") then
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer6.v)))
	   end
	   
	   if imgui.InputText("##Bind7", bind_textbuffer7) then 
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Отправить в мчат [7]") then
	      sampSendChat(string.format("/мчат %s", u8:decode(bind_textbuffer7.v)))
	   end
	   
	   imgui.Text(" ")
	   imgui.Text(u8"Объявления")
	   if imgui.InputText("##BindAd", bind_adtextbuffer) then 
	   end
	   
	   if imgui.Button(u8"Дать объявление в общий чат") then
	      sampSendChat(string.format("* %s", u8:decode(bind_adtextbuffer.v)))
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Дать объявление в /об") then
	      sampSendChat(string.format("/об %s", u8:decode(bind_adtextbuffer.v)))
	   end
	   
	   imgui.Text(" ")
	   
       if imgui.Button(u8("Сохранить")) then
	      ini.binds.textbuffer1 = u8:decode(bind_textbuffer1.v)
	      ini.binds.textbuffer2 = u8:decode(bind_textbuffer2.v)
	      ini.binds.textbuffer3 = u8:decode(bind_textbuffer3.v)
	      ini.binds.textbuffer4 = u8:decode(bind_textbuffer4.v)
	      ini.binds.textbuffer5 = u8:decode(bind_textbuffer5.v)
	      ini.binds.textbuffer6 = u8:decode(bind_textbuffer6.v)
	      ini.binds.textbuffer7 = u8:decode(bind_textbuffer7.v)
	      ini.binds.adtextbuffer = u8:decode(bind_adtextbuffer.v)
		  save()
          if inicfg.save(table1, ini) then
             printStringNow(u8("Сохранено"), 1000)
          end
       end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Очистить все бинды") then
	      bind_textbuffer1.v = " "
	      bind_textbuffer2.v = " "
	      bind_textbuffer3.v = " "
	      bind_textbuffer4.v = " "
	      bind_textbuffer5.v = " "
	      bind_textbuffer6.v = " "
	      bind_textbuffer7.v = " "
		  bind_adtextbuffer.v = " "
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Очистить себе чат") then
		  memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
          memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
          memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
	   end
	   
	   if imgui.Button(u8"Скопировать послед сообщение из чата в буффер (CTRL + C)") then
	       text, prefix, color, pcolor = sampGetChatString(99)
		   setClipboardText(text)
	   end
	   
	   imgui.End()
	end
	
    if show_vehs.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 8),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	   imgui.SetNextWindowSize(imgui.ImVec2(360, 240), imgui.Cond.FirstUseEver)
	   imgui.Begin(u8"Транспорт", show_vehs)
	   
	   -- https://wiki.multitheftauto.com/wiki/Vehicle_IDs
	   imgui.InputText("##BindVehs", vehiclename_buffer)
	   
	   imgui.SameLine()
	   imgui.Text(string.format(u8"ID: %i", vehinfomodelid))
	   
	   local closestcarid = getClosestCarId()
	   imgui.Text(string.format(u8"Ближайший транспорт: %i (внутренний ID)", closestcarid))
	   
	   if isCharInAnyCar(PLAYER_PED) then 
          local carhandle = storeCarCharIsInNoSave(PLAYER_PED)
          local carmodel = getCarModel(carhandle)
		  imgui.Text(string.format(u8"Вы в транспорте: %s(%i)  хп: %i",
		  VehicleNames[carmodel-399], carmodel, getCarHealth(carhandle)))
		  imgui.Text(string.format(u8"Цвет %d и %d", getCarColours(carhandle)))
       end

	  
 	   --imgui.SameLine()
	   --if imgui.Button(u8"Флип") then
	      --if isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/f") end
		  --if isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsCursorActive() then
		  --if isKeyDown(VK_DELETE) then
		  --		addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, -0.15, 0.0)
		  -- elseif isKeyDown(VK_END) then
		  --	addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, 0.15, 0.0)
		  -- end
		  --end
	   --end
	   
	   if imgui.Button(u8"Найти ID транспорта по имени", imgui.ImVec2(320, 25)) then
		  for k, vehname in ipairs(VehicleNames) do
		     if vehname:lower():find(u8:decode(vehiclename_buffer.v:lower())) then
			    vehinfomodelid = 399+k
			    printStringNow(vehinfomodelid, 1000)
			 end 
		  end
	   end
	   
	   if imgui.Button(u8"Заказать машину по имени", imgui.ImVec2(320, 25)) then
	      if not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not  isSampfuncsConsoleActive() then
		     for k, vehname in ipairs(VehicleNames) do
		        if vehname:lower():find(u8:decode(vehiclename_buffer.v:lower())) then
			       vehinfomodelid = 399+k
			    end 
		     end
			 sampSendChat(string.format(u8"/vfibye2 %i", vehinfomodelid))
		  end
	   end
	   
	   if imgui.Button(u8"Заказать машину из списка", imgui.ImVec2(320, 25)) then
	      if not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye2") end
	   end
	   
	   imgui.End()
	end
	
	if show_hotkeys.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 7, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
       imgui.Begin(u8"Горячие клавиши", show_hotkeys)
	   
	   imgui.TextColoredRGB("Доступные только с {FF0000}SAMP ADDON:")
       imgui.TextColoredRGB("{00FF00}Клавиша N{FFFFFF} — меню редактора карт (в полете)")
       imgui.TextColoredRGB("{00FF00}Клавиша J{FFFFFF} — полет в наблюдении (/полет)")
       imgui.TextColoredRGB("{00FF00}Боковые клавиши мыши{FFFFFF} — отменяют и сохраняют редактирование объекта")
       imgui.Text(" ")
       imgui.TextColoredRGB("В режиме редактирования:")
       imgui.TextColoredRGB("{00FF00}Зажатие клавиши ALT{FFFFFF} — скрыть объект")
       imgui.TextColoredRGB("{00FF00}Зажатие клавиши CTRL{FFFFFF} — визуально увеличить объект")
       imgui.TextColoredRGB("{00FF00}Зажатие клавиши SHIFT{FFFFFF} — плавное перемещение объекта")
       imgui.TextColoredRGB("{00FF00}Клавиша RMB (Правая кл.мыши){FFFFFF}  — вернуть объект на исходную позицию")
       imgui.TextColoredRGB("{00FF00}Клавиша Enter{FFFFFF}  — сохранить редактируемый объект")
       imgui.Text(" ")
       imgui.TextColoredRGB("В режиме выделения:")
       imgui.TextColoredRGB("{00FF00}Клавиша RMB (Правая кл.мыши){FFFFFF}  — скопирует номер модели объекта")
       imgui.TextColoredRGB("{00FF00}Клавиша SHIFT{FFFFFF} — переключение между объектами")
       imgui.Text(" ")
	   imgui.TextColoredRGB("Восстановленые скриптом и доступные без {00FF00}SAMP ADDON:")
       imgui.TextColoredRGB("{00FF00}J{FFFFFF} - полет в мире")
       imgui.TextColoredRGB("{00FF00}Z{FFFFFF} - починить транспорт")
       imgui.TextColoredRGB("{00FF00}U{FFFFFF} - анимации")
       imgui.TextColoredRGB("{00FF00}M{FFFFFF} - домашний транспорт")
       imgui.TextColoredRGB("{00FF00}K{FFFFFF} - заказать транспорт")
       imgui.TextColoredRGB("{00FF00}H{FFFFFF} - перевернуть транспорт")
	   imgui.Separator()
	   imgui.Text(u8"Если у вас установлен SAMP ADDON вы можете отключить фикс горячих клавиши в настройках")
       imgui.End()
	end
	
    if show_worldlimits.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 10, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
       imgui.Begin(u8"Лимиты", show_worldlimits)
	   imgui.Text(u8"Каждый игрок от 20 уровня может при наличии свободных слотов создать свой мир для строительства.")
	   imgui.Text(u8"Если все слоты уже были заняты, вы можете воспользоваться любым открытым миром.")
	   imgui.TextColoredRGB("Для создания мира необходимо иметь {00FF00}100 ОА (Очков апгрейда) и 1.000.000$.{FFFFFF}")
       imgui.TextColoredRGB("По умолчанию в мире можно создавать только {00FF00}50 объектов, лимит можно расширить до {00FF00}300{FFFFFF}.")
	   imgui.TextColoredRGB("VIP игроки могут расширять лимит до {00FF00}2000 объектов.{FFFFFF}")
	   imgui.TextColoredRGB("Стоимость расширения мира {00FF00}20 ОА и 500.000$ за 10 объектов.{FFFFFF}") 
	   imgui.TextColoredRGB("Максимальное количество созданных миров {00FF00}500{FFFFFF}.")
	   imgui.TextColoredRGB("При отсутствии на сервере {FF0000}90 дней мир удаляется{FFFFFF}")
	   imgui.Separator()
       imgui.Text(u8"Лимиты в мире")
       imgui.TextColoredRGB("макс. объектов: {00FF00}300 (VIP 2000)")
       imgui.TextColoredRGB("макс. объектов в одной точке: {00FF00}200 ")
       imgui.TextColoredRGB("макс. пикапов: {00FF00}500")
       imgui.TextColoredRGB("макс. маркеров для гонок: {00FF00}40")
       imgui.TextColoredRGB("макс. транспорта: {00FF00}50")
       imgui.TextColoredRGB("макс. слотов под гонки: {00FF00}5")
       imgui.TextColoredRGB("макс. виртуальных миров: {00FF00}500")
	   imgui.Separator()
	   imgui.Text(u8"В радиусе 150 метров нельзя создавать более 200 объектов.")
	   imgui.Text(u8"Максимальная длина текста на объектах в редакторе миров - 50 символов")
       imgui.End()
	end
	
	if show_settings.v then	  
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 7, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	 
       imgui.Begin(u8"Настройки", show_settings)
       if imgui.Checkbox(u8("Фильтр подключений в чате"), checkbox_chatfilter) then
	      if checkbox_chatfilter.v then
	         ini.settings.chatfilter = not ini.settings.chatfilter
			 save()
          end
	   end
	  
   	   if imgui.Checkbox(u8("Анти-афк"), checkbox_antiafk) then 
	      if checkbox_antiafk.v then
			 ini.settings.antiafk = not ini.settings.antiafk
			 save()
		  end
	   end
		
	   if imgui.Checkbox(u8("Фикс горячих клавиш аддона"), checkbox_keybinds) then 
	      if checkbox_keybinds.v then
	         ini.settings.keybinds = not ini.settings.keybinds
			 save()
	      end
	   end
	   
	   if imgui.Button(u8"Обновить конфиг", imgui.ImVec2(200, 25)) then
		  inicfg.save(ini, configIni)
	   end
	   
	   if imgui.Button(u8"Перегрузить скрипт", imgui.ImVec2(200, 25)) then
		  thisScript():reload()
	   end
	   
	   -- Thanks samp++
	   -- imgui.Text(u8"Дальность прорисовки:")
	   -- if imgui.SliderInt(u8"##Drawdist", sliderdrawdist, 50, 3000) then
		  -- sliderdrawdist = sliderdrawdist.v
		  -- memory.setfloat(12044272, sliderdrawdist, true)
	   -- end
		
		-- imgui.Text(u8"Дальность тумана:")
		-- if imgui.SliderInt(u8"##fog", sliderfog, -390, 390) then
		   -- sliderfog = sliderfog.v
		   -- memory.setfloat(13210352, sliderfog, true)
		-- end
			
       imgui.End()
	end
	
	if show_credits.v then	  
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 7, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	   
       imgui.Begin(u8"О скрипте", show_credits)
       imgui.Text(u8"Автор: 1NS (Git: in1x)")
	   --imgui.Text(string.format(u8"Demo version: %s", os.date("%x")))
       imgui.Text(u8"Помошник для мапперов и организаторов мероприятий на Absolute DM")
	   imgui.TextColoredRGB("Homepage: {007DFF}github.com/ins1x/AbsEventHelper")
       imgui.TextColoredRGB("Русскоязычное сообщество мапперов: {007DFF}vk.com\1nsanemapping")
       imgui.TextColoredRGB("Сайт Absolute Play: {007DFF}gta-samp.ru")
       imgui.TextColoredRGB("Чат Absolute Play DM: {007DFF}dsc.gg/absdm")
	   imgui.Text(" ")
       imgui.Text(u8"Credits:")
       imgui.Text(u8"FYP - imgui, SAMP lua library")
       imgui.Text(u8"Gorskin - useful memory hacks")
       imgui.End()
	end
	
	if show_notepad.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeY / 4, sizeY / 2),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	   imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
	   imgui.Begin(u8"Блокнот", show_notepad)
	   
	   imgui.InputTextMultiline('##bufftext', note_textbuffer, imgui.ImVec2(285, 125))

	   if imgui.Button(u8"Сохранить", imgui.ImVec2(85, 25)) then
	      file = io.open(getGameDirectory().."//moonloader//resource//abseventhelper//notes.txt", "w")
          file:write(note_textbuffer.v)
          file:close()
		  printStringNow("Saved moonloader/resource/abseventhelper/notes.txt", 4000)
	   end
	   
	   -- imgui.SameLine()
	   -- if imgui.Button(u8"Загрузить", imgui.ImVec2(120, 25)) then
	      -- file = io.open(getGameDirectory().."//moonloader//resource//abseventhelper//notes.txt", "a")
          -- note_textbuffer.v = file:read("*a")
          -- file:close()
		  -- printStringNow("Loaded", 1000)
	   -- end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Очистить", imgui.ImVec2(85, 25)) then
	      note_textbuffer.v = u8" "
	   end
	   
	   imgui.SameLine()
	   if imgui.Button(u8"Скрыть", imgui.ImVec2(85, 25)) then
	      show_notepad.v = not show_notepad.v
	   end
	   
	   imgui.End()
	end 
end

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
      while not isSampAvailable() do wait(100) end
	  sampAddChatMessage("" .. tag, 0xFFFFFF)
	  local ip, port = sampGetCurrentServerAddress()
	  if not ip:find(hostip) then
	     ini.settings.keybinds = false
	     -- sampAddChatMessage("Keybinds work only Absolute DM", 0x00FF0000)
	  end
	  
	  if not doesDirectoryExist("moonloader/resource/abseventhelper") then 
	     createDirectory("moonloader/resource/abseventhelper")
	  end
	  
	  sampRegisterChatCommand("abshelp", function ()
         main_window_state.v = not main_window_state.v 
	  end)
	  
	  sampRegisterChatCommand("absnote", function ()
         show_notepad.v = not show_notepad.v 
	  end)
	  
	  while true do
	  wait(0)
	  
	  -- Imgui menu
	  imgui.Process = main_window_state.v
	  
	  -- chatfilter
	  function sampev.onServerMessage(color, text)
		if ini.settings.chatfilter then 
			if text:find("подключился к серверу") or text:find("вышел с сервера") then
				chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
				chatlog:write(os.date("[%H:%M:%S] ")..text)
				chatlog:write("\n")
				chatlog:close()
				return false
			end
			
			if text:find("выхода из читмира") then
			   return false
			end
		end
	  end
	  
	  -- copy Nockname to clipboard on click TAB
	  --function sampev.onSendClickPlayer(id)
         --setClipboardText(sampGetPlayerNickname(id))
      --end
	  
	  -- chatfix
	  if isKeyJustPressed(0x54) and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
	     sampSetChatInputEnabled(true)
	  end
	  
	  -- antiafk 
      if ini.settings.antiafk then
         writeMemory(7634870, 1, 1, 1)
         writeMemory(7635034, 1, 1, 1)
         memory.fill(7623723, 144, 8)
         memory.fill(5499528, 144, 6)
	  else
	     memory.setuint8(7634870, 0, false)
         memory.setuint8(7635034, 0, false)
         memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
         memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
	  end
	  
	  -- Absolute Play Key Binds
	  -- Sets hotkeys that are only available with the samp addon
	  if ini.settings.keybinds then
         if isKeyJustPressed(VK_Z) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/xbybnm") end
	 
         if isKeyJustPressed(VK_K) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye2") end

         if isKeyJustPressed(VK_M) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye") end
	  
         if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/anim") end
	  
         if isKeyJustPressed(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/gjktn") end
	  
         if isKeyJustPressed(VK_H) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/f") end
	   
         --if isKeyJustPressed(VK_N) and not sampIsChatInputActive() and not sampIsDialogActive() and not --isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendDialogResponse(1422, 0, 0, " --") end
      end
	  
	  -- ALT+X
      if isKeyDown(VK_MENU) and isKeyJustPressed(VK_X) and not sampIsChatInputActive() and not    sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
         if showobjects then showobjects = false end
		 main_window_state.v = not main_window_state.v 
      end
	  
	  -- ALT+C
      if isKeyDown(VK_CONTROL) and isKeyJustPressed(VK_C) and not sampIsChatInputActive() and not    sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
         text, prefix, color, pcolor = sampGetChatString(99)
		 local text_rus = u8:decode(text, 'CP1251')
		 setClipboardText(text_rus)
		 printStringNow("Last message copied to buffer", 1000)
      end
	  
	  -- Objects render
	  if showobjects and not isPauseMenuActive() then
	     for _, v in pairs(getAllObjects()) do
		    if isObjectOnScreen(v) then
			   local _, x, y, z = getObjectCoordinates(v)
			   local x1, y1 = convert3DCoordsToScreen(x,y,z)
			   local model = getObjectModel(v)
			   renderFontDrawText(font, "{80FFFFFF}" .. model, x1, y1, -1)
			end
		 end
	  end
	  
	  if disableObjectCollision then
         find_obj_x, find_obj_y, find_obj_z = getCharCoordinates(PLAYER_PED)
         result, objectHandle = findAllRandomObjectsInSphere(find_obj_x, find_obj_y, find_obj_z, 25, true)
         if result then
		    setObjectCollision(objectHandle, false)			
			--setObjectCollisionDamageEffect(objectHandle, false)
         end
      else
         find_obj_x, find_obj_y, find_obj_z = getCharCoordinates(PLAYER_PED)
         result, objectHandle = findAllRandomObjectsInSphere(find_obj_x, find_obj_y, find_obj_z, 25, true)
         if result then
            setObjectCollision(objectHandle, true)
			--setObjectCollisionDamageEffect(objectHandle, true)
         end
      end
	  
	  -- END main
   end
end

function direction()
   if sampIsLocalPlayerSpawned() then
      local angel = math.ceil(getCharHeading(PLAYER_PED))
      if angel then
         if (angel >= 0 and angel <= 30) or (angel <= 360 and angel >= 330) then
            return u8"Север"
         elseif (angel > 80 and angel < 100) then
            return u8"Запад"
         elseif (angel > 260 and angel < 280) then
            return u8"Восток"
         elseif (angel >= 170 and angel <= 190) then
            return u8"Юг"
         elseif (angel >= 31 and angel <= 79) then
            return u8"Северо-запад"
         elseif (angel >= 191 and angel <= 259) then
            return u8"Юго-восток"
         elseif (angel >= 81 and angel <= 169) then
            return u8"Юго-запад"
         elseif (angel >= 259 and angel <= 329) then
            return u8"Северо-восток"
         else
            return angel
         end
      else
         return u8"Неизвестно"
      end
   else
      return u8"Неизвестно"
   end
end

function getClosestCarId()
   local minDist = 9999
   local closestId = -1
   local x, y, z = getCharCoordinates(PLAYER_PED)
   for i, k in ipairs(getAllVehicles()) do
      local streamed, carId = sampGetVehicleIdByCarHandle(k)
      if streamed then
         local xi, yi, zi = getCarCoordinates(k)
         local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
         if dist < minDist then
            minDist = dist
            closestId = carId
         end
      end
   end
   return closestId
end

function getVehicleInStream()
	local stream = 0
	for i = 0, 2000 do
		local result, car = sampGetCarHandleBySampVehicleId(i)
		if result then
			stream = stream + 1
		end
	end
	return stream
end

function getObjectsInStream()
	local count = 0
    for _ in pairs(getAllObject()) do count = count + 1 end
    return count
end

lua_thread.create(function()
    while true do
        wait(1000)
        fps = fps_counter
        fps_counter = 0
    end
end)

function onD3DPresent()
    fps_counter = fps_counter + 1
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function intToHex(int)
    return '{'..string.sub(bit.tohex(int), 3, 8)..'}'
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function apply_custom_style()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4

   style.WindowPadding = imgui.ImVec2(15, 15)
   style.WindowRounding = 1.5
   style.FramePadding = imgui.ImVec2(5, 5)
   style.FrameRounding = 4.0
   style.ItemSpacing = imgui.ImVec2(12, 8)
   style.ItemInnerSpacing = imgui.ImVec2(8, 6)
   style.IndentSpacing = 25.0
   style.ScrollbarSize = 15.0
   style.ScrollbarRounding = 9.0
   style.GrabMinSize = 5.0
   style.GrabRounding = 3.0

   colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
   colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
   colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
   colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
   colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
   colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
   colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
   colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
   colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
   colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()