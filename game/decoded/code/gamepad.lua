ctrl_mode = "move"
prev_mode = {}
console_sheet = "console_PC"

local is_move_mode = {
	move_hypnosis = true,
	move_wings = true,
	move_soul = true,
	move_black = true,
}
local is_select_mode = {
	ask_piece = true,
	strafe = true,
	orb = true,
	info = true
}


if PC then
	mouse("show", true)

	local _rumble = rumble
	rumble = function(...)
		if (MOUSE and not SD_PAD) or not RUMBLE then return end
		_rumble(...)
	end
else
	rumble = function(...)
		if not RUMBLE then return end
		ctrlr("rumble", ...)
	end
end

local gamepad_layouts = {
	Xbox = {
		butInfo = {
			validate =      {x=27, y=19, w=9 , h=10},
			cancel =        {x=35, y=19, w=9 , h=10},
			shoot =         {x=13, y=0 , w=14, h=9 },
			special =       {x=43, y=19, w=9 , h=10},
			reload =        {x=51, y=19, w=9 , h=10},

			pause =         {x=59, y=29, w=9 , h=10},
			info =          {x=67, y=29, w=9 , h=10},

			["leftStickY-"]={x=27, y=0 , w=9 , h=10},
			["leftStickX+"]={x=35, y=0 , w=9 , h=10},
			["leftStickY+"]={x=43, y=0 , w=9 , h=10},
			["leftStickX-"]={x=51, y=0 , w=9 , h=10},

			leftPage =      {x=0 , y=18, w=12, h=7 },
			rightPage =     {x=11, y=18, w=12, h=7 },

			--sticks
			bgStick =       {x=60, y=0 , w=11, h=11},
			leftStick =     {x=60, y=11, w=9 , h=9 },
			lstickb =       {x=60, y=11, w=9 , h=9 },
			rightStick =    {x=68, y=11, w=9 , h=9 },
			rstickb =       {x=68, y=11, w=9 , h=9 },
			
			
			spacebar = {x=51, y=19, w=9 , h=10},
			escape = {x=59, y=29, w=9 , h=10},
			cursor = {x=16, y=40, w=6, h=8 },
		},
		CONFIRM_BUTTON="A",
		SPECIAL_BUTTON="X",
		RELOAD_BUTTON="Y",
		SHOOT_BUTTON="RT",
		--RUMBLE_INTENSITY_L=0.8,
		--RUMBLE_INTENSITY_R=0.8,
		--RUMBLE_TIMER=250,

		INPUT_ASSIGNEMENT = [[
			validate> c:a
			cancel> c:b
			shoot> c:rtrigger
			special> c:x
			reload> c:y
			unsafe> c:ltrigger

			pause> c:start
			info> c:back
			leftPage> c:lshoulder
			rightPage> c:rshoulder

			leftStickX-> c:lstick:left, c:dpad:left
			leftStickX+> c:lstick:right, c:dpad:right
			leftStickY-> c:lstick:up, c:dpad:up
			leftStickY+> c:lstick:down, c:dpad:down
			rightStickX-> c:rstick:left
			rightStickX+> c:rstick:right
			rightStickY-> c:rstick:up
			rightStickY+> c:rstick:down

			lstickb> c:lstickb
			rstickb> c:rstickb
		]]
	},
	
	PS = {
		butInfo = {
			validate =      {x=27, y=19, w=9 , h=10},
			cancel =        {x=35, y=19, w=9 , h=10},
			shoot =         {x=13, y=0 , w=14, h=9 },
			special =       {x=43, y=19, w=9 , h=10},
			reload =        {x=51, y=19, w=9 , h=10},

			pause = 				{x=27, y=39, w=25, h=12},
			info =          {x=0 , y=32, w=15, h=8 },
			
			["leftStickX-"]={x=27, y=0 , w=9 , h=10},
			["leftStickY+"]={x=35, y=0 , w=9 , h=10},
			["leftStickX+"]={x=43, y=0 , w=9 , h=10},
			["leftStickY-"]={x=51, y=0 , w=9 , h=10},

			leftPage =      {x=0 , y=18, w=12, h=7 },
			rightPage =     {x=11, y=18, w=12, h=7 },

			--sticks
			bgStick =       {x=60, y=0 , w=11, h=11},
			leftStick =     {x=60, y=11, w=9 , h=9 },
			lstickb =       {x=60, y=11, w=9 , h=9 },
			rightStick =    {x=68, y=11, w=9 , h=9 },
			rstickb =       {x=68, y=11, w=9 , h=9 },
		},
		-- ⓵⓶⓷⓸
		CONFIRM_BUTTON="⓵",
		SPECIAL_BUTTON="⓶",
		RELOAD_BUTTON="⓸",
		SHOOT_BUTTON="R2",
		--RUMBLE_INTENSITY_L=1.0,
		--RUMBLE_INTENSITY_R=0.8,
		--RUMBLE_TIMER=200,

		INPUT_ASSIGNEMENT = [[
			shoot> c:R2
			special> c:square
			reload> c:triangle
			unsafe> c:L2
			
			pause> c:options
			info> c:touchpad
			leftPage> c:L1
			rightPage> c:R1

			leftStickX-> c:lstick:left, c:dpad:left
			leftStickX+> c:lstick:right, c:dpad:right
			leftStickY-> c:lstick:up, c:dpad:up
			leftStickY+> c:lstick:down, c:dpad:down
			rightStickX-> c:rstick:left
			rightStickX+> c:rstick:right
			rightStickY-> c:rstick:up
			rightStickY+> c:rstick:down

			lstickb> c:L3
			rstickb> c:R3
		]]
	},
	
	NX = {
		butInfo = {
			validate =      {x=27, y=19, w=9 , h=10},
			cancel =        {x=35, y=19, w=9 , h=10},
			shoot =         {x=13, y=0 , w=14, h=9 },
			special =       {x=43, y=19, w=9 , h=10},
			reload =        {x=51, y=19, w=9 , h=10},

			pause =         {x=60, y=29, w=7 , h=8 },
			info =          {x=67, y=29, w=7 , h=4 },

			["leftStickX-"]={x=27, y=0 , w=9 , h=10},
			["leftStickY+"]={x=35, y=0 , w=9 , h=10},
			["leftStickX+"]={x=43, y=0 , w=9 , h=10},
			["leftStickY-"]={x=51, y=0 , w=9 , h=10},

			leftPage =      {x=0 , y=18, w=12, h=7 },
			rightPage =     {x=11, y=18, w=12, h=7 },

			--sticks
			bgStick =       {x=60, y=0 , w=11, h=11},
			leftStick =     {x=60, y=11, w=9 , h=9 },
			lstickb =       {x=60, y=11, w=9 , h=9 },
			rightStick =    {x=68, y=11, w=9 , h=9 },
			rstickb =       {x=68, y=11, w=9 , h=9 },
		},
		CONFIRM_BUTTON="A",
		SPECIAL_BUTTON="X",
		RELOAD_BUTTON="Y",
		SHOOT_BUTTON="ZR",
		--RUMBLE_INTENSITY_L=0.7,
		--RUMBLE_INTENSITY_R=0.7,
		--RUMBLE_TIMER=200,

		INPUT_ASSIGNEMENT = [[
			validate> c:a
			cancel> c:b
			shoot> c:rtrigger
			special> c:x
			reload> c:y
			unsafe> c:ltrigger
			
			pause> c:plus
			info> c:minus
			leftPage> c:lshoulder
			rightPage> c:rshoulder

			leftStickX-> c:lstick:left, c:dpad:left
			leftStickX+> c:lstick:right, c:dpad:right
			leftStickY-> c:lstick:up, c:dpad:up
			leftStickY+> c:lstick:down, c:dpad:down
			rightStickX-> c:rstick:left
			rightStickX+> c:rstick:right
			rightStickY-> c:rstick:up
			rightStickY+> c:rstick:down

			lstickb> c:lstickb
			rstickb> c:rstickb
		]]
	},
	
	PC = {
		butInfo = {
			validate =      {x=27, y=19, w=9 , h=10},
			cancel =        {x=35, y=19, w=9 , h=10},
			shoot =         {x=13, y=0 , w=14, h=9 },
			special =       {x=43, y=19, w=9 , h=10},
			reload =        {x=51, y=19, w=9 , h=10},

			pause =         {x=59, y=29, w=9 , h=10},
			info =          {x=67, y=29, w=9 , h=10},

			["leftStickX-"]={x=27, y=0 , w=9 , h=10},
			["leftStickY+"]={x=35, y=0 , w=9 , h=10},
			["leftStickX+"]={x=43, y=0 , w=9 , h=10},
			["leftStickY-"]={x=51, y=0 , w=9 , h=10},

			leftPage =      {x=0 , y=18, w=12, h=7 },
			rightPage =     {x=11, y=18, w=12, h=7 },

			--sticks
			bgStick =       {x=60, y=0 , w=11, h=11},
			leftStick =     {x=60, y=11, w=9 , h=9 },
			lstickb =       {x=60, y=11, w=9 , h=9 },
			rightStick =    {x=68, y=11, w=9 , h=9 },
			rstickb =       {x=68, y=11, w=9 , h=9 },
			
			--keyboard and cursor
			spacebar = {x=27, y=42, w=21, h=6 },
			escape = {x=48, y=40, w=13, h=11 },
			cursor = {x=16, y=40, w=6, h=8 },
		},
		
		CONFIRM_BUTTON="A",
		SPECIAL_BUTTON="X",
		RELOAD_BUTTON="Y",
		SHOOT_BUTTON="RT",
		--RUMBLE_INTENSITY_L=1.0,
		--RUMBLE_INTENSITY_R=1.0,
		--RUMBLE_TIMER=160,

		INPUT_ASSIGNEMENT = [[
			validate> c:a, m:lb
			cancel> c:b, k:escape
			shoot> c:rtrigger
			special> c:x, m:rb
			reload> c:y, k:space
			unsafe> c:ltrigger, k:lshift
			force_shoot> k:return
			force_aim> k:lalt, k:ralt

			pause> c:start, k:escape, k:p
			info> c:back
			leftPage> c:lshoulder
			rightPage> c:rshoulder

			leftStickX-> c:lstick:left, c:dpad:left, k:left
			leftStickX+> c:lstick:right, c:dpad:right, k:right
			leftStickY-> c:lstick:up, c:dpad:up, k:up
			leftStickY+> c:lstick:down, c:dpad:down, k:down
			rightStickX-> c:rstick:left
			rightStickX+> c:rstick:right
			rightStickY-> c:rstick:up
			rightStickY+> c:rstick:down

			lstickb> c:lstickb, m:mb
			rstickb> c:rstickb

			u> k:u
			p> k:p
			l> k:l
			o> k:o
			a> k:a
			d> k:d
			k> k:k

			r> k:r
			f> k:f
			ctrl> k:lctrl 
			shift> k:lshift
			test> k:t
			speed_up> k:pageup, k:kp_plus
			speed_down> k:pagedown, k:kp_minus
			
			mx> m:x
			my> m:y
			lb> m:lb
			rb> m:rb
			
			mouse_move> m:x, m:y
			mouse> m:lb, m:rb, m:mb, k:escape, k:return, k:space, k:lshift, k:lalt, k:ralt
			ctrlr> c:lstick:left, c:lstick:right, c:lstick:up, c:lstick:down, c:rstick:left, c:rstick:right, c:rstick:up, c:rstick:down, c:a, c:b, c:x, c:dpad:left, c:dpad:right, c:dpad:up, c:dpad:down, c:start, c:back, c:touchpad, c:rshoulder, c:lshoulder
		]]
	}
}

function use_gamepad_layout(type, assign_inputs)
	local layout = gamepad_layouts[type]
	butInfo = layout.butInfo
	CONFIRM_BUTTON = layout.CONFIRM_BUTTON
	SPECIAL_BUTTON = layout.SPECIAL_BUTTON
	RELOAD_BUTTON  = layout.RELOAD_BUTTON
	SHOOT_BUTTON   = layout.SHOOT_BUTTON
	
	if assign_inputs then
		INPUT_ASSIGNEMENT = layout.INPUT_ASSIGNEMENT
	end
end

function adjust_to_gamepad(layout)
	if not layout then
		local gc = ctrlr("which", 0)
		
		if gc==0 then
			layout = "PC"
		else
			RUMBLE_SUPPORT = ctrlr("hasrumble", gc)
			layout = ctrlr("type", gc)
		end
	end

	if FORCE_STEAMDECK then -- TEST
		layout = "SteamDeck"
	end
	
	if PSN and layout=="PS" then
		layout = psn("is_prospero") and "PS5" or "PS4"
	end
	
	if layout == "PC" then
		console_sheet = "console_PC"
		mouse("show", true)
	elseif layout == "SteamDeck" then
		use_gamepad_layout("Xbox")
		console_sheet = "console_SteamDeck"
		defbtn("info", 0, "c:back")
	elseif layout == "PS5" then
		use_gamepad_layout("PS")
		console_sheet = "console_PS5"
		butInfo.pause = {x=67, y=29, w=6, h=13}
		defbtn("info", 0, "c:touchpad")
	elseif layout == "PS4" or layout == "PS3" then
		use_gamepad_layout("PS")
		console_sheet = "console_PS4"
		butInfo.pause = {x=27, y=39, w=25, h=12}
		defbtn("info", 0, "c:touchpad")
	elseif layout == "SwitchPro" or layout == "NX" then
		use_gamepad_layout("NX")
		console_sheet = "console_NX"
		defbtn("info", 0, "c:back")
	else -- Xbox 360 & One, and unknown types
		use_gamepad_layout("Xbox")
		console_sheet = "console_Xbox"
		defbtn("info", 0, "c:back")
	end
end

local function ctrlr_list()
	if not PC then return end
	
	local list = ctrlr("list") -- checking new connect or disconnect
	if CTRLR_LIST and #list == #CTRLR_LIST then return end
	
	local cur = ctrlr("which", 0)
	RUMBLE_SUPPORT = nil
	CTRLR_CUR = nil
	
	for i=1,#list do
		defbtn("ctrlr", i, "c:lstick:left, c:lstick:right, c:lstick:up, c:lstick:down, c:rstick:left, c:rstick:right, c:rstick:up, c:rstick:down, c:a, c:b, c:x, c:y, c:dpad:left, c:dpad:right, c:dpad:up, c:dpad:down, c:start, c:back, c:lshoulder, c:rshoulder, c:touchpad")
		ctrlr("assign", list[i], i)
		
		if cur==list[i] or cur<=0 then
			cur = list[i]
			ctrlr("assign", cur, 0)
			CTRLR_CUR = i
			RUMBLE_SUPPORT = ctrlr("hasrumble", cur)
			CTRLR_TYPE = ctrlr("type", cur)
			
			if FORCE_STEAMDECK then -- TEST
				CTRLR_TYPE = "SteamDeck"
			end
		end
		
		--MOUSE = nil
	end
	
	if not CTRLR_CUR and not MOUSE then
		MOUSE = true
		mouse("show", true)
		use_gamepad_layout("PC")
		console_sheet = "console_PC"
	end
	
	if CTRLR_TYPE == "SteamDeck" or CTRLR_TYPE=="SteamController" then
		SD_PAD = true
		mouse("show", true)
		use_gamepad_layout("Xbox")
		console_sheet = "console_SteamDeck"
	end
	
	CTRLR_LIST = list
end

if PC then
	ctrlr_list()
	MOUSE = #CTRLR_LIST==0 or SD_PAD
	if MOUSE then
		mouse("show", true)
	end
	if CTRLR_TYPE=="SteamDeck" or CTRLR_TYPE=="SteamController" then
		mouse("show", true)
		SD_PAD = true
	end
	_log(#CTRLR_LIST.." controllers detected.")
	_log("Using controller "..(CTRLR_CUR or "nil"))
	
	adjust_to_gamepad()
end

use_gamepad_layout(PC and "PC" or GAMEPAD_LAYOUT, true)

--[[ show all stick angle for lotcheck
spritesheet("console")
local posY = 40
for s=0,1 do
	local posX = 0
	local d = -0.25
	local stick = "leftStick"
	if s == 1 then stick = "rightStick" end
	for i=0,9 do
		sspr(0,18,11,11,posX,posY)
		local offX=round(1 + cos(d))
		local offY=sin(d)
		if offY > 0 then offY = offY * 2 end
		offY = round(offY)
		sprSY=18
		
		if i == 0 or i == 1 then
			offX=1
			offY=0
			if i == 1 then sprSY=sprSY+butInfo[stick].h end
		else
			d = d + 0.125
		end
		
		sspr(butInfo[stick].x, sprSY, butInfo[stick].w, butInfo[stick].h, posX+offX, posY+offY)
		
		posX = posX + butInfo[stick].w + 4
	end
	posY = posY + 12
end
spritesheet("gfx")
]]--

function draw_button(but, x, y, fake, press)
	if GAMEPAD_LAYOUT == "NONE" then return end
	if not butInfo[but] then return end
	spritesheet(console_sheet)
	if but == "lstickb" or but == "rstickb" then sspr(butInfo["bgStick"].x, butInfo["bgStick"].y, butInfo["bgStick"].w, butInfo["bgStick"].h,x-1,y) end
	
	local sprSY=butInfo[but].y
	if fake then
		if press~=nil then
			if press then 
				sprSY=sprSY+butInfo[but].h
			end
		elseif time()%2<1 then
			sprSY=sprSY+butInfo[but].h
		end
	elseif btn(but) and not pause then 
		sprSY=sprSY+butInfo[but].h
	end
	
	if SD_PAD and MOUSE and (but=="validate" or but=="special") then
		sprSY=sprSY+21
	end
	
	sspr(butInfo[but].x, sprSY, butInfo[but].w, butInfo[but].h, x, y)
	spritesheet("gfx")
	
	if but == "lstickb" or but == "rstickb" then return butInfo["bgStick"].w end
	return butInfo[but].h
end

function draw_stick(stick, x, y, fake)
	if GAMEPAD_LAYOUT == "NONE" then return 0 end
	if not butInfo[stick] then return 0 end
	spritesheet(console_sheet)
	
	sspr(butInfo["bgStick"].x, butInfo["bgStick"].y, butInfo["bgStick"].w, butInfo["bgStick"].h,x,y)
	local offX, offY
	if fake then
		offX = round(1 + cos(time()))
		offY = sin(time())
		if offY > 0 then offY = offY * 2 end
		offY = round(offY)
	else
		offX=1 + btnv(stick.."X+") - btnv(stick.."X-")
	  offY=btnv(stick.."Y+")*2 - btnv(stick.."Y-")
	end
	
	sspr(butInfo[stick].x, butInfo[stick].y, butInfo[stick].w, butInfo[stick].h, x+offX, y+offY)
	
	spritesheet("gfx")
	
	return butInfo["bgStick"].w
end

-- ctrl_mode variables
local mCursor
local chosen_rov, aim_rov
local move_poss, move_cur, move_t
local any_card_xm, any_card_menu, any_card_left, any_card_right, any_card_sel
local grenade_trg
local dig_trg
local hypnosis_trg


function draw_on_board()
	if is_select_mode[ctrl_mode] and rov then
		if rov.big then
			rect(rov.x, rov.y, rov.x + 2*SQ - 1, rov.y + 2*SQ - 1, 5)
		else
			rect(rov.x, rov.y, rov.x + SQ - 1, rov.y + SQ - 1, 5)
		end
	end
	
	
	local function show_sq(sq,ico)
		if not sq then return end
		rect(sq.x, sq.y, sq.x + SQ - 1, sq.y + SQ - 1, 5)
		if ico then
			sspr(176,192,16,16,sq.x,sq.y-5.5-cos(t/60)*2)
		end
		
	end
	
	if ctrl_mode == "grenade" and grenade_trg then
		show_sq(grenade_trg)
	end
	if ctrl_mode == "dig" and dig_trg then
		show_sq(dig_trg,0)
	end	



	--if DEV then circ(mx,my,2+cyc(3,8),5) end
end

function draw_mode()
	local posX = board_x - 25
	local posY = board_y + 8 * SQ - 16 - 2
	local hideButton=false
	
	--
	local icon,outl = -1
	local function draw_icon()
		sspr(96+icon*16, 352, 16, 16, posX, posY)
	end
	
	if stack.special=="scope" then
		if hero and hero.scope then
			pal_inc(-2)
			hideButton = true
		end
		
		icon = 0
	elseif stack.special=="grenade" then
		if not hero or not hero.grenade_ready or grenade==0 then
			pal_inc(-2)
			hideButton = true
		elseif ctrl_mode == "grenade" then
			if t%30 > 15 then pal_inc(-1) end
			hideButton = true
		end
		icon = 1
	elseif stack.special=="decree" then
		if hero and not(chamber>0 or hero.lift) then
			pal_inc(-2)
			hideButton = true
		elseif ctrl_mode == "strafe" then
			if t%30 > 15 then pal_inc(-1) end
			hideButton = true
		end
		
		--if decree_on then
		--	local centerX = posX + 7
		--	local centerY = posY + 8
		--	circfill(centerX, centerY, 7.75, 5)
		--	circfill(centerX, centerY, 5.75, 1)
		--end
		
		outl = decree_on
		icon = 2
	elseif stack.special=="strafe" then
		if hero and not(chamber>0 or hero.lift) then
			pal_inc(-2)
			hideButton = true
		elseif ctrl_mode == "strafe" then
			if t%30 > 15 then pal_inc(-1) end
			hideButton = true
		end
		icon = 3
	elseif stack.special=="orb" then
		icon = 4
	elseif stack.special=="dig" then
	
		if not hero or not playing then
			pal_inc(-2)
			hideButton = true
		elseif ctrl_mode == "dig" then
			if t%30 > 15 then pal_inc(-1) end
			hideButton = true
		end
		
		icon = 5
	else
		spritesheet("gfx")
		return
	end
	
	if outl then
		brd(draw_icon, 5)
	else
		draw_icon(icon)
		pal_rst()
	end
	
	if not hideButton then
		draw_button("special", posX + 3, posY + 18 - 1)
	end
	spritesheet("gfx")
end

function mode_setup(mode, ...)
	if mode == "move" then
		local a = ...
		if a then
			move_poss = a
		end
		
		info=nil
		
		if btnv("rightStickX-") + btnv("rightStickX+") + btnv("rightStickY-") + btnv("rightStickY+") > 0.5 then
			ctrl_mode = "aim"
			return mode_setup("aim")
		end
	
	elseif mode == "aim" then
		info=nil
	elseif mode == "grenade" then
		grenade_trg = nil
	elseif mode == "strafe" then
		if aim then
			rov = aim
			toggle_target()
		end
	elseif mode=="dig" then
		dig_trg=hero.sq

	elseif mode == "move_hypnosis" then
		hypnosis_trg = ...
		reset_move_cursor()
	elseif mode == "disrupt_ui" then
		if ... then
			disrupt_menu = ...
		end
		disrupt_sel = 1
	elseif mode == "+-" then
		track_flags = ...
		
	elseif mode == "pick_any_card" then
		local a,b,c,d = ...
		any_card_xm = a
		any_card_menu = b
		any_card_left = c
		any_card_right = d
		any_card_sel = 1
	end
end

function reset_mode(mode, ...)
	if mode then ctrl_mode = mode 
	elseif prev_mode[1] then ctrl_mode = prev_mode[1]
	else ctrl_mode = "move" end
	prev_mode = {}
	
	mode_setup(mode, ...)
end

function push_mode(mode, ...)
	add(prev_mode, ctrl_mode)
	ctrl_mode = mode
	
	mode_setup(mode, ...)
end

function pop_mode()
	ctrl_mode = deli(prev_mode, #prev_mode)
end

function is_basic_mode()
	return ctrl_mode == "aim" or ctrl_mode == "move" or ctrl_mode == "move_soul" or ctrl_mode == "select_soul" or ctrl_mode == "select_wand"
end


function console_init()
	if PC then return end

	LIVE = live()
	if LIVE then
		live("fetch_achievements_async", #ACHIEVEMENTS)
	end
	PSN = psn()
	
	if PSN then
		GAMEPAD_LAYOUT = "PS"
		BUILD_TYPE = "PS"
		if psn("is_enter_button_circle") then 
			CONFIRM_BUTTON="⓷"
			
			local tmp = butInfo.cancel
			butInfo.cancel = butInfo.validate
			butInfo.validate = tmp

			INPUT_ASSIGNEMENT = [[
				validate> c:circle
				cancel> c:cross

			]] .. INPUT_ASSIGNEMENT
		else
			CONFIRM_BUTTON="⓵"
			
			INPUT_ASSIGNEMENT = [[
				validate> c:cross
				cancel> c:circle

			]] .. INPUT_ASSIGNEMENT
		end
	end
	
	adjust_to_gamepad(GAMEPAD_LAYOUT or "PC")
end

--local auto_moved
local auto_moved={}
local _,winw,winh
local _t=0
local function upd_mouse_pos(x,y) -- move the actual system cursor when on SteamDeck
	if codex then return end
	x=x or mx
	y=y or my
	if not SD_PAD or x<0 or y<0 then return end
	if abs(x-btnv"mx")>=1 or abs(y-btnv"my")>=1 then
		mouse("setpos",x,y)
		--auto_moved = .1
		add(auto_moved, {x,y,time()})
	end
end

function _window_resize(name,w,h)
	winw,winh=w,h
end

smoothAim={x=0,y=0}
smoothDir={x=0,y=0}
local switched

function gamepad_ctrl()
	if not winw or winw==0 then
		_,_,winw,winh=winspec("lay")
	end
	--[[local str = ""
	for i=1,#prev_mode do
		str = str .. prev_mode[i] .. " "
	end
	str = str .. "[" .. ctrl_mode .. "]"
	print(str)]]--
	
	if not mx then
		mx = 0
	end
	if not my then
		my = 0
	end
	if mMenu == nil then
		mMenu = {}
		mMenu.x = 0
		mMenu.y = 0
	end
	
	local dif_ctrlr
	if PC then
		ctrlr_list()
		for i=1,#CTRLR_LIST do
			if i~=CTRLR_CUR and btn("ctrlr", i) then
				ctrlr("assign", CTRLR_LIST[i], 0)
				dif_ctrlr = true
				CTRLR_CUR = i
				break
			end
		end
		
		_t=_t+1
		if _t==5 and not mode then -- force recheck
			MOUSE = true
			dif_ctrlr = true
		end
	end
	
	local sd = CTRLR_TYPE=="SteamDeck"
	if sd and not SD_PAD then
		SD_PAD = true
	--	mouse("show", true)
	elseif SD_PAD and not sd then
		SD_PAD = false
	--	if not MOUSE then
	--		mouse("show", false)
	--	end
	end
	
	-- counteract mouse events provoked by upd_mouse_pos() on Steam Deck
	local mouse_moved = btn("mouse_move")
	if mouse_moved and auto_moved[1] then
		local x,y=btnv"mx",btnv"my"
		local t=time()
		
		local i=1
		while i<=#auto_moved do
			local m=auto_moved[i]
			
			if abs(x-m[1])<1 and abs(y-m[2])<1 then
				mouse_moved = false
				break
			elseif m[3]<t-2 then
				deli(auto_moved, i)
			else
				i=i+1
			end
		end
		
		if mouse_moved then
			auto_moved={}
		end
	end
	
	-- detect changes from mouse to controller, or vice versa, or from a controller to a different controller
	if switched then
		if MOUSE and not btn("ctrlr") then
			switched=nil
		elseif not MOUSE and not (btn"mouse" or mouse_moved) then
			switched=nil
		end
	elseif MOUSE and (btn("ctrlr") or dif_ctrlr) then
		if dif_ctrlr and (SD_PAD or #CTRLR_LIST==0) then
			MOUSE = true
			mouse("show", true)
			adjust_to_gamepad()
		else
			switched=true
			MOUSE = false
			mouse("show", false)
			adjust_to_gamepad()
			reset_mode("move")
			if disrupt_menu then
				push_mode("disrupt_ui")
			end
		end
	elseif not MOUSE and (mouse_moved or btn("mouse")) and _t>5 then
		switched=true
		MOUSE = true
		mouse("show", true)
		if not SD_PAD then
			use_gamepad_layout("PC")
			console_sheet = "console_PC"
		end
	end
	
	
	if MOUSE then
		mMenu.x = btnv"mx"
		mMenu.y = btnv"my"
		mx = btnv"mx"
		my = btnv"my"
		mcl = btnr("validate") or (SD_PAD and btnp("shoot"))
		mcr = btnr("special")
		mlb = btn("validate")
		reset_mode("move")
		info = false
		return
	elseif btn("mouse") then
		mMenu.x = btnv"mx"
		mMenu.y = btnv"my"
		mx = btnv"mx"
		my = btnv"my"
		return
	end
	
	if not selectedOption or not menu then -- reset selected to 1 between each menu
		selectedOption = 1
	end
	
	if any_card_menu then
		any_card_ctrl()
		upd_mouse_pos()	
		return
	elseif ctrl_mode == "ask_card" then
		ingame_ui_ctrl()
		upd_mouse_pos()
		return
	end
	
	if leveling or not ingame or menu then
		reset_mode("move")
		info = false
	end
	
	if lastPick then lastPick.picked=false end
	
	cancel_mcl_mcr = nil


	
	if menu then
		
		menu_ctrl()
	elseif mode and mode.track_but then
		track_but_ctrl()
	elseif leveling then
		mcl=btnp("validate")
		mcr=btnp("cancel")
		ingame_ui_ctrl()
	elseif codex or not ingame then
		
		mcl=btnp("validate")
		mcr=btnp("cancel")
	else

	
		if info then
			--if btnp("leftPage") and ctrl_mode ~= "select_card" and get_nb_cards(0) > 0 then
			--	--push_mode("select_card")
			--elseif btnp("rightPage") and ctrl_mode ~= "select_card" and get_nb_cards(1) > 0 then
			--	--push_mode("select_card")
			--end
			
			if btnp("info") or btnp("cancel") then 
				info = false
				reset_mode()
				rov = nil
			end
		elseif is_basic_mode() then
			if btnp("rightPage") and ctrl_mode ~= "select_soul" and ctrl_mode ~= "select_wand" and #souls > 0 then
				push_mode("select_soul")
			elseif btnr("rightPage") and ctrl_mode == "select_soul" then
				pop_mode()
			end
			
			if btnp("leftPage") and ctrl_mode ~= "select_wand" and ctrl_mode ~= "select_soul" and #scepters > 0 then
				push_mode("select_wand")
			elseif btnr("leftPage") and ctrl_mode == "select_wand" then
				pop_mode()
			end
			
			if hero and hero.soul and ctrl_mode ~= "move_soul" then
				push_mode("move_soul")
			elseif not (hero and hero.soul) and ctrl_mode == "move_soul" then
				reset_mode()
			end
			
			if (ctrl_mode == "aim" or ctrl_mode == "move") and btnp("info") and playing and get_nb_cards(0) > 0 then 
				info = true
				push_mode("select_card")
			end -- replaced with new inspection controls on aiming
		end
		
		if sub(ctrl_mode, 1, 6) == "select" then
			ingame_ui_ctrl()
		else
			if hero == nil then
				-- do nothing
			elseif ctrl_mode == "grenade" then
				grenade_ctrl()
			elseif ctrl_mode == "dig" then	
				dig_ctrl()
			elseif is_select_mode[ctrl_mode] then
				select_unit_ctrl()
			elseif is_move_mode[ctrl_mode] then
				move_ctrl()
			elseif ctrl_mode == "disrupt_ui" then
				disrupt_menu_ctrl()
			elseif hero ~= nil then
				local xL = btnv("leftStickX+") - btnv("leftStickX-")
				local yL = btnv("leftStickY+") - btnv("leftStickY-")
				local normL = sqrt(xL*xL+yL*yL)
				
				local xR = btnv("rightStickX+") - btnv("rightStickX-")
				local yR = btnv("rightStickY+") - btnv("rightStickY-")
				smoothAim.x = lerp(smoothAim.x, xR, 0.5)
				smoothAim.y = lerp(smoothAim.y, yR, 0.5)
				local normR = sqrt(smoothAim.x*smoothAim.x+smoothAim.y*smoothAim.y)
				
				if (normL > 0.5 or normR > 0.5) and abs(normL - normR) > 0.1 then
					if normR > 0.5 then
						ctrl_mode = "aim"
					else
						ctrl_mode = "move"
					end
				end
				if mode.no_shotgun then
					ctrl_mode = "move"
				end
				
				if ctrl_mode == "aim" then
					reset_move_cursor()
					aim_ctrl()
				elseif ctrl_mode == "move" then
					move_ctrl()
				else
					print("wtf: " .. ctrl_mode)
				end
			

			else
				-- waiting for the start of the game
			end
		end
		
		if cancel_mcl_mcr then
			mcl,mcr = nil,nil
		else
			mcl= btnp("validate")
			if ctrl_mode~="move" and ctrl_mode~="aim" then
				mcr = btnp("cancel")
			else
				mcr = nil
			end
		end
	end



	upd_mouse_pos()

end

function aim_ctrl()
	if aimPos == nil then
		aimPos = {}
		aimPos.x = 0
		aimPos.y = -1
	end
	
	local xShot = smoothAim.x
	local yShot = smoothAim.y
	local normShot = sqrt(xShot*xShot+yShot*yShot)
	
	if normShot > 0.2 then
		aimPos.x = (xShot / normShot)
		aimPos.y = (yShot / normShot)
	end
	mx = (hero.x + 8) + aimPos.x * 48
	my = (hero.y + 8) + aimPos.y * 48
	
	-- find a piece for ROV
	if normShot > 0.2 and hero.sq then
		-- already inspecting a piece, can inspect another with left stick
		if rov and rov.sq then
			local incX = (btnrp("leftStickX+") and 1 or 0) - (btnrp("leftStickX-") and 1 or 0)
			local incY = (btnrp("leftStickY+") and 1 or 0) - (btnrp("leftStickY-") and 1 or 0)
			if incX~=0 or incY~=0 then
				local sq_pieces={}
				for b in all(bads) do
					if not b.inert then
						add(sq_pieces, b.sq)
					end
				end
			
				local curx = rov.sq.px
				local cury = rov.sq.py
				if rov.big then
					curx = curx+0.5+incX*0.5
					cury = cury+0.5+incY*0.5
				end
			
				local bv, best
				for _,sq in pairs(sq_pieces) do
					local dx = sq.px-curx
					local dy = sq.py-cury
					if sq.p.big then
						dx = dx+0.5-incX*0.5
						dy = dy+0.5-incY*0.5
					end
					
					if (incX==0 or (dx~=0 and incX == sgn(dx))) and (incY==0 or (dy ~=0 and incY == sgn(dy))) then
						local manv = abs(dx) + abs(dy)
						if not bv or manv < bv then
							best,bv = sq,manv
						end
					end
					
				end
				if best and best.p~=rov then
					rov = best.p
					chosen_rov = true
				end
			end
		end
	
		-- find piece most directly in aim line
		local nrov
		
		local dx = aimPos.x
		local dy = aimPos.y
		local m=8
		local x,y = m*dx, m*dy
		local px,py = hero.sq.px+0.5,hero.sq.py+0.5
		for i=m,256 do
			x=x+dx
			y=y+dy
			local sq = gsq(flr(px+x/16),flr(py+y/16))
			if not sq then
				break
			elseif sq.p and sq.p.bad and not sq.p.inert then
				nrov = sq.p
				break
			end
		end
		
		if nrov~=aim_rov then
			rov = nrov
			aim_rov = rov
			chosen_rov = nil
		end
		
		--print(rov and rov.name)
		
	else
		rov = nil
		aim_rov = nil
		chosen_rov = nil
	end
end

function shoot_ctrl(shoot_fnc) -- shoot_ctrl called by watch_keys
		if ctrl_mode == "aim" then
			if btnp("shoot") then
				if decree_on then autofire = true end
				shoot_fnc()
			end
		end
		
		if btnp("special") then
			if stack.special=="decree" then
				if decree_on then
					decree_on = nil
				else
					decree_on = true
					rumble(0, 0.6, 0.3, 0.2)
				end
			end
		
			if ctrl_mode ~= "grenade" and ctrl_mode ~= "strafe" and ctrl_mode ~= "orb" then
				if stack.special=="scope" then
					if chamber==0 then
						fx_wrong()
						msg(lang.no_shell_loaded,60)					
					elseif hero.scope then
						fx_wrong()
						msg(lang.scope_on,60)
					elseif check_folly_shields(hero.sq) then
						show_danger(hero.sq)
					else
						remove_buts()
						hero.scope=true
						sfx("scope")
						wait(4,opp_turn)
					end
				end
				
				if stack.special=="grenade" then
					if grenades==0 then
						if not inter.c_msg then
							inter.lack_ammo=60
							fx_wrong(lang.no_grenade_left)
						end
						return
					end
					push_mode("grenade")
				end
				
				if stack.special=="strafe" then
					if not(chamber>0 or hero.lift) then
						sfx("wrong")
						hero.c_need_ammo=30
						return
					end
					
					push_mode("strafe")
				end
				
				if stack.special=="orb" then
					push_mode("orb")
				end
		
				if stack.special=="dig" then
					push_mode("dig")
				end


			end
		end
	
		if btnp("cancel") and decree_on then
			decree_on = false
		end
	--end

end

function reset_move_cursor()
	mCursor = {}
	
	if ctrl_mode == "move_hypnosis" then
		mCursor.x = hypnosis_trg.x
		mCursor.y = hypnosis_trg.y
	else
		mCursor.x = hero.x
		mCursor.y = hero.y
	end
	
	if ctrl_mode == "move" then
		mx = mCursor.x + 8
		my = mCursor.y + 8
	end
end

function manhattan_dist(a, b)
	return abs(a.x - b.x) + abs(a.y - b.y)
end

function move_ctrl()

	rov = nil
	aim_rov = nil
	chosen_rov = nil

	local moves=nil
	local range=stack.sprint and 2 or 1
	
	local hsq=hero.sq
	local grabable={}
	
	local function scan_selectable()
		moves={}
		for sq in all(squares) do
			if sq.selectable then add(moves, sq) end
		end		
	end
	
	if ctrl_mode == "move_hypnosis" then
		range=nil
		scan_selectable()
		
	elseif ctrl_mode == "move_black" then
		range=nil
		scan_selectable()
		
	elseif ctrl_mode == "move_soul" then
		range=nil
		scan_selectable()
		
	elseif ctrl_mode == "move_wings" then
		range=nil
		scan_selectable()
	else
		if not playing then
			return
		end
		moves=move_poss
		
		-- CHECK GRAB    
		local ks_ready=stack.grab--get_slot_card_with("grab")
		for di=0,7 do
			local sq=dsq(hero.sq,di,1)
			if sq and sq.p and not is_king(sq.p.type) and (ks_ready or sq.p.type==9) then
				add(moves, sq)
				grabable[sq] = true
				if hero.hop and not sq.p.airy then
					local hop_sq=dsq(hero.sq,di,2)
					if is_free(hop_sq) then
						range=2
					end
				end
			end
		end
		
		--[[ CHECK BLADE
		if stack.blade then
			for di=0,7 do
				local sq=dsq(hero.sq,di,1)
				if sq and sq.p and (sq.p.hp or 999)<=stack.blade and not sq.p.airy and not sq.p.smoke_king then
					add(moves, sq)
					if hero.hop then
						local hop_sq=dsq(hero.sq,di,2)
						if is_free(hop_sq) then
							range=2
						end
					end
				end
			end
		end
		--]]
		
		
		-- CHECK FLAGSTONES
		if stack.flagstones then
			local n=0
			for _,sq in pairs(moves) do
				if sq.flagstone and (abs(sq.px-hsq.px)>1 or abs(sq.py-hsq.py)>1) then
					range = 2
					break
				end
			end
		end
		
		-- CHECK pad_move buts
		for sq in all(squares) do
			if sq.pad_but then
				range = 2
				add(moves,sq)
			end
		end
	
	end
	
	if not moves then return end
	
	local piece = hero
	if ctrl_mode == "move_hypnosis" then
		piece = hypnosis_trg
	end
	hsq = piece.sq
	
	local dirX = 0
	local dirY = 0
	local best=nil
	if range == 1 then
		if btn("leftStickX+") then dirX = 1
		elseif btn("leftStickX-") then dirX = -1
		end
		if btn("leftStickY+") then dirY = 1
		elseif btn("leftStickY-") then dirY = -1
		end
		smoothDir.x = lerp(smoothDir.x, dirX, 0.8)
		smoothDir.y = lerp(smoothDir.y, dirY, 0.8)
		
		if smoothDir.x > -0.75 and smoothDir.x < 0.75 then
			dirX = 0
		else
			dirX = smoothDir.x
		end
		if smoothDir.y > -0.75 and smoothDir.y < 0.75 then
			dirY = 0
		else
			dirY = smoothDir.y
		end

		local pos={}
		for sq in all(moves) do
			local ignore=false
			if dirX > 0 and sq.x <= piece.x then
				ignore = true
			elseif dirX < 0 and sq.x >= piece.x then
				ignore = true
			elseif dirX == 0 and sq.x ~= piece.x then
				ignore = true
			end
			if dirY > 0 and sq.y <= piece.y then
				ignore = true
			elseif dirY < 0 and sq.y >= piece.y then
				ignore = true
			elseif dirY == 0 and sq.y ~= piece.y then
				ignore = true
			end
			
			if not ignore then
				best=sq
				break
			end
		end
		
	else
		if btnrp("leftStickX+") then dirX = 1
		elseif btnrp("leftStickX-") then dirX = -1
		end
		if btnrp("leftStickY+") then dirY = 1
		elseif btnrp("leftStickY-") then dirY = -1
		end
		
		local pos={}
		for sq in all(moves) do
			if dirX > 0 and sq.x > mCursor.x then 
				add(pos, sq)
			elseif dirX < 0 and sq.x < mCursor.x then 
				add(pos, sq)
			elseif dirY > 0 and sq.y > mCursor.y then 
				add(pos, sq)
			elseif dirY < 0 and sq.y < mCursor.y then 
				add(pos, sq)
			end
		end
		
		local bestv
		for sq in all(pos) do
			local manv = abs(mCursor.x - sq.x)+abs(mCursor.y - sq.y)
			if not bestv or manv < bestv or (manv==bestv and (mCursor.x==sq.x or mCursor.y==sq.y)) then
				best,bestv = sq,manv
			end
		end
	end
	
	if best ~= nil then
		if best~=move_cur then
			move_cur = best
			if (move_t or 0)<t then 
				move_t = t
				sfx("tic",.5)
			end
		end	
		mCursor.x = best.x
		mCursor.y = best.y
	end
	
	mx = mCursor.x + 8
	my = mCursor.y + 8
	
	local currentSq=get_square_at(mx,my)
	local ks_ready=stack.grab--get_slot_card_with("grab")
	if currentSq and currentSq.p and piece==hero and not is_king(currentSq.p.type) and grabable[currentSq] then
		currentSq.p.picked=true
		lastPick=currentSq.p
	end
end

function ingame_ui_ctrl()
	local readcard = ctrl_mode == "select_card" or ctrl_mode == "ask_card"
	if leveling then
		local can_view_bonus=get_nb_cards(0)>0
		local can_view_malus=get_nb_cards(1)>0
		
		if (btn("leftPage") and can_view_bonus) or (btn("rightPage") and can_view_malus) then
			readcard = true
		end
		
		if (btnp("leftPage") and can_view_bonus) or (btnr("rightPage") and can_view_malus) then
			mMenu.x = 4
			mMenu.y = 4
		elseif (btnp("rightPage") and can_view_malus) or (btnr("leftPage") and can_view_bonus) then
			mMenu.x = 246
			mMenu.y = 4
		end
	elseif ctrl_mode ~= "ask_card" then
		if btnp("info") then
			mMenu.x = 4
			mMenu.y = 4
		elseif not info then
			if btnp("rightPage") then
				local ready_piece
				for p in all_pieces() do
					if not p.bad and p.piece and not p.smoke_king then
						if p.ready then
							ready_piece=true
							rov=p
							mMenu.x = p.x
							mMenu.y = p.y
							mx = p.x+8
							my = p.y+8
							break
						end
					end
				end
			
				if not ready_piece and #souls > 0 then
					mMenu.x = souls[1].x
					mMenu.y = souls[1].y
				end
			end
			if btnp("leftPage") and #scepters > 0 then
				mMenu.x = scepters[1].x
				mMenu.y = scepters[1].y
			end
		end
	end
	
	local incX = (btnrp("leftStickX+") and 1 or 0) - (btnrp("leftStickX-") and 1 or 0)
	local incY = (btnrp("leftStickY+") and 1 or 0) - (btnrp("leftStickY-") and 1 or 0)
	
	local best = nil
	local oldM = mMenu
	local best,bestv = nil
	
	for e in all(ents) do
		local process=false
		if leveling and readcard then process=e.iscard and (e.x<MCW*0.5 and btn("leftPage") or e.x>MCW*0.5 and btn("rightPage"))
		elseif readcard then process=e.iscard
		elseif leveling then process=e.lvlup_inspect
		elseif ctrl_mode == "select_soul" then
			process=e.issoul or (not e.bad and e.piece and not e.mastermind and not e.smoke_king)
		elseif ctrl_mode == "select_wand" then process=e.isscepter
		else process=e.button end
		
		if (not e.issq) and process then
			local dx=e.x-oldM.x
			local dy=e.y-oldM.y

			if (incX==0 or (dx~=0 and incX == sgn(dx))) and (incY==0 or (dy ~=0 and incY == sgn(dy))) then
				local dm = abs(dx)+abs(dy)
				if not best or dm<bestv then
					best,bestv=e,dm
				end
			end
		end
	end
	
	if best ~= nil then
		if best.piece then
			rov=best
		else
			rov=nil
		end
		
		mMenu.x = best.x
		mMenu.y = best.y
	end
	
	if readcard then
		mcl,mcr = btnp("validate"),nil
		mx = mMenu.x
		if mMenu.x < 149 then
			mx = mx + 21
		end
		my = mMenu.y
	elseif ctrl_mode == "select_soul" then
		mx = mMenu.x + 8
		my = mMenu.y + 8
		
	elseif ctrl_mode == "select_wand" then
		mx = mMenu.x + 8
		my = mMenu.y + 1
	else
		mx = mMenu.x + 8
		my = mMenu.y + 8
	end
end

function select_unit_ctrl()
	local sq_pieces={}
	for b in all(bads) do
		if not b.not_selectable and not b.smoke_king and not b.inert then
			add(sq_pieces, b.sq)
		end
	end
	
	if #sq_pieces == 0 then
		info = false
		reset_mode("move")
		return
	end
	
	if not rov then
		rov=sq_pieces[1].p
	end
	local best=nil
	
	local incX = (btnrp("leftStickX+") and 1 or 0) - (btnrp("leftStickX-") and 1 or 0)
	local incY = (btnrp("leftStickY+") and 1 or 0) - (btnrp("leftStickY-") and 1 or 0)
	local curx = rov.sq.px
	local cury = rov.sq.py
	if rov.big then
		curx = curx+0.5+incX*0.5
		cury = cury+0.5+incY*0.5
	end
	
	if incX~=0 or incY~=0 then
		local bv, best
		for _,sq in pairs(sq_pieces) do
			local dx = sq.px-curx
			local dy = sq.py-cury
			if sq.p.big then
				dx = dx+0.5-incX*0.5
				dy = dy+0.5-incY*0.5
			end
			
			if (incX==0 or (dx~=0 and incX == sgn(dx))) and (incY==0 or (dy ~=0 and incY == sgn(dy))) then
				local manv = abs(dx) + abs(dy)
				if not bv or manv < bv then
					best,bv = sq,manv
				end
			end
			
		end
		if best then
			rov = best.p
		end
	end
	
	mx = rov.x
	my = rov.y
	
	if ctrl_mode == "strafe" or ctrl_mode == "orb" then
		cancel_mcl_mcr = true
		local do_target = ctrl_mode == "strafe" and toggle_target or ctrl_mode == "orb" and seer_target or print
		
		if btnp("cancel") then
			do_target(nil)
			reset_mode()
			rov=nil
		elseif btnp("validate") then
			do_target(rov)
			reset_mode()
			rov=nil
		end
	end
	
	if info then
		cancel_mcl_mcr = true
		if btnp("cancel") or btnp("validate") then
			reset_mode()
			if rov and hero then
				push_mode("aim")
				aimPos = {
					x = rov.x - hero.x,
					y = rov.y - hero.y
				}
				rov=nil
			end
		end
	end
end

function grenade_ctrl()
	if btnp("cancel") then
		reset_mode()
		return
	end
	if not playing then return end
	
	local dirX = ((btnrp("leftStickX+") or btnrp("rightStickX+")) and 1 or 0) - ((btnrp("leftStickX-") or btnrp("rightStickX-")) and 1 or 0)
	local dirY = ((btnrp("leftStickY+") or btnrp("rightStickY+")) and 1 or 0) - ((btnrp("leftStickY-") or btnrp("rightStickY-")) and 1 or 0)
	
	if not grenade_trg then
		grenade_trg=squares[1]
	end
	
	if dirX~=0 or dirY~=0 then
		local curx,cury = grenade_trg.px, grenade_trg.py
		local bv, best
		for _,sq in pairs(squares) do
			local dx = sq.px-curx
			local dy = sq.py-cury

			if (dirX==0 or (dx~=0 and dirX == sgn(dx))) and (dirY==0 or (dy ~=0 and dirY == sgn(dy))) then
				local manv = abs(dx) + abs(dy)
				if not bv or manv < bv then
					best,bv = sq,manv
				end
			end
		end
		if best then
			grenade_trg=best
			if SD_PAD then
				upd_mouse_pos(best.x, best.y)
			end
		end
	end
	
	if btnp("validate") then
		throw_grenade(grenade_trg)
		reset_mode()
	end
	
	mx = -1
	my = -1
end

function dig_ctrl()
	if btnp("cancel") then
		sfx("cancel")
		reset_mode()
		return
	end
	if not playing then return end
	
	local dx = btnv("leftStickX+") - btnv("leftStickX-")
	local dy = btnv("leftStickY+") - btnv("leftStickY-")
	
	dx=abs(dx)>.5 and round(dx) or 0
	dy=abs(dy)>.5 and round(dy) or 0

	if dx~=0 or dy~=0 then
		local trg=gsq(hero.sq.px+dx,hero.sq.py+dy)
		if trg~=dig_trg then
			dig_trg=trg
			sfx("tic")
		end
		
	else
		dig_trg=nil
	end
	
	if btnp("validate") then
		if dig_trg then
			dig(dig_trg)
		end
		reset_mode()
	end	
	
	mx = -1
	my = -1
	
end

function disrupt_menu_ctrl()

	if disrupt_menu == nil then return end
	disrupt_sel = mid(disrupt_sel + (btnrp("leftStickX+") and 1 or 0) - (btnrp("leftStickX-") and 1 or 0), 1, #disrupt_menu)
	
	--local oldButton = disrupt_menu[selectedDisrupt]
	--if btnrp("leftStickX+") and selectedDisrupt < #disrupt_menu then
	--	selectedDisrupt = selectedDisrupt + 1
	--	--disrupt_menu[selectedDisrupt].but.over()
	--elseif btnrp("leftStickX-") and selectedDisrupt > 1 then
	--	selectedDisrupt = selectedDisrupt - 1 
	--	--disrupt_menu[selectedDisrupt].but.over()
	--end
	
	local b = disrupt_menu[disrupt_sel]
	local pan = b.par
	
	mx = pan.x + b.x + 16
	my = pan.y + b.y + 16
	
	--if selectedButton.but then
	--	if btnp("validate") then
	--		exe(selectedButton.but.left_clic)
	--	end
	--end
	
	if btnp("validate") then
		disrupt_menu = nil
	end
end


function menu_ctrl()



	local selectedButton = menu[selectedOption + 1]
	selectedButton.selected=false
	local skip_ctrl=false
	repeat
		if selectedButton.isRankPan then
			if btnp("validate") and (not selectedButton.check_ready or selectedButton.check_ready()) then
				selectedOption = selectedOption + 1
				skip_ctrl=true
			end
		end
		
		if ingameover then
			if btnrp("leftStickX+") then selectedOption = selectedOption + 1
			elseif btnrp("leftStickX-") then selectedOption = selectedOption - 1 end
		end
		if btnrp("leftStickY+") then selectedOption = selectedOption + 1
		elseif btnrp("leftStickY-") then selectedOption = selectedOption - 1 end
		selectedOption = mid(1, selectedOption, #menu - 1)
		selectedButton = menu[selectedOption + 1]
	until not selectedButton.skip
	
	mx = selectedButton.x + 1
	my = selectedButton.y + 1
	selectedButton.ov=true
	mcl=false
	mcr=false
	
	if skip_ctrl or selectedButton.lock then return end
	
	if selectedButton.isRankPan then
		selectedButton.selected=true
		
		if btnrp("leftStickX+") and selectedButton.next_ar.vis then
			exe(selectedButton.next_ar.but.left_clic)
		end
		if btnrp("leftStickX-") and selectedButton.prev_ar.vis then
			exe(selectedButton.prev_ar.but.left_clic)
		end
	elseif selectedButton.slider then -- option slider
		local n = selectedButton.slider
		if btnrp("leftStickX+") then n = n + 1
		elseif btnrp("leftStickX-") then n = n - 1
		end
		n = mid(0, n, 10)
		

		if n~=SET[selectedButton.opt.id] then
			SET[selectedButton.opt.id]=n
			apply_option(selectedButton.opt.id)
			sfx("tic",.5)
		end
		selectedButton.upn()
	elseif selectedButton.opt then -- option button
		if btnp("validate") or btnp("leftStickX+") then
			exe(selectedButton.but.left_clic)
		end
		if btnp("leftStickX-") then
			exe(selectedButton.but.right_clic)
		end
	else
		if btnp("validate") then  -- menu item
			selectedButton.but.clicked=true
			exe(selectedButton.but.left_clic)
			mx=-1
			my=-1
		end
	end
end

function any_card_ctrl()
	local dx = (btnrp("leftStickX+") and 1 or 0) - (btnrp("leftStickX-") and 1 or 0)
	local dy = (btnrp("leftStickY+") and 1 or 0) - (btnrp("leftStickY-") and 1 or 0)
	
	local i,xm = any_card_sel-1, any_card_xm
	local n = #any_card_menu
	local gx = i%xm
	local gy = flr(i/xm)
	
	local bx = min(n-gy*xm, xm)-1
	local by = ceil(n/xm)-1
	
	if btnr("leftPage") and any_card_left then
		pop_mode()
		any_card_left()
	end
	if btnr("rightPage") and any_card_right then
		pop_mode()
		any_card_right()
		n = #any_card_menu
	end
	
	if gx==0 and dx<0 and any_card_left then
		pop_mode()
		any_card_left()
		gx = xm-1
	elseif gx==xm-1 and dx>0 and any_card_right then
		pop_mode()
		any_card_right()
		n = #any_card_menu
		gx = 0
	else
		gx = mid(gx+dx,0,bx)
	end
	
	gy = mid(gy+dy,0,by)
	
	i = min(gy*xm+gx, n-1)
	any_card_sel = i+1
	
	local butt = any_card_menu[any_card_sel]
	local pan = butt.par
	mx = pan.x+butt.x+11
	my = pan.y+butt.y+26
	
	if btnp("validate") then
		mcl = true
		reset_mode()
		any_card_menu = nil
	end
end

function track_but_ctrl()

	
	-- SHOULDERS
	local track=0
	if btn("leftPage") or btn("unsafe") then track=1 end
	if btn("rightPage") or btn("shoot") then track=2 end
	
	
	-- PAD CURSOR
	if not pad_cursor then
		pad_cursor=mke(0,mx,my)
		pad_cursor.upd=function(e)
			del(ents,e)
			add(ents,e)
		end
		pad_cursor.dr=function(e,x,y)
			if MOUSE then return end
			local z=2.5+cos(t/90)
			y=y-z		
			blend_light(4,-1)
			blend_light(2,-1)
			sspr(0,104,11,8,x+z*.5,y+z*1.5)
			blend_light()
			sspr(0,104,11,8,x,y)
		end
	end
	local sel=pad_cursor.sel 
	
	-- BUILD BUT LISTS ( & move cursor )
	local buts={}
	local function adb(a,dx,dy)
		for e in all(a) do			
			if e.track==track and not e.locked then
				local x,y=dx+e.x+e.w/2,dy+e.y+e.h/2
				if sel and sel.b==e then
					mx,my=x,y
					pad_cursor.x=pad_cursor.x+(mx-pad_cursor.x)*.5
					pad_cursor.y=pad_cursor.y+(my-pad_cursor.y)*.5					
				end		
				add(buts,{b=e,x=x,y=y})
			end
			if e.ents then adb(e.ents,dx+e.x,dy+e.y) end
		end
	end
	adb(ents,0,0)
	
	-- AUTOSEL
	if #buts>0 and (not sel or sel.b.track~=track) then
		sel=buts[1]
		pad_cursor.sel=sel
	end

	-- MOVE SEL
	local dx,dy=0,0
	if btnrp("leftStickX+") then dx=1
	elseif btnrp("leftStickX-") then dx=-1 end
	if btnrp("leftStickY+") then dy=1
	elseif btnrp("leftStickY-") then dy=-1 end
	if sel and abs(dx)+abs(dy)>0 then
		local a={}
		for b in all(buts) do
			local ddx,ddy=rect_dist(sel.x,sel.y,sel.b.w,sel.b.h,b.x,b.y,b.b.w,b.b.h)
			if dx>0 and ddx>0 then add(a,b) end
			if dx<0 and ddx<0 then add(a,b) end
			if dy>0 and ddy>0 then add(a,b) end
			if dy<0 and ddy<0 then add(a,b) end
		end		
		local bd,sl
		for b in all(a) do
			local ddx,ddy=rect_dist(sel.x,sel.y,sel.b.w,sel.b.h,b.x,b.y,b.b.w,b.b.h)
		
			local d=(1.25-abs(dx))*abs(ddx)+(1.25-abs(dy))*abs(ddy)
			if b.track_boost then
				d=d/b.track_boost
			end
			if not sl or d<bd then
				sl,bd=b,d
				
			end	
		end	
		if sl~=sel then
			sel=sl or sel
			pad_cursor.sel=sel
			if sel.b.pad_cursor then sfx("tic") end
		end
	end
	

	pad_cursor.invis=not sel or not sel.b.pad_cursor		

	mcl=btnp("validate")
	mcr=btnp("cancel")

	--[[
	-- TRACK MOVE
	if btnrp("leftStickX+") then dirX = 1
	elseif btnrp("leftStickX-") then dirX = -1
	end
	if btnrp("leftStickY+") then dirY = 1
	elseif btnrp("leftStickY-") then dirY = -1
	end
	
	local pos={}
	for sq in all(moves) do
		if dirX > 0 and sq.x > mCursor.x then 
			add(pos, sq)
		elseif dirX < 0 and sq.x < mCursor.x then 
			add(pos, sq)
		elseif dirY > 0 and sq.y > mCursor.y then 
			add(pos, sq)
		elseif dirY < 0 and sq.y < mCursor.y then 
			add(pos, sq)
		end
	end
	
	local bestv
	for sq in all(pos) do
		local manv = abs(mCursor.x - sq.x)+abs(mCursor.y - sq.y)
		if not bestv or manv < bestv or (manv==bestv and (mCursor.x==sq.x or mCursor.y==sq.y)) then
			best,bestv = sq,manv
		end
	end	
	--]]


	
	

end

function rect_dist(ax,ay,aw,ah,bx,by,bw,bh)
	local dx,dy
	if bx+bw<=ax then
		dx=(bx+bw)-ax
	elseif bx>=ax+aw then
		dx=bx-(ax+aw)
	else
		dx=0
	end
	if by+bh<=ay then
		dy=(by+bh)-ay
	elseif by>=ay+ah then
		dy=by-(ay+ah)
	else
		dy=0
	end
	return dx,dy
end



do -- btn repetition

	local bnk={}
	local sil={}

	function btnrp(id,p,fdel,rdel)
		p = p or 0
		fdel = fdel or 0.3
		rdel = rdel or 0.15
		
		if not bnk[p] then
			bnk[p]={}
		end
		
		if btn(id,p) then
			if sil[p] and sil[p][id] then
				return false
			end
		
			if bnk[p][id] then
				bnk[p][id] = bnk[p][id]-delta()
				if bnk[p][id] <= 0 then
					bnk[p][id] = rdel
					return true
				end
			else
				bnk[p][id] = fdel
				return true
			end
		else
			if sil[p] and sil[p][id] then
				sil[p][id] = nil
			end
			bnk[p][id] = nil
		end
		
		return false
	end
	
	function btnrst(id,p)
		p=p or 0
		if bnk[p] then bnk[p][id]=nil end
	end
	
	function btnsil(id,p)
		p=p or 0
		if not sil[p] then sil[p]={} end
		sil[p][id]=true
	end

end