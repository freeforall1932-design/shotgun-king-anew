id="card lab"
setup={
	slots_max={10,10},
}
weapons={
	{ gid=0, name="Solomon",			chamber_max=2, firepower=4, firerange=3, spread=55, ammo_max=6, },
	{ gid=1, name="Victoria", 		chamber_max=1, firepower=5, firerange=4, spread=45, ammo_max=3, },
	{ gid=2, name="Ramesses II",	chamber_max=2, firepower=4, firerange=3, spread=65, ammo_max=5, knockback=50, },
	{ gid=3, name="Richard III",	chamber_max=3, firepower=3, firerange=5, spread=75, ammo_max=8, pierce=25 },
	{ gid=4, name="Makeda",				chamber_max=2, firepower=3, firerange=3, spread=50, ammo_max=6, blade=2 },
	{ gid=4, name="Alexander",		chamber_max=2, firepower=4, firerange=3, spread=65, ammo_max=8, search=1 },
	{ gid=4, name="Yvan IV",			chamber_max=1, firepower=4, firerange=2, spread=50, ammo_max=6, all_freereload=1 },

}


-- NEW SHOTGUN : ghost shotgun : +1 soul slot + start empty ( +1 regen ammo )


ranks={
	{ nothing=1 },
	{ gain={0,0} },
	{ gain={3} },
	{ ai_lvl=1 },	-- was king_hp=1
	{ gain={1} },
	{ spread=10 },
	{ king_hp=1 },
	{ gain={2} },	
	{ rook_hp=1 },
	{ ai_lvl=1 }, -- knight_hp=1
	{ boss_hprc=200 },
	{ spread=15 },
	{ rook_hp=1 },
	{ ammo_max=-1 },
	{ all_hp=1, ammo_max=2 },
}
base={
	pawn_promote=1, surrender=1,
	gain={0,0,0,1,5,2,0},
	ai_lvl=0,

}
-- unlimited = true

-- X2-4 Y4 weapons unlock
-- X0 ranks pref
-- X1 weapon pref

function initialize()
	-- newsrf("assets/gfx/weapons.png", "weapons")
	newbnk(128,64,4)
	local v1513b = 1
	bset(0,0,v1513b)
	savbnk()
	mode.ranks_index = 0
	mode.weapons_index = 0
	get_blue()
end

function get_blue()
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
		next_floor()
	end) end end).ents[1].button = false
end

function start()

	init_game()
	
	mode.unlimited = false

	for i=1,10 do
		add_card("Black Wild Card")
		add_card("White Wild Card")
	end
	enable_jump()

	local b = mk_but(0,0,16,16,function()
		mode.unlimited = true
		sfx("lift")
	end)
	b.button = false
	add_child(mke(0xfc,109,board_y+16*8+5),b)
	mk_hint_but(109,board_y+16*8+5,16,16,lang.unlimited_desc,{4,3,5}).button = false

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
	if mode.lvl < 12 then new_level()
	elseif mode.lvl == 12 then
		add(upgrades,{gain={6},sac={5}})	
		new_level()
	end
end

function grow()
	if mode.lvl<11 then
		local data={
			id="level_up",
			pan_xm=1,
			pan_ym=2,
			pan_width=80,
			pan_height=96,
			choices={
				{{team=0},{team=1}}, --,{team=0}
				{{team=0},{team=1}},
			},
			force={
				{lvl=3,id="Homecoming",choice_index=0, card_index=1, desc_key="queen_escape" },
				{lvl=3,id="Homecoming",choice_index=1, card_index=1, desc_key="queen_everywhere" }
			}
		}
		level_up(data,next_floor)
	elseif mode.lvl==11 then
		add(upgrades,{gain={6},sac={5}})
		build_stack()
		init_vig({4},next_floor)
	end
end
function outro()

	local v={6,7}
	local best=13

	trig_achievement("COMPLETE")

	if hero.apo then
		v={14}
		trig_achievement("NEW_JOB")
	elseif boss.book then
		best=14
		v={8,6,11}
		trig_achievement("AVENGED")
		if chamber>0  then
			best=15
			v={8,9,10,6,12}
			trig_achievement("EXORCISED")
		end
	elseif boss.type==10 then
		v={13,6,7}
		trig_achievement("MARITAL_PEACE")
	elseif boss.type==11 then
		v={15,6,7}
		trig_achievement("END_OF_THE_WORLD")
	end

	-- BEST FLOOR & BEST RANK
	local rank=mode.ranks_index+1
	bank("save")
	if mode.lvl>bget(rank,1) then bset(rank,1,mode.lvl) end
	if rank>bget(0,1) then bset(0,1,rank) end

	-- BEST TIME
	local best_time=bget(rank,2)
	if best_time==0 or chrono_time<best_time then
		bset(rank,2,chrono_time)
		new_best_time=true
	end

	if LIVE then
		live("send_event", "EndThroneMode", "{\"Rank\":"..rank..", \"Milliseconds\":"..flr(chrono_time*16.66667).."}")
	end
	if PSN then
		psn("end_activity", "rank_"..rank, "completed")
		if rank < 15 then psn("add_available_activity", "rank_"..(rank+1))
		else psn("end_activity", "throne_progress", "completed") end
	end

	-- OTHER ACHIEVEMENTS
	local shotgun=weapons[mode.weapons_index+1]
	trig_achievement(sbs(uppercase(shotgun.name)," ", "_"))
	trig_achievement("RANK_"..(mode.ranks_index+1))
	ach_event("win")


	--
	save()


	-- COLLECTION
	check_collections()


	init_vig(v,init_menu)
end

-- ON
function on_empty()
	end_level(next_floor)
end
function on_hero_death()
	if PSN then
		psn("end_activity", "rank_"..(mode.ranks_index + 1), "abandoned")
	end
	
	-- local rank=mode.ranks_index+1
	-- bank("save")
	-- if mode.lvl>bget(rank,1) then bset(rank,1,mode.lvl) end
	-- save()
	gameover()
end
function on_boss_death()


	if boss.type==6 and not boss.dark then
		
		-- CHECK BLACK BISHOP SPAWN
		local bishops=get_pieces(2)
		local book=has_card("The Red Book")
		local theo=stack.torn_theo
		if book and theo and #bishops==1 then	
			storm_all_but(bishops[1],spawn_dark_bishop)	
			return
		end
		
		-- CHECK QUEEN MOTHER
		local queens=get_pieces(4)
		if #queens==1 and queens[1].iron then
			storm_all_but(queens[1],spawn_mother_queen)		
			return
		end
	
		-- CHECK HORSEMEN OF THE APOCALYPSE
		local knights=get_pieces(1)
		knights.list=1
		if #knights==4 then
			storm_all_but(knights,spawn_horsemen)
			return
		end
		
	end
	

	-- END GAME
	music("ending_A",0)
	fade_to(-4,30,outro)

end

-- WEAPONS & pref
function get_weapons_list()
	local a={0}
	for i=2,#weapons do
		add(a,i-1)
	end
	return a
end

function get_max_rank()
	return 30
end

function check_unlocks()



end
function save_preferences()
	-- bset(0,4,mode.ranks_index)
	-- bset(1,4,mode.weapons_index)
	-- save()
	--log(mode.ranks_index)
end
--
function draw_inter()
	--spritesheet("tutorial") -- bg (maybe add it as easter egg)
	--sspr(208,0,320,182,0,0)
	--spritesheet("gfx")

	local s = lang.floor_.." "
	local x = lprint(s,MCW/2,board_y-19,3,1)
	lprint(mode.lvl,x,board_y-19,5)
	lprint(lang.signature,199,166,mode.unlimited and 5 or blue-1)
end


