require("code/serializer.lua")

function init_codex()
	reset()
	fd=-5
	fade_to(0,30)
	if not DEN.misc.codexitems then DEN.misc.codexitems={} end
	music("codex",0,true)
	if mMenu == nil then
		mMenu = {}
	end
	mMenu.x,mMenu.y=0,0
	codex_mode="codex"
	if BOOT=="UI_ACHIEVEMENTS" then
		codex_mode="achievement"
	end

	local function apply_fireplace()
		if DEN.misc.fireplace then
			_music("fireplace",1,true)
		else
			_music(nil,1)
		end
	end
	apply_fireplace()

	mdr=function()
		foreach(ents,dre)	
	end


	-- VARS
	local tempo=8
	local comp=0
	local comp_ach=0
	local xmax=8
	local bh=13
	local cdw=xmax*24	
	local pw=MCW-(cdw+16)
	local cards
	local statrst
	
	-- BG
	local bg=mke()
	bg.dr=function(e,x,y)
		rectfill(0,0,MCW-1,MCH-1,1)
	end


	-- CODEX	
	local mh_cod
	codex=mke(0,10,5)
	codex.dp=0
	codex.dr=function(e,cmx,cmy)
		--tcamera(-11,-6) -- >_< NOPE
		clip(cmx,bh+7,cdw,MCH-1,true)
	end
	

	-- PAN BG
	local card,pan=nil	
	local pan_bg=mke(0,codex.x+cdw,5)
	local flames=mke()
	local hearth=mke()
	add_child(pan_bg,flames)
	add_child(pan_bg,hearth)
	local function pal_fire()
		if not DEN.misc.fireplace then
			pal(3,1)
			pal(4,2)
			pal(5,2)
		end
	end
		
	pan_bg.upd=function(bg)
		-- FIRE FX		
		if DEN.misc.fireplace then
			local dx=hrnd(12)
			local dy=hrnd(4)
			local p=mke(0,27+dx,118+dy-dx/4)
			add_child(flames,p)
			p.life=32
			p.vy=-rnd(1)
			local fr=irnd(5)
			p.dr=function(e,x,y)
				local r=sqrt(p.life)
				if e.t<8 then r=r*e.t/8 end
				
				local sc=sqrt(p.life/32)
				if e.t<8 then sc=sc*e.t/8 end			
				sspr(40+fr*8,272,8,16,x-4*sc,y-8*sc,sc*8,sc*16)
			end
		end
	end
	pan_bg.dr=function(e,cx,cy)
		clip()
		pal_fire()
		-- BG
		spritesheet("codex")
		sspr(0,0,106,168,cx,cy)
			
		local function dr_furn(front)
			local index=DEN.misc.codexitems[5] or 0
			if (index~=2)==front then
				sspr(384+index*48,0,48,96,cx+64,cy+48)
			end
		end		

		-- FURNITURE
		dr_furn(false)
		
		-- LARGE WALL ITEM
		sspr(168+(DEN.misc.codexitems[4] or 0)*40,96,40,80,cx+64,cy+48)
		
		-- FURNITURE
		dr_furn(true)
		--
		spritesheet("gfx")
		pal()		

	end
	hearth.dr=function(e,cx,cy)
		pal_fire()
	
		spritesheet("codex")
		sspr(106,0,62,MCH,cx,cy)

		
		-- TOOLS
		sspr(168+(DEN.misc.codexitems[1] or 0)*24,0,24,32,cx+40,cy+56)
		sspr(168+(DEN.misc.codexitems[2] or 0)*24,32,24,32,cx+22,cy+56)
		sspr(168+(DEN.misc.codexitems[3] or 0)*24,64,24,32,cx-2,cy+64)
		
		-- 
		spritesheet("gfx")
		pal()
		
		-- FX EYES
		for i=0,1 do			
			local bx,by=cx+18+i*7,cy+21
		
			local dx,dy=0,0
			local mx=mx-pan_bg.x
			local mbx=20.5
			if mx<mbx-8 then dx=-1 end
			if mx>mbx+8 then dx=1 end
			if my<by-2 then dy=-1 end

			pset(bx+dx,by+dy,1)

		end		
		
	end	

	-- DISPLAY
	local function display_cards()
		codex.ents={}

		
		-- CARDS & COMP
		function dr_pan(pan, bpy)
			local ma,py=16,bpy+4
			
			local card=pan and pan.card or card

			if not card then		
				return pprint(lang.codex_select,pw/2,py,pw,2,1)
			end
			
			-- FUNCS
			local function disp_list(key, tags)
				local a=card[key] or {}
				if #a>0 then
					py=py+3
					lprint(lang["codex_"..key]..":",pw/2,py,2,1,1)
					py=py+6
					for i=1,#a do
						local id=a[i]
						if type(id)=="table" then
							del(a,id)
							local k=i
							for n in all(id) do
								if k>i then
									add(a,lang._or_,k)
									k=k+1
								end								
								add(a,n,k)								
								k=k+1
							end
						end
					end
					
					
					
					for id in all(a) do
						local s=tags and ("tag_"..id) or id 
						lprint(get_lang(s),pw/2,py,3,1,1)
						py=py+6
					end
				end
			end
			
			--local function f()
			py=bpy+4

			-- IF LOCKED ( TODO HERE )
			if card.locked then
				lprint(get_lang(card.id),pw/2,py,3,1,1)
				clip(pan_bg.x,0,pw+16,MCH,false)
				local x,y=pw/2-12,py+8
				brd(function() sspr(24,72,24,32,x,y) end, 1)
				sspr(176,256,24,32,x,y)
				py=py+40

				--[[ DISPLAY CARD NEEDS
				if #card.need_card>0 then
					local cards=""
					for id in all(card.need_card) do
						cards=cards..(#cards==0 and "" or ", ")..get_lang(id)
					end
					py=py+4
					local desc=get_lang("codex_gather",{cards,get_lang(card.id)})
					py=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
				end
				
				-- DISPLAY TAG NEEDS
				if #card.need_tag>0 then
					local tags=""
					for id in all(card.need_tag) do
						tags=tags..(#tags==0 and "" or lang._or_)..get_lang(id)
					end
					local desc=get_lang("codex_gather_tags",{tags,get_lang(card.id)})
					py=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
				end		
				--]]
				
				-- DISPLAY SECRET
				if card.pwe==0 then
					local desc=lang.codex_secret
					py=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
				end
				
				for k,v in pairs(card) do
					local k,targets=parse_effect(k)
					
					if targets.need and (type(v)~="table" or #v>0) then
						if k=="card" then
							local cards=""
							for id in all(card.need_card) do							
								cards=cards..(#cards==0 and "" or ", ")..format_list(id,lang._or_)
							end
							
							local desc=get_lang("codex_gather",{cards,get_lang(card.id)})
							py=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
							py=py+4
						elseif k=="tag" then
							local tags=""
							for id in all(card.need_tag) do
								tags=tags..(#tags==0 and "" or lang._or_)..get_lang("tag_"..id)
							end
							local desc=get_lang("codex_gather_tags",{tags,get_lang(card.id)})
							py=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
							py=py+4
						elseif type(v)=="number" then
							local reps={v,get_lang(k)}
							local desc=get_lang("codex_need",reps )
							py=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
							py=py+4
						end
					
					end
				end
				

				-- TODO : need piece

				
				if pan and pan.x<0 then
					hdclear(0,16,-pan.x,py+4)
				end

				return py
			end
			
			-- PLAYED
			lprint(lang.codex_played..": "..card.played,pw/2,py,2,1,1)
			py=py+8

			-- CARD
			lprint(get_lang(card.id),pw/2,py,4,1,1)
			clip(pan_bg.x,0,pw+16,MCH,false)
			dr_flip_card(pw/2-12,py+8,card,0,false)		
			py=py+40

			-- DESC
			local desc=get_desc(card)
			desc = sbs(desc, "|", "\n")
			desc = sbs(desc, "%$", lang.degree_symbol)
			local hy=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
			py=hy+2

			-- LOVE
			local prc=flr(card.played*100/(card.played+card.ignored))
			lprint(lang.codex_love.." "..prc.."%",pw/2,py,5,1,1)
			py=py+6

			-- FAMILY
			disp_list("tags", true)

			-- NEED
			disp_list("need_card")
			
			-- NEED TAG
			disp_list("need_tag", true)
			
			-- EXCLUDE TAG
			disp_list("exclude_tag", true)
			
			py=py+6
			
			if pan and pan.x<0 then
				hdclear(0,16,-pan.x,py+4)
			end
			
			return py
		end
		function remove_last_pan()
			if not pan then return end
			local old_pan=pan
			mv(pan,pw,0,tempo,bind(kl,old_pan))
			pan.twcv=ease_out
			pan=nil
		end
		function select_card(ca)

			sfx("codex_sel")
			card=ca
			remove_last_pan()
			
			pan=mke(0,0,0)
			add_child(pan_bg,pan)
			pan.card=ca
			pan.dr=function(e,cx,cy)
			
				tcamera(-cx,-cy)
				target("playground")
				local _pprint,_lprint = pprint,lprint
				pprint=function(str,x,y,w,c,align) return _pprint(str,x,y-1000,w,c,align)+1000 end
				lprint=function() end
				local h=dr_pan(e,0)
				pprint,lprint = _pprint,_lprint
				target()
				
				clip(pan_bg.x,16,pw+16,MCH,false)
				
				local y=(MCH-h)/2-8
				local ma=12
				local mh=4
				rectshade(ma,y-mh,pw-2*ma,h+2*mh,-2)
				rect(ma,y-mh,pw-ma,y+h+mh,3)

				dr_pan(e,y)
				
				tcamera(cx,cy)
				clip()
			end

			pan.x=pan.x-pw
			mv(pan,pw,0,tempo)
			pan.twcv=ease_in
			pan.dp=DP_BG
			
		end
		
		local n=0
		mh_cod=ceil(#CARDS/xmax)*32+16
		cards={}
		for data in all(CARDS) do
			local ca=mke()
			add(cards,ca)
			tbl_import(ca,data)
			add_child(codex,ca)
			ca.x=(n%xmax)*24
			ca.y=1+flr(n/xmax)*32
			ca.played = ca.played or get_stats(ca.id,true)--bget("stats",ca.gid*2,0)
			ca.ignored= ca.ignored or get_stats(ca.id,false)
			if ca.played>0 then comp=comp+1 end
			ca.locked=ca.played==0

			local b=mk_but(ca.x,ca.y,24,32,bind(select_card,ca))
			b.iscodexcard=true
			add_child(codex,b)	

			ca.dr=function(e,x,y)
				
				--if b.ov thenrectfill(x,y,x+24,y+32,5)	end
				if ca.played>0 then
					dr_flip_card(x,(b.ov and -1 or 0)+y,ca,0,false)
					
					if b.ov and not MOUSE then
						rect(x, y - 2, x + 22, y + 28, 5)
					end
				else
					sspr(24,72,24,32,x,y)
					if b.ov then
						rect(x + 1, y, x + 21, y + 28, MOUSE and 3 or 5)
					end
				end			
			
			end
			
			n=n+1
		end
		comp=comp/#CARDS


		-- RESET STATS BUT	
		local function yes()
			reset_stats()
			init_codex()
		end
		local b=mk_text_but((cdw-112)/2,mh_cod-14,112,lang.codex_reset,bind(confirm,yes))
		add_child(codex,b)
		statrst = b
		statrst.iscodexcard=true
		


	end	
	local function display_ach()
		codex.ents={}
		comp_ach=0
		-- ACHIEVEMENTS
		function dr_pan_ach(pan, bpy)
		
			local achiev = pan and pan.achiev or achiev
			
			--draw_icon()
			local py=bpy+4
			if achiev.data.rank then
				py=pprint(get_lang("ach_rank", achiev.data.rank),pw/2,py,pw-28,4,1)
			else
				py=pprint(get_lang("ach_"..achiev.data.id),pw/2,py,pw-28,4,1)
			end
			py=py+4
			
			clip(pan_bg.x,0,pw+16,MCH,false)
			spritesheet("big_achievement")
			sspr(0,0,64,64,pw/2-32,py)
			spritesheet("gfx")
			py=py+66
			py=py+4

			if achiev.data.cards then
				py=pprint(get_lang("ach_cards_desc", {get_lang(achiev.data.cards[1]), get_lang(achiev.data.cards[2]), get_lang(achiev.data.cards[3])}),pw/2,py,72,3,1)
			elseif achiev.data.gun then
				py=pprint(get_lang("ach_gun_desc"),pw/2,py,72,3,1)
			elseif achiev.data.rank then
				py=pprint(get_lang("ach_rank_desc", achiev.data.rank),pw/2,py,72,3,1)
			else
				py=pprint(get_lang("ach_"..achiev.data.id.."_desc"),pw/2,py,72,3,1)
			end
			
			clip()
			if pan then
				hdclear(0,bpy,201-pan.x,py)
			end
			--if achiev.data.desc then
			--	py=pprint("todo desc unlock",pw/2,py,pw-28,3,1)
			--end

			return py+2
		end
		function select_ach(ach)

			sfx("codex_sel")
			achiev=ach
			
			target("big_achievement")
			draw_icon(achiev.n,0,0)
			if achiev.locked then
				rectshade(0,0,64,64,-1)
			end
			target()
			
			remove_last_pan()
			
			pan=mke(0,cdw-7,0)
			pan.achiev = ach
			pan.dr=function(e,cx,cy)
			
			
				tcamera(-cx,-cy)
			--	clip()
				target("playground")
				local _pprint = pprint
				pprint=function(str,x,y,w,c,align)
					local y=_pprint(str,x,y-1000,w,c,align)+1000
					target("playground")
					return y
				end
				local h=dr_pan_ach(e,0)
				pprint = _pprint
				target()
				
				
				clip(pan_bg.x,0,pw+16,MCH)
				

				local y=(MCH-h)/2--8
				local ma=12
				local mh=4
				rectfill(ma,y-mh,pw-ma-1,y+h+mh,1)
				rect(ma,y-mh,pw-ma-1,y+h+mh,3)
				dr_pan_ach(e,y)
				
				tcamera(cx,cy)
				clip()
			end

			pan.x=pan.x-pw
			mv(pan,pw+16,0,tempo)
			pan.twcv=ease_in
		end

		mw_ach,mh_cod=srfsize("achievements_pane")
		target("achievements_pane")
		cls()

		local n=0
		for data in all(ACHIEVEMENTS) do
			local ach=mke()
			add_child(codex,ach)
			ach.x=2+(n%5)*38
			ach.y=1+flr(n/5)*38
			ach.data=data
			ach.n=n
			--ach.locked=bget("achievements",n,0)==0
			ach.locked=not DEN.achievements[data.id]
			if not ach.locked then comp_ach=comp_ach+1 end

			local b=mk_but(ach.x,ach.y,34,34,bind(select_ach,ach))
			b.isachievement=true
			add_child(codex,b)

			ach.dr=function(e,x,y)
				
				local dy = b.ov and not ach.locked and -1 or 0
				
				spritesheet("achievements_pane")
				sspr(ach.x,ach.y,34,34,x,dy+y)
				spritesheet("gfx")

				if b.ov then
					if MOUSE then
						if ach.locked then
							rect(x, dy+y, x+33, dy+y+33, 3)
						end
					else
						rect(x, dy+y, x+33, dy+y+33, 4)
						
						pset(x+1, dy+y+1, 4)
						pset(x+32, dy+y+1, 4)
						pset(x+1, dy+y+32, 4)
						pset(x+32, dy+y+32, 4)
						
						rect(x-1, dy+y-1, x+34, dy+y+34, 5)
						
						pset(x, dy+y, 5)
						pset(x+33, dy+y, 5)
						pset(x, dy+y+33, 5)
						pset(x+33, dy+y+33, 5)
						
						pset(x-1, dy+y-1, 1)
						pset(x+34, dy+y-1, 1)
						pset(x-1, dy+y+34, 1)
						pset(x+34, dy+y+34, 1)
						
					end
					
					if DEV and btnp("reload") then
						trig_achievement(data.id)
					end
				end
			end

			local x=ach.x
			local y=ach.y
			if ach.locked then
				spritesheet("gfx")
				pal_inc(-1)
			end
			spritesheet("achievements")
			sspr(128,64,34,34,x,y)
			
			if ach.locked then
				spritesheet("gfx")
				pal_inc(-2)
				pal(5,2)
				spritesheet("achievements")
			end
			if data.spr then
				local px=160+data.spr*32
				sspr(px,64,32,32,x+1,y+1)
				
			elseif data.cards then
				spritesheet("gfx")
				local cy=max(y+2,bh-codex.y)
				local diff=flr(cy-(y+2))
				clip(x+1,cy,32,31-diff,true)
				for i=1,3 do
					local ca=get_card(data.cards[i]) or {gid=59}
					if not ca then print(data.cards[i]) end
					local cx=x-6
					local cy=y-4
					if i==2 then
						cx=cx+24
					end
					if i==3 then
						cx=cx+12
						cy=cy+32-12
					end		
					dr_flip_card(cx,cy,ca,0,true)
				end
				clip()
				pset(x+1,y+2,1)
				pset(x+32,y+2,1)
			elseif data.sm then
				local px=(data.sm%32)*32
				local py=128+flr(data.sm/32)*32
				
				if not ach.locked then
					apal(1)
					sspr(px,py,32,32,x+2,y+2)
					pal()
				end
				sspr(px,py,32,32,x+1,y+1)

				
				
			elseif data.gun then
				sspr(256,64,32,32,x+1,y+1)
				
				spritesheet("weapons")
				--sspr(0,col.gun*24,96,24, x,y)
				local sc=.35
				local function f()
					if ach.locked then
						spritesheet("gfx")
						pal_inc(-2)
						spritesheet("weapons")
					end
					asspr(0,data.gun*24,96,24,x+18,y+18,-.125,sc,sc)
				end
				local col=4
				if ach.locked then col=2 end
				brd(f,col)
			elseif data.rank then
				local r=data.rank-1		
				pal(5,1)		
				sspr(384,64,32,32,x+1,y+1)
				pal()
				local function f()
					if ach.locked then
						spritesheet("gfx")
						pal_inc(-2)
						spritesheet("achievements")
					end
					sspr(r*32,256,32,32,x+1,y+2)
				end
				brd(f,1)
			end
			spritesheet("gfx")
			pal()

			n=n+1
		end
		comp_ach=comp_ach/#ACHIEVEMENTS
		target()
	end
	
	display_ach()
	display_cards()

	-- TAB BUTTONS
	local codexb, achb
	local function switch_to(tab)
		if codex_mode==tab then return end
		
		codex_mode=tab
		codex.y=bh+1		
		
		if tab=="codex" then
			display_cards()
		else
			display_ach()
		end
		
		

		mMenu.x,mMenu.y=0,0
		remove_last_pan()
		sfx("menu_in",0.7)
	end
	
	codexb = mk_but(0+11,0+6,95,13,bind(switch_to, "codex"))
	codexb.dr = function(e,x,y)

		local dr_bg=true
		if codex_mode~="codex" then
			if e.ov then
				pal(3,1)
			else
				spritesheet("gfx")
				dr_bg=nil				
				pal_inc(-1)
			end
		end		
		spritesheet("codex")
		if dr_bg then	sspr(0,171,95,13,x,y) end
		
		lprint(get_lang("ui_codex", min_digits(flr(comp*100),2)),x+16+39,y+4,4,1)
		
		pal()
		draw_button("leftPage", x+4, y+3)
	end
	add_child(bg,codexb)
	
	achb = mk_but(95+11,0+6,95,13,bind(switch_to, "achievement"))
	achb.dr = function(e,x,y)

		local dr_bg=true
		if codex_mode~="achievement" then
			if e.ov then
				pal(3,1)
			else
				spritesheet("gfx")
				dr_bg=nil				
				pal_inc(-1)
			end
		end		
		spritesheet("codex")
		if dr_bg then	sspr(0,171,95,13,x,y) end
		
		if PSN then
			lprint(get_lang("ui_trophies", min_digits(flr(comp_ach*100),2)),x+1+39,y+4,4,1)
		else
			lprint(get_lang("ui_achievements", min_digits(flr(comp_ach*100),2)),x+1+39,y+4,4,1)
		end
		
		pal()
		draw_button("rightPage", x+79, y+3)
	end
	add_child(bg,achb)



	
	-- BG BUT [TODO: need to be fully converted to gamepad]
	local function get_card(id)
		for ca in all(cards) do if ca.id==id then return ca end end
		return nil
	end
	local function toggle(x,md)
		if x==0 then
			DEN.misc.fireplace = not DEN.misc.fireplace
		else
			DEN.misc.codexitems[x] = ((DEN.misc.codexitems[x] or 0)+1)%(md or 2)
		end
	end
	local function toggle_item(it,from)
		local lim=DEV and 0 or 5

		local items=ITEMS[it]
		local index=DEN.misc.codexitems[it] or 0
		
		from=from or index
		index=(index+1)%(#items+1)
		DEN.misc.codexitems[it]=index
		
		local ca=get_card(items[index])
		
		if index==0 or ca.played>=lim then
			if from==index then
				sfx("wrong")
			else
				sfx("codex_cycle_item")
			end
		else
			toggle_item(it,from)
		end
	end
	
	local function f()
	
		local function inbox(x,y,w,h)
			local mx=mx-pan_bg.x
			return mx>=x and mx<x+w and my>=y and my<y+h	
		end
		
		if pan then 
			sfx("codex_unsel")
			remove_last_pan()
			return
		end
		
		if inbox(17,111,27,21) then
			toggle(0,2)
			apply_fireplace()
		elseif inbox(40,56,24,32) then
			toggle_item(1)
			--toggle(1,4)
		elseif inbox(24,56,24,32) then
			toggle_item(2)
			--toggle(2,4)
		elseif inbox(-2,64,24,32) then
			toggle_item(3)
		elseif inbox(64,48,16,72) then
			toggle_item(4)
		elseif inbox(64,48,48,96) then
			toggle_item(5)
		end

	end
	
	local b=mk_but(0,0,pw,MCH-16,f)
	ctrlrsup = mke()
	ctrlrsup.upd = function()
		if not MOUSE then -- controller support for just the fireplace
			if btnp("reload") then
				toggle(0,2)
				apply_fireplace()
			end
			
			if btnp("special") then
				sfx("codex_unsel")
				remove_last_pan()
			end
		end
	end
	add_child(b,ctrlrsup)
	add_child(pan_bg,b)
	
	
	-- BACK BUT
	local function exit()
		_music(nil,1,1000)
		sfx("menu_out",0.7)
		remove_buts()
		fade_to(-4,30,init_menu)
		mv(codex,-xmax*24,0,30)
		mv(pan_bg,xmax*24,0,30)
		pan_bg.twcv=ease_in
		codex.twcv=ease_in
		remove_last_pan()
	end
	
	local bstr=lang.back
	local ww=txtwidth(bstr)
	local x,y=MCW-ww-16-11,MCH-15-6
	local butB=mk_but(x,y,ww+8,9,exit)
	butB.dp=DP_TOP+1
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

	--
	codex.upd=function()		
		local scr=(.5-(my/MCH))*2
		scr=sgn(scr)*(scr*scr)
		
		
		if mx < xmax*24 then
			codex.scry=mid(MCH-mh_cod-6,(codex.scry or codex.y)+scr*8,bh+8)
			codex.y=round(codex.scry)
		end

		local off = 24
    
		if btnrp("leftStickX+") or btnrp("rightStickX+") then
			mMenu.x = mMenu.x + off
		elseif btnrp("leftStickX-") or btnrp("rightStickX-") then
			mMenu.x = mMenu.x - off
		end
		
		if btnrp("leftStickY+") or btnrp("rightStickY+") then
			mMenu.y = mMenu.y + off
		elseif btnrp("leftStickY-") or btnrp("rightStickY-") then
			mMenu.y = mMenu.y - off
		end
		
		local bdst,best = 999
		local oldM = mMenu

		for e in all(codex.ents) do
			local process=false
			if codex_mode=="codex" then process=e.iscodexcard or e==statrst
			elseif codex_mode=="achievement" then process=e.isachievement end
			

			if process then
				local dst = abs(oldM.x-e.x)+abs(oldM.y-e.y)
				if not best or dst<bdst then
					best,bdst = e,dst
				end
			end
		end

		if best ~= nil then
			if (best.y == oldM.y-off or best==statrst) and codex_mode=="codex" then
				mMenu.x = statrst.x+20
				mMenu.y = statrst.y-5
			else
				mMenu.x = best.x
				mMenu.y = best.y
			end
		end
		
		if not MOUSE then
			mx = mMenu.x + 8 +10
			my = mMenu.y + codex.y + 8+5
		end

		if btnp("cancel") then
			codex.upd=nil
			exit()
		end
		if btnp("leftPage") and codex_mode~="codex" then
			switch_to("codex")
		end
		if btnp("rightPage") and codex_mode~="achievement" then
			switch_to("achievement")
		end
	end	

	
end




function confirm(yes,no)
	sfx("menu_in")
	local buts=get_all_buts()
	for b in all(buts) do 
		b.ov=nil
		exe(b.out)
	end


	no=no or function() end
	
	frz=1
	
	local ww,hh=120,48
	
	local pan=mke(0,(MCW-ww)/2,(MCH-hh)/2)
	pan.dp=DP_TOP
	pan.perm=true
	pan.dr=function(e,x,y)
		
		for i=1,4 do blend(5,i,max(i-1,1)) end
		blend(5,5,3)
		rectfill(0,0,MCW,MCH,5)
		
		blend()
	
		hdclear(x,y,x+ww,y+hh)
		rectfill(x,y,x+ww-1,y+hh-1,2)
		rect(x,y,x+ww-1,y+hh-1,3)		
		local s=lang.ask_confirm
		lprint(s,x+ww/2,y+8,4,1)
		
		
	end

	local bs,sel={}
	local bw=32
	local ec=(ww-2*bw)/3
	for i=0,1 do
	
	
		local function f()
			kl(pan)
			
			frz=nil
			if i==0 then
				sfx("menu_in")
				yes()
			else
				sfx("menu_out")
				no()
			end


		end
	
		local name=get_lang(i==0 and lang["yes"] or lang["no"])
		local b=mk_text_but(ec+(bw+ec)*i,hh-18,32,name,f)
		b.perm=true
		add_child(pan,b)
		bs[i]=b
	end
	
	pan.upd = function() -- controller support
		if MOUSE then return end
		if not sel then sel=1 return end
		
		if btnp("leftStickX-") or btnp("rightStickX-") then
			sel=0
		end
		
		if btnp("leftStickX+") or btnp("rightStickX+") then
			sel=1
		end
		
		if btnp("cancel") then
			sel=1
			mcl=true
		end
		
		mx = pan.x+bs[sel].x+2
		my = pan.y+bs[sel].y+2
	end
	
	
end

function get_all_buts(from,a,done)
	from=from or ents
	a=a or {}
	done=done or {}
	for k,v in pairs(from) do
		if type(v)=="table" and not done[v] then
			done[v]=1
			if v.button then add(a,v) end
			get_all_buts(v,a,done)
		end
	end	
	return a
end

function format_list(id,lnk)	
	if type(id)=="table" then
		local s=""
		for n in all(id) do
			s=s..(#s>0 and lnk or "")..get_lang(n)									
		end
		return s
	end
	return get_lang(id)
end
