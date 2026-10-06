id="Fairy Endless"

-- MODS.some_fairy_pieces and 
local centaur_typ = MODS.some_fairy_pieces and MODS.some_fairy_pieces.env.centaur_typ or MODS["3342310033"].env.centaur_typ
local archbishop_typ = MODS.some_fairy_pieces.env.archbishop_typ or MODS["3342310033"].env.archbishop_typ
local chancellor_typ = MODS.some_fairy_pieces.env.chancellor_typ or MODS["3342310033"].env.chancellor_typ
local amazon_typ = MODS.some_fairy_pieces.env.amazon_typ or MODS["3342310033"].env.amazon_typ
local commoner_typ = MODS.some_fairy_pieces.env.commoner_typ or MODS["3342310033"].env.commoner_typ
local gryphon_typ = MODS.some_fairy_pieces.env.gryphon_typ or MODS["3342310033"].env.gryphon_typ
local prince_typ = MODS.some_fairy_pieces.env.prince_typ or MODS["3342310033"].env.prince_typ
local banner_typ = MODS.some_fairy_pieces.env.banner_typ or MODS["3342310033"].env.banner_typ

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

base={
	promotion=1, -- Pawn promotion disabled for this game mode
	surrender=1,
	-- gain = {5}
	gain={3,0,0,0,1,5,2,0},
}

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
	-- You have to create a bank if you want to save stuff.
	-- This isn't needed if you already created a save bank in your script.lua file.
	newbnk(128,64,4)
	sk_unlock_all_guns("Fairy Endless")
	mode.ranks_index=bget(0,4)
	mode.weapons_index=bget(1,4)
end

function start()
	init_game()
	mode.lvl=0
	mode.turns=0
	next_floor()
end

-- Progression
function on_empty()
	-- When the floor is cleared we end the level.
	end_level(grow)
end

function next_floor()
	mode.lvl=mode.lvl+1
	new_level()
end

function grow()
	-- Level up

	local data={
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

	if mode.lvl<11 then
		level_up(data,next_floor)
	else
		decayf_up(next_floor)
	end
end

function modulo(a, b)
	while (a > b) do
		a = a - b
	end
	return a
end
function decayf_up(next_floor)
	local floor_to = mode.lvl + 1
	local random = 0
	local army_size = 0
	for k, v in pairs(white_army) do
		army_size = army_size + 1
	end
	if (modulo(floor_to, 10) == 0 or army_size >= 56) then
		add(upgrades, {all_hp=1})
	else
		random = rnd(25)
		if (random <= 3) then
			add(upgrades, {gain={0, 0}})
		elseif (random <= 6) then
			add(upgrades, {gain={1}})
		elseif (random <= 9) then
			add(upgrades, {gain={2}})
		elseif (random <= 12) then
			add(upgrades, {gain={3}})
		elseif (random <= 15) then
			add(upgrades, {gain={4}})
		elseif (random <= 16) then
			add(upgrades, {gain={centaur_typ}})
		elseif (random <= 17) then
			add(upgrades, {gain={archbishop_typ}})
		elseif (random <= 18) then
			add(upgrades, {gain={chancellor_typ}})
		elseif (random <= 19) then
			add(upgrades, {gain={amazon_typ}})
		elseif (random <= 20) then
			add(upgrades, {gain={commoner_typ}})
		elseif (random <= 21) then
			add(upgrades, {gain={gryphon_typ}})
		elseif (random <= 21.5) then
			add(upgrades, {gain={prince_typ}})
		elseif (random <= 24.5) then
			add(upgrades, {all_hp=1})
		else
			add(upgrades, {gain={banner_typ}})
		end
	end
    next_floor()
end

function on_hero_death()	
	progress(0,2,mode.lvl)
	save()
	gameover()	
end

-- Weapons & unlocks
function get_weapons_list()
	bank()
	local a={0}
	for i=2,#weapons do
		if bget(i,4)==1 then add(a,i-1) end
	end
	return a
end

function check_unlocks()
	
	bank()
	local function unlock(x) 
		if bget(x,4)==0 then
			bset(x,4,1)
			save()
			fx_unlock(weapons[x].name,{icon={x=21,y=282,w=12,h=6}})
		end
	end
	if get_firerange()>=6 then unlock(2) end
	if stack.knockback>=100 then unlock(3) end
	if stack.chamber_max>=4 then unlock(4) end
	if stack.blade and stack.blade>=4 then unlock(5) end
	-- SK-REWORK (Build 8 item 4): base Throne rules for the added guns
	if (inter.searched or 0) >= 4 then unlock(6) end
	if stack.firerange==0 then unlock(7) end
	if (stack.sheath or 0)>=2 then unlock(9) end
	savbnk()

	
end

function save_preferences()
	bset(0,4,mode.ranks_index)
	bset(1,4,mode.weapons_index)
	save()
	sk_savbnk() -- SK-REWORK
	--log(mode.ranks_index)
end

-- Interface
function draw_inter()
	local s = lang.floor_.." "
	local x = lprint(s,MCW/2,board_y-19,3,1)
	lprint(mode.lvl,x,board_y-19,5)
end

append("goto_sq", function(e, sq)
	if e.type == 0 and sq.py == 7 then
		add_event(ev_promote, e)
	end
end, "some_fairy_pieces:fe_gtsq")

--[[
PIECES={
	{ type=0, name="pawn", 		hp=3, tempo=5, 
		behavior={
			{ id="line",1,1,1,  move=1 },
			{ id="line",4,5,1,  atk=1 },			
		},
		danger=1, seek="wdist", hdy=2, 
	},
	{ type=1, name="knight", 	hp=3, tempo=3, 
		behavior={
			{ id="jump", move=1, atk=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
		},
		danger=3, seek="kdist", hdy=1, nocarry=1 
	},
	{ type=2, name="bishop", 	hp=4, tempo=3,
		behavior={
			{ id="line",4,7,8,  move=1, atk=1 },
		},
		danger=3, seek="bdist", hdy=0 
	},
	{ type=3, name="rook", 		hp=5, tempo=4,
		behavior={
			{ id="line",0,3,8,  move=1, atk=1 },
		},
		danger=6, seek="rdist", hdy=1, nocarry=1
	},	
	{ type=4, name="queen", 	hp=5, tempo=4,
		behavior={
			{ id="line",0,7,8,  move=1, atk=1 },
		},
		danger=9, seek="qdist", hdy=0
	},
	{ type=5, name="king", 		hp=8, tempo=4,
		behavior={
			{ id="line",0,7,1,  move=1, atk=1 },
		},
		danger=6, seek="wdist", hdy=0 
	},
	{ type=6, name="boss", 		hp=24, tempo=3, boss=1,
		behavior={
			{ id="line",0,3,1,  move=1, },
			{ id="jump",2,0,2,1, 0,2,1,2, -1,0,-1,1,  0,-1,1,-1,  atk=1, fatality="eat" },
		},
		danger=16, big=true, seek="wdist", hdy=-24, nocarry=1,
	},  -- was 24
	{ type=7, name="all", 		}, 
	{ type=8, name="leader", 	},
	{ type=9, name="cannonball", 	hp=99, tempo=4,
		behavior={},
		seek="wdist", hdy=0, inert=true, freelift=1, nocarry=1, knockback=100, 
	},
	{ type=10, name="queen mother", hp=30, tempo=4,
		behavior={
			{ id="line",0,7,8,  move=1, atk=1 },
		},
		danger=16, seek="qdist", hdy=0, boss=1, unlift=1 
	},
	{ type=11, name="horseman", 	hp=12, tempo=4,
		behavior={
			{ id="jump", move=1, atk=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
		},
		danger=9, seek="kdist", hdy=0, team_boss=1, soul_fx=1, unlift=1
	},
}
--]]