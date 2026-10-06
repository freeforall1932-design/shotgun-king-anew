id="throne"
setup={
	slots_max={10,10},
}
weapons={
	{ gid=0, name="Solomon",			chamber_max=2, firepower=4, spread=55, ammo_max=6, },
	{ gid=1, name="Victoria", 		chamber_max=1, firepower=5, firerange=1, spread=45, ammo_max=3, },
	{ gid=2, name="Ramesses II",	chamber_max=2, firepower=4, spread=65, ammo_max=5, knockback=50, },
	{ gid=3, name="Richard III",	chamber_max=3, firepower=3, firerange=2, spread=75, ammo_max=8, pierce=40 },
	{ gid=4, name="Makeda",				chamber_max=2, firepower=3, spread=50, ammo_max=6, blade=2, butcher=1 },
	{ gid=5, name="Alexander",		chamber_max=2, firepower=4, spread=65, ammo_max=8, search=1 },
	{ gid=6, name="Yvan IV",			chamber_max=1, firepower=4, firerange=-1, spread=50, ammo_max=6, all_freereload=1 },
	{ gid=7, name="Attila",				chamber_max=1, firepower=4, spread=65, ammo_max=5,	grenades_max=1, special="grenade", reload_grenade=1, grenade_dmg=-1 },
	{ gid=8, name="Montezuma",		chamber_max=3, firepower=3, spread=65, ammo_max=6,	sheath=1  }
	
}


-- NEW SHOTGUN : ghost shotgun : +1 soul slot + start empty ( +1 regen ammo )
ranks={
	{ nothing=1 },
	{ gain={0,0} },
	{ gain={3} },
	{ ai_lvl=1 },
	{ gain={1} },
	
	{ royal_promote=1 },	-- { spread=10 }
	{ king_hp=1 },
	{ gain={2} },	
	{ rook_hp=1 },
	{ ai_lvl=1 }, 
	
	{ boss_hprc=200 },
	{ spread=15 },
	{ rook_hp=1 },
	{ king_hp=1 },
	{ bishop_hp=1 },
	
	
	{ knight_hp=1 },
	{ queen_hp=1 },
	{ king_hp=1 },
	{ rook_hp=1 }, 
	{ pawn_hp=1,  ammo_max=1 },
	
	
	
	--{ all_hp=1, ammo_max=2 },
	
	
	
}
base={
	pawn_global_promote=1, surrender=1,
	gain={0,0,0,1,5,2,0},
	ai_lvl=0,
	--
	firerange=3,

}

intro=true

-- X2-4 Y4 weapons unlock
-- X0 ranks pref
-- X1 weapon pref

function initialize()
	newsrf("weapons", "assets/gfx/weapons.png")
	if not DEN.prog.throne then DEN.prog.throne={} end
	mode.ranks_index=mid(0,DEN.prog.throne.rank_sel or 0,#ranks-1)
	if FORCE_RANK then mode.ranks_index=FORCE_RANK end
	mode.weapons_index=mid(0,DEN.prog.throne.weapon_sel or 0,#weapons-1)
end

function start()

	if intro and not NO_INTRO then
		intro=false
		init_vig({1,2,3},start)
		return
	end

	if LIVE then
		live("send_event", "BeginThroneMode", "{\"Rank\":"..(mode.ranks_index + 1).."}")
		live("set_presence", "throne")
	end

	if PSN then
		local completed={}
		local available={}
		local max_rank=DEN.prog.throne.rank or 0
		add(available, "throne_progress")
		for i=1,max_rank do
			if i ~= mode.ranks_index + 1 then
				add(completed, "rank_"..i)
				add(available, "rank_"..i)
			end
		end
		add(available, "rank_"..(mode.ranks_index + 1))

		psn("add_available_activities", available)
		psn("resume_activities", "throne_progress", { "rank_"..(mode.ranks_index + 1) }, completed)
	end
	init_game()
	mode.lvl=0
	mode.turns=0
	
	restore_run()

	if START_LVL then
		build_stack()
		mode.lvl=START_LVL
		for ti=0,1 do
			for fi=1,min(START_LVL,10) do
				local ca=pick({team=ti})
				local card=new_card(ca.id)
				if get_free_card_slot(card)==nil then
					kl(card)
					break
				end
				add_card(card)
				ca.n=ca.n-1
				if ca.n>0 then add(cards.pool,ca) end
			end
		end
	end

	if mode.lvl==11 then
		add(upgrades,{gain={6},sac={5}})
	end


	next_floor()

end
function next_floor()
	save_run()
	
	mode.lvl=mode.lvl+1
	new_level()
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
		}

		if mode.lvl==3 then
			for i=1,2 do 
				data.choices[i][2].id="Homecoming"
			end
		end
		
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
	
	local throne = DEN.prog.throne

	-- BOSS BADGES
	local wep = mode.weapons_index+1
	local badges = throne.badges
	if not badges then badges={} throne.badges=badges end
	if not badges[wep] then badges[wep]={} end
	badges=badges[wep]
	
	if hero.apo then
		v={14}
		trig_achievement("NEW_JOB")
		badges[4]=true
	elseif boss.book then
		best=14
		v={8,6,11}
		trig_achievement("AVENGED")
		badges[0]=true
		if chamber>0  then
			best=15
			v={8,9,10,6,12}
			trig_achievement("EXORCISED")
			badges[1]=true
		end
	elseif boss.type==10 then
		v={13,6,7}
		trig_achievement("MARITAL_PEACE")
		badges[2]=true
	elseif boss.type==11 then
		v={15,6,7}
		trig_achievement("END_OF_THE_WORLD")
		badges[3]=true
	end
	
	-- BEST FLOOR & BEST RANK
	local rank=mode.ranks_index+1
	if not throne.lvl then throne.lvl={} end
	if mode.lvl>(throne.lvl[rank] or 0) then
		throne.lvl[rank]=mode.lvl
	end
	
	if rank>(throne.rank or 0) then
		throne.rank=rank
	end
	
	if rank>(badges.rank or 0) then -- weapon rank
		badges.rank=rank
	end

	-- BEST TIME
	if not throne.best_time or type(throne.best_time)~="table" then throne.best_time={} end
	local best_time=throne.best_time[rank] or 0
	if best_time==0 or chrono_time<best_time then
		throne.best_time[rank] = chrono_time
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
	DEN.prog.save()


	-- COLLECTION
	check_collections()


	init_vig(v,init_menu)
end

-- ON
function on_empty()
	end_level(grow)
end
function on_hero_death()
	if PSN then
		psn("end_activity", "rank_"..(mode.ranks_index + 1), "abandoned")
	end

	local rank=mode.ranks_index+1
	local throne=DEN.prog.throne
	if not throne.lvl then throne.lvl={} end
	if mode.lvl>(throne.lvl[rank] or 0) then
		throne.lvl[rank]=mode.lvl
		DEN.prog.save()
	end
	
	forget_run()
	
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
	
	forget_run()

	-- END GAME
	music("ending_A",0)
	fade_to(-4,30,outro)

end

-- WEAPONS & pref
function get_weapons_list()
	local a={0}
	local unl = DEN.prog.throne.weapon_unl
	if unl then
		for i=2,#weapons do
			if unl[i] then add(a,i-1) end
		end
	end
	return a
end

function draw_badges(x,y,wep)
	local badges=DEN.prog.throne.badges
	if not badges or not badges[wep] then return end
	badges=badges[wep]	
	local rnk=badges.rank or 0
	if rnk>0 then
		local x=x+28
		spr(400+flr(rnk/5), x-8, y-4, 1, 1.5)
		lprint(rnk, x, y+4, 4, 1)
	end	
	for i=0,4 do
		if badges[i] then
			spr(384+i, x+91+i*8, y-4+(i%2)*7)
		end
	end
	
end

function get_max_rank()
	return (DEN.prog.throne.rank or 0)+1
end
function get_best_time()
	if DEN.prog.throne.best_time and type(DEN.prog.throne.best_time)=="table" then
		return DEN.prog.throne.best_time[mode.ranks_index+1] or 0
	end
	return 0
end

function check_unlocks()

	local unl=DEN.prog.throne.weapon_unl
	if not unl then
		unl={}
		DEN.prog.throne.weapon_unl=unl
	end
	
	local function unlock(x)
		if not unl[x] then
			unl[x] = true
			DEN.prog.save()
			fx_unlock(weapons[x].name,{icon={x=21,y=282,w=12,h=6}})
		end
	end
	if get_firerange()>=6 then unlock(2) end
	if stack.knockback>=100 then unlock(3) end
	if stack.chamber_max>=4 then unlock(4) end
	if stack.blade and stack.blade>=4 then unlock(5) end
	if (inter.searched or 0) >= 4 then unlock(6) end
	if stack.firerange==0 then unlock(7) end
	if (stack.sheath or 0)>=2 then unlock(9) end
	

	local gun_sq=gsq(7,1)
	if mode.ranks_index==5 and mode.lvl==8 and gun_sq.dug and not unl[8] then
		-- verifier avec trench
		sfx("jingle_theme")
		local e=mke(0,gun_sq.x+8,gun_sq.y+8)
		e.z=-4
		e.life=180
		e.blink=30
		e.dr=function(e,x,y)		
			if e.t<60 and cyc(2,3)==0 then pal(4,5) end
			e.z=e.z-1/20
			spritesheet("weapons")
			sspr(96,128,24,8,x-12,y+e.z)
			spritesheet("gfx")			
			pal()
		end		
		e.drs=function()
			shpr(20,12,7,4,e.x,e.y)		
		end		
		unlock(8)		
	end		
		
	

	--unl[8]=false
	--unlock(8)
	--log("rank:"..mode.ranks_index.." floor:"..mode.lvl)
	

end
function save_preferences()
	DEN.prog.throne.rank_sel = mode.ranks_index
	DEN.prog.throne.weapon_sel = mode.weapons_index
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
end


