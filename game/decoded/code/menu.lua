function init_menu(goto_play)
	VISION=nil
	winspec("bgcol",2)

	if codex then
		kl(codex)
		codex=nil
	end
	
	if LIVE then
		live("set_presence", "menu")
	end
	reset()
	music("title_A")
	
	local intro=not skip_intro
	local goto_throne = false
	if PSN and not activity_trigerred then
		if psn("was_launch_from_activity") then
			intro = false
			goto_throne = true
			activity_trigerred = true
		end
	end
	if DEV then
		intro=false
	end
	skip_intro=true
	
	tempo=intro and 60 or 30
	fd=-3
	fade_to(0,24)

	local bg=mke(0,0,0)
	bg.upd=function()
		
		-- "press A to start"
		if intro and mcl and bg.t>240 then -- (bg.t>240
			mcl=false
			intro=false
			sfx("start",.75)
			wait(5,open_menu)
		end
	
	end
	bg.dr=function(e,x,y)
		spritesheet("title")
		sspr(0,0,MCW,MCH,x,y)
		spritesheet("gfx")
		
		local s="PUNKCAKE#9 v"..VERSION		
		if DEV then
			s=s.." DEV MODE"
		end

		local sav = font()
		font("pico")
		lprint(s,1,1,2)
		font(sav)
	end
	
	
	local str="Join us on Discord!"
	local discord=mk_but(1, 9, #str*4, 8, function() url("https://discord.gg/TkdktuKBgp") end)
	discord.dr = function(e, x, y)
		local sav = font()
		font("pico")
		
		rrectfill(x-1,y-1,#str*4+1,7,2,3)
		
		local ti=t*0.03-4
		for i=1,#str do
			local ch=sub(str,i,i)
			local v=ti*1-i*0.067
			local dy=(v%12<1) and 3.5*sin(v) or 0
			local col=e.ov and 4 or (2 + abs(dy)/1.5)
			lprint(ch, x+(i-1)*4, y+dy, col, nil, e.ov and 1)
		end
		
		font(sav)
	end
	
	-- CASTLE
	local castle=mke(0,0,0)
	castle.dr=function(e,x,y)
		spritesheet("title")
		sspr(0,189,307,163,x,y)
		spritesheet("gfx")
	end
	castle.y=17+MCH/2
	mvt(castle,0,17,tempo)
	castle.twcv=ease_in_out

	
	-- TREES
	local trees=mke(0,0,0)
	trees.dr=function(e,x,y)
		spritesheet("title")
		sspr(463,216,49,29,x,y+78)
		sspr(307,245,205,107,x+115,y)
		spritesheet("gfx")

		if bg.t>240 and intro and t%60<40 then
			local txt = MOUSE and lang.click_start or get_lang("press_start", CONFIRM_BUTTON)
			local w = txtwidth(txt)
			rectfill(244-w/2-3,116-2,244+w/2+3,116+6,1)
			lprint(txt,244-w/2,116,5)
		end
		
	end
	trees.y=73+MCH
	mvt(trees,0,73,tempo+10)
	trees.twcv=ease_in_out

	-- PIECES
	local pieces=mke(0,0,0)
	pieces.dr=function(e,x,y)
		spritesheet("title")
		sspr(320,114,192,66,x,y)
		spritesheet("gfx")
		
		if STEAM and steamws("downloading") then
			local sav = font()
			font("pico")
			lprint("Downloading mods from workshop "..({'\\', '-', '/', '|'})[flr(_t*0.1)%4+1],1,MCH-8,4,nil,1)
			font(sav)
		elseif MODDED then
			local sav = font()
			font("pico")
			lprint("Modded: ON - Achievements: OFF",1,MCH-8,4,nil,1)
			font(sav)
		end
	end
	pieces.y=114+MCH*2
	mvt(pieces,0,114,tempo+15)
	pieces.twcv=ease_in_out
	
	if LIVE then
		local gamertag=live("get_gamertag")
		local gamertag_obj=mke(0,0,0)
		gamertag_obj.upd=function()
			if btnp("special") then
				live("switch_profile")
			end
		end
		gamertag_obj.dr=function(e,x,y)
			local str=get_lang("switch_profile")
			local w=txtwidth(str)
			rectshadeopti(0, MCH-22, max(72,12+w+2), 22)
			local sav = font()
			font("pico")
			lprint(gamertag,1,MCH-20,5)
			font(sav)
			draw_button("special",1,MCH-12)
			lprint(str,12,MCH-10,4)
		end
		gamertag_obj.dp=DP_TOP+1
	end




	-- TITLE
	local boxes={
		{320,0,142,28},
		{320,31,142,52},

		{324,84,7,12},
		{331,84,10,12},
		{340,84,7,12},

		{350,84,6,12},
		{356,84,4,12},
		{359,84,9,12},
		{367,84,9,12},
		{376,84,8,12},

		{386,84,8,12},
		{394,84,10,12},
		{403,84,8,12},
		{411,84,7,12},
		{418,84,8,12},
		{426,84,10,12},
		{436,84,9,12},
		{445,84,6,12},
		{451,84,7,12},
	}
	title=mke()
	
	local bi=1
	local prev=nil
	local function spawn_title()
		if bi>#boxes then return end
			
		local b=boxes[bi]
		local mult=intro and 1 or 0
		
		local tx=(b[1]-320)+173
		local ty=(b[2])+7
		local e=mke(0,tx,MCH)
		add_child(title,e)
		e.bi=bi
		bi=bi+1
		e.dr=function(e,x,y)
			if e.c_shake then
				y=y+e.c_shake*(cyc(2,2,e.c_shake)*2-1)
			end
		
			spritesheet("title")
			sspr(b[1],b[2],b[3],b[4],x,y)
			spritesheet("gfx")
		end
		local p=prev
		local beep=function()
			if not intro then return end
			if e.bi<=2 then
				sfx("shoot")
			else
				_sfx("spawn",-1,1,0,1+hrnd(.01))
			end
			if p then
				p.c_shake=e.bi<=2 and 8 or 3
			end
		end
		
		mvt(e,tx,ty,30*mult)
		
		if goto_play then
			e.x,e.y=tx,ty
		end
		
		wait(15,beep)
		wait((e.bi<=2 and 30 or 6)*mult,spawn_title)
		
		e.twcv=ease_bounce_out
		prev=e
	end
	wait(tempo,spawn_title)

	if not intro then
		if goto_throne then
			hide_title()
			set_mode("throne")
			if mode.resume_save then
				escape(mode.start)
			else
				rank_select()
			end
		elseif goto_play then
			local a={}
			for id in all(GAME_MODES) do
				add(a,id)
			end
			add(a,"back")
			
			title.y = -MCH
			
			wait(tempo,bind(open_menu,a,"play"))
		else
			wait(tempo,open_menu)
		end
	end
end

function open_menu(a,type)
	close_menu()
	menu={}
	show_rec=nil
	
	local sel=-1
	local ma,ecy=8,15-2
	local pw,ph=64,0
	local px,py=212,108
	if not a then 
		a={"play","options","codex","credits","quit"}
		if CONSOLE then del(a,"quit") end
		ph=2*ma+#a*ecy-2
	elseif type == "play" then
		ph=2*ma+#a*ecy-2 + 16
		py=MCH/2-ph/2
		--[[
		if MODLIST then
			ph=2*ma+#a*ecy-2 + 16
			py=MCH/2-ph/2
		else
			ph=2*ma+#a*ecy-2
			py=117
		end
		--]]
	else
		ph=2*ma+#a*ecy-2
		py=MCH/2-ph/2
	end
	
	if ingame then
		px=MCW/2-pw/2
		py=py+2
	end

	local dk=py+ph - (MCH-4)
	if dk>0 then py=py-dk/2 end
	
	-- ERASER
	local e=mke()
	e.dp=DP_TOP
	e.dr=function()
		--hdclear(0,0,MCW,MCH)	
	end
	add(menu,e)
	
	-- BUTS
	if MODLIST and (type=="play" or type=="mods") then
		menu_scroll = mke(0,0)
		menu_scroll.upd = function()
			if ph < MCH then return end
			local scr = .5-(my/MCH)
			local dy = MCH/2-ph/2
			menu_scroll.y=mid(menu_scroll.y+scr*4, -dy+4, MCH-ph-dy)
		end
	
		if type=="play" then
			py=MCH/2-ph/2
			local m=mk_menu_but("mods",px,py+ma-2,pw,ecy-2)
			m.name="Mods"
			m.y=m.y-16
			mv(m,0,16,16)
			m.twcv=ease_out
			py=py+16
		elseif type=="mods" then
			inmods = true
			ph = 2*ma + (#MODLIST+3)*ecy+2
			py = MCH/2-ph/2+ma-2+ecy			
			pw = MCW*0.5
			px = MCW-pw-16
			
			for i,mod in ipairs(MODLIST) do
				local name = (mod.empty and "EMP | " or (mod.active and " ON | " or "OFF | "))..i..". "..mod.title
				local y = py
				
				local up=mk_menu_but('é',px-24,y,11,ecy-2)
				local dw=mk_menu_but('è',px-12,y,11,ecy-2)
				local m=mk_menu_but(name,px,y,pw,ecy-2)
				up.align_left = true
				dw.align_left = true
				m.align_left = true
				up.pico, dw.pico = true, true				
				m.labelc = mod.active and 4 or 2				
				up.lock = i==1
				dw.lock = i==#MODLIST
				
				local s=(i%2)*2-1
				m.x=m.x+s*16
				mv(m,-s*16,0,16)
				m.twcv=ease_out
				
				up.x=up.x+s*16
				mv(up,-s*16,0,16)
				up.twcv=ease_out
				
				dw.x=dw.x+s*16
				mv(dw,-s*16,0,16)
				dw.twcv=ease_out
				
				m.hint_but = mk_but(0,0,pw,ecy-2,function()end)
				m.hint_but.over = function()
					hint_but=e.hint_but
					local str = mod.desc
					str = mod.title.."|"..sbs(str, '\n', '| ')
					show_hint(str,{4,3},0.4*MCW,nil,{x=8, y=16})
				end
				m.hint_but.out = function()
					hide_hint()
				end
				--m.hint_but = mk_hint_but(0,0,pw,ecy-2,mod.desc,{4,3},MCW*0.4,nil,{x=8, y=32, center_y = true})
				add_child(m,m.hint_but)
				py = py+ecy
			end
			
			py=py+4
			px=px-12
			
			local res = mk_menu_but("reset",px,py,pw,ecy-2)
			res.name = "Reset"
			res.lock = true
			
			py = py+ecy
			local bck = mk_menu_but("back",px,py,pw,ecy-2)
			bck.name = "Back"
			
			local title = mke(0,0)
			local typein = "upload"
			title.str = "Mod Load Order"
			add_child(menu[2], title)
			title.dr = function(e,x,y)
				x = x+px*0.5+12
				y = y-ecy
				local str = e.str
				
				if title.uploadin then
					str = "Uploading..."
				elseif title.error then
					str = title.error
				elseif title.downloadin then
					str = "Still downloading..."
				end
				
				lprint(str, x, y, 4, 1, 1)
			end
			title.upd = function()
				if not PC or not STEAM then return end
				if not menu then kl(title) return end
				if title.typein then
					local upl=steamws("uploading")
					local dwl=steamws("downloading")
				
					for i=1,#MODLIST do
						local b = menu[#menu-i+1]
						local mod = MODLIST[i]
						
						if mod.here then
							b.lock = nil
						else
							b.lock = true
							b.id = "⓵"
						end
						
						if mod.empty or (mod.script and not mod.ran) then
							b.lock = true
						else
							b.lock = nil
						end
						
						if b.upl then
							upl = true
							b.id = ({'\\', '-', '/', '|'})[flr(_t*0.1)%4+1]
						elseif upl then
							b.id = "⓵"
						elseif b.id=="⓵" and not b.err and mod.here then
							b.id = "ê"
						end
						
						if b.err then
							title.error = b.err
						end
					end
					
					title.uploadin = upl
					title.downloadin = dwl
					return
				end
				
				if btnp(sub(typein,1,1)) then
					typein = sub(typein,2)
					if #typein==0 then -- create upload buttons
						title.typein = true
						title.str = "/!\\ only upload your own mods /!\\"
						for i=#MODLIST,1,-1 do
							local y = MCH/2-ph/2+ma-2 + i*ecy
							
							local upld=mk_menu_but('ê',px+12+pw+2,y,11,ecy-2)
							upld.align_left = true
							upld.pico = true
						end
						
					end
				end
			end
			
			return
		end
	end
	
	for i=1,#a do	
		local name=a[i]
		local m=mk_menu_but(name,px,py+ma+(i-1)*ecy-2,pw,ecy-2)
		local s=(i%2)*2-1
		m.x=m.x+s*16
		mv(m,-s*16,0,16)
		m.twcv=ease_out
	end
end

function mk_menu_but(id,x,y,w,h)
	local lock=is_locked(id)
	local first=#menu==1
	local save_on_back=false
	if id == "save_back" then 
		id="back"
		save_on_back=true
	end
	
	if ingame then
		if current_lang == "french" or current_lang == "spanish" or current_lang == "german" then
			w = w + 8
		end
		if current_lang == "japanese" then
			w = w + 16
		end
	end
	
	local e=mke(0,x,y)
	e.id=id
	e.name=get_lang(id)
	e.lock=lock
	e.perm=true
	e.dp=DP_TOP
	add(menu,e)
	e.upd=function()
		local ohide = e.hide
		
		local nhide
		if id == "HD text" then
			nhide = (fnt ~= "pico")
		elseif id == "rumble" then
			nhide = (MOUSE or not RUMBLE_SUPPORT)
		end
		
		if nhide~=nil then
			e.hide, e.skip, e.but.skip = nhide, nhide, nhide
		end

		if e.t>10 and id=="back" and btnp("cancel") then
			e.upd=nil
			e.over=true
			if not MOUSE then
				e.but.clicked=true
			end
			if save_on_back then save() end
			act_menu(e.id)
		end	
	end
	e.dr=function(e,x,y)
		if e.hide then return end
		e.name = lang[e.id] or e.name or e.id
		local name = e.red and (e.name.."?") or e.name
		if (current_lang == "spanish" or current_lang == "latam") and e.red then
			name = "¿"..name
		end
		
		spritesheet("title")
		--local w=64
		local w=w
		if ingame then
			hdclear(x,y,x+w-1,y+11)
		end
		local labelc=4
		local valc=4
		if e.lock then -- disabled
			sspr(320,216,2,12,x,y)
			sspr(322,216,1,12,x+2,y,w-4,12)
			sspr(382,216,2,12,x+w-2,y)
			labelc=1
			valc=1
			if e.over then
				labelc=3
			end
		elseif e.over and e.but and e.but.clicked then -- clicked
			sspr(320,180,2,12,x,y)
			sspr(322,180,1,12,x+2,y,w-4,12)
			sspr(382,180,2,12,x+w-2,y)
			labelc=1
		elseif e.over and not e.bleed then -- over
			sspr(320,192,2,12,x,y)
			sspr(322,192,1,12,x+2,y,w-4,12)
			sspr(382,192,2,12,x+w-2,y)
			labelc=1
			valc=5
		else -- normal
			sspr(320,204,2,12,x,y)
			sspr(322,204,1,12,x+2,y,w-4,12)
			sspr(382,204,2,12,x+w-2,y)
			labelc=e.labelc or 4
			valc=4
		end
		spritesheet("gfx")

		local fntsav
		if e.pico then
			fntsav = font()
			font("pico")
		end
		
		-- NAME
		local cx=e.align_left and x+3 or x+w/2-#name*2
		if e.align_left then
		  lprint(name, x+3, y+3, labelc)
		else
		  lprint(name, x+w/2, y+3, labelc, 1)
		end
		
		-- VALUE
		if e.val then
			--write_at(e.val,x+w-2-#e.val*4,y+3,4)
			lprint(e.val, x+w-2, y+3, valc, 2)
		end
		
		if e.pico and fntsav~="pico" then
			font(fntsav)
		end
		

		-- SLIDER
		if e.slider then
			for i=0,9 do
				local px=x+w+i*2-2-10*2
				line(px,y+2,px,y+7,i<e.slider and valc or 1)
			end
		end
		
		
		if first and show_rec then
			local title=show_rec.name.." "
			local bx=x+(w-txtwidth(title..show_rec.n))/2
			lprint(title,bx,y-8,4,0,1)
			lprint(show_rec.n,bx+txtwidth(title),y-8,5,0,1)		
		end

	end
	
	
	-- BEST FLOOR
	local dif_i,rec
	local prog=DEN.prog
	if id=="throne" then
		rec={name=lang.best_rank, n=prog.throne and prog.throne.rank or 0}
	elseif id=="endless" then
		rec={name=lang.best_floor,n=prog.endless or 0}
	elseif id=="chase" then
		rec={name=lang.best_score,n=prog.chase and prog.chase.score or 0}
	elseif id=="charnier" then
		rec={name=lang.best_rank, n=prog.charnier and prog.charnier.best or 0}
	elseif tonum(sub(id,1,1)) then
		local dot = find(id, '%.')
		local mod = MODLIST[tonum(sub(id, 1,dot-1))]
		local mode = sub(id, dot+2)		
		local format = mod.mode_record and mod.mode_record[mode]
		if format then
			if format.key then
				rec={name=format.name, n=MODSAV[mod.save][format.key]}
			else
				rec={name=format.name, n=bget(mod.save, format.bx, format.by)}
			end
		end
	end
	
	-- BUTTONS
	local function act_if_unlocked()
		if save_on_back then save() end
		if not e.lock then act_menu(e.id) end
	end
	--local b=mk_but(x,y,w,h,act_if_unlocked)
	local b=mk_but(0,0,w,h,act_if_unlocked)
	add_child(e,b)

	for opt in all(OPTIONS) do if id==opt.id then			

		--name=lang[id]
		e.align_left=true
		e.opt=opt
		--while #name<14 do name=name.." " end
		
		-- SLIDER
		if opt.opt==11 and opt.id ~= "lang" then
		
			local function upn()
				e.slider=SET[opt.nid]
			end
			upn()
			e.upn=upn
			
			b.left_clic=nil
			b.left_press=function()
				local px=(24+mx-x-w)			
				local n=mid(0,flr(px/2),10)
				if n~=SET[opt.nid] then
					SET[opt.nid]=n
					apply_option(id)
					sfx("tic",.5)
				end
				upn()
			end
			
		else

			local function upn()
				local k=SET[opt.nid]
				if id == "lang" then
					k=lang.lang_endonym
				elseif opt.labels then
					k=opt.labels[k+1]
				elseif opt.opt==2 then
					k=k==0 and lang.off or lang.on
				end	
				e.val=(k or "")..""
			end
			upn()
			e.upn=upn
		
			local function inc(n)
				if not menu then return end
				if b.skip then return end
				sfx("sel_opt",nil,0.4)
				if id=="lang" then
					SET_LANG=(SET_LANG or LANGUAGES[SET.lang] or 1)+n
					SET.lang=LANGUAGES[((SET_LANG-1)%#LANGUAGES)+1]
					--SET_LANG=(((SET_LANG or LANGUAGES[SET.lang] or 0)+n-1)%#LANGUAGES)+1
					--SET.lang=SET_LANG
				else
					SET[opt.nid]=((SET[opt.nid] or 0)+n)%opt.opt
				end
				apply_option(id)
				--upn()
				for e in all(menu) do exe(e.upn) end
			end
			b.left_clic=bind(inc,1)
			b.right_clic=bind(inc,-1)	
			
		
			
		end
	end end
	
	if not e.upn then -- button is "back" or "resign"
		local function upn()
			name=get_lang(id)
		end
		upn()
		e.upn=upn
	end
	

	b.perm=true
	b.over=function()
		if b.skip then return end
		sfx("tic",.5)	
		e.over=true
		mb_id=id
		cdi=dif_i
		if rec and rec.n and rec.n>0 then
			show_rec=rec
		end		
	end
	b.out=function()
		e.over=false
		if show_rec==rec then show_rec=nil end		
	end
	e.but=b
	
	-- HINT
	local desc=get_menu_desc(id)
	local c = {4,3}
	if lock then 
		desc=lang[id.."_lock"]
		c = {3}
	end
	if desc then
		local ext=0
		if id=="chase" and not lock then ext=64 end
		if id=="charnier" and not lock then ext=64 end
		local params={x=105-ext,y=MCH/2+50,center_y=true,float=true}
		if MODLIST then
			params.y = y+6
		end
		e.hint_but=mk_hint_but(0,0,w,h,desc,c,98+ext,nil,params)
		add_child(e, e.hint_but)
		
		if menu_scroll then
			params.free = true
			e.hint_but.over = function()
				hint_but=e.hint_but
				show_hint(desc,c,98+ext,nil,params)
				add_child(menu_scroll, hint_box)
			end
		end
	end
	
	-- SCROLL
	if menu_scroll then
		add_child(menu_scroll, e)
	end

	return e
end

function act_menu(id)
	--remove_buts()
	if not menu then return end
	
	
	for e in all(menu) do
		if e.id == id then
			self = e
		end
	end
	
	
	sfx((id=="back" or id=="resign") and "menu_out" or "menu_in")
	
	 -- mod menu stuff
	if inmods then
		if id=="back" then
			inmods = nil
			return act_menu("play")
		elseif id=="reset" then
			--load_mods()
			local list = {}
			for i,mod in ipairs(MODLIST) do
				mod.active = mod.loaded
				list[mod.num]=mod
			end
			MODLIST=list
			inmods = nil
			act_menu("mods")
			return
		elseif id=="reboot" then
			write_mod_list(MODLIST)
			_S.log("rebooting...")
			run()
			return
		elseif id=="ê" then -- mod upload
			for i,b in ipairs(menu) do
				if b.over then
					local mid = #menu-i+1
					local mod = MODLIST[mid]
					if mod.here and (mod.ran or not mod.script) and not mod.empty then
						local function upload_done(id)
							b.upl = nil
							if id=="0" then
								local err = steamws("error")
								wlog("Uploading mod failed: "..err)
								b.err = err
								b.id = "⓵"
							elseif not mod.id then
								mod.id = id
								file(mod.folder.."/info.lua", "id = \""..id.."\"\n"..file(mod.folder.."/info.lua"))
								_log("Mod successfully created!")
								b.id = "ô"
							else
								_log("Mod successfully updated!")
								b.id = "ô"
							end
						end
					
						b.upl = true
						if mod.id then
							steamws("update", mod.id, mod.title, mod.desc, mod.cover, mod.folder, upload_done)
						else
							steamws("new", mod.title, mod.desc, mod.cover, mod.folder, upload_done)
						end
					end
					
					return
				end
			end
		end
		for i,b in ipairs(menu) do
			if b.over then
				local i=i-1
				local mid = ceil(i/3)
				local mac = i%3
				
				if mac==0 then -- toggle mod
					local mod = MODLIST[mid]
					if mod.empty then
						return
					end
					mod.active = not mod.active
					b.id = (mod.active and " ON | " or "OFF | ")..mid..". "..mod.title
					b.labelc = mod.active and 4 or 2

				elseif mac==1 then -- move up
					local y = MCH*0.5-((#MODLIST+3)*13+2)*0.5+mid*13-2
					menu[1+mid*3].y = y
					menu[1+mid*3-3].y = y-13
					MODLIST[mid],MODLIST[mid-1] = MODLIST[mid-1],MODLIST[mid]
					menu[1+mid*3],menu[1+mid*3-3] = menu[1+mid*3-3],menu[1+mid*3]
					mv(menu[1+mid*3], 0, 13, 16)
					mv(menu[1+mid*3-3], 0, -13, 16)
					menu[1+mid*3].id = (MODLIST[mid].active and " ON | " or "OFF | ")..mid..". "..MODLIST[mid].title
					menu[1+mid*3-3].id = (MODLIST[mid-1].active and " ON | " or "OFF | ")..(mid-1)..". "..MODLIST[mid-1].title
				
				elseif mac==2 then -- move down
					local y = MCH*0.5-((#MODLIST+3)*13+2)*0.5+mid*13-2
					menu[1+mid*3].y = y
					menu[1+mid*3+3].y = y+13
					MODLIST[mid],MODLIST[mid+1] = MODLIST[mid+1],MODLIST[mid]
					menu[1+mid*3],menu[1+mid*3+3] = menu[1+mid*3+3],menu[1+mid*3]
					mv(menu[1+mid*3], 0, -13, 16)
					mv(menu[1+mid*3+3], 0, 13, 16)
					menu[1+mid*3].id = (MODLIST[mid].active and " ON | " or "OFF | ")..mid..". "..MODLIST[mid].title
					menu[1+mid*3+3].id = (MODLIST[mid+1].active and " ON | " or "OFF | ")..(mid+1)..". "..MODLIST[mid+1].title
				end				
				menu[#MODLIST*3+2].lock = nil
				menu[#MODLIST*3+3].id = "reboot"
				menu[#MODLIST*3+3].name = "Save and Reboot"
				
				return
			end
		end
		return
	end
	
	-- give up
	if id=="resign" then
		if self.red then
			for e in all(menu) do
				if e.but then del(ents,e.but)	end
			end		
			unpause()
			remove_buts()
			if hero then
				wait(10, function()
					if hero then
						local sq = hero.sq
						xpl(hero)
						hero.sq = sq
						wait(30,mode.on_hero_death) -- to allow save progress on resign
					end
				end)
			end
			fast_tracker(true, 5)
			mode.resign=true
			music("gameover",0,false)
			--wait(70, bind(fade_to,-4,30,end_game))
		else
			self.red = true
			sfx("menu_in",0.7)
		end
		return
	end

	if id=="skip_tutorial" then
		if self.red then
			for e in all(menu) do
				if e.but then del(ents,e.but)	end
			end
			unpause()
			remove_buts()
			DEN.prog.tutorialdone=true
			if PSN then
				psn("add_available_activity", "throne_progress")
				psn("add_available_activity", "rank_1")
			end
			DEN.prog.save()
			fade_to(-4,30,bind(init_menu, true))
		else
			self.red = true
			sfx("menu_in",0.7)
		end
		return
	end
	
	for e in all(menu) do
		if e.but then del(ents,e.but)	end
	end
	
	-- LAUNCH MODE
	for mid in all(GAME_MODES) do
		if id==mid then
			set_mode(id)
			-- INSERT RANK SELECTION HERE
			if SAVE_RUNS and DEN.runs[game_mode] then
				close_menu(bind(escape,mode.start))
			elseif mode.weapons or mode.ranks then
				hide_title()
				close_menu(rank_select)
			else
				close_menu(bind(escape,mode.start))
			end
			return
		end
	end
	
	-- PLAY
	if id=="play" then
		if not DEN.prog.tutorialdone and not PC and not NO_TUTORIAL then
			set_mode("tutorial")
			close_menu(bind(escape,mode.start))
			return
		end

		local a={}

		for id in all(GAME_MODES) do
			add(a,id)
		end
		
		hide_title()
		
		add(a,"back")

		close_menu(bind(open_menu,a,"play"))		
	end
	
	if id=="mods" then
		close_menu(bind(open_menu,a,"mods"))	
	end

	if id=="codex" then
		close_menu(bind(escape,init_codex))
	end		
		
	if id=="options" then
		local a={}
		for opt in all(OPTIONS) do add(a,opt.id)	end
		if CONSOLE then del(a,"fullscren") end
		if CONSOLE then del(a,"mod") end
		add(a,"save_back")
		hide_title()
		close_menu(bind(open_menu,a))
	end
	
	if id=="credits" then
		hide_title()
		close_menu(init_credits)
	end
	
	if id=="quit" then
		quit()	
	end
	
	if id=="back" then
		if ingame then
			unpause()
		else
			show_title()
			close_menu(open_menu)
		end
	end
end

function show_title()
	if title.y == 0 then return end
	title.y=-MCH
	mv(title,0,MCH,30)
	title.twcv=ease_in
end

function hide_title()
	if title.y == -MCH then return end
	title.y=0
	mv(title,0,-MCH,30)
	title.twcv=ease_in
end

function close_menu(f)
	if not menu then return end
	
	for e in all(menu) do
		if e.but then kl(e.but)	end
		if e.hint_but then kl(e.hint_but)	end
	end
	hide_hint()
	
	for i=1,#menu do
		local m=menu[i]
		m.bleed=true
		mv(m,16*((i%2)*2-1),0,16,bind(kl,m))
		m.twcv=ease_in
	end
	
	if menu_scroll then
		wait(16,function()
			kl(menu_scroll)
			menu_scroll=nil
		end)
	end
	
	menu=nil
	inmods=nil
	if f then wait(16,f) end

end

function escape(f)
	fade_to(-4,30,f)
end

function mk_square_but(name,f,ww)
	local e=mke()	
	e.pw,e.ph=ww or 64,12
	
	local function ff()
		if not e.skip then f() end
	end
	
	local b=mk_but(0,0,e.pw,e.ph,ff)
	e.but=b
	add_child(e,b)
	
	e.dr=function(e,x,y)
		local clc=4

		spritesheet("title")
		if b.clicked then
			sspr(320,180,2,12,x,y)
			sspr(322,180,1,12,x+2,y,e.pw-4,12)
			sspr(382,180,2,12,x+e.pw-2,y)
			clc=1
		elseif b.ov then
			sspr(320,192,2,12,x,y)
			sspr(322,192,1,12,x+2,y,e.pw-4,12)
			sspr(382,192,2,12,x+e.pw-2,y)
			clc=1
		elseif e.skip then -- disabled
			sspr(320,216,2,12,x,y)
			sspr(322,216,1,12,x+2,y,e.pw-4,12)
			sspr(382,216,2,12,x+e.pw-2,y)
			clc=1
		else -- normal
			sspr(320,204,2,12,x,y)
			sspr(322,204,1,12,x+2,y,e.pw-4,12)
			sspr(382,204,2,12,x+e.pw-2,y)
			clc=4
		end
		spritesheet("gfx")

		lprint(name,x+e.pw/2,y+3,clc,1)
	end

	return e
end

-- RANK & GUN SELECTION
function rank_select()
	local bx=240
	local ec=6
	local th=0--48+56+8
	local cy=(MCH-th)/2
	local tma=12
	
	local elements={}
	menu={}

	add(menu,mke()) -- fake eraser
	
	local function mk_panel(id,pw,ph,ary)
		
		if th>0 then th=th+ec end
		th=th+ph
		
		local pan=mke(0,bx-pw/2,MCH)
		
		add(elements,pan)
		pan.id=id
		pan.pw=pw
		pan.ph=ph
		pan.sel=0
		pan.smax=#mode[id]	
		pan.ady=8
		pan.get_sel=function()
			return pan.list and pan.list[pan.sel+1] or pan.sel
		end
		pan.isRankPan=true

		-- ARROW
	
		for i=0,1 do
			local ar=mke(0,3+(pw-8-6)*i,pan.ady+(ary or 0))
			add_child(pan,ar)
			local cl=2
			ar.dr=function(e,x,y)			
				ar.vis=true
				if (i==0 and pan.sel==0) or (i==1 and pan.sel==pan.smax-1) then ar.vis=false return end		
				if pan.selected then
					cl=4
				elseif ar.but.ov then
					cl=5
				else
					cl=2
				end	
				pal(5,cl)
				sspr(192,160,8,24,x+i*8,y,8*(1-i*2),24)			
				pal()
			end
			local function inc(n)
				if not ar.vis then return end
				sfx("sel_opt",nil,0.4)
				pan.sel=mid(0,pan.sel+n,pan.smax-1)
				mode[pan.id.."_index"]=pan.get_sel()
				--exe(mode.save_preferences)
			end	
			
			local b=mk_but(ar.x,ar.y,8,24,bind(inc,i*2-1))
			ar.but=b
			add_child(pan,b)
			if i == 0 then pan.prev_ar=ar else pan.next_ar=ar end
		end
		
		-- SELECT PREF		
		pan.sel=mode[pan.id.."_index"]
		
		--		
		return pan
		
		
	end
	
	
	-- BEST time
	if SET.speedrun==1 then
		local pw=64
		local bt=mke(0,bx-pw/2,MCH)
		bt.ph=8
		th=th+bt.ph
		bt.dr=function(e,x,y)
			--rectfill(x,y,x+pw-1,y+bt.ph,1+t%4)		
			local tm=0
			if mode.get_best_time then
				tm = mode.get_best_time()
			end
			if tm==0 then return end
			
			local s=lang.best_time
			lprint(s,x+pw/2,y,4,1,1)
			s=get_time_string(tm)
			lprint(s,x+pw/2,y+6,5,1,1)			
			
		end
		add(elements,bt)
	end
	
	-- RANKS & WEAPONS
	if mode.ranks then
		pan=mk_panel("ranks",128,48)
		
		if mode.get_max_rank then
			pan.smax=min(pan.smax,mode.get_max_rank())
		end
		
		pan.dr=function(e,px,py)
			local data=mode.ranks[e.sel+1]
			tcamera(-px,-py)
			-- BG
			rectfill(0,0,e.pw-1,e.ph-1,1)	
			if e.selected then
				rect(-1,-1,e.pw,e.ph,5)		
			end	
			-- TITLE
			local s=lang.rank--..":"..(e.sel+1).."/"..#mode.ranks
			lprint(s,e.pw/2,3,3,1)

			-- RANK			
			local s=(pan.sel+1)..""--..""..#mode.ranks
			local bx=e.pw/2-#s*8
			pal(3,4)
			for i=1,#s do
				local k=sub(s,i,i)
				k=k=="/" and 10 or k*1.0
				sspr(k*16,256,16,16,bx+i*16-16,12)
			end
			pal()
			
			-- DESC
			local s=get_desc(data)
			local a=split(s,"|")
			s=sbs(s, "|", "\n")
			s=sbs(s, "%$", lang.degree_symbol)
			pprint(s, e.pw/2, 32+8-#a*3, e.pw, 3, 1)
			tcamera(px,py)
			
		end
		add(menu,pan)
	end
	if mode.weapons then
		local pan=mk_panel("weapons",136,64,6)
		local av={}
		if mode.get_weapons_list then
			for n in all(mode.get_weapons_list()) do
				av[n+1]=true
			end
			pan.check_ready=function() return av[pan.sel+1] end
			
		else
			for i=1,#pan.list do av[i]=true end
		end
		
		pan.dr=function(e,px,py)
			local i=e.get_sel()
			local data=mode.weapons[i+1]
			
			tcamera(-px,-py)			
			rectfill(0,0,e.pw-1,e.ph-1,1)
			if e.selected then
				rect(-1,-1,e.pw,e.ph,5)		
			end	
			
			-- TITLE
			lprint(get_lang(data.name),e.pw/2,3,3,1)
			
			-- GFX
			local avb=av[pan.sel+1]
			spritesheet("weapons")
			local function f() 	
				if not avb then apal(1)	end			
				sspr(0,i*24,96,24,16+4,tma+4) 
				pal()
			end
			brd(f,avb and 4 or 2)
			spritesheet("gfx")
			
			--[[
			if bv[i+1] and bv[i+1]>=0 then
				local v=flr(mid(bv[i+1],0,3))
				if v<2 then
					sspr(128+v*10,200,11,24,16,-4)
				else
					sspr(120+v*14,200,14,24,14,-4)
				end
				lprint(cv[i+1], 21, 4, 4, 1)
			end
			--]]


			if not avb then
				local desc=get_lang("shotgun_unlock_"..e.sel)
				pprint(desc,e.pw/2, 40, e.pw, 3, 1)
				tcamera(px,py)
				return
			end


			-- AMMO
			local x=e.pw-16-(data.chamber_max+data.ammo_max+1)*4-(data.grenades_max or 0)*6 -4
			local y=28+8
			for i=1,(data.grenades_max or 0) do
				sspr(195,1,5,7,x,y)
				x=x+6
			end
			for i=1,data.chamber_max do
				sspr(4,56,3,7,x,y)
				x=x+4
			end
			sspr(83,48,3,6,x,y+1)
			x=x+4
			for i=1,data.ammo_max do
				sspr(4,56,3,7,x,y)
				x=x+4
			end


			-- STATS
			local x=10
			local y=48
			local k=0			
			local function spec(id)
				local n=data[id]
				if not n then return end
				
				local disp_stat,s=1
				if id =="all_freereload" then
					s,disp_stat=lang.effect_freereload
				elseif id=="reload_grenade" then
					s,disp_stat=lang.reload_grenade
				elseif id=="butcher" then
					s,disp_stat=lang.butcher					
				else					
					s=lang[id]..":"				
				end
				
				local x,y=x+(k%2)*62,y+flr(k/2)*7
				x = lprint(s,x,y,3)				
				if id=="firerange" then n=n>0 and "+"..n or n end
				if id=="spread" then n=n..lang.degree_symbol end
				if id=="knockback" then n=n.."%" end
				if id=="pierce" then n=n.."%" end
				if disp_stat then	lprint(n,x+3,y,4) end
				k=k+1
			end

			local ids={"firepower","spread","firerange","knockback","blade","pierce","search","all_freereload","reload_grenade","butcher","sheath","death_curse"}
			-- "firerange",
			
			for id in all(ids) do spec(id) end
			
			tcamera(px,py)
			
			if mode.draw_badges then
				mode.draw_badges(px,py,pan.sel+1)
			end
			
		end

		add(menu,pan)

		--[[
		if mode.get_weapons_list then
			pan.list=mode.get_weapons_list()
			pan.smax=#pan.list
			for i=1,#pan.list do
				if pan.list[i]==pan.sel then
					pan.sel=i-1
					break
				end
			end			
		end
		--]]
		
		
		
	end

	-- START BUT
	local function start()
		exe(mode.save_preferences)
		menu=nil
		remove_buts()
		
		local wt=0
		for e in all(elements) do 
			wait(wt,mv,e,0,-MCH,16,bind(kl,e))
			e.twcv=ease_in
			wt=wt+6
		end

		sfx("menu_in",0.7)
		wait(8,fade_to,-4,30,mode.start)
	end
	local e=mk_square_but(lang.start,start)
	e.upd=function()
		e.skip=false			
		for p in all(elements) do
			e.skip=e.skip or (p.check_ready and not p.check_ready() )
		end
	end
	e.x,e.y=bx-32,MCH
	th=th+e.ph+ec
	add(elements,e)
	add(menu,e)

	local function back()
		exe(mode.save_preferences)
		menu=nil
		remove_buts()
		
		local wt=0
		for e in all(elements) do 
			wait(wt,mv,e,0,-MCH,16,bind(kl,e))
			e.twcv=ease_in
			wt=wt+6
		end	
		sfx("menu_out",0.7)
		wait(wt,show_title)
		wait(wt+16,open_menu)
	end
	local e=mk_square_but(lang.back,back)
	e.upd=function()
		if e.t>10 and btnp("cancel") then
			e.upd=nil
			e.but.clicked=true
			back()
		end
	end
	e.x,e.y=bx-32,MCH
	th=th+e.ph+ec
	add(elements,e)
	add(menu,e)



	-- align panels an button
	local y=(MCH-th)/2
	local wt=0
	for e in all(elements) do
		e.y=y+MCH
		wait(wt,mvt,e,e.x,y,16)
		e.twcv=ease_out
		wt=wt+6
		y=y+e.ph+ec
	end
	

	-- START

	



end


-- DESC
function get_menu_desc(id)
	local _concat=_S.concat
	
	for mid in all(GAME_MODES) do
		if mid==id then
			local desc=get_lang(id.."_desc")
			if not desc then return end
			
			local prog=""
			
			if id=="charnier" then
				local ch=DEN.prog.charnier
				if ch then
					prog=_concat({prog,'|',get_lang("rank"),': ',#ch.burdens})
					prog=_concat({prog,'|',get_lang("cinders"),': ',ch.cinders})
				end
			end
			
			local save=SAVE_RUNS and DEN.runs[id]
			if save then
				if id=="throne" then
					prog=_concat({prog,'|',get_lang("rank"),': ',DEN.prog.throne and DEN.prog.throne.rank_sel or 1})
					prog=_concat({prog,'|',get_lang(({"Solomon","Victoria","Ramesses II","Richard III","Makeda","Alexander","Yvan IV","Attila","Montezuma"})[(DEN.prog.throne and DEN.prog.throne.weapon_sel or 0)+1])})
				end
				
				prog=_concat({prog,'|',get_lang("floor_"),' ',save.lvl+1})
			end
			
			if #prog>0 then
				desc=desc..'| '..prog
			end
			
			return desc
		end
	end
	
	return nil
end

-- CREDITS
function init_credits()
	local e=mke(0,230,14)
	e.autoscroll=true
	e.scroll=0

	local scrlmax=0
	local stt=time()

--	local butB=mke(0, MCW-35, MCH-20)
--	butB.dr=function(sl,x,y)
--		hdclear(x, y, x+35, y+9)
--		draw_button("cancel", x, y)
--		pprint(lang.back, x + 11, y + 2, 48, 4, 0, nil, 1)
--	end
	
	local bstr=lang.back
	local ww=txtwidth(bstr)
	local x,y=MCW-35,MCH-20
	local butB=mk_but(x,y,ww+8,9,exit)
	butB.dr=function(b,x,y)
		if not MOUSE then
			draw_button("cancel", x-7, y)
		end
		
		if b.ov then
			lprint(lang.back, x+4, y + 2, 1, 0, 4)
		else
			lprint(lang.back, x+4, y + 2, 4, 0, 1)
		end
		
	end
	

	--credits.active=true
	e.upd=function()
		if time()-stt>0.45 then
			if (mcl or mcr or (btnp"cancel")) then
				sfx("menu_out",0.7)
				mcl=false
				kl(e)
				kl(butB)
				show_title()
				open_menu()
			end

			local scrollInput = 0
			if MOUSE then
				scrollInput = ((my/MCH)-0.5)*6
			else
				scrollInput = btnv("leftStickY+") - btnv("leftStickY-")
			end
			
			if abs(scrollInput) > 0.1 then 
				e.autoscroll = false
				e.scroll = e.scroll + scrollInput
			end
		end

		if e.autoscroll and e.t > 90 then
			e.scroll = e.scroll + 0.25
		end
		e.scroll = mid(0, e.scroll, scrlmax)
	end
	e.dr=function(e,x,y)
		local w=min(e.t*20,MCW/2)
		
		local w=sin(min((time()-stt)*2, 1)*0.25)
		w=w*w*MCW*0.5
		
		rectshadeopti((MCW/2-10)+(MCW/2-w)/2,0,w,MCH,-2)
		clip((MCW/2-10)+(MCW/2-w)/2+4,0,w-8,MCH)
		--rectfill((MCW/2-10)+(MCW/2-w)/2,0,(MCW/2-10)+(MCW/2-w)/2+w,MCH,1)

		local sav = font()
		font("Terminus")
		
		
		local dy = y-e.scroll
		
		local cy=dy
		local adt=function(title)
			cy=pprint(title,x,cy,150,3,1,nil,1)+6
		end
		local sep=function()
			cy=cy+10
		end
		local adl=function(work,name)
			lprint(work,x,cy,4,1,1,80)
			lprint(name,x,cy+8,5,1,1)
			cy=cy+20
		end
		
		local adloc=function(work,names)
			lprint(work,x,cy,4,1,1,80)
			for i,s in pairs(names) do
				lprint(s,x,cy+8+(i-1)*7,5,1,1)
			end
			cy=cy+14+#names*7
		end
		
		local adp=function(name)
			cy=pprint(name,x,cy,150,5,1,nil,1)+1
		end
		local adlogo=function(sx,sy,sw,sh)
			target(OVERLAY_SURF)
			spritesheet("logo_hd")
			pal(4,1)
			pal(5,1)
			sspr(sx,sy,sw,sh,x*2-sw/2+2,cy*2+2)
			pal()
			sspr(sx,sy,sw,sh,x*2-sw/2,cy*2)
			spritesheet("gfx")
			target()
			cy=cy+sh/2+10
		end
		
		adt("Shotgun King by PUNKCAKE DELICIEUX")
		adl("Code / GFX / SFX / Game design:","Benjamin Soule")
		adl("Sugar engine / Narrative / Code support:","Lorraine Devaux")
		adl("Music:","Pentadrangle")

		sep()

		adt("Console port by HEADBANG CLUB")
		adl("Console Adaptation / Development:","Togi")
		adl("Console Arts:","Guillaume \"Gyhyom\" Breton")
		adl("Console Producer:","David Elahee")
		adl("Office Manager:","Tinu")

		sep()

		adl("Console Communication:","Mylene Lourdel - Raccoon Business")
		adl("Console Relations:","Olivier Penot - Seaven Studio")
		adl("Illustrator:","Fafodill")
		
		sep()

		adt("QA by Lollipop Robot")
		adp("Iván Cano")
		adp("Iván de Rosa")
		adp("Oscar Navalón")

		sep()
		
		adt("Localization")
		adloc("French",		{"Eris Desquilbet", "Lloyd Bastien", "Frédéric Tabard (LOC3)", "Claire Deiller (LOC3)"})
		adloc("Spanish",	{"Ramón Méndez González", "Crisol. \"Ubre\" Sable", "Cintia Izquierdo (LOC3)", "Ismael Fernandez (LOC3)"})
		adloc("LATAM Spanish",	{"Juan Ignacio Luque"})
		adloc("Portuguese",	{"Bruna Carvalho", "Emerson P. Machado"})
		adloc("German",		{"Raven", "Nick Schaefer (LOC3)", "Angelika Hell (LOC3)"})
		adloc("Dutch",		{"Thijmen Zuiderwijk"})
		adloc("Italian",	{"Riccardo De Angelis", "Primo Vinicio Calabrese"})
		adloc("Romanian",	{"Etilon N. Mihai"})
		adloc("Catalan",	{"Arnau Frago (Projecte Ce Trencada)", "Francesc G. Parisi (Projecte Ce Trencada)", "Ignasi Sanfeliu (Projecte Ce Trencada)"})
		adloc("Galician",	{"Rubén Castro Barro"})
		
		adloc("Polish",		{"Paweł \"kantal\" Turaczyk", "Marcin \"tranzystorekk\" Puc", "Albion Localisations (LOC3)"})
		adloc("Ukrainian",{"Jan Kiepski", "Roman \"Catless\" Haidei", "Nadya Dubyshkina (LOC3)", "Tetiana Kulinich (LOC3)"})
		adloc("Russian",	{"Konstantin \"drugon\" Lanin", "Anna Shulikina (LOC3)", "Nadezhda Lynova (LOC3)"})
		
		adloc("Chinese",{"Sound of Mystery", "Active Gaming Media (LOC3)"})
		adloc("Korean",		{"Baeseong \"Otiel\" Lee", "Active Gaming Media (LOC3)"})
		adloc("Japanese",	{"Rie Ihara", "Active Gaming Media (LOC3)"})
		adloc("Vietnamese",{"Phạm \"Shiroku\" Đức Minh"})
		

		if not PC then
			sep()
			adt("Made with FMOD Studio by Firelight Technologies Pty Ltd.")
			adlogo(0,0,300,110)
		end

		sep()
		adt("Shotgun King was made possible thanks to PUNKCAKE's lovely Patreon supporters, especially these people who were giving us extra money at the time of the original release:")

		cy = pprint(BACKERS,x,cy,150,5,1) + 6
		
		adt("Check us out on https://punkcake.club")

		scrlmax = cy+32-dy-MCH+4

		camera()
		clip()
		font(sav)
	end
end

-- INTRO
function init_intro()

	reset()

	local bg=mke()
	bg.dr=function()
		cls(1)
	end
	
	init_vig({1,2,3},init_game)


end
function init_vig(seq,nxt)
	fast_tracker(false)
	if not recurs then
		fast_clicks = 0
	end

	if #seq==0 then
		kl(vbg)
		vbg=nil
		nxt()
		return
	end
	
	vbg=mke()
	vbg.dp=DP_TOP
	vbg.dr=function() 
		cls(1)
		hdclear(0,0,MCW*2,MCH*2)
	end	
	
	local id=seq[1]
	del(seq,id)
	if id==4 and stack.theocracy then id=5 end
	if id==11 then id=7 end -- they were the same, so I'm removing 11 from the language file - Remy
	

	fd=-4
	fade_to(0,16)
	local fast=false
	local fasst=false
	local leavin=false
	local slide=16
	local slide_tempo=32
	local typing=true
	local desc=lang["vig_"..id]
	if (id==2 or id==3) and mode.id=="tutorial" then desc=lang["vig_"..id.."_tuto"] end
	local len = safesize(desc)
  
	local e=mke(0,0,slide)
	e.dp=DP_TOP
	local tt=0
	e.upd=function()
		if leavin then
			if mcl then
				mcl=false
				if fasst then
					sfx("next_vig_2")
					while #seq>0 do deli(seq,1) end
					e.upd = nil
				end
			end
			return
		end
	
		tt=tt+(fast and 5 or .5)
	
		if mcl then
			mcl=false
			if fast then
				sfx("next_vig_2")
				--e.upd=nil
				leavin=true
				local function f()
					kl(e)					
					init_vig(seq,nxt)
				end
				mv(e,0,-slide,slide_tempo,f)
				fade_to(-4,slide_tempo)
				e.twcv=ease_in
			else
				fast=true
				fasst = true
			end
		end
		
		if typing and tt>slide_tempo/2 then
		
			if e.t%(fast and 3 or 6)==0 then

				_sfx("tic",3,.2,0,.5+hrnd(.02))
			end
		end
	
	end
	e.dr=function(e,px,py)
		tcamera(-px,-py)
		
		-- VIG
		local vw,vh=128,64
		local x=(MCW-vw)/2
		local y=16
		rectfill(x,y,x+vw-1,y+vh-1,5)
		spritesheet("intro")
		sspr(0,id*vh-vh,vw,vh,x,y)
		spritesheet("gfx")

		-- TEXT
		local sw=128+64
		local lim=max(tt-slide_tempo/2,0)
		if lim>len then fast=true typing=false end		
		--local story=slicer(desc,sw,lim)
		local cy=96--e.t/10
		--pprint(desc, (MCW-sw)/2, cy, sw, 4)
		pprint(desc, (MCW-sw)/2, cy, sw, 4, 0, lim)
		
		tcamera(px,py)
	end
	
	mv(e,0,-slide,slide_tempo)


end

-- SCRIPT
function set_mode(id)
	local mod
	if tonum(sub(id,1,1)) then
		local dot = find(id, '%.')
		mod = MODLIST[tonum(sub(id, 1,dot-1))]
		id = sub(id, dot+2)
	end

	MOD = mod and mod.name
	game_mode=id
	
	if mod then
		MODDED = true
		tbl=safe_require(mod.folder, "modes/"..id..".lua", {"DEV", "START_LVL", "FORCE_WHITE_ARMY", "DUMMY", "FRAGILE", "SHOW_BUTS", "TEST_CARDS", "TEST_SOULS", "OVERWEIGHT", "BOOT", "game_mode", "CARDS", "PIECES", "EXCLUDE", "AUTO_REPLACE", "FIRST_ARMY", "HERO_INIT", "hero", "heir", "leader", "rov", "squares", "pentasquares", "waypoint", "ammo", "chamber", "grenades", "stack", "scepters", "menu", "bg", "white_army", "perm", "mode", "cards", "mx", "my", "mcl", "mlb", "mcr", "mMenu", "VISION"})
	else
		tbl=safe_require("", "code/modes/"..id..".lua",{"lvl", "rov", "mx", "my", "mcl", "mlb", "mcr", "mMenu", "pad_cursor","chrono_time"},{"DEN"})	-- {"DEN"} = trucs autorisés
	end
	
	mode=tbl
	mode.frags={}	
	exe(mode.initialize)
end

-- TOOLS
function mk_text_but(x,y,ww,str,f)
	local hh=11
	local e=mke(0,x,y)
	e.txt=str
	e.dr=function(e,x,y)
		if e.brd then
			rectfill(x-1,y-1,x+ww,y+hh,e.brd)
		end
		if e.shd then
			local n=e.shd
			rectfill(x+n,y+n,x+n+ww-1,y+n+hh-1,1)
		end
		local bcl=e.ov and 5 or 3
		local tcl=4
		if e.but.locked then
			bcl=2
			tcl=1			
		end		
		rectfill(x,y,x+ww-1,y+hh-1,bcl)
		lprint(e.txt,x+ww/2,y+3,tcl,1)
	end
	
	local b=mk_but(0,0,ww,hh,f)
	add_child(e,b)
	b.over=function()
		sfx("tic",.5)
		e.ov=true
	end
	b.out=function()
		e.ov=false
	end
	
	e.but=b
	return e

end