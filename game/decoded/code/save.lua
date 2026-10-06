SAVE_FILE="save/save.bnk"
STAT_FILE="save/stats.bnk"
ACH_FILE="save/achievements.bnk"
-- I moved save files to a save folder to support GOG cloud saves
-- -Remy
SAVE_VERSION=1
local load_ver


-- SAVE
local function get_version_num(version)
	local v
	local i=find(version, "%a")
	if i then
		v=tonum(sub(version, 1, i-1))+ord(sub(version,i,i))
	--if ord(sub(version,-1))>=65 then
	--	v=sub(version,1,-2)*1000000+ord(sub(version,-1))
	else
		v=version*1000000
	end
	return v
end


function check_save()
	--load_legacy_save()
	if not DEN.version then -- no recent save
		DEN.prog = {}
		DEN.stats = {}
		DEN.achievements = {}
		DEN.misc = {}
		
		_log("Attempting to load legacy save...")
		load_legacy_save()
	end
	
	if not DEN.runs then
		DEN.runs = {}
	end
	
	if not SET.music then -- loading default settings
		reset_settings()
	end
	
	-- achievements
	if STEAM then
		for i,ach in ipairs(ACHIEVEMENTS) do
			if steam("get_achievement", ach.steam) then
				DEN.achievements[ach.id] = true
			end
		end
	
	elseif PSN then
		-- made sure to use the subset of achievements defined under PS in achievements_data.lua
		local order = {"FULL_SET", "COMPLETE", "EXORCISED", "BLITZ", "BULLET", "SOLOMON", "VICTORIA", "RAMESSES_II", "RICHARD_III", "MAKEDA", "A_VELVET_GLOVE", "DELETED", "INCARNATION", "PROJECTILE_DYSFUNCTION", "HOPE_THIS_HITS", "UNDERPRESSURE_AMMO", "YOU_SHALL_NOT_PASS", "LIFEGUARD", "WIZARD", "HUMILIATION", "HOW_IT_SHOULD_BE", "SHE_IS_EVERYWHERE", "YOUR_WIFE_MY_WIFE", "GLUTTONY", "MR_PRESIDENT", "IRON_KING", "WIDOW", "RANK_5" , "RANK_10", "RANK_15", "ALEXANDER", "YVAN_IV"}
		
		for i,id in ipairs(order) do
			local v=0
			if psn("get_trophy", i) then
				DEN.achievements[id] = true
			end
		end
	elseif LIVE then
		_log("Waiting for achievement fetch to end...")
		while not live("fetch_achievements_result_ready") do
			freeze(0.016)
		end
		_log("Done")
		
		local order = {"FULL_SET","WIZARD","COMPLETE","AVENGED","EXORCISED","SWARM","LEGION","SNIPER","ASSASSIN","STEROID","TRIGGER_HAPPY","SCAVENGER","HAREM","SOCIAL_DISTANCING","RELIGION","SECRET","SECURITY_SERVICE","INQUISITION","MOBILITY","BOUNDARIES","MACHINE_GUN","SURVIVOR","DEMOLITION","HORSEMEN_OF_THE_APOCALYPSE","ROYAL_RETAINER","THE_FLOOR_IS_LAVA","EMPEROR","LATE_TO_THE_PARTY","UNEXPECTED_ENTRANCE","SWORDMAN","CLIFFHANGER","NINJA","SLAUGHTER","BENEVOLENCE","BUILDER","SOLOMON","VICTORIA","RAMESSES_II","RICHARD_III","MAKEDA","MERCIFUL_RULER","A_VELVET_GLOVE","DELETED","SQUARE_ALLEGIANCE","INCARNATION","LIKE_FATHER_LIKE_SON","HUMILIATION","HASTA_LA_VISTA_BABY","HOW_IT_SHOULD_BE","SHE_IS_EVERYWHERE","MORTAL_PERIL","PROJECTILE_DYSFUNCTION","HOPE_THIS_HITS","NINE_LIVES","YOUR_WIFE_MY_WIFE","A_MIGHTY_FORTRESS","UNDERPRESSURE_AMMO","GLUTTONY","IRON_KING","WIDOW","YOU_SHALL_NOT_PASS","BLITZ","BULLET","SUICIDE_PACT","OH_NO","MR_PRESIDENT","LIFEGUARD","MMMMH_DELICIEUX","RANK_1","RANK_2","RANK_3","RANK_4","RANK_5","RANK_6","RANK_7","RANK_8","RANK_9","RANK_10","RANK_11","RANK_12","RANK_13","RANK_14","RANK_15"}
		
		for i,id in ipairs(order) do
			local v=0
			if live("get_achievement", i) then
				DEN.achievements[id] = true
			end
		end
	end

	DEN.version = VERSION
	DEN.vernum = get_version_num(VERSION)
	SET.vernum = get_version_num(VERSION) -- DEN is stored on the Steam cloud, SET is not
end

function load_legacy_save()
	local save_loaded,stats_loaded = init_banks()
	
	if save_loaded then -- settings
		bank("save")
		local order = {"music", "sfx", "fullscreen", "crt", "speedrun", "shields", "scrshake", "scrflash", "lang", "hdtext", "rumble"}
		for i,k in ipairs(order) do
			SET[k] = bget(i-1, 0)
		end
		
		local langs
		if PC then
			langs = {
				"english",
				"french",
				"spanish",
				"german",
				"polish",
				"ukrainian",
				"russian",
				"simplified_chinese",
				"korean",
				"japanese",
				"catalan",
				"dutch",
				"romanian",
				"vietnamese",
				"italian",
				"portuguese",
				"latam",
			}
		elseif BUILD_TYPE == "NX_H2" then
			langs = {
				"english",
				"japanese",
				"korean",
				"traditional_chinese", -- /!\ H2 EXCLUSIVE /!\
				"simplified_chinese",
				
				"french",
				"spanish",
				"german",
				"polish",
				"ukrainian",
				"russian",
			}
		elseif BUILD_TYPE == "PS" then
			langs = {
				"english",
				"french",
				"spanish",
				"german",
				"polish",
				"ukrainian",
				"russian",

				"japanese",
				"korean",
				"traditional_chinese", -- /!\ H2 EXCLUSIVE /!\
				"simplified_chinese",
			}
		else
			langs = {
				"english",
				"french",
				"spanish",
				"german",
				"polish",
				"ukrainian",
				"russian",

				"japanese",
				"korean",
				"simplified_chinese",
			}
		end
		
		if SET.lang > #langs then
			set_default_lang()
		else
			SET.lang = langs[SET.lang+1]
		end
	end
	
	if save_loaded then -- progress
		bank("save")
		
		-- throne
		local throne = {
			rank_sel = bget(0,4),
			weapon_sel = bget(1,4),
			rank = bget(0,1),
			lvl = {},
			best_time = {},
			badges = {},
			weapon_unl = {}
		}
		
		for i=1,15 do
			local v=bget(i,1)
			if v>0 then throne.lvl[i] = v end
			local bt=bget(i,2)
			if bt>0 then throne.best_time[i]=bt end
		end
		
		for i=1,7 do
			throne.weapon_unl[i] = bget(i,4)==1
			throne.badges[i] = {
				rank = bget(i-1,5),
				[0] = band(bget(i+14,5),1)>0,
				[1] = band(bget(i+14,5),2)>0,
				[2] = band(bget(i+14,5),4)>0,
				[3] = band(bget(i+14,5),8)>0,
				[4] = band(bget(i+14,5),16)>0,
			}
			if throne.badges[i].rank==0 then throne.badges[i].rank=nil end
		end
		
		
		DEN.prog.throne = throne
		
		-- endless
		DEN.prog.endless = bget(0,2)
		if DEN.prog.endless == 0 then DEN.prog.endless=nil end
		
		-- chase
		DEN.prog.chase = {
			score = bget(0,3),
			turns = bget(1,3)
		}
		if DEN.prog.chase.score==0 and DEN.prog.chase.turns==0 then DEN.prog.chase=nil end
		
		-- tutorial
		DEN.prog.tutorialdone = bget(0,6)==1
	end
	
	if save_loaded then -- misc (codex decorations)
		bank("save")
		DEN.misc = {
			fireplace = bget(0,6)==1,
			codexitems = {}
		}
		for i=1,5 do
			DEN.misc.codexitems[i] = bget(i,6)
		end
	end
	
	if stats_loaded then -- stats
		local cards = { -- card list (by their gid) as they were before v1.515f
			[0]="Ermine Belt",
			[1]="Rightful Curtsy",
			[2]="Elite Gem",
			[3]="Extra Barrel",
			[4]="Royal Loafers",
			[5]="Majestic Censer",
			[6]="Sacred Crown",
			[7]="Blunderbuss",
			[8]="Engraved Scope",
			[9]="Holy Gunpowder",
			[10]="Ritual Dagger",
			[11]="August Presence",
			[12]="Crow's Blessing",
			[13]="Wand of Downpour",
			[14]="Wand of Frenzy",
			[15]="Wand of Wrath",
			[16]="Wand of Wings",
			[17]="The Moat",
			[18]="Gradual Absolution",
			[19]="Taunting Hop",
			[20]="Wand of Gust",
			[21]="Unfaithful Steed",
			[22]="Unjust Decree",
			[23]="Kingly Alms",
			[24]="Subtle Poison",
			[25]="Kingdom Wealth",
			[26]="Small Fry Harvest",
			[27]="A Piercing Truth",
			[28]="Black Mist",
			[29]="King's Shoulders",
			[30]="High Focus",
			[31]="Courteous Jousting",
			[32]="Cornered Despot",
			[33]="Sawed-off Justice",
			[34]="Welcome Gift",
			[35]="Cannon Fodder",
			[36]="Possessed",
			[37]="Philanthropy",
			[38]="Imperial Shot Put",
			[39]="Egotic Maelstrom",
			[40]="Church Organ",
			[41]="Black Plague",
			[42]="Ravenous Rats",
			[43]="Deep Water",
			[44]="Unholy Call",
			[45]="Undercover Mission",
			[46]="Caltrops",
			[47]="Nightbane",
			[48]="Bushido",
			[49]="Bloodless Coups",
			[50]="Wand of Hypnosis",
			[51]="Presbyopia",
			[52]="Golden Aging",
			[53]="Fool Companion",
			[54]="Force-feeding",
			[55]="Seer's Orb",
			[56]="Fearsome",
			[57]="Human Shield",
			[58]="Reign of Terror",
			[59]="Selective Listening",
			[60]="Monarch's Confidence",
			[61]="The Mole",
			[62]="Elusive",
			[63]="Holoking",
			[64]="Cloaking Device",
			[65]="Low-Cost Disguise",
			[66]="Wand of Souls",
			[67]="Wand of Execution",
			[68]="Patience",
			[69]="Bold Plan",
			[70]="Silencer",
			[71]="Ambush",
			[72]="Ancient Flagstone",
			[73]="Tearing Bullets",
			[74]="Indelible Memories",
			[75]="Mystic Shackles",
			[76]="Secret Move",
			[77]="Sacred Light",
			[78]="Workshop",
			[80]="Backups",
			[81]="Cavalry",
			[82]="Conclave",
			[83]="Entitle",
			[84]="Cardinal",
			[85]="Remparts",
			[86]="Pillage",
			[87]="Crusades",
			[88]="Peace",
			[89]="King's Mistress",
			[90]="Revolution",
			[91]="Bodyguard",
			[92]="Ruins",
			[93]="Assault",
			[94]="Kite Shield",
			[95]="Zealots",
			[96]="Militia",
			[97]="Ammunition Depot",
			[98]="Scouting",
			[99]="Pikemen",
			[100]="Ascension",
			[101]="Castle",
			[102]="Conscription",
			[103]="Theocracy",
			[104]="Fallen Dynasty",
			[105]="Iron Maiden",
			[106]="Court of the King",
			[107]="The Red Book",
			[108]="Saboteur",
			[109]="Homecoming",
			[110]="Lookout Tower",
			[111]="Throne Room",
			[112]="The Secret Heir",
			[113]="Genderqueer",
			[114]="Karma",
			[115]="Undead Armies",
			[116]="Shortage",
			[117]="Succubus",
			[118]="Bunker",
			[119]="Sanctity",
			[120]="Knightmare",
			[121]="Highest Dungeon",
			[122]="Cathedral",
			[123]="The Bridge",
			[124]="Divine Healing",
			[125]="Last Guardian",
			[126]="Trowel",
			[127]="Full Plate Armor",
			[128]="Military Academy",
			[129]="Witch's Curse",
			[130]="Saddle",
			[131]="The Jester",
			[132]="Guillotine",
			[133]="Analysis Paralysis",
			[134]="Plumed Knight",
			[135]="Emergency Call",
			[136]="Mangonel",
			[137]="Governess",
			[138]="Mausoleum",
			[139]="Reverend Mother",
			[140]="Sokoban",
			[141]="Tag Team",
			[142]="Unicorn",
			[143]="Lady in the Tower",
			[144]="Final Countdown",
			[145]="Nomad Life",
			[146]="Prison",
			[147]="Inquisition",
			[148]="King's Look-alike",
			[149]="The Royal Hunt",
			[150]="Tragic Homecoming",
			[151]="Buckler of Limos",
			[152]="Vampirism",
			[153]="Commoner's Reign",
			[154]="Bouncy Castle",
			[155]="Self-Defense",
			[156]="Unsettled Throne",
		}
		
		bank("stats")
		for gid,id in pairs(cards) do
			DEN.stats[id] = {
				played = bget((gid%80)*2, flr(gid/80)),
				ignored = bget((gid%80)*2+1, flr(gid/80))
			}
		end
	end
	
	do -- achievements
		local achiev = encfile("save/achievements.enc")
		if achiev then
			achiev = sub(achiev, 4, -4)
			local lst=split(achiev,"\t")
			local tbl={}
			for _,k in pairs(lst) do
				tbl[k] = true
			end
			
			for i,ach in ipairs(ACHIEVEMENTS) do
				if tbl[ach.id] then
					DEN.achievements[ach.id] = true
				end
			end
		end
	end
	
	DEN.prog.save()
	DEN.misc.save()
	DEN.stats.save()
	DEN.achievements.save()
	DEN.save()
	SET.save()
	
	if save_res then delbnk("save") end
	if stats_res then delbnk("stats") end
	
	do -- move legacy files
		local files = {	"save.bnk", "stats.bnk", "achievements.bnk", "achievements.enc"	}
		local any
		for f in all(files) do
			if isfile("save/"..f) then any=true end
		end
		
		if any then
			if not isfolder("save/old") then
				mkdir("save/old")
			end
			
			for f in all(files) do
				if isfile("save/"..f) then
					local foo = (f=="achievements.enc") and encfile or file
					local a = "save/"..f
					local b = "save/old/"..f
					
					foo(b, foo(a))
					foo(b.."_bak", foo(a.."_bak"))
					
					local res=foo(b)
					if res and res~="" then -- if copy succeeded, then delete
						rm(a)
						rm(a.."_bak")
					end
				end
			end
		end
	end
end


-- LEGACY SAVE
function check_corrupt(save)
  if not save then return nil end
	if #save==0 then
		wlog("Save seems to be corrupted, duplicating to 'save/corrupted_save.bnk'.")
		file("save/corrupted_save.bnk", save)
    return nil
	end
	
  local k = #save
  for i=1,k do
    local ch = ord(sub(save,i,i))
    if ch<48 or ch>70 or (ch>58 and ch<65) then
      wlog("Save seems to be corrupted, duplicating to 'save/corrupted_save.bnk'.")
      file("save/corrupted_save.bnk", save)
      save = nil
      break
    end
  end
  return save
end

--local function get_version_num(version)
--	local v
--	if ord(sub(version,-1))>=65 then
--		v=sub(version,1,-2)*1000000+ord(sub(version,-1))
--	else
--		v=version*1000000
--	end
--	return v
--end


function init_banks()
	if CONSOLE then 
		SAVE_FILE="save.bnk"
		STAT_FILE="stats.bnk"
		ACH_FILE="achievements.bnk"
	end
	
	local save_res, stats_res
	
	-- SAVE
	local save_data=file(SAVE_FILE)
	if not CONSOLE and not save_data then
		mkdir("save")
		save_data=file("save.bnk")
	end
	
	save_data = check_corrupt(save_data)
	if not save_data then
		save_data = check_corrupt(file(SAVE_FILE.."_bak"))
	end

	if save_data and not FORCE_RESET then
		_log("Found legacy save!")
		save_res = true
		
		newbnk("save",save_data)
		
		if bget(25,0)~=SAVE_VERSION then
			file("legacy_save.bnk", save_data)
			reset_save()
			wlog("outdated save")
		end
		
		load_ver=bget(26,0)
		bset(26,0,get_version_num(VERSION))
		
		if load_ver<1515000 then
			for i=0,29 do
				bset(i,5,0)
			end
		end
		
		if load_ver<1515100 then
			set_default_lang()
		end
	else
		_log("No legacy save could be found.")
		save_res = nil
	end
	
	-- STATS
	local stats_data=file(STAT_FILE)
	if not CONSOLE and not stats_data then
		stats_data=file("stats.bnk")
	end
	
	stats_data=check_corrupt(stats_data)
	if not stats_data then
		stats_data=check_corrupt(file(STAT_FILE.."_bak"))
	end
	
	if stats_data then
		_log("Found legacy save!")
		stats_res = true
		
		newbnk("stats",stats_data)
		
		local w,h=bnksize("stats")
		if h==1 then
			wlog("upgrade stats")
			newbnk("new_stats",400,2,4)
			bank("new_stats")
			for x=0,399 do for y=0,1 do bset(x,y,0) end end
			
			for y=0,1 do
				for x=0,119 do
					bset("new_stats",x,y,bget("stats",x+y*60,0))
				end
			end
			delbnk("stats")
			stats_data=expbnk("new_stats")			
			newbnk("stats",stats_data)
			delbnk("new_stats")
		end
	else
		_log("No legacy stats could be found.")
		stats_res = nil
	end
	
	-- ACHIEVEMENTS
	if not LIVE and not PSN then
		local function valid(save)
			return save and sub(save,1,3)=="123" and sub(save,-3)=="456"
		end
		
		local new_achiev = encfile("save/achievements.enc")
		if not valid(new_achiev) then
			new_achiev = encfile("save/achievements.enc_bak")
		end
		
		if valid(new_achiev) then
			new_achiev = sub(new_achiev, 4, -4)
		else
			new_achiev = ""
			-- loading legacy save
			local achiev_data=check_corrupt(file(ACH_FILE))
			
			if not achiev_data then
				achiev_data=check_corrupt(file(ACH_FILE.."_bak"))
			end
			
			if achiev_data then
				local order = {"FULL_SET","WIZARD","COMPLETE","AVENGED","EXORCISED","SWARM","LEGION","SNIPER","ASSASSIN","STEROID","TRIGGER_HAPPY","SCAVENGER","HAREM","SOCIAL_DISTANCING","RELIGION","SECRET","SECURITY_SERVICE","INQUISITION","MOBILITY","BOUNDARIES","MACHINE_GUN","SURVIVOR","DEMOLITION","HORSEMEN_OF_THE_APOCALYPSE","ROYAL_RETAINER","THE_FLOOR_IS_LAVA","EMPEROR","LATE_TO_THE_PARTY","UNEXPECTED_ENTRANCE","SWORDMAN","CLIFFHANGER","NINJA","SLAUGHTER","BENEVOLENCE","BUILDER","SOLOMON","VICTORIA","RAMESSES_II","RICHARD_III","MAKEDA","MERCIFUL_RULER","A_VELVET_GLOVE","DELETED","SQUARE_ALLEGIANCE","INCARNATION","LIKE_FATHER_LIKE_SON","HUMILIATION","HASTA_LA_VISTA_BABY","HOW_IT_SHOULD_BE","SHE_IS_EVERYWHERE","MORTAL_PERIL","PROJECTILE_DYSFUNCTION","HOPE_THIS_HITS","NINE_LIVES","YOUR_WIFE_MY_WIFE","A_MIGHTY_FORTRESS","UNDERPRESSURE_AMMO","GLUTTONY","IRON_KING","WIDOW","YOU_SHALL_NOT_PASS","BLITZ","BULLET","SUICIDE_PACT","OH_NO","MR_PRESIDENT","LIFEGUARD","MMMMH_DELICIEUX","RANK_1","RANK_2","RANK_3","RANK_4","RANK_5","RANK_6","RANK_7","RANK_8","RANK_9","RANK_10","RANK_11","RANK_12","RANK_13","RANK_14","RANK_15"}
				
				newbnk("old_achiev", achiev_data)
				bank("old_achiev")
				for i,id in ipairs(order) do
					if bget(i-1,0)>0 then
						new_achiev = new_achiev..id.."\t"
					end
				end
				new_achiev = sub(new_achiev,1,-2)
				delbnk("old_achiev")

				local str = "123"..new_achiev.."456"
				encfile("save/achievements.enc", str)
			end
		end
		
		--newbnk("achievements",#ACHIEVEMENTS,1)
		--bank("achievements")
		--
		--local lst=split(new_achiev,"\t")
		--local tbl={}
		--for _,k in pairs(lst) do
		--	tbl[k] = true
		--end
		--
		--for i,ach in ipairs(ACHIEVEMENTS) do
		--	if tbl[ach.id] then
		--		bset(i-1,0,1)
		--	else
		--		bset(i-1,0,0)
		--	end
		--end
		
	--[[ legacy, in effect this is all done in check_save() now	
	elseif PSN then
		newbnk("achievements",#ACHIEVEMENTS,1)
		bank("achievements")
		for i=1,#ACHIEVEMENTS do
			local v=0
			if psn("get_trophy", i) then v=1 end
			bset(i-1,0,v)
		end
		
	else -- LIVE
		newbnk("achievements",#ACHIEVEMENTS,1)

		_log("Waiting for achievement fetch to end...")
		while not live("fetch_achievements_result_ready") do
			freeze(0.016)
		end
		_log("Done")

		bank("achievements")
		for i=1,#ACHIEVEMENTS do
			local v=0
			if live("get_achievement", i) then v=1 end
			bset(i-1,0,v)
		end
		
		local order = {"FULL_SET","WIZARD","COMPLETE","AVENGED","EXORCISED","SWARM","LEGION","SNIPER","ASSASSIN","STEROID","TRIGGER_HAPPY","SCAVENGER","HAREM","SOCIAL_DISTANCING","RELIGION","SECRET","SECURITY_SERVICE","INQUISITION","MOBILITY","BOUNDARIES","MACHINE_GUN","SURVIVOR","DEMOLITION","HORSEMEN_OF_THE_APOCALYPSE","ROYAL_RETAINER","THE_FLOOR_IS_LAVA","EMPEROR","LATE_TO_THE_PARTY","UNEXPECTED_ENTRANCE","SWORDMAN","CLIFFHANGER","NINJA","SLAUGHTER","BENEVOLENCE","BUILDER","SOLOMON","VICTORIA","RAMESSES_II","RICHARD_III","MAKEDA","MERCIFUL_RULER","A_VELVET_GLOVE","DELETED","SQUARE_ALLEGIANCE","INCARNATION","LIKE_FATHER_LIKE_SON","HUMILIATION","HASTA_LA_VISTA_BABY","HOW_IT_SHOULD_BE","SHE_IS_EVERYWHERE","MORTAL_PERIL","PROJECTILE_DYSFUNCTION","HOPE_THIS_HITS","NINE_LIVES","YOUR_WIFE_MY_WIFE","A_MIGHTY_FORTRESS","UNDERPRESSURE_AMMO","GLUTTONY","IRON_KING","WIDOW","YOU_SHALL_NOT_PASS","BLITZ","BULLET","SUICIDE_PACT","OH_NO","MR_PRESIDENT","LIFEGUARD","MMMMH_DELICIEUX","RANK_1","RANK_2","RANK_3","RANK_4","RANK_5","RANK_6","RANK_7","RANK_8","RANK_9","RANK_10","RANK_11","RANK_12","RANK_13","RANK_14","RANK_15"}
	
		for i,id in ipairs(order) do
			if bget(i-1,0)>0 then
				new_achiev = new_achiev..id.."\t"
			end
		end
		new_achiev = sub(new_achiev,1,-2)
		delbnk("old_achiev")
	--]]
	end
	


	--bset(8, 0, 0) -- force lang
	--cheat_unlock_all()
	
	return save_res,stats_res
end

function reset_settings()
	wlog("reset settings")
	
	for i,d in ipairs(OPTIONS) do
		SET[d.nid] = d.def
	end
	
	set_default_lang()
	SET.vernum = get_version_num(VERSION)
	SET.save()
end

function reset_save()
	wlog("reset save")
	
	DEN.prog={}
	DEN.version=VERSION
	DEN.vernum=get_version_num(VERSION)
	
	
	--newbnk("save",30,7,4)
	--bank("save")
	--for i=1,#OPTIONS do	bset(i-1,0,OPTIONS[i].def) end
	--for y=1,6 do for x=0,29 do
	--	bset(x,y,0)
	--end end
	--bset(25,0,SAVE_VERSION)
	--
	--local v=get_version_num(VERSION)
	--bset(26,0,v)
	--load_ver=v
	--
	--set_default_lang()
	
	
	-- Y0 options
		-- 25 -> save version
	
	-- Y1 throne unlock 
		-- 0->rank max completed	
		-- 1-X-> Floor max for rank X
		
	-- Y2 record 
		-- 0->Best endless floor
		-- 1-X -> best time for rank X
	-- Y3 Chase
		-- 0-> Best score for chase
		-- 1-> Best turn for chase
	-- Y4 CUSTOM ZONE
		-- 1-3 throne weapons unlock
	-- Y5 CODEX PREF
		-- 0-> Fire on / Off
	
	
	save()
end
function reset_stats()
--	delbnk("stats")
--	newbnk("stats",400,2,4)
--	bank("stats")
--	for x=0,399 do for y=0,1 do bset(x,y,0) end end
--	file(STAT_FILE,expbnk("stats"))
--	bank("save")
	DEN.stats = {}
end

function cheat_unlock_all()
--	print("cheat")
--	bset("save",0,1,15)
--	bset("save",0,2,15)
--	for i=1,15 do
--		bset("save",i,1,11)
--	end
--	for i=2,8 do
--		bset(i,4,1)
--	end
--	for i=0,399 do
--		bset("stats",i,0,1)
--	end
--	for i=1,#ACHIEVEMENTS do
--		bset("achievements",i-1,0,1)
--	end
--	file(SAVE_FILE,expbnk("save"))
--	file(STAT_FILE,expbnk("stats"))
--	file(ACH_FILE,expbnk("achievements"))
	
	-- throne
	DEN.prog.throne = {
		rank=20,
		weapon_unl={}
	}
	for i=1,16 do
		DEN.prog.throne.weapon_unl[i]=true
	end
	
	-- endless
	DEN.prog.endless = 15
	
	-- charnier
	DEN.prog.charnier = {
		best_rank=25,
		cinders = 8,
		burdens = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22},
		augments = {},
	}
	--for i=0,22 do add(DEN.prog.charnier.burdens, i)	end
	for i=0,11 do add(DEN.prog.charnier.augments, i)	end
	
	
	-- cards
	for ca in all(CARDS) do
		DEN.stats[ca.id] = { played=1 }
	end
	
	
	-- achievements
	for ach in all(ACHIEVEMENTS) do
		DEN.achievements[ach.id] = true
	end
	
	DEN.prog.save()
	DEN.stats.save()
	DEN.achievements.save()
end

function save()
	DEN.prog.save()
end
function save_stats()
	DEN.stats.save()
end
function save_achievements()
	DEN.achievements.save()
end

-- added for use on mobile
function save_run()
	if not SAVE_RUNS or mode.lvl<=0 then return end
	
	local save={
		lvl=mode.lvl,
		chrono=chrono_time,
		cards={},
		upgrades=clone(upgrades,true),
		data={},
	}
	
	for sl in all(card_slots) do
		if sl.ca then add(save.cards, sl.ca.id) end
	end
	
	local keys={"fool","pawn_promoted","frags"}
	for k in all(keys) do
		if type(mode[k])=="table" then
			save.data[k]=clone(mode[k])
		else
			save.data[k]=mode[k]
		end
	end
	
	DEN.runs[game_mode]=save
	wait(60,bind(msg,"progression saved",90))
end

function restore_run()
	local save=DEN.runs[game_mode]
	if not SAVE_RUNS or not save then return end
	
	mode.lvl=save.lvl or 0
	chrono_time=save.chrono or 0
	
	if save.upgrades then
		upgrades=clone(save.upgrades)
	end
	
	if save.cards then
		for id in all(save.cards) do
			for i,ca in ipairs(cards.pool) do
				if ca.id==id then
					ca.n=ca.n-1
					if ca.n<=0 then deli(cards.pool, i) end
					add_card(ca.id)
				end
			end
		end
	end
	
	if save.data then
		for k,v in pairs(save.data) do
			if type(v)=="table" then
				mode[k]=clone(v)
			else
				mode[k]=v
			end
		end
	end
end

function forget_run()
	DEN.runs[game_mode]=nil
end


function map(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end


VOL_MAX=1.0
if BUILD_TYPE=="PS" then
	VOL_MAX=0.92
end

function apply_option(id)
	if id == "music" then
		musvol(MUTE or map(SET.music, 0, 11, 0, VOL_MAX)^2)
	elseif id == "sfx" then
		sfxvol(MUTE or map(SET.sfx, 0, 10, 0, VOL_MAX)^2)
	elseif id == "fullscren" then
		winspec("wmode", SET.fullscreen==0 and "resize" or "fullscreen")
	elseif id == "crt" and not (PC and SHADERLESS) then
		shader(SET.crt>0 and "assets/crt_calmos.shader" or "assets/stretch.shader")
		shdrf("curve", SET.crt>0 and (0.005+(SET.crt-1)*.01) or 0)
	elseif id == "rumble" then
		RUMBLE=SET.rumble==1
		rumble(0, 0.75, 0.75, 0.16)
	elseif id == "lang" then
		if not SET.lang then
			v=set_default_lang()
		end
		load_lang(SET.lang)
	elseif id == "HD text" then
		force_HD=SET.hdtext==1
		load_lang(SET.lang)
	end
end
function apply_options(not_lang)
	musvol(MUTE or map(SET.music, 0, 11, 0, VOL_MAX)^2)
	sfxvol(MUTE or map(SET.sfx, 0, 10, 0, VOL_MAX)^2)
	winspec("wmode", SET.fullscreen==0 and "resize" or "fullscreen")
	
	if not (PC and SHADERLESS) then
		shader(SET.crt>0 and "assets/crt_calmos.shader" or "assets/stretch.shader")
		shdrf("curve",0.005+(SET.crt-1)*.01)
	end

	force_HD=SET.hdtext==1
	RUMBLE=SET.rumble==1
	
	-- can't load fonts on the first apply_options, data gets overwritten with punkcake intro
	if not not_lang then
		if not SET.lang then
			set_default_lang()
		end
		load_lang(SET.lang)
	end
end

-- LANG
function set_default_lang()
	local lang,country = syslang()
	local setl
	if lang then
		if country then
			setl = SUPPORTED_LANG[lang.."_"..country] or SUPPORTED_LANG[lang]
		else
			setl = SUPPORTED_LANG[lang]
		end
	end
	
	SET.lang = setl or "english"
	return SET.lang
end


-- MODE LOCK
function is_locked(id)
	if id=="endless" then
		return not DEN.prog.throne or (DEN.prog.throne.rank or 0)==0
	end
	if id=="chase" then
		return (DEN.prog.endless or 0)<15 
	end
	if id=="charnier" then		
		return not DEN.prog.throne or (DEN.prog.throne.rank or 0)<5
	end
	
	return false
end


-- TOOLS
function progress(x,y,n,best) -- ?? I don't think this is used anywhere?
	local best=best or max
	bset(x,y,best(bget(x,y),n))
end
function inc_stats(id,played)
	local type=played and "played" or "ignored"
	local stat=DEN.stats[id]
	if stat then
		stat[type]=(stat[type] or 0)+1
	else
		DEN.stats[id]={[type]=1}
	end
end
function get_stats(id,played)
	local type=played and "played" or "ignored"
	local stat=DEN.stats[id]
	return stat and stat[type] or 0
end




