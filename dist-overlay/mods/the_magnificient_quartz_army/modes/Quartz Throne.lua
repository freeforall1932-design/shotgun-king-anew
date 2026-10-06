id="Quartz Throne"

local tmqacat = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqacat
local tmqafox = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqafox
local tmqawolf = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqawolf
local tmqaplaguedoctor = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqaplaguedoctor
local tmqacatapult = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqacatapult
local tmqalieutenant = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqalieutenant
local tmqabulwark = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqabulwark
local tmqawraith = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqawraith
local tmqadog = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqadog
local tmqatanuki = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqatanuki
local tmqawatchtower = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqawatchtower
local tmqabowman = MODS.the_magnificient_quartz_army and MODS.the_magnificient_quartz_army.env.tmqabowman


setup={

	slots_max={10,10},
	
}


weapons={ -- SK-REWORK (Build 8 item 4): full base-game Throne list (9 guns,
	-- game code/modes/throne.lua); firerange made absolute (throne base=3).
	{ gid=0, name="Solomon",			chamber_max=2, firepower=4, firerange=3, spread=55, ammo_max=6, },
	{ gid=1, name="Victoria", 		chamber_max=1, firepower=5, firerange=4, spread=45, ammo_max=3, },
	{ gid=2, name="Ramesses II",	chamber_max=2, firepower=4, firerange=3, spread=65, ammo_max=5, knockback=50, },
	{ gid=3, name="Richard III",	chamber_max=3, firepower=3, firerange=5, spread=75, ammo_max=8, pierce=40 },
	{ gid=4, name="Makeda",				chamber_max=2, firepower=3, firerange=3, spread=50, ammo_max=6, blade=2, butcher=1 },
	{ gid=5, name="Alexander",		chamber_max=2, firepower=4, firerange=3, spread=65, ammo_max=8, search=1 },
	{ gid=6, name="Yvan IV",			chamber_max=1, firepower=4, firerange=2, spread=50, ammo_max=6, all_freereload=1 },
	{ gid=7, name="Attila",				chamber_max=1, firepower=4, firerange=3, spread=65, ammo_max=5,	grenades_max=1, special="grenade", reload_grenade=1, grenade_dmg=-1 },
	{ gid=8, name="Montezuma",		chamber_max=3, firepower=3, firerange=3, spread=65, ammo_max=6,	sheath=1 },
}


ranks={

	{ nothing=1 },
	{ gain={tmqacat} },
	{ gain={tmqabulwark} },
	{ gain={tmqacatapult},ai_lvl=1 },
	{ gain={tmqadog} },
	{ gain={tmqalieutenant} },		
	{ gain={tmqawraith,tmqawraith} },
	{ gain={tmqatanuki} },
	{ gain={tmqafox} },			
	{ gain={tmqawatchtower},ai_lvl=1 },
	{ gain={tmqabowman} },		
	{ gain={tmqawolf} },
	{ gain={tmqaplaguedoctor} },
	{ gain={tmqacat,tmqawolf}, ammo_max=3 },
	{ gain={tmqalieutenant,tmqawraith}, firepower=1 },
	
}


base={

	pawn_promote=1, surrender=1,
	gain={0,0,0,1,5,2,0,tmqacat},	

}


intro=true


-- SK-REWORK (Build 8 item 4): this mode used to keep its gun unlocks only in
-- RAM (it never called savbnk), so every boot started from zero. Flush the
-- mod bank after every save, and - owner's 100% intent - unlock all guns.
-- Set SK_ALL_GUNS = false to earn them again (state is kept in the bank).
local SK_ALL_GUNS = true
local function sk_savbnk()
	if type(savbnk) == "function" then savbnk() end
end
local function sk_unlock_all_guns(tag)
	if not SK_ALL_GUNS then return end
	local changed = 0
	for i = 2, #weapons do
		if bget(i, 4) ~= 1 then bset(i, 4, 1) changed = changed + 1 end
	end
	if changed > 0 then sk_savbnk() end
	log("SK-REWORK: " .. tag .. " guns=" .. #weapons .. " newly_unlocked=" .. changed)
end

function initialize()

	-- SK-REWORK (Build 8 item 4): tmqa_weapons.png is an old copy of the base
	-- sheet with only 5 guns; the engine loads the full 9-gun 'weapons' sheet
	-- at boot (code.lua:62), and overriding it also broke later modes.
	-- newsrf("weapons", "tmqa_weapons.png")
	sk_unlock_all_guns("Quartz Throne")
	mode.ranks_index=mid(0,bget(0,4),#ranks-1)
	mode.weapons_index=mid(0,bget(1,4),#weapons-1)
	
end

function start()

	if intro and not DEV then
		intro=false
		init_vig({1,2,3},start)
		return
	end

	init_game()
	mode.lvl=0
	mode.turns=0


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
		if START_LVL==11 and game_mode=="throne" then
			add(upgrades,{gain={6},sac={5}})
		end
	end


	next_floor()

end


function next_floor()

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

	local k=0
	if hero.apo then
		v={14}
		trig_achievement("NEW_JOB")
		k=16
	elseif boss.book then
		best=14
		v={8,6,11}
		trig_achievement("AVENGED")
		k=1
		if chamber>0  then
			best=15
			v={8,9,10,6,12}
			trig_achievement("EXORCISED")
			k=2
		end
	elseif boss.type==10 then
		v={13,6,7}
		trig_achievement("MARITAL_PEACE")
		k=4
	elseif boss.type==11 then
		v={15,6,7}
		trig_achievement("END_OF_THE_WORLD")
		k=8
	end
	
	bank("save")
	
	bset(mode.weapons_index+15,5,bor(bget(mode.weapons_index+15,5), k))

	-- BEST FLOOR & BEST RANK
	local rank=mode.ranks_index+1
	if mode.lvl>bget(rank,1) then bset(rank,1,mode.lvl) end
	if rank>bget(0,1) then bset(0,1,rank) end
	
	if rank>bget(mode.weapons_index, 5) then
		bset(mode.weapons_index,5,rank)
	end

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
	sk_savbnk() -- SK-REWORK


	-- COLLECTION
	check_collections()


	init_vig(v,init_menu)
	
end


function on_empty()

	end_level(grow)
	
end


function on_hero_death()

	if PSN then
		psn("end_activity", "rank_"..(mode.ranks_index + 1), "abandoned")
	end
	
	local rank=mode.ranks_index+1
	bank("save")
	if mode.lvl>bget(rank,1) then bset(rank,1,mode.lvl) end
	save()
	sk_savbnk() -- SK-REWORK
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


function get_weapons_list()

	local a={0}
	for i=2,#weapons do
		if bget(i,4)==1 then add(a,i-1) end
	end
	return a
	
end


function get_max_rank()

	return bget(0,1)+1
	
end


function check_unlocks()

	bank("save")
	local function unlock(x)
		if bget(x,4)==0 then
			bset(x,4,1)
			save()
			sk_savbnk() -- SK-REWORK
			fx_unlock(weapons[x].name,{icon={x=21,y=282,w=12,h=6}})
		end
	end
	if get_firerange()>=6 then unlock(2) end
	if stack.knockback>=100 then unlock(3) end
	if stack.chamber_max>=4 then unlock(4) end
	if stack.blade and stack.blade>=4 then unlock(5) end
	if (inter.searched or 0) >= 4 then unlock(6) end
	if stack.firerange==0 then unlock(7) end
	if (stack.sheath or 0)>=2 then unlock(9) end -- SK-REWORK: base Montezuma rule

end


function save_preferences()

	bset(0,4,mode.ranks_index)
	bset(1,4,mode.weapons_index)
	save()
	sk_savbnk() -- SK-REWORK

end


function draw_inter()

	local s = lang.floor_.." "
	local x = lprint(s,MCW/2,board_y-19,3,1)
	lprint(mode.lvl,x,board_y-19,5)
	
end


