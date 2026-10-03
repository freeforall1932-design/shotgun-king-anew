upd = {}
upd_menu = {}
upd_codex = {}
draw = {}
autocall = {start={},on_fire={},on_piece_move={},on_bad_hurt={},on_bad_death={},on_new_turn={},on_empty={}}
on_sq_but_init = {}
on_card_but_init = {}
on_menu_but_init = {}
edit_disp_stats = {}
act_new_piece = {}
sort_spawn = {}
custom_flip = {}

for mod in all(MODLIST) do if mod.env then for k,v in pairs(mod.env) do if type(v) == "function" then

	if autocall[k] then
		add(autocall[k],v)

	elseif k == "upd" then
		add(upd,v)

	elseif k == "upd_menu" then
		add(upd_menu,v)

	elseif k == "upd_codex" then
		add(upd_codex,v)

	elseif sub(k,1,5) == "draw_" then
		local dp = tonum(sub(k,6))
		if dp and not draw[dp] then draw[dp] = {} end
		add(draw[dp],v)

	elseif k == "on_sq_but_init" then
		add(on_sq_but_init,v)

	elseif k == "on_card_but_init" then
		add(on_card_but_init,v)

	elseif k == "on_menu_but_init" then
		add(on_menu_but_init,v)

	elseif k == "on_bad_spawn" or k == "change_new_p" then
		add(act_new_piece,v)

	elseif k == "edit_disp_stats" then
		add(edit_disp_stats,v)

	elseif k == "sort_spawn" then
		add(sort_spawn,v)

	elseif k == "check_custom_flip" then
		add(custom_flip,v)

	end

end end end end

function set_autocall()
	for name,t in pairs(autocall) do if #t > 0 then
		local foo = nil
		if mode[name] then foo = mode[name] end
		mode[name] = function(...)
			if foo then foo(...) end

			if name == "on_piece_move" then
				local p = ...
				if p.grab_canceled or p.named then return end
			end

			for f in all(t) do f(...) end
		end
	end end
end

append("set_mode",set_autocall,"terminal autocall")

function set_updater()
	loop(function()
		for f in all(upd) do f() end
	end).glacies = "Terminal Updater"
end

function set_menu_updater()
	loop(function()
		for f in all(upd_menu) do f() end
	end).glacies = "Terminal Updater"
end

function set_codex_updater()
	loop(function()
		for f in all(upd_codex) do f() end
	end).glacies = "Terminal Codex Updater"
end

function set_drawing(dp)
	local e = mke()
	e.dr = function()
		for f in all(draw[dp]) do f() end
	end
	e.dp = dp
	e.glacies = "Terminal Drawing "..dp
end

function set_all_drawing()
	for dp,t in pairs(draw) do
		set_drawing(dp)
	end
end

append("init_game",set_updater,"terminal updater")
append("init_menu",set_menu_updater,"terminal menu updater")
append("init_codex",set_codex_updater,"terminal codex updater")
append("init_game",set_all_drawing,"terminal drawing")

append("ach_event",function(str) if str == "play" then
	for e in all(ents) do if e.button then
		if e.issq then
			for sq in all(squares) do if e.x == sq.x and e.y == sq.y then
				for f in all(on_sq_but_init) do f(e,sq) end
				break
			end end
		elseif e.iscard then
			for sl in all(card_slots) do
				local ca = sl.ca
				if ca and e.x == sl.x and e.y == sl.y then
					for f in all(on_card_but_init) do f(e,ca) end
					break
				end
			end
		end
	end end
end end,"terminal change buttons")

local making_menu_but
local menu_but,id,w,h
prepend("mk_menu_but",function(idd,x,y,ww,hh)
	making_menu_but = true
	id,w,h = idd,ww,hh
end,"terminal change menu buttons")

append("add",function(tbl,e) if making_menu_but then
	making_menu_but = false
	menu_but = e
end end,"terminal change menu buttons")

append("mk_menu_but",function()
	for f in all(on_menu_but_init) do f(menu_but,id,w,h) end
end,"terminal change menu buttons")

-- local spawning = false
-- local piece_spawned
-- -- prepend("new_piece",function(type,bad,sq) if bad then spawning = true end end,"spawning")
-- append("setup_piece",function(p) piece_spawned = p end,"spawn")
-- append("new_piece",function(type,bad,sq)
-- 	-- spawning = false
-- 	if bad then for f in all(act_new_piece) do f(piece_spawned) end end
-- 	-- piece_spawned = nil
-- end,"spawning")
append("new_piece",function(type,bad,sq)
	local p = sq.p -- in case someone kills it in this process
	if not p then return end
	for f in all(act_new_piece) do f(p) end
end,"spawning")

local spawning_army = false
prepend("spawn_pieces",function() spawning_army = true end,"spawn pieces")
append("custom_sort",function(tbl) if spawning_army then
	spawning_army = false
	for f in all(sort_spawn) do f(tbl) end
end end,"sort spawn")

---[[
local grab_canceled = nil
append("sfx",function(str)
	if str == "grab_cancel" then
		grab_canceled = true
	end
end,"on_move fix")

prepend("goto_sq",function(p)
	if grab_canceled then
		grab_canceled = nil
		p.grab_canceled = true
	end
end,"on_move fix")
--]]

local getting_stat = false
local id
prepend("get_disp_stats",function()
	getting_stat = true
	if hero and hero.hop and hero.hop>0 then
		id = "jump"
	elseif (stack.fearsome or 0) > 0 then
		id = "fearsome"
	elseif stack.blade and stack.blade>0 then
		id = "blade"
	elseif stack.pierce>0 then
		id = "pierce"
	elseif stack.knockback>0 then
		id = "knock"
	else
		id = "f_arc"
	end
end,"edit_disp_stats")
append("add",function(stats,stat) if getting_stat and stat.id == id then
	for f in all(edit_disp_stats) do f(stats) end
	getting_stat = false
end end,"edit_disp_stats")

prepend("check_cards_auto_flip",function()
	if not hero or not hero.sq then return end
	for ca in all(get_slot_cards(true)) do
		for chk in all(custom_flip) do
			if chk(ca) then
				ca._flip_on = ca.flip_on
				ca.flip_on = "no_DUMMY"
				return
			end
		end
	end
end,"custom flip conditions")

append("check_cards_auto_flip",function()
	for ca in all(get_slot_cards(true)) do
		if ca._flip_on then
			ca.flip_on, ca._flip_on = ca._flip_on
		end
	end
end,"custom flip conditions")

-- FITNESS fix
prepend("setup_piece",function(p)
	p.fitness = nil
end,"fitness fix")

---[[ FALLING SQUARES
local flying
prepend("get_range",function(p)
	if p.flying then
		flying = true
		for sq in all(squares) do
			if sq.fall then
				sq.p = true
			end
		end
	end
end,"falling squares")

append("get_range",function(p)
	if flying then
		flying = nil
		for sq in all(squares) do
			if sq.fall then
				sq.p = nil
			end
		end
	end
end,"falling squares")

local ri
local rsq
prepend("gsq",function(x,y,di,n,_,raw)
	if raw or flying then return end
	local sq = gsq(x,y,di,n,nil,true)
	if sq and sq.fall then
		for i,v in ipairs(squares) do
			if sq == v then
				ri = i
				rsq = sq
				squares[i] = false
				break
			end
		end
	end
end,"falling squares")

append("gsq",function(x,y,di,n,_,raw)
	if raw or flying then return end
	if ri then
		squares[ri] = rsq
		ri = nil
		rsq = nil
	end
end,"falling squares")

-- Stop throwing grenades towards void
function avoid_grenades(but,sq)
	if stack.special == "grenade" and sq.fall and but.right_clic then
		but.right_clic = nil
	end
end
add(on_sq_but_init,avoid_grenades)
--]]

append("set_mode",function()
	function mode.get_squares(t,e,max_range,flying,add_sq,min_range,d)
		-- d = d or 1
		-- local i = 1
		-- local x = e.sq.px
		-- local y = e.sq.py
		-- while i <= #t do
		-- 	if (max_range and d > max_range) then return end
		-- 	if type(t[i]) == "number" then
		-- 		local sq = gsq(x+t[i],y+t[i+1])
		-- 		if not sq then return end
		-- 		if not (min_range and d < min_range) then add_sq(sq) end
		-- 		if ((sq.moat and not e.moat) or (sq.p and sq.p.bad)) and not flying then break end
		-- 		i = i+2
		-- 		d = d+1
		-- 	else
		-- 		mode.get_squares(t[i],e,max_range,flying,add_sq,min_range,d)
		-- 		i = i+1
		-- 	end
		-- end
		d = d or 1
		local i = 1
		local x = e.sq.px
		local y = e.sq.py
		while i <= #t do
			if (max_range and d > max_range) then return end
			if type(t[i]) == "number" then
				local sq = gsq(x+t[i],y+t[i+1])
				local dd = d
				if min_range and d < min_range then dd = -1 end
				if e == hero then
					if dd == -1 then
						if not sq then return end
						if not flying and (sq.p or (sq.moat and not e.sq.moat)) then return end
					elseif not add_sq(sq) then return end
				elseif not add_sq(sq,dd) then return end
				i = i+2
				d = d+1
			else
				mode.get_squares(t[i],e,max_range,flying,add_sq,min_range,d)
				i = i+1
			end
		end
	end

	function mode.strike(p)
		xpl(p)
		screen_shake(4)

		fx_red_flash()
		
		local e=mke(0,p.x+8,p.y+10)

		local a={}
		local x,y=e.x,e.y
		local ec=8
		while y>-32 do
		add(a,{x=x,y=y})
		x=x+hrnd(ec)
		y=y-8-rnd(16+ec)
		ec=ec*1.5
		end
		e.life=10
		e.dp=DP_FX
		e.dr=function(e,x,y)
		
			for p in all(a) do
				line(x,y,p.x,p.y,sget(e.life,1))
				x,y=p.x,p.y
			end
			
		end
		
		-- SPARKS
		for i=0,8 do
			local e=mke(0,e.x,e.y)
			impulse(e,rnd(1),2)
			e.frict=.75+rnd(.23)
			e.life=8+rnd(32)
			e.vz=-rnd(3)
			e.we=rnd(.05)
			e.dr=function(e,x,y)
				pset(x,y,5)
			end
			e.drs=function()
				local x,y=e.x,e.y
				pset(x,y,bright(pget(x,y),-1))
			end
		
		end

		rumble(0, 0.4, 0.75, 0.12)
	end

	function mode.hero_fail(tempo,e)
		remove_buts()
		hero.fail = true
		fx_detect(tempo,e)
		wait(tempo,xpl_king,hero)
	end

	function mode.heal(p,hp)
		sfx("healing",0.3)
		p.hp=min(p.hp+hp,p.hp_max)
		fx_emote(p,"heart")
	end

	function mode.square_fall(sq,animation)
		if animation then
			sq.c_deep = 1
			sq.rev_c = true
			sq.life = 80
		end

		sq.fall = true
		sq.reserved = true
		-- if sq.p and sq.p ~= hero then
		-- 	local p = sq.p
		-- 	leave_sq(p)
		-- 	xpl(p)
		-- end
		-- for di=0,7 do
		-- 	local nsq = dsq(sq,di)
		-- 	if nsq then
		-- 		local fall = true
		-- 		for di2=0,7 do
		-- 			if dsq(nsq,di2) then
		-- 				fall = nil
		-- 				break
		-- 			end
		-- 		end
		-- 		if fall then
		-- 			trigger("fall",{sq=nsq})
		-- 		end
		-- 	end		
		-- end
	end

end,"extra functions")

append("start_lvl_music",function() if hero then hero.fail=nil end end,"terminal")


function get_blue()
	local plt = palette()
	for k,v in pairs(plt) do if v == 0xdfff then
		blue = k-1
		return
	end end
	add(plt,0xdfff)
	palette(plt)
	blue = #plt-1
end

get_blue()

target("gfx")
spritesheet("gfx")
sspr(20,0,1,10,16+blue,-1)
sset(blue,0,blue)
sset(16+blue,4,blue)
target()

prepend("rectshade",function(px,py,ww,hh,n)
	local n=n or -1
	local i = blue
	blend(1,i,bright(i,n))
end,"pal blue")

append("rectshade",function(px,py,ww,hh,n)
	local n=n or -1
	local i = blue
	blend(1,i,1)
end,"pal blue")

-- local pall
-- append("pal_inc",function(fd) if fd and fd<0 then pall = true pal(blue,mid(1,4+fd,8)) pall=false end end,"fade")
-- append("pal", function(ca,cb)
-- 	if not pall then
-- 		pall = true
-- 		if fd and fd<0 then pal(blue,mid(1,4+fd,8),true) end
-- 		pall = false
-- 	end
-- end,"fade")



local carrier
append("goto_sq",function(p,sq,t,f) if f==init_new_turn then carrier = p end end,"terminal")
prepend("init_new_turn",function() carrier=nil end,"terminal")
add(autocall.on_bad_death,function(p) 
	if p == carrier then
		wait(TEMPO,function() if p == carrier then
			init_new_turn()
		end end)
	end
end)

append("new_level",function()
	if not mode.turns then
		mode.turns = 0
	end
end,"terminal")

prepend("get_lang",function(s,reps)
	if reps and type(reps) == "table" then
		for key in all{"<piece>","<pieces>"} do
			if reps[key] then
				local str = reps[key]
				if sub(str,1,6) == "black " then
					reps[key] = sbs(str,"black ",get_lang("black").." ")
				end
			end
		end
	end
end,"fix black effect")

function set_signature()
	local credit = mke(-1,MCW)
	credit.glacies = "credit"
	credit.dr = function(self,x,y)
		rectfill(x,MCH-9,MCW,MCH,2)
		lprint(current_lang=="simplified_chinese" and "冰凌中枢" or "Glac Terminal",x+2,MCH-7,blue)
	end
	mvt(credit,MCW-55,0,25,bind(wait,60,function()
		mvt(credit,MCW,0,25,bind(kl,credit))
		credit.twcv = ease_in
	end))
	credit.twcv = ease_out
end

append("init_menu",set_signature,"terminal signature")