id="nightmare"
nightmare = true
setup={
	slots_max={10,10},
}
ban={"Devil's Deception",
"Revenge",
"Recycle",
"Sacrifice",
"Patience"}

weapons={
	{ gid=0, name="Solomon",			chamber_max=2, firepower=4, firerange=3, spread=55, ammo_max=6, },
	{ gid=1, name="Victoria", 		chamber_max=1, firepower=5, firerange=4, spread=45, ammo_max=3, },
	{ gid=2, name="Ramesses II",	chamber_max=2, firepower=4, firerange=3, spread=65, ammo_max=5, knockback=50, },
	{ gid=3, name="Richard III",	chamber_max=3, firepower=3, firerange=5, spread=75, ammo_max=8, pierce=25 },
	{ gid=4, name="Makeda",				chamber_max=2, firepower=3, firerange=3, spread=50, ammo_max=6, blade=2 },
	{ gid=5, name="Alexander",		chamber_max=2, firepower=4, firerange=3, spread=65, ammo_max=8, search=1 },
	{ gid=6, name="Yvan IV",			chamber_max=1, firepower=4, firerange=2, spread=50, ammo_max=6, all_freereload=1 },

}
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

-- newbnk(128,64,4)

-- intro=true

-- X2-4 Y4 weapons unlock
-- X0 ranks pref
-- X1 weapon pref

function initialize()
	newsrf("weapons.png", "weapons")
	mode.ranks_index=mid(0,SAVE.nightmare.rank_sel or 0,#ranks-1)
	mode.weapons_index=mid(0,SAVE.nightmare.weapon_sel or 0,#weapons-1)

	get_blue()
end

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

function start()

	init_game()
	mode.lvl=0
	mode.turns=0

	--[[
	-- add_card("Theocracy")
	-- add_card("The Red Book")
	add(upgrades,{firepower=200,spread=50,firerange=10})
	mode.lvl = 10
	--]]
	
	next_floor()
	-- grow()
	-- for i=1,10 do add_card(pick({team=0}).id) end
	-- for i=1,15 do add_card(pick({team=1}).id) end

end

function next_floor()
	mode.lvl=mode.lvl+1
	new_level()
end

function grow()
	if mode.lvl<6 then
		local data1 = {
			id="level_up",
			pan_xm=1,
			pan_ym=2,
			pan_width=80,
			pan_height=96,
			choices={
				{{team=0},{team=1}},
				{{team=0},{team=1}},
			},
			force={
				{lvl=3,id="Homecoming",choice_index=0, card_index=1, desc_key="queen_escape" },
				{lvl=3,id="Homecoming",choice_index=1, card_index=1, desc_key="queen_everywhere" }
			}
		}
		local data2 = {
			id="level_up",
			pan_xm=1,
			pan_ym=2,
			pan_width=60,
			pan_height=96,
			choices={
				{{team=0}},
				{{team=0}},
			},
			force={
				{id="Nightmare Blank", choice_index=1, card_index=0 },
			}
		}
		level_up(data1,bind(level_up,data2,next_floor))

	elseif mode.lvl < 16 then
		local data = {
			id="level_up",
			pan_xm=1,
			pan_ym=3,
			pan_width=80,
			pan_height=41*3,
			choices={
				{{team=0},{team=1}},
				{{team=0},{team=1}},
				{{team=1}},
			},
		}
		-- local data2 = {
		-- 	id="level_up",
		-- 	pan_xm=3,
		-- 	pan_ym=2,
		-- 	pan_width=128,
		-- 	pan_height=96,
		-- 	choices={
		-- 		{{team=1}},
		-- 		{{team=1}},
		-- 		{{team=1}},
		-- 	}
		-- }
		local function init_tear()
			for b in all(ents) do if b.iscard then
				for sl in all(card_slots) do if sl.x == b.x and sl.y == b.y then
					if sl.team == 1 or sl.ca.id == "Gunpowder Improvement" or sl.ca.id == "Bold Plan" then break end
					local function click()
						if btn("unsafe") then
							tear_apart(sl.ca)
							b.out()
							kl(b)
						end
					end
					b.left_clic = b.left_clic and merge_funcs(b.left_clic,click) or click
					break
				end end
			end end
			msg(lang.discard,36000)
		end
		level_up(data,next_floor)
		init_tear()
	elseif mode.lvl==16 then
		add(upgrades,{gain={6},sac={5}})
		build_stack()
		init_vig({4},next_floor)
	end
end

function outro()

	local v={6,7}
	local best=13

	local throne = SAVE.nightmare

	-- BOSS BADGES
	local wep = mode.weapons_index+1
	local badges = throne.badges
	if not badges then badges={} throne.badges=badges end
	if not badges[wep] then badges[wep]={} end
	badges=badges[wep]
	
	if hero.apo then
		v={14}
		badges[4]=true
	elseif boss.book then
		best=14
		v={8,6,11}
		badges[0]=true
		if chamber>0  then
			best=15
			v={8,9,10,6,12}
			badges[1]=true
		end
	elseif boss.type==10 then
		v={13,6,7}
		badges[2]=true
	elseif boss.type==11 then
		v={15,6,7}
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

	--
	SAVE.save()


	init_vig(v,init_menu)
end

-- ON
function on_empty()
	end_level(grow)
end

function on_hero_death()
	local rank=mode.ranks_index+1
	local throne=SAVE.nightmare
	if not throne.lvl then throne.lvl={} end
	if mode.lvl>(throne.lvl[rank] or 0) then
		throne.lvl[rank]=mode.lvl
		SAVE.save()
	end
	
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

function draw_badges(x,y,wep)
	local badges=SAVE.nightmare.badges
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
			spr(384+i, x+89+i*8, y-4+(i%2)*7)
		end
	end
	
end

function get_max_rank()
	-- return bget(0,1)+1
	return max((SAVE.nightmare.rank or 0)+1,10)

end

function get_best_time()
	if SAVE.nightmare.best_time and type(SAVE.nightmare.best_time)=="table" then
		return SAVE.nightmare.best_time[mode.ranks_index+1] or 0
	end
	return 0
end

function get_slot_data(team,i)
	local data

	if team == 0 then
		if i>9 then return nil end

		data={
			x=7+(i%2)*24,
			y=13+flr(i/2)*32,
			team=0,
		}	
	elseif team == 1 then
		if i>14 then return nil end

		data={
			x=7+(i%3)*22+MCW-48-26,
			y=13+flr(i/3)*32,
			team=1,
		}	
	end
	return data
end

function check_unlocks()

	-- local function unlock(x)
	-- 	-- log(bget(x,4))
	-- 	if bget(x,4)==0 then
	-- 		bset(x,4,1)
	-- 		savbnk()
	-- 		fx_unlock(weapons[x].name,{icon={x=21,y=282,w=12,h=6}})
	-- 	end
	-- end
	-- if get_firerange()>=6 then unlock(2) end
	-- if stack.knockback>=100 then unlock(3) end
	-- if stack.chamber_max>=4 then unlock(4) end
	-- if stack.blade and stack.blade>=4 then unlock(5) end


end
function save_preferences()
	SAVE.nightmare.rank_sel = mode.ranks_index
	SAVE.nightmare.weapon_sel = mode.weapons_index
	-- savbnk()
end

function draw_inter()
	local s = lang.floor_.." "
	local x = lprint(s,MCW/2,board_y-19,3,1)
	lprint(mode.lvl,x,board_y-19,5)
	lprint(lang.signature,199,171,blue)
end

--[[
local test = {
	firepower=100,
	firerange=10
}
tbl_import(base,test)
--]]
