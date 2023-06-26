script_author("1NS")
script_name("Absolute Events Helper")
script_description("Assistant for mappers and event makers on Absolute DM")
script_dependencies('imgui', 'lib.samp.events', 'vkeys', 'memory')
script_url("vk.com/1nsanemapping")

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
 
local sizeX, sizeY = getScreenResolution()
local main_window_state = imgui.ImBool(false)
local show_favorites = imgui.ImBool(false)
local show_credits = imgui.ImBool(false)
local show_hotkeys = imgui.ImBool(false)
local show_colors = imgui.ImBool(false)
local show_worldlimits = imgui.ImBool(false)
local show_effects = imgui.ImBool(false)
local checkbox_chatfilter = imgui.ImBool(true)
local checkbox_antiafk = imgui.ImBool(true)
local checkbox_keybinds = imgui.ImBool(true)
local checkbox_showobjects = imgui.ImBool(false)
local color = imgui.ImFloat4(1, 0, 0, 1)
local antiafk = true
local chatfilter = true
local keybinds = true
local effects = true
local fps = 0
local fps_counter = 0
local showobjects = false

local function starts_with(str, start)
   return str:sub(1, #start) == start
end 

-- imgui
function imgui.OnDrawFrame()
   if main_window_state.v then
      imgui.SetNextWindowSize(imgui.ImVec2(440, 400), imgui.Cond.FirstUseEver)
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin("Absolute Events Helper", main_window_state)
	 
	  if imgui.Button(u8"������") then
		 show_worldlimits.v = not show_worldlimits.v
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"�����") then
		 show_colors.v = not show_colors.v
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"�������") then
		 show_effects.v = not show_effects.v
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"������� �������") then
		 show_hotkeys.v = not show_hotkeys.v
	  end
		
	  imgui.SameLine()
	  if imgui.Button(u8"� �������") then
		 show_credits.v = not show_credits.v
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"������") then
		 main_window_state.v = not main_window_state.v 
      end
	    
	  --local id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	  --local nickname = sampGetPlayerNickname(id)
	  local servername = sampGetCurrentServerName()
	  imgui.Text(string.format(u8"������: %s", servername))
	
	  local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)
	  imgui.Text(string.format(u8"������� x: %.1f, y: %.1f, z: %.1f ��������: %i",
	  positionX, positionY, positionZ, getActiveInterior()))
	  
	  imgui.Text(string.format(u8"�����������: %s", direction()))
	  imgui.Text(string.format(u8"FPS: %i", fps))
	  
	  local streamedplayers = sampGetPlayerCount(true) - 1
	  imgui.Text(string.format(u8"������� � ������: %i ����������: %i",
	  streamedplayers, getVehicleInStream()))
	  
	  local closestcarid = getClosestCarId()
	  imgui.Text(string.format(u8"��������� ���������: %i", closestcarid))
	  imgui.Separator()
	  
	  --imgui.Text(u8"�������")
	  if imgui.Button(u8"��������� �������") then
		 show_favorites.v = not show_favorites.v
	  end
	  
	  imgui.SameLine()
	  imgui.Checkbox(u8("���������� ID �������� �����"), checkbox_showobjects)
	  if checkbox_showobjects.v then
	     showobjects = not showobjects
	  end
	  
	  imgui.Checkbox(u8("������ ����������� � ����"), checkbox_chatfilter)
	  if checkbox_chatfilter.v then
	     chatfilter = not chatfilter
	  end
	  
	  imgui.Checkbox(u8("����-���"), checkbox_antiafk)
	  if checkbox_antiafk.v then
	     antiafk = not antiafk
	  end
	  
	  imgui.Separator()
	  if imgui.Button(u8"����") then
		 if not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/ghsu") end
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"������") then
	     if not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye") end
	  end
	  
	  imgui.SameLine()
	  if imgui.Button(u8"����") then
	      if isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/f") end
		  --if isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsCursorActive() then
		  --if isKeyDown(VK_DELETE) then
		  --		addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, -0.15, 0.0)
		  -- elseif isKeyDown(VK_END) then
		  --	addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, 0.15, 0.0)
		  -- end
		  --end
	  end
	  
      imgui.End()
   end
   
   if show_favorites.v then
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 4),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"���������", show_favorites)
      imgui.Text(u8"������� ���������� ������� ��� ������: 19481, 19480, 19482, 19477")
      imgui.Text(u8"��������� ������� ��� ������: 19476, 2662")
      imgui.Text(u8"�������: ������� ����� 18691, ������� ����� 18692, �����+��� (��������) 18723")
      imgui.Text(u8"���������� ����� 18728, ����� 18702, ����� 18693")
      imgui.Text(u8"�������� �����: 18766, 18765, 18764, 18763, 18762")
      imgui.Text(u8"����: ������ 18752, ��������� 18751, �������� ���� �������� 19548")
      imgui.Text(u8"���������: ������ ��������� 19552, 19538, ���������� 18753, 18754")
      imgui.Text(u8"�����: 19355, 19435(���������), 19447(�������), 19391(�����), 19408(����)")
	  imgui.Separator()
      imgui.Text(u8"�� ����� ������ ������? ���������� �� dev.prineside.com")
      imgui.End()
	end
	
	if show_colors.v then
	   imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 4),
	   imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
       imgui.Begin(u8"�������� �������", show_colors)
       imgui.TextColoredRGB("{FF0000}RED    {FF0000}FF0000")
       imgui.TextColoredRGB("{008000}GREEN  {008000}008000")
	   imgui.TextColoredRGB("{0000FF}BLUE   {0000FF}0000FF")
	   imgui.TextColoredRGB("{FFFF00}YELLOW {FFFF00}FFFF00")
	   imgui.TextColoredRGB("{FF00FF}PINK   {FF00FF}FF00FF")
	   imgui.TextColoredRGB("{00ffff}AQUA   {00ffff}00FFFF")
	   imgui.TextColoredRGB("{00ff00}LIME   {00ff00}00FF00")
	   imgui.TextColoredRGB("{800080}PURPLE {800080}800080")
	   imgui.TextColoredRGB("{FFFFFF}WHITE  {FFFFFF}FFFFFF")
	   imgui.TextColoredRGB("{808080}GREY   {808080}808080")
	   imgui.TextColoredRGB("{363636}BLACK  {363636}000000")
	   imgui.ColorEdit4("", color)
	   imgui.SameLine()
	   imgui.Text("HEX: " ..intToHex(join_argb(color.v[4] * 255, color.v[1] * 255,
	   color.v[2] * 255, color.v[3] * 255)))
	   imgui.Separator()
	   imgui.End()
	end
	
	if show_hotkeys.v then
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 4),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"������� �������", show_hotkeys)
      imgui.Text(u8"J - ����� � ����")
      imgui.Text(u8"Z - �������� ���������")
      imgui.Text(u8"U - ��������")
      imgui.Text(u8"M - �������� ���������")
      imgui.Text(u8"K - �������� ���������")
      imgui.Text(u8"H - ����������� ���������")
	  imgui.Separator()
	  imgui.Text(u8"���� � ��� ���������� Samp Addon �� ������ ��������� ������� �������")
	  imgui.Checkbox(u8("������� �������"), checkbox_keybinds)
	  if checkbox_keybinds.v then
	     keybinds = not keybinds
	  end
	  -- local test_text_buffer = imgui.ImBuffer(256)
	  -- if imgui.InputText(u8"������� ����� ����", test_text_buffer) then 
		 -- u8:decode(test_text_buffer.v)
	  -- end
	  -- imgui.Text(u8"�������� �����: " .. test_text_buffer.v)
	  
      imgui.End()
	end
	
    if show_worldlimits.v then
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 4),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"������", show_worldlimits)
	  imgui.Text(u8"������ ����� �� 20 ������ ����� ��� ������� ��������� ������ ������� ���� ��� ��� �������������.")
	  imgui.Text(u8"���� ��� ����� ��� ���� ������, �� ������ ��������������� ����� �������� �����.")
	  imgui.Text(u8"��� �������� ���� ���������� ����� 100 �� (����� ��������) � 1.000.000$.")
      imgui.Text(u8"�� ��������� � ���� ����� ��������� ������ 50 ��������, ����� ����� ��������� �� 300.")imgui.Text(u8"VIP ������ ����� ��������� ����� �� 2000 ��������.")
	  imgui.Text(u8"��������� ���������� ���� 20 �� � 500.000$ �� 10 ��������.") 
	  imgui.Text(u8"������������ ���������� ��������� ����� 500. ��� ���������� �� ������� 90 ���� ��� ���������")
	  imgui.Separator()
      imgui.Text(u8"������ � ����")
      imgui.Text(u8"����. ��������: 300 (VIP 2000)")
      imgui.Text(u8"����. �������� � ����� �����: 200 ")
      imgui.Text(u8"����. �������: 500")
      imgui.Text(u8"����. �������� ��� �����: 40")
      imgui.Text(u8"����. ����������: 50")
      imgui.Text(u8"����. ������ ��� �����: 5")
      imgui.Text(u8"����. ����������� �����: 500")
	  imgui.Separator()
	  imgui.Text(u8"� ������� 150 ������ ������ ��������� ����� 200 ��������.")
	  imgui.Text(u8"������������ ����� ������ �� �������� � ��������� ����� - 50 ��������")
      imgui.End()
	end
	
	if show_effects.v then	  
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 4),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"�������", show_credits)
	  if imgui.Button(u8"��������� ��� �� ���� � ������ ������� �� ���� �������, ������� �������.") then
		 effects = not effects
		 if effects then
            memory.hex2bin('8B4E08E88B900000', 0x4A125D, 8)
		 else 
		    memory.fill(0x4A125D, 0x90, 8, true)
		 end
	  end 
	  
	  -- disable wind effects
	  if imgui.Button(u8"��������� ������ �������� �� ����� ����� � �������� �����") then
	     memory.fill(0x535030, 0x90, 5, true)
	  end
	  
	  -- nop all effects render
	  if imgui.Button(u8"��������� ��� �������") then
	     memory.fill(0x53EAD3, 0x90, 5, true)
	  end
	  
      imgui.End()
	end
	
	if show_credits.v then	  
	  imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 4),
	  imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  
      imgui.Begin(u8"� �������", show_credits)
      imgui.Text(u8"�����: 1NS (Git: in1x)")
	  --imgui.Text(string.format(u8"Demo version: %s", os.date("%x")))
      imgui.Text(u8"�������� ��� �������� � ������������� ����������� �� Absolute DM")
      imgui.Text(u8"Homepage: ������������� ���������� ��������: vk.com\1nsanemapping")
      imgui.Text(u8"Credits:")
      imgui.Text(u8"FYP - imgui and SAMP lua library")
      imgui.Text(u8"MOL - antiafk")
      imgui.Text(u8"Gorskin - useful memory hacks")
      imgui.End()
	end
	
end

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
      while not isSampAvailable() do wait(100) end
      sampAddChatMessage("" .. tag, 0xFFFFFF)
	  while true do
	  wait(0)
	  
	  -- Imgui menu
	  imgui.Process = main_window_state.v
	  
	  -- chatfilter
	  function sampev.onServerMessage(color, text)
		if chatfilter then 
			if starts_with(text, "�����") then
				chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
				chatlog:write(os.date("[%H:%M:%S] ")..text)
				chatlog:write("\n")
				chatlog:close()
				return false
			end
		end
	  end
		
	  -- chatfix
	  if isKeyJustPressed(0x54) and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
	     sampSetChatInputEnabled(true)
	  end
	  
	  -- antiafk 
      if antiafk then
         writeMemory(7634870, 1, 1, 1)
         writeMemory(7635034, 1, 1, 1)
         memory.fill(7623723, 144, 8)
         memory.fill(5499528, 144, 6)
	  end
	  
	  -- Absolute Play Key Binds
	  -- Sets hotkeys that are only available with the samp addon
	  if keybinds then
         if isKeyJustPressed(VK_Z) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/xbybnm") end
	 
         if isKeyJustPressed(VK_K) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye2") end

         if isKeyJustPressed(VK_M) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye") end
	  
         if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/anim") end
	  
         if isKeyJustPressed(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/gjktn") end
	  
         if isKeyJustPressed(VK_H) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/f") end
	   
         --if isKeyJustPressed(VK_N) and not sampIsChatInputActive() and not sampIsDialogActive() and not --isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendDialogResponse(1422, 0, 0, " --") end
      end
	  
      if isKeyJustPressed(VK_X) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
         main_window_state.v = not main_window_state.v 
      end
	  
	  sampRegisterChatCommand("abshelp", function ()
         main_window_state.v = not main_window_state.v 
	  end)
	  
	  if showobjects then
	     for _, v in pairs(getAllObjects()) do
		    if isObjectOnScreen(v) then
			   local _, x, y, z = getObjectCoordinates(v)
			   local x1, y1 = convert3DCoordsToScreen(x,y,z)
			   local model = getObjectModel(v)
			   renderFontDrawText(font, "{80FFFFFF}" .. model, x1, y1, -1)
			end
		 end
	  end
		
   end
end

function direction()
   if sampIsLocalPlayerSpawned() then
      local angel = math.ceil(getCharHeading(PLAYER_PED))
      if angel then
         if (angel >= 0 and angel <= 30) or (angel <= 360 and angel >= 330) then
            return u8"�����"
         elseif (angel > 80 and angel < 100) then
            return u8"�����"
         elseif (angel > 260 and angel < 280) then
            return u8"������"
         elseif (angel >= 170 and angel <= 190) then
            return u8"��"
         elseif (angel >= 31 and angel <= 79) then
            return u8"������-�����"
         elseif (angel >= 191 and angel <= 259) then
            return u8"���-������"
         elseif (angel >= 81 and angel <= 169) then
            return u8"���-�����"
         elseif (angel >= 259 and angel <= 329) then
            return u8"������-������"
         else
            return angel
         end
      else
         return u8"����������"
      end
   else
      return u8"����������"
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