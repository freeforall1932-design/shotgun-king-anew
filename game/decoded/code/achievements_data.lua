if BUILD_TYPE=="PS" then
    ACHIEVEMENTS={
        --{ id="PLATINIUM",	                                    type="P"},

        { id="FULL_SET",	            chk="on_card",  spr=1,  type="B"},
        { id="COMPLETE",                                spr=4,  type="B"},
        { id="EXORCISED",                               spr=6,  type="G"},
        { id="BLITZ",                   chk="win", 	    spr=8,  type="S" },
        { id="BULLET",                  chk="win",      spr=9,  type="G"},

        -- GUNS
        { id="SOLOMON",	                gun=0,                  type="B" },
        { id="VICTORIA",                gun=1,                  type="B" },
        { id="RAMESSES_II",             gun=2,                  type="B" },
        { id="RICHARD_III",             gun=3,                  type="B" },
        { id="MAKEDA",	                gun=4,                  type="B" },


        { id="A_VELVET_GLOVE",	        chk="end_floor",sm=1,   type="B" },
        { id="DELETED",			        chk="end_floor",sm=2,   type="B" },
        { id="INCARNATION",		        chk="end_floor",sm=4,   type="B" },
        { id="PROJECTILE_DYSFUNCTION",  chk="play",     sm=11,  type="B" },
        { id="HOPE_THIS_HITS",		    chk="play",     sm=12,  type="B" },
        { id="UNDERPRESSURE_AMMO",	    chk="play",     sm=16,  type="B" },
        { id="YOU_SHALL_NOT_PASS",	    chk="win",      sm=20,  type="B" },
        { id="LIFEGUARD",                               sm=25,  type="B" },
        { id="WIZARD",		            chk="on_card",  spr=2,  type="S"},
        { id="HUMILIATION",	            chk="frag",     sm=6,   type="S" },
        { id="HOW_IT_SHOULD_BE",        chk="play",     sm=8,   type="S" },
        { id="SHE_IS_EVERYWHERE",       chk="play",     sm=9,   type="S" },
        { id="YOUR_WIFE_MY_WIFE",       chk="play",     sm=14,  type="S" },
        { id="GLUTTONY",                chk="play",	    sm=17,  type="S"},
        { id="MR_PRESIDENT",                            sm=23,  type="S"},
        { id="IRON_KING",               chk="win",      sm=18,  type="G" },
        { id="WIDOW",                   chk="win",      sm=19,  type="G"},

        -- RANKS
        { id="RANK_5" ,                 rank=5,                 type="S" },
        { id="RANK_10",                 rank=10,                type="S" },
        { id="RANK_15",	                rank=15,                type="G" },
				
				-- v1.5 new achievements
				{ id="ALEXANDER",						desc="Beat throne mode with this shotgun"	, gun=5 },
				{ id="YVAN_IV",							desc="Beat throne mode with this shotgun"	, gun=6 },
    }
else
    ACHIEVEMENTS={
        { id="FULL_SET",	chk="on_card", desc="Have 10 black cards", spr=1},
        { id="WIZARD",		chk="on_card", desc="Have 4 Magic Wands" , spr=2},

        { id="COMPLETE",	desc="Kill The White King"	, spr=4},
        { id="AVENGED",		desc="Kill The Black Bishop", spr=5},
        { id="EXORCISED",	desc="Kill The Red Book"		, spr=6},

        { id="SWARM", 							cards={	"Pillage", "Revolution", "Conscription" } },
        { id="LEGION",							cards={	"Militia", "Assault", "Pikemen", } },
        { id="SNIPER",							cards={	"High Focus", "Crow's Blessing", "Engraved Scope" } },
        { id="ASSASSIN",						cards={	"Ritual Dagger", "Taunting Hop", "Subtle Poison"} },
        { id="STEROID",							cards={	"Sacred Crown", "Majestic Censer", "Courteous Jousting"} },
        { id="TRIGGER_HAPPY",				cards={	"Ermine Belt", "Kingdom Wealth", "Unjust Decree"} },
        { id="SCAVENGER",						cards={	"Ammunition Depot", "Elite Gem", "Small Fry Harvest"} },
        { id="HAREM",								cards={	"Iron Maiden", "Genderqueer", "King's Mistress"} },
        { id="SOCIAL_DISTANCING",		cards={	"The Moat", "Wand of Gust", "August Presence"} },
        { id="RELIGION",						cards={	"Conclave", "Cardinal", "Sanctity"} },
        { id="SECRET",							cards={	"Genderqueer", "Saboteur", "The Secret Heir"} },
        { id="SECURITY_SERVICE",		cards={	"Castle", "Kite Shield", "Bodyguard"} },
        { id="INQUISITION",					cards={	"Zealots", "Ascension", "The Red Book"} },
        { id="MOBILITY",						cards={	"Royal Loafers", "Wand of Wings", "Faithful Steed"} },
        { id="BOUNDARIES",					cards={	"Rightful Curtsy", "Rightful Curtsy", "The Moat" } },
        { id="MACHINE_GUN",					cards={	"Extra Barrel", "Extra Barrel", "Extra Barrel"} },
        { id="SURVIVOR",						cards={	"Majestic Censer", "Black Mist", "Cornered Despot"} },
        { id="DEMOLITION",					cards={	"Ruins", "Pillage", "Kingly Alms"} },
        { id="HORSEMEN_OF_THE_APOCALYPSE",		cards={	"Cavalry", "Kite Shield", "Courteous Jousting"} },
        { id="ROYAL_RETAINER",			cards={	"Court of the King", "Court of the King", "Full Plate Armor"} },
        { id="THE_FLOOR_IS_LAVA",		cards={	"Royal Loafers", "Cornered Despot", "Unholy Call"} },
        { id="EMPEROR",							cards={	"Throne Room", "Kingdom Wealth", "Castle" } },
        { id="LATE_TO_THE_PARTY",		cards={	"Cavalry", "Lookout Tower", "Conclave" } },
        { id="UNEXPECTED_ENTRANCE",	cards={	"A Piercing Truth", "Blunderbuss", "Welcome Gift"} },
        { id="SWORDMAN",						cards={	"Nightbane", "Bushido", "Ritual Dagger" } },
        { id="CLIFFHANGER",					cards={	"Analysis Paralysis", "Sacred Crown", "Black Mist" } },
        { id="NINJA",								cards={	"Bushido", "Caltrops", "Taunting Hop" } },
        { id="SLAUGHTER",						cards={	"Guillotine", "Cannon Fodder", "Small Fry Harvest" } },
        { id="BENEVOLENCE",					cards={	"Bloodless Coups", "Peace", "Philanthropy" } },
        { id="BUILDER",							cards={	"Highest Dungeon", "Cathedral", "Trowel" } },


				-- NEW COLLECTION ACHIEVEMENTS
				{ id="DANGEROUS_LIFE",			cards={	"Unicorn", "Sokoban", "Cornered Despot" } },
        { id="NIGHTMARE_ERA",				cards={	"Human Shield", "Fearsome", "Reign of Terror" } },
        { id="DRAUGHTS",						cards={	"Elusive", "Taunting Hop", "Secret Move" } },
        { id="PUPPET_MASTER",				cards={	"Seer's Orb", "Wand of Hypnosis", "Bold Plan"  } },
        { id="HIDDEN_CONSPIRATOR",	cards={	"The Mole", "Low-Cost Disguise", "King's Look-alike" } },
        { id="DECEIVER",						cards={	"Black Mist", "Elusive", "Holoking" } },				
        { id="STARBURST",						cards={	"Sacred Light", "Presbyopia","Sanctity" } },
        { id="DETENTION",						cards={	"Mystic Shackles", "Imperial Shot Put", "Prison" } },
        { id="OUT_OF_TIME",					cards={	"Zealots", "Analysis Paralysis", "Final Countdown" } },
        { id="JEALOUSY",						cards={	"Succubus", "King's Mistress", "Tragic Homecoming" } },
        { id="DISCREET_HOST",				cards={	"Cloaking Device", "Ambush", "Silencer" } },
        { id="FIRST_AID",						cards={	"Indelible Memories", "Divine Healing", "Emergency Call"} },


        { id="SOLOMON",				desc="Beat throne mode with this shotgun"	, gun=0 },
        { id="VICTORIA",			desc="Beat throne mode with this shotgun"	, gun=1 },
        { id="RAMESSES_II",		desc="Beat throne mode with this shotgun"	, gun=2 },
        { id="RICHARD_III",		desc="Beat throne mode with this shotgun"	, gun=3 },
        { id="MAKEDA",				desc="Beat throne mode with this shotgun"	, gun=4 },
				{ id="ALEXANDER",			desc="Beat throne mode with this shotgun"	, gun=5 },
				{ id="YVAN_IV",				desc="Beat throne mode with this shotgun"	, gun=6 },
				{ id="ATTILA",				desc="Beat throne mode with this shotgun"	, gun=7 },
				{ id="MONTEZUMA",			desc="Beat throne mode with this shotgun"	, gun=8 },
				

        { id="MERCIFUL_RULER",				chk="end_floor", 	sm=0,	desc="Finish a floor without killing any pawn" },
        { id="A_VELVET_GLOVE",				chk="end_floor", 	sm=1,	desc="Finish a floor without killing any non-leader piece" },
        { id="DELETED",								chk="end_floor", 	sm=2,	desc="Finish a floor by turn 6" },
        { id="SQUARE_ALLEGIANCE",			chk="end_floor",	sm=3,	desc="Finish a floor without moving to a white tile" },
        { id="INCARNATION",						chk="end_floor",	sm=4,	desc="Finish a floor moving only with souls" },


        { id="LIKE_FATHER_LIKE_SON",	chk="frag", sm=5,	desc="Kill the white king by throwing his heir at him" },
        { id="HUMILIATION",						chk="frag", sm=6,	desc="Kill the white king by hopping on him" },
        { id="HASTA_LA_VISTA_BABY",		chk="frag", sm=7,	desc="Kill an Iron Queen" },

        { id="HOW_IT_SHOULD_BE",			chk="play", sm=8,	desc="Have 2 knights, 2 rooks, 2 bishops, 1 queen, 1 king, and 8 pawns on the enemy field" },
        { id="SHE_IS_EVERYWHERE",			chk="play", sm=9,	desc="Have 5+ queens on the board at one time" },
        { id="MORTAL_PERIL",					chk="play", sm=10,	desc="Be threatened by 4 pieces at once" },
        { id="PROJECTILE_DYSFUNCTION",chk="play", sm=11,	desc="Have more ammo in your clip than in your max reserves" },
        { id="HOPE_THIS_HITS",				chk="play", sm=12,	desc="Have an arc of 120 or higher" },
        { id="NINE_LIVES",						chk="play",	sm=13,	desc="Activating black mist 9 times" },
        { id="YOUR_WIFE_MY_WIFE",			chk="play", sm=14,	desc="Grab the queen and carry her to the square you start the round on" },
        { id="A_MIGHTY_FORTRESS",			chk="play",	sm=15,	desc="Have 6+ rooks on the board at one time" },
        { id="UNDERPRESSURE_AMMO",		chk="play",	sm=16,	desc="Have a firepower equal to 1" },
        { id="GLUTTONY",							chk="play",	sm=17,	desc="Have 20+ ammo" },


        { id="IRON_KING",							chk="win", 	sm=18,	desc="Beat Throne mode without using a folly shield" },
        { id="WIDOW",									chk="win", 	sm=19,	desc="Beat Throne mode without killing a queen" },
        { id="YOU_SHALL_NOT_PASS",		chk="win", 	sm=20,	desc="Beat Throne mode without letting a pawn promote" },
        { id="BLITZ",									chk="win", 	spr=8,	desc="Beat Throne mode in less than 5 minutes" },
        { id="BULLET",								chk="win", 	spr=9,	desc="Beat Throne mode in less than 2 minutes" },

				-- EVENT
        { id="SUICIDE_PACT",					sm=21,		desc="Destroy the last leader and the black king with a grenade" },
        { id="OH_NO",									sm=22,		desc="Get killed by your own grenade" },
        { id="MR_PRESIDENT",					sm=23,		desc="Make a rook save the king from a flying piece" },
        { id="LIFEGUARD",							sm=25,		desc="Push a piece out of the moat" },
        { id="MMMMH_DELICIEUX",				sm=26,		desc="Get eaten by the white king" },
				
				
				-- NEW ACHIEVEMENTS
				{ id="MARITAL_PEACE",				sm=38, desc="Kill the Blight"},
				{ id="END_OF_THE_WORLD",		spr=10, desc="Kill The Four Horsemen of the Apocalypse"},
				{ id="NEW_JOB",							sm=37, desc="Steal A Horseman's job"},
				{ id="WORKPLACE_ACCIDENT",	chk="frag", sm=31,	desc="Make a non-pawn piece fall off the board" },
				{ id="BULLFIGHTING",				chk="frag", sm=32,	desc="Make a unicorn kill itself" },
				{ id="BURIED_ALIVE",				chk="frag", sm=35,	desc="Kill the king with only Mausoleum damage" },
				{ id="COLD_REGICIDE",				chk="frag", sm=36,	desc="Kill the king while in stealth mode" },
				{ id="FINAL_ESCAPE",				chk="end_floor", sm=30,	desc="Finish a floor without damaging any piece during the final countdown" },
				{ id="HIPPOCRACY",					chk="play", sm=33, desc="Let the knights rule the white army" },
				{ id="BLOODBATH",						chk="play",	sm=27,	desc="Have 12+ bleeding pieces on the board at one time" },				
				{ id="ANARCHY",							chk="play",	sm=28,	desc="Have 4+ Kings on the board at one time" },				
				{ id="WARDEN",							chk="play",	sm=34,	desc="Have 8+ pieces in jail" },
				{ id="MIDNIGHT_DANCE",			sm=29,	desc="get +4 firepower from a secret move" },
				
				-- NEW 1.6
				{ id="KING_WARBAND",				chk="play",	sm=39,	desc="Have a knight, a bishop and a rook as ally" },
				{ id="OVERPOPULATION",			chk="play",	sm=40,	desc="Generate more than 12 Knights on a single floor" },
				{ id="OBSCURANTISM",				chk="play",	sm=41,	desc="Have 6 black cards turned face down" },
				{ id="EXPULSION",						chk="play",	sm=42,	desc="Send back 4+ non-pawn pieces on a single floor" },
				{ id="UNITED_HANDS",				chk="play",	sm=43,	desc="Have 8 piece types at once on the board" },
				{ id="DEATH_SENTENCE",			sm=24,	desc="Kill 4+ pieces while reloading your shotgun" },
				{ id="KINDLED_ATROCITY",								sm=44,	desc="Burn 6 Villages in Charnier Mode" },
				{ id="ARCHITECT_OF_RUIN",								sm=45,	desc="Burn 10 Villages in Charnier Mode" },
				{ id="SOVEREIGN_OF_THE_MASS_GRAVE",			sm=46,	desc="Burn 15 Villages in Charnier Mode" },
				{ id="CINDERLORD",											sm=47,	desc="Hoard 5+ cinders in Charnier Mode" },
				
    }
    for i=1,20 do
        add(ACHIEVEMENTS,{ id="RANK_"..i,	desc="Finish throne at rank "..i	, rank=i })
    end
end

if PC then
	local special = {
		["MMMMH_DELICIEUX"] = "MMMMH DELICIEUX !",
		["MR_PRESIDENT"] = "MR PRESIDENT !",
		["OH_NO"] = "OH NO !",
	}

	local keep_underscores = {
		"TRIGGER_HAPPY", "SOCIAL_DISTANCING", "SECURITY_SERVICE", "MACHINE_GUN", "FULL_SET"
	}
	
	local keep_as_is = {}
	for _,k in pairs(keep_underscores) do
		keep_as_is[k] = true
	end

	for i,dat in ipairs(ACHIEVEMENTS) do
		local stm
		if special[dat.id] then
			stm = special[dat.id]
		elseif keep_as_is[dat.id] then
			stm = dat.id
		else
			stm = sbs(dat.id, '_', ' ')
		end
		dat.steam = stm
	end
end

for i,d in ipairs(ACHIEVEMENTS) do
	ACHIEVEMENTS[d.id]=i
end

