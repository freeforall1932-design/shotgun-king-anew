id="endless lab"
setup={
	slots_max={10,10},
}
base={
	chamber_max=2, firepower=4, firerange=3, spread=55, ammo_max=5,
	pawn_promote=1, surrender=1,
	gain={3,0,0,0,1,5,2,0},
	ai_lvl=1,
}

function initialize()
	newbnk(128,64,4)
	local v1513b = 1
	bset(0,1,v1513b)
	savbnk()
	
	local plt = palette()
	for k,v in pairs(plt) do if v == 0xdfff then
		blue = k
		return
	end end
	add(plt,0xdfff)
	palette(plt)
	blue = #plt
end

function enable_jump()
	mk_text_but(56,board_y+16*8+8,48,lang.jump_to_boss,function() if playing and mode.lvl < 12 then
		remove_buts()
		end_level(function()
		mode.lvl = 11
		grow()
	end) end end).ents[1].button = false
end

function start()
	if LIVE then
		live("set_presence", "endless")
	end

	init_game()

	-- mode.unlimited = false

	for i=1,10 do
		add_card("Black Wild Card")
		add_card("White Wild Card")
	end
	enable_jump()

	-- local b = mk_but(0,0,16,16,function()
	-- 	mode.unlimited = true
	-- 	sfx("lift")
	-- end)
	-- b.button = false
	-- add_child(mke(0xfc,109,board_y+16*8+5),b)
	-- mk_hint_but(109,board_y+16*8+5,16,16,lang.unlimited_desc,{4,3,5}).button = false

	mode.lvl=0
	mode.turns=0

---[[
	prob = mke()
	cnt = 100
	prob.upd = function()
		if btn("ctrl") and hero and hero.current_an then
			for p in all(bads) do
				p.prob = {}
			end
			local spread = get_spread()
			local lower_bound = hero.current_an - spread/720
			local firerange = get_firerange()
			for an = 1,cnt do
				local angle = lower_bound + (an-0.5)*spread/cnt/360
				local dmg = 1
				for r = 0,(firerange+2)*2 do
					if r > firerange*2 then
						dmg = dmg - 0.2
					end
					for radius = (r-1)*8+1,r*8 do
						if radius >= 0 then
							local x = hero.x+8+radius*cos(angle)+8*cos(hero.current_an)
							local y = hero.y+8+radius*sin(angle)+8*sin(hero.current_an)
							for X = x,x+1 do
								for Y = y,y+1 do
									local sq = get_square_at(X,Y)
									if sq and sq.p and sq.p.bad and not sq.p.prob[tostr(angle)] then
										sq.p.prob[tostr(angle)] = dmg
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	prob.dr = function()
		if btn("ctrl") and hero and hero.current_an then
			for p in all(bads) do
				local sum = 0
				if p.prob then
					for k,v in pairs(p.prob) do
						sum = sum+v
					end
				end
				if sum > 0 then
					lprint(sum/(cnt)*100,p.x,p.y,5)
				end
			end
		end
	end
	
	prob.dp = 4
	--]]

	next_floor()
end
function next_floor()
	mode.lvl=mode.lvl+1
	new_level()	
	if LIVE then
		live("send_event", "BeginEndlessFloor", "{\"Floor\":"..mode.lvl.."}")
	end
end
function on_empty()
	end_level(grow)		
end
function on_hero_death()
	-- bank("save")
	-- if mode.lvl > bget(0,2) then
	-- 	bset(0,2,mode.lvl)
	-- end
	-- save()
	gameover()	
end


function grow()

	if mode.lvl<11 then
		next_floor()
	else			
		decay_up(next_floor)
	end	
end

--
function draw_inter()
	local s = lang.floor_.." "
	local x = lprint(s,MCW/2,board_y-19,3,1)
	lprint(mode.lvl,x,board_y-19,5)
	lprint(lang.signature,199,166,blue-1)
end
