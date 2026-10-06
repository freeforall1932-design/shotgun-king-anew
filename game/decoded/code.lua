-- need this to print things in the log
_log = log
PC = true

psyms(false)
watch(false)
unwatch("code.lua")

if EXE_ARGS[1] == "shaderless" then
	_log("Launching the game in shaderless mode.")
	SHADERLESS = true
end

require("../../libs/hdtext.lua")
require("../../libs/hoard.lua")
require("../../libs/toolkit.lua")
require("../../libs/ents.lua")
require("../../libs/dirload.lua")
require("../../libs/gifkey.lua")
GIF_SCALE = 2
GIF_LENGTH = 180
GIF_SNAP_SCALE = 3
--require("../../libs/autosnaps.lua")

require("code/codex.lua")
require("code/menu.lua")
require("code/mods.lua")
require("code/grid.lua")
require("code/data.lua")
require("code/save.lua")

read_gameplay_file("code/gameplay.lua")

require("code/gamepad.lua")
require("code/lang.lua")
require("code/achievements.lua")
require("../../punkcake/punkcake_intro.lua")

if not PC then
	require("../../headbang/headbang_intro.lua")
	require("../../fmod/fmod_intro.lua")
end


function _init()
	console_init()
	STEAM = PC and steam("init", 1972440)
	
	palette("assets/gfx/gfx.png")
	logs={}
	
	do -- MUSIC
		watch("assets/sfx/<*>.wav", function(file,name) newsfx(name, file) end, 2) -- tmp fix, there's an issue with SUGAR v0.0.8c where sfx get replaced with nothingness after calling run
		--newsfx("assets/sfx/<*>.wav")
	
		if not NO_MUS then -- saves time on first launch
			newmus("assets/music/<*>.ogg")
		end
	end
	
	do -- SURFACES
		newsrf("assets/gfx/<*>.png")
		
		if not PC then
			newsrf("logo_hd", "assets/gfx/console_only/logo_hd.png")
		end
		
		newsrf("playground",MCW,MCH)
		newsrf("achievements_pane",190,ceil(#ACHIEVEMENTS/5)*38-1)
		newsrf("big_achievement",64,64)
	end
	
	do -- FONTS
		addfont("pico", false, "assets/fonts/pico_font.png", "!\"#°%&'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`@abcdefghijklmnopqrstuvwxyz{|}~⓵⓶⓷⓸éèêôû")
		
		if PC then
			load_hd_font()
		else
			load_all_fonts()
		end
	end
	
	load_safe_lang()
	
	curve=0
	
	-- BANKS
	--init_banks()
	
	if PC then
		load_mods()
	end
	
	do -- NEW SAVES
		-- v1.515f+ save files (features autosave and automatic backups)
		
		local params = {
			DEN = {
				encode = true,
				folder = "save",
				rootfile = "reg",
				ext = ".sav",
				backup = ".bak",
				wait = 0.5,
			},
			
			SET = { -- tables in SETTINGS won't create new save files, because of the `rootonly` flag. All is stored in SETTINGS.
				folder = ".",
				rootfile = "settings",
				rootonly = true,
				ext = ".txt",
				wait = 2,
			},
			MODSAV = {
					folder = "save/mods",
					rootfile = "reg",
					ext = ".sav",
					backup = ".bak",
					--onlyload = mods,
				}
		}
		
		--if MODLIST then
		--	local mods = {}
		--	for m in all(MODLIST) do
		--		if m.active then
		--			add(mods,m.name)
		--		end
		--	end
		--	
		--	if mods[1] then
		--		params.MODSAV = {
		--			folder = "save/mods",
		--			rootfile = "reg",
		--			ext = ".sav",
		--			backup = ".bak",
		--			onlyload = mods,
		--		}
		--	end
		--end
		
		init_hoard(params)
		
		check_save()
	end
	
	-- WINDOW
	local wmode = SET.fullscreen==0 and "resize" or "fullscreen"
	local shader = SET.crt==0 and "assets/stretch.shader" or "assets/crt_calmos.shader"
	
	if PC and SHADERLESS then
		newwin("Shotgun King", MCW, MCH, MSC, wmode, "scale")
	else
		newwin("Shotgun King", MCW, MCH, MSC, wmode, "scale", shader)
	end
	
	winspec("title","Shotgun King: The Final Checkmate")
	fpslimit(60)
	shdrf("curve", 0.01)
	shdrf("chroma",0)

	apply_options(true)

	if not DEV then
		if not PC then
			winspec("screen", MCW*4, MCH*4)
			fmod_splash_intro()
		end
		
		winspec("screen", MCW*2, MCH*2)
		punkcake_intro()
		winspec("screen", MCW, MCH)
		
		if not PC then
			headbang_intro()
		end
	end
	--winspec("screen", MCW, MCH)
	winspec("bgcol",2)
	
	spritesheet("gfx")
	sprgrid(16,16)
	pat=get_patterns(48,12,16)	
	gen_gfx()
	
	apply_option("lang")
	
	controls(INPUT_ASSIGNEMENT)
	if PC and not MOUSE and sub(CTRLR_TYPE,1,2)=="PS" then
		defbtn("info", 0, "c:touchpad")
		if CTRLR_TYPE == "PS5" then
			butInfo.pause = {x=67, y=29, w=6, h=13}
		end
	end
	
	if PC then
		run_mods()
	end

	boot()
end
function gen_gfx()

	-- GRENADE
	local r=SQ*1.5
	local frames=12
	newsrf("grenade",frames*r*2,r*2)
	target("grenade")
	cls(0)
	for i=0,frames-1 do
		local cx=r+i*2*r
		local cy=r
		local c=i/frames		
		local hc=max((i-10)/(frames-10),0)
		
		circfill(cx,cy,pow(c,.5)*r,5)
		circfill(cx,cy,pow(c,2)*r,0)
	end
	target()

	--
	local frames=12
	newsrf("mini_xpl",frames*16,16)
	target("mini_xpl")
	cls(0)
	for i=0,frames-1 do
		local cx=8+i*16
		local cy=8
		local c=i/frames		
		circfill(cx,cy,pow(c,.4)*7.5,5)		
		local rh=pow(c,.5)*7.5
		local an=.5+c*.5
		circfill(cx+cos(an)*(8-rh),cy+sin(an)*(8-rh),rh,0)
		
		
		--circfill(cx,cy,7.5,5)
	end
	target()

	--
	local sr=32
	newsrf("spiral",sr*2,sr*2)
	target("spiral")
	cls(0)
	local x,y,r,a=sr,sr,0,0
	for i=0,100 do
		r=r+.25
		a=a+4/(PI*r*2)
		local nx=x+cos(a)*r
		local ny=y+sin(a)*r
		line(x,y,nx,ny,5)
		x,y=nx,ny		
	end	
	target()


end

function boot()
	reset()
	if BOOT=="GAME" or BOOT=="LEVEL_UP" then 
		set_mode(game_mode or "throne")
		mode.start()
	end	
	if BOOT=="MENU" then
		init_menu()
	end
	if BOOT=="INTRO" then
		init_intro()
	end
	if BOOT=="ACHIEVEMENTS" then
		init_achievements()	
	end	
	if BOOT=="TEST" then
		init_test()
	end
	if BOOT=="CODEX" or BOOT=="UI_ACHIEVEMENTS" then
		init_codex()
	end
	
end
function reset()
	camera()
	show_danger_zone=false
	ingame=false
	pause=false
	cmx,cmy=0,0
	_t,t,fd=0,0,0
	mdr,lighting=nil
	ents={}	
	reset_mode("move")
end

function init_test()
	
	
	
	
	
	mdr=function()
		rectfill(0,0,MCW,MCH,5)
	end
	
	
	
	
end

-- GAME
function init_game()
	winspec("bgcol",1)

	reset()
	mode.frags={}
	
	fd=-4
	fade_to(0,30)
	
	mdr=draw_game
	game_mode=game_mode or "throne"
	
	ingame=true
	new_best_time=nil
	
	chamber=0
	ammo=0	
	grenades=0
	reloading=nil
	building_ammo=nil
	presence={}

	shields=SET.shields

	boss,seer=nil
	xmax,ymax=8,8
	board_x=(MCW-xmax*SQ)/2
	board_y=(MCH-ymax*SQ)/2+4--+8
	--white_army={}
	--black_army={}
	--
	wait_ammo=0
	curtsy=0
	--+
	perm={}	
	white_army={}
	events={}
	bullets={}
	spawners={}
	stack={}
	backups={}
	
	--

	-- UPGRADES 
	temporary={}
	upgrades={}
	if mode.base then 
		add(upgrades,mode.base) 
	end
	if mode.weapons then 
		local i=mode.weapons_index or 0
		add(upgrades,mode.weapons[i+1])
	end
	if mode.ranks then
		for i=0,#mode.ranks-1 do
			if i<=(mode.ranks_index or 0) then
				add(upgrades,mode.ranks[i+1])
			end
		end		
	end	
	for upg in all(mode.upgrades or {}) do
		add(upgrades,upg)
	end


	
	-- BG
	bg=mke()
	bg.dp=DP_BG
	bg.dr=function()
		rectfill(0,-32,MCW-1,MCH+64-1,1)
	end
	
	
	-- BOARD
	board=mke()
	board.dp=DP_SHADES
	board.x=board_x
	board.y=board_y
	board.dr=function(e,bx,by)	
	
		-- PIECE SHADE
		for e in all(ents) do exe(e.drs) end
		
		-- ROLE LINE
		for b in all(bads) do
			if b.role and b.see_hat and not b.dead and hero.sq then
				b.exposed=true
				e.friend=b.role=="spy"
				dr_dot_line(hero.sq,b.sq)
			end
		end
		
		-- SEER EYE		
		if hero and seer and seer.gr then
			local gr=seer.gr
			if gr.act=="move" then
				if seer.open>0 then
					local sq=gr.sq
					if seer.trg.ready then
						pal(2,5)
						sspr(240,224+flr(seer.open/4)*8,16,8,sq.x,sq.y+4)
						pal_rst()
					else
						shpr(240,224+flr(seer.open/4)*8,16,8,sq.x,sq.y+4,-1)
					end
				end
			end
		end
		
		-- GAMEPAD stuff
		draw_on_board()
	end


	-- INTER
	inter=mke()
	inter.perm=true
	inter.dp=DP_BG
	inter.dr=function()
		exe(mode.draw_inter)

		if not mode.no_shotgun then
			-- AMMO
			local ram=ammo-wait_ammo
			if mode.highlight_ammo and t%60<30 then ram=0 end
			for i=0,stack.ammo_max-1 do
				
				local y=board.y-10
				if inter.c_regen and i==ammo-1 then
					sspr(0,56,3,7,board.x+i*4,y)
					local c=max(0,(inter.c_regen-20)/10)
					y=y+c*6
				end	
			
				sspr(i<ram and 4 or 0,56,3,7,board.x+i*4,y)
			end
			
			-- SHIELDS
			local shields_max=SET.shields
			if mode.id == "tutorial" then
				shields_max=2
			end
			if mode.infinite_shield then
				local fr=0
				shields_max=1
				if inter.c_shield_lost and t%6<3 then fr=1 end
				pal(5,3)
				sspr(32+fr*6,64,6,7,board.x+stack.ammo_max*4+1,board.y-10)
				pal_rst()
			else
				local rsh=shields
				if inter.c_shield_lost and t%6<3 then rsh=rsh+1 end
				if mode.highlight_shields and t%60<30 then rsh=0 end
				for i=0,shields_max-1 do
					sspr(i<rsh and 32 or 38,64,6,7,board.x+stack.ammo_max*4+i*6+1,board.y-10)
				end
			end
		
			-- GRENADES
			for i=0,stack.grenades_max-1 do
				sspr(i<grenades and 44 or 50,64,6,7,board.x+stack.ammo_max*4+shields_max*6+i*6+2,board.y-10)
			end

			-- CHAMBER
			if hero and hero.c_need_ammo and t%12<6 then pal(2,5) end	
			local chmax=max(stack.chamber_max,chamber)
			local rch=chamber
			if mode.highlight_barrels and t%60<30 then rch=0 end
			for i=0,chmax-1 do
				local y=board.y-19
				
				if inter.c_reload and i==chamber-1 then
					sspr(0,56,3,7,board.x+i*4,y)
					local c=max(0,(inter.c_reload-20)/10)
					y=y+c*6
				end
			
				sspr(i<rch and 4 or 0,56,3,7,board.x+i*4,y)
			end
			
			pal_rst()
			-- SHOTGUN
			local dx=hero and hero.c_need_ammo and hrnd(4) or 0
			local fr,fy=96,0
			local dy=inter.ov_shotgun	and -1 or 0
			if inter.c_reload then fr=120 end
			if inter.c_shoot then
				local c=inter.c_shoot/10
				dx=dx-ease_uturn(c)*8
			end
			
			--112
			spritesheet("weapons")
			if mode.weapons_index then
				fy=(mode.weapons_index+1)*16
			end
			
			sspr(fr,fy,24,16,board.x+chmax*4+dx,board.y+dy-20)
			
			if ingame and not (leveling or info) and (ctrl_mode == "move" or ctrl_mode == "aim") then draw_button("reload",board.x+chmax*4+dx+25,board.y+dy-22) end
		end
		
		spritesheet("gfx")
		
		-- ROV
		local cx,cy=board_x-27,board_y+32		
		local gy=28
		if rov then
			sspr(168,104,24,24,cx,cy)
			-- BUTTON HINTS
			if not MOUSE then
				color(3)
				trifill(cx+3, cy+9, cx+1, cy+11, cx+3, cy+13)
				trifill(cx+19, cy+9, cx+21, cy+11, cx+19, cy+13)
				trifill(cx+9, cy+3, cx+11, cy+1, cx+13, cy+3)
				trifill(cx+9, cy+19, cx+11, cy+21, cx+13, cy+19)
			end
			
			local function disp_life_bar()
				local x,y=cx+2,cy+23
				rectfill(x,y,x+18,y+6,2)
				rectfill(x,y,x+18*(rov.hp/rov.hp_max),y+6,5)
				local hp=rov.hp.."&"
				local sav = font()
				font("pico")
				lprint(hp,x+10,y+1,4,1)
				font(sav)
			end

			if rov.type==6 then

				-- SPRITE
				if rov.dark then
					sspr(176,160,16,24,cx+4,cy+2-8)
				else
					sspr(192,80,16,16,cx+4,cy+2)
					sspr(208,80,16,16,cx+4,cy-5)
				end
				
				-- HP
				disp_life_bar()
				gy=gy+2
			else
			
				-- NAME
				local s=lang["short_piece_"..rov.type]
				lprint(s,cx+12,cy-6,4,1)
				
				-- SPRITE
				if rov.custom_dr then
					rov.custom_dr(rov, cx+4, cy+2)
					spritesheet("gfx")
				else				
					rov.dr(rov,cx+4,cy+4)
				end

				-- HEARTS
				if rov.hp_max>10 then				
					disp_life_bar()
					cy=cy+2
				else
					local ym=ceil(rov.hp_max/5)-1
					local n=0
					for dy=0,ym do
						local xm=min(rov.hp_max-dy*5,5)
						for dx=0,xm-1 do
							sspr(rov.hp>n and 8 or 11,56,3,3,cx+12+dx*4-xm*2,cy+dy*4+24-ym*2)
							n=n+1
						end			
					end
				end

			end
			
			-- MOVE
			dr_movemap(rov,cx,cy+gy)			

			-- TIME
			cy=cy+gy+24
			local bx=cx+12-(6+get_piece_tempo(rov)*2)/2
			sspr(14,56,5,7,bx,cy)
			local tmax=get_piece_tempo(rov)
			for i=0,tmax-1 do
				if rov.ready and t%60<30 and i==0 then -- FLICKERING??
					apal(5)
				end				
				sspr( i<=(tmax-rov.cd) and 20 or 22 ,56,2,7,bx+6+i*2,cy)
				pal_rst()
			end
			cy=cy+10

			-- POISON
			local status={}
			local function ads(id,n,suf)
				if not n then return end
				suf=suf or ""
				local s=get_lang(id)
				lprint(s,cx+12,cy,2,1)		
				cy=cy+6
				local s=n..suf
				lprint(s,cx+12,cy,3,1)			
			end
			ads("poison",rov.poisoned)
			ads("dodge",rov.dodge,"%")
			ads("dmg cap",rov.armorgap)
	
	
			if ctrl_mode=="strafe" or MOUSE then
				draw_mode()
			end
			
		elseif not mode.no_shotgun then

			local a,cy,ec=get_disp_stats()
			rectfill(cx-1,cy-2,cx+19,cy+#a*ec-4,1)
			
			for o in all(a) do
			
				local cl=3

				lprint(o.name,cx+10,cy,2,1)
				if type(o.value)=="string" then
					local s=o.value
					if o.boost  then --and cyc(2,6)==0
						--if o.boost>0 then s=s.."+" end
						--if o.boost<0 then s=s.."-" end
						if o.boost>0 then cl=4 end
						if o.boost<0 then cl=5 end						
					end					
					lprint(s,cx+10,cy+6,o.cl or cl,1)
					
					
					
				else
					for i=0,9 do
						local fr=112
						if o.rand and i<o.value+o.rand then fr=114 end
						if i<o.value then fr=116 end					
						sspr(fr,75,2,5,cx+i*2,cy+6)
					end
				end
				cy=cy+ec
			end
			
			draw_mode()
			
		end

		-- FOOTER
		local s,cl
		if mode.turns and not mode.hide_turn then
			s=lang.turn_.." "..mode.turns
			cl=2
			--s=lang.dif_..lang[difficulty].."	"..s.."	"..lang.mode_..lang[game_mode]
			if DEMO then
				s="demo - "..lang.turn_.. mode.turns
			end
			if hero and stack.deathcount and hero.deathcount_start and not hero.dead then
				local n=stack.deathcount+hero.deathcount_start-mode.turns
				s=lang.final_countdown..":"..n
				local cc=cyc(2,n==0 and 3 or 12)==0 
				if n>3 then 
					cl=t%32>2 and 3 or 4 
				else
					cl=cc and (n==0 and 4 or 3) or 5
				end
				
			elseif MODDED then
				s=s.." *Modded*"
			end
		end
	
		-- MSG
		if MOUSE and playing and rov_sq and not aiming and not rov_move and not aim and not btn"force_aim" then
			s=lang.force_aiming
			cl=2
		end
		if inter.msg and (inter.c_msg or inter.msg_perm) then
			s=inter.msg		
			cl=inter.msg_perm and 2 or (3+cyc(2,15,_t))
			if inter.c_warn then cl=4+cyc(2,6) end
			if inter.msg_flip and cyc(2,16)==0 then
				cl=inter.msg_flip
			end
		end
		if btn("unsafe") and playing and not mode.infinite_shield then
			s=t%90>60 and "" or lang.unsafe_mode
			cl=5
		end
		if hero and hero.checkmate then
			s=t%12<6 and lang.checkmate or ""
			cl=5
		end
		if s then		
			if mode.id=="tutorial" then
				lprint(s,MCW/2,board_y+8*SQ+6-15,cl,1)
			else
				lprint(s,MCW/2,board_y+8*SQ+6,cl,1)
			end
		end

	
	end
	
	-- CHRONO
	local cw,ch=35,9
	chrono_time=0
	chrono=mke(0,MCW-cw-1,MCH-ch-1)	
	chrono.dp=DP_TOP
	chrono.upd=function()
		if timerun then
			chrono_time=chrono_time+1
		end
	end

	-- DEBUG GAMEPAD MOUSE
	if DEBUG_GAMEPAD_MOUSE then
		debug_mouse=mke()	
		debug_mouse.dp=DP_TOP
		debug_mouse.dr=function(e,x,y)
			circfill(mx, my, 1.5, 4)
			circ(mx, my, 1.5, 5)
		end
	end

	-- SCEPTERS
	scepters={}

	-- SOULS
	souls={}	
	add_soul_slot()
	
	--
	crosshair=mke()
	crosshair.dp=DP_FX
	crosshair.dr=dr_crosshair
	
	
	-- CARDS SLOTS
	card_slots={}
	local gsd=mode.get_slot_data or function(team,i)
		if i>9 then return nil end
	
		local data={
			x=7+(i%2)*24+team*(MCW-48-14),
			y=13+flr(i/2)*32,
			team=team,
		}	
		return data
	end
	for j=0,1 do
		for i=0,99 do
			local d=gsd(j,i)			
			if d then
				local sl=mke()
				tbl_import(sl,d)
				add(card_slots,sl)
				sl.dr=function(sl,x,y)
					if mode.hide_cards then return end
					sspr(24,72,24,32,x,y)
					if sl.side_icon then
						sspr(168+sl.side_icon*8,96,8,8,x+24,y+11)
					end
					if sl.village then
						spritesheet("charnier")
						sspr(256,16,16,16,x+4,y+8)
						spritesheet("gfx")
					end
					
				end				
			end	
		end	
	end

	local butL=mke()
	butL.x = 8
	butL.y = 4
	butL.dr=function(sl,x,y)
		if get_nb_cards(0) == 0 then return end
		
		if leveling then
			draw_button("leftPage",x,y)
		else
			draw_button("info",x-2,y-2)
		end
	end
	local butR=mke()
	butR.x = MCW-8-13
	butR.y = 4
	butR.dr=function(sl,x,y)
		if leveling and get_nb_cards(1) > 0 then draw_button("rightPage",x,y) end
	end

	
	
	-- CARDS POOL
	cards={pool={}}	
	for c in all(CARDS) do 
		local ban=false
		for bid in all(mode.ban or {}) do
			if c.id==bid then ban=true end
		end
		if not ban then add(cards.pool,clone(c)) end
	end
	
	-- DEV
	if DEV and SEED then srand(SEED) end
	local function insert_card(ca)
		--local dat=get_card(id)
		local lim={0,0}
		for ca in all(cards) do
			lim[ca.team+1]=lim[ca.team+1]+1
		end
		if lim[ca.team+1]<10 then			
			local card=new_card(ca.id)
			
			add_card(card)
		end

		ca.n=ca.n-1
		if ca.n>0 then add(cards.pool,ca) end
		
		
	end
	for id in all(TEST_CARDS or {}) do
		local ca
		for tca in all(cards.pool) do
			if tca.id==id then
					ca=tca
			end
		end		
		if ca then
			del(cards.pool,ca)
			insert_card(ca)
		else
			log("can't find "..id )
		end
	end
	for id in all(TEST_SOULS or {}) do add_soul(id)	end

	--- CHEATCODE
	if PC then
		local function cheats()
			cheatcode("vision",function() VISION=1 sfx("trainer") end)
			cheatcode("busy",function() exe(mode.on_hero_death) sfx("menu_in",0.7) ingameover,menu,ov=nil remove_buts() reset() exe(mode.start) end)
		end
	
		if SD_PAD then
			local b=mke()
			b.x=0
			b.y=MCH-8
			b.upd=function(b)
				b.ov=(mx<8 and my>b.y)
				if b.ov and mcl then
					cheats()
				end
			end
			b.dr=function(b,x,y)
				if b.ov then
					rectfill(b.x,b.y,b.x+7,b.y+7, 2)
					if mlb then
						rectfill(b.x,b.y,b.x+7,b.y,3)
					end
				end
			end
		else -- brings up the virtual keyboard on SteamDeck...
			cheats()
		end
	end

	--newgif(_gifw, _gifh, GIF_LENGTH * 33)

end
function dr_movemap(piece,x,y)

	if piece.big then
		sspr(120,80,24,24,x,y)
		return
	end
	
	local grid={}
	for i=1,25 do grid[i]=0 end
	local a={"move","atk"}
	local function gp(px,py)
		return x+2+px*4, y+2+py*4
	end
	local function paint(px,py,n)
		local x,y=gp(px,py)				
		sspr(n*4,248,4,4,x,y)			
	end
	for i=0,24 do paint(i%5,flr(i/5),0) end
	
	for tag in all(a) do
		for bh in all(piece.behavior) do
			if bh[tag] and ( not piece.fear or tag~="atk" ) then						
				local x,y=2,2
				local n=tag=="move" and 2 or 3
				if bh.backstab then n=n+2 end
				
				if bh.id=="line" then								
					for di=bh[1],bh[2] do
						local max=min(bh[3],2)
						for k=1,max do
							local nx=x+DIRS[di*2+1]*k
							local ny=y+DIRS[di*2+2]*k	
							local cl=pget(nx,ny)
							local n=n
							if n==3 and (cl==2 or not bh.move) then
								if k==max then 
									n=n+1+(di or 0)												
									local ax,ay=gp(2,2)
									local bx,by=gp(nx,ny)
									
									line(ax+1,ay+1,bx+1,by+1,5)
								else
									n=-1
								end										
							end										
							paint(nx,ny,n)
						end						
					end
				end
				if bh.id=="jump" then
					for i=1,#bh,2 do
						local nx=x+bh[i]
						local ny=y+bh[i+1]									
						paint(nx,ny,n)						
					end
				end
				if bh.id=="teleport" then
					for dx=-2,2 do for dy=-2,2 do
						local nx=x+dx
						local ny=y+dy
						paint(nx,ny,n)
					end	end			
				end
				
			end				
		end			
	end
	paint(2,2,1)

end


function draw_game()


	cls()
	camera()

	-- YSORT
	local a={}
	for e in all(ents) do if e.z then add(a,e) end end
	custom_sort(a,function(e) return e.y+(e.ysort_dy or 0) end)
	for e in all(a) do del(ents,e) add(ents,e) end


	
	-- BUILD DEPTH LIST
	local a={}
	for i=0,15 do add(a,{}) end
	for e in all(ents) do 
		add(a[e.dp+1],e) 
	end	
	
	-- SCREEN SHAKE
	local cy=0
	if inter and inter.c_screen_shake and SET.scrshake==1 then
		local s=cyc(2,2,inter.c_screen_shake)*2-1
		cy=s*inter.c_screen_shake		
	end


	-- PAUSE
	local black=pause or (inter and inter.c_unpause)
	black=black and not inter.light
	if black then --
		if inter and inter.c_unpause then
			pal_inc(-1 * inter.c_unpause / 10)
		else 
			pal_inc(-2)
		end
		pause_pal=pal
		pal=function() end
	end
	

	-- DRAW ALL ( DEPTH )
	camera(0,cy)
	depth=0
	for tbl in all(a) do
		foreach(tbl,dre)		
		depth=depth+1
		if black and depth==DP_TOP then
			pal=pause_pal
			pal_rst()
		end
	end	
	camera()

	-- PAL SWITCH
	
	


	-- DRAW CHRONO
	if game_mode == "throne" and SET.speedrun==1 then 
		local cw,ch=35,9
		local x,y=MCW-cw-1,MCH-ch-1		
		if new_best_time and t%60<30 then
			pal(4,5)
			pal(5,4)
		end		
		rectfill(x,y,x+cw-1,y+ch-1,5)
		local s=get_time_string(chrono_time)
		local sav = font()
		font("pico")
		lprint(s,x+2,y+2,4)
		font(sav)
		pal_rst()		
	end

end
function end_game()
	reset()
	ingameover=true
	fade_to(0,30)
	fast_tracker(false)
	
	local bg=mke()
	bg.dr=function() 
		cls(1) 
		local s=lang.try_again
		lprint(s,MCW/2,MCH/2-16,4,1)
	end
	
	menu={}
	add(menu,mke())
	for i=0,1 do
		local f=function()
			menu=nil
			ingameover=false
			sfx("menu_in",0.7)
			remove_buts()
			ov=false
			--e.c_sel=30
			nxt=i==0 and mode.start or init_menu
			wait(30,fade_to,-4,30,nxt)
		end

		local e = mk_square_but(i==0 and lang.yes or lang.no, f, 32)
		e.x, e.y = MCW/2+(i*2-1)*24-e.pw/2, MCH/2
		add(menu,e)

		e.upd=function()
			if e.t>10 and btnp("cancel") then
				selectedOption=2
			end
		end
	end
	
	mdr=function(e)
		foreach(ents,dre)		
	end

	--init_menu()
end

--
function get_disp_stats()
	local a={}	
	
	local boost_firepower=get_firepower()-get_firepower(true)
	local boost_firerange=get_firerange()-get_firerange(true)
	local boost_spread=get_spread()-get_spread(true)
	
	
	
	add(a,{id="firepower",name=lang.power,value=get_firepower().."",boost=boost_firepower})	
	add(a,{id="range",name=lang.range,value=max(get_firerange(),0).."-"..max(get_firerange()+2,0),rand=2,boost=boost_firerange})	
	add(a,{id="f_arc",name=lang.f_arc,value=get_spread()..lang.degree_symbol,boost=-boost_spread})
	
	
	
	if stack.knockback>0 then
		add(a,{id="knock",name=lang.knock,value=stack.knockback.."%"})
	end
	if stack.pierce>0 then
		add(a,{id="pierce",name=lang.pierc,value=stack.pierce.."%"})
	end
	if stack.blade and stack.blade>0 then
		add(a,{id="blade",name=lang.blade,value=stack.blade..""})
	end
	if (stack.fearsome or 0) > 0 then
		add(a,{id="fearsome",name=lang.fright,value=stack.fearsome..""})
	end
	if hero and hero.hop and hero.hop>0 then
		local n=(hero.hop or 0)
		add(a,{id="jump",name=lang.jump,value=n..""})
	end
	if stack.grenades_max>0 then
		add(a,{id="g_dmg",name=lang.g_dmg,value=stack.grenade_dmg..""})
	end
	

	local ec=min(flr(128/#a),16)
	local cy=board_y+4*SQ-#a*ec/2
	if stack.special~="none" then cy=cy-16   end
	
	
	return a,cy,ec
end


-- INTRO
function start_lvl_music()
	--local track_id=mode.boss and "boss_A" or "ingame"
	local track_id=inter.bgm and inter.bgm or "ingame"--(mode.boss and "boss_A" or "ingame")
	if white_army[6] then track_id="boss_A" end
	if white_army[10] then track_id="boss_queen_A" end
	if white_army[11] then track_id="boss_riders_A" end

	if mode.id=="chase" then track_id="chase" end
	if mode.id=="endless" then track_id="endless" end
	if mode.id=="tutorial" then track_id="title_A" end
	if mode.id=="tutorial" and mode.lvl == 2 then track_id="codex" end
	if hero and hero.deathcount_start then track_id="final_countdown" end
	
	music(track_id)

end
function start_music(track_id)
	inter.bgm=track_id
	music(track_id)
end

function new_level()
	fade_to(0,30)

	ach_count("reset")
	bads={}	
	ingame=true
	aim,hero=nil
	inter.bgm=nil
	start_lvl_music()
	leader=get_leader_type()

	if mode.get_board_size then
		xmax,ymax=mode.get_board_size()
		board_x=(MCW-xmax*SQ)/2
		board_y=(MCH-ymax*SQ)/2+4--+8
		board.x=board_x
		board.y=board_y
	end

	-- SQUARES	
	local tempo=60
	squares={}	
	local k=irnd(2)
	for x=0,xmax-1 do for y=0,ymax-1 do

		local sq=mke(0,board_x+SQ*x,board_y+SQ*y)
		sq.mark={}
		sq.danger={}
		sq.shells={}
		sq.dp=DP_BOARD
		sq.seed=irnd(999)
		sq.px=x
		sq.py=y
		--sq.moat=sq.py==stack.moat
		sq.cl=(x+y)%2
		sq.c_deep=tempo+irnd(tempo)	
		if k==1 then
			local c=(atan2(sq.px-4,sq.py-4)-.25)%1
			sq.c_deep=tempo+c*(tempo-8)+irnd(8)		
		end
		sq.upd=function()


			-- PLAGUE
			if sq.plague and (sq.seed+t)%32==0 then
				fx_ground_poison(sq.x+rnd(16),sq.y+rnd(16),3-sq.cl)
			end

			-- SHELLS
			for i=1,#sq.shells do
				for j=i+1,#sq.shells do
					local a=sq.shells[i]
					local b=sq.shells[j]
					local dx=a.x-b.x
					local dy=a.y-b.y
					local d=6-sqrt(dx*dx+dy*dy)
					if d>0 then
						
						local an=atan2(dx,dy)
						local dx=cos(an)*d/2
						local dy=sin(an)*d/2
						a.x=a.x+dx
						a.y=a.y+dy
						b.x=b.x-dx
						b.y=b.y-dy
					end
				end			
			end
			
			
			
		end
		sq.dr=function(sq,x,y)

			local icl=3-sq.cl

			if sq.c_deep then
				local c=sq.c_deep/tempo
				c=1-ease_out_back(1-c)
				y=y+c*tempo
				pal_inc(min(0,1-c*5))
			end
			local fr=30+sq.cl
			if sq.moat then fr=fr-2 end
			spr(fr,x,y,1,1+3/16)
			
			-- GLYPH ( penta / waypoint / flagstone )
			if sq.penta then
				if sq.penta_off then pal(5,sq.cl==0 and 3 or 4 ) end
				spr(14,x,y)
			elseif sq.waypoint then
				spr(15,x,y)
			elseif sq.flagstone then
				pal(5,3+sq.cl)
				sspr(192,64,16,16,x,y)
				pal_rst()
			end			
			pal_rst()

			-- HOLE
			if sq.hole or (sq.c_was_hole and t%6<3) then
				if sq.cl==0 then pal_inc(1) end
				sspr(128+(sq.hole_fr or 2)*16,208,16,16,x,y)
				pal()
			end

			-- SHOW
			if (sq.show or sq.c_show or sq.selectable) or (not MOUSE and playing and ctrl_mode == "move" and sq.highlight) then
				if sq.imprint then
					sq.imprint(x,y,3+sq.cl)
				else
					rect(x+3,y+3,x+SQ-4,y+SQ-4,3+sq.cl)
				end
			end

			-- DEV
			if DEV and rov then
			
				if ROV_SHOW_MOVE_ZONES then
					local a = get_range(rov)
					for ssq in all(a) do
						if ssq==sq then
							fillp(0xC639,true)
							rectfill(x+1,y+1,x+14,y+14,icl)
							fillp()
						end
					end					
				end
				
				if ROV_SHOW_ATK_ZONES then
					for e in all(sq.danger) do
						if e==rov then
							local i=0
							fillp(0xC639,true)
							rectfill(x+1,y+1,x+14,y+14,icl)
							fillp()
						end				
					end			
				end
			end

			-- SHOW DANGER
			if ingame then
				local show_danger_fr=-1
				local show_danger_zone=show_danger_zone or mode.always_show_danger or VISION
				for i=1,#sq.danger do
					if (info and rov==sq.danger[i]) or show_danger_zone then
						if (sq.danger[i].hp or 1)>0 and not sq.danger[i].in_move then
							show_danger_fr=sq.cl
							if not info then break
							elseif rov==sq.danger[i] and show_danger_zone then
								show_danger_fr=2
								break
							end
						end
					end
				end
				if show_danger_fr>=0 and not sq.p then
					sspr(80+show_danger_fr*16,272,16,16,x,y)
				end			
			end
			
			if SHOW_DIST and sq[SHOW_DIST] then lprint(sq[SHOW_DIST],x+1,y+1,icl) end
			if SHOW_PDIST then
				if SHOW_PDIST.dgr then
					lprint(SHOW_PDIST.dgr[sq],x+1,y+1,3-sq.cl)
				end
				--[[
				local gr=SHOW_PDIST.grids[sq]				
				if gr then
					local s=flr(gr.score*10)/10
					lprint(s,x+1,y+1,3-sq.cl)
				end
				--]]
				
			end
			if SHOW_DANGER and #sq.danger>0 then lprint(#sq.danger,x+1,y+1,icl) end
		end
		
		add(squares,sq)
	end end

	-- SPAWN
	wait(tempo*2,spawn_pieces)
	
	--START SQ 
	start_sq=gsq(3+irnd(2),7)
	if mode.get_start_square then
		start_sq=mode.get_start_square()
	end	
	
	-- PENTAGRAMS & WAYPOINT
	pentasquares={}
	flagstones={}
	trench={}
	local pool={}
	for sq in all(squares) do
		if sq.py>=2 and sq.py<4 then --
			add(pool,sq)
		end
	end
	local function tsq(r)
		local sq=steal(pool)
		if not sq then return nil end
		local z=get_zone(sq,r or 1)
		for sq in all(z) do del(pool,sq) end
		return sq
	end	
	
	waypoint=tsq(0)
	for sq in all(squares) do
		if sq.py>4 and sq~=start_sq then
			add(pool,sq)
		end
	end
	for i=1,3 do add(pentasquares,tsq()) end
	for i=1,1 do add(flagstones,tsq(0)) end
	
	for sq in all(pool) do
		if sq.py>5 then del(pool,sq) end
	end
	for sq in all(squares) do
		if sq.py==1 then add(pool,sq) end
	end	
	for i=1,10 do add(trench,tsq(0)) end

	
	--
	build_stack()
	for b in all(bads) do
		b.hp=b.hp_max or b.hp
		if FRAGILE then b.hp=1 end
	end
	
	-- FAST_TRACKER
	fast_tracker(true, 5)

end
function spawn_pieces()

	-- FLIP ON CARDS
	for sl in all(card_slots) do
		if sl.ca and sl.ca.flipped then
			unflip_card(sl.ca)
		end
	end
	
	
	
	--
	if DEV_BOARD then
		for i=0,63 do
			local k=DEV_BOARD[i+1]
			local px=i%8
			local py=flr(i/8)			
			local bad=true
			
			if k>=20 then
				k,bad=k-20
			
			end
			
			if k==8 then
				start_sq=gsq(px,py)
			elseif k~=9 then
				local p=new_piece(k,bad,gsq(px,py))
				exe(p.give_role)
				fx_spawn(p)
			end
		end
		wait(30,spawn_hero)
		build_stack()
		
		return
	end
	
	-- BADS	
	local work={}
	for k,v in pairs(white_army) do
		for i=1,v do
			add(work,k)
		end
	end
	
	local function f(n)
		return -n-(PIECES[n+1].big and 999 or 0)
	end
	custom_sort(work,f)
	
	local xpos={3,4,2,5,1,6,0,7}
	local xi=1
	local py=0
	
	if stack.anarchy then shuffle(work) end

	--del(work,6)

	local function spawn()
		if #work==0 then
			spawn_hero()
			return
		end	
		local k=work[1]
		
		if k==6 and stack.ruler then
			replace_card("ruler","Fallen Dynasty",bind(wait,10,spawn))
			add(upgrades,{torn_theo=true})
			build_stack()
			return
		end
		
		
		local px,boss=xpos[xi]
		local tsq=gsq(px,py)
		if (k>0 or py>0 or stack.anarchy ) and is_free_for(tsq,k) then --not tsq.p
			del(work,k)
			local p=new_piece(k,true,tsq)
			fx_spawn(p)
		else

		end
		xi=xi+1
		if xi>8 then
			xi=1
			py=py+1
		end		
		wait(10,spawn)
		
	end
	spawn()
	
	
	
end
function spawn_hero()
	
	sfx("hero_light")

	-- FX FLAMES
	local tempo=60
	local r=32
	local max=8
	for i=1,max do
		local an=i/max
		local dx,dy=cos(an)*r,sin(an)*r
		local kt=irnd(32)
		local function pop()
			local e=mke(0,start_sq.x+8+dx,start_sq.y+8+dy)					
			mv(e,-dx,-dy,tempo-kt,bind(kl,e))
			e.twcv=ease_in_back
			e.dr=function(e,x,y)
				local r=(e.t/tempo)*3
				circfill(x,y,r+cyc(2,3)*r,3+cyc(3,3))
			end
		end
		wait(kt,pop)
	
	end
	
	-- BLACK ARMY
	local work={}
	for k,v in pairs(black_army) do
		for i=1,v do add(work,k) end
	end	
	local function get_free_sq()
		local a={}
		for x=0,7 do for y=4,6 do
			local sq=gsq(x,y)
			if is_free(sq) then add(a,sq) end
		end end
		return rnd(a)
	end
	
	local function spawn_army()
		if #work==0 then
			init_new_turn()
			return
		end		
		local k=work[1]
		del(work,k)

		local p=new_piece(k,false,get_free_sq())
		fx_spawn(p)
		
		wait(10,spawn_army)
	end

	-- HERO
	local function spawn_king()			
		hero=new_piece(5,false,start_sq)
		hero.tracked=1
		hero.mastermind=1
		hero.boost={}
		hero.frags={}
		hero.an=0
		hero.c_burning=60	
		reset_move_cursor()		
		if mode.no_shotgun then
			wait(10,spawn_army)
		else
			wait(stack.cannonball and (stack.cannonball*16+1) or 10,refill_ammo,spawn_army)
		end
		sfx("spawn_final")
		
		
		--
		if DUMMY then
			local p=new_piece(DUMMY,true,gsq(start_sq.px-1,start_sq.py-2))
		end
		
		--
		if stack.cannonball then
			local a={}
			for x=0,7 do for y=4,6 do
				local sq=gsq(x,y)
				if is_free(sq) then add(a,sq) end
			end end
			
			for i=1,stack.cannonball do
				if #a>0 then
					local sq = steal(a)
					local function f()
						local p=new_piece(9,true,sq)
						fx_spawn(p,8)
					end
					wait((i-1)*16,f)
				end
			end
		end

		-- 
		build_stack()
		--for b in all_bads() do
		--	b.hp=b.hp_max
		--end
	end
	wait(tempo,spawn_king)
	

	
	
	
	-- ADD FALSE KING TAG
	if stack.false_king then
		local a={}
		for b in all_bads() do if b.type==5 then add(a,b) end end		
		for i=1,stack.false_king do
			if #a==0 then break end
			local p=steal(a)
			p.false_king=true
		end		
	end	
	

end
function refill_ammo(nxt,skip_init)

	if not skip_init then
		hero.free_souls=stack.free_souls and stack.free_souls or 0
	end


	local re=bind(refill_ammo,nxt,true)


	if ammo<stack.ammo_max then
		inc_ammo()
		wait(10,re)
		return
	end
	
	if chamber<stack.chamber_max then
		--ammo=ammo-1
		chamber=chamber+1
		inter.c_reload=30
		sfx("reload")
		wait(20,re)
		return
	end

	if grenades<stack.grenades_max then
		grenades=grenades+1
		sfx("reload")
		wait(20,re)
		return
	end


	--
	if short_refill then
		nxt()
		short_refill=false
		return
	end

	-- REFILL WANDS
	for e in all(scepters) do
		if e.cd>0 then
			e.cd=e.cd-1 
			sfx("refill_wand")
			wait(10,re)
			return
		end
	end
	
	-- CHOOSE PAWN ROLES ( HEIR / SPY )
	local pawns={}
	local all_roles={"heir","spy"}
	local roles={}
	for o in all(ROLES) do 
		for i=1,(stack[o.id] or 0) do add(roles,o.id) end
	end
	for b in all(bads) do 
		if b.role then del(roles,b.role) end	
		if b.type==0 and not (b.role or b.jester) then add(pawns,b) end		
	end
	if #roles>0 then
	
		if #roles<#pawns then
			local a=clone(pawns)
			local hats={}
			local wt=10
			local count=16
			for id in all(roles) do
				local p=steal(a)
				local crown=mke(0,p.x,p.y)
				crown.cur=p
				crown.role=id
				crown.dp=DP_FX
				crown.dr=function(e,x,y)
					sspr(160+ROLES[e.role].gid*9,26,9,6,x+3,y-4)
				end
				add(hats,crown)
			end		

			local function f(ev)
				count=count-1
				if count==0 then 
					for h in all(hats) do kl(h) end
					kl(ev)
					re() 
					return 
				end
			
				sfx("tic")
				local a=clone(pawns)			
				for h in all(hats) do	h.cur.role=nil end
				for h in all(hats) do		
					if count<=2 then
						h.invis=true
					end
					if count<=4 then
						h.life=60
						h.blink=60
					end
					local prev=h.cur
					del(a,prev)
					h.cur=steal(a)
					add(a,prev)
					h.cur.role=h.role			
					h.cur.c_heir=30
					mvt(h,h.cur.x,h.cur.y,wt)
					h.jmp=8
					h.twcv=ease_in_out
				end
				
				wait(wt+1,f)
				
				
				
			end
			f()		
			--wait(160,re)
			
			return 
		else
			for p in all(pawns) do
				p.role=steal(roles)
			end
		end
		
	end

	-- CHOOSE JESTER
	local jesters=0
	for p in all(bads) do if p.jester then jesters=jesters+1 end	end
	if jesters<(stack.jester or 0) and #pawns>0  then
		local p=steal(pawns)
		jesterize(p)
		wait(p.c_jester_spawn,re)
		return
	end
	
	-- CHOSEN
	for k,v in pairs(stack) do	
		k,targets=parse_effect(k)	
		if targets.choose then 
			local chosen=0
			local a={}
			for p in all(bads) do	
				if is_valid_target(p,targets,true) then
					if p[k] then 
						chosen=chosen+1
					else
						add(a,p)
					end
				end
			end
			if v>chosen and #a>0 then
				local p=rnd(a)
				sfx("jester")
				p[k]=1
				setup_piece(p)
				p.hp=p.hp_max
				p.c_morph=60
				wait(p.c_morph,re)
				return
			end
		end 
	end
	
	-- FREE_SOULS
	if hero.free_souls>0 then		
		msg(lang.free_soul,60)
		hero.free_souls=hero.free_souls-1
		add_soul(1+irnd(3))		
		wait(60,re)
		return
	end
	

	
	--
	(nxt or new_turn)()

end
function jesterize(p)
	sfx("jester")
	p.jester=1
	setup_piece(p)
	p.c_jester_spawn=60
end

function clean_up(nxt)

	hero.win=nil

	-- UNFLIP CARDS
	for sl in all(card_slots) do if sl.ca then
		
		if sl.ca.flipped then
			unflip_card(sl.ca)
			sfx("flip_back")
			wait(10,clean_up,nxt)
			return
		end
		if sl.ca.reversed then
			sl.ca.reversed=false
			sl.ca.c_rev_fade=30
			--sl.ca.alt_dr=nil
			wait(10,clean_up,nxt)
			return
		end		
		if sl.ca.marked then
			sl.ca.marked=nil
		end
				
	end end
	
	

	-- RESET TEMPO AND CARDS TURN COUNT
	temporary={}
	events={}
	build_stack()	
	for ca in all(get_slot_cards()) do
		ca.turn_count=0
		ca.disrupted=nil
	end
	
	--
	exe(nxt)
	
end


-- STATS
function get_boost(k)
	local n=0
	-- SQUARE
	if hero and hero.sq then n=n+(hero.sq.stack[k] or 0) end
	if hero then n=n+(hero.boost[k] or 0) end
	return n
end

function get_firepower(raw)
	local fp=stack.firepower
	if raw then return fp end	
	
	-- SQUARE BOOST
	fp=fp+get_boost("firepower")
	
	-- FLAGSTONE BONUS
	if hero and hero.sq and hero.sq.flagstone then
		fp=fp+1
	end
		
	-- SOULS
	local ab=stack.absolution or 0
	for sl in all(souls) do
		if not sl.id then fp=fp+ab end
	end
	
	-- CONFIDENCE
	if stack.confidence then 
		fp=fp+max(stack.chamber_max-chamber,0)
	end	

	-- BULLY / PLAGUE / SCOPE
	if hero and hero.sq then
		for e in all(hero.sq.danger) do
			if e.bully then fp=fp-1 end
		end
		if hero.sq.plague then
			fp=fp-2
		end		
	end
	
	--[[ SCOPE
	if hero and hero.sq and hero.scope then
		fp=fp+(#hero.sq.danger==0 and 1 or 0)	
	end
	--]]
	

	-- FULL
	if chamber>=stack.chamber_max then
		fp=fp+(stack.full_firepower or 0)
	end
	
	return max(1,fp)
end
function get_firerange(raw)
	local n=stack.firerange
	if raw then return n end
	n=n+get_boost("firerange")
	if hero and hero.scope then n=n+2 end	
	if chamber>=stack.chamber_max then
		n=n+(stack.full_firerange or 0)
	end
	return n
end
function get_spread(raw)
	local n=stack.spread
	if raw then return n end
	n=n+get_boost("spread")
	if hero and hero.scope then 
		n=n-45 
	end
	if aim then	n=n+15 end	
	n=max(5,n)	
	return n
end
function get_dodge(e)
	local dodge=e.dodge or 0
	if e.sq and (e.sq.hole or e.sq.moat) and stack.hole_cover then
		dodge=dodge+50 
	end
	return dodge
end

-- LEVEL_UP
function end_level(nxt, no_music)
	fast_tracker(true, 5)

	if not no_music then wait(36,music,"level_up_A",0) end
	ingame=false

	local function bye_level()
		exe(mode.on_bye_level)
		mode.turns=nil
		inter.msg=nil
		tempo=40
		remove_buts()
		for sq in all(squares) do
			local function f()
				if irnd(8)==0 then 
					sfx("tile_move",.25+rnd(.5))
					--wait(60,sfx,"tile_out") 
				end
				sq.c_deep=1
				sq.rev_c=true
				sq.life=80
			end
			wait(irnd(tempo),f)
		end
		wait(tempo+60,nxt)
	end


	--- HERO LEAVE
	sfx("hero_leave")
	goto_heaven(hero,bind(clean_up,bye_level))
	--[[
	local tempo=40
	local e=mke(0,hero.x+8,hero.y+12)
	e.dp=DP_SHADES
	e.life=tempo
	e.dr=function(e,x,y)
		local c=e.life/tempo
		c=ease_in(c)
		local ec=c*8
		local cl=3+t%3
		rectfill(x-ec,0,x+ec-1,y,cl)
		hero.clp={x=x-ec,y=0,w=ec*2,h=y}
	end
	
	local function last_parts()
		for i=0,16 do
			local p=mke(0,e.x,rnd(e.y))
			p.vy=hero.vy--(1+hrnd(.25))
			p.frict=.9+rnd(.1)
			--p.we=hero.we
			p.life=16+rnd(16)
			p.dr=function(e,x,y)
				pset(x,y,5)
			end
			--p.blink=16
		end		
	end
	wait(tempo,last_parts)	
	
	e.nxt=bind(clean_up,bye_level)
	hero.we=-.15
	hero.life=tempo
	
	--]]
	
	

	-- KILL SHELLS
	for sq in all(squares) do for b in all(sq.shells) do
		kl(b)
		local e=mke(0,b.x+2,b.y+4)
		e.life=12
		e.we=-.02-rnd(.01)
		e.dr=function(e,x,y)
			circfill(x,y,e.life/3+t%3,5)
		end
	end end

	-- KILL PROJECTILES
	for e in all(ents) do
		if e.projectile then e.life=30 end
	end			

	-- KILL OVERLOADED SHELLS
	chamber=min(chamber,stack.chamber_max)

	-- ASCEND PIECES LEFT ( probably balls )
	for b in all_pieces() do 
		if b~=hero then	goto_heaven(b) end
	end
	


	-- KILL HOLOKING
	if hero.holoking then
		kl(hero.holoking)
		fx_vanish(hero.holoking)
	end
	
	-- SEER
	if seer then
		seer.life=32
		seer.blink=32
	end

	-- ACHIEVEMENTS
	ach_event("end_floor")
	

	

end
function level_up(data,nxt)
	if leveling then return end -- avoid duplicate level_ups


	fast_tracker(false)

	-- PATIENCE CHOICE
	if one_time("browse") then
		inter.rem_black_card=1	-- remove the black card from future choice	
		local function f()
			add_any_card({team=0},bind(level_up,data,nxt),{"Patience"})
		end		
		show_card("Patience",f,60,stack.browse)
		return
	end
	
	-- EXTRA WHITE CHOICES
	local wc=stack.extra_white_choice or 0	
	for a in all(data.choices) do for o in all(a) do
		 -- RMV WHITE CHOICES if FORCED CARD
		if o.id and o.team==1 then wc=0 end 
	end end	
	if wc>0 then
		for a in all(data.choices) do for i=1,wc do
			add(a,{team=1})
		end end
		data.pan_width=data.pan_width+wc*24
	end

	
	
	local xm=data.pan_xm
	local ym=data.pan_ym	
	msg(lang.choose_set,-1)
	leveling=true	
	local choices={}	
	local ec=4
	local sx=board_x+(128-data.pan_width)/2
	local sy=board_y+(128-data.pan_height)/2
	local pw=(data.pan_width-(xm-1)*ec)/xm
	local ph=(data.pan_height-(ym-1)*ec)/ym

	local recycle_count=stack.search or 0
	local recycle_done
	local discarded={}
	local hover

	local function post_choice()
		-- RESTORE POOL
		for gh in all(discarded) do
			if gh.pwe>0 and gh.n>0 then
				add(cards.pool,gh)
			end
		end
		discarded={}
		
		-- BOLD PLAN
		if one_time("replace_white_card") then
			msg(lang.replace_white_card,-1)
			local function f()
				add_any_card({team=1},post_choice)			
			end
			local function rem_card(ca)
				tear_apart(ca,f)	
				msg()
			end
			local function chk(ca) return ca.team==1 end	
			ask_card(chk,rem_card)	
			return		
		end
		
		exe(nxt)
	end
	local function choose(ch)
		remove_buts()
		msg()
		
		
		local team={{},{}}		
		for och in all(choices) do
			for ca in all(och.cards) do
				ca.chosen=och==ch
				if ca.chosen then
					add(team[ca.team+1],ca)
				end
			end
		end
		
		-- WHITE CHOICE
		while wc>0 do
			wc=wc-1
			local ca=steal(team[2])
			ca.chosen=false
		end
	
		
		-- RESTORE CARD POOL
		for och in all(choices) do				
			for ca in all(och.cards) do			
				local gh=ca.ghost
				if ca.chosen then
					gh.n=gh.n-1
					inc_stats(gh.id,true)
				else
					inc_stats(gh.id,false)
				end				
				add(discarded,ca.ghost)
			end
			if och~=ch then
				och.life=32
				och.blink=32			
			end
		end
		save_stats()

		sfx("level_up_sel")
		local function zoom()
			kl(ch)
			fx_zoom_panel(ch.x,ch.y,pw,ph)
			
			local function f()
				wait(10,post_choice)
			end
			
			for i=1,#ch.cards do
				local ca=ch.cards[i]
				pop_child(ca)	
				add_card(ca,i==#ch.cards and post_choice or nil)
			end

			
		end

		local function exclude()
			local wt=2
			for ca in all(ch.cards) do
				if not ca.chosen then
					ca.life=32
					ca.blink=32
					del(ch.cards,ca)
					wt=64
				end
			end
			if wt>2 then sfx("exclude_card") end
			wait(wt,zoom)
		end

		local function scroll()
			mvt(ch,ch.x,board_y+(ph+4)/2-12,30,exclude)
			ch.twcv=ease_in_out
		end
		wait(40,scroll)
		
	end
	
	
	-- BUILD CHOICES
	local dchoices=clone(data.choices)	
	if inter.rem_black_card then
		inter.rem_black_card=nil
		for a in all(dchoices) do
			for cons in all(a) do
				if cons.team==0 then
					del(a,cons)
				end
			end
		end
	end
	
	for i=0,#dchoices-1 do
		local px=(i%xm)
		local py=flr(i/xm)
		local cards_setup=dchoices[i+1]
		local cmax=#cards_setup
		
		
		local ch=mke(0,sx+px*(pw+ec),MCH)
		ch.dp=DP_INTER
		local ov=false
		ch.id=i
		add(choices,ch)

		local flip_tempo=16
		local tsp=30
		local ji=i
		ch.upd=function()

		end
		ch.dr=function(ch,px,py)
			--if ov then py=py-1 end
			tcamera(-px,-py)
			

			--			
			rectfill(0,0,pw-1,ph-1,2)
			hdclear(0,0,pw-1,ph-1)
			local c=3
			if ch.ovl and not mode.block_ui_ctrl  then
				c=5 --4+cyc(2,3) --  FLICKERING 
			end
			rect(0,0,pw-1,ph-1,c)
			tcamera(px,py)		
		end
		
		-- LIBS
		
		local function pick_cards()

			local ids={}
			for j=0,#cards_setup-1 do		
				--
				local cons=cards_setup[j+1]
				if cons.id=="Homecoming" and recycle_done then
					cons.id="Tragic Homecoming"
				end
				-- DESC Modifications
				local gh=pick(cons,ids)	
	
				if gh.id=="Homecoming" then				
					local desc_key=i==0 and "queen_escape" or "queen_everywhere"
					gh.desc=get_lang(desc_key)
				elseif gh.id=="Tragic Homecoming" then
					local desc_key=i==0 and "queen_escape_tragic" or "queen_everywhere_tragic"
					gh.desc=get_lang(desc_key)
				end	
				--
				if mode.id=="tutorial" then
					gh.desc=get_lang(j==0 and "tuto_card_black" or "tuto_card_white")
				end						
				--
				add(ids,gh)

			end
			
			local ecc=4
			local ma=(pw-#ids*24-(#ids-1)*ecc)/2

			ch.cards={}
			for ki=0,#ids-1 do
				local ghost=ids[ki+1]
				local ca=new_card(ghost.id,ghost.desc)
				
				ca.ghost=ghost
				ca.x=ma+(ec+24)*ki--8+ki*64
				ca.y=1+(ph-32)/2
				add_child(ch,ca)
				ca.flip_co=1
				ca.flipped=true
				add(ch.cards,ca)
			end
		
		end
		local function recycle()
			-- avoid spam click incidents
			if ch.cards[1].flipped then return end
			if ch.hint then kl(ch.hint) end
			
			recycle_count=recycle_count-1
			recycle_done=1
			inter.searched=inter.searched and inter.searched+1 or 1
			exe(mode.check_unlocks)
			sfx("recycle_cards")
			for ch in all(ch.cards) do
				--kl(ch)
				ch.c_hold=600
				ch.flipped=true
			end
			local function f()
				for ca in all(ch.cards) do					
					add(discarded,ca.ghost)
					kl(ca)
				end
				pick_cards()
			end
			wait(30,f)
			
			
		end
		local function spawn_but()
			local function chf()
				if mode.block_ui_ctrl then
					return
				end
				for ca in all(ch.cards) do 
					if ca.flipped then return end
				end
				ov=false
				if ch.hint then kl(ch.hint) end
				ch.hint=nil
				choose(ch)
			end
			local b=mk_but(ch.x,ch.y,pw,ph,chf)
			b.over=function()
				hover=ch
				ch.ovl=true
				sfx("tic",.5)
			end
			b.out=function()
				if hover==ch then hover=nil end
				ch.ovl=false
				
				if not ch.hint then return end
				kl(ch.hint)
				ch.hint=nil
			end
			timerun=true

			for i=1,#ch.cards do
				local ca=ch.cards[i]
				local function get_str()
					local ca=ch.cards[i]
					return get_lang(ca.id).."|"..get_desc(ca,true)
				end
				local b=mk_hint_but(ch.x+ca.x,ch.y+ca.y,24,32,get_str,{4,3})
				b.lvlup_inspect=true
			end

		
			-- RECYCLE
			if recycle_count>0 then		
				local sz=15
				local px,py=pw+3,(ph-sz)/2
				if mode.recycle_down then
					px,py=(pw-sz)/2,ph+1
				end
				
				local e=mke(nil,px,py)
				local b=mk_but(0,0,sz,sz,recycle)
				b.over=function()
					sfx("tic")
				end
				add_child(e,b)
				add_child(ch,e)
				e.upd=function(e)
					if recycle_count<=0 then 
						kl(e)
					end
					
					if (not MOUSE or SD_PAD) and btnp("reload") and ch.ovl then
						recycle()
					end
				end
				e.dr=function(e,x,y)
					if b.ov then
						pal(2,5)
					elseif (ch.ovl and MOUSE and not SD_PAD) or ((SD_PAD or not MOUSE) and hover and not ch.ovl) then
						pal(2,1)
						pal(3,1)
						pal(4,2)
					end
					--rectfill(x,y,x+sz-1,y+sz-1,b.ov and 5 or 2)
					--sspr(208,224,8,8,x+1,y+1)
					sspr(224,224,15,15,x+1,y+2)
					lprint(recycle_count,x+7+2,y+7,4,1)
					pal(2,2)
					pal(3,3)
					pal(4,4)
					
					if not b.dead and ch.ovl and (SD_PAD or not MOUSE) then
						draw_button("reload", x+17, y+6)
					end
				end
			end		
		
		end
		
		--
		pick_cards()
		
		local ty=sy+py*(ph+ec)
		wait(8+i*8,mvt,ch,ch.x,ty,16)
		wait(24+#dchoices*8+#ch.cards*flip_tempo,spawn_but)
		ch.twcv=ease_out_back
		
	end
	
	if not MOUSE then
		wait(23+#dchoices*8+16, function()
			local ch
			if ym>xm then
				if btn("leftStickY+") or btn("rightStickY+") then
					ch = choices[#choices]
				else
					ch = choices[1]
				end
			else
				if btn("leftStickX+") or btn("rightStickX+") then
					ch = choices[#choices]
				else
					ch = choices[1]
				end
			end
			
			if not MOUSE then
				mMenu.x = ch.x
				mMenu.y = ch.y
				mx = mMenu.x
				my = mMenu.y
			end
		end)
	end


	-- CARD FLIPPER
	local function card_flipper(ev)
		if not leveling then kl(ev) end
		if ev.t>16 then
			for ch in all(choices) do
				for ca in all(ch.cards) do
					if ca.flipped and not ca.c_hold then
						ca.flipped=false
						sfx("turn_card",.75) 
						ev.t=0
						return
					end
				end				
			end			
		end
	
	end
	loop(card_flipper)

	-- CARD HINTS
	init_cards_hint()

end
function one_time(k)
	local res = (stack[k] or 0) > (inter[k] or 0)
	if res then inter[k]=inter[k] and inter[k]+1 or 1 end
	return res
end

function add_any_card(cons,nxt,exclude)
	exclude=exclude or {}
	msg(lang.choose_any_card,-1)
	
	-- BUILD LIST
	for id in all(exclude) do exclude[id]=1 end
	local a={}
	for ca in all(cards.pool) do
		local ok=true
		for k,v in pairs(cons) do	if ca[k]~=v then ok=false end end	
		if ok and is_card_available(ca,with) and ca.pwe>0 and not exclude[ca.id] then
			add(a,ca)
		end	
	end			
	
	--
	local ma=32
	local xm,ym=5,3
	local pw,ph=xm*24+2*ma,ym*32+6
	
	local page=0
	local pan=mke(0,(MCW-pw)/2,(MCH-ph)/2)
	pan.dp=DP_INTER
	pan.dr=function(e,x,y)
		hdclear(x,y,x+pw,y+ph)
		rectfill(x,y,x+pw-1,y+ph-1,2)
		rect(x,y,x+pw-1,y+ph-1,4)
		draw_button("validate",x+pw-11,y+ph-12)
	end
	
	local display_page
	local page_max=flr(#a/(xm*ym)-.0001)
	local function inc_page(n)
		sfx("sel_opt",nil,0.4)
		page=mid(0,page+n,page_max)
		display_page()
	end
	local function select_card(oca)
		remove_buts()
		msg()	
		sfx("level_up_sel")
		
		-- EXHAUST AND REMOVE FROM DECK IF NEEDED
		oca.gh.n=oca.gh.n-1
		inc_stats(oca.gh.id,true)
		if oca.gh.n==0 then del(cards.pool,oca.gh) end		

		pan.ents={oca}
		mv(oca,0,-12,40)
		oca.twcv=ease_in_out

		local function f()
			kl(pan)
			local ca=new_card(oca.id)
			ca.x=oca.x+pan.x
			ca.y=oca.y+pan.y
			add_card(ca,nxt)				
			fx_zoom_panel(pan.x,pan.y,pw,ph)
		end
		wait(40,f)

	end
	
	function display_page()

		init_cards_hint(true)
	
		-- CLEAN
		pan.ents={}
		
		-- CARDS
		local list = {}
		for i=0,xm*ym-1 do			
			local ca=a[1+i+page*xm*ym]		
			if ca then
				local e=mke(0,ma+(i%xm)*24,4+flr(i/xm)*32)
				e.gh=ca
				tbl_import(e,ca)
				add_child(pan,e)			
				
				e.dr=function(e,x,y)
					sspr(48,72,24,32,x,y)
					dr_flip_card(x,y,ca,0,nil)
				end
				
				local b=mk_but(e.x,e.y,24,32,bind(select_card,e))
				add_child(pan,b)

				local desc=get_lang(ca.id).."|"..get_desc(ca)
				local b=mk_hint_but(e.x,e.y,24,32,desc,{4,3},nil,true)
				add_child(pan,b)
				b.iscard=true
				b.dr=function(e, x, y)
					if not MOUSE and hint_but==b then
						rect(x, y - 1, x + 22, y + 29, 5)
					end
				end	

				add(list, e)
			end
		end
		
		-- SIDE BUT
		for i=0,1 do		
			if (page>0 or i==1) and (page<page_max or i==0) then
				local bt = i==0 and "leftPage" or "rightPage"
				local dx=(ma-8)/2
				local b=mk_but(i*(pw-ma),0,ma,ph,bind(inc_page,i*2-1))
				add_child(pan,b)
				local e=mke(0,dx+i*(pw-ma),(ph-32)/2)
				add_child(pan,e)
				e.dr=function(e,x,y)
					draw_button(bt, x-2, y-8)
					local cl=(b.ov or btn(bt)) and 5 or 3
					pal(5,cl)
					sspr(192,160,8,24,x+i*8,y,8*(1-i*2),24)
					pal(5,5)
				end
			end
		end
		
		push_mode("pick_any_card", xm, list, page>0 and bind(inc_page,-1), page<page_max and bind(inc_page,1))
	
	end
	
	display_page()

	pan.y=pan.y+MCH
	mv(pan,0,-MCH,16)
	pan.twcv=ease_out_back



end

-- GET
function get_desc(ca,ignore_flip)

	--local desc=ca.desc or ""
	
	-- FLIP CONDITION
	local flip_cond
	if ca.flip_on then
		flip_cond=lang["cond_"..ca.flip_on]
		if sub(ca.flip_on,1,3)=="no_" then
			local pname=sub(ca.flip_on,4)
			for p in all(PIECES) do if p.name==pname then
				pid=p.type
			end end
			flip_cond=get_lang("cond_no_piece", get_piece_name(pid))
		end
		if sub(ca.flip_on,1,5)=="only_" then
			local pname=sub(ca.flip_on,6)
			for p in all(PIECES) do if p.name==pname then
				pid=p.type
			end end
			flip_cond=get_lang("cond_only_pieces", get_piece_name(pid))
			if ca.id == "Iron Maiden" then
				flip_cond = nil
			end
		end
	end
	
	-- FLIPPED BREAK
	if ca.flipped and not ignore_flip then	
		if flip_cond then
			return get_lang("card_exhausted_bc",flip_cond)
		else

			local when=mode.id=="chase" and lang.refresh_when_chase or lang.refresh_when
			return get_lang("card_exhausted",when) 
		end
	end
	

	-- DELAY
	local desc,delay,final="","",""
	desc=ca.desc or ""
	
	if ca.delay then	
		local dl=get_delay(ca.delay)
		delay=get_lang("at_delay",dl)	
		if ca.cycle then delay=get_lang("every_x_turn",dl)	end
	end	
	if ca.final then
		final=get_lang("at_final")
	end

	local function add_line(s)
		if #desc>0 then desc=desc.."|" end
		desc=desc..first_upper(s)
	end

	-- ADD / REMOVE PIECES
	local function adp(a,black)	
		if not a or #a==0 then return end
		local pieces=get_pieces_list(a,black)
		local s=get_lang("add_group",{pieces})
		s=rep(s,"$delay",delay)	
		s=rep(s,"$final",final)
		s=sbs(s,"  "," ")
		s=sbs(s," $","")
		s=sbs(s," %.",".")
		
		-- chinese
		s=sbs(s,"，，","，")
		s=sbs(s,"^，","")
		
		add_line(s)
		--[[
		local a=get_inventory(a)
		for k,v in pairs(a) do			
			local s
			if delay=="" and lang.add_piece_nodelay then
				s=get_lang("add_piece_nodelay",{v,get_piece_name(k,black)})
			else
				s=get_lang("add_piece",{v,get_piece_name(k,black)})		
				s=rep(s,"$delay",delay)				
			end   
			s=rep(s,"$final",final)
			add_line(s)
		end
		--]]
	end
	if ca.sac and #ca.sac>0 then
		local pieces=get_pieces_list(ca.sac,black)
		local s=get_lang("rem_group",{pieces})
		add_line(s)		
		--[[
		local a=get_inventory(ca.sac)
		for k,v in pairs(a) do
			local s=get_lang("rem_piece",{v,get_piece_name(k)})
			add_line(s)
		end
		--]]
	end
	adp(ca.gain)
	adp(ca.allies,true)	

	
	

	-- WANDS
	if ca.wand then
		local w2=ca.wand[2]
		if w2=="firepower" then 
			w2=lang.firepower 
		end
	
		local s=get_lang("wand_"..ca.wand[1],w2,ca.wand[3])
		if s then
			s=rep(s,"$leader", get_leader_name())
		end
		add_line(s)
	end

	-- PIECE BONUS && EFFECTS	
	--local raise={}
	local function gd(k,v)
		if not k then return nil end
		
		local leader = get_leader_name()
		
		-- EFFECTS
		local key = console_alt("effect_"..k)
		if lang[key] then
			local reps={v,sig(v)}
			local trgp=get_piece_name(v)
			reps["<target_piece>"]=trgp
			reps["<target_pieces>"]=get_plural(trgp,999)
			reps["<leaders>"]=get_plural(leader,999)
			reps["<inc>"]=sig(v)
			
			local s=get_lang(key,reps)
			if s then
				s=rep(s,"$leader", leader)
				return s, effect_order[k] or 0
			end
		end
		
		-- PARSED EFFECTS
		local targets={}
		k,targets=parse_effect(k)		
		
		if #targets>0 then
			if k=="tempo" then v=-v end
			
			-- MUTE GRAPHIC EFFECT
			if k=="buckler" then return nil end
			
			-- TABLE DE PIECES
			local trgp,sv
			if type(v)=="table" then
				trgp = ""
				for n in all(v) do
					if #trgp>0 then trgp=trgp.."," end
					trgp=trgp..get_piece_name(n)
				end
				sv = trgp
			else
				trgp=get_piece_name(v)
				sv=v
			end
			
			--local reps={ 	get_group_name(targets),	v..""	}
			local reps={sv}
			
			reps["<pieces>"]=get_group_name(targets,true)
			reps["<piece>"]=get_group_name(targets,false)
			reps["<target_piece>"]=trgp
			reps["<target_pieces>"]=get_plural(trgp,999)
			reps["<leaders>"]=get_plural(leader,999)
			reps["<inc>"]=sig(v)
			reps["<head>"]=targets.bad and leader or lang.black_leader
			
			local key = console_alt("effect_"..k)
			if not lang[key] then key="effect_"..k end
			
			local s=get_lang(key,reps) or "unknown effect"
			s = rep(s,"$leader", get_leader_name())
			return s, effect_order[k] or 0
			
		end
	
		-- SQUARE COLOR
		if targets.square then
			if ca.reversed and ca.reversable then v=-v end
			local s,n=gd(k,v)
			if s then
				col=get_lang(targets.black and "black" or "white")
				--if current_lang == "french" then -- -_-
				--	col=dat[1]=="sqb" and "noires" or "blanches"
				--end
				return get_lang("standing",{col,s}),n
			end
		end
		--
		return nil
	end
	
	-- ensuring effects will always be described in the same order (order of definition in english.txt)
	local lst={}
	for k,v in pairs(ca) do
		local s,n=gd(k,v)
		if s then
			add(lst,{s,n})
		end
	end
	custom_sort(lst,function(d) return d[2] end)
	for d in all(lst) do
		add_line(d[1])
	end

	-- SPECIFIC
	if ca.special then
		add_line(get_lang(console_alt("special_"..ca.special), {SPECIAL_BUTTON, SHOOT_BUTTON}))
	end
	if flip_cond then	
		add_line(get_lang("flip_if",flip_cond) )
	end
	if ca.delayed then
		local s=get_desc(ca.delayed)
		--add_line(s.." "..delay)
		add_line(delay..":|"..s)
	end

	return desc
end
function sig(n) 
	if type(n)~="number" then return n end
	return 	n>0 and "+"..n or n 
end
function get_leader_type()
	local n=5
	if perm and stack and stack.ruler then n=stack.ruler end
	return n
end
function get_leader_name()
	local str = get_piece_name(get_leader_type())
	if current_lang == "german" then
		return str
	end
	return lowercase(str)
end
function get_piece_name(id,black)
	id=type(id)=="number" and id or PIECES_NAMES[id].index
	if id==8 then id=get_leader_type() end
	local str = get_lang("piece_"..id)
	if black then 
		str=get_lang("black_piece",str,1)
	end
	
	if current_lang == "german" then -- ?
		return str
	end
	return lowercase(str)
end
function get_inventory(a)
	local res={}
	for n in all(a) do		
		res[n]=res[n] and res[n]+1 or 1
	end
	return res
end
function get_delay(n)
	if not stack then return n end
	return flr(n*(100-(stack.delay_mult or 0))/100)
end
function get_group_name(a,plur)
	local s=""
	local plur = plur and 999 or 1
	for i=1,#a do
		local n=a[i]
		if #s>0 then s=s..(i==#a and " "..get_lang("and").." " or ", ") end
		s=s..get_plural(get_piece_name(n),plur)
	end	
	if not a.bad then s=get_lang("black_piece", s, plur)  end
	
	return s
end
function get_pieces_list(a,black)	
	local list={}
	for k,v in pairs(get_inventory(a)) do
		local s=get_lang("pieces",{v,get_piece_name(k,black)})
		add(list,s)
	end
	local s=""
	for i=1,#list do
		if #s>0 then s=s..(i==#list and lang._and_ or ", ") end
		s=s..list[i]
	end
	return s
end


function parse_effect(s)
	local targets={bad=true}
	local dat=split(s,"_")
	for k in all(dat) do
		if PIECES_NAMES[k] then 
			add(targets,k) 
			del(dat,k)
		end	
		if k=="choose" then
			targets.choose=true
			del(dat,k)
		end	
		if k=="black" then
			targets.bad=false
			del(dat,k)
		end
		if k=="global" then
			targets.bad=nil
			del(dat,k)
		end
		if k=="need" then
			targets.need=true
			del(dat,k)
		end
		
		if k=="sqb" or k=="sqw" then
			targets.square=1
			targets.white=k=="sqw"
			targets.black=k=="sqb"
			del(dat,k)
		end
	end
	return join(dat,"_"),targets
	
end
function is_valid_target(e,targets,chosen)
	if targets.choose~=chosen then return false end
	for trg_name in all(targets) do
		local name_ok=trg_name==e.name or trg_name=="all" or (trg_name=="leader" and (e.type==leader or (e.type==5 and leader==6)))
		if name_ok and (targets.bad==nil or e.bad==targets.bad)  then
			return true
		end
	end
	return false 
end

function pick(cons,with)



	cons=cons or {}
	local a={}
	for ca in all(cards.pool) do
	
		-- FORCED
		if cons.id==ca.id then return ca	end

		-- IS AVAILABLE ?
		local ok=is_card_available(ca,with) 
	
		-- CHECK CONSTRAINS
		for k,v in pairs(cons) do
			ok=ok and ca[k]==v 
		end	
		
		-- WEIGHT
		if ok then for i=1,ca.pwe+#ca.need_card*4 do add(a,ca) end	end
		
	end	
	

	if #a>0 then
		local ca=rnd(a)
		del(cards.pool,ca)
		return ca
	else
		return nil
	end

end
function is_card_available(ca,others)
	others=others or {}

	local function rk(k)
		return k==8 and (leader or 5) or k
	end


	local all_needs={}
	for ca in all(get_all_cards(true)) do
		local g={}
		for n in all(ca.need or {}) do
			local i=rk(n)		
			g[i]=g[i] and g[i]+1 or 1
		end
		for i,v in pairs(g) do
			all_needs[i]=max(all_needs[i] or 0,v)
		end
	end


	local function check(a,sac)
		if not a then return true end
		local inv=get_inventory(a)
		for k,v in pairs(inv) do
			local i=rk(k)
			local n=white_army[i] or 0
			if sac then n=n-(all_needs[i] or 0) end			
			if v>n then return false end
		end
		return true
	end

	-- EXCLUDE
	for id in all(ca.exclude or {}) do
		if perm[id] then 
			return false 
		end
		for oca in all(others) do
			if oca.id==id then return false end
		end
	end

	-- NEEDS + NO	
	for k,v in pairs(ca) do
		local kk=k
		local k,targets=parse_effect(k)
		if targets.need then			
			if k=="card" then 
				for id in all(v) do
					local a=type(id)=="table" and id or {id}
					local ok=false
					for id in all(a) do
						ok=ok or perm[id]
					end
					if not ok then return false end					
					--if not perm[id] then return false end					
				end
			elseif k=="tag" then
				local ok=#ca.need_tag==0
				for id in all(ca.need_tag) do
					for oid in all(stack.tags or {}) do
						if id==oid then ok=true break end
					end
					if ok then break end
				end
				if not ok then return false end
			elseif k=="soul" then 
				if v>#souls then return false end
			elseif type(v)=="number" then
				if v>(stack[k] or 0) then
					return false
				end
			end		
		end
		if targets.no then
			if stack[k] then return false end
		end
	end
	

	-- SPECIAL
	if ca.special and stack.special~="none" then
		if stack.special~=ca.special then
			return false
		end	
	end

	if ca.ammo_max and stack.ammo_max+ca.ammo_max<1 then
		return false
	end
	if ca.soul_slot and #souls+ca.soul_slot>5 then
		return false
	end
	
	if ca.wand and #scepters>=3 then
		return false
	end


	if ca.floor_min and ( not mode.lvl or mode.lvl<ca.floor_min ) then
		return false	
	end
	if ca.floor_max and ( not mode.lvl or mode.lvl>ca.floor_max ) then
		return false	
	end

	if ca.grab and stack.blade and stack.blade>0 then -- console only, prevent grab with a blade (include the Makeda)
		return false
	end
	if ca.blade and ca.blade>0 and stack.grab then -- prevent blade with a grab (exclude Plate Armor)
		return false
	end

	return check(ca.need) and check(ca.sac,true)
end

function decay_up(nxt)
	
	if not inter.piece_pool or #inter.piece_pool==0 then
		inter.piece_pool={1,2,3,4,0,-1}
	end

	-- UPGRADES
	local tp=steal(inter.piece_pool)	
	if tp==-1 then
		add(upgrades,{blood_bowl=1})		
	else
		add(upgrades,{gain=tp==0 and {0,0} or {tp}})
	end
	build_stack()
	
	
	local e=mke(0,MCW/2,MCH/2)

	
	local function leave()
		kl(e)
		nxt()
	end
	
	e.upd=function()
		if e.t==60 then 
			sfx("decay_jingle") 
			screen_shake(8,8)
			
		end
		if e.t>180 and mcl then
			e.upd=nil
			mv(e,0,MCH,30,leave)
			e.twcv=ease_in
		
		end
	end
	e.dr=function(e,cx,cy)
		if e.t<60 then
			local pmax=64
			srand(32)			
			for ci=0,2 do
				for i=1,pmax do
					local an=i/pmax
					local c=ease_in(e.t/60)
					local d=rnd(256)*(1-c)
					local x=cx+cos(an)*d
					local y=cy+sin(an)*d					
					local r=c*3+rnd(2)+(i+t)%2-ci*2
					if r>0 then circfill(x,y,r,2+ci) end	
				end				
			end
			circfill(cx,cy,ease_in(e.t/60)*8,4)
			srand()
		else
			if tp>=0 then
				for i=0,1 do
					local x=cx-8			
					if tp==0 then x=x+(i*2-1)*6 end
					sspr(tp*16,432,16,16,x,cy-9)
				end
			else
				sspr(176,80,16,16,cx-8,cy-8)
			end
			
		end
		
		if e.t>120 then
		
			local s="???"
			if tp>=0 then
				s=get_lang(tp==0 and "pawns_join" or "piece_join", get_piece_name(tp))
			elseif tp==-1 then
				s=lang.blood_bowl
			end
			
			local lim=(e.t-120)/3
			local maxw = 64			
			--local y = cy+6+16-pprint(s,0,-100,maxw)/2 WAS NOT WORKIGN ANYMORE, NO IDEA WHY
			pprint(s, cx, cy+16, maxw, 3, 1, lim)
		end
		
	end
	
	local function scroll()
		mv(e,0,-16,60,describe)
		e.twcv=ease_in_out
	end
	
	wait(60,scroll)
	
end
function white_king_up()
	if not prev_ents then
		local function black()
			prev_ents,ents=ents,{}
			white_king_up()
		end
		fade_to(-4,30,black)
		return
	end
	
	local bg=mke()
	bg.dr=function() cls(1)	end	
	
	
	local function last_level()
		new_level()
	
	end
	
	local function nxt()
		set_army(5,nil)
		set_army(6,1)
		
		ents,prev_ents=prev_ents
		fade_to(0,30,last_level)
	end
	
	init_vig(get_leader_type()==2 and {5} or {4},nxt)
	
	
end

-- BORDEL
function get_index_table(tbl)
	local a={}
	for n in all(tbl) do 
		a[n]=(a[n] or 0)+1	
	end	
	return a
end

-- CARDS
function new_card(cid,desc)


	local e=mke(0,px,py)
	e.turn_count=0
	e.dp=DP_INTER
	tbl_import(e,get_card(cid))
	e.desc=desc
	e.x=board_x+2
	e.y=board_y+27+e.team*32
	
	e.upd=function()
		
		if e.flipped and not e.flip_co then
			e.flip_co=0		
		end
		
		if e.flip_co then
			e.flip_co=mid(0,e.flip_co+.05*(e.flipped and 1 or -1),1)
			if e.flip_co==0 then e.flip_co=nil end
		end
	
	end
	
	e.dr=function(e,x,y)

		

		if e.c_show then
			local c=e.c_show/60
			y=y-abs(sin(c*2))*min(c,1)*8
		end

		if e.c_detect and t%4<2 then
			apal(1)	
		end

		if e.c_fade_in then
			local c=e.c_fade_in/16
			sfillp_dissolve(c)
		end

		
		-- DRAW FLIP / NORMAL
		if e.flip_co then
			dr_flip_card(x,y,e,e.flip_co,nil)
		else	
			spritesheet(e.spsheet or "cards")
			sspr((e.gid%10)*24,flr(e.gid/10)*32,24,32,x,y)
			spritesheet("gfx")
			-- ALT DR
			if e.reversed or (e.c_rev_fade and t%6<3) then
				exe(e.alt_dr,e,x,y)
			end
			-- TURN COUNT
			if e.delay and e.turn_count then
				local dl=get_delay(e.delay)
				local n=-e.turn_count
				local hh=2
				local c=min(e.turn_count/dl,1)
				local cl= e.c_turn_count and t%6<3 and 4 or 5
				rectfill(x+1,y+25,x+21,y+28,4)
				rectfill(x+2,y+26,x+20,y+27,3)
				if c>0 then
					rectfill(x+2,y+26,x+2+18*c,y+27,cl)	
				end
			end
			
			-- SELECTABLE
			if e.selectable and t%60<30 and MOUSE then	-- FLICKERING sabotage
				rect(x+1,y,x+21,y+28,5)
			end					
			
			--
			if e.marked then				
				sspr(91,48,5,6,x+16,y+1+cyc(2,32))			
			end
			

		end	
		sfillp_rst()
		
		if e.c_show and cyc(2,3)==0 then
			rect(x+1,y,x+21,y+28,4+cyc(2,6))
		end
		--[[ SHOW
		if e.c_show then
			rect(x+1,y,x+21,y+28,4+cyc(2,6))
			for cl=0,5 do	blend(5,cl,bright(cl,1+cyc(2,6))) end
			pal_rst()
			sspr(232,320,24,32,x,y-1)
			blend()			
		end	
		--]]
		
	end
	
	return e
	


end
function add_card(e,nxt)

	if type(e)=="string" then
		e=new_card(e)
	end

	local tsl=get_free_card_slot(e)
	

	if mode.fill_last_slot then 
		tsl=nil

		--DECAL IF ABLE
		for i=1,#card_slots-1 do
			local sla=card_slots[i]
			local slb=card_slots[i+1]
			if slb.ca and not sla.ca then
				sla.ca=slb.ca
				sla.ca.sl=sla
				slb.ca=nil
				mvt(sla.ca,sla.x,sla.y,30)
			end
		end
		
		local sl=card_slots[#card_slots]
		if not sl.ca then tsl=sl end
	
	end

	-- FREE FIRST SLOT IF FULL AND RETRY
	if not tsl then
		local a={}
		for sl in all(card_slots) do 
			if sl.team==e.team then add(a,sl) end 
		end
		local tempo=30
		local function f()
			for i=2,#a do
				local sl=a[i]
				local nsl=a[i-1]		
				local ca=sl.ca
				nsl.ca=ca
				nsl.ca.sl=nsl
				mvt(ca,nsl.x,nsl.y,tempo)
				sl.ca=nil				
			end
			wait(tempo,add_card,e,nxt)
		end
		tear_apart(a[1].ca,f)
		return
	end	
	
	-- FILL SLOT
	tsl.ca=e
	e.sl=tsl
	
	-- EXTRA AMMO / GRENADE
	if e.ammo_max then	ammo=ammo+e.ammo_max end
	if e.grenades_max then	grenades=grenades+e.grenades_max end
	
	-- REGISTER
	build_stack()
	
	
	local function land()
		_sfx("card_land",3)
		screen_shake(4,4)
		exe(nxt)
	end
	
	local function go()	
		mvt(e,tsl.x,tsl.y,30,land)
		e.twcv=ease_in_back
	end
	wait(e.team*12,go)
	
	-- STEAM ACHIEVEMENT CHECK
	ach_event("on_card")


end
function get_free_card_slot(e)
	for i=1,#card_slots do
		local csl=card_slots[i]
		if not csl.ca and csl.team==e.team then
			return csl
		end
	end
	return nil

end
function dr_flip_card(cx,cy,ca,ct,shade,spsheet)	
	-- DW
	local cpy=cy
	
	cpy=cpy-sin(ct/2)*8				
	local dw=cos(ct/2)*24				
	
	-- SHADOW
	if shade then
		rectshade(cx+13-dw/2,cy+1,22,29,-1)
	else
		apal(1)
		sspr(48,72,24,32,cx+13-dw/2,cy+1,dw,32)
		pal_rst()
	end
	
	-- FRONT
	if dw>0 then
		spritesheet(ca.spsheet or "cards")
		sspr((ca.gid%10)*24,flr(ca.gid/10)*32,24,32,cx+12-dw/2,cpy,dw,32)
		spritesheet("gfx")
	else
		sspr(48+ca.team*24,72,24,32,cx+12+dw/2,cpy,-dw,32)
	end


end
function show_card(id,nxt,t,index,mute )
	t=t or 60
	nxt=nxt or function() end
	
	local ca=id
	if type(id)=="string" then
		ca=get_card_with(id,index)
	end	
	if not ca then
		wait(2,nxt)
		return
	end
	if not ca.c_show and not mute then sfx("show_card") end
	ca.c_show=t
	wait(t,nxt)
	
end
function get_card_with(id,index,flip_ok)
	index=index or 1
	local a={}
	for ca in all(get_all_cards(flip_ok)) do
		if ca.id==id then add(a,ca) end
		for k,v in pairs(ca) do
			if k==id then add(a,ca) end
		end			
	end	
	index=min(index or 1,#a)
	return a[index],a
end
function init_cards_hint(cards_only)
	-- CARDS
	for sl in all(card_slots) do if sl.ca then
		local ca=sl.ca
		local desc=get_desc(ca)
		desc=get_lang(ca.id).."|"..desc
		local c=mk_hint_but(sl.x,sl.y,24,32,desc,{4,3})
		c.iscard=true
		c.dr = function(e, x, y)
			if not MOUSE and hint_but==c then
				rect(x, y - 1, x + 22, y + 29, 5)
			end -- FLICKERING
		end
		
		if DEV then
			c.right_clic=function()
				if btn"shift" then
					tear_apart(sl.ca)
				end
			end
		end
	end end
	
	if cards_only then return end

	-- SCEPTERS	
	for e in all(scepters) do
		desc=""
		for o in all(CARDS) do
			if o.wand and o.wand[1]==e.id then 
				local w2=o.wand[2]
				if w2=="firepower" then 
					w2=lang.firepower 
				end
			
				desc=	get_lang(o.id).."|"..get_lang("wand_"..o.wand[1],{w2, ["$leader"]=get_leader_name()})
				if e.cd==0 then
					desc=desc..(MOUSE and "" or ("|"..get_lang("press_to_use", CONFIRM_BUTTON)))
				else
					desc=desc.."|"..lang.replenish_floor
				end
			end
		end


		local s=mk_hint_but(e.x,e.y,16,16,desc,{4,3})
		s.isscepter=true
	end
	
	-- SOULS
	for sl in all(souls) do
		local desc
		if sl.id then
			local piece_name = get_piece_name(sl.id)
			desc=get_lang(console_alt(sl.id>=1 and "soul_desc" or "pawn_soul_desc"),{piece_name,CONFIRM_BUTTON})
			desc=first_upper(desc)	
			if stack.crown then desc=desc.." "..lang.crow_turn end
			if stack.summoner and #get_allies()==0 and sl.id~=12 then 
				desc=desc..get_lang("soul_proj", piece_name)
			end
			if PIECES[sl.id+1].ward then
				desc=desc.."|"..lang.warden_soul
			end
			
		else
			desc=lang.soul_slot
		end
		local s=mk_hint_but(sl.x,sl.y,24,32,desc,{4,3},68,true)
		s.issoul=true
		s.dr = function(e, x, y)
			local off = 1
			if sl.id then off = 2 end
			if not MOUSE and hint_but==s then rect(x, y - off, x + 22, y + 30 - off, 5) end -- FLICKERING
		end
	end
	
	if mode.no_shotgun then return end
	
	-- SHIELDS
	local desc=lang.folly_shield
	mk_hint_but(board.x+stack.ammo_max*4+1,board.y-10,SET.shields*6,8,desc,{4,3},nil,true)
	
	-- DISP STATS
	local a,cy,ec=get_disp_stats()
	for o in all(a) do
	
		local s=o.value
		s=tonum(s) or s
		if type(s)=="string" then s=rep(s,"%","") end		
		local desc=get_lang("stat_"..o.id,s) or "test"
		mk_hint_but(board.x-27,cy,20,11,desc,{3},nil,true)
		cy=cy+ec
	end
	

end
function plur(n)
	return n>1 and "s" or ""
end
function get_slot_card_with(key)
	for sl in all(card_slots) do
		if sl.ca and sl.ca[key] and not sl.ca.flipped then
			return sl.ca
		end
	end
	return nil
end
function exhaust_card_with(id)
	local ca=get_slot_card_with(id)
	if ca then flip_card(ca) end
	
end
function has(key)
	return stack[key]
end

function flip_card(ca,nxt)
	ca.flipped=true	
	if ca.ammo_max then
		ammo=ammo-ca.ammo_max
	end	
	build_stack()	
	
	-- ROLLBACK -> NXT
	local events={}
	local function rollback()
		if #events==0 then
			exe(nxt)
			return
		end
		local f=events[1]
		del(events,f)
		f()	
	end	
	if ca.gain and (not ca.delay or get_delay(ca.delay)<=ca.turn_count) then
		add(events,bind(retire,ca.gain,rollback))
	end	
	for k,v in pairs(ca) do
		local k,targets=parse_effect(k)
		if targets.choose then
			add(events,bind(demote,k,targets,v,rollback))
			--local pnxt = nxt
			--nxt=bind(demote,k,targets,v,pnxt)
		end
	end	
		
	rollback()
	
	--exe(nxt)
end
function unflip_card(ca)
	ca.flipped=false
	build_stack()
end
function check_cards_auto_flip()
	for sl in all(card_slots) do if sl.ca and sl.ca.flip_on then
		local flip=check_condition(sl.ca.flip_on)
		if sl.ca.flipped and not flip and not sl.ca.disrupted then -- 
			unflip_card(sl.ca)
		end
		if not sl.ca.flipped and flip then
			flip_card(sl.ca)
		end			
	end end
end
function check_condition(id)
	
	if not hero or not hero.sq then return false end
	local hsq=hero.sq

	if id=="contact" then
		for di=0,7 do 
			local nsq=dsq(hsq,di,1)
			if nsq and nsq.p and not nsq.p.airy and not nsq.p.inert and nsq.p.bad then return true end
		end
		return false
	end
	
	if id=="inner" then
		return hsq.px>0 and hsq.px<7 and hsq.py>0 and hsq.py<7		
	end

	if id=="not_cloaked" then
		return not hero.cloaked
	end
	
	
	-- NO
	if sub(id,1,3)=="no_" then
		for b in all(bads) do 
			if b.name==sub(id,4) then return false end
		end
		return true
	end
	
	-- NO
	if sub(id,1,5)=="only_" then
		if inter.storming then return false end
		for b in all(bads) do 
			if b.name~=sub(id,6) then return false end
		end
		return true
	end
	
	return false

end

--
function set_army(tp,n)
	white_army[tp]=n
end
function inc_army(tp,n)	
	white_army[tp]=white_army[tp] and white_army[tp]+n or n
end
function inc_black_army(tp,n)
	black_army[tp]=black_army[tp] and black_army[tp]+n or n
end

-- STACK
function build_stack(n)


	white_army={}
	black_army={}
	
	-- PERM
	perm={}
	for sl in all(card_slots) do
		if sl.ca then perm[sl.ca.id]=true end
	end
	
	-- DEFAULTS
	stack={
		ammo_regen=1,
		ammo_max=0,
		chamber_max=0,
		firepower=0,
		firerange=0,
		spread=0,
		
		knockback=0,
		pierce=0,
		special="none",
		grenades_max=0,
		grenade_dmg=3,
		blood_bowl=0,
		
		soul_slot=1
		
	}
	local wands={}

	-- GLOBAL
	for ca in all(get_all_cards()) do
		
		-- SIGN
		local sn=ca.reversed and ca.reversable and -1 or 1

		-- ARMY
		if ca.sac then
			for n in all(ca.sac) do 
				inc_army(n,-1)
			end
		end
		if ca.gain then
			for n in all(ca.gain) do 	
				if not ca.delay and not ca.period and ( not ca.final or mode.lvl==(mode.lvl_max or 11) )  then 
					inc_army(n,1)
				end
			end
		end
		
		-- ALLIES
		if ca.allies then
			for n in all(ca.allies) do 	
				if not ca.delay and not ca.period then 
					inc_black_army(n,1)
				end
			end
		end
		
		
		-- STACK
		for k,v in pairs(ca) do
			
			-- GLOBALS
			if _G[k] then
				if type(_G[k])=="number" then 
					_G[k]=_G[k]+v*sn
				elseif type(_G[k])=="string" then 
					_G[k]=v
				end
			end		
			
			-- NUMBER / OBJECT
			if type(v)=="number" then
				stack[k]=stack[k] and stack[k]+v*sn or v*sn
			elseif type(v)=="table" then
				stack[k]=stack[k] or {}
				for p in all(v) do add(stack[k],p) end
				
			else
				stack[k]=v
			end
			
			-- REVERSE
			if ca.reversed then 
				stack["rev_"..k]=v
			end
			
		end
		
		-- SCEPTERS
		if ca.wand then wands[ca.wand[1]]=ca.wand end
		
	end
	
	-- LEADER
	leader=get_leader_type()
	if boss then leader=boss.type end
	

	--

	
	-- PIECES SETUP
	local a=clone(bads or {})
	add(a,hero)
	for b in all(a) do
		setup_piece(b)
		if FRAGILE then b.hp=1 end
	end
	
	-- REMOVE/ADD SCEPTERS
	for e in all(scepters) do
		if wands[e.id] then
			wands[e.id]=nil
		else
			kl(e)
			del(scepters,e)
			recal_scepters()
		end	
	end
	for k,v in pairs(wands) do
		add_scepter(v)
	end
	
	-- SOULS
	while #souls<stack.soul_slot do
		add_soul_slot()
	end
	while #souls>stack.soul_slot do
		remove_soul_slot()
	end

	-- SQUARE EFFECTS
	local esq={w={},b={}}
	local colors="bw"
	for k,v in pairs(stack) do
		local a=split(k,"_")
		for i=1,2 do
			local let=sub(colors,i,i)
			if a[1]=="sq"..let then 
				local k=a[2]
				local n=esq[let][k]
				esq[let][k]=n and n+v or v 
			end
		end
	end		
	
	for sq in all(squares or {}) do	
		sq.moat= (sq.py==stack.moat) and ( not stack.bridge or abs(sq.px-3.5)>1 )
		sq.penta=nil
		sq.waypoint=nil
		sq.flagstone=nil
		sq.stack={}
		local tbl=sq.cl==0 and esq.w or esq.b		
		for k,v in pairs(tbl) do sq.stack[k]=v end			
	end
	if pentasquares then 	for i=1,(stack.pentagrams or 0) do
		pentasquares[i].penta=true
	end end
	if waypoint and stack.waypoint then
		waypoint.waypoint=true
	end
	if flagstones then for i=1,(stack.flagstones or 0) do
		flagstones[i].flagstone=true
	end end
	--log(stack.trench)
	if trench then for i=1,(stack.hole_start or 0) do --
		local sq=trench[i]
		if sq then sq.hole=1 end
	end end	


end
function get_all_cards(flip_ok)
	local a={}
	for ca in all(upgrades) do	add(a,ca) end
	for ca in all(temporary) do	add(a,ca)	end
	
	if TEST_STACK then add(a,TEST_STACK) end
	

	
	-- CARDS
	for ca in all(get_slot_cards(flip_ok)) do
		add(a,ca)		
	end
	return a
end
function get_slot_cards(flip_ok)
	local a={}
	for sl in all(card_slots) do
		if sl.ca and (not sl.ca.flipped or flip_ok ) then 			
			add(a,sl.ca)
		end
	end
	return a
end
function is_square_clean(sq)
	return not (sq.penta or sq.hole or sq.waypoint or sq.flagstone)
end

-- CROSSHAIR
function dr_crosshair(e)
	local hide_crosshair = not hero or (not aiming and not aim and not btn"force_aim") or (chamber==0 and not hero.lift)
	if not MOUSE then
		hide_crosshair = ctrl_mode ~= "aim" and not (ctrl_mode == "move" and special=="strafe" and aim ~= nil)
	end
	if not hero or hide_crosshair or pause or not playing then return end --
	
	local bx=hero.x+8+cos(hero.an)*8
	local by=hero.y+8+sin(hero.an)*8
	
	local fra=get_firerange()

	--	clip(board_x,board_y,8*SQ,8*SQ) --not on console
	
	local cx,cy		
	local pmax=12
	local d
	if MOUSE then
		d=sqrt((hero.x+8-mx)^2+(hero.y+8-my)^2)-8
		
		if aim then
			local ax,ay=get_center(aim)
			d=sqrt((hero.x-ax)^2+(hero.y-ay)^2)--8
		end
	else
		d=fra*16
	end
	
	if hero.lift then
		spr(13, mx-8,my-8)
		clip()
		return
	end
	
	local cl=5
	if MOUSE then
		if d>fra*16 then
			local rate=(d-fra*16)/32
			cl=rnd(1)>rate and 5 or 2
		end
		if d>fra*16+32 then
			cl=2
		end
	end
	if chamber==0 and not hero.lift then -- console only
		cl=2
	end
	
	-- dot spread
	if not MOUSE then
		for i=0,1 do
			local dd=0
			repeat
				local an=hero.an+(get_spread()/720)*(i*2-1)	
				local nx=bx+cos(an)*dd
				local ny=by+sin(an)*dd
				if dd > 5 then
					if cl==2 then
						pset(nx,ny,cl)
					else
						pset(nx,ny,(pget(nx,ny) <= 3) and 6 or 7)
					end
				end
				dd = dd + 8
			until dd > d
		end
	end
	
	-- ARC
	for arcRng=0, MOUSE and 0 or 1 do
		local dArc=d+arcRng*16*2
		for i=0,pmax do
			local an=hero.an+(get_spread()/720)*((i/pmax)*2-1)			
			local nx=bx+cos(an)*dArc
			local ny=by+sin(an)*dArc
			if arcRng == 1 then
				if cl==2 then
					pset(nx,ny,cl)
				else
					pset(nx,ny,(pget(nx,ny) <= 3) and 6 or 7)
				end
			elseif cx then			
				--brd(bind(line,cx,cy,nx,ny,5),t%6<3 and 4 or 3 )
				line(cx,cy,nx,ny,cl)
				--brd(bind(line,cx,cy,nx,ny,5),5 )
			end
			cx,cy=nx,ny
		end
		cx=nil
	end

	-- ARC BORDER
	local dArc=d
	local dd=4
	for i=0,1 do
		local an=hero.an+(get_spread()/720)*(i*2-1)
		line( bx+cos(an)*(dArc+dd), by+sin(an)*(dArc+dd), bx+cos(an)*(dArc-dd), by+sin(an)*(dArc-dd), cl)
	end

	
	-- ARROW
	d=d+4
	local k=2
	local ax=bx+cos(hero.an)*d+cos(hero.an+.25)*k
	local ay=by+sin(hero.an)*d+sin(hero.an+.25)*k
	local cx=bx+cos(hero.an)*d+cos(hero.an-.25)*k
	local cy=by+sin(hero.an)*d+sin(hero.an-.25)*k
	local dx=bx+cos(hero.an)*(d+2*k)
	local dy=by+sin(hero.an)*(d+2*k)
	trifill(ax,ay,cx,cy,dx,dy,cl)

	-- SCOPE
	if hero.scope and cl==5 then
	
		local x,y=bx,by
		local ok=t%3<6
		local td=0
		while td<256 do
			local d=rnd(16)
			local nx=x+cos(hero.an)*d
			local ny=y+sin(hero.an)*d
			if ok then
				line(x,y,nx,ny,5)
			end
			ok= not ok
			td=td+d
			x,y=nx,ny
		end
	
	
	
	end

	-- RECOIL
	local rsq,di=get_recoil_square()
	if rsq and di then
		spr(32+di,rsq.x,rsq.y)		
	end


	clip()
		
end
function get_recoil_square()
	if not has("recoil") or hero.lift then return nil end
	local k=round((hero.an+.5)*8)%8
	local di=ADI[k+1]
	local sq=dsq(hero.sq,di,1)
	if is_free(sq) then
		return sq,di
	end	
	return nil
end


-- HINTS
function show_hint(str,colors,pw,center,params)
	params=params or {}
	colors=colors or {4}	
	pw=pw or 98
	hide_hint()
	local ma=4
	
	str = sbs(str, "|", "\n")
	str = sbs(str, "%$", lang.degree_symbol)
	
	local txtw = pw-3*ma
	local ph=-100
	local i,n,l=1,0,0
	repeat
		l=n+1
		n = find(str, "\n", l)
		ph = pprint(sub(str, l, n and (n-1)), 0, ph, txtw, 0, 0)
		i=i+1
	until not n
	ph = ma*2 + (ph - 1 + 100)
	
	hint_box=mke()
	hint_box.dp=DP_INTER
	
	local fr=force_right
	hint_box.upd=function(e)
		local ma=2
		local tx=mx+5
		local ty=my+5
		
		local s=1
		local mdx=mx-MCW/2
		if abs(mdx)<96 then s=-1 end	
		
		if sgn(mdx)==s then
			tx=mx-5-pw
		end
		if center then
			tx=mx-pw/2
		end
		
		if params.x then
			tx=params.x
		end		
		if params.y then
			ty=params.y
		end		
		if params.center_y then
			ty=ty-ph/2
		end		
		
		if params.free then
			e.x = tx
			e.y = ty
		else
			e.x=mid(ma,tx,MCW-ma-pw)
			e.y=mid(ma,ty,MCH-ma-ph)
		end


		
	end
	hint_box.dr=function(e,x,y)
		
		local sz,z=3,0
		if params.float then
			z=2.25-cos(t/120)*2
			sz=2+z
		end
		rectshade(x+sz,y+sz,pw,ph)
		y=y-z
	
		rectfill(x,y,x+pw-1,y+ph-1,2)
		hdclear(x,y,x+pw-1,y+ph-1,2)
		rect(x,y,x+pw-1,y+ph-1,3)
		local cx,cy=flr(x+ma),flr(y+ma)
		local i,n,l=1,0,0
		
		
		repeat
			l=n+1
		  n = find(str, "\n", l)
			cy = pprint(sub(str, l, n and (n-1)), cx, cy, txtw, colors[min(i,#colors)] or 4, 0)
			--lprint(sub(str, l, n and (n-1)), cx, cy, colors[min(i,#colors)])
			--cy = cy+7
			i=i+1
		until not n

		--pprint(str, cx, cy, txtw, colors[1] or 4)
	end
end
function hide_hint()
	if not hint_box then return end
	kl(hint_box)
	hint_box=nil
end

-- GRID
function gsq(x,y,di,n)
	n=n or 1
	if di then
		x=x+DIRS[di*2+1]*n
		y=y+DIRS[di*2+2]*n
	end
	if x>=0 and x<xmax and y>=0 and y<ymax then
		return squares[1+x*ymax+y]
	else
		return nil
	end
end
function dsq(sq,di,n)
	if not sq then return nil end
	return gsq(sq.px,sq.py,di,n)
end
function sqp(sq)
	return board.x+sq.px*SQ, board.y+sq.py*SQ
end
function is_free(sq) 
	return sq and not sq.p and not sq.reserved

end
function is_free_for(sq,e)
	if type(e)=="number" then
		e=PIECES[e+1]
	end

	if not e.big then
		return is_free(sq)	
	end
	local z=gsq_zone(sq)
	for sq in all(z) do
		if not is_free(sq) then return false end
	end
	return #z==4
end

-- SOULS
function add_soul_slot()

	local sl=mke(0,board_x+8*SQ+7,MCH)
	sl.dp=DP_BOARD
	add(souls,sl)


	sl.dr=function(e,x,y)

		if sl==souls[1] then
			lprint(lang.souls,x+12,y-8,2,1)
		end

		if sl.ov then y=y-1 end
		sspr(24,72,24,32,x,y)		


		if sl.id or sl.c_move_out then
			local id=sl.id or sl.oid
			local dx=0
			local c=0			
			if sl.c_move_in then c=sl.c_move_in/30 end
			if sl.c_move_out then c=1-sl.c_move_out/30 end
			if c>0 then
				sfillp_dissolve(c)
			end			
			local dy=-c*c*8
			sspr(0,72,24,32,x,y+dy)	
			pal(1,4)
			pal(4,2)
			pal(3,1)		
			local dc=1-(sl.c_draw and sl.c_draw/30 or 0)
			
			local custom=PIECES[id+1].custom_dr
			if custom then
				if dc<1 then
					clip(x+4,y+dy+6,16,dc*16)
				end
				custom({},x+4,y+dy+6)
				spritesheet("gfx")
				clip()
			else
				sspr(id*16,432,16,dc*16,x+4,y+dy+6)
			end
			
			sfillp_rst()
			pal_rst()
		elseif stack.absolution then
			local str=lang.power
			if current_lang == "english" and not force_HD then
				str="POW"
			end
			pprint(str.."\n"..sig(stack.absolution),sl.x+12,sl.y+12,20,2,1)
			sspr(112,48,16,4,sl.x+4,sl.y+7)
			--circfill(sl.x+11.5,sl.y+14,4,3)
			--circfill(sl.x+11.5,sl.y+14,2,4)
		end

		if sl.ov then y=y+1 end
		if sl==souls[#souls] then
			if ingame and not (leveling or info) and is_basic_mode() then
				local x=x+6
				for p in all_pieces() do
					if not p.bad and p.ready and not p.smoke_king then
						x=x+cyc(2,6)
						break
					end
				end
				draw_button("rightPage",x,y+30)
			end
		end		
	end
	
	
	
	for i=0,#souls-1 do
		local sl=souls[i+1]
		mvt(sl,sl.x,board.y+ymax*8+i*32-#souls*16,30)
		sl.twcv=ease_in_out
	end	
	
	
end
function remove_soul_slot()
	local sl=souls[1]
	kl(sl)
	del(souls,sl)
	for i=0,#souls-1 do
		local sl=souls[i+1]
		mvt(sl,sl.x,board.y+ymax*8+i*32-#souls*16,30)
		sl.twcv=ease_in_out
	end		
end
function get_empty_soul_slot()
	for sl in all(souls) do
		if not sl.id then return sl end
	end
	return nil
end
function add_soul(id,from,sanct,force)

	if id==11 then id=1 end

	local sl=get_empty_soul_slot()
	if not sl then 
		if force then			
			sl=souls[1]
			if not sl then return end
			if not sanct then
				sl.c_move_out=30
				sl.oid,sl.id=sl.id
				wait(30,add_soul,id,from,sanct)
				return
			end
		else
			return
		end
	end

	if from then 
	
		local function pop(i)
			local p=mke(0,from.x+8+hrnd(3),from.y+8+hrnd(3))
			p.dp=DP_FX
			local r=1+irnd(2)
			p.dr=function(e,x,y)
				fillp(0x7D7D,true)
				local cl=1
				if p.life then cl=max(4-p.life/10,1) end
				circfill(x,y,r,cl)
				fillp()
			end
			if sanct then
				p.x=p.x+hrnd(4)
				p.y=p.y+hrnd(4)
				p.we=-rnd(1)/10
				p.life=10+rnd(20)
				return
			end

			sl.c_draw=30

			local c=i/30
			local tx=sl.x+4+rnd(16)
			local ty=sl.y+6+c*16
			local function f()
				kl(p)
			end
			mvt(p,tx,ty,30,f)		
			p.jmp=sin(i/60)*24
			p.twcv=ease_in
		end
		for i=0,30 do
			wait(i,pop,i)
		end
		
		if not sanct then sfx("soul") end
		
	end
	
	if sanct then return end

	sl.id,sl.oid=id
	sl.c_move_in=30
	
end
function activate_soul(sl)
	if ctrl_mode ~= "select_soul" and not MOUSE then return end -- console only
	
	local can_summon=stack.summoner and #get_allies()==0
	local a=get_range(hero,{move=1,type=sl.id,soul=1})
	
	if sl.id>0 and #a==0 and not can_summon then
		fx_wrong()
		return
	end

	exhaust_soul(sl)
	
	local selecting=true
	remove_buts()
	
	-- CANNON FODDER
	if sl.oid==0 then
	
		local function f()
			sfx("boost")
			local e=mke()
			e.life=20
			e.dp=DP_FX
			e.dr=function()
				local x=hero.x+8
				local y=hero.y+8
				local c=ease_out(1-e.life/20)
				circ(x,y,4+c*12,5)
			end		
			hero.c_burning=10
			boost("firepower",2)
		end

		local e=mke(0,sl.x+8,sl.y+16)
		e.dp=DP_FX
		e.upd=function(e)
			local sh=mke(0,e.x,e.y)
			sh.dr=function(sh,x,y)
				sfillp(5,pat[4+sh.life*2],5*256)
				e.dr(sh,x,y)
				sfillp(5,0,5)
			end
			sh.life=5
			
		end
		e.dr=function(e,x,y)
			sspr(217,112,7,16,x-3,y-8)
		end
		e.life=30
		mvt(e,hero.x+8,hero.y+8,e.life-1,f)
		e.twcv=ease_in
		
		wait(60,play)
		return
	end
	

	timerun=true	
	hero.soul=sl.oid
	hero.c_soul=30
	local function cancel_soul()
		hero.c_soul=30
		wait(hero.c_soul,function() hero.soul=nil end)	
	end
	for sq in all(a) do
		sq.selectable,sq.show=true
		local f=function()
			if not has("crown") then
				if stack.holocloak then
					for b in all(sq.danger) do
						if b.uncover and check_folly_shields(sq) then return end
					end
				elseif check_folly_shields(sq) then
					return
				end
			end
			
			remove_buts()
			local function land()
				sfx("unsoul")
				cancel_soul()
				if stack.crown then earn_extra_turn() end
				wait(30,opp_turn)				
			end
			local osq=hero.sq
			move_hero(sq,land)
			if stack.holoking then set_holoking(osq) end
			reset_mode()
		end
		mk_sq_but(sq,f,9)
	end
	
	-- SUMMONER
	if can_summon then
		local z=get_zone(hero.sq,2)
		for sq in all(a) do del(z,sq) end
		for sq in all(z) do if is_free(sq) then
		
			local function f()
				remove_buts()			
				sfx("soul_proj")				
				cancel_soul()
				
				local p=new_piece(sl.oid,false,sq)
				p.cd=0
				p.x=hero.x
				p.y=hero.y
				local tx,ty=sqp(sq)
				mvt(p,tx,ty,30,play)
				p.twcv=ease_in_out
			end
		
			sq.selectable,sq.show=true
			sq.imprint=function(x,y,cl)
				pal(5,cl)
				sspr(16,112,16,16,x,y)
				pal()
			end
			mk_sq_but(sq,f,82)				
		end end		
	
	end
	

	-- RIGHT CLICK CANCEL
	local function clean()
		cancel_soul()
		for sq in all(a) do	sq.selectable=nil end			
		add_soul(sl.oid)
	end
	scan_cancel(clean)

	
end
function get_soul_range(id)

	local a=get_range(hero,{move=1,type=id})
	local good={}
	local bad={}	
	for sq in all(a) do
		add(#sq.danger>0 and bad or good,sq)
	end	
	return good,bad
end
function exhaust_soul(sl)
	sl.c_move_out=30
	sl.oid,sl.id=sl.id	
	sfx("use_card")
end

-- SCEPTERS
function add_scepter(wdat)

	local e=mke(0,board.x+SQ*8-#scepters*16-16,-16)
	e.wdat=wdat
	e.id=wdat[1]
	e.dp=DP_BG
	e.cd=0
	e.upd=function()
		if e.c_shake and rnd(90) < e.c_shake then
			fx_magic_star(e.x+13+hrnd(6),e.y+4+hrnd(6))
		end
	end
	
	e.dr=function(e,x,y)
	
		if e.over and e.cd==0 then y=y-1 end
	
		if e.c_shake then			
			local c=e.c_shake/60
			local r=sin(ease_in(c)/2)*4
			y=y+cos(c*3)*r
		end
	
		local fr=72+e.id
	
		if e.over then
			fbrd(bind(sspr,e.id*16,368,16,16,x,y),e.cd>0 and 3 or 5)
		end
	
		--spr(fr,x,y,1,1,false,e.c_flip)
		sspr(e.id*16,368,16,16,x,y)
		
	
		if e.cd>0 and not e.c_shake then
			clip(x,y,16,2+e.cd*2,true)
			apal(2)
			--spr(fr,x,y)
			sspr(e.id*16,368,16,16,x,y)
			pal_rst() 
			clip()
		end

		if e==scepters[#scepters] then
			if e.over and e.cd==0 then y=y+1 end
			if ingame and not (menu or leveling or info) and is_basic_mode() then draw_button("leftPage", x - 12, y + 8) end
		end
	end
	add(scepters,e)
	recal_scepters()

end
function recal_scepters()
	for i=1,#scepters do
		local e=scepters[i]
		mvt(e,board.x+SQ*8-i*16,board.y-18,30)
		e.twcv=ease_in_out
	end
end
function activate_scepter(e)

	timerun=true
	
	local function cancel(s)	-- TODO DISPLAY TEXT
		if s then msg(s,60,true) end
		fx_wrong()
		wait(10,play)
	end	
	local function finish()
		e.cd=6
		play()
	end
	local function get_val(i)
		
		local n=e.wdat[i]
		if type(n)=="number" then
			return n
		else
			return _G["get_"..n]()
		end
	
	end
	
	-- DOWNPOUR
	if e.id==0 then
		local targets={}
		for e in all_bads() do
			add(targets,{e=e,hp=e.hp})
		end
		if #targets==0 then
			cancel()
			return
		end
		timerun=false
		local count=get_val(2)
		local function rain()
			if count==0 or #targets==0 then
				wait(30,finish)
				return
			end
			sfx("missile")
			count=count-1
			local o=rnd(targets)
			o.hp=o.hp-1
			if o.hp==0 then del(targets,o) end
			local trg=o.e
			
			local p=mke(0,e.x+16,e.y)
			p.dp=DP_FX
			local ox,oy=p.x,p.y
			p.dr=function(e,x,y)
			
				local e=mke()
				e.life=8
				e.dp=DP_FX
				local ex,ey=ox,oy
				e.dr=function()
					line(x,y,ex,ey,t%6<3 and 4 or 5 )
				end
				ox,oy=x,y
				circfill(x,y,rnd(4),4+rnd(2))
			end
			local function impact()				
				hit(trg,1,{magic=1})
				kl(p)				
			end
			
			local a=atan2(trg.x-e.x,trg.y-e.y)	
			
			mvt(p,trg.x+8,trg.y+8,30,impact)
			p.jmp=16
			--p.twcv=ease_out
			
			
				
			mv(e,-cos(a)*8,-sin(a)*8,16)
			--mv(e,0,-8,12)
			e.twcv=ease_uturn
			--e.c_flip=16
			
			wait(20,rain)
			
			
		end
		wait(30,rain)
	end
	
	-- FRENZY
	if e.id==1 then
		timerun=false
		if chamber==stack.chamber_max and ammo==stack.ammo_max then
			cancel(lang.already_loaded)
			return
		end
		local function refill()
			if ammo<stack.ammo_max then
				inc_ammo()
				wait(20,refill)
			elseif chamber<stack.chamber_max then
				reload()
				wait(20,refill)
			else
				finish()
			end
		
		end
		wait(30,refill)
	end
	
	-- WRATH
	if e.id==2 then
		
		local n=get_val(2)
		--local n=""
		local function fireball(trg)
						
			if n<=0 or trg.hp<=0 then
				finish()
				return
			end

			local e=mke(0,trg.x+8+hrnd(8),trg.y-32)
			e.dp=DP_FX
			e.dr=function(e,x,y)
				circfill(x,y,rnd(4),4+rnd(2))
			end
			local function f()
				local p=mke(0,e.x,e.y)
				p.life=12
				p.dp=DP_FX
				p.dr=function(p,x,y)
					spritesheet("mini_xpl")
					sspr(p.t*16,0,16,16,x-8,y-8-2)
					spritesheet("gfx")
				end
				
				kl(e)
				hit(trg,1,{magic=1})
				n=n-1
				fireball(trg)
			end

			mvt(e,trg.x+8,trg.y+8,24,f)
			e.twcv=ease_in
			
			
		end
		local function chk(b) return b.type~=leader end
		ask_piece(chk,fireball,bind(cancel,lang.no_valid_target))
		--push_mode("wrath")

	end
	
	-- WINGS
	if e.id==3 then
		local dum={
			sq=hero.sq,
			hop=hero.hop,
			type=4,
			flying=true,
			cage=get_val(2)
		}
		local a=get_range(dum)
		if #a==0 then
			cancel(lang.cant_move)
			return
		end	
	
		local function clean()
			set_instructions()
			for sq in all(squares) do	
				sq.selectable=false	
			end
			reset_mode()
		end		

		set_instructions(lang.choose_destination)
		for sq in all(a) do
			sq.selectable,sq.show=true
			local f=function()
				remove_buts()
				clean()
				move_hero(sq,finish)
			end
			mk_sq_but(sq,f,9)
		end
		push_mode("move_wings")
		
		-- RIGHT CLICK CANCEL
		scan_cancel(clean)		
		
		
		
	end
	
	-- GUST
	if e.id==4 then
		timerun=false
		local a=clone(bads)
		ysort(a)
		sfx("gust")		
		local function gust(y)
			if y==8 then
				finish()
				return
			end			
			for x=0,7 do
				local sq=gsq(x,y)
				local b=sq.p
				if b and b.bad and b.sq==sq then					
					b.cd=b.cd-2
					b.ready=false
					local nsq=dsq(sq,3,1)
					local function backspace()
						if b.big then
							local a={3,7}
							for i=1,2 do
								local nsq=dsq(b.sq,a[i],1)
								if not nsq or nsq.p then return false end
							end
							return true
						else							
							return nsq and not nsq.p
						end
					end
					if backspace() then
						goto_sq(b,nsq)
					end					
				end
				-- DUST
				local e=mke(0,sq.x+rnd(16),sq.y+rnd(16))
				e.t=irnd(2)
				e.vy=-rnd(6)
				e.frict=.95
				e.life=24+irnd(8)
				e.dr=function(e,x,y)
					--pset(x,y,4+cyc(2,3,e.t))	--3+cyc(2,3,e.t) --bright(pget(x,y),-1)
					line(x,y,x,y+e.vy,4)
				end
				e.drs=function()
					local x,y=e.x+2,e.y+2
					line(x,y,x,y+e.vy,3)
				end
				
			end			
			wait(8,gust,y+1)
		end
		gust(0)	
	end
	
	-- CONTROL
	if e.id==5 then

		local trg=nil
		local function clean()
			set_instructions()
			for sq in all(squares) do
				sq.show=false
				sq.selectable=false
			end
			if trg then trg.hypno=false end
			reset_mode()
		end
		local function move_piece(sq)
			local function f()
				trg.hypno=false
				finish()
			end
			exhaust(trg)	
			trg.hypno=true			
			goto_sq(trg,sq,TEMPO,f)		
		end
		local function select_piece(e)
			sfx("hypnosys")
			trg=e
			trg.hypno=true
			
			local function f()
				set_instructions(lang.choose_destination)
				local a=get_range(trg)
				
				if stack.flagstones then
					for _,sq in pairs(squares) do
						if sq.flagstone and is_free(sq) then add(a,sq) end
					end
				end
				
				for sq in all(a) do
					sq.selectable,sq.show=true
					local f=function()		
						sfx("hypno_execute")
						remove_buts()
						clean()
						move_piece(sq)
					end
					mk_sq_but(sq,f,9)
				end	
				push_mode("move_hypnosis", trg)
				scan_cancel(clean)
			end
			--FX
			local tempo=90
			local e=mke(0,trg.x+8,trg.y+8)
			e.life=tempo
			e.dp=DP_FX
			
			local r=32
			e.dr=function(e,x,y)
			
				local pw=sin(e.life*.5/tempo)
				for k=0,1 do 
					local ax,ay=x,y
					local r,a=0,e.t/120+k*.5				
					for i=0,100 do 
						r=r+2
						a=a+6/(PI*r*2)
						local bx=x+cos(a)*r
						local by=y+sin(a)*r					
						local c=min(r/64,1)
						local cc=1-min(r/128,1)*pw						
						fillp(pat[1+flr(cc*15)],true)
						line(ax,ay,bx,by,5)					
						for di=0,3 do
							local dx=DIRS[di*2+1]*c
							local dy=DIRS[di*2+2]*c
							line(ax+dx,ay+dy,bx+dx,by+dy,5)
						end
						ax,ay=bx,by		
					end					
					
					
					--[[
					spritesheet("spiral")
					sspr(0,0,r*2,r*2,x-r,y-r)
					spritesheet("gfx")
					--]]
				end 
			end
			e.nxt=f
		
		end


		local function chk(b)
			return #get_range(b)>0 and b.type<6
		end

		ask_piece(chk,select_piece,bind(cancel,lang.no_valid_target))
	end
	
	-- SOULS
	if e.id==6 then
	
		local function chk(e)	return is_reapable(e) end
		local function select_piece(b)
			-- STEAL SOUL
			sfx("soul_wand")
			sfx("hurt")
			b.stun=2
			b.soulless=1
			
			b.c_shake=4
			b.c_hit=30
			
			
			add_soul(b.type,b,b.sanctity,true)
			wait(30,finish)
		end
		ask_piece(chk,select_piece,bind(cancel,lang.no_valid_target))
	
	end
	
	-- EXECUTION
	if e.id==7 then

		local function chk(e)	return e.type==0 end
		local function select_piece(b)
			xpl(b)
			sfx("execute")
			wait(8,finish)
			--fx_screen_flash(1,8)
			screen_shake(8)
			fx_red_flash()
			
			local tempo=16
			local e=mke(0,b.x+8,b.y+14)
			e.dp=DP_FX
			e.life=tempo
			e.dr=function(e,x,y)
				local c=e.life/tempo
				local h=64*ease_in(c)
				local r=4*(1-c)
				rectfill(x-r,y-h,x+r,y,cyc(2,3)==0 and 5 or 4)
			end

			
			
		end
		ask_piece(chk,select_piece,bind(cancel,lang.no_valid_target))

	end
	
	-- TREACHERY
	if e.id==8 then
	
		local function chk(e)
			--if e.type>=5 then return nil end
			if not e.reap and e.type>0 then return nil end
			
			local dx=e.sq.px-hero.sq.px
			local dy=e.sq.py-hero.sq.py
			return abs(dx)+abs(dy)==1
		end

	
		local function select_piece(b)		
			convert(b,finish)
		end
		
		
		ask_piece(chk,select_piece,bind(cancel,lang.no_valid_target))

	end
	
	-- NO CANCELING
	e.c_shake=60
	sfx("wand")
	

end
function ask_piece(chk,select,cancel)
	local targets={}
	for b in all_bads() do
		if chk(b) then add(targets,b) end
	end		
	if #targets==0 then
		cancel()
		return
	end
	
	set_instructions(lang.select_a_piece)
	
	
	local function clean()
		set_instructions()
		for e in all(bads) do	
			e.not_selectable=false	
			e.sel_rover=nil
		end
		for sq in all(squares) do
			sq.show=false
			sq.sel_rover=false
		end
		reset_mode()
	end
	
	for e in all(bads) do
		e.not_selectable=true
	end
	
	for e in all(targets) do
		e.not_selectable=nil			
		local f=function()
			rov=nil
			remove_buts()				
			clean()
			select(e)
		end
		
		local b=mk_sq_but(e.sq,f)
		b.over=function()
			e.sel_rover=true
			sfx("tic") 
			rov=e
		end
		b.out=function()
			e.sel_rover=nil
			if rov_sq==e.sq then
				rov=nil
			end
		end
		
	end


	scan_cancel(clean)
	push_mode("ask_piece")

end
function get_scepter(id)
	for e in all(scepters) do if e.id==id then return e end end
	return nil
end

-- MESSAGES
function set_instructions(str)
	msg(str,-1)
	inter.msg_flip=3
	
end
function msg(str,t,warn)
	inter.msg=str
	inter.msg_perm=t and t<0 or nil
	inter.c_msg=t or 60
	inter.msg_instruction=nil
	if warn then
		inter.c_warn=inter.c_msg
	end
end


-- BORDEL
function scan_cancel(clean)
	selecting=true	
	local function f(ev)
		if not selecting then 
			kl(ev)
		elseif mcr and ev.t>32 then
			remove_buts()
			exe(clean)
			sfx("cancel")	
			wait(30,play)
			kl(ev)
		end			
	end
	loop(f)
end
function earn_extra_turn(mute)
	
	if not hero.extra_turn and not hero.win then
		if not mute then sfx("extra_turn") end
		hero.extra_turn=true
		fx_emote(hero,lang.extra_turn,60)
	end
end
function boost(k,n,solo)
	n=n or 0
	if solo then
		if hero.boost[solo] then return end
		hero.boost[solo]=1
	end
	hero.boost[k]=(hero.boost[k] or 0 )+n
	
	
end
function dr_dot_line(a,b)
	if not a or not b then return end
	local dx=b.x-a.x
	local dy=b.y-a.y
	local d=sqrt(dx*dx+dy*dy)
	asspr(8-cyc(8,3),254,d,1,a.x+7,a.y+7,atan2(dx,dy),1,1,0,0)
end
function screen_shake(n,chr,flh)
	inter.c_screen_shake=n

	if chr and false then
		fx_screen_flash(n*2,chr,"chroma")
	end
	if flh then
		fx_screen_flash(1,flh)
	end	
end
function spend_hop()
	hero.hop=hero.hop>1 and hero.hop-1 or nil
	if not hero.hop and stack.botte then
		boost("firepower",stack.hop,"botte")
		show_card("botte",nil,60)
		if stack.hop>=4 then trig_achievement("MIDNIGHT_DANCE") end
	end
end

-- PIECES
function new_piece(type,bad,sq)


	local e=mke()
	e.piece=1
	e.mark={}
	e.ind={}
	tbl_import(e,PIECES[type+1])
	e.behavior=clone(e.behavior,true)
	
	if e.boss then boss=e	end
	e.z=0
	e.still=true
	e.prison_bar=0
	e.type=type
	e.bad=bad
	e.team=bad and 1 or 0
	
	e.ysort_dy=15
	e.upd=function()

	
		-- BOSS ANGLE
		if e.type==6 then
			local tx,ty=e.x+16,MCH
			
			if hero then
				tx,ty=hero.x+8,hero.y+8
			end
			
			--tx,ty=mx,my
			
			local dx=tx-(e.x+16)
			local dy=ty-(e.y+16)
			local ta=atan2(dx,dy)	
			if e.eating then
				ta=.25
			end	
			e.an=e.an+hmod(ta-e.an,.5)*.15
				
		end
	
		--HERO ANGLE
		if e==hero and not autofire and not e.c_slash then
			local x=mx-(e.x+8)
			local y=my-(e.y+8)
			if aim then 
				local ax,ay=get_center(aim)
				x,y=ax-(e.x+8),ay-(e.y+8)
			end
			if x ~= 0 or y ~= 0 then
				e.an=atan2(x,y)		
			end
		end

		if e.force_ang then
			e.an = e.force_ang 
		end
		
		-- FX_BURN
		if e.c_burning and e.t%4==0 then
			local p=mke(0,e.x+hrnd(4),e.y-1)
			p.z=0
			p.vz=0
			local r=(4+rnd(4))*(e.c_burning/60)*min(1,e.t/8)

			p.dr=function(p,x,y)

				y=y+p.z
				r=r*.95
				circfill(x+8,y+8,r,5)
			end
			p.we=-.05-rnd(.05)
			p.frict=.92
			p.life=20+rnd(30)
		end 
		
		-- FX_POISON
		if ((e.poisoned and e.poisoned>0) or (e.c_plague)) and e.t%15==0 then
			local p=mke(0,e.x+8,e.y)
			p.we=-.03
			p.life=30
			p.dp=DP_FX
			local a=rnd(1)
			p.dr=function(e,x,y)
				for i=0,1 do
					local c=p.life/30
					local r=3*c-i
					if r>0 then
						circfill(x+.5+cos(a+c)*2,y,r,1+i*2)
					end
				end
			end		
		end
		
		-- FX_FEAR
		if (e.fear or e.c_regret) and t%8==0 then
			local p=mke(0,e.x+8,e.y+rnd(2))
			p.we=-.03
			p.life=30
			p.dp=DP_FX
			local a=rnd(1)
			p.dr=function(e,x,y)
				color(2)
				fillp(0xAAAA,true)		
				local c=p.life/30
				local r=3*c
				circfill(x+.5+cos(a+c)*2,y,r)
				fillp()
			end

		
		end
		
		-- ASCENSION
		if (e.flying or e.taken) and not e.twc and not e.falling then
			e.z=-3.5+cos(e.t/60)*2
		end
	
		-- HEIR
		e.see_hat=false
		if e.role and hero and hero.sq and not e.c_heir and stack[e.role] then
			if is_orth_view(hero,e) then
				e.see_hat=true
			end
		end		
	
		-- RAISE
		if e.c_raise and e.c_raise%10==0 then
			_sfx("raise",-1,.25,0,1+hrnd(1)/10 )
			local p=fx_crumb(e,3+irnd(2))
			p.z=(e.c_raise/60-1)*16-2
			p.vz=-1
			p.dp=DP_FX
		end
	
		-- PRISON BAR
		e.jail=is_imprisoned(e)
		local jr=e.jail and not e.twc and (e.z==0	or e.flying)	
		e.prison_bar=mid(0,e.prison_bar+(jr and 1 or -1)/32, 1)
	
		-- SMOKING
		if e.c_smoke and t%3==0 then
			local tempo=16
			
			local p=mke(0,e.x+8+hrnd(4),e.y+13+hrnd(2))
			p.life=tempo
			p.z=1
			local r=0
			p.dr=function(e,x,y)		
				p.z=(p.z-.2)*.95
				y=y+p.z
				local c=p.t/tempo
				r=sin(ease_out(c)/2)*3
				color(3,4)
				fillp(pat[8])
				circfill(x,y,r)
				fillp()
			end
			p.drs=function()
				circfill(p.x,p.y,r,3)
			end

		end
	
	
		
	end
	e.dr=dr_piece
	e.drs=function()
		
		if (e.z and e.z<0) or e.type==9 then
			
			if e.big then
				shpr(224,36,24,11,e.x+4,e.y+15)
			else		
				shpr(20,12,7,4,e.x+4,e.y+13+PDY)
			end
		end
	end
	
	-- SKIN
	e.dr_skin=dr_skin
	if type==6 then -- BOSS
		inter.bossfight=1
		e.dr_skin=dr_boss
		e.alt_move=boss_turn
		
	end
	if type==9 then -- BOULET
		e.dr_skin=function(e,x,y,tp)
			spr(173,x,y+PDY)
		end
	end
	if type==10 then -- QUEEN MOTHER
		inter.bossfight=1
		e.cd=2
		local actions={
			fire =  { we=2, cd=2, act=fire},
			cross = { we=1, cd=4,solo=1},
			sword = { we=1, cd=4, },
		}
		local tentacles={}
		for i=0,5 do
			local tn={k=i%3,s=flr(i/3)*2-1,r=rnd(1)}
			add(tentacles,tn)
		end

		local function fire(tn)
			local last=tn[#tn]
			
			--
			local aid=tn.aid
			if aid~="fire" then
				local p=mk_part(last.x,last.y+8-3)
				p.z=-8
				p.vz=-1-rnd(1)
				p.dr=function(e,x,y)
					y=y+p.z
					local function f()
						if aid=="cross" then
							sspr(136,64,3,4,x-1,y-2)
						end
						if aid=="sword" then
							sspr(136,68,3,9,x-1,y-4)
						end
					end
					brd(f,2)					
				end
				p.drs=function()
					shpr(27,5,5,3,p.x-2,p.y-1)				
				end
				p.vx=hrnd(1)
				p.vy=hrnd(1)
				p.frict=.96
				p.on_impact=function()
					local avz=abs(p.vz/10)
					_sfx("shell_ground",-1,avz/2,0,0.8+rnd(.05))
					if avz<0.05 then
						p.vz=0
						p.we=0
					end					
				end
				return
			end
			
			-- FIRE
			local an=rnd(1)
			local trg=get_hero_trg()
			if trg then
				--an=atan2(trg.x+8-b.x,trg.y+8-b.y)+hrnd(.15)
				an=atan2(trg.x-last.x,trg.y-last.y+3)+hrnd(.15)
			end		
			bad_shoot(last.x,last.y+3,an)

		
		
		end
		
		local backups={1,2,3}
		local ft=0
		e.turn_move=function()

			if ft%7==0 then 
				local tp=backups[1]
				del(backups,tp)
				add(backups,tp)
				add_event(ev_side_spawn,tp)
			end
			ft=ft+1
			local free_tentacles={}
			local free_actions=clone(actions)
			for t in all(tentacles) do
				if t.cd then
					if actions[t.aid].solo then free_actions[t.aid]=nil end
					
					t.cd=t.cd-1
					if t.cd==0 then						
						t.cd=nil
						fire(t)
						t.aid=nil
						
					end
				else
					add(free_tentacles,t)
				end
			end

			-- +2 turns : ACTION
			local aids={}
			for k,v in pairs(free_actions) do	
				for i=1,actions[k].we do add(aids,k) end	
			end
			
			local tn=steal(free_tentacles)
			local aid=steal(aids)
			if tn and aid then
				tn.aid=aid
				tn.cd=actions[aid].cd


			end
	

		
		end
		e.dr_skin=function(e,x,y,tp)
			

			for tn in all(tentacles) do
				local i=tn.k
				local s=tn.s
				local px=x+8
				local py=y+6+i
				local an=s*.15-.25+(i-1)*s*.06--+cos(t/60)*.05
				local le=2.25+cos(t/360+(i*s/8))*.5					

				tn[1]={x=px,y=py}
				
				local max=e.c_spawn and flr( (1-e.c_spawn/60)*6 ) or 6
				
				for k=0,max do					
					an=an+cos(t/120+(i*s/4))*.01
					local a=an+cos(k/4+t/40+tn.r+(e.c_hit and t/30 or 0))*.1
					local nx=px+cos(a)*le
					local ny=py+sin(a)*le				
					px,py=nx,ny
					tn[k+2]={x=px,y=py}
				end

			end
			for tn in all(tentacles) do

				local last=tn[#tn]
				if tn.aid=="fire" then 
					circfill(last.x,last.y,.5+cyc(2,3)+2-tn.cd,5)
				end
				if tn.aid=="cross" then 
					circ(last.x,last.y-2,4,3+cyc(2,3))
				end							

			end
			
			local function f(bot)
				for tn in all(tentacles) do
					--
					for k=1,#tn-1 do					
						line(tn[k].x,tn[k].y,tn[k+1].x,tn[k+1].y,(k<4 or k>6) and 3 or 4)
					end	
					if tn.aid=="fire" and cyc(2,3)==0 then
						local last=tn[#tn]
						pset(last.x,last.y,5)					
					end					
					if tn.aid=="cross" then
						local last=tn[#tn]
						sspr(136,64,3,4,last.x-1,last.y-4)					
					end
					if tn.aid=="sword" then
						local last=tn[#tn]
						pal_piece(e)
						sspr(136,68,3,9,last.x,last.y-8,tn.s*3,9)
						pal_rst()
					end	
					
				end
				palt(1,true)
				--pal_piece(e)
				sspr(64,432,16,bot and 15 or 16,x,y+PDY)
				--
			end
			

			
			--
			local ocl=1
			if e.c_hit and t%6<3 then ocl=5 end
			--if e.c_warn and t%6<3 then ocl=5 end

			brd(f,ocl)
			f(true)
			palt()

		end

		e.on_new_turn=function()
			e.mother_range=0
			for t in all(tentacles) do
				if t.aid=="cross" then e.dmg_cap=2 end
				if t.aid=="sword" then e.mother_range=e.mother_range+1 end
			end
		end
		
	end
	if type==11 then -- HORSEMAN

		e.dr_skin=function(e,x,y)
			pal_piece(e)
			sspr(16,432,16,16,x,y-2)	-- ?
			pal_rst()
		end

		local function dr_apo(e,x,y)

			if e.pike and not e.c_lance then
				sspr(106,72,5,19,x+9,y-5)						
			end
			if e.plague_bearer then
				sspr(166,63,12,17,x+6,y-4)
			end
			
			pal_piece(e)			
			for i=0,15 do
				local c=max(i-8,0)/16
				local dx=cos(i/15+t/60)*2*c
				sfillp_dissolve(c)
				sspr(16,432+i,16,1,x+dx,y+i-2)
			end
			sfillp_rst()

			if e.black_king then pal_piece(hero) end
			sspr(139,64,6,16,x-1,y-4)
			
			if e.black_king then
				local va=.02
				e.an=e.an+mid(-va,hmod(e.ta-e.an,.5),va)				
				sspr(56+(round((e.an%1)*8)%8)*8,64,8,8,x-1,y-6)
			end



		end
	
		e.give_role=function()

			inter.role=inter.role and inter.role+1 or 1
			inter.bossfight=1	

			e.dr_skin=dr_apo

			
			-- PLAGUE ( PLAGUE )
			if inter.role==1 then	e.ind.plague_bearer=2 end

			-- WAR ( PIKE )
			if inter.role==2 then	
				e.ind.pike=1
				e.ind.militia=1
			end

			-- FAMINE ( SHIELD )
			if inter.role==3 then
				e.ind.armorgap=2	
				e.ind.buckler=1
			end

			-- DEATH ( ARCHER )
			if inter.role==4 then
				e.ind.bow=3
				e.ind.tempo=-1
				e.turn_move=function()	
				

				end
			end

			--


			setup_piece(e)
		end
	
	
	end

	
	goto_sq(e,sq,0)
	
	-- BADS
	if e.bad then
		add(bads,e)		
		if e.type==6 then	e.an=.25 end			
	end
	

	
	-- BLACK & WHITE
	e.cd=e.cd or irnd(get_piece_tempo(e))	
	setup_piece(e)
		
	-- FINAL
	e.poisoned=e.poison
	e.hp=e.hp_max
	if FRAGILE then e.hp=1 end
	if SUPPER_IS_READY then e.cd=get_piece_tempo(e) end

	return e

end
function setup_piece(e)
		

	local tbl=PIECES[e.type+1]
	e.hp_max=tbl.hp
	e.tempo=tbl.tempo
	e.dodge=tbl.dodge
	e.behavior=clone(tbl.behavior,true)
		
	-- RESET
	e.hprc=nil
	e.joust=nil
	e.cage=nil
	e.bodyguard=nil
	e.shield=nil
	e.shell=nil
	e.flying=nil
	e.castle=nil
	e.iron=nil
	e.orth=nil
	e.rep=nil
	e.sanctity=nil
	e.wraith=nil
	e.protect=nil
	e.healer=nil
	e.lastg=nil
	e.peace=nil
	e.curse=nil
	e.minr=nil
	e.carry=nil
	e.despair=nil
	e.leaderbond=nil
	e.catapult=nil
	e.emergency=nil
	e.push=nil	
	e.plague_bearer=nil
	e.armorgap=tbl.armorgap
	e.pike=nil
	e.reformed=nil
	e.disguise=nil
	e.investigate=nil
	e.uncover=nil
	e.vampire=nil
	e.bully=nil
	e.promote=nil
	e.killprom=nil
	e.charge=nil
	e.swap=nil
	e.despair=nil
	e.prison=nil
	e.bow=nil
	e.militia=nil
	e.carryking=nil
	e.censor=nil
	e.fitness=nil
	e.spawn=nil
	e.exile=nil
	e.lightfoot=nil
	e.stoning=nil
	e.block=nil


	-- HP BONUS
	e.hp_max=e.hp_max+stack.blood_bowl
	if e.plumed then e.hp_max=e.hp_max+3 end
	
	--
	local function adb(e,k,v)
		if type(v)=="number" then
			if not e[k] then e[k]=0 end			
			local min_v=-100
			if k=="hp" or k=="tempo" then min_v=1 end
			if k=="hp" then k="hp_max" end
			e[k]=max(min_v,e[k]+v)					
		elseif type(v)=="table" and #v>0 then
			e[k]=e[k] or {}
			for n in all(v) do add(e[k],n) end
		else
			e[k]=v
		end		
	end
	
	-- ALL BONUS
	for ca in all(get_all_cards()) do
		for k,v in pairs(ca) do
			local targets={}
			k,targets=parse_effect(k)
			if is_valid_target(e,targets) then
				adb(e,k,v)
			end
		end
	end
	
	-- LEADER BONUSES AFFECT FALSE KINGS ON BOSS FLOOR
	

	-- PERSO
	for k,v in pairs(e.ind) do adb(e,k,v) end

	-- BEHAVIOR
	if e.jester then		
		e.tempo=e.tempo-2
		if stack.jester_guard then
			add(e.behavior,{id="line",0,7,1,move=1})
		else
			add(e.behavior,{id="line",4,5,1,move=1})
		end		
	end
	if e.pike then
		add(e.behavior,{id="line",1,1,2,atk=1,fatality="pike",ignore_moat=1})
	end
	if e.orth then
		add(e.behavior,{id="line",0,3,8,move=1})
	end
	if e.reformed then
		for bh in all(e.behavior) do
			if bh.native then bh.atk=nil end
		end
	end
	if e.plumed then
		add(e.behavior,{id="line",4,7,1,atk=1})
	end
	if e.fitness then
		add(e.behavior,{ id="jump", move=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 })
	end
	if e.militia or e.fear then		
		for bh in all(e.behavior) do
			if bh[2] and abs(bh[1]-bh[2])<=2 then
				bh[1]=flr(bh[1]/4)*4
				bh[2]=bh[1]+3
			end
		end
	end
	if e.sided and not e.bad then
		for bh in all(e.behavior) do
			for i=1,2 do
				local k=flr(bh[i]/4)
				local n=(bh[i]-k*4)%4
				n=(n+2)%4
				bh[i]=k*4+n				
			end
		end	
	end
	

	--[[ TELEPORT
	if e.teleport then		
		for bh in all(e.behavior) do bh.move=nil end
		local bh={id="teleport",move=1}
		add(e.behavior,bh)
	end
	--]]
	
	-- MULT then MIN/MAX STUFF
	if e.hprc then e.hp_max=flr(e.hp_max*(1+e.hprc/100)) end	
	e.tempo=mid(1,e.tempo,10)
	e.hp=min(e.hp or 0,e.hp_max)

	-- DMG CAP
	e.dmg_cap=e.armorgap

	-- APPLY LOST
	if e.shield_lost then e.shield=nil end
	
	-- BLIGHT CURSE
	if e.type==10 or e.type==11 then 
		if not e.ind or not e.ind.bow then
			e.bow=nil
		end
		if not e.ind or not e.ind.armorgap then
			e.armorgap=nil
		end
	end



end
function goto_sq(e,sq,t,f,jh)
	t=t or TEMPO
	
	jh=jh or (e.big and 12 or 8)
	
	local hop=(e==hero or e.lightfoot) and sq.hop_trg

	if e.big and t>0 then t=t+12 end
	if hop then
		t=t*2
		if e==hero then spend_hop() end
	end
	
	-- LEAVE
	leave_sq(e)

	e.sq=sq
	e.sq.p=e
	e.sq.reserved=nil
	if e.big then
		sfx("boss_jump")
		local a=gsq_zone(e.sq)
		for sq in all(a) do	sq.p=e end
	end

	for sq in all(squares) do
		sq.highlight = false
	end

	local tx,ty=sqp(sq)
	
	if t>0 then	
		local function land()
			
			if hop and e==hero then earn_extra_turn() end
			if e.big then
				sfx("boss_land")
				inter.c_screen_shake=8
			end
			e.in_move=false			
			-- INQUISITION
			if sq.waypoint and e.investigate then				
				add_event(ev_abort_mission)
			end						
			-- CALTROPS
			if e.bad and not e.bleed and stack.caltrops and irnd(100)<stack.caltrops then
				inflict(e,"bleed")
			end
			
			exe(mode["on_"..e.name.."_move"])
			exe(mode.on_piece_move,e)
			exe(f)
			
			
			
		end
	
		mvt(e,tx,ty,t,land)
		
		local sz=e.z or 0

		
		local function jump(ev)
			local c=ev.t/t
			e.z=sz*(1-c)-sin(c/2)*jh
			if hop then
				e.z=e.z-abs(sin(c))*8
				if ev.t==flr(t/2) then
					sfx("head_bump")
					hop.hopped_on=true
					if e==hero then expose() end			
					if stack.hop_dmg and e==hero then
						hit(hop,stack.hop_dmg,{direct=1, hop=true})
					else
						hop.c_shake=4
					end
				end
			end
			if e.crusher then
				e.z=e.z-10*c
			end
		end
		if not e.crawl then
			local ev=loop(jump,t)
			ev.perm=e.perm
			ev.nxt=function()
				e.crusher=nil
			end
		end
		e.crawl=nil
		e.in_move=true
	else
		e.x,e.y=tx,ty	
	end
	
	-- PROMOTE
	if e.promote and sq.py==(e.bad and 7 or 0) then
		add_event(ev_promote,e)
	end
	
	-- REGRET
	show_regret(e)
	
	
	-- CHECKS
	trace_all_piece_dist()
	trace_heros_dists()
	check_cards_auto_flip()
end
function leave_sq(e)
	if e.sq and e.sq.p==e then
		e.wsq=e.sq
		if e.big then
			local a=gsq_zone(e.sq)
			for sq in all(a) do	sq.p=nil end
		end
		e.sq.p=nil
		e.sq=nil					
	end
	
	
end
function hit(e,dmg,at,from,fsq)
	

	
	at=at or {}

	-- DELAY IF PAUSE
	if pause then
		wait(2,hit,e,dmg,at,from)
		return
	end
	
	-- TOOLS
	local function apply_impact()
		local apply=function()
			if from then
				local kb=from.knockback or stack.knockback or 0
				kb=kb+(e.knockweak or 0)
				
				if kb>0 and not e.curtsy and not e.big then	
				
					e.curtsy=true
					curtsy=curtsy+1
					local di
					if e.sq and fsq then
						di=flr(atan2(e.sq.px-fsq.px,e.sq.py-fsq.py)*8+.25)%8
					else
						di=flr(atan2(from.vx,from.vy)*8+.25)%8
					end
					
					local nsq=dsq(e.sq,ADI[di+1],1)
			
					-- curtsy
					local function r()
						curtsy=curtsy-1
					end
					local f=function()
					
						if rnd(100)>kb then r() return end
						
						local affected=e.hp>0 or e.block
						if affected and not e.boss and not nsq then
							goto_fall(e,ADI[di+1])
							wait(60,r)
						elseif affected and is_free(nsq) then	
							if e.sq.moat and not nsq.moat then trig_achievement("LIFEGUARD") end
							e.kback=true
							goto_sq(e,nsq)
							wait(30,r)
						else
							r()
						end	
						
					end
					--wait(2,f)
					f()
					return
				end
				e.dcx=from.vx
				e.dcy=from.vy	
			else
				e.c_shake=8
			end
		end
		
		if from and (from.knockback or stack.knockback) then
			wait(2,apply)
		else
			apply()
		end
		
	end

	-- CANNONBALL
	if e.type==9 then
		_sfx("hurt",-1,.5,0,1+hrnd(.02))
		apply_impact()
		return
	end

	-- STUN
	if at.stun then
		stun_piece(e,at.stun)
	end

	-- IRON
	if chk_iron(e) then
		apply_impact()
		return
	end
	
	-- INFLICT BLEED 
	if at.bleed and not e.bleed then
		e.mark.bleed=1
		inflict(e,"bleed")
	end
	

	
	-- APPLY BLEED
	dmg=bleed_dmg(e,dmg)

	-- PROTECTION 
	local capped
	if not at.direct  then

		-- PROTECTOR
		local protector=get_nei_with(e,"protect")
		if protector and protector.type~=e.type then
			e.dmg_cap=min(e.dmg_cap or 2, 2)
		end
		
		-- DMG CAP
		if e.dmg_cap then
			dmg=min(e.dmg_cap,dmg)
			if protector and dmg==0 then 
				fx_emote(protector,lang.cover)
				return 
			end		
			if dmg==0 then
				capped=true
				sfx("dmg_cap") 
				--log("!!")
			end
			e.dmg_cap=e.dmg_cap-dmg	
		end
	end

	-- CHECK SHIELD
	if chk_shield(e) then return end

	
	-- CHECK CASTLE
	local function f(savior)
		hit(savior,dmg,at,from,fsq)
	end
	if chk_castle(e,f) then return end

	-- MARK SHEATH
	if at.sheath then
		inflict(e,"sheath")
	end


	--
	dmg=max(dmg,0)
	e.hp=max(e.hp-dmg,0)
	e.c_hit=30
	e.from=from
	
	-- BODYGUARD
	if e.hp<=0 and chk_bodyguard(e) then
		e.hp=1	
	end
	
	-- EMERGENCY CALL
	if dmg>0 and e.emergency and not e.emergency_done then
		e.emergency_done=true
		add_event(ev_ask_for_help,e)	
	end

	-- FALSE KING
	if dmg>0 and e.false_king then	
		stun_piece(e)
		add_event(ev_usurper,e)
	end

	-- ACHIEVEMENT STUFF
	if dmg>0 then
		-- FINAL ESCAPE [ACH]
		if hero.deathcount_start then
			hero.fail_final_escape=1
		end
		-- BURIED ALIVE
		if not at.bond then e.non_bond_dmg=1 end
		
	end

	-- DMG_FX
	if not e.lifted and (dmg>0 or capped ) then		--and  dmg>0
		
		fx_dmg(e,dmg,capped)		
		--[[
		local p=mke(0,e.x+8,e.y) 
		if e.big then
			p.x=p.x+8
			p.y=p.y-12
		end
		p.dp=DP_FX
		e.hurt=p
		p.dmg=dmg
		p.vy=-2
		p.frict=.85
		p.life=60
		p.capped=capped
		p.dr=function(p,x,y)
			local s=p.dmg..""
			local cl=p.capped and (3-cyc(2,3)) or 5
			fbrd(function()
				local sav = font()
				font("pico")
			  lprint(s,x,y,4,1)
				font(sav)
			end,cl)
			--lprint(s,x,y,5,1)
		end
		p.nxt=function() e.hurt=nil end
		--]]
	end
	
	if e.hp<=0 and not e.dead then
		e.hop_death = at.hop
		if e.block then
			e.dead=true
			add_event(ev_death,e)
		else
			xpl(e)
		end
	else
		exe(mode.on_bad_hurt,e,dmg)
		if at.plague then
			e.c_plague=30
			sfx("plague",.5)
		elseif e.boss then
			sfx("hurt_boss",.15)
		else
			_sfx("hurt",-1,.5,0,1+hrnd(.02))
		end
		apply_impact()
	
	end
end
function xpl(e)

	local psq=e.sq
	e.psq=psq
	del(bads,e)
	
	if e.team_boss then
		local a={}
		for b in all(bads) do	if b.team_boss then add(a,b) end	end
		if #a==1 then 
			boss=a[1]
			boss.boss=true		
		end
	end
	
	
	if e.boss then
		e.c_hit=9999
		return
	end
	leave_sq(e)
	kl(e)
	
	if e.mastermind and not e.bad then
		sfx("crystal_xpl",.75)
	end
	
	-- ON DEATH
	on_death(e)

	-- BOSS SOUL
	if e.soul_fx then
		local ghost=mke(0,e.x+8,e.y+8)
		ghost.dp=DP_FX
		ghost.z=-6
		ghost.life=120
		
		local spd=1/(e.fast_soul and 4 or 10)
		ghost.upd=function(e)
			e.z=e.z-spd
		end
		ghost.dr=function(e,x,y)
			y=y+e.z
			for i=0,16 do
				local c=max((i-4)/12,0)
				if ghost.life<30 then c=min(c+1-ghost.life/30,1) end
				sfillp_dissolve(c)
				sspr(128,64+i,8,1,x-4,y+i)
			end
			sfillp_rst()
		end
		ghost.drs=function()
			shpr(20,12,7,4,ghost.x-3,ghost.y+2)
		end
		
	end
	
	-- FX+SFX VANISH ( default PARTS )
	if e.smoke_king then
		fx_vanish(e)
	elseif e.crumb then
		fx_dust(e.type*16,432,16,16,e.x,e.y-2)
	else
		sfx("xpl")
		for i=0,6 do fx_crumb(e,i) end
	end
	
	--
	check_cards_auto_flip()

	-- BURY RETURN
	if e.bury then return end

	-- UNDEAD
	local will_rep=psq and e.rep 
	if psq and e.rep==0 and psq.py==7 and stack.pawn_global_promote then 
		will_rep=false 
	end
	if hero.win then will_rep=false end
	
	if will_rep then
		psq.reserved=true
		add_event(ev_raise_dead,psq,e.rep)
	end	
	
	-- RATS
	for i=1,(stack.rats or 0) do if psq then
		sfx("rat")		
		local rat=mke(0,e.x+8,e.y+8)
		rat.sq=psq
		rat.upd=function(e)
			if psq and not e.twc and not e.blink then
				local tx,ty=sqp(psq)
				mvt(rat,tx+rnd(SQ),ty+rnd(SQ),-1)
				rat.twcv=ease_in_out
			end		
			if e.ex then
				e.flp=e.ex<e.x
			end
			if not ingame then kl(e) end
			
		end
		rat.dr=function(e,x,y)
			local function f() 
				spr(7+5*16,x-4,y-4,.5,.5,e.flp,false)
			end
			brd(f,0)
		end
		add_event(ev_rat_atk,rat)
	end	end
	
	-- LAST GUARDIAN
	if e.lastg then
		local a={}
		for b in all(bads) do
			if b.type==e.type then add(a,b) end
		end
		if #a==1 then
			add_event(ev_promote,a[1])
		end
	end
	
	-- JESTER
	if e.jester then
		local a={}
		for b in all(bads) do
			if b.type==0 then add(a,b) end
		end
		local b=steal(a)
		if b then
			jesterize(b)
		end	
	end

	-- DEATHMARK
	--[[
	if e.deathmark then 
		add_event(ev_mark_card,{team=0}) 
	end
	--]]


	-- ACHIEVEMENTS
	


end
function xpl_anyone(e)
	if e.mastermind then
		xpl_king(e)
	else
		xpl(e)
	end
end
function exhaust(e)
	e.cd=0
	e.ready=false
end
function stun_piece(e,n)
	if e==hero then return end
	e.stun=n or 1
	e.ready=king
	e.catapult_sq=nil
end
function bleed_dmg(e,dmg)
	if e.bleed and not e.mark.bleed then
		dmg=dmg+1
		e.mark.bleed=1
	end
	return dmg
end

-- ESCAPE MECHANICS
function chk_bodyguard(e)

	if e.type==leader then
		local ok=false
		for b in all(bads) do
			if b.bodyguard and b.bad==e.bad then
				ok=true
				b.c_protect=30
				fx_emote(b,lang.knight_guard,60)
			end
		end
		if ok then 				
			fx_shield(e)
			return true
		end
	end	
	return false



end
function chk_castle(e,nxt)

	if e.type~=leader and e~=hero then return false end
	local castlers={}
	for b in all_pieces() do
		if b.castle and b.bad==e.bad and not b.stun then add(castlers,b) end
	end
	if #castlers==0 then return false end
	if not e.sq then return false end -- thrown
	
	local savior=steal(castlers)

	-- CLEAN
	
	if e==hero then
		start_lvl_music()
		hero.detected=nil
	end
	
	if e.mark.bleed then	-- need better patch
		e.bleed=nil
		e.mark.bleed=nil
	end
	
	sfx("castle")
	msg(lang.castle)			
	savior.stun=1
	stun_piece(e)	
	if e.type==5 and e.mark.throw_impact then
		trig_achievement("MR_PRESIDENT")
	end	
	if e.big then 
		nxt(savior)
		return true
	end 

	local tempo=20
	pause=true
	inter.light=true
	e.perm=true
	e.castled=true
	savior.perm=true				
	local ksq=e.sq
	local rsq=savior.sq				
	local dx=ksq.x-rsq.x
	local dy=ksq.y-rsq.y
	local an=atan2(dx,dy)
	leave_sq(savior)
	leave_sq(e)
	goto_sq(e,rsq,tempo)
	goto_sq(savior,ksq,tempo)
	local function land()
		inter.light=false
		e.perm=false
		savior.perm=false
		pause=false
		nxt(savior)
	end				
	local function dust(ev)
		local a={e,savior}
		for i=1,2 do
			local trg=a[i]
			local e=mke(0,trg.x+rnd(16),trg.y+rnd(16))
			e.perm=true
			e.t=irnd(2)
			impulse(e,an,rnd(4)*(i*2-3))
			e.frict=.95
			e.life=min(8+irnd(8),ev.life-8)
			e.dr=function(e,x,y)
				line(x,y,x-e.vx,y-e.vy,4)
			end
			e.drs=function()
				local x,y=e.x+2,e.y+2
				line(x,y,x,y+e.vy,3)
			end
			
		end
		
	end
	
	local ev=loop(dust,tempo+16,land)
	ev.perm=true

	return true
	
end
function chk_shield(e)
	if not e.shield and not e.c_protected then return false end
	if not e.c_protected then 
		sfx("shield")
	end	
	e.c_protected=16	
	e.shield=nil	
	e.shield_lost=true
	fx_shield(e)
	return true
end
function chk_iron(e) 
	if e.iron then
		e.c_iron=16
		if not e.c_protected then sfx("shield") end	
		e.c_protected=16
		return true
	end
	return false
	
end

-- RANGE
function get_range(p,pm)	--tag,soul_type,planning

	local psq=p.sq
	
	-- DEFAULT
	pm=pm or {move=1}
	--tag=tag or "move"

	-- PEACE
	if pm.atk then
		local deepwater = p.sq.moat and stack.deepwater and stack.moat and p.bad
		if p.peace or p.fear or p.friend or p.stun or deepwater then return {} end --or elusive 
	end

	-- PRISON
	if p.jail then return {} end	
	--
	local result={}

	-- MODIFY RANGE
	local inc_range=0
	local min_range=p.minr or 1	
	local max_range=p.mother_range or p.cage or 8	
	if p.poisoned then
		max_range=1
	end
	if p==hero then
		inc_range=inc_range+(stack.sprint or 0)
	end
	if p.assault and p.still and pm.move then
		inc_range=1
	end


	-- HOP
	local hop_trg,hop_done=nil
	
	-- TOOLS
	local function is_free(sq)
		if p.big then
			local a={0,0,1,0,0,1,1,1}
			for i=0,3 do
				local tsq=gsq(sq.px+a[i*2+1],sq.py+a[i*2+2])
				if not tsq or (tsq.p and tsq.p~=p) then return false end			
			end
			return true
		else
			return not sq.p
		end
	end
	local function pass(sq,bh)
		if not sq then return  false end
		if sq.p and p.hop and not hop_done and not sq.p.airy and pm.move and not sq.p.hopped_on then
			hop_trg=sq.p
			hop_done=true
			return true
		end				
		if p.flying then return true end
		if not psq.moat and sq.moat and not bh.ignore_moat then return false end		
		if sq.p and sq.p==hero and pm.scan then return true end --
		if sq.p and sq.p.jail then return true end
		
		return is_free(sq) or (sq.p and sq.p.airy)
	end
	local function add_sq(sq,bh)
	
		if not sq then return end
	
		if hop_trg and hop_trg~=1 then
			sq.hop_trg=hop_trg			
		end		
		hop_trg=nil
	
		if is_free(sq) or pm.atk then
			sq.mark[p]=bh.fatality
			add(result,sq)
		end
		
		
	end	
	local function seek_lines(a,b,max,bh)
		max=max or 8	
		local dirs={}
		if type(a)=="table" then
			dirs=a
		else		
			for di=a,b do add(dirs,di) end
		end
		for di in all(dirs) do
			hop_done,hop_trg=nil
			local k=1
			local sq=psq
			while k<=max do
				sq=dsq(sq,di,1)
				if k>=min_range then add_sq(sq,bh)	end
				if not pass(sq,bh) then break end
				if hop_trg then 
					k=max
				else 
					k=k+1 
				end
			end
		end		
		
	end	


	local behavior=p.behavior or PIECES[(p.type or 5)+1].behavior	
	if pm.type then
		behavior=PIECES[pm.type+1].behavior	
	end
	
	for bh in all(behavior) do
		for tag,v in pairs(pm) do if bh[tag] then
			local av=true
			--chamber>0 

			if bh.backstab and (not hero.sweaty) and not pm.soul then av=false end
			
			
			if av then
				if bh.id=="line" then
					local range=min(bh[3]+inc_range,max_range)				
					seek_lines( bh[1],bh[2],range,bh)
				end
				if bh.id=="jump" then
					for i=1,#bh,2 do
						local x=p.sq.px+bh[i]
						local y=p.sq.py+bh[i+1]
						add_sq(gsq(x,y),bh)
					end				
				end
				if bh.id=="teleport" then
					for sq in all(squares) do 
						--and (sq.px==0 or sq.px==7 or sq.py==0 or sq.py==7)
						if is_free(sq) then 
							add_sq(sq,bh)
						end
					end
				end
			
			end
		
		end	end	
	end	


	--[[ PRESENCE
	if stack.presence and p.bad and p.type~=5 and pm.move then
		local hsq=get_hero_sq()
		for di=0,7 do
			local nsq=dsq(hsq,di,1)
			del(result,nsq)
		end		
	end
	--]]
	

	return result
end
function get_piece_targets(p,psq)

	if psq then p.sq,p.wsq=psq,p.sq end	
	local a=get_range(p,{atk=1})
	if psq then p.sq=p.wsq end
	
	local result={}
	for sq in all(a) do
		local trg=sq.p
		if trg and trg.bad~=p.bad then
			local valid=true
			
			-- CAN ONLY TARGET KING IF NOT READY
			if not p.ready and not (trg.mastermind or trg.smoke_king) then
				--log("kabunga!")
				break
			end
			
			-- VALIDATE SPY
			if p.investigate and trg.role=="spy" and trg.exposed then
				valid=true
			end
			
			-- UNVALIDATE CLOAKED
			if trg.cloaked and not p.uncover then	
				valid=false	
			end
			
			-- UNVALIDATE ELUSIVE KING
			if trg.mastermind and stack.elusive and p.cd>=get_piece_tempo(p) then
				valid=false
			end
			
			-- UNVALIDATE CANNONBALL
			if trg.peaceful then
				valid=false
			end
			
			
			if valid then	add(result,trg)	end	
	
		end

	end
	return result

end


-- SHOOT
function bad_shoot(x,y,an)
	an=an or rnd(1)

	local b=mke(0,x,y)
	b.dp=DP_FX
	b.projectile=true
	b.an=an
	b.spd=.5

	b.z=-3
	b.dis=0
	

	b.sync_upd=function(e)
	
		if e.stop then return end
	
		e.x=e.x+cos(e.an)*e.spd
		e.y=e.y+sin(e.an)*e.spd
		
		
		local sq=get_square_at(e.x,e.y)
		local s=sq and -1 or 1				
		e.dis=mid(0,e.dis+s/20,1)
		if e.dis==1 then kl(e) end
		
		
		-- CHECK HERO KILL 
		local sq=e.gsq(0)
		if sq and sq.hole then sq=nil end
		if not hero.detected and sq==hero.sq and not hero.in_move then 
			local tempo=180
			fx_detect(tempo,e.x,e.y+e.z)
			hero.detected=true
			e.c_detect=tempo
			e.stop=true
			local function f()
				kl(e)
				xpl_king(hero)
			end			
			wait(tempo,f)
			
		-- CHECK BLACK PIECE KILL
		elseif sq and sq.p and sq.p.sq==sq and not sq.p.bad then
			if not sq.p.detected then
				if sq.p.mastermind or sq.p.smoke_king then
					xpl_king(sq.p)
				else
					xpl(sq.p)
				end
			end
			
			kl(e)		
		end
		
	end
	b.dr=function(e,x,y)
		y=y+e.z
		local cl=4+cyc(2,6)		
		cl=5
		local dis=e.dis or 0
		if e.life then dis=min(e.life/30,e.dis) end
		fillp_dissolve(dis)		
		if e.c_detect and t%4<2 then apal(1) end
		circfill(x,y,2,cl)
		fillp_dissolve( max(dis,.5) )
		circfill(x-cos(an)*2,y-sin(an)*2,1.5,cl)				
		fillp()
		circfill(x,y,1,4)
		pal_rst()
	end	
	b.drs=function()
		shpr(27,5,5,3,b.x-2,b.y-1,-1)
	end			
	b.gsq=function(steps)
		local d=b.spd*(TEMPO+2)*(steps or 0)
		local x=b.x+cos(b.an)*d
		local y=b.y+sin(b.an)*d	
		local sq=get_square_at(x,y)
		if sq and abs(sq.x+8-x)<5 and abs(sq.y+10-y)<5 then
			return sq
		end
		return nil	
	end
	
	b.get_danger=function(steps)
		local a={}
		local x,y=b.x,b.y
		for i=1,(steps or 1)*(TEMPO-1) do
			x=x+cos(b.an)*b.spd
			y=y+sin(b.an)*b.spd
			local sq=get_square_at(x,y)
			if sq and not sq.hole and abs(sq.x+8-x)<5 and abs(sq.y+10-y)<5 then
				uadd(a,sq)
			end
		end
		return a
	end
	
	


	return b
end

-- DRAW PIECE
function dr_piece(e,x,y)

	-- INSPECTION CURSOR (GAMEPAD)
	if rov==e and not MOUSE then
		trifill(x+2,y+2,
						x+2,y  ,
						x  ,y+2,
						5)
	end

	-- SHAKE
	if e.ready and (playing or throwing) then
		x=x+cyc(2,6)
	end	
	if e.c_shake then
		x=x+e.c_shake*(cyc(2,3,e.c_shake)*2-1)
	end

	-- PROTECTION
	if e.c_protect then
		circfill(x+6,y+7,3+e.c_protect/6,5)
	end

	-- SOUL
	local soul=e.soul
	if e.c_soul and t%6<3 then soul=nil end

	-- MOAT	
	if e.sq and (e.sq.moat or e.sq.hole) and not e.twc and e.type~=6 and not e.chosen and not e.flying and e.z>-1 then		
		clip(x-24,y-20,64,30,true)
		if e.sq.moat then	y=y+.5+cos(t/60) end
		if e.c_dodge then 
			local c=(e.c_dodge/24)^2
			y=y+sin(c/2)*8 
		end
		y=y+(e.deep_y or 0)
	end
	
	-- RAISE
	if e.c_raise then
		local c=ease_in(e.c_raise/60)
		clip(x-8,y-10,32,25,true)	
		if e.c_raise>20 then
			x=x+cyc(2,3,e.c_raise)
		end
		y=y+c*16
		
		
	end
	
	-- GLUE
	if e.c_glue then
		local c=(e.c_glue-1)/30
		e.z=min(-sin(c*.5)*4,0)
		local r=4-sin(c*.5)*4
		rectfill(x+8-r,y+14,x+7+r,y+14-e.z,5)
	end
	
	-- MIST BUILD
	if e.mist_build then
		local c=1-(e.mist_build/64)
		local h=c*20
		clip(x,y+h-4,16,20-h,true)	
	end

	-- SHOTGUN A
	local an=e.an
	if aim then
		an=atan2(aim.x-e.x,aim.y-e.y)
	end
	e.current_an=an
	local scl=4
	if e.lift and e.lift.type~=9 and e.lift.bad then scl=1 end	
	local function draw_shotgun()
		if soul then return end
		if mode.no_shotgun then return end
		if e.falling then return end
		
		air(e)
		
		local scy=abs(an)<.25 and 1 or -1
		
		if e.drag then
		
		elseif e.lift then	
			
			local x,y=x,y
			local a=an-.25
			if e.c_lift then
				local c=e.c_lift/20
				y=y+sin(c)*4
				a=a*(1-c)
			end			
			if e.lift.type==9 then
				x=x+cos(an)*3
				y=y+sin(an)*2			
			end
			
			if e.c_flh_lift then 
				pal_inc(1)
			end
			dr_rotated_piece(e.lift,x,y,a)
			pal()
			
			--[[
			local spx,spy=e.lift.type*16,432
			if e.lift.iron then	spy=spy+16 end
			if e.lift.custom_dr then
				palt(1,true)
				e.lift.custom_dr(e.lift, x+8, y+2+dy, a)
				palt(1,false)
				spritesheet("gfx")
			elseif e.lift.type==9 then
				local dx=cos(an)*3
				dy=dy+sin(an)*2
				sspr(spx,spy+16,16,16,x+dx,y+dy-6)
			else				
				palt(1,true)				
				colorize_piece(e.lift)
				asspr(spx,spy,16,16,x+8,y+2+dy,a,1,1,8,8)
				palt(1,false)
			end
			
			--]]
			
		elseif rov_slash or e.c_slash then
			local a=an
			if e.c_slash then
				a=a+sin(e.c_slash/24)*.2*scy
			end
			local dx,dy,dw=0,16,8
			if has_card("Nightbane") then
				dx,dy=0,16
			elseif mode.weapons_index==4 then -- MAKEDA
				dx,dy=24,16	
			elseif has_card("Bushido") then
				dx,dy=24,24
			elseif has_card("Small Fry Harvest") then
				dx,dy,dw=48,16,16
			elseif has_card("Shovel") then
				dx,dy=0,24
			elseif has_card("Ritual Dagger") or has_card("Vendetta") then
				dx,dy=72,16					
			end
			-- Vendetta
			-- Ritual Dagger
			-- Small Fry Harvest
			
			asspr(dx,dy,24,dw,x+8,y+8,a,1,scy,4,4)
			
		else
			--if not MOUSE and ctrl_mode ~= "aim" then return end			
			local sw=has("recoil") and 12 or 16
			asspr(32,0,sw,16,x+8,y+8,an,1,scy,4,8)
		
		end
	end
	if e==hero and an%1>.5 then
		brd(draw_shotgun,scl)
	end		
	
	-- DRAG
	if e.drag and get_square_at(mx,my)~=e.sq then
		sspr(137,16,7,6,x+4,y+abs(cos(t/30))*2-9.5)
	end
	if e.picked then
		spr(42,x,y-6)	
	end
		
	-- BOW BACK
	if e.bow and (e.arrow_count or 0)<(e.arrow_limit or 1) and not e.big then
		sspr(145,63,7,17,x+8,y-4)
	end		
		
	-- TYPE
	local tp=e.type
	if e.disguised then tp=e.disguised end
	if soul then tp=soul end
	if e.c_promoted and t%6<3 then 
		tp=e.prom_from or 0 
	end

	-- DRAW SPRITE
	e.dr_skin(e,x,y,tp)

	-- HEAD
	air(e)
	if tp==5 then
		if e.mastermind then
			sspr(56+(round((e.an%1)*8)%8)*8,64,8,8,x+4,y-3)
		else
			sspr(leader==5 and 96 or 104,16 ,8,8,x+4,y-3)
		end
	elseif tp==leader and not e.big and not e.boss then
		--sspr(113,56,5,4,x+5,y+e.hdy-5)
		sspr(97,16,5,4,x+5,y+e.hdy-5)
	end
	
	if e.role and (e.see_hat or e.reveal) then
		if e.reveal and t%6<3 then pal_inc(1)	end		
		local by=y+(e.type==0 and 0 or -1)
		sspr(160+ROLES[e.role].gid*9,26,9,6,x+3,by+cos(t/(e.reveal and 24 or 60))*2-4.5)
		pal_rst()
	end
	if e.jester and (not e.c_jester_spawn or t%6<3) then
		sspr(144,16,9,7,x+3,y-2)
	end
	if e.plumed and (not e.c_morph or t%6<3) then
		local y=e.type==1 and y-1 or y-3
		sspr(121,64,7,7,x-1,y)
	end
	
	-- HEALER
	if e.healer then
		sspr(106,91,5,5,x+5,y+8)
	end	

	-- CHARGE ( UNICORN )
	if e.charge and e.type==1 then sspr(123,71,5,5,x+10,y-2) end
	pal_rst()
	sfillp_rst()

	-- BOW / SHIELD
	if not e.big then
		if is_bow_ready(e) then
			sspr(152,63,14,17,x,y-4)
		elseif e.shield then
			sspr(88,0,8,9,x,y+5)
		elseif e.buckler and e.armorgap then
			sspr(178,63,11,11,x-3,y+1+e.hdy)
		elseif e.hold_stone then
			local dy=e.c_hold_stone or 0
			if e.jester then
				for i=0,e.hold_stone do
					local c=i/e.hold_stone+t/60 
					local x=x+5+cos(c)*5
					local y=y+8.5-abs(sin(c))*(c%1<.5 and 4 or 14)
					sspr(112,90,6,6,x,y+dy)
				
				end
			else
				
				clip(x,y,16,16,true)
				sspr(112,90,6,6,x+1,y+7+dy)
			end
			
		end
	end

	-- SHOTGUN B
	if e==hero and an%1<=.5 then
		brd(draw_shotgun,scl)
		sfillp_rst()		
	end

	-- AIM
	if aim==e and playing and t%60<30 then
		local hx,hy=get_center(e)
		spr(40,hx-8,hy-8)
	end
		
	-- STUN / SOULLESS
	if e.stun then
		local cx,cy,r=x+8,y,6
		if e.big then 
			cx=x+16
			cy=y-18
			r=8
		end
		for i=0,2 do
			local a=i/3+_t/60
			local px=cx+cos(a)*r
			local py=cy+sin(a)*r/2-2
			sspr(118,75,5,5,px-2,py-2)
		end
		
	elseif e.soulless and t%32==0 then
		local p=mke(0,e.x+8+hrnd(5),e.y+e.hdy-3-rnd(6))
		p.life=32
		p.dp=DP_FX
		p.dr=function(e,x,y)
			local fr=flr(p.t/8)
			local function f()
				sspr(128+fr*8,272,8,8,x-4,y)
			end
			brd(f,3)
		end
		
	end

	-- PARALYSIS
	if e.c_paralysis then
		sspr(168+cyc(3,8)*8,240,8,8,x+4,y-10)
	end

	-- FX DANGER
	if e==hero and e.sq and #e.sq.danger>0 and playing then
		local fr=flr(((e.an or 0)%1)*8)
		local offx=0
		if fr>=2 and fr<=6 then
			offx=1
		end
		if fr>=3 and fr<=5 then
			offx=2
		end
		sspr(0+19*(round(t/6)%5),352,19,12,x+offx-3,y-10)
	end
	
	-- FX BACKSTABB
	for bh in all(e.behavior or {}) do
		if e.ready and bh.backstab and hero and hero.sweaty and playing then
			for i=0,1 do
				local s=1-i*2
				ssspr(192,234,3,6,x+s*(4-cyc(4,6))+i*13-1,y-1-cyc(2,12),s)
			end
		end
	end

	-- FX_SHEATH
	if e.sheath then
	
		local x,y=x+5,y+7
		if e.big then
			x=x+8
			y=y+8
		end
		if survive_sheath(e) then pal(5,3) end	
		sspr(182,75,5,5,x,y)
		pal()
	end

	-- FX_PRISON	
	if e.prison_bar>0 then
		local hh=(e.jail and ease_bounce_out(e.prison_bar) or ease_out(e.prison_bar) )*15
		local x,y=e.x,e.y
		for dx=2,15,5 do
			line(x+dx,y,x+dx,y+hh,4)
			rectshade(x+dx+1,y,1,hh,-1)
			rectshade(x+dx-1,y,1,hh,-1)		
		end
	end


	-- FX BLEED
	if e.bleed then
		local x,y=x+8,y+8+cyc(3,8)
		if e.big then
			x=x+16
			y=y+10
		end
	
		sspr(178,76,3,4,x,y)
	end


	-- FX LOCKED
	if e.tactic_locked then
		sspr(240,72,7,8,x+4,y+3.5+cos(t/60))
	end


	----
	--if DEV and e.militia then
	--	sspr(rnd(128),rnd(128),4,4,x,y)
	--end

	--
	if KING_CIRCLE and e.win then
		circ(x+8,y+8,8,4+cyc(2,3))
	end

	--
	clip()
end
function dr_skin(e,x,y,tp)

	tp=tp or e.type
	--

	pal_piece(e)
	if e.pike and not e.c_lance then			
		sspr(106,72,5,19,x+9,y-5)
	end
	if e.iron and e.c_iron then pal_inc(1) end
	air(e)
	
	-- SKIN
	local custom=PIECES[tp+1].custom_dr
	if custom then
		custom(e,x,y+PDY)
		spritesheet("gfx")
	else
		--[[
		if e.iron then tp=tp+12*16+11 end
		spr(16+tp,x,y+PDY)
		--]]
		if e.iron then tp=tp+16 end
		spr(432+tp,x,y+PDY)
	end

	sfillp_rst()
end
function air(e)
	if e.c_warn then return false end
	if e.airy or (e.cloaked and not e.disguised ) then
		local a={0x5FAF,0xF5FA,0xAF5F,0xFAF5}
		for i=0,5 do
			sfillp(i,a[cyc(4,8)+1],i)
		end
	end
end	

function dr_rotated_piece(p,x,y,a)


	local spx,spy=p.type*16,432
	if p.iron then	spy=spy+16 end
	
	if p.custom_dr then
		palt(1,true)
		p.custom_dr(p, x+8, y+2, a)
		palt(1,false)
		spritesheet("gfx")
	elseif p.type==9 then
		sspr(spx,spy+16,16,16,x,y-6)
	else				
		palt(1,true)				
		colorize_piece(p)
		asspr(spx,spy,16,16,x+8,y+2,a,1,1,8,8)
		palt(1,false)
	end


end

-- TOOLS
function on_death(e,psq)
	
	if e.bury then return end
	e.killer=e.killer or hero
		
	-- FRAGS
	if not e.bury then 
		add(hero.frags,e.type) 
		add(mode.frags,e.type) 
	end
	
	-- LEADER CHECK
	local win=e.type==leader
	for b in all(bads) do		
		win=win and (b.type~=leader or b.false_king)
	end	
	if win then
		hero.win=true		
		local heir=seek_role("heir")
		if heir then
			add_event(ev_reveal_heir)
		elseif stack.surrender then
			wlog("make ev_surrender on floor "..mode.lvl.." on turn "..mode.turns)
			if not tbl_has(events,ev_surrender) then add_event(ev_surrender) end
		end	
	end
		
	-- ON DEATH
	if e.type==leader then exe(mode.on_leader_death) end
	exe(mode["on_"..e.name.."_death"])
	exe(mode.on_bad_death,e)

	-- REWARD
	if (e.give_soul or is_reapable(e)) and not e.bury and not e.soulless and e.bad then
		add_soul(e.type,e,e.sanctity)
	end
	
	-- SHELLS
	if e.shell then
		give_ammo(e,e.shell)
	end
	
	-- ALARM
	for i=1,(stack.alarm or 0) do
		increase_card_turns({team=1})
	end
	
	-- JOUST / JESTER GUARD
	if e.joust or (e.jester and stack.jester_guard) then
		earn_extra_turn()
	end

	-- LEADER BOND
	if e.leaderbond then
		for p in all(bads) do if p.type==leader then
			hit(p,e.leaderbond,{direct=1,bond=1})
		end end
	end
	
	-- FEARSOME
	if e.bad and (e.type>0 or stack.humanshield) and stack.fearsome then
		local function fear_around(sq)
			if not sq then return end
			local a=get_zone(sq,stack.fearsome)
			for sq in all(a) do
				if sq.p and sq.p.bad and not sq.p.big and not sq.p.inert then
					sq.p.fear=true
					setup_piece(sq.p)
				end
			end
		end
		if e.killer==hero then 
			fear_around(e.killer.sq)
			if stack.terrorism then
				fear_around(e.psq)
			end
		end
		
	end

	-- DEMORALIZE
	if e.despair then
		for b in all(bads) do	
			b.fear=true
			setup_piece(b)
		end
	end
	
	-- AUTO RELOAD
	if e.freereload then
		add_event(ev_reload,1)
	end

	-- CURSE FLIP
	if e.curse then
		for ca in all(get_slot_cards()) do
			if ca[e.name.."_curse"] then
				flip_card(ca)
				build_stack()
			end
		end	
	end

	-- DISGUISE
	if e.disguise then
		cloak_hero(e.disguise,e.type)
	end

	-- RAPUNZEL
	if stack.rapunzel and e.type==3 and e.bad then --
		e.psq.reserved=true		
		add_event(ev_piece_drop,e.psq,4,false)	
		local ca=get_card_with("rapunzel")
		flip_card(ca)
	end

	-- VENDETTA
	if stack.vendetta and e.bad then
		local a={}
		for b in all(bads) do
			if b.type==e.type then 
				b.cd=100
				b.c_burning=60
				add(a,b)
			end
		end	
		if #a>0 then
			custom_sort(a,function(b) return b.x end)
			local b=a[1+flr(#a/2)]
			fx_emote(b,get_lang("revenge_"..irnd(2)))
		end
	end

	-- REDEMPTION
	if stack.redemption and not e.bad then
		local ca={id="Redemption",gain={e.type}}
		add_event(ev_backup,ca,get_card_with("redemption"))
	end

	-- ACHIEVEMENT
	if not e.bury then ach_event("frag",e) end

	-- REFILL EXECUTION
	if e.type and e.type>0 then
		local w=get_scepter(7)
		if w then	w.cd=0 end
	end



end
function mk_part(x,y)
	local p=mke(0,x,y)
	p.we=.1+rnd(.1)
	p.life=120+irnd(180)
	local ins=true
	p.upd=function(p)
		ins= ins and get_square_at(p.x,p.y)
		p.dp=p.z<=0 and DP_PIECES or DP_BG			
		
		local bnc=p.bnc or .5
		if p.z>0 and ins then
			p.z=0
			p.vz=-p.vz*bnc
			p.vx=p.vx*bnc
			p.vy=p.vy*bnc
			p.life=min(p.life,60)
			p.blink=30
			exe(p.on_impact)
		end		
	end
	return p
end
function seek_role(id)
	if not stack[id] then return nil end
	for b in all(bads) do
		if b.role==id and not b.dead and b.sq then return b end
	end
	return nil
end
function goto_fall(p,di,t)
	
	local tramp=stack.trampoline and p.bad
	
	t=t or TEMPO
	local tx=p.sq.x+DIRS[di*2+1]*SQ
	local ty=p.sq.y+DIRS[di*2+2]*SQ
	
	p.dead=nil
	
	local function fall(ev)
		p.z=p.z+1
	
		if p.dead then
			kl(ev)
			curtsy=curtsy-1

		elseif p.z>32 then
			kl(ev)
			curtsy=curtsy-1
			if tramp then
				add(events,bind(ev_trampoline,p),1)
				del(bads,p)
				return
			end
			if p.type==5 and not p.bad then
				xpl_king(p)
			else
				xpl(p)
			end
			
		end

	end
	local function f()	
		if p.dead then return end
		sfx("fall")
		curtsy=curtsy+1
		p.dp=DP_BG
		p.falling=true
		loop(fall)	
	end

	mvt(p,tx,ty,t)
	wait(t,f)	-- call f() with a wait bc mvt can be canceled by death 

	

end
function is_reapable(e)
	if not e.bad then return false end
	return e.reap or (e.type==0 and stack.pawnreap)
	--[[
	local type=e.type
	if type==11 then type=1 end
	if type>0 and type<=4 then return true end	
	if type==0 and stack.pawnreap then return true end
	--]]
	--return false
end
function is_imprisoned(p)	
	if not p.prison or not p.sq or not p.bad then return false end
	local a=get_zone(p.sq,1)
	for sq in all(a) do				
		if sq.p and sq.p.type==p.prison then  return true end
	end
	return false
end
function inflict(e,sta,n)
	if sta=="bleed" and e.vampire then return end
	e[sta]=n or 1
end
function get_allies()
	local a={}
	for p in all_pieces() do
		if not p.bad and p~=hero then
			add(a,p)
		end
	end 
	return a
end

-- COLOR PIECE
function pal_piece(e)
	colorize_piece(e)
	pal_z(e)
	if e.c_detect then
		if t%4<2 then apal(1) end
	end
	if e.c_flh and t%6<3 then	
		apal(4)
		pal(1,3)
	end
	if e.c_protect then	pal(1,2) end
	if e.c_warn and t%6<3 then
		apal(5)		
	end
	if e.c_fade_in then
		pal_inc(-(e.c_fade_in*3/TEMPO))	
	end


	-- SELECTION
	if e.sel_rover then
		pal(1,5)
	elseif e.not_selectable  then
		pal(1,3)
	end
	if e.ui_show and t%12<6 then
		pal(1,5)
	end

	
	if e.hypno then pal(2,5) pal(1,5) pal(3,5) end
	if e.c_carry then
		for i=1,4 do pal(i,sget(i,e.bad and 13 or 15)) end
	end
	
	if e.hopped_on and hero.hop and e.bad then
		pal(1,2 )
	end
	
end
function colorize_piece(e)

	local dis=e.disguised and ( t%6>=3 or not e.c_promoted) 
	local bad=e.bad
	if e.c_convert and t%6<3 then bad = not bad end
	if (not bad or e.black) and ( not e.c_bishop_mute or t%6<3) and not dis then
		pal(1,4)
		pal(4,2)
		pal(3,1)
		pal(2,3)
		if (e.c_burning and e.c_burning>30)  then
			pal(4,5)
			pal(3,5)
		end		
	end
	if e.c_suck then		
		pal(4,5)
		pal(3,5)
	end
	
	
	if e.c_hit and t%6<3	then pal(1,5) end
end
function pal_z(e)
	if e.z>8 then pal_inc(-min((e.z-8)/8,4)) end
end

-- BOSS
function boss_turn()
	boss.ci=(boss.ci or 1)+1
	
	-- BUILD ACTION LIST
	local a={"mov","mov"}
	if stack.royal_promote then	add(a,"prom")	end
	
	--
	local pawns=get_pieces(0)
	
	
	local aid=a[1+boss.ci%#a]	
	if #pawns==0 then aid="guards" end
		
	if aid=="mov" then
		return false
	end	
	if aid=="prom" then
		sfx("regal_ascent")
		boss.c_talk=60
		
		local p=steal(pawns)
		local function light_piece()
			sfx("regal_light")
			local tempo=30				
			local r=7.5
			local light=mke(0,p.x,p.y-1)
			light.upd=function(e)
				if e.t%3==0 then
					local kx=e.x+r
					local p=mke(0,e.x+rnd(16),e.y+rnd(48)-32)
					p.we=-.05-rnd(.05)
					p.life=30
					p.blink=10
					p.z=0
					p.dp=DP_FX
					p.frict=.96
					p.dr=function(e,x,y)
						if abs(e.x-kx)< (light.cr or 0) then
							pset(x,y,4)
						end
					end
				end
				
			end
			light.z=0
			light.dr=function(e,x,y)
				local c=min(e.t/tempo,1)
				if e.rev then c=1-c end
				local cr=c*r
				light.cr=cr
				blend_light(5,1+cyc(2,3))
				rectfill(x+r-cr,0,x+r+cr,y+16,5)
				blend_light()
				if c==0 then kl(e) end
			end
			local function f()
				light.rev=1
				light.t=0
				wait(tempo,opp_move)
			end
			local function promote()
				direct_event(f,ev_promote,p)
			end			
			wait(tempo,promote)
		end
		fx_emote(boss,lang.regal_ascent)
		wait(60,light_piece)
		return true
	end
	if aid=="guards" then
	
		local ca={id="Royal Guards",gain={0,0,0}}
		add_event(ev_backup,ca)
	
		sfx("call_guards")
		boss.c_talk=60
		fx_emote(boss,lang.royal_guards)
		wait(60,opp_move)
		
		
		return true
	end

end
function dark_bishop_turn() 

	-- ACTIONS
	local army={1,0,3,1,0,3,1,0,3,1,0,2}
	local army_pos={
		0,-1, 1,-1, 2,-1,
		2,0,2,1,2,2,
		1,2,0,2,-1,2,
		-1,1,-1,0,-1,-1, 
	}
	local army_index=0
	local function spawn_army()
		if army_index==#army then
			opp_move()
			return
		end
		
		local px=boss.sq.px+army_pos[army_index*2+1]
		local py=boss.sq.py+army_pos[army_index*2+2]

		local sq=gsq(px,py)
		if is_free(sq) then 
			local p=new_piece(army[army_index+1],true,sq)
			fx_spawn(p)
		end
		army_index=army_index+1
		wait(10,spawn_army)
	end
	local function summon(n)
		if #bads==1 then
			spawn_army()
		else
			local a={}
			for sq in all(squares) do
				if is_free(sq) and sq.wdist>1 then add(a,sq) end
			end
			if #a>0 then
				local p=new_piece(2,true,steal(a))
				fx_spawn(p)
			end
			wait(30,opp_move)
		end
	end
	local function heal()
		sfx("healing")
		for b in all_bads() do
			if b.hp < b.hp_max then
				b.hp=b.hp+1
				fx_emote(b,"heart")
			end			
		end
		wait(60,opp_move)
	end

	boss.ci=boss.ci and boss.ci+1 or 0
	local tempo=2
	if boss.ci%tempo==0 then
		local k=flr(boss.ci/tempo)%2
		local kk=(flr(boss.ci/(tempo*2)))%2		
		local a={bind(summon,kk),heal}		
		boss.c_read_book=120
		wait(boss.c_read_book,a[k+1])		
		wait(20,sfx,"incantation")
		return true
	else
		return false
	end

end
function dr_boss(e,x,y)

	local mouth_co=0
	if e.c_eat then
		mouth_co=1-max(e.c_eat/30-2 ,0)
		mouth_co=ease_in_out(mouth_co)
		if e.c_eat<20 then
			mouth_co=e.c_eat/20
		end
	end	
	if e.hand_full and e.c_eat and e.c_eat<60 then
		e.hand_full=false
	end

	local function draw_face(n)
	
		sspr(208,80,16,16,x+8,y-20-mouth_co*2)
	
		for i=0,2 do
			local a=e.an+(i-1)*.075
			if (a+n)%1<.5 then
			
				local px=x+cos(a)*9+16.5
				local py=y+sin(a)*(4-mouth_co*4)-6.5
				
				-- MOUTH
				if i==1 then		
					if e.c_eat then
						sspr(120+8*round(mouth_co*4),24,8,8,px-4,py)						
						if e.c_eat<60 then
							local c=max((e.c_eat-30)/30,0)
							clip(x+12,y-25,8,23)
							local x,y=x+12,e.y+8-30*sqrt(c)
							dr_boss_target(x+4,y+10)
							clip()
						end
					elseif e.c_talk then
						sspr(109+cyc(2,6)*4,24,4,8,px-2,py+1)
					else
						sspr(105+(e.c_hit and 4 or 0),24,4,8,px-2,py+1)
					end	
				
				-- EYES
				else					
					sspr(101,e.c_hit and 28 or 24,4,4,px-2,py-2)					
				end
			end
		end		
	end
	
	draw_arms(e,x,y,.5)
	draw_face(.5)
	pal_piece(e)
	if e.crumble then
		spritesheet("crumble")
		sspr(e.crumble*32,0,32,48,x,y+PDY-18)
		spritesheet("gfx")
	else
		sspr(224,80,32,48,x,y+PDY-18)
	end
	draw_face(0)
	draw_arms(e,x,y,0)

end
function dr_dark_bishop(e,x,y)
	
	local hy=-17
	if e.c_hit then hy=hy-sin(max(e.c_hit-15,0)/30)*2 end
	
	local function draw_face(n)
		for i=0,1 do
			local a=e.an+(i*2-1)*.085
			local px=x+cos(a)*4+16.5
			local py=y+sin(a)+hy+4.5		
			if (a+n)%1<.5 then		
				local fr=112
				if (e.an-.25)%1<.5 then fr=116 end
				if e.c_hit and i==0 then fr=fr+8 end
				sspr(fr,16,4,6,px-2,py-2)		
			end
		end		
	end
	local function draw_book(n)
				
		if (e.an+n)%1<.5 then		
			local ax=x+cos(e.an)*7+15.5	--10
			local ay=y+sin(e.an)*4+9.5
			ax=ax+.5+cos(t/210)*2
			ay=ay+.5+cos(t/173)*2
			ay=ay+e.z*1.5
			
			if e.c_read_book then
				local c=sin(e.c_read_book/240)
				ay=ay-pow(c,.5)*16	
				if c>.5 and t%6<3 then
					apal(4)
				end
			end			
			
			local fr=flr(3-e.an*12+.166)%12
			sspr((fr%6)*20,197+flr(fr/6)*23,20,23,ax-10,ay-12)
			pal_rst()
			
		end
	end
	
		
	e.book=true
	draw_face(.5)
	draw_arms(e,x,y+4,.5)
	draw_book(.5)
	
	pal_piece(e)
	sspr(144,160,32,32,x,y-1)	
	local fr=flr(e.an*16+.125)%16
	sspr((fr%8)*18,155+flr(fr/8)*21,18,21,x+7,y+hy)	-- HEAD
	
	draw_book(0)
	draw_arms(e,x,y+4,0)
	draw_face(0)
	
	
end
function draw_arms(e,x,y,n)
	
	for i=0,1 do
		local a=e.an+(i*2-1)*.25
		local a2=a
		if e.book then
			a2=e.an+(i*2-1)*.1
		end
		
	
		
		if (a+n)%1<.5 then
		
			-- SHOULDERS
			local sx=x+cos(a)*8+15.5
			local sy=y+sin(a)*4+1.5

			-- ARMS
			local ax=x+cos(a2)*10+15.5
			local ay=y+sin(a2)*4+12.5-3
			if e.book then
				ax=ax+.5+cos(t/210)*2
				ay=ay+.5+cos(t/173)*2
				if e.c_read_book then
					local c=e.c_read_book/120
					ay=ay-pow(sin(c/2),.5)*16
				end		
			else
				ax=ax+.5+cos(i/2+t/210)*2
				ay=ay+.5+cos(i/2+t/173)*2+sin(i/4+t/344)*3
			end
			ay=ay+e.z*1.5

			if e.c_take and (e.hi and i==e.hi or not e.hi and n==0) then
				e.hi=i
				local trg=e.target--get_hero_trg()
				local c=e.c_take/40
				local tx,ty=trg.x+8,trg.y+8
				local cu=ease_uturn(c)
				ax=ax+(tx-ax)*cu
				ay=ay+(ty-ay)*cu
				if not trg.dead and c<=.5 then
					leave_sq(trg)
					kl(trg)
					e.hand_full=true
				end					
			end
			if e.c_eat and i==e.hi then
				local c=max((e.c_eat-30)/60,0)		--90
				local tx,ty=e.x+16,e.y-12
				local cu=ease_uturn(c)
				ax=ax+(tx-ax)*cu
				ay=ay+(ty-ay)*cu
			end
			
			-- ELBOWS
			local ix,iy,jx,jy=sx,sy,ax,ay
			if i==1 then
				ix,iy,jx,jy=jx,jy,ix,iy
			end
			if ay<sy then
				ix,iy,jx,jy=jx,jy,ix,iy
			end
			local ex,ey=inv_kin(ix,iy,jx,jy,7,7)	--6,6
			
			
			local cl=((a-.125)%1)<.5 and 4 or 3
			if e.dark then cl=cl-2 end
			
			local function dr()
				line(sx,sy,ex,ey,cl)
				line(ex,ey,ax,ay,cl)
				circfill(ax,ay,2,cl)
			end
			brd(dr,e.c_hit and t%6<3 and 5 or (e.dark and 4 or 1))
	
			pax,pay=ax,ay
			if e.hand_full and n==0 then
				dr_boss_target(ax,ay)
			end
			
			-- BOW
			if hero and e.bow and i==0 then
				local s=sgn(hero.x-ax)
				if is_bow_ready(e) then
					ssspr(152,63,14,17,ax-8,ay-8,s)
				else
					ssspr(145,63,7,17,ax-2,ay-8,s)
				end
			end
			
			-- BUCKLER
			if e.armorgap and i==1 then 
				sspr(178,63,11,11,ax-3,ay-3)
			
			end
			
			
			
			--pset(sx,sy-1,cl)

			--[[
			local px=x+cos(a)*9+16.5
			local py=y+sin(a)*4-6.5
			if i==1 then
				sspr(105+(e.c_hit and 4 or 0),24,4,8,px-2,py+1)
			else
				sspr(101,24,4,4,px-2,py-2)
			end
			--]]
			
		end
	end	

end
function gsq_zone(sq)
	local a={sq}
	local b={0,1,4}
	for di in all(b) do
		local sq=dsq(sq,di,1)
		add(a,sq)
	end
	return a	
end
function xpl_boss()
	boss.dp=DP_FX
	_music(nil,0,nil,1)
	
	local function flash(k)
		
		if k==4 then				
			if SET.scrflash==1 then
				fd=4
				fade_to(0,16)		
			end
			leave_sq(boss)
			kl(boss)
			del(bads,boss)	
			sfx("boss_crumble")
			if boss.book then
				dark_bishop_up()
			else
				if boss.big then
					local e=mke(0,boss.x,boss.y)
					e.z=0
					e.life=120
					e.blink=30
					e.dr=function(e,x,y)
						spritesheet("crumble")
						k=min(2+flr(e.t/6),19)
						sspr((k%10)*32,flr(k/10)*48,32,48,x,y+PDY-18)
						spritesheet("gfx")			
					end			
				else
					boss.boss=nil
					boss.soul_fx=true
					xpl(boss)
					
					
				end
				wait(60,mode.on_boss_death)
			end
			
			return
		end	
		sfx("flash_boss")
		boss.c_hit=40
		boss.c_shake=8
		inter.c_screen_shake=4
		boss.crumble=boss.crumble and boss.crumble+1 or 0
	
		local a={}
		local pmax=k*3
		for i=1,pmax do
			local an=(i+rnd(1))/pmax

			local md=MCW
			

			--local va=1/100*(irnd(2)*2-1)
			--local fa=.9+rnd(.085)
			local dd=ease_out(rnd(1))
			if not boss.big then dd=dd*.5 end
			local tempo=30+irnd(30)
			
			--local x,y=boss.x+8,boss.y+8
			
			local e=mke(0,boss.x+(boss.big and 16 or 8),boss.y+8)
			--add_child(boss,e)
			e.dp=DP_INTER
			e.life=tempo
			e.dr=function(e,x,y)

				local c=e.life/tempo
				local da=ease_in(c)/16			
				
				
				local	ax=x+cos(an+da)*6*dd
				local	ay=y+sin(an+da)*16*dd
				local	bx=x+cos(an-da)*6*dd
				local	by=y+sin(an-da)*16*dd	
				
				local	cx=ax+cos(an+da)*md
				local	cy=ay+sin(an+da)*md
				local	dx=bx+cos(an-da)*md
				local	dy=by+sin(an-da)*md
			
				local cl=5
				if SET.scrflash==1 then
					cl=rnd(1)<c and 5 or 4
				end
				
				trifill(ax,ay,bx,by,cx,cy,cl)
				trifill(bx,by,cx,cy,dx,dy,cl)
				
				target(OVERLAY_SURF)
				trifill(ax*2,ay*2,bx*2,by*2,cx*2,cy*2,OVERLAY_TKEY)
				trifill(bx*2,by*2,cx*2,cy*2,dx*2,dy*2,OVERLAY_TKEY)
				target()
			

			end

					
		end
		wait(80,bind(flash,k+1))
	end
	
	
	flash(1)
	
	
	
end
function spawn_dark_bishop()

	-- FALL
	local function fall()
		
		local a={}
		for sq in all(squares) do
			local b=gsq_zone(sq)
			local ok=#b==4 and sq.px>0 and sq.py>0 and sq.px<6 and sq.py<6
			for nsq in all(b) do
				if nsq.p then ok=false end
			end
			if ok then add(a,sq) end
		end
		custom_sort(a,function(sq) return -sq.wdist end)
		
		local tsq=a[1]
		
		local e=new_piece(6,true,tsq)
		e.alt_move=dark_bishop_turn
		e.dark=true
		e.dr_skin=dr_dark_bishop
		
		e.tempo=2
		e.cd=get_piece_tempo(e)
		fx_spawn(e)
		wait(60,bind(clean_up,refill_ammo))
		start_music("boss_A")
	end
		
	-- ASCEND
	local function ascend(ev)
		local c=ev.t/120	
		chosen.z=-32*c*c
		if ev.t+30==120 then
			chosen.life=30
			chosen.blink=30
		end
		del(bads,chosen)
		chosen.sq.p=nil
	end
	
	-- SHOW BOOK
	local function book_spawn()
		local book=mke(0,1,4)
		book.dr=function(e,x,y)
			if e.t>30 or t%6<3 then 
				sspr(80,56,6,8,x,y)
			end
		end
		add_child(chosen,book)
		local function asc()
			sfx("ascend")
			loop(ascend,120,bind(wait,30,fall))
		end
	
		fx_emote(chosen,lang.black_bishop_warcry,60)
		sfx("alleluia",.5)

		wait(90,asc)
	end
	local function book_light(ca)

		local e=mke(0,ca.x+10,ca.y+14)
		e.dr=function(e,x,y)
			local r=max(12-e.t/2,0)
			circfill(x,y,r+rnd(3),3+t%3)
		end
		local function f()
			kl(e)
			book_spawn()
		end		
		mvt(e,chosen.x+8,chosen.y+8,120,f)
		e.twcv=ease_in_out
	end

	-- GO
	local ca=get_slot_card("The Red Book")
	if ca then
		sfx("show_book")
		ca.life=120
		ca.blink=120
		wait(60,book_light,ca)
		ca.sl.ca=nil
		build_stack()
	else
		book_spawn()
	end

	


end
function dark_bishop_up()

	fx_dust(144,160,32,32,boss.x,boss.y)
	fx_dust(0,155,18,21,boss.x+7,boss.y-17)

	local e=mke(0,boss.x+16,boss.y+32)
	
	e.z=0
	local ec=4
	local r=16
	local by=0
	
	
	e.upd=function(e)
		by=e.y+cos(t/60)*ec-26.5
		if e.t>60 then
			ec=ec*.95
			local c=(e.t-60)/180
			by=by-c*c*e.y
		end		
		
		if e.t==68 then
			sfx("book_float",.5)
		end
		if e.t==250 then
			exe(mode.on_boss_death)
		end		
		if e.t>240 then
			r=r*.95
			if r<.25 then
				kl(e)
				
			end
		end
	end
	
	
	e.dr=function(e,x,y)

		if t%2==0 then
			rectfill(x-r,0,x+r-1,y-1,4+cyc(2,3))
		end
		if t%6>=3 then apal(4) end
		sspr(0,200,20,20,x-10,by)
		pal_rst()
	end



end
function spawn_mother_queen()
	
	local function go_play()
		clean_up(refill_ammo)
		
	end
	
	local function my_love()
		local p=fx_emote(chosen,lang.my_love,120,go_play)
		start_music("boss_queen_A")
		kl(chosen)
		
		local p=new_piece(10,true,chosen.wsq)
		p.c_spawn=60		
		
	end
	
	local function dialog()
		fx_emote(chosen,lang.come_to_me,120,my_love) --
	end
	
	wait(60,dialog)
	
	
end
function spawn_horsemen()
	--log("spawn_horsemens !!")
	fast_tracker(false)
	boss=nil
	local names={ lang.apo_name_0, lang.apo_name_1, lang.apo_name_2, lang.apo_name_3 }	
	local apo=get_pieces(11)
	shuffle(apo)
	local tempo=60
	for i=1,#apo do		
		local e=apo[i]
		local function chk(sq) return is_free(sq) end
		local a=get_zone(e.sq,2,chk)
		local sq=steal(a)		
		
		local p
		if i==4 and hero.disguised==0 then
			p=hero
		else		
			p=new_piece(0,true,sq)
			p.c_raise=tempo
		end
		
		e.pawn=p
		
	end	
	
	local apo_index=1
	local h=apo[4]
	
	local function talk(s,nxt)
		_sfx("king_talk",-1,1,nil,1+rnd(.1))
		h.ta=.25
		fx_emote(h,s,60,nxt)
	end	
	local function run_away(h)

		local function f()
			kl(h)
			music("ending_A",0)
			fade_to(-4,30,mode.outro)	
			
			-- NEED BETTER CLEAN STRATEGY
			if seer then kl(seer) end

		
		end
	
		local function move()
			h.ta=0
			mv(h,64+16,0,80,f)
			h.twcv=ease_in_back
			h.c_smoke=80
			_sfx("charge",-1,1,nil,.6)
		end

		wait(30,talk,lang.apo_threat_4,move)
		h.ta=.25
		
		
	end
	local function kill_others()
	
		
		del(apo,h)
		local index=0
		local function threat(nxt)
			talk(get_lang("apo_threat_"..index),nxt)
			index=index+1
		end
		
		local function kill_next()
			
			if #apo==0 then
				local csq=gsq(3,3)
				h.ta=atan2(csq.x-h.x,csq.y-h.y)
				goto_sq(h,csq,60,bind(run_away,h))
				return 
			end
			
			local trg=steal(apo)
			trg.fast_soul=1
			h.ta=atan2(trg.x-h.x,trg.y-h.y)
			

			local function crush()
				xpl(trg)				
				local tempo=30
				wait(tempo,bind(threat,kill_next))	
				local function landing(ev)
					local c=ev.t/tempo
					h.z=(c-1)*10-sin(c/2)*12
				end
				loop(landing,tempo)

			end
			h.crusher=true
			wait(16,goto_sq,h,trg.sq,TEMPO,crush)

		end
		
		
		
		
		wait(60,bind(threat,kill_next))
		
			
	
	end
	local function goto_corners()
	
		local corners={gsq(0,0),gsq(0,7),gsq(7,7),gsq(7,0)}
		
		-- REMOVE IF ALREADY IN PLACE
		for e in all(apo) do			
			for sq in all(corners) do
				if e.sq==sq then
					del(apo,e)
					del(corners,sq)
				end			
			end		
		end
		
		-- CHANGE IF CORNER IS OCCUPIED
		for sq in all(corners) do
			if not is_free(sq) then
				del(corners,sq)
				local free={}
				for osq in all(squares) do if is_free(osq) then add(free,osq) end end
				local function f(osq) return dist(osq,sq) end
				custom_sort(free,f)
				add(corners,free[1])		
			end
		end

		-- ALL APO MOVE
		for e in all(apo) do	
			local function f(sq) return dist(e.sq,sq) end
			custom_sort(corners,f)
			local tsq=corners[1]
			del(corners,tsq)			
			goto_sq(e,tsq,TEMPO)			
		end
		
		-- START
		local function start()
			start_music("boss_riders_A")
			clean_up(refill_ammo)
		end
		wait(TEMPO,start)

	end
	local function jump()
		if apo_index>4 then
			apo_index=1
			if apo[4].pawn==hero then 
				kill_others()
			else
				goto_corners()
			end
			return
		end
		local e=apo[apo_index]
		
		if not e.pawn.named then
			sfx("apo_talk")
			e.pawn.named=true
			e.pawn.c_detect=60
			local s=names[1]
			del(names,s)
			fx_emote(e.pawn,s,60,jump)
			return
		end
		
				
		sfx("apo_jump")
		local sq=e.sq	
		local function f()
			sfx("apo_sit")
			e.give_role()
			kl(e.pawn)
			del(bads,e.pawn)
			goto_sq(e,sq,0)			
			wait(30,jump)
			
			if e.pawn==hero then 
				e.an=hero.an
				e.ta=hero.an
				hero.sq=hero.wsq 
				hero.disguised=nil
				hero.apo=1
				e.black_king=1
				
			end
			
			
		end		
		leave_sq(e)
		goto_sq(e.pawn,sq,TEMPO,f)
		
		apo_index=apo_index+1
		
	end
		
	wait(tempo,jump)
	
end
function storm_all_but(e,nxt)

	music()
	local a= e.list and e or {e}
	for e in all(a) do
		chosen=e
		e.chosen=true
	end	
	custom_sort(bads,function(e) return e.chosen and 1 or 0 end)	
	storm( bind(wait,30,nxt) )	
	
	
	
	
end
function dr_boss_target(ax,ay)
	local e=boss
	if e.target==hero then
		sspr(96,72,9,17,ax-4,ay-10)
		sspr(73,61,1,2,ax,ay-4)
	else
		pal_piece(e.target)
		sspr(e.target.type*16,432,16,16,ax-8,ay-10)
		pal()
	end				
end


-- TOOLS
function get_pieces(type)
	local a={}
	for b in all(bads) do
		if b.type==type then add(a,b) end
	end
	return a
end
function has_card(id,chk_flip) 
	for sl in all(card_slots) do
		if sl.ca then 
			if sl.ca.id==id then 
				return not chk_flip or not sl.ca.flipped 
			end
		end
	end
	return false
end
function get_slot_card(id) 
	for sl in all(card_slots) do
		if sl.ca and sl.ca.id==id then 
			return sl.ca
		end
		for k,v in pairs(sl.ca or {}) do
			if k==id then return sl.ca end
		end
	end
end
function get_nb_cards(team) 
	local nb=0
	for sl in all(card_slots) do
		if sl.ca and sl.team==team then
			nb = nb + 1
		end
	end
	return nb
end
function tear_apart(ca,nxt)

	if type(ca)=="string" then
		ca=get_slot_card(ca)
	end
	
	
	
	
	if ca then 
		-- FX
		local function cut()
			kl(ca)
			ca.sl.ca=nil
			for i=0,1 do
				local e=mke(0,ca.sl.x,ca.sl.y-1)
				e.dp=DP_INTER
				e.dr=function(e,x,y)
					
					local bx=(ca.gid%10)*24
					local by=flr(ca.gid/10)*32
					spritesheet(ca.spsheet or "cards")
					
					for k=0,1 do
					
						local sdy=(1-k)*20
					
						for dx=0,21 do for dy=sdy,28 do
							if min(sget(240+dx,dy)-1,1)==i then							
								if k==0 then
									pset(x+dx+2,y+dy+2,bright(pget(x+dx,y+dy),-1))
								else						
									pset(x+dx,y+dy,sget(bx+dx,by+dy))
								end
							end					
						end end
			
					end
				
					
					--sspr(,flr(ca.gid/10)*32,24,32,x,y)
					spritesheet("gfx")
					
				end
				e.life=40
				mv(e,(i*2-1)*8,0,e.life)
				e.twcv=ease_in
				e.blink=8
				if i==0 and nxt then e.nxt=bind(nxt,ca) end				
			end

			build_stack()

		end		
		for i=-1,1 do
			local e=mke(0,ca.sl.x+i+.5,ca.sl.y)
			e.dp=DP_INTER
			e.dr=function(e,x,y)
				spritesheet("cards")
				palt(1,true)
				palt(2,true)
				pal(3,5)
				sspr(240,0,22,29,x,y)
				palt()
				spritesheet("gfx")
			end
			mv(e,-i,0,4)
			e.life=8
		end
		wait(12,cut)
		sfx("tear_up",.5)

	else
		exe(nxt)	
	end
	
	-- ??? 
	for ca in all(get_all_cards(true)) do
		if ca.id==id then
			del(cards,ca)
		end
	end
	

	
	
	
end
function replace_card(a,b,nxt)

	local function f(oca)	
		sfx("replace_card")
		local ca=new_card(b)
		ca.x=oca.x-8
		ca.y=oca.y-8
		ca.c_fade_in=16
		inc_stats(ca.id,true)
		add_card(ca,nxt)	
	end


	tear_apart(a,f)
end
function get_nearest_piece(sq)
	local best,dist
	for b in all_bads() do
		local dx=sq.x-b.sq.x
		local dy=sq.y-b.sq.y
		local d=sqrt(dx*dx+dy*dy)
		if not best or d<dist then
			best,dist=b,d
		end	
	end
	return best
end
function get_nei_with(e,k)
	for di=0,7 do
		local sq=dsq(e.sq,di)
		if sq and sq.p and sq.p[k] then 
			return sq.p
		end
	end
	return nil
end



-- HDIST
function trace_heros_dists()
	if not hero then return end


	local hsq=get_hero_sq()

	-- WALK DIST
	local function gnx(sq) 
		local a={}
		for di=0,3 do 
			local sq=dsq(sq,di)
			if sq and (not sq.p or sq.p.type==6) then add(a,sq) end
		end	
		return a
	end
	trace_hdist("wdist",{hsq},gnx)
	
	
	local function seek_lines(sq,a,b,dmin,dmax)
		dmin=dmin or 1
		dmax=dmax or 12
		local res={}
		for di=a,b do for k=dmin,dmax do
			local sq=dsq(sq,di,k)
			if is_free(sq) then 
				add(res,sq) 
				if sq.moat then break end
			else
				if not (sq and fly) then break end
			end
		end	end
		return res
	end
	
	-- ROOK DIST
	local function gnx(sq)
		return seek_lines(sq,0,3,stack.rook_minr,12)
	end 
	trace_hdist("rdist",{hsq},gnx)
	
	-- QUEEN DIST
	local function gnx(sq)
		return seek_lines(sq,0,7,stack.queen_minr)
	end 
	trace_hdist("qdist",{hsq},gnx)

	-- BISHOP DIST
	local function gnx(sq)
		return seek_lines(sq,4,7,stack.bishop_minr)
	end 
	trace_hdist("bdist",{hsq},gnx)
		
	-- KNIGHT DIST
	local function gnx(sq) 
		local a={}
		for di=0,7 do 
			local nx=sq.px+KNIGHT_MOVES[di*2+1]
			local ny=sq.py+KNIGHT_MOVES[di*2+2]
			local sq=gsq(nx,ny)
			if is_free(sq) then add(a,sq) end
		end	
		return a
	end
	trace_hdist("kdist",{hsq},gnx)
	
	-- GUARD DIST
	local a={}
	for b in all(bads) do
		if b.type==leader then
		 add(a,b.sq)
		end
	end
	local function gnx(sq) 
		local a={}
		for di=0,3 do 
			local sq=dsq(sq,di)
			if sq and (not sq.p or sq.p.type==6) then add(a,sq) end
		end	
		return a
	end
	if #a>0 then	
		trace_hdist("gdist",a,gnx)
	end
	
	
	-- DIAG DIST
	local function gnx(sq) 
		local a={}
		for di=0,7 do 
			local nx=sq.px+DIRS[di*2+1]
			local ny=sq.py+DIRS[di*2+2]
			local sq=gsq(nx,ny)
			if sq then add(a,sq) end
		end	
		return a
	end
	trace_hdist("ddist",{hsq},gnx)
	
	
	-- GRENADE
	for sq in all(squares) do	
		sq.risk=0
		if sq.grenade then
			local a={sq}
			for di=0,7 do
				local nsq=dsq(sq,di,1)
				add(a,nsq)
			end 
			for sq in all(a) do
				sq.risk=5
			end
		end
	end


	-- DOUBT DIST
	if hero.cloaked and hero.disguised then
		local a={hsq}
		for b in all(bads) do if b.type==hero.disguised then add(a,b.sq) end end
		trace_hdist("doubt_dist",a)
	end

	
	
	-- COVER
	--trace_cover()
	
	

end
function trace_hdist(key,start,gnx)
	gnx=gnx or function(sq) 
		local a={}
		for di=0,3 do 
			local sq=dsq(sq,di)
			if is_free(sq) then add(a,sq) end
		end	
		return a
	end
	for sq in all(squares) do sq.dist=99 sq[key]=99 end
	local work={}

	local function ins(sq,n)
		sq.dist=n
		sq[key]=n
		add(work,sq)
	end	
	for sq in all(start) do ins(sq,0) end
	
	while #work>0 do
		local sq=work[1]
		del(work,sq)
		for nsq in all(gnx(sq)) do
			if nsq.dist>sq.dist+1 then
				ins(nsq,sq.dist+1)
			end		
		end
	end	
	
end
function trace_cover()
	for sq in all(squares) do sq.cover=0 end
	for sq in all(squares) do
		local a=bres_2(hero.sq.px,hero.sq.py,sq.px,sq.py)			
		for i=2,#a do
				local p=a[i]
				local osq=gsq(p.x,p.y)
				if osq.p and osq.p.type~=5 then
					sq.cover=sq.cover+osq.p.hp				
				end
			end
	end
end
function trace_all_piece_dist()
	if not hero then return end
	for e in all(bads) do trace_piece_dist(e) end
end
function trace_piece_dist(e)
	
	local dgr={}
	e.dgr=dgr
	
	if not hero or not hero.sq then return end
	

	local function ifr(sq)
		return sq and (is_free(sq) or sq.p==e)
	end
	local gnx=function(sq) 
		local a={}
		for di=0,3 do 
			local sq=dsq(sq,di)
			if ifr(sq) then add(a,sq) end
		end	
		return a
	end
	local function seek_lines(sq,a,b,dmin,dmax)
		dmin=dmin or 1
		dmax=dmax or 12
		local res={}
		for di=a,b do for k=dmin,dmax do
			local sq=dsq(sq,di,k)
			if ifr(sq) then 
				add(res,sq) 
				if sq.moat then break end
			else
				if not (sq and fly) then break end
			end
		end	end
		return res
	end	
	
	if e.seek=="bdist" then
		gnx=function(sq)
			return seek_lines(sq,4,7,stack.bishop_minr)
		end 
	end	
	if e.seek=="rdist" then
		gnx=function(sq)
			return seek_lines(sq,0,3,stack.rook_minr,12)
		end 
	end
	if e.seek=="qdist" then
		gnx=function(sq)
			return seek_lines(sq,0,7,stack.queen_minr)
		end 
	end
	if e.seek=="kdist" then
		gnx=function(sq)
			local a={}
			for di=0,7 do 
				local nx=sq.px+KNIGHT_MOVES[di*2+1]
				local ny=sq.py+KNIGHT_MOVES[di*2+2]
				local sq=gsq(nx,ny)
				if ifr(sq) then add(a,sq) end
			end	
			return a
		end 
	end

	
	for sq in all(squares) do dgr[sq]=99 end
	local work={}
	local function ins(sq,n)
		dgr[sq]=n
		add(work,sq)
	end	
	ins(get_hero_sq(),0)
	
	while #work>0 do
		local sq=work[1]
		del(work,sq)
		for nsq in all(gnx(sq)) do
			if dgr[nsq]>dgr[sq]+1 then
				ins(nsq,dgr[sq]+1)
			end		
		end
	end	
	
end

-- FX
function fx_shield(e)
	local e=mke(0,e.x-1,e.y-5)
	e.life=16
	e.dp=DP_FX
	e.dr=function(e,x,y)
		sspr(e.t*17,128,17,25,x,y)
	end	
end
function fx_emote(e,str,life,nxt)
	local p=mke(0,e.x+8,e.y+(e.z or 0))
	if e.big then
		p.x=p.x+8
		p.y=p.y-8
	end
	p.vy=-2
	p.frict=.85
	p.life=life or 60 -- was 30
	p.dp=DP_FX
	p.upd=function()
		if p.sus and p.t%30==0 then str=str.."." end 
	end
	p.dr=function(e,x,y)
		lprint(str,x,y,4,1,1)

	end
	p.nxt=nxt
	
	if str=="heart" then
		p.dr=function(e,x,y)			
			sspr(87,56,9,8,x-5,y-4)
		end
		e.frict=.75
		p.life=60
		p.blink=30
	
	end
	
	
	return p
end
function fx_screen_flash(k,t,key)
	key=key or "flash"
	local function f(ev)
		local c=1-ev.t/t		
		shdrf(key,k*c)		
	end	
	loop(f,t)

	

end
function fx_trg(e,s)

	local hx,hy=get_center(e)
	local e=mke(0,hx,hy)	
	e.dp=DP_FX
	local tempo=8
	e.life=tempo
	e.dr=function(e,x,y)	
		local c=.5-(e.t/tempo-.5)*s
		c=ease_in(c)
		circ(x,y,5+16*c,5)
	end	
end
function fx_cart(vx,vy)
	local e=mk_part(hero.x+8,hero.y+8)
	e.z=-2
	e.vz=hrnd(1)-2.5
	e.bnc=.75
	if e.vx then
		e.vx,e.vy=vx,vy or 0
	else
		impulse(e,rnd(.75),rnd(.75))
	end
	
	
	local an=rnd(1)
	local va=hrnd(.25)
	local fra=.9
	local oupd=e.upd
	e.upd=function(e)
		oupd(e)
		an=an+va
		va=va*fra
	end
	e.on_impact=function()
		local avz=abs(e.vz/10)
		va=hrnd(avz)
		_sfx("shell_ground",-1,avz/2,0,1+rnd(.05))
	end
	e.dr=function(e,x,y)
		--brd(bind(aspr,53,x,y,an,5/16,8/16),1)	--5 8
		brd(bind(aspr,53,x,y,an,3/16,6/16),1)	--5 8
	end
	e.drs=function()
		if e.z<=0 then
			shpr(20,12,7,4,e.x-3,e.y-2)
		end
	end
end
function fx_spawn(p,shake)
	p.z=-32
	
	local tempo=20
	local f=function(ev)
		local c=ev.t/tempo
		p.z=-32*(1-ease_bounce_out(c))	
		if ev.t==9 then 
			_sfx("spawn",-1,fast and 0.25 or 1,0,1-p.type*.03)
			if shake then screen_shake(shake) end
			
		end
	end
	loop(f,tempo)	
end
function fx_detect(tempo,x,y)
	
	music("gameover",0,false)
	
	if type(x)=="table" then
		x.c_detect=tempo
		x,y=get_center(x)		
	end

	local e=mke(0,x,y)
	e.dp=DP_TOP
	e.perm=true
	e.life=tempo
	e.dr=function(e,x,y)	
		local c=pow(e.life/80,2)
		circ(x,y,4+c*120+t%3,t%4<2 and 1 or 4)
	end
	
end
function fx_dust(px,py,pw,ph,x,y)
	for dx=0,pw-1 do for dy=0,ph-1 do
		local n=sget(px+dx,py+dy)
		if n>0 then
			local p=mke(0,x+dx,y+dy)
			p.dr=function(p,x,y)
				pset(x,y,n)
			end
			local f=function()
				p.we=-rnd(.05)
				p.life=30+irnd(60)
			end
			wait( irnd(60), f)

		end
	end end
end
function fx_frame_drop(wt,frict)
	frame_drop={ wt=wt, n=wt, frict=frict }	
end
function fx_crumb(e,i)
	local p=mk_part(e.x+5+rnd(6),e.y+2+rnd(12))
	p.bad=e.bad
	impulse(p,rnd(1),rnd(1))
	p.vz=-rnd(4)
	p.z=e.z
	if e.from then
		p.vx=p.vx+e.from.vx/10
		p.vy=p.vy+e.from.vy/10
	end
	
	local px,py=24+i*8,48
	if i==6 and e.type<6 then px,py=24+e.type*8,56 end
	
	p.dr=function(p,x,y)
		colorize_piece(p)
		if i==6 and e.custom_debris then
			e.custom_debris(p, x, y)
			spritesheet("gfx")
		else
			sspr(px,py,8,8,x-4,y-4)
		end
		pal_rst()
	end
	p.drs=function()
		if p.blink and p.life<p.blink and p.t%6<3 then return end
		if p.z>0 then return end
		shpr(px,py,8,8,p.x-4,p.y-4)
	end
	return p
end
function fx_twinkle(sq,t)

	local function f(ev)
		if ev.t%12==0 then
			local p=mke(0,sq.x+rnd(SQ),sq.y+rnd(SQ))
			p.dp=DP_FX
			p.we=-(1+rnd(5))/100
			p.z=0
			p.life=30
			p.dr=function(e,x,y)
				sspr(96+cyc(2,3)*5,91,5,5,x-2,y-2)
			end
		end
	end
	loop(f,t)
end
function fx_unlock(s,params)

	params=params or {icon={x=16,y=282,w=5,h=6}}

	local ma=4
	local s=get_lang("unlocked",s)
	local iw=params.icon and params.icon.w+2 or 0
	local pw=txtwidth(s)+ma*2+iw	
	local ph=5+2*ma

	
	local e=mke(0,(MCW-pw)/2,-ph)
	e.dp=DP_INTER
	
	e.dr=function(e,x,y)
		local sz=2
		rectshade(x+sz,y+sz,pw,ph)
	
		rectfill(x,y,x+pw-1,y+ph-1,2)
		hdclear(x,y,x+pw-1,y+ph-1)
		rect(x,y,x+pw-1,y+ph-1,3)
		if params.icon then
			local i=params.icon
			if e.t<60 and e.t%6<3 then apal(5) end
			sspr(i.x,i.y,i.w,i.h,x+ma,y+ma-1)
			pal_rst()
		end
		lprint(s,x+iw+ma,y+ma,4)	
	end
	
	-- SCROLL
	mv(e,0,ph+4,16)
	e.twcv=ease_out	
	local function back()
		mv(e,0,-ph-4,16,bind(kl,e))
		e.twcv=ease_in
	end
	wait(180,back)
	
	


end
function fx_vanish(e)
	sfx("holo_vanish")
	for i=0,16 do
	
			local function pop()
				local p=mke(0,e.x+rnd(16),e.y+rnd(16))
				p.dp=DP_FX
				p.life=30+irnd(30)
				p.vx=hrnd(1)
				p.vy=-rnd(2)
				p.frict=.95
				
				local r=1+irnd(2)
				p.dr=function(e,x,y)
					fillp(0x7D7D,true)
					circfill(x,y,r,1)
					fillp()
				end	
			end
			wait(i,pop)
			
			
	
	end


end
function fx_red_flash(t)
	if SET.scrflash==0 then return end
	
	fd=6
	wait(t or 4,function() fd=0 end)

end
function fx_white_flash(t)
	t=t or 16
	if SET.scrflash==0 then return end
	
	local function f(ev)
		local c=ev.life/t
		fd=flr(c*5)
	end
	local ev=loop(f,t)
	ev.perm=true

end
function fx_magic_star(x,y)
	local p=mke(0,x,y)
	p.life=16+irnd(16)
	p.dp=DP_INTER
	local fr=irnd(4)
	p.dr=function(e,x,y)
		shpr(fr*8,64,8,8,x-3,y-3,2)
		pset(x,y,4)
	end
	p.vy=-rnd(1)
	return p
end
function fx_ground_poison(x,y,cl)

	local tempo=64

	local p=mke(0,x,y)
	p.life=tempo
	p.z=0
	local vz=(-1-rnd(1))/8
	p.upd=function(e)
		e.z=e.z+vz
		e.z=e.z*.98
	end
	p.dr=function(e,x,y)
		local c=p.life/tempo
		local r=sin(c/2)*4	
		r=1+(1-c)*5

		fillp_dissolve(1-c)		
		circfill(x,y,r,cl)
		fillp()
	end
	
end
function fx_zoom_panel(x,y,w,h,nxt)
	sfx("level_up_zoom")
	local tempo=8
	local e=mke(0,x,y)
	e.life=tempo
	e.dr=function(e,x,y)
		local c=1-e.life/tempo
		local ma=ease_in(c)*32
		rect(x-ma,y-ma,x+w+ma-1,y+h+ma-1,sget(e.life,2))
	end	
	e.nxt=nxt
			

end
function fx_talk(e,a,nxt)
	if type(a)=="string" then a={a} end
	if #a==0 then
		exe(nxt)
		return
	end

	local s=a[1]
	del(a,s)
	_sfx("king_talk",-1,1,nil,1.1+rnd(.1))
	fx_emote(e,s,60,bind(fx_talk,e,a,nxt))
end
function fx_show_piece(e,t,nxt)
	e.c_warn=t or 30
	sfx("show")
	if nxt then
		wait(e.c_warn,nxt)
	end
end
function fx_miss(x,y)
	local p=mke(0,x,y)
	p.dp=DP_FX
	p.life=48
	p.blink=16
	p.dr=function(e,x,y)
		sspr(208,233,16,7,x-8,y-3)
	end
	mv(p,0,-8,p.life)

end
function fx_dmg(e,dmg,capped)


	if e.hurt then
		e.hurt.dmg=e.hurt.dmg+dmg
		e.hurt.life=60
		e.hurt.capped=e.hurt.capped or capped
		return
	end


	local p=mke(0,e.x+8,e.y+2) 
	if e.big then
		p.x=p.x+8
		p.y=p.y-12
	end
	p.dp=DP_FX
	p.dmg=dmg
	p.capped=capped
	p.vy=-2
	p.frict=.85
	p.life=60		
	p.dr=function(p,x,y)
		local s=p.dmg>0 and (p.dmg.."") or "miss"
		--if type(s)=="number" then s=s.."" end
		
		local cl=p.capped and (3-cyc(2,3)) or 5
		if s=="miss" then
			cl=3
--			s=get_lang("miss")
		end
		fbrd(function()
			local sav = font()
			font("pico")
			lprint(s,x,y,4,1)
			font(sav)
		end,cl)
	end
	
	e.hurt=p
	p.nxt=function() e.hurt=nil end		
	
	return p
end
function fx_show_sq(sq,type)
	local e=mke(0,sq.x,sq.y)
	e.life=60
	e.blink=20
	e.dr=function(e,x,y)
		if type then
			palt(4,true)
			palt(3,true)
			pal(1,5)
			sspr(type*16,432,16,16,x,y-2)
			palt(4,false)
			palt(3,false)
			pal()			
		else
			rect(x+1,y+1,x+14,y+14,4+cyc(2,3))
		end
	end
	return e
end

--

function get_center(e)
	if e.big then
		return e.x+16,e.y+16
	else
		return e.x+8,e.y+8
	end
end

-- NEW_TURN
function init_new_turn()
	

	if hero.detected then return end
	--
	exe(mode.on_new_turn)
	
	-- INC TURN
	increase_card_turns()
	mode.turns=mode.turns and mode.turns+1 or 1
	

	
	
	-- NEW TURN checks
	for b in all(bads) do
		if b.vampire then
			add_event(bind(ev_vampire,b))		
		end
		b.censor_done=nil		
	end
	
	-- FIRST TURN ANARCHY
	if stack.anarchy and mode.turns==1 then
		local pool={}
		for b in all(bads) do if not b.promoted and not b.big then -- b.type>0 and 
			add(pool,b) 
		end end
		
		for i=1,min(#pool,2) do	
			local a={0,1,2,3,4,5}
			add_event(ev_promote,steal(pool),nil,a,get_lang("anarchy"))
		end
		
	end
	
	-- BACKUPS
	if #backups>0 then
		local ca={id="Latecomer",gain=clone(backups)}
		backups={}
		add_event(ev_backup,ca)
	end
	--
	
	new_turn()
end
function new_turn()

	fast_tracker(false)
	shields=SET.shields
	if mode.id == "tutorial" then
		shields=2
	end
	
	-- EXTRA TURN BREAK
	if hero.extra_turn and not hero.win then
		hero.extra_turn=false
		play()
		return
	end

	-- CLEAN SQUARES
	for sq in all(squares) do
		sq.plague=nil
	end
	
	-- DIST + SAFE
	trace_heros_dists()
	init_safe_mode()
	
	-- SPOTS 
	local spots={}
	local hsq=get_hero_sq()
	for sq in all(squares) do
		if is_free(sq) or hsq==sq then add(spots,sq) end
	end
	local function f(sq)
		return (sq.wdist or 0 )+#sq.danger*2  
	end
	shuffle(spots)
	custom_sort(spots,f)
	spots.get=function(lim)
		lim=lim or 3
		local index=min(irnd(lim)+1,#spots)
		local sq=spots[index]
		deli(spots,index)
		return sq
	end
	
	-- BAD READY
	local ab={}
	for e in all_pieces() do	
		if e.bad then	add(ab,e) end
		e.ready=false
		if e.cd and not e.stun and not e.mastermind and not e.npc then
			e.cd=e.cd+1
			e.ready=e.cd>=get_piece_tempo(e)
		end
		if e.ready and e.bad then
			local gr=get_piece_next_action(e)
			if not gr and not e.regret and not e.boss then 
				e.ready=false 
			end
		end
		e.hopped_on=nil
		e.airy=e.wraith and not e.ready
		if e.airy then
			local hsq=get_hero_sq()	
			for b in all(hsq.danger) do
				if b==e then e.airy=nil end
			end
		end
		
		e.curtsy,e.hurt,e.kback=nil
		
		-- COUNTERS
		local a={"poisoned","stun"}
		for k in all(a) do
			e[k]=e[k] and e[k]>1 and e[k]-1 or nil
		end
		
		-- DMG CAP
		e.dmg_cap=e.armorgap		
		if is_bow_ready(e) and not e.big then e.dmg_cap=nil end
		
		-- PLAGUE
		if e.plague_bearer and e.sq then
			local a=get_zone(e.sq,e.plague_bearer)
			for sq in all(a) do	sq.plague=1 end		
		end

		-- CATAPULT
		if e.catapult and (not e.stun or e.fear) then
			e.catapult_sq=nil
			e.catapult_count=e.catapult_count and e.catapult_count+1 or 1		
			if e.catapult_count>3 and irnd(2)==0 then
				e.catapult_sq=spots.get(3-stack.ai_lvl)
			end
		end
		
		exe(e.on_new_turn)
	end
	
	-- TACTIC
	if stack.tactic then
		local groups={}
		
		for b in all(bads) do
			b.tactic_locked=nil
			if b.ready then
				local gr=groups[b.type]
				if not gr then 
					gr={type=b.type, sco=0}
					groups[b.type]=gr
				end
				local grid=get_piece_next_action(b)
				if grid then
					score_grid(grid)
					gr.sco=max(gr.sco,grid.score)
				end
			end
		end
		local a={}
		for k,v in pairs(groups) do add(a,v) end
		local function f(gr) return -gr.sco-#gr end
		custom_sort(a,f)
		for i=stack.tactic+1,#a do
			for b in all(bads) do
				if b.type==a[i].type and b.ready then 
					b.ready=false
					b.tactic_locked=1
				end
			end
		end	
	end		
	
	--
	check_cards_auto_flip()
	
	-- SEER 
	if seer then seer.read_target_mind() end
	
	-- PLAGUE
	if stack.plague and #ab>0 then
		hit(rnd(ab),1,{direct=1,plague=1})
	end
	
	-- HERO READY
	hero.grenade_used=nil
	hero.grenade_ready=grenades>0
	hero.bushido=stack.bushido
	hero.hop=stack.hop
	

	if hero.cloaked then
		hero.cloaked=hero.cloaked-1
		if hero.cloaked>0 then 
			fx_emote(hero,hero.cloaked)			
		else
			cloak_hero()
		end
		
	end
	
	
	-- 
	

	-- MODE FEATURES UNLOCKS
	exe(mode.check_unlocks)

	--


	--
	play()
end
function increase_card_turns(restrict)
	restrict=restrict or {}


	local function chk(ca,a)
		for k,v in pairs(a) do
			if ca[k]~=v then return false end
		end
		return true
	end

	for ca in all(get_all_cards()) do if not ca.flipped and ca.turn_count and chk(ca,restrict) then
		ca.turn_count=ca.turn_count+1
		if ca.delay and ca.turn_count==get_delay(ca.delay)  then
			if ca.gain then
				add_event(ev_backup,ca)
			end
			if ca.delayed then
				uplift(ca.delayed)
			end
		end
	end	end
	
	-- UPGRADES DELAYS
	for upg in all(upgrades) do
		if upg.gain and upg.delay and (mode.turns or 0)+1==get_delay(upg.delay) then
			add_event(ev_backup,upg)		
		end
	end
	
	
end

-- PLAY
function play()
	if hero.dead then return end
	
	if not autofire then
		init_safe_mode()
	end

	-- PLAY EVENT
	if play_events(play) or check_auto_replace(play) or perma_checks(play) then return end

	-- UNMARK
	for e in all(bads) do e.mark={} end

	-- STOP AUTOFIRE
	if autofire then
		init_safe_mode()
		autofire=false
	end

	-- SKIP TURN
	if hero.win or (boss and boss.hp<=0) then
		wait(2,opp_turn)
		return
	end

	-- CHECK FINAL COUNTDOWN
	if stack.deathcount and hero.deathcount_start then
		if mode.turns-hero.deathcount_start>=stack.deathcount then
			if stack.rev_deathcount and not inter.storming then				
				storm(play)
				return
			end		
			local tempo=130
			local ca=get_card_with("deathcount")			
			fx_detect(tempo,ca.x+11,ca.y+15)
			ca.c_detect=tempo
			wait(tempo,xpl_king,hero)
			return
		end
	elseif #get_real_bads()<=(stack.deathcount_trig or -1) and not inter.bossfight then
		hero.deathcount_start=mode.turns
		start_music("final_countdown")
	end
	
	-- HOP/HOLOKING CLEAN
	for sq in all(squares) do sq.hop_trg=nil end
	if hero.holoking and hero.holoking.dead then
		hero.holoking=nil
		if stack.holocloak then
			cloak_hero()
		end
	end

	-- CHECK SPY
	for di=0,3 do	
		local nsq=dsq(get_hero_sq(),di)
		if nsq and nsq.p and nsq.p.role=="spy" and not nsq.p.spied then
			reveal_spy(nsq.p,play)
			return
		end
	end

	---- PLAYING ----
	check_cards_auto_flip()
	playing=true

	-- CANCEL AIM 
	if aim then
		if aim.dead or chamber==0 then 
			aim=nil
		end	
	end

	-- ANALIZE SAFE
	init_safe_mode()

	-- ANALYSIS PARALYSIS	
	if stack.paralysis then
		hero.awake=hero.awake or #hero.sq.danger>0 or stack.paralysis<mode.turns
		if not hero.awake then
			hero.c_paralysis=TEMPO+8
			opp_turn()
			return
		end
	end
	
	-- TIMERUN GO
	timerun=true
	hero.sweaty=hero.sq and #hero.sq.danger>0

	-- CLEAN
	local avm=0	
	local done={}
	for sq in all(squares) do
		sq.highlight = false
	end

	--MOVES
	local moves=get_range(hero)
	if stack.flagstones then
		for sq in all(squares) do
			if sq.flagstone and is_free(sq) then add(moves,sq) end
		end
	end

	for nsq in all(moves) do
		local will_reload = not aim and can_reload()
		local f=function()		
			if not check_folly_shields(nsq,aim,will_reload) then
				remove_buts()
				hero.walked=true
				move_hero(nsq,opp_turn)
			end	
		end			
		mk_sq_but(nsq,f,nsq.p and 10 or get_sq_di(hero.sq,nsq) )
		nsq.highlight = true
		done[nsq]=true
	end
	
	-- GAMEPAD MOVES
	reset_mode("move", moves)

	-- GRAB
	local ks_ready=stack.grab
	for di=0,7 do
		local sq=dsq(hero.sq,di,1)
		if sq and sq.p and not is_king(sq.p.type) and not sq.p.unlift and (ks_ready or sq.p.freelift) and not hero.lift then
			local lift=function()
				remove_buts()
				local p=sq.p

				sfx("grab_done")
				hero.c_lift=20
				hero.lift=p
				p.lifted=true
				p.picked=false							
				leave_sq(p)
				del(bads,p)								
				del(ents,p)
				
				if seer and seer.trg==p then
					seer.swap_target()
				end
				
				aim=nil
				if not p.freelift then
					exhaust_card_with("grab")
				end
				
				init_safe_mode()
				
				wait(8,play)
			end
			local click = function() -- controller controls
				if MOUSE or ctrl_mode=="select_soul" then return end
				lift()
			end
			local drag = function()
				local p=sq.p
				if not MOUSE then return end
				if hero.drag or not p or p.sq~=sq then return end
				remove_buts()
				sfx("lift")
				
				hero.drag=p
				p.picked=true
				p.dp=DP_FX
				local dx=p.x-mx
				local dy=p.y-my
				
				local f=function(ev)
					p.x=mx+dx
					p.y=my+dy
					p.z=p.z+(-8-p.z)*.2
					
					local lim=24
					if dist(p,hero)>lim then
						local a=atan2(p.x-hero.x,p.y-hero.y)
						p.x=hero.x+cos(a)*lim
						p.y=hero.y+sin(a)*lim						
					end
					
					if not mlb then
						kl(ev)
						p.dp=DP_PIECES
						p.picked=nil
						hero.drag=nil
						p.z=0
						if hero.sq==get_square_at(mx,my) then
							lift()
						else
							sfx("grab_cancel")								
							goto_sq(p,p.sq,8)	
							wait(8,play)							
						end
					end
				end
				loop(f)
			end
			
			local b=mk_sq_but(sq, click)
			b.on_drag = drag
			--sq.highlight = true
		end
	end	
	
	-- SMALL KEY
	if stack.small_key then
		local function exhaust_key()
			local ca=get_card_with("small_key")
			flip_card(ca)		
		end
		for di=0,7 do
			local sq=dsq(hero.sq,di)
			local p=sq and sq.p	
			if p and p.jail then
				local function open()
					remove_buts()
					exhaust_key()
					sfx("breakout")
					fx_emote(p,get_lang("free"))
					p.bad=false
					setup_piece(p)
					del(bads,p)			
					wait(30,bind(ask_disrupt,play))
				end
				local b=mk_sq_but(sq,open,83)
				sq.pad_but=b
				done[sq]=true
			end	
			if p and p.bad and p.type==3 then
				local function crumble()
					sfx("sky_dust",.5)
					p.crumb=1
					xpl(p)					
					wait(60,bind(ask_disrupt,play))
				end
				local function unlock()
					remove_buts()
					exhaust_key()
					p.c_shake=4
					sfx("unlock")
					wait(30,crumble)
				end
				local b=mk_sq_but(sq,unlock,83)
				sq.pad_but=b
				done[sq]=true
			end	

			
		end
	end
	
	-- BLADE
	if stack.blade and stack.blade>0 then
		for di=0,7 do
			local sq=dsq(hero.sq,di,1)
			local e=sq and sq.p
			
			local killable=e and e.bad
			if killable and not stack.butcher then
				killable=(e.hp or 999)<=(stack.blade+(e.bleed and 1 or 0))
			end			
			if killable and not e.airy and not e.smoke_king and not done[sq] then
				local function slice()				
					if check_fatality(sq,stack.blade, hero.sq, true) or not check_folly_shields(hero.sq) then
						remove_buts()
						hero.c_slash=24
						wait(8,blade_hit,hero,e,stack.blade)
					end					
				end
				local b=mk_sq_but(sq,slice,15*16)
				sq.pad_but=b
				local over=function()	rov_slash=sq end
				local out=function()	if rov_slash == sq then rov_slash=nil end	end
				b.over=merge_funcs(b.over,over)
				b.out=merge_funcs(b.out,out)
				done[sq]=true
			end
		end
	end

	-- ARMY
	for p in all_pieces() do
		if not p.bad and p.ready and not p.smoke_king then 
			local function click()
				if not p.sq then -- side-stepping a crash if black piece is dead but still selectable (couldn't find why that happened)
					remove_buts()
					wait(1,play)
					return
				end
				
				remove_buts()
				move_black_piece(p)
			end	
			done[p.sq]=true
			local b=mk_sq_but(p.sq, click, 10)
		end
	end

	-- TUNNELS
	if stack.tunnels then
		local local_hole
		for di=0,7 do
			local nsq=dsq(hero.sq,di)
			if nsq and nsq.hole and is_free(nsq) then local_hole=nsq end
		end
		
		if hero.sq.hole then local_hole=hero.sq end
		if local_hole then for sq in all(squares) do
			if sq.hole and sq.ddist>1 and is_free(sq) and not done[sq] then
				done[sq]=1
				local function burrow()
					sfx("tunnel")
					local function land()
						e.deep_y=nil
						if not stack.hole_solid then
							local_hole.hole=nil
							local_hole.c_was_hole=30
						end
						play()					
					end
					local tempo=16
					local function f(ev)
						hero.deep_y=sin(ev.t/(tempo*2))*16
						if ev.t==flr(tempo/2) then
							goto_sq(hero,sq,0)	
						end	
					end
					loop(f,tempo,land)			
					--
				end
				local function tunnel()
					--if check_folly_shields(sq) then return end
					remove_buts()
					if local_hole==hero.sq then 
						burrow() 
					else
						goto_sq(hero,local_hole,TEMPO,burrow)
					end
				end
				local pm={}
				if local_hole~=hero.sq then
					pm.extra_icons={}
					add(pm.extra_icons,{fr=82,sq=local_hole,dc=.5})
				end
				local b=mk_sq_but(sq,tunnel,84,pm)	
				sq.pad_but=b
				
				sq.highlight = true
			end
		end end
	end




	-- TARGETS
	local function shoot(wild, sq)	
	
		if reloading and can_reload() then
			return
		end
	
		if autofire then
			for e in all(bads) do e.mark={} end
		end
	
	
		-- RECOIL SQUARE
		local rsq,rdi=get_recoil_square()
		if hero.lift then rsq=nil end

		local k=(flr((hero.an+.125/2)*8))%8
		local shoot_sq=dsq(hero.sq,ADI[k+1],1)


		-- SIMULATE UNCLOAK
		local pcl
		if hero.cloaked and not stack.silencer then
			pcl,hero.cloaked=hero.cloaked
			init_safe_mode()
			hero.cloaked = pcl
		end

		-- DANGER SQ
		local dasq=hero.sq
		if rdi then
			local n=autofire and chamber or 1
			for i=1,n do
				dasq=dsq(dasq,rdi) or dasq
			end
		end
		
		wild = wild or (btn("unsafe") and not mode.infinite_shield)
		local function is_safe() 
			local res=check_fatality(sq,nil,dasq) or not check_folly_shields(dasq,true)
			return res
		end		
		
		if chamber==0 and not hero.lift then
			sfx("wrong")
			hero.c_need_ammo=30
			autofire=false
		elseif not wild and not is_safe() then
			if pcl then		
				hero.cloaked=pcl
				init_safe_mode()
			end		
			autofire=false
		elseif hero.lift then
			remove_buts()
			throw_piece()
			wait(TEMPO,opp_turn)
			autofire=false				
		else
			rumble(0, 0.5, 1.0, 0.14)
			--ctrlr("rumble", 0, RUMBLE_INTENSITY_L, RUMBLE_INTENSITY_R, RUMBLE_TIMER)
			
			if pcl then		
				hero.cloaked=pcl
				init_safe_mode()
			end			
			
			remove_buts()
			fire()
			
			-- RECOIL
			local lock
			if rsq then
				lock=true
				local function unlock() lock=false end
				move_hero(rsq,unlock,true,autofire and 14 or TEMPO)
			else
				hero.x=hero.sq.x
				hero.y=hero.sq.y
				mv(hero,-cos(hero.an)*4,-sin(hero.an)*4,16)
				hero.twcv=ease_uturn				
			end
			
			local nxt,tmpo
			local function checklock()
				if lock then
					wait(2, checklock)
				else
					nxt()
				end
			end
			
			if autofire and chamber>0 then
				nxt,tmpo = bind(shoot, true, sq),16
			else
				autofire=false
				nxt,tmpo = opp_turn,TEMPO
			end
			
			wait(tmpo, checklock)
		end	
		

		
	end
	
	-- mouse controls for shooting and specials
	for sq in all(squares) do
		local _shoot = shoot
		local function shoot(wild)
			_shoot(wild, sq)
		end
		
		if hero.sq~=sq then -- and not hero.sq==sq

			local b
			if done[sq] then
				b=mk_sq_but(sq)		
			else			
				b=mk_sq_but(sq,shoot,8)		
			end
			
			if stack.special=="decree"  then --and not reloading
				b.right_clic=function()
					if not reloading then
						autofire=true
						shoot()
					end
				end
			end
			
			if stack.special=="strafe" then
				b.right_clic=bind(toggle_target,sq.p)
			end
			
			if stack.special=="grenade" then
				b.right_clic=function()
					if hero.grenade_ready then
						throw_grenade(sq)
					else
						inter.lack_ammo=60
						fx_wrong(grenades>0 and lang.one_grenade_per_turn or lang.no_grenade_left)
					end
				end
			end
			
			if stack.special=="scope" then
				b.right_clic=function()

					if chamber==0 then --and ammo>0 
						fx_wrong()
						msg(lang.no_shell_loaded,60)					
					elseif hero.scope then
						fx_wrong()
						msg(lang.scope_on,60)
					elseif not check_folly_shields(hero.sq) then
						remove_buts()
						hero.scope=true
						sfx("scope")
						wait(4,opp_turn)
					end
				end
			end
			
			if stack.special=="orb" then
				b.right_clic=bind(seer_target,sq.p,true)
			end
			
			if stack.special=="dig" then
				-- DIG
				if sq.ddist==1 and not sq.hole then
					b.right_clic=bind(dig,sq)
				end
					
			end						
			
			if stack.special=="dev" then
				b.right_clic=function()
					dev_right_click_sq(sq)
					if sq.p then dev_right_click_piece(sq.p) end
				end
			end
			
		end
	end
	if stack.special=="dev" then
		for ca in all(get_slot_cards()) do
			local function f()
				remove_buts()
				flip_card(ca,play)				
			end
			local b=mk_but(ca.x-5,ca.y-5,24,32,f)
		end	
	end


	-- RELOAD
	local function reload_shotgun()

		local will_reload = not aim and can_reload()

		if check_folly_shields(hero.sq,nil,will_reload) then
			return				
		end
		if ammo==0 then
			fx_wrong()
			return
		end
		remove_buts()
		inter.ov=false
		reload(nil,nil,true)
		wait(30,opp_turn)
	end	
	if (need_reload() or (stack.overload and chamber<=7)) and not mode.no_shotgun then 

		local b=mk_but(board.x,board.y-20,26+max(chamber,stack.chamber_max)*4,8,reload_shotgun)
		b.over=function()
			inter.ov_shotgun=true
			sfx("tic") 				
		end
		b.out=function() 
			inter.ov_shotgun=false
		end

		local function get_str()
			local n=min(stack.chamber_max-chamber,ammo)
			if ammo>0 then
				if n<=0 and stack.overload and chamber<=7 then
					n=1
				end
				return get_lang("reload_shotgun_desc",{n,lang.shell})
			else
				return lang.no_ammo_left
			end
		end		
		mk_hint_but(board.x,board.y-20,26+max(chamber,stack.chamber_max)*4,8,get_str,{3})
		
	end
	
	-- SOULS
	for sl in all(souls) do
		if sl.id then		
			local a=get_range(hero,{move=1,type=sl.id,soul=1})
			if sl.id==0 then a={} end
			local b=mk_but(sl.x,sl.y,24,32,bind(activate_soul,sl))
			b.over=function()
				sl.ov=true sfx("tic") 				
				for sq in all(a) do	
					sq.show=true 
					sq.show_from=sl 
				end
			end
			b.out=function() 
				sl.ov=false 
				for sq in all(a) do	
					if sq.show_from==sl then 
						sq.show=false
					end 
				end	
			end
			--
			avm=avm+#get_soul_range(id)			
		end	
	end
	
	-- SCEPTERS
	for e in all(scepters) do
		local f=function()
			e.over=false
			remove_buts()
			activate_scepter(e)			
		end
		if e.cd~=0 then
			f=nil
		end
	
		local b=mk_but(e.x,e.y,16,16,f)		
		b.over=function()
			e.over=true
			sfx("tic")
		end
		b.out=function()
			e.over=false
		end
	end
	
	-- HINT
	init_cards_hint()

	-- SHORTCUT
	local function watch_keys(ev)
		if not playing then
			kl(ev)
			return
		end

		if (ctrl_mode == "move" or ctrl_mode == "aim") and not info then
			if btnp("reload") and (need_reload() or (stack.overload and chamber<=7)) then
				reload_shotgun()
			elseif not MOUSE then
				shoot_ctrl(shoot)
			end
		end
		
		-- PC SHOOT KEY
		if PC then
			if btnp("force_shoot") or (mcl and btn("force_aim")) then
				shoot(false,get_square_at(mx,my))
			end
		end
		
		
		-- CONSOLE ONLY
		if btnp("lstickb") and not PC then
			show_danger_zone=not show_danger_zone
		end		
		
		-- DEV
		if DEV and btn"shift" and mcr then
			local sq=get_square_at(mx,my)
			if sq then
				if sq.p then
					remove_buts()
					sq.p.hp=0
					local boss=sq.p.boss
					xpl(sq.p)
					wait(TEMPO,boss and opp_turn or play)
				else
					remove_buts()
					move_hero(sq,opp_turn)
				end
			end
		end
		if DEV and btnp("rstickb") then
			remove_buts()
			opp_turn()
		end


	end
	loop(watch_keys)

	-- SHOW FX
	for b in all(bads) do 
		if b.catapult_sq then
			show_catapult(b,b.catapult_sq)
		end
	end	

	-- 
	ach_event("play")
	

	--[[ CHECKMATE
	if avm==0 and not hero.checkmate then
		remove_buts()
		hero.checkmate=true
		play()
	end
	--]]
	
	
	--[[ TEST BRES
	local e=mke(0,hero.x,hero.y)
	e.dp=DP_FX
	local path={}
	e.upd=function(e)
		e.x=hero.x+8+cos(hero.an)*8
		e.y=hero.y+8+sin(hero.an)*8
		

		if not playing then kl(e) end

		local x0=hero.sq.px+.5+cos(hero.an)*.5
		local y0=hero.sq.py+.5+sin(hero.an)*.5
		local x1=(mx-board.x)/SQ
		local y1=(my-board.y)/SQ
		
		local dx=e.x-mx
		local dy=e.y-my
		local range=sqrt(dx*dx+dy*dy)/16+1
		local x1=x0+cos(hero.an)*range
		local y1=y0+sin(hero.an)*range
		
		
		path=bres_2(x0,y0,x1,y1)
		
	end
	e.dr=function(e,x,y)
		line(x,y,mx,my,5)
		
		local k=0
		for p in all(path) do			
			local x=board.x+flr(p.x)*SQ
			local y=board.y+flr(p.y)*SQ
			rect(x+k,y+k,x+15-k,y+15-k,5)
			k=k+1
		end
		
	end
	--]]
	
	
	
end
function move_hero(tsq,f,skip_reload,tempo)

	
	
	--[[ HERO SQUARE EVENTS MOVED to play_events()
	
	-- CHECK PENTAGRAMS
	if stack.pentagrams then
		if tsq.penta and not tsq.penta_off then
			local of=f
			f=function()
				earn_extra_turn(true)
				tsq.penta_off=true
				hero.penta_count=hero.penta_count and hero.penta_count+1 or 1
				--
				sfx("penta")				
				if hero.penta_count==3 then-- then stack.pentagrams then
					local function evolve()
						hero.c_warn=30
						hero.c_burning=30
						hero.penta_count=0
						sfx("penta_full")
						uplift({firepower=2})
						wait(30,of)
						hero.need_penta_reset=true
					end
					wait(40,evolve)
				elseif of then
					of()
				end
			end
		elseif hero.need_penta_reset then
			hero.need_penta_reset=false
			sfx("penta_reset")
			local function lp(ev)
				for sq in all(squares) do sq.penta_off=ev.t%6>=3 end
			end
			loop(lp,24,of)
		end		
	end
	
	
	if stack.waypoint then
		if tsq.waypoint then			
			local of=f
			f=function()
				tsq.waypoint,waypoint=nil
				ask_disrupt(of)
			end
		end	
	end
	
	-- CHECK SPY
	for di=0,3 do	--nsq in all(get_zone(hero.sq,1))
		local nsq=dsq(tsq,di)
		if nsq and nsq.p and nsq.p.role=="spy" then
			local of=f
			f=function()
				reveal_spy(nsq.p,of)			
			end			
		end
	end
	
	
	
	--]]
	
	--
	if tsq.cl==0 then
		hero.whited=true
	end	
	--
	if not skip_reload and not mode.no_shotgun then
		if aim and hero.lift then	
			throw_piece()
		elseif aim and chamber>0 then 
			fire() 
		elseif can_reload() then
			reload()
		elseif ammo<stack.ammo_max then
			wait(16,inc_ammo,stack.ammo_regen)
		end
	end
	
	--
	sfx("jump")
	hero.scope=false
	goto_sq(hero,tsq,tempo or TEMPO,f)

end
function reload(single_reload,rloop,clicked)
	if not rloop and reloading then return end
	if building_ammo then wait(2,reload,single_reload,rloop) return end
	
	local overfeed
	if clicked then
		overfeed = stack.overload and chamber>=stack.chamber_max
	end

	local ca,jumps=get_card_with("jumpy")
	for ca in all(jumps) do flip_card(ca) end
	
	check_cards_auto_flip()
	reloading=true
	sfx("reload")
	hero.scope=false
	
	-- SHEATH
	if not rloop then
		local snd,frags=1,0
		for b in all(bads) do
			if b.sheath then
				hit(b,stack.sheath)
				if not stack.deathcurse then b.sheath=nil end
				if snd then sfx("death_mark") snd=nil end
				if b.dead then frags=frags+1 end
			end
		end
		if frags>=4 then trig_achievement("DEATH_SENTENCE") end
	end
	
	--
	ammo=ammo-1	
	if chamber<stack.chamber_max or overfeed then
		chamber=chamber+1
		inter.c_reload=30
	elseif stack.reload_grenade and grenades<stack.grenades_max then
		grenades=grenades+1
		hero.grenade_ready=not hero.grenade_used
	end

	if can_reload() and not (stack.manual_reload or single_reload) then
		wait(20,reload,single_reload,true)
	else
		reloading=false
	end
	
end
function need_reload()
	return chamber<stack.chamber_max or (stack.reload_grenade and grenades==0)
end
function can_reload()
	return ammo>0 and need_reload()

end

function inc_ammo(n)
	building_ammo=true
	n=n or 1
	if ammo==stack.ammo_max then 
		building_ammo=false
		return
	end
	
	inter.c_regen=30
	ammo=ammo+1
	sfx("ammo",.5)
	if n>1 then
		wait(30,inc_ammo,n-1)
	else
		building_ammo=false
	end
end
function check_fatality(sq,power,tsq,blade)
	if not sq then return false end

	power=power or (hero.lift and 3 or get_firepower())
	tsq=tsq or hero.sq
	if aim and aim.sq then
		sq=aim.sq
	end

	local e=sq.p
	if not e then return false end
	if e.smoke_king then return end
	if e.wraith and not e.ready then return false end	-- TODO 
	if e.shield or e.block or (get_dodge(e)>0 and not blade) then return false end


	local lone_threat=tsq and #tsq.danger==1 and tsq.danger[1]==e
	
	-- CHK if kill would cloak
	if e.disguise then 
		local ok=true
		for p in all(tsq.danger) do	
			if p.uncover or p.projectile then ok=false end 
			if p.catapult_sq==tsq then ok=false end
		end
		if ok then lone_threat=true end
	end
	-- CHK if bushido would trigger
	if hero.bushido and blade then
		lone_threat=1
	end
	
	
	if e.bleed then power=power+1 end
	power=min(power,e.armorgap or 999)
	
	if e.type==leader then
		for b in all(bads) do
			if b.bodyguard then return false end
		end
	end
	
	local protector=get_nei_with(e,"protect")
	if protector and protector.type~=e.type then
		power=min(power, min(e.dmg_cap or 2, 2))
	end

	local dx=e.x-hero.x
	local dy=e.y-hero.y	
	return sqrt(dx*dx+dy*dy)<24 and e.hp<=power and not e.iron and lone_threat
end
function check_auto_replace(nxt)
	for a in all(AUTO_REPLACE) do
		if perm[a[1]] and perm[a[2]]  then
			replace_card(a[1],a[3],nxt)
			return true
		end		
	end	
	return false
end
function move_black_piece(p)
	sfx("lift")
	-- CARRY
	local air=get_carry_list(p)
	add(air,p)
	for p in all(air) do p.taken=1 end

	-- CLEAN
	local function clean(z)
		remove_buts()
		for p in all(air) do p.taken=nil p.z=z or 0 end
		p.z=0
	end
	
	-- MOVE
	local a=get_range(p)
	for sq in all(a) do
		sq.selectable,sq.show=true
		local f=function()
			clean()
			sfx("move_piece")
			move_piece(p,sq,play)			
		end
		mk_sq_but(sq,f,9)	
	end
		
	-- ATTACK
	local a=get_piece_targets(p)
	for trg in all(a) do if not trg.boss and not trg.team_boss then
		trg.sq.selectable,trg.sq.show=true
		local function f()
			clean()
			sfx("move_piece")
			execute_piece(p,trg,play)
		end		
		mk_sq_but(trg.sq,f,9)
		trg.ui_show=1
		
		
		--if trg.sq.selectable then log("?") end
		
	end end

	-- RIGHT CLICK CANCEL
	push_mode("move_black", trg)
	scan_cancel(bind(clean,0))

	


end


-- FIRE
function toggle_target(e)
	if e==hero.holoking then e=nil end
	
	if (aim and aim==e) or (aim and not e) then 
		fx_trg(aim,-1)

		aim=nil
		sfx("trg_out")
		
	elseif e then
		if chamber>0 or hero.lift then
			aim=e
			sfx("trg_in")
			fx_trg(e,1)
		else
			sfx("wrong")
			hero.c_need_ammo=30
		end
	end

	--aim=aim==e and nil or e
end
function fire()

	local k=.25+rnd(.5)
	fx_cart(-cos(hero.an)*k,-sin(hero.an)*k)
	
	screen_shake(8,8)
	
	local k="shoot"
	if mode.weapons_index then
		k="shoot_"..(mode.weapons_index%5)
	end
	if hero.cloaked and stack.silencer then
		k="shoot_silencer"
	end
	
	
	sfx(k)
	inter.c_shoot=10
	local shrapnel=stack.shrapnel or 0
	for i=1,get_firepower()+shrapnel do
		local an=hero.an
		local x=hero.x+8+cos(an)*8
		local y=hero.y+8+sin(an)*8
		
		local sp=get_spread()
		--if i<=(stack.bad_shells or 0) then sp=sp*2 end

		local a=an+(rnd(1)*2-1)*sp/720
		local b=mk_bullet(x,y,a,8,hero)	-- was 8+R4
		if i<=shrapnel then
			b.dmg=0
		end
		
		-- FX
		for i=0,2 do
			local p=mke(0,x,y)
			p.dp=DP_FX
			impulse(p,an+hrnd(.05),3)
			p.dr=function(p,x,y)
				pset(x,y,5)
			end
			p.life=8+irnd(24)
			p.frict=.85+rnd(.12)
		end
	end
	chamber=chamber-1
	exe(mode.on_fire)
	--
	hero.boost={}

	if hero.cloaked and not stack.silencer then 
		expose()
	end

	-- DODGE
	for p in all(bads) do
		if p.sq and (p.sq.hole or p.sq.moat) and stack.hole_cover then
			p.c_dodge=24
		end
	end


end
function throw_piece()
	sfx("throw")
	local p=hero.lift	
		
	hero.lift=nil
	
	local b=mke(0,hero.x+8,hero.y+8)
	b.knockback=p.knockback or 0
	reg_add(bullets,b)
	b.z=-8
	local an=hero.current_an	
	local va=1/32	
	
	local function impact(trg)
		b.done=true
		sfx("throw_impact")

		fx_frame_drop(8,.5)
		local e=mke(0,b.x,b.y)
		e.life=8
		e.dp=DP_INTER
		e.perm=true
		e.dr=function(e,x,y)
			local c=1-e.life/8
			circ(x,y,sqrt(c)*128,0)
		end
		
		rumble(0, 1.0, 1.0, 0.2)
		if SET.scrflash==1 then	
			fd=7 
			local function f() fd=0	end		
			fwait(8,f)
		end
		screen_shake(8)
	
		-- MARK
		trg.mark.throw_impact=true
		if p.role=="heir" then
			trg.mark.heir_impact=true
		end
		
		
		-- HIT ( first bc of knockback chances ) ( NOT WORKING )
		local dmg=3
		hit(trg,dmg,{impact=p},b)		
		
		-- FREE SQ
		local free={}
		for sq in all(squares) do
			if is_free(sq) then add(free,sq) end		
		end
		local function f(sq)
			local dx=trg.x-sq.x
			local dy=trg.y-sq.y
			return sqrt(dx*dx+dy*dy)
		end
		custom_sort(free,f)
		local fsq=free[1]
		local rdmg = bleed_dmg(p,dmg)
		if p.hp<=rdmg or not fsq then		
			b.we=.1
			b.vz=-2.5
			b.vx=b.vx/4
			b.vy=b.vy/4
			b.life=60
			b.blink=30
			va=1/16
			p.psq=fsq
			on_death(p)
		else		
			local function land()
				sfx("land")
				kl(b)
				if p.bad then
					add(bads,p)	
				end
				add(ents,p)
				p.lifted=nil				
				if not p.inert then
					p.stun=1
				end
				goto_sq(p,fsq,0)
				p.c_shake=nil
				screen_shake(p.inert and 8 or 4)
			end
			hit(p,dmg,{impact=trg})
			p.c_shake=nil
			
			local tempo=45--*3
			mvt(b,fsq.x+8,fsq.y+8,tempo,land)
			fsq.reserved=true
			local ban=an
			local function fly(ev)
				local c=ev.t/tempo
				an=ban+(0.25-ban)*c+c
				b.z=sin(-c/2)*32
			end
			loop(fly,tempo)
		end
		
	end
	
	b.upd=function()
		an=an+va
		
		p.x=b.x-8
		p.y=b.y-8				
		if b.done then 
			return
		end
		
		local sq=get_square_at(b.x,b.y)
		if sq and sq.p and sq.p.bad then
			--kl(b)
			impact(sq.p)
		end
		if not sq and not b.life then
			b.life=30
			b.done=true	
			b.nxt=function()
				p.psq=rnd(get_free_squares())
				on_death(p)
			end
		end

		--

		
		
	end
	b.dr=function(b,x,y)
	
		local function f()
			dr_rotated_piece(p,x-8,y-8,an-.25)
		end
		
		brd(f,p.type==9 and 4 or 1)
		--[[
		if p.custom_dr then
			palt(1,true)
			local function f()
				p.custom_dr(p, x, y, an-.25)
			end
			brd(f,1)
			palt(1,false)
			spritesheet("gfx")
		elseif p.type==9 then
			sspr(208,176,16,16,x-8,y-8)
		else

			local spx=176+p.type*16
			local spy=192
			if p.iron then
				spy=spy+16
				palt(1,true)
			end
			local function f() 
				pal_piece(p)
				asspr(spx,spy,16,16,x,y,(an-.25),1,1,8,8) 
			end
			brd(f,p.bad and 1 or 4)			
			palt(1,false)
			
		end
		--]]
	
	
	end
	b.drs=function()
		shpr(20,12,7,4,b.x,b.y)
	end
	
	impulse(b,an,5)


end
function mk_bullet(x,y,an,spd,from)

	local done={}

	local b=mke(0,x,y)
	b.dp=DP_FX
	add(bullets,b)
	impulse(b,an,spd)
	b.shot=true
	b.life=get_firerange()*2+irnd(5)
	b.dmg=1
	b.pierce=stack.pierce
	b.from=from
	
	local fsq=from and from.sq
	
	local targets={}
	
	local csq=get_square_at(x,y)
	
	
	b.upd=function(b)

	
		-- COLLISIONS
		local dirs={0,0,1,0,1,1,0,1}
		local steps=8
		for i=steps,0,-1 do
			local c=i/steps
			local x=b.x-b.vx*c
			local y=b.y-b.vy*c
			
			for i=0,3 do
				local sq=get_square_at(x+dirs[i*2+1],y+dirs[i*2+2])
				if sq and sq.p and sq.p.bad and not done[sq.p] and (not sq.p.airy or sq.p.shield) then
					-- DODGE & PIERCE
					local dodge,miss=get_dodge(sq.p)
					if rnd(100)<dodge then
						done[sq.p]=true
						miss=1
						fx_dmg(sq.p,0)		
						--fx_frame_drop(8,.5)
						--fx_miss(sq.p.x+8,sq.p.y)
						
					elseif b.pierce and rnd(100)<b.pierce then
						done[sq.p]=true
						b.pierce=flr(b.pierce/2)
					else			
						b.x,b.y=x,y
						kl(b)		
					end
					
					if not miss then
						local at={bullet=1}
						if stack.tearing then at.bleed=1 end
						if stack.sheath then at.sheath=1 end
						
						hit(sq.p,b.dmg,at,b,fsq)

						
					end
					
					break
				end		
			end
			
			
			if b.dead then break end
		end


		
		-- FX
		local an=atan2(-b.vx,-b.vy)
		local e=mke(0,b.x,b.y)		
		e.dp=DP_FX
		local k=8
		e.life=k
		e.dr=function(e,x,y)
			local cl=5
			if b.dmg==0 then cl=4 end
			sfillp(5,pat[1+flr(e.life*15/k)],cl*256)
			for i=0,1 do
				if i==0 then blend_light(cl,-1) end
				aspr(6,x,y+(1-i)*3,an, 1,.25, spd/16,.5, 0,2)
				blend_light()
			end
			sfillp() -- was sfillp(5,i,5) ( now idea how it could have work this long )
		end	
	
	
	end
	b.nxt=function()
		del(bullets,b)
	end		
	
	
	
	
	
	
	
	
	--[[ SQUARE HITS
	local pi=pierce
	local x0=(x-board.x)/SQ
	local y0=(y-board.y)/SQ
	local x1=x0+cos(an)*(range+1)
	local y1=y0+sin(an)*(range+1)
	local path=bres_2(x0,y0,x1,y1)
	for p in all(path) do
		local sq=gsq(flr(p.x),flr(p.y))
		if not sq then break end
		if sq.p and sq.p.bad then
			add(targets,sq.p)
			if pi>0 then 
				pi=pi-1
			else	
				break 
			end
		end
	end
	--]]
	
	
	

	
	
	return b
end

-- SPECIAL
function throw_grenade(tsq,e)

	local nxt=play


	local bounce_frict=(stack.trampoline and .75 or .5)
	
	if tsq.out then
		e.jz=e.jz*bounce_frict
		local dd=dist(tsq.sq,hero.sq)
		local t=(dd+e.jz*1.5)/3
		local tx=tsq.sq.x+8+DIR[tsq.di*2+1]*16
		local ty=tsq.sq.y+8+DIR[tsq.di*2+2]*16
		local function f()
			sfx("grenade_fall")
			e.upd=function()
			
			end
			e.dp=DP_BG	
			e.we=.25
			e.vz=2
			e.life=60
			e.drs=nil
			nxt()
		end
		mvt(e,tx,ty,t,f)	
		return
	end
	
	throwing=true
	local dd=dist(tsq,hero.sq)

	if e then
		e.jz=e.jz*bounce_frict
	else

		remove_buts()
		grenades=grenades-1		
		hero.grenade_ready=nil
		hero.grenade_used=true
	
		e=mke(0,hero.x+8,hero.y+8)
		e.an=0
		e.fra=.95
		e.upd=function(e)
			e.an=e.an+e.va
			e.va=e.va*e.fra
			e.z=e.twc and -sin(e.twc/2)*e.jz or 0
			if e.sink then
				e.y=e.y+e.sink
			end
			
		end
		e.dr=function(e,x,y)
		
			if e.sink then
				clip(tsq.x,tsq.y,16,10)
			end
		
			if e.shaking then
				if t%6<3 then x=x+1 end
			end		
			local function f()
				asspr(192,0,11,11,x,y,e.an)
			end
		
			brd(f,(e.c_warning and t%6<3 or t%24<12) and 5 or 2)
			
			if e.c_warning and t%6<3 then
				apal(5)
				f()			
			end
			
			clip()
			
		end
		e.drs=function()
			shpr(20,12,7,4,e.x,e.y,-1)
		end
		e.jz=dd/2+8
	end
	e.va=hrnd(.2)

	local zone={}	
	add(zone,tsq)	
	for di=0,7 do
		local osq=dsq(tsq,di)
		if osq then 
			add(zone,osq) 
		else
			add(zone,{sq=tsq,di=di,out=true})
		end
	end
	
	custom_sort(zone, function(sq) return sq.p and sq.p.type==leader and -1 or 0 end)
	
	local function boom()
		--
		hero.blow_up,hero.safe=nil		
		tsq.grenade=nil
		local gmo=false
		sfx("grenade_xpl")
		for b in all_pieces() do b.safe=nil end
		if tsq.hole then
			zone={tsq}
		end
		
		for i=1,#zone do
			local sq=zone[i]
			if sq.p and not sq.p.safe then
				local trg=sq.p
				if trg.type==5 and not trg.bad then	
					if not trg.blow_up and not stack.grenade_proof then
						gmo=true
						trg.blow_up=true
						xpl_king(trg)
					end
				else
					trg.safe=true
					local dmg=stack.grenade_dmg
					if sq==tsq then dmg=dmg+(stack.grenade_center_dmg or 0) end
					if #zone==1 then dmg=dmg+2 end
					if dmg<0 then dmg=0 end					
					local at={explosion=1}
					at.bleed=stack.grenade_bleed
					at.stun=stack.grenade_stun
					hit(trg,dmg,at)
					
					if trg.sq ~= sq then -- piece moved (eg. with Castle), moving its new square to the next position on the list if it's still in the zone
						trg.safe=false
						for j,q in ipairs(zone) do
							if q==trg.sq and j>i+1 then
								deli(zone,j)
								add(zone,q,i+1)
								break
							end
						end
					end
				end
			end
		end
		kl(e)
		
		-- XPL FX	
		
		if #zone>1 then
			local p=mke(0,e.x,e.y)
			p.life=12
			p.dr=function(e,x,y)	
				spritesheet("grenade")
				sspr( 48*p.t,0,48,48, x-24,y-24)
				spritesheet("gfx")
			end
		else
			local p=mke(0,tsq.x,tsq.y-16)
			p.life=21
			p.dp=DP_FX
			p.dr=function(e,x,y)
				sspr(80+cyc(7,3,e.t)*16,384,16,32,x,y)
			end
		
		end
		
		rumble(0, 1.0, 1.0, 0.25)

		

		-- FLASHBANG
		if stack.grenade_stun then fx_white_flash(16) end

		if gmo then 
			trig_achievement("OH_NO")
			if hero.win then trig_achievement("SUICIDE_PACT") end
		else
			wait(30,nxt) 
		end		
	end
	
	local function will_explode(k)		
		
		if k==0 then		
			-- CHECK KING OWN
			for sq in all(zone) do
				if sq==hero.sq and not stack.grenade_proof and (not tsq.hole or tsq==hero.sq) then					
					fx_detect(180,e.x,e.y)
					wait(140,function() e.shaking=true end)
					wait(180,boom)
					return
				end
			end
			boom()
			return
		end
		_sfx("grenade_beep",-1,.75,0,1.3-k*.1)
		e.c_warning=20
		wait(20,will_explode,k-1)
		rumble(0,(4-k)*0.0,(4-k)*0.15,20*0.016)
	end
	
	local function land()	
	
		if tsq.moat then
			sfx("splash")
			e.sink=.1
			e.life=60
			e.drs=nil
			for i=0,8 do
				local p=mk_part(e.x,e.y)
				p.dr=function(e,x,y)
					pset(x,y,4)
					pset(x+1,y+1,3)
				end
				impulse(p,rnd(1),rnd(1))
				p.frict=.95
				p.vz=-rnd(5)
				--p.drs=function()
				--	pset(p.x,p.y,min(pget(p.x,p.y)-1,1))
				--end
				p.on_impact=function()
					kl(p)
				end
				
			end

			nxt()
			return
		elseif tsq.hole then
			sfx("grenade_fall")
			e.sink=1
			e.life=4
			--e.dr=nil
			e.drs=nil
			will_explode(3)
			--nxt()
			return			
		end
	
		sfx("grenade_bounce")
		if e.jz>20 then
			throw_grenade(steal(zone),e)
		else
			throwing=false
			tsq.grenade=true
			e.an,e.va=0,0
			will_explode(3)
		end		
	end
	
	
	local t=(dd+e.jz*1.5)/3
	
	local tx=tsq.p and tsq.x+9 or tsq.x+8
	mvt(e,tx,tsq.y+8,t,land)
	

end
function seer_target(e)
	-- CANCEL
	if not e then return end
	if e==hero.holoking then return end

	sfx("seer")
	
	if not seer or seer.dead then
		seer=mke(0,hero.x+8,hero.y+8)
		seer.dp=DP_PIECES
		seer.z=-8
		seer.frict=.92
		seer.seed=rnd()
		seer.dr=function(e,x,y)
			--y=y+e.z-sin(t/120)-.5
			y=y-sin(t/120)-.5
			
			local warn=seer.trg.ready
			
			
			local fr=0
			if seer.gr then
				if seer.gr.act=="atk" then	
					fr=2 
					warn=true
				elseif seer.gr.act=="heal" then
					fr=3
				elseif seer.gr.act=="push" then
					fr=4
				elseif seer.gr.act=="swap" then
					fr=5
				elseif seer.gr.act=="charge" then
					fr=6
				elseif seer.gr.act=="spawn" then
					fr=8				
				elseif seer.gr.act~="move" then	-- push swap charge
					fr=1 
				end				
			end
			if warn and cyc(2,6)==0 then
				pal(1,5)
				pal(2,5)
				pal(3,4)		
			end
			sspr(80+fr*9,245,9,9,x-4,y-4)
			pal_rst()
			
		end
		seer.drs=function()
			shpr(20,12,7,4,seer.x-3,seer.y-2)
		end		
		seer.open=-1
		seer.upd=function(e)
		
			if stack.special~="orb" then
				e.life=32
				e.blink=e.life
				e.upd=nil
				return
			end
			
			-- REMOVE ( SHOULD CHANGE TRG INSTEAD )
			if e.trg.dead then
				e.swap_target()
			end
		
			-- MOVE
			local dx=e.trg.x+8-e.x
			local dy=e.trg.y+12-e.y
			if e.trg.big then
				dx=dx+8
				dy=dy+8
			end
			local cap,acc=.1,.015
			e.vx=e.vx+dx*acc
			e.vy=e.vy+dy*acc
			local tz=e.trg.hdy-20
			e.z=e.z+(tz-e.z)*.1
			
			-- OPEN
			e.open=mid(-1,e.open+(playing and 1 or -1),15)

			--Draw new level-up cards $0 additional time(s)
			---[[ SCAN REQUALIFY
			if e.gr and e.gr.act=="atk" then
			
				if is_free(e.gr.sq) or e.gr.sq.p==e.trg then
					e.gr.act="move"
					e.gr.sync=true
				end
			end
			--]]
			
			
		end
		seer.read_target_mind=function()
			--seer.c_open_eye=16
			
			if not seer.trg.sq then return end
			
			
			-- SHACKLES 
			if stack.shackles and seer.gr and not seer.gr.done and is_action_valid(seer.gr,seer.trg) then return end
			
			-- SET RND SEED
			local sseed=rnd()
			srand(seer.seed+mode.turns)
			
			-- CHECK MOVE
			seer.gr=nil
			seer.gr=get_piece_next_action(seer.trg)


			--CHECK ATK
			local a=get_piece_targets(seer.trg)
			if #a>0 then
				local def=a[1]
				local gr=mk_grid()
				gr.mov(seer.trg,def.sq)
				gr.pos[def]=nil
				gr.act="atk"
				gr.sq=def.sq
				seer.gr=gr
				--seer.gr={act="atk",sq=a[1].sq,pos={}}				
			end
			
			-- RESET SEED
			srand(sseed)
			
			-- SIGN ( pref and fsq )
			if seer.gr then
				-- FROM
				seer.gr.fsq=seer.trg.sq
				seer.gr.pred=1
			end
					
		
		
		end
		seer.swap_target=function()
			local a={}
			for b in all(bads) do add(a,b) end				
			if #a==0 or inter.storming then		
				e.life=32
				e.blink=e.life
				e.upd=nil
				return					
			end
			local function f(p) 
				local sco=dist(p,hero)/100
				if p.type==6 then sco=sco+3 end
				if p.type==0 then sco=sco+2 end
				if p.type==5 then sco=sco+1 end
				return sco
			end
			custom_sort(a,f)
			seer_target(a[1])
		end
		seer.nxt=function() seer=nil end
	end
	
	local a=atan2(e.x+8-seer.x,e.y+8-seer.y)+.25+irnd(2)*.5
	impulse(seer,a,3)
	seer.gr=nil
	seer.trg=e
	e.c_flh=16
	seer.read_target_mind()

	
end
function show_catapult(from,sq)
	
	local fsq=from.sq or from.wsq

	
	-- LINES
	local e=mke()
	e.dp=DP_FX
	e.upd=function()
		if not fsq.p or fsq.p~=from or not from.catapult then kl(e) return end
		if not playing and not e.life then e.life=8 return end
	end
	e.dr=function(e,x,y)
		local sx=fsq.x+8
		local sy=fsq.y+8
		local ex=sq.x+8
		local ey=sq.y+8	
		local pmax=24		
		local gp=function(c)
			c=min(c,0.999)
			local x=sx+(ex-sx)*c
			local y=sy+(ey-sy)*c-sin(c/2)*64
			return flr(x),flr(y)
		end
		
		for i=0,pmax-1,2 do
			local ki=i+(t/16)%2		
			local ax,ay=gp(ki/pmax)
			local bx,by=gp((ki+1)/pmax)
			
			if e.life then
				bx=ax+(bx-ax)*(e.life/8)
				by=ay+(by-ay)*(e.life/8)
			end
			
			line(ax,ay,bx,by,5)
		end

	end

	-- GROUND
	local e=mke()
	e.dp=DP_BOARD
	e.upd=function()
		if not fsq.p or fsq.p~=from or not from.catapult then kl(e) return end
		if not playing then kl(e) return end
	end
	e.dr=function(e,x,y)	
		local n=(t/16)%2		
		if n>=1 then
			circ(sq.x+8,sq.y+8,flr((n-1)*8)+.5,5)
		end
	end

end
function set_holoking(sq)


	if hero.holoking then
		kl(hero.holoking)
		fx_vanish(hero.holoking)
	end

	local e=mke(0,sq.x,sq.y)
	e=new_piece(5,false,sq)
	e.hp_max,e.hp=1,1
	e.smoke_king=1
	e.dr=function(e,x,y)
		for i=0,16 do		
			--local dx=cos((i/8)+t/32)*min(cos(t/60)*3,0)*(1-pow(i/16,2))--*sin(i/32)--(1-i/16)
			local dx=irnd(4)>0 and 0 or hrnd(2)
			sspr(96,72+i,9,1,x+dx+4,y+i-3)

		end
	end

	hero.holoking=e
	if stack.holocloak then cloak_hero(6) end

end
function cloak_hero(n,dis)
	if n then
	
		if dis and not hero.cloaked then
			sfx("disguise")
			fx_emote(hero,lang.disguised)
			hero.c_promoted=60
			hero.prom_from=5
		else
			sfx("cloak_in")
		end
		hero.cloaked=max(hero.cloaked or 0, n+1)
		hero.disguised=dis
	else
		sfx("cloak_out")
		hero.cloaked=nil
		hero.disguised=nil
		fx_emote(hero,lang.visible)
	end
end
function expose()
	if not hero.cloaked then return end
	cloak_hero()
end
function dig(sq)
	if not is_square_clean(sq) then
		fx_wrong()
		return
	end
	
	if check_folly_shields(hero.sq) then
		return				
	end	
	remove_buts()
	sq.hole=1
	sq.dug=1
	sq.hole_fr=-1
	
	
	local function shovel()	
		sfx("dig")
		sq.hole=1
		sq.hole_fr=sq.hole_fr+1	
		if sq.hole_fr==2 then
			opp_turn()
		else
			wait(16,shovel)
		end		
		-- parts
		local k=sq.hole_fr
		for i=1,2+k do
			local p=mk_part(sq.x+8,sq.y+8)
			p.z=0
			local fr=irnd(5)
			local cl=sq.cl
			p.dr=function(e,x,y)
				pal_inc(-sq.cl)
				sspr(128+fr*3,205,3,3,x-1,y-1)
				pal()
			end
			p.drs=function()
				shpr(128,204,2,1,p.x,p.y)
			end
			p.vz=(-1-rnd(2))*(.5+k*.25)
			impulse(p,rnd(.1)+i/3,.25+rnd(k/2))
			p.life=60+rnd(60)
			
		end

	end
	shovel()

end

-- BLADE
function blade_hit(from,trg,dmg)

	

	screen_shake(8,8)
	sfx("blade")
	hit(trg,dmg,{blade=1})
	wait(32,opp_turn)

	local e=mke(0,from.x+8,from.y+8)
	e.dp=DP_FX
	e.life=18
	e.dr=function(e,x,y)
		spr(20*16+cyc(8,3,e.t)*2,x-16,y-16,2,2,trg.x<from.x,trg.y<from.y)
	end
	mv(e,(trg.x-from.x)/2,(trg.y-from.y)/2,24)
	e.twcv=ease_out
	
	if hero.bushido and trg.hp<=0 then
		hero.bushido=false
		earn_extra_turn()
	end	

end

-- DISRUPTION
function ask_disrupt(nxt)
	sfx("mission")
	
	local pw,ph=150,69
	local pw,ph=150,84
	local sel=-1
	local opt={0,1,2,3,4,5,6,7} --4,5,6
	local sz,ec=32,4
	
	-- REMOVE 0 if no white card available
	local function chk(ca)
		return ca.team==1 and not ca.flipped
	end		
	local sum=0
	for ca in all(get_slot_cards()) do if chk(ca) then sum=sum+1 end end
	if sum==0 then del(opt,0) end
	
	-- REMOVE 3 if no king
	local a,b=get_pieces(5),get_pieces(6)
	if #a+#b==0 then del(opt,3) end

	-- REMOVE 5 if no karma
	if not has_card("Karma",true) then
		del(opt,5)
	end
	
	-- REMOVE 6 if pawns<8
	if #get_pieces(0)<8 then
		del(opt,6)
	end
	
	-- REMOVE 7 if no final countdown
	if not has_card("Final Countdown",true) then
		del(opt,7)
	end

	-- REMOVE DONE
	for n in all(hero.disrupted or {}) do del(opt,n) end


	-- NO MORE THAN 6
	while #opt>6 do steal(opt) end


	-- RESIZE
	pw=max(#opt*sz+(#opt-1)*ec+ec*4,104)
	
	--
	local pan=mke(0,(MCW-pw)/2,(MCH-ph)/2)
	pan.dp=DP_TOP
	pan.dr=function(e,cx,cy)
		hdclear(cx,cy,cx+pw,cy+ph)
		tcamera(-cx,-cy)
		rectfill(0,0,pw-1,ph-1,2)
		rect(0,0,pw-1,ph-1,3)

		lprint(lang.choose_disrupt,pw/2,4,4,1)
		
		if sel>=0 then

			local name=get_lang("disrupt_effect_name_"..opt[sel+1]) -- perm and stack.theocracy and 999 or 1
			name=rep(name, "$leader", get_leader_name())
			local desc=get_lang("disrupt_effect_desc_"..opt[sel+1])
			desc=rep(desc, "$leader", get_leader_name())

			local dy=pprint(desc,1000,0,pw-16,3,1)/6
			local by=48
			local y=by+(ph-by-dy-12)/2
			
			lprint(name,pw/2,y,4,1)
			pprint( desc,pw/2,y+8,pw-16,3,1)
		else
			for e in all(e.ents or {}) do
				if e.id then
					pal(5,3)
					sspr(48,32,16,16,e.x+8,e.y+40)
					pal_rst()
				end
			end		
		end
		
	
		draw_button("validate",pw-11,ph-12)
		
		tcamera(cx,cy)
	end
	pan.y=pan.y+MCH
	mv(pan,0,-MCH,16)
	pan.twcv=ease_out
	
	-- VALIDATE
	disrupt_menu=true -- this is used in gamepad.lua, please leave it alone, thx -remy
	local function exec()	
		disrupt_menu=nil
		remove_buts()
		sfx("execute_disruption")
		
		local function go()
			kl(pan)			
			local function nxt_disrupt()
				reset_mode()
				earn_extra_turn()
				hero.grenade_ready=grenades>0
				nxt()
			end
			disrupt(opt[sel+1],nxt_disrupt)
		end

		local function slide()
			mv(pan,0,-MCH,16,go)
			pan.twcv=slow_in
		end
		
		kl(pan)
		for e in all(pan.ents) do
			if e.index==sel then
				e.dp=DP_FX
				add(ents,e)
				e.x=e.x+pan.x
				e.y=e.y+pan.y
				kl(e.but)
				e.life=60
				--e.blink=30
				e.c_dissolve=60
				e.nxt=go
				e.par=nil
				e.z=0
				e.upd=function(e)
					e.z=e.z-.25
					if e.life<30 then
					
					end
				end
				e.drs=function()
					local x,y=e.x-e.z,e.y-e.z
					rectshade_dither(x,y,32,32,-1,min(e.c_dissolve/30,1))				
				end
			end
		end
	end

	-- OPTIONS
	local list={}
	local ma=(pw-#opt*sz-(#opt-1)*ec)/2
	for i=1,#opt do	
		local id=opt[i]
		
		local e=mke(0,ma+(i-1)*(sz+ec),12)
		add_child(pan,e)		
		e.id=id
		e.index=i-1
		e.dr=function(e,x,y)		
			y=y+(e.z or 0)		
			local ov=e.but and e.but.ov
			if not ov then pal_inc(-1)end
			
			if e.c_dissolve then				
				sfillp_dissolve(1-e.c_dissolve/30)
			end
			
			sspr(id*32,288,32,32,x,y)
			sfillp_rst()
			pal_rst()
		end
		
		local function pop_but()
			local but=mk_but(e.x,e.y,32,32,exec)
			but.over=function()
				sfx("tic",.5)
				sel=i-1
			end
			but.out=function()
				if sel==i-1 then sel=-1 end
			end
			e.but=but
			add_child(pan,but)		
		end
		wait(16,pop_but)
		add(list,e)

	end
	push_mode("disrupt_ui",list)

	
	--local butA=mke()
	--butA.x = pw-10-1
	--butA.y = ph-11-1
	--butA.dr=function(sl,x,y)
	--	draw_button("validate",x,y)
	--end
	--add_child(pan,butA)

	--[[local valid_but
	local w=48
	local function add_but()
		valid_but=mk_text_but((pw-w)/2,64,w,"execute",exec)
		add_child(pan,valid_but)
	end
	wait(16,add_but)]]--
	
end
function disrupt(id,nxt)
	
	hero.disrupted=hero.disrupted or {}
	add(hero.disrupted,id)
	
	if id==0 then -- SABOTAGE
		msg(lang.select_white_card,-1)
		local function select(ca)
			sfx("disrupt")
			msg()
			flip_card(ca,nxt)
			ca.disrupted=true

		end
		local function chk(ca)
			return ca.team==1 and not ca.flipped
		end
		ask_card(chk,select)
	end

	if id==1 then -- POISON WATER
		sfx("water_poison")
		for b in all(bads) do
			b.c_plague=30
		end	
		uplift({all_hp=-1})
		wait(30,nxt)
	end
	
	if id==2 then	-- REFILL AMMO
		short_refill=true
		refill_ammo(nxt)
	end
	
	if id==3 then -- ASSASSINATE
		for b in all(bads) do	if b.type==5 or b.type==6 then 
			hit(b,4,{direct=1})
			local tempo=16
			local e=mke(0,b.x,b.y)
			e.dp=DP_FX
			e.life=tempo
			e.dr=function(e,x,y)
				local c=e.t/tempo
				local ca=ease_in(c)
				local cb=ease_out(c)
				local ax=x+16*ca
				local ay=y+16*ca
				local bx=x+16*cb
				local by=y+16*cb
				local r=sin(c/2)*2
				local cx=(ax+bx)/2+r
				local cy=(ay+by)/2-r
				local dx=(ax+bx)/2-r
				local dy=(ay+by)/2+r
				
				--line(ax,ay,bx,by,5)
				trifill(ax,ay,cx,cy,dx,dy,5)
				trifill(bx,by,cx,cy,dx,dy,5)
			end
			break
		end end 
		wait(30,nxt)
	end
	
	if id==4 then -- GLUE
		uplift({all_tempo=1})
		sfx("glue")
		for b in all(bads) do	b.c_glue=30 b.ready=nil end 
		wait(30,nxt)
	end
	
	if id==5 then -- REVERSE KARMA
		local function alt_dr(e,x,y)
			spritesheet("cards")
			sspr(240,32,24,32,x,y)
			spritesheet("gfx")				
			local c=min(e.t/30,1)
			c=ease_bounce_out(c)
			asspr(200,256,20,20,x+12,y+15,c*.5,1,1,9,9)
		end		
		local ca=get_slot_card("Karma")
		reverse_card(ca,alt_dr)
		wait(60,nxt)
	end
	
	if id==6 then -- DISARM PAWNS
		sfx("disarm")
		uplift({pawn_peace=1})
		for b in all(bads) do if b.type==0 then b.c_warn=60 end end
		wait(60,nxt)
	end
	
	if id==7 then -- REVERSE FINAL COUNTDOWN

		local ca=get_slot_card("Final Countdown")
		local function alt_dr(e,x,y)
			if e.t>30 or cyc(2,3)==0 then
				sspr(238,297,10,10,x+9,y+8)
			end
		end
		reverse_card(ca,alt_dr)

		wait(60,nxt)
	end	
	
	
end
function ask_card(chk,select)
	local cards={}
	for sl in all(card_slots) do if sl.ca and chk(sl.ca) then
		add(cards,sl.ca)
		
		sl.ca.selectable=true
		local function f()
			remove_buts()
			for ca in all(cards) do ca.selectable=false end
			select(sl.ca)
		end
		
		local b=mk_but(sl.ca.x,sl.ca.y,24,32,f)
		b.dp=DP_INTER		
		
	end end
	
	push_mode("ask_card")
	mMenu.x=cards[1].x+11
	mMenu.y=cards[1].y+26
	
	-- HINTS
	init_cards_hint()
	

end
function demote(k,targets,n,nxt)
	local a={}
	
	for p in all(bads) do	
		if p[k] and is_valid_target(p,targets,true) then
			add(a,p)
		end
	end
	
	local function demote_next()
		if #a==0 or n<=0 then
			nxt()
			return
		end
	
		local p=steal(a)
		n=n-1
		
		sfx("retire")
		
		p.c_morph=30
		
		wait(p.c_morph, function()
			p[k]=nil
			setup_piece(p)
			demote_next()
		end)
	end
	
	demote_next()
end
function retire(a,nxt)
	a=clone(a)
	
	local function remove_next()
		if #a==0 then
			nxt()
			return
		end
		local type=steal(a)
		local b=clone(bads)
		shuffle(b)
		
		if DEV then
			local function f(p) return p.false_king and 1 or 0 end
			custom_sort(b,f)
		end
		
		local trg
		for e in all(b) do
			if e.type==type then
				trg=e
				break				
			end
		end
		
		if not trg then
			remove_next()
			return
		end
		sfx("retire")
		if trg.type>0 then
			ach_count("retire")
		else
			--log("!!")
		end
		fx_ascend(trg,remove_next)
		
	end

	remove_next()
	
end
function fx_ascend(trg,nxt)
	--trg.picked=true
	local function ascend(ev)
		trg.z=trg.z-ev.t/10		
		trg.invis = ev.t>20 and ev.t%4<2		
		if ev.t==30 then
			kl(ev)
			kl(trg)
			del(bads,trg)
			exe(nxt)
		end			
	end
	loop(ascend)
end
function reverse_card(ca,dr)
	sfx("reverse_karma")
	ca.t=0
	ca.reversed=true
	ca.alt_dr=dr
	build_stack()	
	
	--[[
	local e=mke()
	add_child(ca,e)
	e.upd=function(e)
		if not e.life and not ca.reversed then
			e.life=30
			e.blink=30
		end
	end
	e.dr=dr
	--]]
	
	
end

-- BORDEL
function fx_wrong(txt)
	local tempo=30
	if txt then
		tempo=tempo+#txt
		msg(txt,tempo,true)
	end
	sfx("wrong")
	hero.c_wrong=tempo
end
function get_square_at(x,y)
	return gsq( flr((x-board.x)/SQ), flr((y-board.y)/SQ))
end
function give_ammo(e,n)
	if n==0 then return end
	--give_ammo(e,3)
	local p=mke(0,e.x+8-2,e.y+8-4)
	p.dr=function(e,x,y)
		sspr(72,56,5,8,x,y)
	end
	local f=function()
		kl(p)
		inc_ammo(1)
		if n>1 and ammo<stack.ammo_max then
			give_ammo(e,n-1)
		end		
	end
	
	local tx=board.x+ammo*4,board.y
	local ty=board.y-2
	
	mvt(p,tx,ty,30,f)
	p.twcv=ease_in
		


end
function get_sq_di(sq,esq)
	local a=atan2(esq.px-sq.px,esq.py-sq.py)
	return ADI[1+round(a*8)%8]
end
function unpause()
	inter.c_unpause=20
	pause=false
	close_menu()
	if mode.id ~= "tutorial" then
		shields=min(shields,SET.shields)
	end
	
	--sfx("pause",.5)
	--sfx("menu_out",0.7)
end
function check_folly_shields(sq,shooting,will_reload)

	-- REAL DANGER ( death mark & hole cover )
	local danger=get_sq_danger(sq,will_reload)
	for di=0,7 do
		local nsq=dsq(sq,di)
		if nsq and nsq.it then return false end	
	end

	--
	if sq.hop_trg then return false end
	if (sq.penta and not sq.penta_off) or sq.waypoint then return false end
	if #danger>0 and mode.infinite_shield then return true end

	
	local res= #danger>0 and shields>0 and not btn("unsafe")
	if res then 
		mode.fool=true 
		show_danger(sq,will_reload)
	end
	
	return res
	
end
function uplift(ca)

	if ca.mk_grenades then
		grenades=min(grenades+1,stack.grenades_max)
	end
	if ca.mk_ammo then
		inc_ammo(ca.mk_ammo)
	end
	
	add(temporary,ca)
	build_stack()
end
function sfillp_dissolve(c)
	for i=0,5 do sfillp(i,pat[1+flr(mid(0,c,1)*15)],i) end
end
function sfillp_rst()
	for i=0,5 do sfillp(i,0,i) end
end
function fillp_dissolve(c)
	for i=0,5 do fillp(pat[1+flr(mid(0,c,1)*15)],true) end
end
function get_hero_sq(doubt)
	
	if doubt and hero.cloaked and not hero.holoking then
		if hero.disguised then
			local a={hero}
			for b in all(bads) do 
				if b.type==hero.disguised then	add(a,b) end
			end
			local p=steal(a)
			return p.sq
		else
			return rnd(squares)
		end
	
	end

	return hero.holoking and hero.holoking.sq or (hero.sq or hero.wsq or squares[1])
end
function get_hero_trg()
	return hero.holoking or hero
end
function goto_heaven(p,nxt)
	
	local tempo=40
	local e=mke(0,p.x+8,p.y+12)
	e.dp=DP_SHADES
	e.life=tempo
	e.dr=function(e,x,y)
		local c=e.life/tempo
		c=ease_in(c)
		local ec=c*8
		local cl=3+t%3
		rectfill(x-ec,0,x+ec-1,y,cl)
		p.clp={x=x-ec,y=0,w=ec*2,h=y}
	end
	
	local function last_parts()
		for i=0,16 do
			local pa=mke(0,e.x,rnd(e.y))
			pa.vy=p.vy--(1+hrnd(.25))
			pa.frict=.9+rnd(.1)
			--p.we=p.we
			pa.life=16+rnd(16)
			pa.dr=function(e,x,y)
				pset(x,y,5)
			end
			--p.blink=16
		end		
	end
	wait(tempo,last_parts)	
	
	e.nxt=nxt
	p.we=-.15
	p.life=tempo
	

end
function get_sq_danger(sq,will_reload)
	local res={}
	for e in all(sq.danger) do
		local ok=true
		if not survive_sheath(e) and not e.block and will_reload then	ok=false	end
		if e.projectile and sq.hole then ok=false end		
		if ok then add(res,e) end
	end
	return res
end

-- SAFE
function init_safe_mode()

	

	for sq in all(squares) do 
		sq.danger={}	
	end
	
	-- CATAPULT
	for e in all_bads() do
		local csq=e.catapult_sq
		if csq and (not hero.lift or hero.sq==csq) then
			add(e.catapult_sq.danger, e)
		end
	end
	

	-- ATK RANGE + CHARGE
	for b in all(bads) do
	
		local king_elusive=stack.elusive and b.cd>=get_piece_tempo(b)	
		if b.sq and (not hero.cloaked or b.uncover) and not king_elusive then
			local a=get_range(b,{atk=1,scan=1})
			for sq in all(a) do
				add(sq.danger,b)
			end
			
			if b.ready and not b.jail then
				if b.charge then
					for di=0,3 do
						local sq=b.sq
						for k=1,8 do
							local nsq=dsq(sq,di)		
							if not nsq then	
								add(sq.danger,b)
								break
							elseif nsq.p and nsq.p~=hero then
								break
							elseif nsq.moat then
								break
							end
							sq=nsq
						end
					end			
				end
				
				if b.push then
					for di=0,3 do
						local n,moat=0
						local sq=b.sq
						
						for k=1,8 do
							local nsq=dsq(sq,di)		
							if not nsq then
								break
							elseif nsq.moat then
								moat=true
								break
							elseif not nsq.p or nsq.p==hero then
								n=n+1
							end
							sq=nsq
						end
						
						if n<=3 and not moat then
							for k=0,2 do
								local nsq=dsq(sq,di,-k)
								add(nsq.danger,b)
							end
						end
						
					end			
				end
			
			end
		end
	end

	-- PROJECTILES
	local hsq=get_hero_sq()
	local function add_proj_danger(e)
		local a=e.get_danger(1)
		for sq in all(a) do
			add(sq.danger,e)
		end		
	end	
	for e in all(ents) do
		if e.projectile then
			add_proj_danger(e)
		end		
	end



end
function show_danger(sq,will_reload)
	sfx("wrong_shield")
	shields=shields-1
	inter.c_shield_lost=30
	local a=get_sq_danger(sq,will_reload)
	for p in all(a) do
		p.c_warn=30 
	end	
end

-- IA
function opp_turn()


	-- CANCEL DECREE (console)
	decree_on=nil

	-- WAIT knockback and shots
	if #bullets>0 or curtsy>0 then 
		wait(4,opp_turn) return 
	end
	
	-- PLAY EVENTS
	if perma_checks(opp_turn) then return end
	
	
	
	-- GRAB ITEMS
	for sq in all(squares) do
		if hero and sq.it then
			local dx=sq.px-hero.sq.px
			local dy=sq.py-hero.sq.py
			if abs(dx)<=1 and abs(dy)<=1 then
				earn_extra_turn()
				grab_item(sq.it,opp_turn)
				return
			end
		end
	end

	-- EXTRA TURN
	if hero.extra_turn then
		new_turn()
		return
	end
	
	-- PATCH
	trace_heros_dists()
	
	-- CHECK END GAME
	local pass=DEV and (btn("rstickb") or btn("k"))
	if boss and (boss.hp<=0 or pass) then
		xpl_boss()
		return 
	end
	if pass then 
		hero.win=true 
		add_event(ev_surrender)
	end

	-- CHECK EXECUTION
	executions={}
	for e in all(bads) do 
		local pred=get_prediction(e) -- ?		
		if not e.stun and not e.kback then
			local a=get_piece_targets(e)
			local function f(b)
				if b.mastermind then return -1 end
				if b.smoke_king then return -2 end
				return 0
			end
			custom_sort(a,f)
			for p in all(a) do
				add(executions,{atk=e,def=a[1],dsq=p.sq})				
				break
			end
		end
	end
	local function f(o)
		local n=0
		if dsq==o.def.sq then n=n-8 end
		if o.atk.killprom then n=n-1 end
		if o.def.mastermind then n=n-2 end
		if o.def.smoke_king then n=n-4 end
		return n
	end
	custom_sort(executions,f)
	
	--if #executions>0 then E=executions stop() end
	
	-- GO FOR MOVE
	opp_move()
	

end
function execute_piece(atk,def,nxt)
	
	if hero.win or def.dead then
		opp_move()
		return
	end

	local atk_sq=atk.sq
	local def_sq=def.sq
	local slowmo=def.mastermind

	--
	exhaust(atk)

	-- DETECTION
	if slowmo and not def.detected then
		def.detected=true
		atk.airy=nil
		fx_detect(80,atk)
		wait(80,execute_piece,atk,def,nxt)
		return
	end
	
	
	-- LANCER
	if def.sq.mark[atk]=="pike" then
		local tempo=slowmo and 90 or TEMPO
		local a=atan2(def.x-atk.x,def.y-atk.y)		
		local e=mke()
		e.dp=DP_FX
		mv(atk,-cos(a)*6,-sin(a)*6,tempo)
		atk.twcv=ease_uturn
		atk.c_lance=tempo+30
		local le=2
		if abs(atk.sq.px-def.sq.px)+abs(atk.sq.py-def.sq.py)<2 then	le=1 end
		le=le-.25
		e.life=tempo+30
		e.dr=function()	
			local c=min(e.t/tempo,1)
		
			if e.t>tempo then
				c=max(0,1-(e.t-tempo)/30)
			end		
			c=c*c
			local cle=max(.25,c)*le
			
			local d=c*16
			local x=atk.x+8+cos(a)*d
			local y=atk.y+8+sin(a)*d	
			aspr(14+4*16,x,y,a+.5,cle,5/16,1,1,8*cle,2)
		end
		local xpl=xpl
		if def.mastermind or def.smoke_king then
			wait(tempo,xpl_king,def)
			return		
		else
			local function f()
				xpl(def)
				wait(8,nxt)
			end
			wait(tempo,f)	
			return
		end
		
	end
	
	-- BOSS 
	if def.sq.mark[atk]=="eat" then	

		local function death()
			local a=atan2(def.x-8-atk.x,def.y-8-atk.y)+.5
			atk.c_take=40
			mv(atk,-cos(a)*8,-sin(a)*8,atk.c_take)
			atk.twcv=ease_uturn
			atk.target=def
			local function eat()
				atk.c_eat=90
				atk.eating=true				
				if def.smoke_king then
					def.x=atk.x+8
					def.y=atk.y-16
					wait(40,fx_vanish,def)
					wait(30,opp_move)					
				else
					local function f()
						if def==hero then 
							mode.on_hero_death()
						else				
							atk.eating=nil	
							on_death(def)
							wait(30,opp_move)
						end						
					end
				
					wait( 40, bind(sfx,"eat"))
					wait( atk.c_eat,f)
					wait( 60, bind(trig_achievement,"MMMMH_DELICIEUX"))
				end
			end
			wait( atk.c_take, eat)
			wait( 20, bind(sfx,"catch"))
		end	
		
		-- DARK BISHOP
		if atk.dark then death=function()
			

			local function random_jump(p,k)
			
				sfx("jump")
				local a=get_range(p)
				if #a==0 or k==6 then fade_to(-4,30,end_game) end
				if #a==0 then	return end
				
				local sq=steal(a)
				goto_sq(p,sq)
				wait(TEMPO+16,random_jump,p,k+1)		
			
			end


			local function white()
				local sq=def.sq
				local smoke=def.smoke_king
				leave_sq(def)
				kl(def)
				local p=new_piece(def.type,true,sq)			
				if smoke or def.type~=5 then
					p.soulless=true
					wait(30, opp_move)
				else
					wait(60,random_jump,p,0)
				end
				sfx("lost_king")
			end


			local function morph()
				--def.bad=true
				def.c_bishop_mute=60
				sfx("bishop_resist")
				wait(60,white)
			end

			boss.c_read_book=120
			wait(boss.c_read_book,morph)		
			wait(20,sfx,"incantation")

		
					
		end end
		
		if def==hero then
			black_mist_check(death)
		else
			death()
		end
		
		return
	end

	
	-- CLASSIC
	local osq=def.sq or def.wsq
	leave_sq(def)

	local function search_peace_square(p)
		local a={}
		for sq in all(squares) do
			if is_free(sq) then
				local targets=get_piece_targets(p,sq)
				add(a,{sq=sq,fatal=#targets>0,dist=dist(sq,osq)})
			end
		end
		local function f(o) return (o.fatal and 512 or 0)+o.dist end
		custom_sort(a,f)		
		return a[1].sq
	end


	local function cancel_crush()
		goto_sq(atk,atk_sq,TEMPO,nxt)
		goto_sq(def,def_sq,0)		
	end

	local function crush(trg)
		if trg then def=trg end
		-- KILL PROM
		if atk.killprom and def.mastermind then			
			local function back()
				def.detected=nil
				--def.sq=osq
				--osq.p=def			
			
				local bsq=search_peace_square(atk)
				start_lvl_music()
				goto_sq(atk,bsq,30)
				goto_sq(def,osq,0)
				wait(30,opp_move)
				
				local b={}
				for i,dat in ipairs(executions) do
					local a=get_piece_targets(dat.atk)
					local function f(b)
						return b.mastermind and -1 or b.smoke_king and -2 or 0
					end
					custom_sort(a,f)
					if a[1] then
						add(b,{atk=dat.atk,def=a[1],dsq=a[1].sq})
					end
				end
				executions=b
			end			
			atk=morph_to(atk,4,back)			
			return 
		end	
	

		-- IRON / SHIELD / BODYGUARD
		if chk_iron(def) or chk_shield(def) or chk_bodyguard(def)  then
			wait(16,cancel_crush)
			return
		end		

		-- CASTLE
		if chk_castle(def,crush) then return end
		
		
		-- LOOP
		local tempo=30
		local function landing(ev)
			local c=ev.t/tempo
			atk.z=(c-1)*10-sin(c/2)*12
		end
		loop(landing,tempo)				
		
		-- STUN if holoking
		if def.smoke_king then
			stun_piece(atk,3)
		end
		
		-- KILL HERO
		if def.mastermind or def.smoke_king then
			xpl_king(def)
			return
		end	
		
		-- KILL
		if def.exposed and def.role=="spy" then
			msg(lang.spy_executed,60,true)
		end		
		def.killer=atk		
		xpl(def)
		goto_sq(atk,def_sq,0)
		wait(60,nxt)
	end
	atk.crusher=true
	carry_nearby_pieces(atk,osq)
	goto_sq(atk,osq,slowmo and 90 or TEMPO,crush)
	def.sq=def_sq
	

	

end
function opp_move()

	if hero.win then 
		init_new_turn()
		return 
	end

	-- EXECUTIONS
	if #executions>0 then
		local ex=executions[1]
		del(executions,ex)
		if ex.def.sq==ex.dsq then
			execute_piece(ex.atk,ex.def,opp_move)
		else
			opp_move()
		end
		return
	end
	
	-- PRESENCE
	presence={}
	if stack.presence then
		local hsq=get_hero_sq()
		for di=0,7 do
			local nsq=dsq(hsq,di,1)
			if nsq then presence[nsq]=1 end
		end
	end

	-- ASYNC MOVES
	for e in all(bads) do if e.ready and not e.fear and not e.stun then
		
		
		-- ASYNC MOVES
		if is_async(e) then
			local gr=get_piece_next_action(e)
			if gr and not gr.sync then
				execute_action(e,gr,opp_move)
				return
			end
		end
		
		-- OTHER ALT MOVE
		if e.alt_move and e.alt_move() then
			exhaust(e)
			return
		end
	
	end end
	
	-- TURN MOVES
	for e in all(bads) do if not e.stun then
		-- BOW
		if e.bow then
			local tsq=get_hero_sq(true)			
			-- ARROW LIMIT
			e.arrow_limit=3-e.bow
			for b in all(bads) do if b.bow then e.arrow_limit=e.arrow_limit+1 end end			
			e.arrow_limit=max(e.arrow_limit,1)	
			e.arrow_count=e.arrow_count and e.arrow_count or irnd(e.arrow_limit)

			if is_hero_close(e) then
				-- too close
			elseif (e.arrow_count or 0)>=e.arrow_limit then
				sfx("arrow")
				e.arrow_count=0
				local an=atan2(tsq.x-e.x,tsq.y-e.y)			
				local b=bad_shoot(e.x+8,e.y+8,an)		--14 6
				b.z=-6
				b.spd=1
				b.dr=function(e,x,y)
					local detect=e.c_detect and t%4<2
					local warn=e.c_warn and cyc(2,6)==0
					local dx=cos(e.an)
					local dy=sin(e.an)
					
					local function f()
						if detect then apal(4) end
						if warn then 
							apal(5)
							pal(5,4)
						end
						line(x+dx,y+dy,x-dx*4,y-dy*4,5)
						line(x+dx,y+dy,x+dx*2,y+dy*2,4)
					end					
					local bcl=(detect or warn) and 5 or 1
					if warn then bcl=5 end
					brd(f,bcl)
				end
			else
				e.arrow_count=e.arrow_count+1
			end
		end	
		
		-- STONING
		if e.stoning and irnd(e.jester and 2 or 5)==0 and not is_hero_close(e) then
			local tsq=get_hero_sq(true)
			local an=atan2(tsq.x-e.x,tsq.y-e.y)
			if e.hold_stone then
				sfx("arrow")
				e.hold_stone=e.hold_stone>1 and e.hold_stone-1 or nil
				local b=bad_shoot(e.x+8,e.y+8,an)	
				b.z=-6
				b.spd=1	
				b.dr=function(e,x,y)
					local detect=e.c_detect and t%4<2
					local warn=e.c_warn and cyc(2,6)==0
					--local bcl=(detect or warn) and 5 or 1
					if warn then 
						apal(5)
					elseif detect then
						pal(2,5)						
					end
					
					-- TRAIL
					local r,la,lb=2,4,6
					local co,si=cos(an),sin(an)
					line(x-r*si,y+r*co,x-r*si-la*co,y+r*co-la*si,1)
					line(x+r*si,y-r*co,x+r*si-la*co,y-r*co-la*si,1)
					line(x,y,x-lb*co,y-lb*si,1)
					circfill(x-co,y-si,2,1)
					
					sspr(112,90,6,6,x-2.5,y-2.5)
					
					--if warn then bcl=5 end
					--brd(f,bcl)
				end

			elseif not e.peace then
				e.hold_stone=e.jester and 3 or 1
				e.c_hold_stone=8
			end
			
		end
		
		-- CATAPULT
		if e.catapult and e.catapult_sq then
			sfx("boulder_launch")
			local sq=e.catapult_sq 
			e.catapult_count,e.catapult_sq=0,nil
			
			local trg=get_hero_trg()					
			local tempo=60
			local sx=e.x+8
			local sy=e.y+8
			local ex=sq.x+8
			local ey=sq.y+8			
			local hit_hero=sq==trg.sq
			if hit_hero and trg.mastermind and not hero.lift then
				fx_detect(60,e)
				tempo=tempo+120
			end			
			if hit_hero and hero.lift then
				ey=ey-5
			end			
			
			local boulder=mke(0,sx,sy)
			boulder.z=0
			boulder.dp=DP_FX
			boulder.life=tempo
			boulder.upd=function(e)
				local c=e.t/tempo
				e.z=-sin(c/2)*32		
				e.x=sx+c*(ex-sx)
				e.y=sy+c*(ey-sy)			
			end	
			boulder.dr=function(e,x,y)
				y=y+e.z
				sspr(224,69,11,11,x-5,y-5)
			end	
			boulder.drs=function()
				shpr(20,12,7,4,boulder.x,boulder.y,-1)
			end
			boulder.nxt=function()
				sfx("boulder_xpl")				
				local crx,cry=sq.x,sq.y
				if hit_hero then
					if hero.lift then
						local e=hero.lift
						cry=cry-5
						hero.c_lift=10
						if e.iron then
							sfx("shield")
						elseif e.name=="cannonball" then
							hero.c_flh_lift=8
							sfx("shield")
						else
							e.x=hero.x
							e.y=hero.y-4
							xpl(e)
							hero.lift=nil
						end
						
						local function f()
							if hero.extra_turn then
								init_safe_mode()
								new_turn()
							else
								opp_move()
							end
						end
						
						wait(30,f)
					else
						screen_shake(8,8)
						xpl_king(trg)
					end
				else
					screen_shake(8,8)
				end
				
				-- PARTS
				for i=0,3 do 
					local dum={bad=0,sq=sq,x=crx,y=cry}
					fx_crumb(dum,irnd(6))
				end			
			end

			if hit_hero then
				return
			end

			--if not hit_hero then wait(8,nxt) end
			
		
		end
		
		
		-- SPECIFIC
		exe(e.turn_move)
	end end
	
	
	-- SYNC MOVES ( = JUMP )	
	local nxt=init_new_turn
	local a=clone(bads)
	local function f(b) 
		local score=0
		if b.carry then score=score-1 end
		if seer and seer.trg==b then score=score-2 end
		return score
	end	
	custom_sort(a,f)

	for e in all(a) do if e.ready and not e.stun then
		local sq=choose_piece_move(e)		
		if sq then
			move_piece(e,sq,nxt)
			nxt=nil
		else
			show_regret(e)
		end		
	end end	
	
	for e in all(ents) do
		if e.sync_upd then
			e.c_sync=TEMPO-1
			if nxt then
				wait(TEMPO,nxt)
				nxt=nil
			end
		end
	end
	

	exe(nxt)
	
end
function get_prediction(e,key)
	if seer and seer.trg==e and seer.gr and (seer.gr.act==key or not key) and is_action_valid(seer.gr,e) then
		return seer.gr
	end
	return nil
end
function choose_piece_move(e)
		

	-- SEER
	local pred=get_prediction(e,"move")
	if pred then 
		pred.done=true
		return pred.sq 
	end
	
	
	local a=get_range(e)
	

	------ NEW GRID SYS ----------
	local grids={}
	for sq in all(a) do
		local grid=mk_grid()
		grid.sq=sq
		grid.mov(e,sq)			
		score_grid(grid,e)
		add(grids,grid)
	end
	
	-- LIGHTFOOT
	if e.lightfoot then
		for di=0,3 do
			local bsq=dsq(e.sq,di)
			local sq=dsq(e.sq,di,2)
			if is_free(sq) and (bsq.p or bsq.moat) then
				local grid=mk_grid()
				grid.act="hop"
				grid.sq=sq
				grid.bsq=bsq
				grid.mov(e,sq)
				score_grid(grid,e)
				add(grids,grid)
			end
		end
	end
	
	local function f(gr) return -gr.score end
	custom_sort(grids,f)		
	
	-- REMEMBER MOVES
	e.grids={}
	for gr in all(grids) do
		e.grids[gr.sq]=gr
	end
	
	
	-- AUGUST PRESENCE
	if stack.presence and e.bad and e.type~=5 then
		e.regret=nil
		local first=1
		for gr in all(grids) do
			if presence[gr.sq] then
				del(grids,gr)					
				if first then 
					e.regret=gr.sq					
				end			
			end
			first=nil
		end	
	end	
	
	
	
	
	-- BEST MOVE
	local n=min(#grids,3-(stack.ai_lvl or 0))
	n=irnd(n)+1
	e.fgr=#grids>0 and grids[n] or nil
	if e.soulless then e.fgr=rnd(grids) end
	
	--
	if #grids==0 then return nil end

	
	return e.fgr.sq,e.fgr




end
function get_piece_tempo(e)
	local tempo=e.tempo
	if e.bleed then tempo=tempo+(stack.bleed_slow or 0) end 	
	if e.emergency_done then tempo=max(tempo-1,1) end
	if stack.shackles and seer and e==seer.trg then  tempo=tempo+1 end
	return tempo
end

--
function move_piece(e,sq,nxt)
	exhaust(e)
	e.still=nil			
	carry_nearby_pieces(e,sq)
	goto_sq(e,sq,TEMPO,nxt)				
	if e.fear then
		e.fear=nil
		setup_piece(e)
	end
end

-- ACTION SYSTEM
function get_piece_next_action(e)

	-- SEER
	local pred=get_prediction(e)
	if pred then return pred end
	
	local curgr=mk_grid()
	score_grid(curgr,e)
	local curscore = curgr.score

	local grids={}	
	local function ngr(id,bonus)
		local gr=mk_grid()
		gr.act=id
		gr.bonus=bonus or 0
		add(grids,gr)
		return gr
	end

	-- BEST MOVE
	local msq,gr=choose_piece_move(e)
	if gr then 
		gr.act="move"
		gr.sync=true
		add(grids,gr)
	end

	-- HEALER
	if e.healer then
		local function chk(e) 
			return e.bad and (e.hp<e.hp_max or e.poisoned or e.bleed) and not e.inert 
		end
		local a=get_zone_targets(e.sq,e.healer,chk)
		if #a>0 then 
			local gr=ngr("heal",#a)	
			gr.targets=a
		end
	end
	
	-- PUSHERS
	if e.push then
		for di=0,3 do				
			for i=1,e.push do
				local gr=ngr("push")
				gr.di=di
				gr.k=i
				for j=1,i do 
					gr.pushed=gr.push(e,di)
					local sq=gr.pos[e]
					if not sq or sq.moat then break end
				end					
				if gr.pushed<=0 then del(grids,gr) end
			end
		end	
		
	end

	-- SWAPS
	local swap =e.ward and {get_leader_type()} or e.swap
	if swap then
		local a={}		
		for id in all(swap) do
			for b in all(bads) do
				if b.type==id	and not b.pre_move then
					--local gr=ngr("swap",-1)
					local gr=ngr("swap",-1)
					gr.pos[e],gr.pos[b]=gr.pos[b],gr.pos[e]
					gr.a=e
					gr.b=b
				end
			end			
		end
	end

	-- CHARGE
	if e.charge and not e.jail and not (hero and hero.cloaked) then
		local a={}
		local trg=get_hero_trg()
		for di=0,3 do
			local sq=e.sq
			for i=1,10 do
				sq=dsq(sq,di)
				if not is_free(sq) or sq.moat then
					if sq and sq.p==trg and i>1 then							
						local nsq=dsq(sq,di)
						if not nsq or is_free(nsq) then
							local gr=ngr("charge")
							gr.di=di
							gr.tsq=dsq(sq,(di+2)%4)
							gr.mov(e,gr.tsq)
							gr.push(trg,di)
						end
					end					
					break					
				end
			end
		end
	end

	-- SPAWN
	if e.spawn and #get_pieces(e.spawn)<=3 then

		local a=get_range(e,{move=1,type=e.spawn})
		if #a>0 then
			local gr=ngr("spawn",(rnd(1)^2)*3)
			gr.pid=e.spawn
			gr.sq=rnd(a)		
		end	
	end

	-- CHOOSE BEST ACTION
	for gr in all(grids) do
		score_grid(gr,e)
		-- removing special moves that would result in a worse position
		if gr.score < curscore and gr.act~="move" then
			del(grids,gr)
		end
	end
	local function f(gr) return -gr.score end
	custom_sort(grids,f)
	
	--
	return grids[1]

end
function is_async(e)
	return e.catapult or e.healer or e.push or e.swap or e.charge or e.spawn or e.ward or e.lightfoot
end
function execute_action(e,gr,nxt)

	--[[
	if DEV then 
		local s=e.name..": "..gr.act
		if gr.pred then s=s.." (predicted)" end
		wlog(s)
	end
	--]]

	gr.done=true

	exhaust(e)


	local id=gr.act

	if id=="move" then
		log("move exection error")
	end

	if id=="heal" then

		local function heal()
			sfx("healing")
			for e in all(gr.targets) do
				e.poisoned=nil
				e.bleed=nil
				e.hp=min(e.hp+1,e.hp_max)
				fx_emote(e,"heart")
			end
			wait(30,nxt)			
		end				
		local tempo=45				
		for sq in all(get_zone(e.sq,e.healer)) do
			fx_twinkle(sq,tempo)
		end		
		sfx("twinkle")
		wait(tempo,heal)
		e.c_flh=tempo
	
	end

	if id=="swap" then
		sfx("swap_init")
		msg(lang.swap,90)
		local function swap()
			sfx("swap")
			local sqa=gr.a.sq
			local sqb=gr.b.sq				
			leave_sq(gr.a)
			leave_sq(gr.b)			
			goto_sq(gr.a,sqb,30)
			goto_sq(gr.b,sqa,30)			
			exhaust(gr.a)
			if gr.b.ready then
				exhaust(gr.b)
			end					
			wait(30, opp_move)			
		end
		
		local k=60
		gr.a.c_flh=k
		gr.b.c_flh=k				
		wait(k,swap)
	
	end

	if id=="push" then
		local function push(t)
			t=t or TEMPO
			if gr.k==0 then
				opp_move()
				return
			end
			
			local a={}
			local sq=e.sq
			while sq and sq.p do
				add(a,sq.p)
				sq=dsq(sq,gr.di)
			end

			if #a>1 then sfx("sokoban_push") end

			local last=a[#a]
			if t==TEMPO and last==hero and not dsq(last.sq,gr.di) then 
				fx_detect(60,e)
				wait(100,push,60)
				return
			end
			
			gr.k=gr.k-1
			local interrupt=false
			
			for i=#a,1,-1 do
				local p=a[i]
				p.crawl=p~=e
				if p.crawl then stun_piece(p) end
				local tsq=dsq(p.sq,gr.di)
				if tsq then
					goto_sq(p,tsq,t)
				else
					goto_fall(p,gr.di,t)
					interrupt=interrupt or p==hero
				end
			end
			if interrupt then return end
			wait(t+10,push)					
		end
		push()	
	end
	
	if id=="charge" then

		local path,sq,trg
		local function make_path()
			path={}
			sq,trg=e.sq
			while sq do
				sq=dsq(sq,gr.di)
				if not sq then
					add(path,"self fall")
					break
				elseif is_free(sq) then
					add(path,sq)
				else
					if sq.p then
						trg=sq.p
						local nsq=dsq(sq,gr.di)
						if not nsq then
							add(path,trg==hero and "hero fall" or "any fall" )
						elseif is_free(nsq) then
							add(path,"push")
						else
							add(path,"bump")
						end
					else
						add(path,"bump")
					end
					
					break
				end
			end
		end
		make_path()
		
		local tempo=12

		local function dash(first)
			
			if first then sfx("charge") end
		
			local sq=path[1]
			
			if not sq then -- tentative freeze fix
				make_path()
				sq=path[1]
				if not sq then
					opp_move()
				end
			end
			
			del(path,sq)
			
			if type(sq)~="string" then			
				e.crawl=true
				e.c_smoke=tempo
				goto_sq(e,sq,tempo,dash)
				tempo=max(flr(tempo*.75),4)
				return
			end

			if trg then
				screen_shake(4)
				sfx("hurt")
				e.c_shake=6
			end

			if sq=="self fall" then
				e.suicide=1
				goto_fall(e,gr.di)
				wait(60,opp_move)		
			elseif sq=="any fall" then
				goto_fall(trg,gr.di)
				wait(60,opp_move)
			elseif sq=="hero fall" then
				goto_fall(trg,gr.di)
			elseif sq=="push" then
				goto_sq(trg,dsq(trg.sq,gr.di),TEMPO,opp_move)
			else -- fail safe
				wait(5, opp_move)
			end

		
		end
		
		if path[#path]=="hero fall" then
			fx_detect(100,e)
			wait(100,dash,true)	
		else
			dash(true)

		end



		
		--[[

		local trg=get_hero_trg()
		local hsq=dsq(trg.sq,gr.di)
		
		local function dash()
			sfx("charge")
			local tempo=40
			local function push()
				screen_shake(4)
				sfx("hurt")
				e.c_shake=6
				if hsq then
					goto_sq(trg,hsq,TEMPO,nxt)							
				else
					goto_fall(trg,gr.di)							
				end
			end		
			e.crawl=true
			e.c_smoke=tempo
			goto_sq(e,gr.tsq,tempo,push)
			e.twcv=ease_in
		end
		
		if hsq or not trg.mastermind then
			dash()
		else
			fx_detect(100,e)
			wait(100,dash)
		end
		
		--]]
	
	end

	if id=="spawn" then
		
		local function f()
			sfx("spawner")
			local p=new_piece(gr.pid,true,gr.sq)
			p.x,p.y=e.x,e.y
			goto_sq(p,gr.sq,TEMPO,nxt)
			ach_count("spawn")
		end		
		fx_show_piece(e,30,f)

	
	end
	
	if id=="hop" then		
		if gr.bsq.p then
			gr.sq.hop_trg=gr.bsq.p
		end	
		goto_sq(e,gr.sq,TEMPO,nxt)
	end
	

end
function is_action_valid(gr,e)

	if gr.act=="atk" then
		--return false
	end

	if gr.act=="move" then	
		local a=get_range(e)
		for osq in all(a) do
			if osq==gr.sq then return true end
		end
		return false
	end
	
	if gr.act=="charge" then	
		local nsq=dsq(e.sq,gr.di)
		if not is_free(nsq) then return false end		
	end
	
	if gr.act=="swap" then
		if gr.a.dead or gr.b.dead or gr.a.falling or gr.b.falling then return end
	end
	
	if gr.act=="push" then
		local tsq=dsq(e.sq,gr.di)
		if not tsq or is_free(tsq) then return false end
	end



	return true
end

function xpl_king(e)
	if e.smoke_king then
		kl(e)
		fx_vanish(e)
		opp_move()
		return 
	end


	local function death()
		xpl(hero)	
		wait(30,mode.on_hero_death)
	end	
	black_mist_check(death)

end
function black_mist_check(death, survive)
	-- FIND SAFE SQUARE ( MIST )
	trace_heros_dists()
	local pcl=hero.cloaked
	hero.cloaked=nil
	init_safe_mode()
	local free_sq={}
	for sq in all(squares) do
		if is_free(sq) and (sq.penta and not sq.penta_off or sq.waypoint or #sq.danger==0) then
			add(free_sq,sq)
		end
	end
	hero.cloaked=pcl
	init_safe_mode()

	-- CHECK MIST
	local black_mist=get_slot_card_with("mist")
	local warden
	for sl in all(souls) do
		if sl.id==13 then
			warden=sl
		end
	end
	
	-- CHECK HEIR
	local heir
	if not black_mist and not warden then
		for p in all_pieces() do
			if not p.bad and not p.mastermind and not p.smoke_king and (p.role=="heir" and not heir or p.type==5) then
				heir=p
				break
			end
		end
	end
	
	if (not black_mist and not warden and not heir) or (#free_sq==0 and not heir) then
		death()
		return
	elseif survive then
		survive()
	end
	
	-- SAVE KING ( MIST )
	for e in all(bads) do e.ready=false end
	
	sfx("black_mist",.75)
	mode.mist_rescue=(mode.mist_rescue or 0)+1
	
	local twd=2
	local function sort (sq) 
		return abs(sq.wdist-twd)+abs(sq.y-hero.y)/100 
	end
	custom_sort(free_sq,sort)
	local tsq=heir and heir.sq or free_sq[1]	
	local tempo=30
	local pmax=64
	local sx,sy=hero.x,hero.y
	goto_sq(hero,tsq,0)
	hero.mist_build=0
	hero.detected=nil
	hero.crawl=nil
	start_lvl_music()
	
	if heir then
		hero.type=heir.type
		hero.behavior=clone(heir.behavior)
		hero.promote=heir.promote
		hero.role=heir.role
	end
	
	for i=1,pmax do
		local function pop()
			local p=mke(0,sx+4+rnd(8),sy+rnd(16))
			p.dp=DP_FX
			local ox,oy=p.x,p.y
			local r=1+irnd(2)
			p.dr=function(e,x,y)
				fillp(0x7D7D,true)
				circfill(x,y,r,1)
				fillp()
				ox,oy=x,y
			end
			local function f()
				kl(p)
				
				hero.mist_build=hero.mist_build+1
				if hero.mist_build==pmax then
					kl(heir)
					if hero.extra_turn then
						new_turn()
					else
						opp_move()
					end
					hero.mist_build=nil
				end
			end
			local tx=tsq.x+4+rnd(8)
			local ty=tsq.y+rnd(16)
			
			mvt(p,tx,ty,tempo+irnd(10),f)
			land=nil
			p.twcv=ease_in
			p.jmp=8+rnd(8)
		end
		wait(1+i/2,pop)		
	end
	
	--
	hero.z=0
	hero.dp=DP_PIECES
	hero.falling=false
	if hero.deathcount_start then
		local function inc_countdown(n)
			sfx("inc_countdown")
			hero.deathcount_start=hero.deathcount_start+1
			if n>0 then wait(12,inc_countdown,n-1) end
		end
		inc_countdown(5)
	end
	
	if warden then
		exhaust_soul(warden)
	elseif black_mist then
		flip_card(black_mist)
	end
	
	
	-- TURN CARD
	--exhaust_card_with("mist")
end

-- TOOLS
function orth(a,b)
	return a.sq.px==b.sq.px or a.sq.py==b.sq.py
end
function is_orth_view(a,b)
	for di=0,3 do
		local sq=a.sq
		for n=0,8 do
			sq=dsq(sq,di,1)
			if not sq then break end
			if sq.p==b then return true end
			if sq.p then break end			
		end		
	end
	return false
end
function is_king(type)
	return type==5 or type==6
end
function fwait(t,f)
	local ev=wait(t,f)
	ev.perm=true
	return ev
end
function get_zone_targets(sq,ray,chk)
	ray=ray or 1
	chk=chk or function(p) return p.bad end
	local a={}
	for sq in all(get_zone(sq,ray)) do 
		if sq.p and chk(sq.p) then
			uadd(a,sq.p)
		end
	end
	return a	
end
function get_zone(sq,ray,chk)
	chk=chk or function(sq) return true end
	local a={}
	for dx=-ray,ray do for dy=-ray,ray do 
		local x=sq.px+dx
		local y=sq.py+dy
		local sq=gsq(x,y)
		if sq and chk(sq) then add(a,sq) end
	end end
	return a	
end
function get_real_bads()
	local a={}
	for b in all(bads) do
		if not b.inert then add(a,b) end
	end
	return a
end
function all_bads()
	return all(get_real_bads())
end
function all_pieces()
	local a={}
	for p in all(ents) do
		if p.piece then add(a,p) end
	end
	return all(a)
end
function get_piece_squares(e)
	
	local a={}
	
	if e.big then
	
		local k={0,0,1,0,1,1,0,1}
		for di=0,3 do
			local sq=gsq(e.sq.px+k[di*2+1],e.sq.py+k[di*2+2])
			if sq then add(a,sq) end
		end

	else
		add(a,e.sq)
	end
	
	return a
end
function is_piece(e,name)
	return e.name==name or name=="all" or (name=="leader" and e.type==leader) 
end
function is_hero_close(e)
	local tsq=get_hero_sq()
	if not tsq then return false end	
	for sq in all(get_piece_squares(e)) do
		if max(abs(tsq.px-sq.px),abs(tsq.py-sq.py))<=1 then return true end
	end
	return false

end
function is_type(e,id)
	return e.type==id or (id==8 and e.type==get_leader_type())
end
function survive_sheath(e)
	if not e.sheath then return true end
	local sheath_dmg=stack.sheath or 0
	if e.bleed then sheath_dmg=sheath_dmg+1 end
	return sheath_dmg<e.hp 
end

-- SPECIFIC MECHANICS
function is_bow_ready(e)
	return e.bow and e.arrow_count and e.arrow_count>=e.arrow_limit
end
function get_carry_list(e)

	--if not e.carry then return {} end
	
	local function chk(p) 
		if not p or p.bad~=e.bad or p.in_move  or p.big then return false end
		if e.carry then
			return p.type~=1 and p.type~=3
		elseif e.carryking then
			return p.type==5
		end		
	end
	
	
	local a={}	
	for di=0,7 do
		local sq=dsq(e.sq,di)
		local p=sq and sq.p
		if chk(p) then add(a,p) end
	end
	return a
end
function carry_nearby_pieces(e,to)	
	local from=e.sq
	local dx=to.px-from.px
	local dy=to.py-from.py
	local a=get_carry_list(e)
	for p in all(a) do		
		local tsq=gsq(p.sq.px+dx,p.sq.py+dy)
		if is_free(tsq) then				
			p.ready=false
			if p.cd<1 then p.cd=1 end
			p.c_carry=TEMPO --c_flh
			goto_sq(p,tsq,TEMPO)
		end	
	end
end


-- EVENTS
function play_events(nxt,a)	
	local events=events or a

	--[[
	-- END LEVEL
	if #get_real_bads()==0 and not (hero.lift and hero.lift.bad) and mode.on_empty and not boss then --and mode.id~="tutorial"
		if not mode.on_empty() then 
			wlog("finish floor "..mode.lvl.." on turn "..mode.turns)
			return true 
		end
	end

	-- PENTAGRAM STAND
	local hsq=hero.sq
	if stack.pentagrams and hsq.penta and not hsq.penta_off then
		earn_extra_turn(true)
		hsq.penta_off=true
		hero.penta_count=hero.penta_count and hero.penta_count+1 or 1
		sfx("penta")				
		if hero.penta_count==3 then-- then stack.pentagrams then
			local function evolve()
				hero.c_warn=30
				hero.c_burning=30
				hero.penta_count=0
				sfx("penta_full")
				uplift({firepower=2})
				wait(30,nxt)
				hero.need_penta_reset=true
			end
			wait(40,evolve)
		else
			nxt()	
		end
		return true
	elseif hero.need_penta_reset and hsq.penta==nil then
		hero.need_penta_reset=false
		sfx("penta_reset")
		local function lp(ev)
			for sq in all(squares) do sq.penta_off=ev.t%6>=3 end
		end
		loop(lp,24,nxt)
		return true
	end
	
	-- WAYPOINTS
	if stack.waypoint and hsq.waypoint then
		hsq.waypoint,waypoint=nil
		ask_disrupt(nxt)
		return true
	end	
	
	-- CHECK SPY
	for di=0,3 do
		local nsq=dsq(hsq,di)
		if nsq and nsq.p and nsq.p.role=="spy" then
			reveal_spy(nsq.p,nxt)		
			return true
		end
	end
	
	--]]
	
	-- ACTUALLY CHECK EVENTS
	if #events==0 then return false end
	event_nxt=nxt or event_nxt
	local f=events[1]
	del(events,f)
	f()
	return true
end
function direct_event(nxt,f,a,b,c)
	event_nxt=function()
		event_nxt=nil
		exe(nxt)
	end
	f(a,b,c)
end
function add_event(func,a,b,c,d,e,f,g)
	add(events,bind(func,a,b,c,d,e,f,g))
end

function perma_checks(nxt)
	
	
	-- END LEVEL
	if #get_real_bads()==0 and not (hero.lift and hero.lift.bad) and mode.on_empty and not boss then --and mode.id~="tutorial"
		if not mode.on_empty() then 
			wlog("finish floor "..mode.lvl.." on turn "..mode.turns)
			return true 
		end
	end

	-- PENTAGRAM STAND
	local hsq=hero.sq
	if stack.pentagrams and hsq.penta and not hsq.penta_off then
		earn_extra_turn(true)
		hsq.penta_off=true
		hero.penta_count=hero.penta_count and hero.penta_count+1 or 1
		sfx("penta")				
		if hero.penta_count==3 then-- then stack.pentagrams then
			local function evolve()
				hero.c_warn=30
				hero.c_burning=30
				hero.penta_count=0
				sfx("penta_full")
				uplift({firepower=2})
				wait(30,nxt)
				hero.need_penta_reset=true
			end
			wait(40,evolve)
		else
			nxt()	
		end
		return true
	elseif hero.need_penta_reset and hsq.penta==nil then
		hero.need_penta_reset=false
		sfx("penta_reset")
		local function lp(ev)
			for sq in all(squares) do sq.penta_off=ev.t%6>=3 end
		end
		loop(lp,24,nxt)
		return true
	end
	
	-- WAYPOINTS
	if stack.waypoint and hsq.waypoint then
		hsq.waypoint,waypoint=nil
		ask_disrupt(nxt)
		return true
	end	
	
	-- CHECK SPY
	for di=0,3 do
		local nsq=dsq(hsq,di)
		local p=nsq and nsq.p
		if p and p.role=="spy" and not p.spied then
			reveal_spy(p,nxt)		
			return true
		end		
	end
	
	-- CENSORSHIP
	local hsq=get_hero_sq()
	for p in all(hsq.danger) do if p.censor and not p.censor_done then
		p.censor_done=1
		
		local opt={}		
		local free={}
		local marked={}
		for ca in all(get_slot_cards()) do
			if ca.team==0 then
				add(ca.marked and marked or free,ca)
			end
		end		
		if #marked>0 then add(opt,"purge") end
		if #free>0 then add(opt,"heresy") end		
		local aid=rnd(opt)
		if aid then
			local work
			if aid=="heresy" then
				--add(cards,rnd(marked))
				local ca=rnd(free)
				work=function()
					local function f()
						sfx("mark_card")
						ca.marked=1
						wait(30,nxt)
					end					
					show_card(ca,f,60)
				end
			elseif aid=="purge" then
				work=function()
					if #marked==0 then nxt()	return end
					local ca=steal(marked)
					ca.marked=nil
					sfx("censor_card")
					flip_card(ca,work)
				end
			else
				wait(30,nxt)
			end

			sfx("censorship")
			fx_emote(p,get_lang(aid),60,work)
			
			return true			
		end
		
		--[[
		if #a>0 then
			local function f()
				sfx("censor_card")
				hero.censored=1
				flip_card(rnd(a))
				wait(30,nxt)
			end
			p.c_warn=90
			fx_emote(p,get_lang("heresy"),60,f)		-- repent, purge, silence
			sfx("censorship")
			return true
		end
		--]]
	
	end end


	-- EXILE
	for ca in all(get_slot_cards()) do
		if ca.exile and mode.turns>=ca.exile then 
			local bishop
			for p in all(bads) do 
				if p.type==2 then bishop=p end			
			end
			if bishop then	
				local function flip()
					sfx("censor_card")
					flip_card(ca,nxt)
				end			
				function show()
					show_card(ca,flip,60)				
				end
				sfx("exile")
				fx_emote(bishop,get_lang"exile",60,show)
				bishop.c_warn=60				
				return true				
			end
			
		end
	end
	
	--
	return false

end

function ev_surrender()
	wlog("apply ev_surrender on floor "..mode.lvl.." on turn "..mode.turns)
	storm(event_nxt)
end
function ev_promote(e,ready,a,txt)

	-- PROMOTION ANNULEE !!
	if not e.sq or e.dead or e.falling then
		event_nxt()	
		return
	end
	
	--
	mode.pawn_promoted=true
	local ca,jumps=get_card_with("reform")
	for ca in all(jumps) do flip_card(ca) end	
	

	a= a or {1,2,3,4}
	del(a,e.type)
	if stack.force_promote then a={stack.force_promote} end
	if e.role=="spy" then del(a,5) end
	if stack.heirprom and e.role=="heir" then 
		a={5} 
		e.role=nil
	end
	
	
	-- AFTER
	local p
	function on_prom()
		if p.role=="spy" then --  and p.type~=5 
			p.role=nil
			convert(p,event_nxt)
		else
			event_nxt()
		end
	end
	
	-- MORPH
	p=morph_to(e,steal(a) or 0,on_prom,txt)
	if e.jester then
		local a={}
		for b in all(bads) do
			if b.type==0 then add(a,b) end
		end
		local b=steal(a)
		if b then
			jesterize(b)
		end	
	end

	
	-- ONBOARDING 
	if stack.onboarding then
		local ca,jumps=get_card_with("jumpy",1,true)
		for ca in all(jumps) do unflip_card(ca) end
	end

	--
	if ready then
		p.cd=get_piece_tempo(p)
		p.ready=true
	end
	
	

end
function ev_backup(ca,sca)

	if hero.win then
		event_nxt()
		return
	end
	
	
	if sca then
		show_card(sca,bind(ev_backup,ca),60)
		return
	end
	

	-- SEEK FREE SQUARES
	local free={}
	for x=0,7 do
		local sq=gsq(x,0)
		if is_free(sq) then add(free,sq) end
	end
	
	-- NO FREE SPACE
	--if #free==0 then	event_nxt() return end


	local tempo=32
	msg(get_lang(ca.id),tempo+16)
	sfx("conscription",.75)
	ca.c_turn_count=TEMPO

	for tp in all(ca.gain) do
		local sq=steal(free)
		if sq then
			local p=new_piece(tp,true,sq)
			p.y=p.y-16
			p.c_fade_in=TEMPO
			mv(p,0,16,TEMPO)
		else
			add(backups,tp)			
		end		
	end
	local function f()
		if ca.cycle then 
			ca.turn_count=0
		end
		event_nxt()
	end
	
	-- ONBOARDING
	if stack.onboarding then
		local ca,jumps=get_card_with("jumpy",1,true)
		for ca in all(jumps) do unflip_card(ca) end
	end
	
	
	
	
	wait(tempo,f)
	
end
function ev_reveal_heir()
	
	-- SECURITY CHECK
	local heir=seek_role("heir")
	if not heir then
		if hero.win and not tbl_has(events,ev_surrender) then
			add_event(ev_surrender)
		end
		
		event_nxt()
		return
	end

	msg(lang.heir_promote)
	sfx("legacy",60)

	local function prom()
		sfx("promote")
		local hsq=heir.sq
		kl(heir)
		del(bads,heir)
		
		hero.win=false
		local p=new_piece(leader,true,hsq)
		p.c_promoted=60		
		wait(60,event_nxt)
	end

	heir.reveal=true
	wait(90,prom)
	
end
function ev_raise_dead(sq,bid)

	sq.reserved=false	
	-- ABORT IF PIECE ABOVE
	if sq.p then
		wait(2,event_nxt)
		return
	end
	
	
	local tempo=60
	local p=new_piece(bid,true,sq)
	p.c_raise=tempo	
	wait(tempo,event_nxt)

end
function ev_rat_atk(rat)
	
	local trg=get_nearest_piece(rat.sq)

	if not trg then
		rat.life=30
		rat.blink=30
		event_nxt()
		return
	end

	
	local function impact()
		kl(rat)
		hit(trg,1,{direct=rat_dmg or 1,bleed=stack.rat_bleed})
		wait(2,event_nxt)	
	end
	mvt(rat,trg.x+8,trg.y+8,-1,impact)


	
	
	
	
	
	
end
function ev_side_spawn(gain)
	gain=tbz(gain)
	--sfx("conscription",.75)
	
	-- SEEK FREE SQUARES
	local free={}
	for k=0,1 do for x=0,7 do for y=0,7,7 do			
			local sq=k==1 and gsq(x,y) or gsq(y,x)
			if is_free(sq) then uadd(free,sq) end
	end end end
	
	-- SPAWN PIECES
	for tp in all(gain) do
		local sq=steal(free)
		if not sq then break end
		local p=new_piece(tp,true,sq)
		
		local fdi=0
		for di=0,3 do
			if dsq(sq,di)==nil then 
				fdi=di
			end
		end
		local dx=DIR[fdi*2+1]*16
		local dy=DIR[fdi*2+2]*16
		
		p.x=p.x+dx
		p.y=p.y+dy
		p.c_fade_in=TEMPO
		mv(p,-dx,-dy,TEMPO)		
		
		
	end
	
	event_nxt()
	
end
function ev_spawn_item(id)


	local item_names={"ammo_box"}
	for i=1,#item_names do item_names[item_names[i]]=i-1 end

	
	-- FIND FREE SQUARE
	local free={}
	for sq in all(squares) do 
		if not sq.it and sq.kdist>=4 then add(free,sq) end
	end
	if #free==0 then
		event_nxt()
		return
	end
	local sq=rnd(free)
	
	
	local sats={}
	for i=0,2 do
		local e=mke()
		e.ysort_dy=15
		e.z=-3
		e.dr=function(e,x,y)
			brd(bind(sspr,4,56,3,7,x+7,y+5),1)
		end
		add(sats,e)
	end	
	
	local item=mke(0,sq.x,sq.y)
	item.id=id
	item.gid=item_names[gid]
	item.sq=sq
	item.upd=function()
		for i=1,3 do
			local e=sats[i]
			local a=(i+(t/20)%1)/3
			e.x=item.x+cos(a)*5
			e.y=item.y+sin(a)*4
		end
	end
	item.dr=function(e,x,y)

	end
	item.nxt=function()
		for e in all(sats) do kl(e) end
	end
	
	event_nxt()
	
	
	
	sq.it=item
	

end
function ev_talk(e,str)
	fx_emote(e,str)
	wait(60,event_nxt)
end
function ev_hit(e,n,at)
	hit(e,n,at)
	wait(60,event_nxt)
end
function ev_reload(single_reload)

	--if (chamber>=stack.chamber_max and not (stack.overload and chamber<8)) or ammo==0 then
	if chamber>=stack.chamber_max or ammo==0 then
		event_nxt()
		return
	end

	reload(single_reload)
	local function f(ev)
		if not reloading then
			wait(12,event_nxt)
			kl(ev)
		end
	end
	loop(f)

end
function ev_abort_mission()
	sfx("abort_mission")
	msg(lang.abort_mission,60,true)
	local tempo=30
	local sq=waypoint
	local e=mke()
	e.dp=DP_FX
	e.life=tempo
	e.dr=function(e,x,y)
		local c=e.life/tempo
		circ(sq.x+8,sq.y+8,8+c*c*16,5)
	end
	e.nxt=function()
		sq.waypoint=nil		
		waypoint=nil		
		wait(30,event_nxt)
	end
	
end
function ev_vampire(vamp)

	if vamp.dead or not vamp.sq then	-- patch
		event_nxt()
		return
	end

	local z
	if vamp.big then
		local px,py=vamp.sq.px,vamp.sq.py
		local ds={{-1,0},{-1,1},{0,-1},{1,-1},{2,0},{2,1},{0,2},{1,2}}
		z={}
		for _,d in pairs(ds) do
			add(z,gsq(px+d[1],py+d[2]))
		end
	else
		z=get_zone(vamp.sq,1)
	end
	
	--local z=get_zone(vamp.sq,1)
	local n=0
	for sq in all(z) do
		local p=sq.p
		if p and p.bleed then
			p.bleed=nil
			n=n+1
			local drop=mke(0,p.x+8,p.y+8)
			drop.dp=DP_FX
			drop.dr=function(e,x,y)
				sspr(178,76,3,4,x,y)
			end
			local function f() 
				_sfx("vampire_eat",nil,1,nil,1+hrnd(.1))
				kl(drop)
				n=n-1
				vamp.c_suck=4
				vamp.hp=min(vamp.hp+1,vamp.hp_max)
			end			
			mvt(drop,vamp.x+7,vamp.y+5,-.5,f)		
			drop.twcv=ease_in
			
		end
	end	
	if n>0 then sfx("vampire_suck") end

	local function f(ev)
		if n==0 then 
			kl(ev)
			event_nxt()
		end
	end	
	loop(f)
	
	
end
function ev_ask_for_help(e)
	if e.dead then event_nxt() return end
	
	local a={}
	for p in all(bads) do	if p.type==0 then add(a,p) end end
	if #a==0 then
		event_nxt()
		return
	end

	local function f(p) return dist(p,e) end
	custom_sort(a,f)
	sfx("help")
	fx_emote(e,lang.help)
	wait(60,ev_promote,a[1],true)

end
function ev_usurper(e)
	if e.dead then
		event_nxt()
		return
	end
	local oca=get_card_with("false_king",1,true)
	local function new_reign()
		
		local ca=new_card("Commoner's Reign")
		inc_stats(ca.id,true)
		
		
		ca.dp=DP_INTER
		ca.x=e.x-4--oca.x-8
		ca.y=e.y-8--oca.y-8		
		local z=-4
		ca.drs=function()
			local n=-z/2
			rectshade(ca.x+n,ca.y+n,24,32,-1)
		end
		
		
		local function f()
			ca.drs=nil
			
			local a={lang.power_people_0, lang.power_people_1, lang.power_people_2}
			
			fx_talk(e,a,event_nxt)
			
		end
		add_card(ca,f)
		
		sfx("hippocracy")
		fx_red_flash()
		screen_shake(8)
		
		
	end
	local function commoner_test()

		local leadersum=0		
		for b in all(bads) do if b.type==leader then leadersum=leadersum+1 end end
		if stack.false_king or leadersum>0 or not oca or stack.ruler then
			event_nxt()
			return
		end
		
		msg(lang.crowning,-1)
		tear_apart(oca)
		
		local crown=mke(0,e.x+8,e.y+10)
		local z=-48
		crown.dr=function(e,x,y)
			if e.t<16 and cyc(2,3)==0 then return end  
			y=y+z
			sspr(160,26,9,6,x-4,y-6)
		end
		crown.dp=DP_TOP
		crown.upd=function(e)
			if e.t%20==0 then _sfx("crown_fly",nil,1,nil,1+e.t/500) end
			z=z+1/4
			if z>-8 then
				kl(crown)
				new_reign()
			end			
		end
		crown.drs=function()
			shpr(27,5,5,3,crown.x-2,crown.y-1,-1)
		end			
			
	end
	morph_to(e,1,commoner_test,lang.usurper)
end
function ev_trampoline(e)
	
	local a=get_free_squares()
	local function f(a) return abs(a.px-4)+abs(a.py-4) end
	custom_sort(a,f)
	
	
	if #a==0 then
		kl(e)
		del(bads,e)
		event_nxt()
		return
	end

	e.hp=e.hp_max
	e.crawl=nil

	local sq=a[1]

	local function land()
		screen_shake(4)
		sfx("land")
		event_nxt()
	end
	
	local function up(ev)
		e.z=e.z-2
		if e.z<=0 then
			kl(ev)
			e.dp=DP_PIECES
			e.falling=nil			
			goto_sq(e,sq,60,land,64)
		end
	end
	sfx("trampoline")
	add(bads,e)
	loop(up)



end
function ev_piece_drop(sq,bid,bad)

	sq.reserved=false	
	if not is_free(sq) then
		sq=get_nearest_free_square(sq)
		if not sq then
			wait(2,event_nxt)
			return
		end		
	end
	sfx("drop_piece")
	local p=new_piece(bid,bad,sq)
	p.z=-32
	p.c_blink=64
	local function f(ev)
		local c=ev.t/64
		p.z=-32*(1-c)
	end
	local function land()
		p.c_flh=30
		event_nxt()
	end
	loop(f,64,land)
	
	--wait(60,event_nxt)

	
end
function ev_death(e)
	if e.hp<=0 then	
		xpl(e) 
	else
		e.dead=nil
	end
	event_nxt()
end

function storm(f)
	
	fast_tracker(true, 5)
	
	inter.storming=true
	
	local rb=get_real_bads()
	if hero.lift and hero.lift.bad then
		hero.lift.x=hero.x+8
		hero.lift.y=hero.y+2
		add(rb,hero.lift)
	end
	for e in all(rb) do if e.stormed then del(rb,e) end end
	
	
	if #rb==0 then
		inter.storming=false
		f()
		return
	end
	
	local e=rb[1]
	
	
	if e.chosen then
		fast_tracker(false)
		del(bads,e)
		
		sfx("xpl")
			
		if e.type==4 then
			sfx("dmg_cap")
			e.iron=nil
			e.c_warn=90
			tear_apart("Iron Maiden")
			for i=0,1 do
				local p=mke(0,i*8,-2)
				add_child(e,p)
				p.dr=function(e,x,y)
					sspr(160+8*i,448,8,16,x,y)
				end
				p.life=60
				p.blink=30				
				mv(p,(i*2-1)*8,0,60)			
			end
		elseif e.type==1 then
			sfx("apo_sing_"..irnd(4))
			kl(e)
			local p=new_piece(11,true,e.wsq)
			p.stormed=true
			p.c_shake=12
			p.c_hit=120
		else
			sfx("bishop_resist")
			e.bad=false
			e.c_bishop_mute=60
		end
		
	else
		e.bury=true
		xpl(e)
		if hero.lift==e then hero.lift=nil end
	end
	wait(30,storm,f)	
	screen_shake(4)
	
	
	-- FLASH
	fx_red_flash()
	
	-- LIGHTNING
	local p=mke(0,e.x+8,e.y+10)
	local a={}
	local x,y=p.x,p.y
	local ec=8
	while y>-32 do
	add(a,{x=x,y=y})
	x=x+hrnd(ec)
	y=y-8-rnd(16+ec)
	ec=ec*1.5
	end
	p.life=10
	p.dp=DP_FX
	p.dr=function(e,x,y)
		
	
		for p in all(a) do
			line(x,y,p.x,p.y,sget(e.life,1))
			x,y=p.x,p.y
		end
		
	end
	

	
	-- SPARKS
	for i=0,8 do
		local p=mke(0,p.x,p.y)
		--p.dp=DP_FX
		impulse(p,rnd(1),2)
		p.frict=.75+rnd(.23)
		p.life=8+rnd(32)
		p.vz=-rnd(3)
		p.we=rnd(.05)
		p.dr=function(e,x,y)
			pset(x,y,5)
		end
		p.drs=function()
			local x,y=p.x,p.y
			pset(x,y,bright(pget(x,y),-1))
		end
	
	end

	-- CONTROLLER RUMBLE
	rumble(0, 0.4, 0.75, 0.12)
	
end

-- TOOLS
function morph_to(e,type,nxt,txt)
	txt=txt or lang.promote
	local osq=e.sq
	kl(e)
	del(bads,e)

	local p=new_piece(type,e.bad,osq)
	p.c_promoted=60
	p.prom_from=e.type
	p.role=e.role
	p.stun=e.stun
	p.sheath=e.sheath
	p.bleed=e.bleed
	
	-- for black heir reincarnation
	p.tracked=e.tracked
	p.mastermind=e.mastermind
	p.boost=e.boost
	p.frags=e.frags
	p.hop=e.hop
	p.free_souls=e.free_souls
	p.holoking=e.holoking
	p.deathcount_start=e.deathcount_start
	p.fail_final_escape=e.fail_final_escape
	p.bushido=e.bushido
	p.grenade_ready=e.grenade_ready
	p.an=e.an
	
	if e==hero then hero=p end
	
	p.z=e.z
	
	if p.z<0 then -- finishing landing
		local tempo=10
		local function landing(ev)
			local c=(ev.t/tempo)*.3+.7
			p.z=(c-1)*10-sin(c*.5)*12
		end
		loop(landing,tempo)
	end
	
	wait(60,nxt)
	
	fx_emote(p,txt)
	sfx("promote")	
	
	
	return p
end
function get_free_squares()
	local a={}
	for sq in all(squares) do if is_free(sq) then add(a,sq) end end
	return a
end
function get_nearest_free_square(sq)
	local a=get_free_squares()
	local function f(a) return abs(a.px-sq.px)+abs(a.py-sq.py) end
	custom_sort(a,f)		
	return a[1]
end
function convert(e,nxt)	

	fx_emote(e,get_lang("defect"))
	e.bad=false
	sfx("convert")
	e.c_convert=60
	del(bads,e)
	setup_piece(e)
	wait(60,nxt)
	
	if e.promote and e.sq.py==0 then
		add_event(ev_promote,e)
	end
	
end

-- ITEMS
function grab_item(it,nxt)

	if not it.dead then
		local function f()			
			it.sq.it=nil
			it.sq=nil
			kl(it)
			grab_item(it,nxt)
		end
		mvt(it,hero.x,hero.y,30,f)
		return
	end
	if it.id=="ammo_box" then	
		
		-- REINIT JUMPY CARDS
		local ca,jumps=get_card_with("jumpy",1,true)
		for ca in all(jumps) do unflip_card(ca) end

		-- FLIP ON CARDS		
		for sl in all(card_slots) do
			if sl.ca and sl.ca.flipped then
				unflip_card(sl.ca)
			end
		end	
		refill_ammo(nxt)		
	end

end

-- SPECIFICS
function reveal_spy(spy,nxt)


	if not spy or spy.dead or not spy.sq then
		nxt()
		return
	end
	sfx("legacy",60)	
	
	local tempo=90
	
	msg(lang.meet_spy,90)
	spy.c_flh=90

	
	local function f()
		--spy.role=nil
		spy.reveal=nil
		ask_disrupt(nxt)
	end
	
	
	spy.reveal=true
	spy.spied=true
	wait(90,f)
end
function show_regret(e)
	if not e.regret then return end

	fx_show_sq(e.regret,e.type)		
	e.regret=nil
	e.c_regret=60

	local ca=get_card_with("presence")
	show_card(ca,nil,30,nil,true)

end

-- GAMEOVER
function gameover(cbk)
	end_msg(lang.game_over,cbk or end_game)
end
function end_msg(s,nxt)

	-- ANIM
	local e=mke()
	e.dr=function(e,x,y)	
		local fntt=(fnt=="pico") and "old_console" or fnt
		local sle=safesize(s)
		local ec=10
		if fntt=="indienovaBC" then ec=16 end
		
		local sav = font()
		font(fntt)

		for i=1,sle do
			local k=safesub(s,i,i)
			local y=MCH/2-4			
			if e.t<90 then
				local c=1-e.t/90
				local r=32*ease_in(c)
				y=y+cos(c*3+i/sle)*r			
			end				
			brd( bind(print,k,(MCW/2-(sle-1)*ec/2)+(i-1)*ec,y,5), 4)
		end		
		font(sav)
	
	end
	e.dp=DP_INTER
	e.upd=function()
		if (mcl and e.t>60) or (e.t > 180) then
			e.upd=nil
			fade_to(-4,30,nxt)			
		end		
	end

end
function success_msg(s,nxt)

	-- ANIM
	local e=mke()
	e.dr=function(e,x,y)	
		local fntt=(fnt=="pico") and "old_console" or fnt
		local sle=safesize(s)
		local ec=10
		if fntt=="indienovaBC" then ec=16 end
		
		local sav = font()
		font(fntt)


		for i=1,sle do
			local k=safesub(s,i,i)
			local x=(MCW/2-(sle-1)*ec/2)+(i-1)*ec
			local y=MCH/2-6
			local z=.5+cos(i/sle+t/60)*2
			
			if e.t<90 then
				local c=1-e.t/90
				local d=ease_in_back(c)*96
				local a=i/sle+ease_out(c)
				x=x+cos(a)*d
				y=y+sin(a)*d
			end				
		
			brd( bind(print,k,x,y+z,4),3+cyc(2,3)*2)
			
	
			--shpr(20,12,7,4,x-3,y+16)
			
		end		
		font(sav)
	
	end
	e.dp=DP_INTER
	e.upd=function()
		if (mcl and e.t>60) or (e.t > 180) then
			e.upd=nil
			fade_to(-4,30,nxt)			
		end		
	end

end



-- BUTS
function mk_but(x,y,w,h,f)
	local e=mke(0,x,y)
	e.w,e.h=w,h
	e.left_clic=f
	e.button=true
	e.clicked=false
	e.dp=DP_INTER
	local inside=false
	e.upd=function()
		if btn"force_aim" then return end
		if cancel_but then return end

		local bx,by,par=x,y,e.par
		while par do
			bx=bx+par.x
			by=by+par.y
			par=par.par
		end

		local ins= mx>=bx and mx<bx+w and my>=by and my<by+h 
		if inside and (not ins or ctrl_mode == "aim") then 
			e.ov=false
			exe(e.out) 
		end
		if not inside and ins and ctrl_mode ~= "aim" then 
			e.ov=true
			exe(e.over)			
		end
		inside=ins
		if inside and mcl and ctrl_mode ~= "aim" then
			e.clicked=true
			exe(e.left_clic)
		end
		if inside and mcr and ctrl_mode ~= "aim" then exe(e.right_clic) end
		if inside and mlb then 
			exe(e.left_press)	
			if e.on_drag and not e.drag then		
				e.drag=true
				local function f(ev)
					if not mlb then 
						kl(ev)
						e.drag=false
					elseif ev.t>6 then 
						e.on_drag() 
						kl(ev)
					end
				end
				loop(f)
			end			
		end

		if inside and e.cover then
			cancel_but=1
		end

	end
	if SHOW_BUTS then
		e.dr=function(e,x,y)
			if cyc(2,3,_t)==0 then
				rect(x,y,x+w-1,y+h-1,5)
			end
		end
	end
	
	return e
end
function mk_sq_but(sq,f,icon,pm)
	local px,py=sqp(sq)
	e=mk_but(px,py,SQ,SQ,f)
	tbl_import(e,pm or {})
	e.dp=DP_FX
	e.issq=true
	local ov=false
	
	e.over=function()
		ov=true
		aiming=icon==8
		if MOUSE then
			if rov_sq~=sq or not rov_move then
				rov_move=icon and icon<8
			end
			
			rov_sq=sq
			rov=nil
			if sq.p then -- and sq.p.bad
				rov=not sq.p.inert and sq.p	or nil	
			end
		end

	end
	e.out=function()
		ov=false
		if rov_sq==sq and MOUSE then
			aiming=nil
			rov_move=nil
			rov=nil
			rov_sq=nil
		end
	end
	e.dr=function(e,x,y)
		

		if ov and icon then
		
			local function show_icon(icon,x,y,dc)
				if btn("force_aim") then return end
				if icon==10 or (icon>=82 and icon<90) then
					if icon==10 and not MOUSE and ctrl_mode~="select_soul" then
						return
					end
					
					y=y+cos(t/60+(dc or 0))*3-5.5
				end		
				if icon~=8 then
					spr(32+icon,x,y)
				end
			end
			show_icon(icon,x,y)
			for ico in all(e.extra_icons or {}) do
				show_icon(ico.fr,ico.sq.x,ico.sq.y,ico.dc)
			end
		end
		

		if SHOW_BUTS then
			if t%2==0 then
				rectfill(x,y,x+SQ-1,y+SQ-1,5)
			end
		end
	end
	--if sq.but and sq.but.pad_move then log("pad_move crushed") end
	return e
end
function mk_hint_but(x,y,w,h,str,a,b,c,d)
	
	local get_str= type(str)=="function" and str or function() return str end
	local but=mk_but(x,y,w,h)
	but.over=function()
		hint_but=but
		show_hint(get_str(),a,b,c,d)
	end
	but.out=function()
		if hint_but==but then
			hint_but=nil
			hide_hint()
		end
	end
	return but
end
function remove_buts()
	
	hide_hint()
	selecting=false
	timerun=false
	playing=false
	leveling=false
	aiming=false
	show_best_floor,rov,rov_slash=nil
	for e in all(ents) do
		if e.button then del(ents,e) end
	end
	
	for sq in all(squares or {}) do	
		sq.selectable=false
		sq.show=false
		sq.imprint=false
		sq.pad_but=nil
	end	
	
	local function rec_del(a)
		for e in all(a) do
			if e.button then del(a,e) end
			if e.ents then rec_del(e.ents) end
			if e.ui_show then e.ui_show=nil end
		end		
	end
	rec_del(ents)
	
	
	--
	if mode then	
		mode.track_but=nil
	end
	if pad_cursor then
		kl(pad_cursor)
		pad_cursor=nil
	end
	
end

-- ENTS
function mke(fr,x,y)
 local e={
	fr=fr or -1,
	x=x or 0,
	y=y or 0,
	t=0,vx=0,vy=0,we=0,frict=1,
	dcx=0,dcy=0,
	ww=16,hh=16,
	dp=DP_PIECES,
	flx=false,fly=false,
 } 
 add(ents,e)
 return e
end
function upe(e)

	e.t=e.t+1

	-- physics
	e.vx=e.vx*e.frict
	e.vy=e.vy*e.frict
	
	e.x=e.x+e.vx
	e.y=e.y+e.vy
	if e.vz then
		e.vz=e.vz*e.frict
		e.z=(e.z or 0 )+e.vz
		e.vz=e.vz+e.we
		
	else
		e.vy=e.vy+e.we
	end

	e.dcx=e.dcx*.9
	e.dcy=e.dcy*.9
	if abs(e.dcx)<1 then e.dcx=0 end
	if abs(e.dcy)<1 then e.dcy=0 end

	-- update
	if e.upd then e.upd(e) end

	if e.sync_upd and e.c_sync then e.sync_upd(e) end

 --	tweens
	if e.twc then
		local c=min(e.twc+1/e.tws,1)
		cc=e.twcv and e.twcv(c) or c
		e.x=e.sx+(e.ex-e.sx)*cc
		e.y=e.sy+(e.ey-e.sy)*cc
		if e.jmp then
			local k=sin(c/2)*e.jmp
			local a=e.jma or -.25
			e.x=e.x+cos(a)*k
			e.y=e.y+sin(a)*k
		end	
		if e.spiral then
			local ray=sin(c/2)*80
			local an=.5+cc*3
			e.x=e.x+cos(an)*ray
			e.y=e.y+sin(an)*ray
		end
		e.twc=c	
		if c==1 then
			e.twc=nil
			e.jmp=nil
			e.twcv=nil
			local f=e.twf
			if f then
				e.twf=nil
				f()
			end
		end
	end	

 
 -- update childs
	if e.ents then
		for e in all(e.ents) do upe(e) end
	end
 
 
	-- counters
	for v,n in pairs(e) do	if sub(v,1,2)=="c_" then
		n=n+(e.rev_c and 1 or -1)
		e[v]= n>0 and n or nil

	end end

 -- life
	if e.life then
		e.life=e.life-1
		if e.life<=0 then
			kl(e)
		end
	end 

 
end
function dre(e,ddx,ddy)
	
	if e.blink and e.life<e.blink and e.t%6<3 then return end
	if e.c_blink and e.t%3<1 then return end
	if e.invis then return end
	
	local x=(ddx or 0)+e.x+e.dcx
	local y=(ddy or 0)+e.y+e.dcy+(e.z and e.z or 0)
	local flx=e.flx
	local fly=e.fly

	if e.ovl then y=y-1 end

	
	--if e.c_hit and t%6<3 then	apal(5)	end

	-- CLIP
	if e.clp then
		clip(e.clp.x,e.clp.y,e.clp.w,e.clp.h)
	end


	-- DRAW
	if e.fr>0 then
		
		spr(e.fr,flr(x),flr(y),e.ww/16,e.hh/16,flx,fly)
	end		
	if e.dr then e.dr(e,x,y) end
 
	--
	-- CLIP
	if e.clp then clip() end	
	pal_rst()
 
	-- draw childs 	
	if e.ents and not e.child_invis then 
		
		--[[
		tcamera(-x,-y)
		foreach(e.ents,dre)
		tcamera(x,y)
		--]]
		for e in all(e.ents) do
			dre(e,x,y)
		
		end
		
		
	end
	


end
function kl(e)
	
	if not e then return end
	e.dead=true
	
	if e.sq and e.sq.p==e then
		leave_sq(e)
	end
	
	del(e.par and e.par.ents or ents ,e)
	if e.reg_tables then for a in all(e.reg_tables) do
		del(a,e)
	end end	
	
	if e.nxt then
		local f=e.nxt
		e.nxt=nil
		f()
	end 
end

-- ENGINE
function _update()

	_t=_t+1
	cancel_but=nil

	-- FRAME DROP
	local skip=false
	if frame_drop then
		if frame_drop.n>0 then
			frame_drop.n=frame_drop.n-1
			skip=true
		else
			frame_drop.wt=frame_drop.wt*frame_drop.frict
			frame_drop.n=frame_drop.wt
			if frame_drop.n<1 then
				frame_drop=nil
			end
		end		
	end

	
	-- LOOP
	local function lp()
		gamepad_ctrl()
		
		if pause or skip or frz then
			for e in all(ents) do
				if e.perm then upe(e) end
			end
		else
			t=t+1
			foreach(ents,upe)	
			foreach(ents_ach,upe)	
		end
	
	end
	local fst=fast
	if btn("speed_up") and DEV then fst=10 end
	
	if btn("speed_down") and  DEV then
		if _t%10==0 then lp() end
	elseif fst then
		for i=1,fst do lp() end		
	else
		lp()
	end
	target()
	
	-- CONTROL
	if DEV and not CONSOLE and btnp("r") then
		boot()
	end
	
	if ingame and playing and btnp("pause") then
		if pause or inter.c_unpause==20 then
			unpause()
		else
			sfx("pause")
			pause=true
			local a={}
			for opt in all(OPTIONS) do add(a,opt.id)	end
			if CONSOLE then del(a,"fullscren") end
			if current_lang ~= "english" then del(a,"HD text") end

			del(a,"lang")
			del(a,"mod")
			if mode.id ~= "throne" then
				del(a,"speedrun")
			end
			if mode.id == "tutorial" then
				del(a,"shields")
				add(a,"skip_tutorial")
			else
				add(a,"resign")
			end
			add(a,"save_back")
			open_menu(a)		
			
		end
	end

end
function _draw()

	target()

	
	cls(0)
	camera()
	fillp()
	
	
	exe(mdr or (function()foreach(ents,dre)end) )	
	exe(function()foreach(ents_ach,dre)end)	

	-- FADE
	if fd~=0 then
		if fd==6 and fast then
			local c = sget(17,4+fd)
			rect(0,0,MCW-1,MCH-1,c)
			rect(1,1,MCW-2,MCH-2,c)
			rect(2,2,MCW-3,MCH-3,c)
			rect(3,3,MCW-4,MCH-4,c)
		else
			for i=0,9 do pal(i,sget(16+i,mid(1,4+fd,11)),true) end 
		end
	end		
	
	pal(FORCE_DARK,2,true)
	pal(FORCE_MEDIUM,3,true)
	pal(FORCE_BRIGHT,4,true)

	-- WRONG RED FLASH
	if hero and hero.c_wrong and SET.scrflash==1 and t%6<3 then
		rect(0,0,MCW-1,MCH-1,5)
		rect(1,1,MCW-2,MCH-2,5)
	end
	
	
	--
	camera()

	


	local ly=0
	for s in all(logs) do
		print(s,22,ly,5)
		ly=ly+8
	end
	
end
function log(s,clean)

	if type(s)=="boolean" then
		s=s and "true" or "false"
	end

	if clean then logs={} end
	add(logs,s.."")
	if #logs>20 then del(logs,logs[1]) end
end


-- COMMON
function brd(f,col)
	apal(col)
	_pal=pal
	pal=function() end
	tcamera(1,0)
	f()
	tcamera(-1,1)
	f()
	tcamera(-1,-1)
	f()
	tcamera(1,-1)
	f(true)
	tcamera(0,1)
	pal=_pal
	pal_rst()
	f()
end
function fbrd(f,col)
	apal(col)
	_pal=pal
	pal=function() end
	tcamera(1,0)
	f()
	tcamera(0,1)
	f()
	tcamera(-1,0)
	f()
	tcamera(-1,0)
	f()
	tcamera(0,-1)
	f()
	tcamera(0,-1)
	f()
	tcamera(1,0)
	f()
	tcamera(1,0)
	f()
	tcamera(-1,1)
	pal=_pal
	pal_rst()
	f()
end
function get_patterns(x,y,n)
	local a={}
	local ns={1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768}
	for i=0,n-1 do
		local k=0
		for j=0,15 do
			local px=x+i*4+j%4
			local py=y+flr(j/4)
			if sget(px,py)>0 then k=k+ns[j+1]	end		
		end
		add(a,k)
	end
	return a

end
function inv_kin(ax,ay,bx,by,sc,sa,s)	
	s=s or 1
	local dx,dy=ax-bx,ay-by
	local sb=sqrt(dx*dx+dy*dy)	
	local an=atan2(dx,dy)+tri_angle(sa,sb,sc)*s+.5
	local x=ax+cos(an)*sc
	local y=ay+sin(an)*sc	
	return x,y	
end
function tri_angle(a,b,c)
	return acos( mid(-1,(b^2+c^2-a^2)/(2*b*c),1) )
end
function listord(s)
	local str=""
	for i=1,#s do
		local n=ord(sub(s,i,i))
		str=str..n..","
	end
	return str
end
function uppercase(s)
	local str=""
	i=1
	repeat
		local n=ord(sub(s,i,i))
		if n==0xD0 or n==0xD1 then
			local cyrn=ord(sub(s,i+1,i+1))
			if n==0xD0 and (cyrn>=0xB0 and cyrn<=0xBF) then
				cyrn=cyrn-32
			elseif n==0xD1 and (cyrn>=0x80 and cyrn<=0x8F) then
				n=0xD0
				cyrn=cyrn+32
			elseif n==0xD1 and (cyrn>=0x90 and cyrn<=0x9F) then
				n=0xD0
				cyrn=cyrn-16
			end
			str=str..chr(n)..chr(cyrn)
			i=i+2
		else
			if n>=97 and n<=122 then
				n=n-32
			end
			i=i+1
			str=str..chr(n)
		end
	until i>#s
	return str
end
function lowercase(s)
	if s=="" then return "" end
	local str=""
	i=1
	repeat
		local n=ord(sub(s,i,i))
		if n==0xD0 or n==0xD1 then
			local cyrn=ord(sub(s,i+1,i+1))
			if n==0xD0 and (cyrn>=0x80 and cyrn<=0x8F) then
				n=0xD1
				cyrn=cyrn+16
			elseif n==0xD0 and (cyrn>=0x90 and cyrn<=0x9F) then
				cyrn=cyrn+32
			elseif n==0xD0 and (cyrn>=0xA0 and cyrn<=0xAF) then
				n=0xD1
				cyrn=cyrn-32 -- = + 32 - 64 (block + 1)
			end
			str=str..chr(n)..chr(cyrn)
			i=i+2
		else
			if n>=65 and n<=90 then
				n=n+32
			end
			str=str..chr(n)
			i=i+1
		end
	until i>#s
	return str
end
function first_upper(s)
	local n=ord(sub(s,1,1))
	if n>=0xC2 and n<=0xDF then
		return uppercase(sub(s,1,2))..sub(s,3)
	else
		return uppercase(sub(s,1,1))..sub(s,2)
	end
end

-- PAL
function bright(k,n)
	--return mid(1,k+n,4)
	return sget(16+k,mid(1,4+n,8))
end
function pal_inc(k)
	for i=0,9 do pal(i,sget(16+i,mid(1,4+k,8))) end
end
function pal_rst()
	for i=0,9 do pal(i,i) pal(i,i,1) end
	for i=1,9 do palt(i,false) end
	palt(0,true)
	sfillp(1,0,1)
end
function shpr(px,py,pw,ph,x,y,inc)
	inc=inc or -1
	for dx=0,pw-1 do for dy=0,ph-1 do
		if sget(px+dx,py+dy)>0 then
			pset(x+dx,y+dy, bright(pget(x+dx,y+dy),inc) )
		end		
	end end
end
function rectshade(px,py,ww,hh,n)
	local n=n or -1
	for i=0,5 do blend(1,i,bright(i,n)) end
	rectfill(px,py,px+ww-1,py+hh-1,1)
	for i=0,5 do blend(1,i,1) end
end
function rectshadeopti(px,py,ww,hh)
	local n=-2
	for i=0,5 do blend(1,i,bright(i,n)) end
	rectfill(px,py,px+ww-1,py+hh-1,1)
	for i=0,5 do blend(1,i,1) end
end
function rectshade_dither(px,py,ww,hh,n,dith)
	n=n or -1
	fillp(pat[dith], true)
	for i=0,5 do blend(1,i,bright(i,n)) end
	rectfill(px,py,px+ww-1,py+hh-1,1)
	for i=0,5 do blend(1,i,1) end
	fillp()
end
function blend_light(src,inc)
	blended=blended or {}
	if not src then
		for src in all(blended) do
			for dst=0,CLM-1 do
				blend(src,dst,src)
			end	
		end	
		return
	end	
	uadd(blended,src)	
	local function f(dst) 
		return bright(dst,inc) 
	end
	for dst=0,CLM-1 do
		blend(src,dst,f(dst))
	end
end

-- FADE
function fade_to(n,tempo,nxt,from) 
	
	local sn=from or fd
	fd=sn
	
	local f=function(e) 
		fd=sn+(n-sn)*e.t/tempo
	end 
	local ev=loop(f,tempo,nxt)
	ev.pause_act=true

end

-- TEXT
function write_big_at(s,x,y,cl)
	if cl then pal(21,cl) end
	s=s..""
	for i=1,#s do
		local k=ord(sub(s,i,i))-32-1
		sspr((k%32)*6,84+flr(k/32)*7,6,7,x+(i-1)*6,y)	
	end
	if cl then pal_rst() end
end
function slicer(s,max_width,cc)

	cc=cc or 99999
	
	s=join(split(s,"|")," | ")	
	local cut=split(s," ")		
	local res={}
	local s=""
	for i=1,#cut do
		local k=cut[i]
		if k=="|" then k="" end
		if (#s+#k+1)*4<=max_width and #k>0 then
			s=s..(#s==0 and "" or " ")..k
		else
			if #s>cc then 
				add(res,sub(s,1,cc)) 
				return res
			end		
			add(res,s)
			cc=cc-#s
			s=k
		end			
	end
	if #s>cc then s=sub(s,1,cc) end		
	add(res,s)
	return res
	
end

-- DEV
function dev_right_click_sq(sq)

end
function dev_right_click_piece(p)
	--SHOW_PDIST=p
	if scanp then kl(scanp) end
	scanp=mke()
	scanp.dp=DP_FX
	scanp.dr=function()

		-- SHOW GRIDS SCORES
		for sq,gr in pairs(p.grids or {}) do
			local sco=flr(gr.score*10)/10
			lprint(sco,sq.x+1,sq.y+1,4+cyc(2,3))			
		end

		
		--[[ SHOW CHOSEN MOVE DANGERS
		if p.fgr then
			for sq,dan in pairs(p.fgr.dangers or {}) do
				if dan>0 then lprint(dan,sq.x+1,sq.y+1,4+cyc(2,3)) end	
			end
		end
		--]]
		
	end
	
	
end

-- FAST TRACKER
do
	local tracker
	local speed
	local function f(ev)
		if mcl then 
			fast=speed
		end
	end
	
	function fast_tracker(enable, spd)
		if enable then
			speed = spd or 5
			tracker = tracker or loop(f)
		else
			fast = false
			kl(tracker)
			tracker = nil
		end
	end
end

--
_sfx=sfx
_music=music
current_music=nil
function music(s,fade_sec,loop)
	if s==current_music then return end
	if loop==nil then loop=true end

	fade_sec=fade_sec or 1
	--_music()
	if type(s)=="string" and sub(s,#s,#s)=="A" then
		
		_music(s,0,false,fade_sec)

		nxtmusic(sub(s,1,#s-1).."B",-1,true)
	else

		_music(s,0,loop,fade_sec)
	end
	current_music=s
end



function sfx(str,vol)
	vol=vol or 1
	
	if fast then vol=0.25 end
	
	_sfx(str,-1,vol)
end

