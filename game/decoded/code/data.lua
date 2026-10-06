BUILD_TYPE="PC" -- NX_EU, NX_H2, XBOX, PS, TRAILER
VERSION="1.623b"


BOOT="MENU"
if BUILD_TYPE=="PC" then
	PC = true
	GAMEPAD_LAYOUT="PC"

elseif BUILD_TYPE == "TRAILER" then
	GAMEPAD_LAYOUT="NONE"
	VERSION="1.0.0-TRAILER"
	IN_EXPORT=false
	DEV=true
	
	lvl=tonum(EXE_ARGS[2])
	if lvl then
		BOOT="GAME"
		game_mode="throne"
		START_LVL=mid(0,lvl,11)
	end
elseif BUILD_TYPE == "NX_EU" then
	GAMEPAD_LAYOUT="NX"
	VERSION="1.0.2.N"
elseif BUILD_TYPE == "NX_H2" then
	GAMEPAD_LAYOUT="NX"
	VERSION="1.0.0.H2"
elseif BUILD_TYPE == "XBOX" then
	GAMEPAD_LAYOUT="Xbox"
	VERSION="1.0.0.X"
else
	GAMEPAD_LAYOUT="PS"
	VERSION="1.0.0.P"
end

_log("Playing Shotgun King v"..VERSION..(PC and "" or "-console"))

MCW=320
MCH=180
MSC=4
CLM=6

SQ=16
DP_BG=			0
DP_BOARD=		1
DP_SHADES=	2
DP_PIECES=	3
DP_FX=			4
DP_INTER=		5
DP_TOP=			6

ADI={0,4,1,5,2,6,3,7}
DIRS={ 1,0, 0,1, -1,0, 0,-1, 1,1, -1,1, -1,-1, 1,-1 }
KNIGHT_MOVES={ 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
TEMPO=20
PDY=-2
HALF_POOL=100

FORCE_DARK=10
FORCE_MEDIUM=11
FORCE_BRIGHT=12

--IN_EXPORT=false
DEV=true
--NO_TUTORIAL=true
--NO_MUS=true
NO_INTRO=true
--FORCE_RANK=19
--SUPPER_IS_READY=true
--IGNORE_MODS=true --ROV_SHOW_MOVE_ZONES=1 --CONSOLE=true --KING_CIRCLE=true

-- CHEAT
--FORCE_RESET=true
BOOT="GAME" --game_mode="tutorial" 
--SEED=2
--BOOT="ACHIEVEMENTS"
--START_LVL=10
--TEST_SOULS={13,13,13}
--FRAGILE=1
--game_mode="tutorial"
--DUMMY=1
--SHOW_BUTS=true
--SHOW_DIST="doubt_dist"
--SHOW_DANGER=true
--SHOW_ACH=true
--DEBUG_GAMEPAD_MOUSE=true
--ROV_SHOW_ATK_ZONES=1
--FORCE_STEAMDECK=true
--SAVE_RUNS=true

-- 6 / 10 / 15


-- ne marche plus -> marcher versu ne piece condamnée

--[[ DEV BOARDS

	DEV_BOARD={ -- TEST ZONE
		1,0,0,0,0,0,0,0,
		1,9,9,9,9,9,0,0,
		9,9,9,9,9,9,9,9,
		9,9,9,9,9,9,9,9,
		9,9,9,9,8,9,9,9,
		9,9,9,9,9,9,9,9,
		9,9,9,9,9,9,9,9,
		9,9,9,9,9,9,9,9,
	}	
	
--]]


--[[ changelog 1.623b

	[BUGFIX] Fixed a bug in the codex where card panels would grow in size when leaving the screen.
	[BUGFIX] Fixed another codex bug where the card panel that slides out when selecting another card was showing the new card instead of the old one.
	[MODDING] Mods can now trigger the "vision" cheat feature.
	[ENGINE] Yet another engine update for added stability!

--]]

--[[ changelog 1.623

	[BUGFIX] White pieces will no longer prioritize killing your black pieces over killing you if they have that chance.
	[BUGFIX] Heirs no longer produce the "Spy executed!" message when killed by another piece.
	[BUGFIX] White pieces will now properly kill you instantly even if you are not a king.
	[BUGFIX] Player promotion now properly preserves jumps and other properties.
	[BUGFIX] Other black kings will no longer get killed instantly by white pieces who are not yet ready to move.
	[BUGFIX] Converting a pawn that is on the upmost row will now promote it instantly.
	[BUGFIX] Glueing the enemies' shoes now prevents them from moving immediately.
	[BUGFIX] Tentative fix for a bug where a stone could kill a black piece by breaking free of its metaphysical condition and hitting the victim through the 8th dimension, while not even being on the same square.
	[BUGFIX] Fixed an issue where a black piece could get killed and still be selectable, resulting in a crash if you did select it.
	[BUGFIX] Fixed a couple visual and text issues on the codex.
	[ENGINE] Fixed a bug with the lua interpreter, where the game would crash randomly on certain systems. (not 100% sure but may have been exclusively on computers with ARM processors)
	
--]]


--[[
	
	-- les cartes qui ajoutent des alliés ne les retirent pas quand elles sont retournées.
	-- marquer les roles detectés
	-- [NEW CARD] +25% dodge on pawns
	-- UNIFIER MENU ET BOUTON et utiliser confirm()
	-- UNIFIER LES FLICKERING ( une seule fonction )
	-- carte noire puissante derrière iron queen
	-- new card = king can't attack in diagonals
	-- new boss jester ? ( = jester heir )
--]]

-- sfx sur throw grenade

TEST_STACK={
	--search=2,
	--waypoint=2,
	--sheath=1,
	--hop=1,
	--search=9,
	--knockback=100,
	--extra_white_choice=1,
	--grenade_dmg=1,
	--gain={5,5,5},
	--sac={0,0,0,0,0,0},
	--gain={1,1,1,4},
	--soul_slot=2,
	--boss_hp=-200,
	--hole_start=64,
	--all_hp=-20,
	--shrapnel=8,
	--allies={1,2,3,4},
	--sheath=1,
	--firepower=-10,
	--heir=4,
	--hole_start=10,
}
TEST_CARDS={
	--"The Royal Hunt",
	--"Stoning",
	--"Unsettled Throne",
	--"Black Mist",
--"The Mole",
--"The Royal Hunt",
--"Stoning",
--"Emergency Call",
	--"Taunting Hop",
	--"Holoking",
	--"Sacred Light",
	--"Cloaking Device",
	--"August Presence",
	--"Low-Cost Disguise",
	--"Courteous Jousting",
	--"Kingly Alms",
	--"Wand of Treachery",
	--"Wand of Wrath",
	--"Wand of Wings",
	--"Castle",
	--"Force-feeding",
	--"Elusive",
	--"Unicorn",
	--"Soul Projection",
	--"The Jester",
	--"Stoning",
	--"Shovel",
	--"Flesh Wall",
	--"Lightfoot",
	--"August Presence",
	--"Remparts",
	--"Bold Plan",
	--"Sprint",
	--"King's Shoulders",
	--"Theocracy",
	--"Right-hand",
	--"Imperial Shot Put",
	--"Bouncy Castle",
	--"Rapunzel",
	--"Force-feeding",
	--"Undercover Mission",
	--"Soul Projection",
	--"Final Countdown",
	--"Stoning",
	--"Bushido",
	--"Bastion",
}

OVERWEIGHT={
	--"Bodyguard",
	--"Guillotine",
	--"Throne Room",
}

NEW_CARDS={
	
	-- ANARCHY > pawn can promote to king
	-- IRON KING !! for 10+ first turns
}


if IN_EXPORT then
	BOOT="MENU"
	DEV,NO_MUS,IGNORE_MODS,MUTE,FORCE_RESET,DUMMY,FRAGILE=nil
	NO_TUTORIAL,NO_INTRO,KING_CIRCLE=nil
	SHOW_ACH,SHOW_DANGER,SHOT_BUTS,SHOW_DIST,DEV_BOARD=nil
	FORCE_STEAMDECK=nil
	SUPPER_IS_READY=nil
	TEST_STACK={}
	TEST_CARDS={}
	TEST_SOULS={}
	OVERWEIGHT={}
	NEW_CARDS={}
	START_LVL=nil
	SAVE_RUNS=not PC
end

--lprint(str, x, y, c, [align], [outline_color])
--pprint(str, x, y, w, c, [align], [char_limit])

-- LANGUAGES
-- NOTE: I did not add the new languages to the console language sets. Please do that yourselves. -Remy
local language_sets = {
	NX_EU = {
		set = {
			"english",
			"french",
			"spanish",
			"german",
			"polish",
			"ukrainian",
			"russian",
		},
		support = {
			en = "english",
			fr = "french",
			es = "spanish",
			de = "german",
			pl = "polish",
			uk = "ukrainian",
			ru = "russian"
		},
		order = {
			"english",
			"french",
			"spanish",
			"german",
			"polish",
			"ukrainian",
			"russian",
		}
	},
	
	NX_H2 = {
		set = {
			"english",
			"french",
			"german",
			"polish",
			"russian",
			"spanish",
			"ukrainian",

			"japanese",
			"korean",
			"traditional_chinese", -- /!\ H2 EXCLUSIVE /!\
			"simplified_chinese",
		},
		support = {
			en = "english",
			fr = "french",
			es = "spanish",
			ru = "russian",
			uk = "ukrainian",
			de = "german",
			pl = "polish",
			
			ja = "japanese",
			ko = "korean",
			zh_HK = "traditional_chinese", -- /!\ H2 EXCLUSIVE /!\
			zh_CN = "simplified_chinese",
		},
		order = {
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
	},
	
	PS = {
		set = {
			"english",
			"french",
			"german",
			"polish",
			"russian",
			"spanish",
			"ukrainian",

			"japanese",
			"korean",
			"traditional_chinese", -- /!\ H2 EXCLUSIVE /!\
			"simplified_chinese",
		},
		support = {
			en = "english",
			fr = "french",
			es = "spanish",
			ru = "russian",
			uk = "ukrainian",
			de = "german",
			pl = "polish",
			
			ja = "japanese",
			ko = "korean",
			zh_HK = "traditional_chinese", -- /!\ H2 EXCLUSIVE /!\
			zh_CN = "simplified_chinese",
		},
		order = {
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
	},
	
	XBOX = {
		set = {
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
		},
		support = {
			en = "english",
			fr = "french",
			es = "spanish",
			de = "german",
			pl = "polish",
			uk = "ukrainian",
			ru = "russian",
			
			ja = "japanese",
			ko = "korean",
			zh_CN = "simplified_chinese",
		},
		order = {
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
	},
	
	PC = {
		set = {
			"english",
			"french",
			"spanish",
			"latam",
			"portuguese",
			"german",
			"dutch",
			"italian",
			"romanian",
			"catalan",
			
			"polish",
			"ukrainian",
			"russian",

			"japanese",
			"korean",
			"simplified_chinese",
			"vietnamese",
		},
		support = {
			en = "english",
			fr = "french",
			es_ES = "spanish",
			es = "latam",
			pt = "portuguese",
			de = "german",
			nl = "dutch",
			it = "italian",
			ro = "romanian",
			ca = "catalan",
			gl = "galician",
			
			pl = "polish",
			uk = "ukrainian",
			ru = "russian",
			
			ja = "japanese",
			ko = "korean",
			zh = "simplified_chinese",
			vi = "vietnamese",
		},
		order = {
			"english",
			"french",
			"spanish",
			"latam",
			"portuguese",
			"catalan",
			"galician",
			"dutch",
			"german",
			"italian",
			"romanian",
			"polish",
			"ukrainian",
			"russian",
			"vietnamese",
			"simplified_chinese",
			"korean",
			"japanese",
		}
	}
}

if PC then -- PC version gets all lang files in lang folder
	if not IN_EXPORT then
		file("lang/safe_english.txt", file("lang/english.txt"))
	end
	
	if IN_EXPORT then -- Filling in lang folder in prefpath for Mac and Linux
		local set = language_sets.PC.set
		for s in all(set) do
			if not isfile("lang/"..s..".txt") then
				file("lang/"..s..".txt")
			end
		end
	end
	
	
	local set = language_sets.PC.set
	local langs = ls("lang", true)
	local tmap = {}
	
	del(langs, ".")
	del(langs, "..")
	
	for l in all(set) do
		if isfile("lang/"..l..".txt") then
			log("found "..l)
			tmap[l]=true
		else
			log("couldn't find "..l)
			del(set,l)
		end
	end
	
	for l in all(langs) do
		local l=sub(l,1,-5)
		if not tmap[l] and isfile("lang/"..l..".txt") then
			add(set,l)
		end
	end
	
	--local set = {}
	--local langs = ls("lang", true)
	--if not IN_EXPORT then del(langs, "safe_english.txt") end
	--for s in all(langs) do add(set,sub(s,1,-5))	end
	--language_sets.PC.set = set
end

local buildset = language_sets[BUILD_TYPE]
LANGUAGES = buildset.set
SUPPORTED_LANG = buildset.support
ORDER = buildset.order


do -- reordering the languages
	local trues = {}
	for k,v in pairs(LANGUAGES) do
		trues[v] = true
	end
	
	for i,v in pairs(ORDER) do
		if trues[v] then
			del(LANGUAGES, v)
		else
			deli(ORDER, i)
		end
	end
	
	for i,v in ipairs(LANGUAGES) do
		add(ORDER, v)
	end
	
	for i,v in ipairs(ORDER) do
		ORDER[v]=i
	end
	
	LANGUAGES = ORDER
end
ORDER=nil

-- OPTIONS
OPTIONS={
	{ id="music", 		nid="music", 			opt=11, 		def=10 },
	{ id="sfx", 			nid="sfx", 				opt=11,			def=10 },
	{ id="fullscren", nid="fullscreen", opt=2,			def=1},
	{ id="crt", 			nid="crt", 				opt=11,			def=1},	
	{ id="speedrun",	nid="speedrun",		opt=2,			def=0},	
	{ id="shields", 	nid="shields", 		opt=4,			def=2},
	{ id="scr.shake",	nid="scrshake",		opt=2,			def=1},
	{ id="scr.flash",	nid="scrflash",		opt=2,			def=1},
	{ id="lang",			nid="lang",				opt=#LANGUAGES,	def=99, labels=LANGUAGES},
	{ id="HD text",		nid="hdtext",			opt=2,			def=0},
	{ id="rumble",		nid="rumble",			opt=2,			def=1},

}
ITEMS={
	{ 	-- HEARTH A
		"Subtle Poison",
		"Ravenous Rats",
		"Welcome Gift",
		"Mystic Shackles",
		"Vendetta",
	},
	{ 	-- HEARTH B
		"Kingdom Wealth",
		"Sacred Crown",
		"Trowel",
		"Final Countdown",
		"Small Key",
	},
	{ 	-- HEARTH C
		"Elite Gem",
		"Kingly Alms",
		"Fool Companion",
		"The Royal Hunt",
		"Onboarding Party",
	},
	{ 	-- LARGE WALL
		"Small Fry Harvest",
		"Crusades",
		"Unjust Decree",
		"Ritual Dagger",
		"Inquisition",
		"Shovel",
	},	
	{		-- FURNITURE
		"Throne Room",
		"Prison",
	},
}
ROLES={
	{ id="heir" },
	{ id="spy" },
}

--
BACKERS="Alexis, Alukard, Amanda Thouvenin, Amethyst Pixie, Anatolijs Ropotovs, Anthony Colello, Austin Merrick, Benjamin Finkel, Berkfrei, Bertin William, Bigaston, Blas, Bret M Carlson, Calvin Spealman, Capsized Moose, Cheap Plastic Imitation Of A Game Dev, Christopher, Christopher Shuler, Ciaran Walsh, Connor Sheridan, Craig Cashman, David Cole, David Mekersa, Deepnight, Eiyeron, Elias Alonso, Emmet, Greg Winter, Hans Sjunnesson, Hauke Petersen, Iconoclaste, James Jensen, Jason Matson, Javier Del Nogal, Jay, Jearl, Jeremy Schryer, John Blue, John Faulkenbury, Jon_Jon13, Kat Salandar, Kristoffer Jetmundsen, Kristoffer Strom, Marty Kovach, Max Wolf, Mike Pudy, Mikolaj Gacon, Minimg, Montreuillois, Mossmouth, Nickadial, Note, Oshiwa, Paul Mccann, Paul Nguyen, Pierre-Antoine Cheron, Piper Vow, Raphael Gaschignard, Raxius, Retromation, Rob Dubbin, Rogue Justice, Rotatetranslate, Ryan, Ryan Malm, Sam Loeschen, Samuel Martin, Sebastian Stautz, Simon Sevcech, Simon Weiler, Stevie Hryciw, Takeru Grima, Totalblazing, Wegpast, Will Blanton, Zack Vanderpool, Zakuratech, Zep"
TRANSLATORS = "Benjamin + Remy (French), Pentadrangle (Spanish), Song of Mystery (Chinese), Otiel + Trek (Korean), Drugon (Russian), NamorSom (Ukrainian), "

-- TOOLS
function get_card(id)
	for ca in all(CARDS) do 
		if ca.id==id then return ca end
	end
end
function add_indexes(a)
	for i=1,#a do a[i].index=i-1 end
end
function id_tbl(tbl)
	local gid=0
	for o in all(tbl) do
		if o.id then tbl[o.id]=o end
		o.gid=gid
		gid=gid+1
	end
end
id_tbl(ROLES)



-- FORMAT
function get_time_string(n)
	local s=""
	local sec=flr(n/60)
	local min=flr(sec/60)
	local ct=flr((n%60)*10/6)	
	return min_digits(min%99,2).."'"..min_digits(sec%60,2).."'"..min_digits(ct,2)
end

--[[ changelog 1.622b

	[ERGO] Added a message that says "hold ALT to force aiming" at the bottom of the screen when hovering over other actions besides moving.
	[BUGFIX] A black pawn promoting into a king no long crashes the game.
	[BUGFIX] You can no longer inspect other gamemodes after selecting a gamemode.
	[BUGFIX] Meeting with a spy no longer consumes its spy status, so that it can now still promote into a black piece afterwards.
	
	-- not included in public changelog:
	[SECRET] If you have converted an heir, you get reincarnated into that heir on death if it's still alive, taking its moveset.

--]]
--[[ changelog 1.622

	[ERGO] You can now see your Charnier progress from the game mode menu.
	[BUGFIX] Fixed a softlock when an arrow kills a holoking during the Horsemen fight.
	[BUGFIX] Fixed a softlock when two arrows would kill the king on the same turn during the Horsemen fight.
	[BUGFIX] Improved the accuracy of folly shields for projectiles.
	[BUGFIX] Hovering a card during the flip animation on the level-up screen will no longer describe the card as exhausted.
	[BUGFIX] Using the "busy" cheatcode in Charnier now properly acts like giving up on that raid.
	[STEAMDECK] Can now switch directly from mouse-aiming to wand selection with LB.
	
--]]
--[[ changelog 1.621

	[FIX] Fixed a bug where if the pike-wielding apocalypse horseman killed a holoking, the game would go into an existential crisis.
	[FIX] Unicorns and Sokoban rooks can no longer kill you by pushing you off the board's edge if you have Elusive.
	[FIX] Throwing a Theocracized bishop at a rook while Castle is active will no longer confuse the game into crashing.
	[FIX] Using Force-feeding when missing a grenade with the Attila will now properly load an additional shell anyway.
	[FIX] Slayer's soul description no longer says you can create a slayer if you have Soul Projection. (you can't)
	[FIX] Bold Plan will no longer duplicate cards in the card pool.
	[FIX] Rumble is back for gamepads and SteamDeck!
	[MODDING] The reboot button works once again!
	[CHEAT] Added a secret button in-game to input cheatcodes on the SteamDeck

--]]
--[[ changelog 1.620

	[FIX] Fixed a crash when a black piece's placement threatened an Imperial Shot Put
	[FIX] Black Pieces can no longer attack Imperial Shot Puts.
	[FIX] Bushido no longer disables folly shields after its first use during a same turn.
	[FIX] Pawns can no longer use Lightfoot to get close to the king if you have August Presence.
	[FIX] Dead Flesh Wall pawns can now be pushed with knockback.
	[FIX] You can now use a grenade after reloading it by jumping over a piece with the Attila if you didn't have any grenade when the turn started.
	[FIX] In the Bold Plan menu, you can now choose cards that were recycled or unchosen during the previous card choice just past.
	[FIX] Switching from mouse controls to gamepad controls while on the disrupt menu will now resume the proper controls.
	[VISUAL] Stoning stones now have a small trail showing you their direction.
	[ERGO] You can now hold ALT to force aim over other interactions.
	[GAMEPAD] Switched to single card inspection because of a visibility issue with the Extra White Choice burden in Charnier. (this will also make our lives way easier for future updates, thanks for understanding)
	[STEAMDECK] Using RB to go to souls now works even while using the trackpads.
	[CHEAT] Cheatcode input is no longer timed.
	[CHEAT] Cheatcode vision now resets when you return to the main menu.
	[CHEAT] Added cheatcode "busy" to restart your run instantly.

--]]

--[[ BETA changelog 1.619

	[FIX] Black Mist is not activated anymore when the boss tries to eat a non-king black piece
	[FIX] Cards reversed by Disruption can now be turned face down
	[FIX] Disruption effect doesn't offer to reverse flipped cards anymore
	[FIX] Sabotage now works on Flesh Wall
	[FIX] Flesh Wall + fatal Death Mark won't stop the folly shield from working anymore
	[FIX] Rapunzel now spawns even if you throw towers on other pieces or over the board. It seems you can't escape her too.
	[FIX] Soul Projection can now be used even if movement with the soul is impossible
	[FIX] Pawns jumping with lightfoot won't reveal a disguised king anymore
	[FIX] Expulsion achievement doesn't count pawns anymore (in accordance with the description)
	[FIX] Force-Feeding now works with Attila
	[FIX] Fixed a crash when pieces are marked with no Death Mark card active.
	[FIX] Fixed the Tragic Homecoming flavor text.
	[FIX] Crash when double pressing the confirm button on a controller while on the "back" button in the pause menu.
	
--]]
--[[ BETA changelog 1.618c

	[STEAMDECK] Improved SteamDeck controls.
	[GAMEPAD] Clarified and improved black piece selection.
	[FIX] Holoking can no longer be controlled.
	[FIX] Can no longer stab bleeding pieces with 0 blade.
	[FIX] Thrown black pieces no longer acquire free-will if they survive.
	[MODDING] watch(ptrn,foo) now uses the mod's folder.
	[MODDING] sfx no longer get removed when rebooting the game from the mods menu.
	
--]]
--[[ BETA changelog 1.618b

	[FIX] Fixed a crash on entering Charnier mode with a save from a previous version.
	[FIX] Fixed a crash when leaving the codex while on the achievement tab.
	[FIX] Fixed broken panels in codex when using the non-HD font.
	
--]]
--[[ BETA changelog 1.618

	[BALANCE] unlocking titles in Charnier mode now let you start runs with more cinders (up to 3)
	[BALANCE] +1 augment available for ammo regen in Charnier mode
	[BALANCE] Gatehouse rooks now have an extra -1 speed (-2 speed total)		
	[FIX] Tunnels tag is back on Shovel (Catacomb is now unlockable)
	[FIX] Death Mark only applied to the rook if castle triggers
	[FIX] Saddle can't carry big pieces anymore
	[FIX] Anarchy can't change big pieces' type anymore
	[FIX] Grenades in hole near the black king won't trigger death animation
	[FIX] Pieces gfx now display correctly in endless mode
	[FIX] Title no longer shows up on gamemode menu after exiting tutorial.
	[VISUAL] Boss explosion now clears HD text
	[LANG] Fixed Unfaithful Steed not using the black_piece translation key.
	[LANG] Plural now applies for negative numbers under -1.
	[CHEAT] Added cheatcode VISION.
	
--]]
--[[ BETA changelog 1.617b

	[UI] Realigned Attila's ammo and grenade on weapon selection.
	[UI] Shotgun names can now take multiple lines in the weapon selection screen.
	[FIX] HD text works properly again.
	[FIX] Fixed softlock on re-entering gamemodes.
	[FIX] Fixed resource loading for mods.
	[FIX] Fixed slow reboot time for mods.
	
--]]
--[[ BETA changelog 1.617

	[ENGINE] Upgraded to SUGAR v0.0.8
	[ERGO] controller support for new features
	[FIXED] Small Key now disrupts white army after jail's unlock
	[CODEX] Rapunzel now has the "ally" tag
	[TEXT] Grammar corrections
	[TEXT] Language can now update from modified files, while still in game

--]]
--[[ BETA changelog 1.616b

	[FIXED] backup stacking
	[FIXED] achievement for montezuma
	[FIXED] various card's descriptions

--]]
--[[ BETA changelog 1.616

	[NEW] New Shotgun

	[REWORK] Anarchy effect become : Randomize spawning pattern. Promote two random pieces to any other type
	
	[BALANCE] Makeda now have butcher:"Blade is no longer restricted to one-shot kills"
	[BALANCE] Being in a hole now protect black pieces from any projectiles
	[BALANCE] Bleeding and Death Mark now transfer to any promoted piece
	[BALANCE] Richard II pierce is now 40% ( was 25% )
	[BALANCE] Wand of gust now delay pieces next move by two turns
	
	[FIXED] Folly shield now ignore please who gonna die from death mark if you reload
	[FIXED] blade now trigger taking account of bleed extra damage
	[FIXED] Buckler GFX is back on famine
	[FIXED] Bleeding and Death Mark now display at correct position on boss
	[FIXED] Grindstone no longer available in chase mode
	[FIXED] It's not longer possible to select a card while recycling it during level up in chase mode
	[FIXED] Charnier mode now unlock at throne rank 5
	[FIXED] black bishop can't be played anymore in the tutorial
	[FIXED] Charnier music don't play anymore when you go back to menu
	
	[GFX] Blade animation is now specific to the cards giving the blade stat
	
	[CODEX] Wand of Treachery now have "Ally" tag
	[CODEX] Vendetta : Added King's Mistress to card's need ( or )
	[CODEX] Knightmare : Added Fearsome to card's need ( or )
	
	[TEXT] various achievement text fixed
	[TEXT] Faithful Steed,Royal Loafers and Prison text fixed
	
	[MOD] damage is now an input for on_bad_hurt 

--]]
--[[ BETA changelog 1.615
	
	[NEW] +11 Achievements ( +5 from new ranks )
	
	[BALANCE] Royal Loafers : Removed cards needs, adjusted weight to 2 ( was 4 ). Now have a +15% spread malus when used.
	[BALANCE] Caltrops slow effect now stack if you have more than one caltrop card.
	[BALANCE] Bloodless Coups : Now have -15° Firearc
	[BALANCE] Knightmare : Knight become visible if they're threatening you
	[BALANCE] Mangonel : Shooting don't replace rook's move anymore. rook speed : -2 ( was -1 )
	[BALANCE] Engraved Scope : Replaced the +1 firepower with a +1 Firerange ( +2 total )
	[BALANCE] Fear don't apply anymore on pieces killed by non-king black pieces
	[BALANCE] Shovel gets +1 Blade
	
	[CODEX] Royal Loafers : Removed cards needs, adjusted weight to 2
	[CODEX] Highest Dungeon : Removed cards needs, adjusted weight to 2
	[CODEX] Flagstone : Removed cards needs, adjusted weight to 2
	[CODEX] Rapunzel : Added Highest Dungeon to cards need ( Highest Dungeon OR Lady in the Tower )
	
	[FIXED] Tutorial
	[FIXED] Brands icon in charnier mode
	[FIXED] Folly shield now trigger when you try to shoot a pawn for disguise while being targeted by a projectile
	[FIXED] August Presence FX
	[FIXED] Fear on Slayers won't crash the game anymore
	[FIXED] Attila discovery animation is fixed
	[FIXED] Banned from Chase mode : "Human Shield","Reign of Terror","Onboarding Party","Workshop","Mystic Shackles","Ambush","Cloaking Device"
	[FIXED] Folly shield will now let you grab ammo boxes in chase mode

--]]
--[[ BETA changelog 1.614

	[NEW] 6x new cards
	
	[CODEX] removed "Kingdom Wealth" from Onboarding Party needs
	[CODEX] removed "Ammunition Depot" from Small Key needs

	[BALANCE] Egotic Maelstrom is now 12 turns ( was 10 )
	[BALANCE] Slayer now activate their special move when black king is in check at the start of a turn ( instead of empty shotgun )
	[BALANCE] Warden -1hp and + armorgap of 2 ( can't take more damage than 2 in a single turn )
	[BALANCE] Grenades now fall in holes ( like moat ) and deal +2 damage on that square
	[BALANCE] The Mole loose +1 ammo. Spies now turn to black when promoting
	
	[ERGO] The danger visualization on middle-click has been removed
	[ERGO] You can now press "enter" to fire shotgun
	[ERGO] Slayers now have a special effect to show hen their special move is available
	[FIX] Anarchy fixed
	[FIX] Various cards descriptions
	
	[VISUAL] Grandpa's eyes are back

--]]
--[[ BETA changelog 1.613

	[NEW] Boss can now call for pawns if there's no pawn on board
	[NEW] Slayer's soul let you go anywhere ( even if your have ammo left in your gun )
	[NEW] Bodyguard's soul save you from death

	[VISUAL] August Presence and Selective Listening now show how they affect piece's moves
	
	[BALANCE] Throne rank 6 now add a special attack to boss instead of +10° spread 
	[BALANCE] Sokoban now stun pushed pieces
	[BALANCE] Karma now flip when a pawn promote
	[BALANCE] Knightmare don't add a knight anymore	
	[BALANCE] Chase Mode : +1 extra turn when you take a munition crate
	[BALANCE] Chase Mode : Deep Water removed from pool
	
	[FIX] Black pieces are not immune to grenades anymore after 1 grenade hit
	[FIX] Secret Gun reveal loop is fixed
	[FIX] Codex and Charnier mode now display correctly	
	
--]]
--[[ BETA changelog 1.612
	
	[NEW] New secret shotgun !
	[NEW] Charnier : Added extra cinders on some burdens
	[NEW] Charnier : +3 new brands

	[BALANCE] Gatehouse slowdown rooks and they generate knights only if there's 3 or less knight on board
	[BALANCE] Shovel now start with 2 holes
	[BALANCE] Holy Gunpowder now has -1 ammo max
	[BALANCE] High Focus firespread bonus is now -10° ( was -18° )
	[BALANCE] Ritual Dagger now give King -3 hp ( was -2 hp )	
	[BALANCE] Removed Extra Barrel firespread bonus ( was +7° )
	[BALANCE] Engraved Scope now also give +1 firepower if not in check
	[BALANCE] The piece killing the Holoking is stunned for 2 turns

	[FIX] Divine Healing can now save Flesh Wall pawns from death
	[FIX] Vampire now heal themselves instead of their victims
	[FIX] Pieces with dodge don't trigger folly shield vs blade attacks anymore.
	
	[FIX] Resigning in Charnier mode don't speed up menu animations anymore
	[FIX] Purchased brands can't be bought again
	[FIX] Cinders now vanish properly when you buy a new brand
	[FIX] Fixed some HD text in Charnier mode	
	[FIX] SFX for Disruption effect is back
	[FIX] White King Boss can't overlap pieces on startup anymore with anarchy 

	[CODEX] need Sprint or Caltrops or Patience to access Royal Loafers
	[CODEX] need Golden Aging or Highest Dungeon to access Ancient Flagstone
	
	[VISUAL] no more dead red pixels when shooting
	[VISUAL] no more red X on blight anim + horsemen of the apocalypse
	[VISUAL] Fixed some card's borders and artworks missing pixels
	[VISUAL] Badge icon for new ranks (15-20)
	[HAIRSTYLE] White king's cross fixed
	
	[TXT] Charnier : Augments renamed to "brands"
	[TXT] Charnier mode description format
	[TXT] Faithful Steed & Small Key descriptions	
	
 
--]]
--[[ BETA changelog 1.61
 
	
 [NEW] Charnier mode : use cinders to unlock permanent augments
 
 [FIX] Holoking Vanish FX now work with projectiles
 [FIX] Marks on card disappear sooner ( when level end )
 [FIX] Fixed black outline on hopped-on black pieces 
 [FIX] Gray dmg fx for capped damage is fixed
 [FIX] no more x red on Blight
 [FIX] Black pieces can't attack bosses anymore
 [FIX] Boss eating black pieces don't kill the black king anymore
 [FIX] Fixed Boss eat anim and shotgun recoil anim
 [FIX] Tooltip for grenade dmg fixed
 [FIX] Undead amries don't spawn anymore on last line	
 [FIX] Tragic Homecoming is back !
 [FIX] Dodge now work properly on slayer
 [FIX] Extra level for charnier are now fixed. 
 [FIX] Title now scroll when you open menu
 
 [HAIRSTYLE] Queen outline is fixed
 

--]]
--[[ BETA changelog 1.6

 [NEW] +24 cards
 [NEW] New Mode : Charnier
 [NEW] Throne Mode : 5 new ranks to smooth out difficulty curve
 
 [UI] grenade's damage is now displayed if your have grenades
 [REWORK] Unfaithful Steed become Faithfull Steed : add 1x Black Knight and let you travel with him
 [REWORK] pieces in jail are not blocking other pieces move
 [FIX] backups that can't spawn now wait for the next turn to spawn
 

--]]

--[[ v1.515g

	[LANG] Update German translation
	
--]]
--[[ v1.515f

	[SAVE] Now using a new save system which should be more stable!
	[BUGFIX] Fixed a crash when Lady in the Tower should have saved you from other pieces after landing in their way
	[BUGFIX] Fixed phrases with no space characters in story screens and in tutorial
	[BUGFIX] Fixed CRT shader for MacOS
	[MODDING] Fixed 'require' only returning the first result of the required file
	
--]]
--[[ v1.515e

	[BUGFIX] Phrases with no space characters (notably in Chinese, Korean and Japanese) are now properly broken down into multiple lines again
	[BUGFIX] Pieces will no longer randomly stop acting at all
	[BUGFIX] Folly shields no longer warn you against safe Sokoban Rooks
	[BUGFIX] Knockback angle now calculated before strafe movement with Royal Loafers
	[BUGFIX] Sabotaging the Mangonel card will now cancel prepared mangonel shots

--]]
--[[ v1.515d

	[BALANCE] Inquisition bishops are less likely to target Moles and Undercover Mission tiles if other moves are available
	[BALANCE] Black Mist now teleports you to an actually safe tile even if you are in stealth
	[BUGFIX] Bishops and rooks will no longer use Tag Team for no reason
	[BUGFIX] Rooks will no longer use Sokoban for no reason, and are less likely to sacrifice other pieces
	[BUGFIX] Rooks will no longer use Sokoban on you when you are in stealth
	[BUGFIX] Sokoban rooks will now actually try to kill you if they have the chance
	[BUGFIX] Fixed a bug where pieces could stack on top of each other because of simultaneous Sokoban pushes and Tag Team swaps
	[BUGFIX] Fixed a rare crash on aiming with a game controller
	[BUGFIX] On a gamepad, pressing B no longer triggers special abilities
	[BUGFIX] Fixed the Discord link on the title screen
	[BUGFIX] Seer's Orb now positions itself correctly above the boss white king
	[BUGFIX] Horsemen no longer get buckler and bow when you step on the third Unholy Call pentacle
	[BUGFIX] Stepping up to the mole as you kill it with Royal Loafers will no longer crash the game
	[BUGFIX] Folly shields now properly warn you against shooting at a pawn when you have Low-Cost Disguise but a Mangonel rook is about to fire at you
	[BUGFIX] Mangonel shot line and circle now properly disappear if canceled with Castling
	[BUGFIX] Sabotaging Vampirism now properly removes blood sucking abilities from queens and leaders
	[BUGFIX] More precise knockback
	[BUGFIX] Fixed rendering of kite shields on knightmares
	[BUGFIX] You can no longer shoot before reloading ends
	[BUGFIX] King's Shoulders now explicitely excludes blade cards using codex tags
	[BUGFIX] Moving into an Inquisition bishop's path with holocloak will now properly use up a folly shield
	[BUGFIX] The correct track is now played after triggering Black Mist during a secret boss fight
	[BUGFIX] If Lady in the Tower places a promoted rook on a square that blocks another threat to the black king, then you are now actually saved from that threat
	[BUGFIX] Fixed button hitbox position for reloading the shotgun with the mouse
	[BUGFIX] Fixed a bug were pieces would appear to slide on the board after getting pushed off the board by a Sokoban rook then saved by Bouncy Castle or Black Mist
	[BUGFIX] Poor cannonballs can no longer be scared
	[LANG] The spanish translation was reviewed and reworked
	[LANG] The spanish translation was further localized into a LATAM spanish translation!
	
--]]
--[[ v1.515c

	[BUGFIX] Fixed a crash when releasing the soul of a sanctified bishop with no soul slot
	[BUGFIX] Fixed a visual bug where after killing a santified bishop it looks like you're about to steal its soul even if you don't have an empty soul slot
	[BUGFIX] Codex and Shotgun progress badges no longer share the same save space
	[ENGINE] Updated Steam API, which hopefully fixes the controller issues a few people have been having
--]]
--[[ v1.515b

	[BUGFIX] Fixed a crash on picking the disrupt reload option
	[BUGFIX] Fatality check now takes Bodyguard, Kite Shield and Cathedral into account

--]]
--[[ v1.515

	[NEW] You can now track your best rank won on each shotgun in Throne mode
	[LOCA] Added Italian and Portuguese localizations!
	[BALANCE] Rooks can no longer protect the king with Castle when stunned
	[BUGFIX] Tentative fix for a bug on controllers where the right stick stops responding
	[BUGFIX] Fixed a bug on controllers where confirming your first move would send you to inspect your cards
	[BUGFIX] Move squares no longer flash at the start of your turn if you're holding right stick
	[BUGFIX] First choice on level ups no longer flashes when the appearing animation ends
	[BUGFIX] Fixed a bug where receiving ammo at the same time as you reloaded
	[BUGFIX] Further refined arrow folly shield detection
	[BUGFIX] Tentative fix for a bug where arrows kill you when they hit the square you just moved from
	[BUGFIX] Prevented level up screen duplication
	[BUGFIX] Bleeding buffs every separate shot from Unjust Decree
	[BUGFIX] Force-feeding now properly capped to 8 shells, even with Yvan IV
	[BUGFIX] Fixed piece %hp bonuses
	[BUGFIX] Mausoleum now gets the leader tag as intended
	[BUGFIX] Castle, Theocracy, Commoner's Reign, and Heir cards now all get the leader tag
	[BUGFIX] Can no longer get sanctified bishops' souls with the Wand of Souls
	[BUGFIX] Extra kings now get leader bonuses during the boss battle
	[BUGFIX] Removed irrelevent delay after white piece moves when there is no bow and arrows
	[BUGFIX] Vampire boss king can now properly suck the blood off the pieces surrounding it on all sides
	[BUGFIX] Codex back button now always shows above card descriptions
	[BUGFIX] Black Mist should no longer move you into arrows
	[BUGFIX] Fixed a bug where some achievement-tracking stats were not properly reset on hitting try again on the gameover
	[BUGFIX] Kite Shields now properly block and get used up by rats and taunting hops
	[BUGFIX] Castling now properly protects the king from rats and taunting hops
	[BUGFIX] Seer's Orb no longer lets you cycle through a piece's options
	[BUGFIX] Grenades will now always trigger Castle before doing damage to any pieces
	[BUGFIX] Castling now protects the king from bleeding
	[BUGFIX] Ambush no longer gets the grenade tag
	[BUGFIX] Fixed the Humiliation achievement so that it only triggers when killing a king by hopping on him
	[BUGFIX] You can now use grenades again right after refilling them with a disruption effect
	[BUGFIX] Can no longer shoot after resigning while being stuck in Analysis Paralysis
	[BUGFIX] Mangonels won't show the targetting line if they're not about to attack because of Selective Listening
	[BUGFIX] Unicorns no longer charge you if you're in stealth mode
	[BUGFIX] Plural forms of words now properly reset when switching languages
	[BUGFIX] Fixed a bug that prevented Sokoban rooks from trying to push you
	[BUGFIX] Folly shields now detect Sokoban rooks who can push you off the board
	[BUGFIX] Fixed a bug where Sokoban rooks or the pieces they push wouldn't fully register as going to their destination if the piece previously at that destination was just pushed off the board, resulting in other pieces being able to move to that same destination and stacking with the piece that just got there
	[LANG] The Royal Hunt's description now mentions the shooting speed increment on stack
	[LANG] Low-Cost Disguise's description now says "when a pawn dies" instead of "when you kill a pawn"
	
--]]
--[[ v1.514

	[BUGFIX] Elusive now works properly with pieces than are blocked
	[BUGFIX] Pieces no longer update their move timer while they're stunned
	[BUGFIX] Only the first rat hitting a bleeding piece during the same turn gets the bleed bonus
	[BUGFIX] No more double sound on pause exit 
	[BUGFIX] Stun now transfers to morphing pieces
	[BUGFIX] Adjusted deepwater description (Knight can't attack from moat)
	[BUGFIX] Commoner's Reign now adds a knight to the white army
	[BUGFIX] Sokoban rooks can't push leaders anymore
	[BUGFIX] False Kings morph to knight AFTER bouncing back to board with Bouncy Castle
	[BUGFIX] Monarch's Confidence doesn't give negative firepower for overfed shotgun anymore
	[BUGFIX] Triggering Spy with Black Mist won't result in multiple disrupt panels and deafening sound
	[BUGFIX] Militia is now properly removed from pawn when sabotaged
	[BUGFIX] Seer's Orb attack target is now updated after holoking's death
	[BUGFIX] Humiliation achievement is now fixed
	[BUGFIX] Finer arrow detection for folly shields
	[BUGFIX] Lifting the Seer's Orb target with King's Shoulders now sends the Seer's Orb to some other piece

--]]
--[[ v1.513

	[BETA] Coming out of beta!
	[BALANCE] AI now has difficulty levels which increase at ranks 4 and 10
	[BUGFIX] Holoking no longer gets the 'leader' tag
	[LANG] Ensured card effects will always be described in the same order
	[LANG] Updated Spanish, Polish, Russian and Japanese translations
	
	[LANG] Added a few forgotten 'msg' keys in the english file

--]]

--[[ BETA v1.512j

	[BUGFIX] Fixed overly genrous tag distribution on the cards
	[BUGFIX] Fixed version regression on the english file
	[BUGFIX] Fixed a minor visual issue on the codex when playing with a gamepad
	[LANG] Updated the French, Ukrainian, Korean, Chinese, and Catalan translations!
	[LANG] Added new Dutch, Romanian and Vietnamese translations!

--]]
--[[ BETA v1.512i

	[BUGFIX] Fixed thrown bleeding pieces becoming undying beings causing mayhem wherever they tread
	[BUGFIX] The Heir no longer needs a full turn to read the manual for the Buckler of Limos after becoming king
	[BUGFIX] Tentative fix for a bug where folly shields trigger in the middle of using Unjust Decree
	[BUGFIX] You can no longer use blade on Holoking

--]]
--[[ BETA v1.512h

	[BUGFIX] Fixed the description for The Royal Hunt so that it doesn't mention movement anymore
	[BUGFIX] Pieces bleeding from caltrops alone no longer get double damage from every pellet in shotgun shots
	[BUGFIX] Killing the last leader with bushido while holding a piece no longer results in a soft lock
	[BUGFIX] Fixed imprecise folly shield detection for arrows
	[BUGFIX] Mangonel no longer considered a threat by folly shields just after they got stunned
	[BUGFIX] Using the Seer's Orb with a gamepad no longer lets you inspect Imperial Shot Puts
	[BUGFIX] Fixed controls to inspect cards with gamepads
	[BUGFIX] Fixed a crash with Analysis Paralysis when playing with a gamepad
	[BUGFIX] Boss white king can no longer grow an extra arm to pick up the Black King
	[BUGFIX] [REDACTED] purifying the Holoking no longer ends the game
	[LANG] Updated the description for The Royal Hunt
	[LANG] Clarified the Reverse Karma disrupt effect
	[ENGINE] Engine update

--]]
--[[ BETA v1.512g

	[BALANCE] Bleeding now affects damage from all sources
	[BALANCE] Caltrops bleed chance dropped to 10% (previously 15%)
	[VISUAL] Iron pieces no longer look like regular pieces when held with King's Shoulders
	[BUGFIX] Iron pieces will no longer break when hit with boulders
	[BUGFIX] Messages announcing backups now use the localized version of the card names
	[BUGFIX] Fixed a crash on deactivating The Final Countdown
	[BUGFIX] The holoking no longer crashes the game as revenge for jumping on him
	[BUGFIX] Orb and Strafe now ignore poor holoking
	[BUGFIX] Kings can no longer call for help if they are already dead, a band-aid won't fix it
	[BUGFIX] Strafe shots now use parameters from before moving
	[BUGFIX] Alexander shotgun unlock text no longer overflows outside of the panel
	[BUGFIX] Fixed custom_dr for modded pieces
	
--]]
--[[ BETA v1.512f

	[BALANCE] "Cover thy head 'gainst this gravel that comes from over yonder your grace"
	[BUGFIX] Stat descriptions can use singular again
	[BUGFIX] Fixed the Wand of Wrath wand description
	[BUGFIX] Clicking the reroll button no longer shows the controller-mode card panels
	
--]]
--[[ BETA v1.512e

	[BALANCE] Black Mist may bring you unexpected opportunities
	[BUGFIX] Pieces now take full damage before knockback is applied
	[BUGFIX] Fixed the Wand of Wrath description
	[BUGFIX] Fixed pluralization of pieces on a few card descriptions
	[BUGFIX] Shooting at wraith pieces point blank no longer detected as a safe move
	[BUGFIX] King's Look-Alike no longer has double leader tag
	[BUGFIX] Rerolling cards with a controller will now properly update the card descriptions
	[LANG] Replaced all instances of "bullets" with "pellets" which should be less confusing in all cases.

--]]
--[[ BETA v1.512d

	[ENGINE] Fixed language files not updating on Mac and Linux
	[ENGINE] Fixed a crash when trying to use mods on Mac or Linux
	[ENGINE] Fixed a crash related to non-ASCII characters in filenames and folders

--]]
--[[ BETA v1.512c

	[BALANCE] Wand of Wrath can't be used on leaders in general instead of just kings
	[GAMEPAD] Added controller support for card rerolls
	[GAMEPAD] Added controller support for stats reset in codex
	[BUGFIX] Fixed a crash on hovering the Tag Team card
	[BUGFIX] Fixed tag attribution + unlocks on cards
	[BUGFIX] Using jumps with souls and with the wand of wings now correctly spends jumps
	[BUGFIX] In the codex, Reset statistics text now always shows correctly on the button
	[BUGFIX] In the codex, card descriptions no longer get overly excited about you scrolling the card selection
	[BUGFIX] New panels now correctly hide HD text rendered in the background
	[BUGFIX] Reroll number now aligns correctly when using an HD font
	[BUGFIX] Level ending animation can be sped up again

--]]
--[[ BETA v1.512

	[GAMEPAD] Fixed, improved and updated controller support!
	[GAMEPAD] New inspection controls for controllers! (tentative, please let us know what you think)
	[ERGO] Can now speed through the gameover animation after resigning by clicking anywhere
	[BALANCE] Flash grenades now also stun iron pieces
	[BALANCE] Stunned pieces can no longer use bows
	[BALANCE] Pieces under influence can now use the ancient flagstone
	[BUGFIX] Shooting at the holoking point blank doesn't confuse the game into crashing anymore
	[BUGFIX] Poor cannonballs can no longer be scared, stunned, bleeding etc
	[BUGFIX] Tentative fix for unicorn freeze
	[OPTI] Minor optimizations
	[LANG] Minor fixes here and there
	[LANG] English language file now fully documented, please get in touch if you're interested in updating one of the current translations! (paid, but we'll need you to be able to invoice us)

--]]

--[[ BETA v1.511

	[BALANCE] Theocracy now needs 2 bishops to spawn
	[BUGFIX] Lifting the last piece with king's shoulders does not end the level anymore
	[BUGFIX] Tutorial fixed
	[BUGFIX] Force-feeding and Monarch's Confidence now count ammo before shooting to adjust firepower bonus
	
-- ]]
--[[ BETA v1.510

	[BALANCE] Bow users now don't shoot at close range (if they can see you)
	[BALANCE] Blight can't use bow and buckler anymore
	[ERGO] Tutorial is back from its holidays
	[ERGO] Made it harder to spam-click through card rerolls by accident
	[BUGFIX] Fixed boss not getting all hp bonuses preperly
	[BUGFIX] REDACTED and REDACTED no longer wear the leader cross
	[BUGFIX] Trying to shoot from a dangerous place will no longer use up two folly shields
	[BUGFIX] No more quantic fire in the codex room
	[BUGFIX] Folly shields won't trigger for a unicorn on the other side of the moat anymore
	[BUGFIX] Unicorns can no longer break out of prison to charge you
	[BUGFIX] Pawn disguise now comes off again after triggering a folly shield
	[BUGFIX] Fixed Unjust Decree requirements description
	[BUGFIX] Killing the king and then his heir (or promoting the heir) on the same turn will no longer send the game into a timeloop
	[BUGFIX] Pawns that kill holokings on the last row no longer get frozen in mid-air after promoting
	[BUGFIX] Flipping Plumed Knight will now remove a knight's plume
	[BUGFIX] Throwing a pawn to death now triggers Low-Cost Disguise
	[BUGFIX] Ammunition Depot rooks will now properly give you free ammo when they die, whatever the cause of death
	[BUGFIX] Re-fixed Fool Companion spawning requirements
	[BUGFIX] Recycling card is now possible in chase mode
	[BUGFIX] Blight move range is now correctly limited by how many swords she has
	[BUGFIX] All pieces get stunned with sacred light even if castling happens, the flash FX doesn't stay longer than it should

--]]
--[[ BETA v1.509

	[BUGFIX] Self Defense won't crash the game anymore
	[BUGFIX] Sokoban Rooks can't push big pieces anymore
	[BUGFIX] Sokoban Rooks now respect Moat rules
	[BUGFIX] Can't unlock Buried Alive by throwing leaders with King's Shoulders
	[BUGFIX] Mangonel Rooks being stunned cancels projectile launching
	
--]]
--[[ BETA v1.508

	[NEW] New cards: Workshop & Unsettled Throne
	[NEW] 27 new achievements!
	[BALANCE] Bouncy Castle also makes grenades bouncier
	[BUGFIX] Secret Move only works on last jump, description has been changed accordingly
	[BUGFIX] Secret Move bonus cannot be stacked anymore
	[BUGFIX] Royal Loafers + Disguise now checks folly shields correctly
	[BUGFIX] Trying to shoot while disguised now highlights danger correctly
	[BUGFIX] Commoner's Reign can now be added to the codex
	[BUGFIX] Sacred kight now really stuns for 2 turns
	[BUGFIX] Grenade damage can't be negative anymore
	[BUGFIX] Stealth now deactivates folly shield on a short range killing blow
	[BUGFIX] Healer can't heal allies above hp_max anymore
	[BUGFIX] Blight and Horsemen can't be picked up with king's shoulders anymore

--]]
--[[ BETA v1.507

	[BUGFIX] Secret Move now spawn correctly if you have a jump card
	[BUGFIX] Right click during  Wand of Wrath selection don't crash the game anymore
	[BUGFIX] No more bouncy castle softlock if you kill a piece falling of the board

--]]
--[[ BETA v1.506

	[NEW] New card: Secret Move, Sacred Light, Bouncy Castle
	[BALANCE] Jump from Taunting Hop is now a stat you can stack. You have to choose different targets for each jump on a single turn.
	[BALANCE] Elusive now has jump +1
	[BALANCE] "King's Look-alike" now always adds a king (It will generate an additional king even on Theocracy) (+1hp still goes to leader)
	[BALANCE] Disrupt effect Stab now only works on king (invisible if no king on board)
	[BALANCE] Shooting the false king now stuns him
	[BALANCE] Shooting or jumping during stealth now reaveals you immediatly
	[BALANCE] Wand of Souls now stuns for 2 turns
	[BALANCE] Engraved Scope now has search +1
	[BALANCE] Monarch Confidence effect change: +1 firepower for every missing ammo in your shotgun barrels
	[BALANCE] Caltrops bleed chance changed to 15% (instead of 20%)
	[BUGFIX] Pieces with no possible actions will no longer shake
	[BUGFIX] A king is now removed when King's Look-alike is flipped (Not necessarily the false one)
	[BUGFIX] reworked orb calculation so it can't make invalid moves (knockback, august presence)
	[BUGFIX] grenade icon is now hidden when no grenade available
	[BUGFIX] Flipping Secret Heir now works properly
	[BUGFIX] Holoking won't count as adjacent for High-Focus anymore
	[BUGFIX] Prison Fx now displays on flying bishops
	[BUGFIX] Codex now displays achievements and completion correctly
	[BUGFIX] Vampires killed by rats won't comme back from hell crashing your system trying to suck its blood
	[BUGFIX] Reset Stats button now shows text properly (but not translated yet)

	
--]]
--[[ BETA v1.505

	[NEW] New cards: Mystic Shackles (old shackles renamed to Selective Listening)
	[NEW] Seer's Orb now also predicts special moves, attacks, and flashes red when piece is ready to act
	[UI] Wand selection now lets you see target hp
	[UI] Folly Shields now scan projectiles and charging unicorns
	[BALANCE] The Royal Hunt firerate lowered if more than one piece has a bow
	[BALANCE] Wand of Souls now removes the soul of the target: A Soulless piece moves randomly and doesn't give a soul when killed.
	[BALANCE] Selective Listening exclusions are now decided before the player moves
	[BALANCE] Small Fry Harvest now have +1 blade instead of +1 ammo_max
	[BALANCE] Healers now heal poison and bleeding
	[BALANCE] Saddle doesn't need Cavalry anymore
	[BUGFIX] Chase Mode is fixed
	[BUGFIX] Wand of Wrath damage are back to normal (= firepower)
	[BUGFIX] Seer's Orb doesn't crash the game anymore
	[BUGFIX] Fixed Sokoban ability to push up to 3 times
	[BUGFIX] Falling pawns can't promote anymore
	[BUGFIX] Emergency call now chooses its target after turn ends
	[BUGFIX] Patience on floor 2 doesn't prevent Homecoming on floor 3 anymore
	[BUGFIX] Castle and Emergency now work on boss
	[BUGFIX] Knight can't attack the turn they get imprisoned anymore
	[BUGFIX] No more [nil] dialog
	[BUGFIX] Stats fixed + added a reset stats button
	[BUGFIX] Fixed a bug lowering the chance for cards needing specific tags to spawn
	[BUGFIX] Plumed Knight and Jester fixed
	[BUGFIX] Black Mist doesn't stop Boss music anymore

--]]
--[[ BETA v1.504

	[NEW] +3 cards Vampirism, Tearing Bullets, Indelible Memories
	[NEW] new mechanic: pieces with bleeding take +1 damage from bullets
	[BALANCE] Caltrops now have 50% chance to inflict bleeding on moving pieces and bleeding pieces lose 1 speed
	[BALANCE] Caltrops don't delay backup cards anymore
	[BALANCE] Kingly alms now inflict +2 dmg on center square
	[BALANCE] Inquisition lets bishops attack cloaked king & doesn't remove 1 firepower anymore if in range
	[BUGFIX] Standing next the holoking with a blade won't crash the game anymore
	[BUGFIX] Enemy pieces cancel the seer action if their move is no longer valid
	

--]]
--[[ BETA v1.503
	
	[NEW] +1 card
	[BALANCE] Plague and Mausoleum damage are now immune to Castle, Shield, Bucklers, and Dungeon protection
	[BUGFIX] Prison random behavior fixed
	[BUGFIX] Folly Shields now take buckler bonus into account
	[BUGFIX] Analysis Paralysis + Unicorn
	[BUGFIX] Right Click cards are no longer blocked
	[BUGFIX] Knocking back flying pieces out of the board now works properly
	[BUGFIX] Events like lightnings, rats, backups won't trigger on next floor anymore
	[BUGFIX] Tag Team and Prison now need a rook, a knight and a bishop to spawn
	[BUGFIX] Assault doesn't increase range anymore
	
--]]
--[[ BETA v1.502
	
	[NEW] +3 cards
	[BALANCE] Throwing grenades doesn't spend a turn anymore and their damage is increased to 3
	[BALANCE] Kingly Alms only gives 1 grenade now
	[BALANCE] Philantropy +2 grenades -1 damage for grenades & doesn't need Kingly Alms anymore to spawn
	[BALANCE] Bunker, Throne, Hunt, Buckler and Dagger now work on any leader
	[BALANCE] Guillotine and cards mentioning leaders are now excluding each others
	[BUGFIX] Bow and Buckler now display correctly on boss
	[BUGFIX] Reverend Mother doesn't crash the game when dying
	[BUGFIX] Theocracy + Undead Armies loop is fixed
	[BUGFIX] Assault doesn't give an additional square range to the black king anymore

--]]
--[[ BETA v1.501

	[UI] All temporary bonus/malus to firerange/firepower/fire arc now display white/red flickering
	[UI] Changed wand selection instructions and FX
	[UI] Fright range now displayed in left panel
	[UI] Folly shields now protect from unicorns
	[BALANCE] Iron queen now removes a queen ( need 2+ queens to spawn )
	[BUGFIX] King doesn't disguise anymore while storming ennemies
	[BUGFIX] King's lookalike: there's now always one true king
	[BUGFIX] Cards added from the card selector are now correctly removed from the deck
	[BUGFIX] Being crushed by the Lady in the Tower doesn't free the king square anymore
	[BUGFIX] Deep Water is fixed
	[BUGFIX] [REDACTED] can't be usurpers anymore
	[BUGFIX] soul wand can now be canceled
	[BUGFIX] unicorns can't charge through the moat anymore
	[BUGFIX] scared mangonel rooks can't fire anymore
	[BUGFIX] Final Countdown music doesn't resume on next floor anymore
	
	
	
--]]
--[[ BETA v1.5
	[NEW] +30 cards
	[NEW] +2 shotguns
	[NEW] new UI for disruption effects ( undercover mission )

	[NEW] added 4 disruption effects
	[BALANCE] knockback can now push pieces off of the board
	[BALANCE] Force-feeding also gives +1 firepower while your gun is full, +1 ammo bonus removed
	[BALANCE] Cathedral damage cap is increased to 2
	[BALANCE] Bullets now hit shield even if the piece is hidden
	[BALANCE] +100% Knockback on Imperial Shot Put
	[BALANCE] Pieces can move through knighmares when they're intangible
	[BALANCE] Analysis Paralysis now lets you recycle cards	
	[BUGFIX] pikes now work through moat
	

--]]

--[[ 1.41 (remy)
	- [ERGO] You can now read mods' descriptions (or at least the start of it) in the mod menu.
	- [LANG] Fixed a typo in Bloodless Coups' english description.
	- [FIX] Fixed controller rumble not initializing correctly on launch.
	- [FIX] Fixed some controls counting twice or too early for both mouse controls and gamepad.
	- [FIX] The shotgun and rank menu arrows now light up red again.
	- [FIX] Attempting to use blade on iron pieces now triggers a folly shield.
	- [FIX] Restored mouse drag controls for King's Shoulders.
	- [FIX] Analysis Paralysis now properly pauses the timer.
	- [FIX] Mod menu buttons won't get misplaced anymore if you spam-click the arrows.
	- [FIX] Fixed switch back to gamepad controls on game over when using a mouse and a gamepad is plugged in.
	- [FIX] Fixed a bug on the level up screen where a choice's descriptions sometimes wouldn't go away if clicking too fast.
	- [FIX] Cannonballs are no longer affected by Saddle.
	- [FIX] Catalan language was added back.
	- [FIX] In settings the back button will now translate every time the language is changed.
	- [FIX] Mod menu buttons are now always drawn with the pixel font, showing the correct icons.
	- [FIX] Fixed an issue with game mode descriptions when scrolling.
	- [FIX] Title will no longer appear behind the play menu when coming back from the tutorial and mods are present.
	- [FIX] Game will now switch back to the default language if a modded language was previously selected but is no longer available.
	- [MODDING] Mods can now access mouse controls variables
	- [MODDING] Both local and workshop versions of a same mod will now be loaded up.
	- [MODDING] Made the mod menu's upload buttons a little nicer.
	- [MODDING] If an upload fails it will now tell you why and also print the reason in the log.txt.
	- [MODDING] 'run' function now allowed in mods to restart the game.
	- [MODDING] Empty mods (no language, game modes nor script) will no longer be loaded up.
	- [MODDING] Fixed append and prepend so that they wouldn't crash if multiple mods use them. (or any, in the case of prepend)
	- [MODDING] Now properly allowing global variable replacement for a set of variable names. (check 'gimme("replaceable")')
	- [MODDING] Mods can now use newbnk, bset, bget, and savbnk to safely save players' progress to a mod-specific save.
	- [MODDING] Custom pieces can now have custom movement, custom attack, custom draw, and custom debris.
	- [MODDING] Added "cond_only_pieces" in language keys.
	- [MODDING] Replaced deprecated function table_from_file with quarentine_req and quarentine_req_env.
	- [MODDING] Fixed unhelpful "Error in error handling" error message when a mod's code crashes the game.
	- [MODDING] Added support for custom pieces' souls.
	- [MODDING] Shotgun sprites are now mode-specific. (load your spritesheet in initialize())
	- [MODDING] Fixed custom pieces effects not showing in card descriptions.
	- [MODDING] Fixed the Saddle carry effect when applied to non-knight & non-rook pieces.
	- [MODDING] Added piece properties nocarry and freelift, they can be given with custom cards.
	- [MODDING] Added support for custom game mode scores.

--]]
--[[ 1.4 (console version & PC version merge!)
	- [NEW] Controller support
	- [NEW] Scripted tutorial
	- [NEW] New art
	- [NEW] In-game achievements
	- [MODDING] Steam Workshop support
	- [MODDING] Modding overhaul

--]]
--[[ 1.39 (remy again)
	- [FIX] Fixed a crash that happened when getting pushed back onto a pentagram or an undercover mission tile with Sawed-off Justice.
	- [FIX] It's no longer possible to get back onto the last of three pentagrams before they're done resetting.
	- [FIX] Fixed pawn souls not increasing damage with Cannon Fodder.
	- [FIX] Folly shields will now properly activate in case of an unsafe point-blank kill or blade kill.
	- [FIX] Cannonballs can no longer spawn on the same tile.

--]]
--[[ 1.38 (remy did this one)
	- [ENGINE] Engine update
	- [FIX] Fixed wrong index for arrow sprites because of engine update.
	- [FIX] Fixed softlock with unjust decree + sawed-off justice because of engine update.
	- [SAVE] Added backup system for saves, so that the game can recover on its own if your save is corrupt for whatever reason.
	
--]]
--[[ 1.37 (remy did this one)
  - [BALANCE] Promoted jesters now pass the hat.
  - [FIX] You can no longer trigger a right click ability and fire your shotgun on the same frame.
  - [FIX] Fixed Iron Maiden description.
  - [LANG] Added Catalan language option! Thank you to Arnau Frago from Projecte Ce Trencada!
  - [LANG] Fixed a few issues in the Ukrainian, Korean, Chinese and Spanish translations. Thank you very much to players who submitted corrections!
  - [LANG] Added translator names on the credits screen

--]]

--[[ 1.36
- [BALANCE] Heir status is now preserved after promotion.
- [BALANCE] Iron Maiden now deactivate if there's only queens on the board.
- [BALANCE] Guillotine and Iron Maiden are not excluding each others anymore.

- [FIX] Fixed a crash bug involving Kingly Alms and Black mist
- [FIX] Healer won't heal cannonball anymore
- [FIX] It's no longer possible to jump over knighmares with taunting hop.
- [FIX] Fixed a bug where you can over-reload your gun if moving too fast after reload
- [FIX] Fixed a bug preventing the use of unjust decree if moving too fast after reload
- [FIX] Healers can no longer heal boss over max hp
- [FIX] Game won't freeze when secret heir, last guardian and king are killed with the same shot.
- [FIX] Philanthropy extra turn now work even if grenade fall off the board or in the moat.

- [LANG] Wording for iron effect : can't die -> can't take damage
- [ACHIEVEMENTS] Theocracy replaced with sanctity in the RELIGION achievement

--]]

--[[ 1.35
[LANG] Piece's names are now correctly displayed on undead armies description	

[BALANCE] Undead Armies now reduce pawn hp by one
[BALANCE] Golden Aging now reduce king and queen hp by one
[BALANCE] one by one reloading removed from Church Organ
[BALANCE] Richard III reworked ammo_max:-1 firerange:+1 pierce:+25%

[ERGO] Title Intro now play only once when you launch game
[ERGO] Retry sequence is now active after resign

[FIX] Wizard achievement is now fixed
[FIX] Imperial Shot Put added to the chase mode banned cards
[FIX] Stray pixels have been hunted down and decimated
[FIX] Philanthropy now work even if Kingly Alms is removed
[FIX] Philantropy extra turn now bypass folly shield
[FIX] Chase mode unlocked too soon now fixed
[FIX] Codex data are now included in steamcloud save
[FIX] bishop moves grid now take account of the red book
[FIX] stabbing the big king with Undercover Mission is fixed
[FIX] It's now possible to throw a piece while moving with Royal Loafers even if you don't have any ammo
[FIX] Shields are now totally removed on the same turn you put them to zero in options screen during game.
[FIX] Fixed hint display for knockback and pierce
[FIX] Kingly Alms is now added to needed card for Bunker & Philantropy
[FIX] Big King won't step on zombies anymore
[FIX] Undercover mission now only display of available missions
[FIX] Autoflipping white cards like Zealot or Witch's Curse can now be deactivated with Undercover Mission
[FIX] Can't lift anything with King's Shoulder if you are already holding a piece or a cannonball
[FIX] Fixed some gfx problem with lifted pieces from the moat	

--]]
--[[ 1.344
[LANG] Updated existing translations
[LANG] Added German, Polish and Japanese
[FIX] Missing degree symbols in codex
[FIX] Fixed an issue that was breaking multi-line texts in Chinese, Korean and Japanese, resulting in wrong and/or missing characters
[FIX] Fixed an issue with "Add X pieces" text that occured after switching between certain languages.

--]]
--[[ 1.343


[GFX] new shotguns have their own sfx and graphics in interface
[ERGO] You can now read unlock conditions for locked shotguns in the shotgun selection screen

[FIX] fixed Theocracy + Ravenous Rats + Undead Rats "Happy Hopping Rook" bug
[FIX] fixed Sawed-off + Unjust Decree soft lock
[FIX] "MMMMH DELICIEUX !" achievement is now fixed
[FIX] zombie pawns won't spawn on fresh backup squares or boss anymore
[FIX] Bodyguards protect big king as expected
[FIX] Cannonball won't affect high focus anymore	
[FIX] Legacy modes won't crash the client if loaded on a modded game
[FIX] spacebar now triggers force-feeding

--]]
--[[ BETA 1.342

[BALANCE] Force-feeding now limited to 7 shells
[BALANCE] Force-feeding extra ammo when level end
[BALANCE] Analysis Paralysis is now capped to 6 turn.Free soul effect removed. Now Stackable ( for the nostalgics )
[BALANCE] Caltrops now additionally delay backup arrivals by 50%

[FIX] Boss music is back
[FIX] Flying pieces now ignore moat to choose move/attack target
[FIX] Collection achievements can't be unlocked on death anymore
[FIX] Fixed a bug where Undercover mission waypoint was sometime missing
[FIX] Fixed a bug making knightmares untargetable with blade	
[FIX] Dark Bishop won't respawn a second time if a bishop is left when he dies
[FIX] Rats spawning because of wand effects will now attack targets before your next move
[FIX] Rats won't spawn anymore on dark bishop spawn animation
[FIX] Recoil from Sawed-off Justice now triggers Unholy Call & Undercover Mission
[FIX] Cannonballs don't need to be killed to finish the game when king is guillotined
[FIX] Cannonballs won't be destroyed by lightning and can now be used for dark bishop fight
[FIX] Shotgun King won't spawn on an unholy pentagram anymore
[FIX] Guillotine and Secret Heir won't spawn in the same game

[NITPICKING] Unholy Call replaced by Caltrops in the NINJA achievement
[NITPICKING] Airy Knights won't affect High Focus


--]]
--[[ BETA 1.34

[NEW CONTENT] +1 card
[FIX] Fixed a bug randomly deactivating follyshield for a specific square ( the may-undercover mission one )
[FIX] In throne mode shotgun king won't spawn in the middle of the arena anymore
[FIX] fixed AI behaviour within deepwater
[FIX] Saddle can't move big king anymore
[FIX] Big King can't be targeted by wand of Hypnosis
[FIX] Using back on rank/shotgun select screen wont crash chase/endless mode anymore
[FIX] Endless Mode now start at floor 1
[FIX] Missed knockback won't keep white piece from attacking
[FIX] Black Bishop is back and now spawn properly in the right situation
[FIX] Shotgun selection panel now display correct shotgun artwork 
[FIX] Plague, Rats, Wands won't affect Shot Put anymore
[FIX] Pikemen attacks are now displayed correctly in UI

--]]
--[[ BETA PATH 1.33

[NEW CONTENT] +1 card and +1 shotgun
[MUSIC] new bgm for chase and codex
[GFX] new design for codex

[BALANCE] +1 range and +1 amo for Richard III

[Fix] Iron Maiden and Guillotine now exclude each others
[Fix] Jester and Fool Companion can now spawn ingame


--]]
--[[ BETA PATCH 1.32

[NEW CONTENT] +6 cards
[ERGO] You can now read pre-requirements and names of undiscovered cards in codex

[BALANCE] Ravenous rats can't be stacked anymore ( 1 max ) 
[BALANCE] Rooks can't protect each others anymore with Cathedral
[BALANCE] cards with specific card needs now spawn more frequently ( +100% per needed cards )
[BALANCE] Richard III can now be unlocked with only 4 canons

[FIX] Folly Shields now ignore recoil if the King is lifting a piece
[FIX] Rooks don't protect theocracy bishops anymore at the boss floor

--]]
--[[ BETA PATCH 1.31

[NEW CONTENT] +1 card
[BALANCE] decreased throne mode difficulty 

[FIX] Fixed tooltip for zealot
[FIX] Last leader killed won't be revived as undead anymore (locking the game)
[FIX] Taunting hop won't cause random extra turn message anymore
[FIX] Turn counter now resets correctly on endless mode
[FIX] Endless Mode, white army upgrades after turn 12 are now working properly
[FIX] Chase mode now waits for levelup animation before playing again, so that torn cards are really deactivated on next turns.
[FIX] Big King won't lock the game anymore if killed with bushido
[FIX] Big King now dies instantly it last hit by rat
[FIX] Unlocked gun wrong name fixed
[FIX] Castle card can't cause rook dying multiple times in one shoot

[ERGO] Added "back" button to mode & gun/rank selection
[BETA] All modes are unlocked so you can test them

--]]
--[[ BETA 1.3		
-- PISTE SINERGY
-- NEED FIX : grenade philantropy shuold block folly

[NEW CONTENT] A codex has been added so you can track your cards statistics and try to catch'em all
[NEW CONTENT] +33 new cards

[VISUAL] Added a proper animation for soul reaping
[VISUAL] Theocracy is now torn up when boss fight begins
[VISUAL] Backups countdown is now visible on card

[Balance] Knight speed -1 (they will now move every 3 turns like bishops)
[Balance] Grenade dmg is now 2 and has its own ammo type
[Balance] Grenade big bounce (2 squares away) is removed, but grenades can now fall off board or sink in the moat.
[Balance] Bodyguard now give knights +1hp
[Balance] Conscription now spawn pawns every 5 turns (was 4)
[Balance] Conclave and Cavalry delay decreased from 20 to 15 turns
[Balance] Pikemen now removes one pawn from the white army
[Balance] Backups now behave like conscription, they spawn on the backline only
[Balance] Percing Truth no longer removes 1 firerange
[Balance] Black Mist now removes 1 firerange while the card is face up
[Balance] Scouting now only add two pawns instead of three
[Balance] Pikemen now gives pawn +1 hp but pawns can now longer attack diagonally
[Balance] Knockback now prevents pieces from attacking you on the turn they are moved.
[Balance] Wands are now limited to 3.
[Balance] Zealots is now flipped if there's no bishop.
[Balance] Ritual Dagger now has blade +1 but lowers king hp by 2 instead of 3
[Balance] Lookout Tower now decreases backup timer each time you kill a piece
[Balance] Pierce mechanic now works like knockback with a % chance for each bullet to pierce its target. Piercing Truth doesn't decrease firepower anymore.

[Rework] Unfaithful Steed: +1 move range, flip this card if there's no knight on the board
[Rework] Taunting Hop: Once per turn, jump over a nearby piece dealing it $0 dmg without ending the turn. Now also works with soul moves.

[Achievements] Wizard achievement now only require 3 wands.
--]]

--[[ v1.253 Changes

- [Lang] Added Korean! Thank you Otiel!
- [Lang] Added Russian! Thank you Drugon!
- [Lang] Added Ukrainian! Thank you NamorSom!
- [Bugfix] Fixed text beeps playing for longer than the actual text in non-latin languages.

--]]
--[[ v1.252 Changes

- [Engine] Fixed an issue that resulted in a heavily slanted screen.
- [Engine] Fixed an issue where audio wouldn't properly initialize, leaving the game silent - or crashing.
- [Ergo] Restored the old card description animation on card choice.
- [Bugfix] Fixed the little pause at the end of each line of the story texts for languages that use non-latin characters.

-- UNLISTED --
- [Lang] $leader will now be replaced with the plural for 999 bishops instead of 2 in case of theocracy.
- [Lang] Can now specify special spellings for any number, plural or not

--]]
--[[ v1.251 Fixes

- [Bugfix] Black mist can't be triggered twice with the same grenade
- [Bugfix] King's shoulders can't lift two pieces at once anymore
- [Bugfix] fixed joust extra turn when you kill a knight with a throw
- [Bugfix] killing heir and king in a single shot won't crash the game
- [Bugfix] Fixed access to the secret boss

- [Lang] It's now possible to add any fonts to the font folder
- [Lang] lang file : added font_size, font_line_height, font_offset_y to adjust font's settings
- [Lang] removed "depixel" font, replaced with "Terminus" which is smaller and supports more characters

-- UNLISTED --
- [Bugfix] Text for best floor and completion align fixed in any language
- [Lang] Added new key: translators

--]]
--[[ v1.25

- [Controls] <SPACE> shortcut to reload
- [Controls] King Shoulders now use drag & drop to be activated

- [Balance] Castle now stuns king and rook so they can't attack you right after swapping
- [Balance] Castle now offers +1hp to rooks
- [Balance] Secret Heir is now theocracy compatible
- [Balance] Theocracy and throne room now exclude each other

- [Engine] Grenades now explode right after being launched.
- [Engine] Surrender now happens on last leader death. It won't happen anymore if there's no leader in the level setup.
- [Engine] Taunting Hop can now override Folly Shields if it kills its target
- [Engine] Folly Shields now take extra damage from Unjust Decree into account
- [Engine] Sacred crown now ignores Folly Shields when you use a soul.

- [Visual] Heir animation is skipped if there's only one pawn.
- [Visual] Moat floating animation is now compatible with flying bishops and spotted heirs

- [Bugfix] reloading shotgun now waits for full ammo regeneration 	
- [Bugfix] Folly shields now check for 3 dmg ( not your firepower ) if you throw a piece at close range with King's Shoulders
- [Bugfix] You can now throw pieces with King's Shoulders even if your shotgun is empty
- [Bugfix] Pause is now activable only during your turn
- [Bugfix] White Pieces and Black King starting their turn in the moat can now move within the moat without constraint
- [Bugfix] Thrown pieces can't overlap knocked back pieces anymore
- [Bugfix] Folly shield now take account of the Royal Loafers target
- [Bugfix] HP Bar now display correctly when 10hp+ pieces fall below 10hp
- [Bugfix] Theocracy bishops can now be thrown at each other, without Castle's rooks crashing the game.
- [Bugfix] Exorcised steam achievement doesn't block the unlocking of Avenged steam achievement anymore.
- [Bugfix] using black mist to escape a grenade won't make you invicible to other grenadas.

- [Lang] "souls" has been added to translation file
- [Lang] difficulty mode now displays correctly in the game footer


-- UNLISTED --
- [Typo] Wand of Wrath ( firepower )
- [Typo] Fullscreen
- [Typo] damage(s)
- [Typo] swaps position
- [Typo] effect_flying::$0s can move and attack across any obstacles
- [Typo] effect_mist::Protects from death once per floor

- [Lang] added/changed : add_piece, flip_if, card_exhausted, card_exhausted_bc
- [Lang] removed : card_wait_floor, cond_if, cond_because
- [Lang] can now specify plural forms for specific numbers

--]]
--[[ v1.245 CHANGES -- done by Remy! ;D
--[Ergo] Added a "resign" button
--[Ergo] Left-click to speed up level complete sequence
--[Ergo] Triple-click at the start of the intro to skip it
--[Bugfix] Crash on lifting secret heir
--[Bugfix] Weird patterns after waking up computer from sleep with the game still running
--[Bugfix] Fixed some annoying mod folder crashes
--[Bugfix] Black Mist now saves you from the boss and the Kingly Alms
--[Bugfix] Free turns give you back your folly shield
--[Bugfix] Now checking on white king death after using magic wands
--[Bugfix] Now processing white king death before free turns
--[Bugfix] Menu back buttons now update when changing language
--[Bugfix] Fixed crashes and freezes that could happen after the splash-screens
--]]
--[[ v1.244 CHANGES
--[Bugfix] Unjust decree won't lock aiming anymore on folly shield use
--[Bugfix] Game won't crash anymore after you throw a heir with King's Shoulders
--[Bugfix] bullet trajectory fixed ( some ~45% bullets had chance to miss )
--[Lang] Renamed the card "Crossdresser" to the more positive, inclusive and safer term "Genderqueer"
--]]
--[[ v1.243 CHANGES
--[New] Steam achievements
--[Visual] Addedd a sight line to make heir detection more obvious
--[Bugfix] leader bonus are not assigned to rooks instead of bishops in case of theocracy
--[Bugfix] No more black screen on pause
--]]
--[[ v1.242 CHANGES
--[Ergonomy] Now drawing a litteral line of sight when uncovering the secret heir
--[Trad] Updated French and Spanish translations
--[Bugfix] No more black screen while the game is paused
--[Bugfix] Leader bonuses are no longer assigned to rooks instead of bishops in case of theocracy
--]]
--[[ v1.241 CHANGES
--[Balance] Flying bishop can now also attack throught pieces. Also added a cool floating effect.
--[Balance] Lookout Tower 10 turns -> 15 Turns
--[Mod support] you can now add a language.txt in your mod to modify/add some text
--[Mod support] intro.png added to the modable files
--[Bugfix] No more softlock if you have no pawn and the secret heir
--[Bugfix] Boss music resume correctly after black mist
--[Trad] at_delay now have a $0
--[Trad] card return id instead of name if the name has no translation
--[MINOR] change hint for exhausted cards
--]]
--[[ v1.24 CHANGES

- [New] 10 new cards !
- [New] "mod" option added : customize various gameplay values and graphics
- [Rework] Engraved Scope : Right click to get : fire arc -45° and range +1. Reset on each move.
- [Balance] Blunderbuss : fire arc 24° --> 30°
- [Balance] Unfaithful Steed : Do not remove knight souls at the start of each floor
- [Balance] Iron Maiden : queen: -1 speed --> queen: -2 speed
- [Balance] Court of The King : 2 Knight + 2 Rooks --> 2 Knight + 1 Bishop + 1 Rook
- [Balance] Holy Gunpowder : 3 cards max --> 2 cards max
- [Balance] Ermine Belt : 4 cards max --> 3 cards max	
- [Visual] Castle event now pause the game for a short time
- [Bugfix] no more vanishing gun on pointing left
- [Bugfix] no more red flicking bg when "scr.flash" is deactivated
- [Bugfix] Unjust Decree is not changing king position anymore on multiple fire.
- [Bugfix] Red Book or Ascension are not applied on soul's moves anymore.
- [Bugfix] changing aim during unjust decree is now impossible. The decree is unjust enough.
- [Text] Sabotage card renamed Ruins

--]]
--[[ v1.23 CHANGES
-[New] New Demo version ( LudumDare Version still available )
-[New] Shaderless compatibility mode ( use the "shaderless .bat" file )
-[Change] EndlessMode : Changed the way Army bonus are chosen
-[Lang] Added a log tracing how many entries are loaded when language is changeds
-[Lang] On first launch, will now look up the user's language and select it if available
-[Balance] Pillage : add 6 pawns --> add 5 pawns
-[Balance] Added another condition to the secret ending


--]]
--[[ V1.22 CHANGES
-[New] Shotgun King if now available in french ( selection from option )
-[Ergonomy] It's now possible to cancel Wands Effect ( like souls )
-[SFX] Jingle for conscription	
-[Fix] Unjust Decree don't stay activated after a folly shield warning
-[Fix] Rollover from one souls ot another now display the red squares properly
-[Fix] speedrun counter is now stopping during backup
-[Fix] Sacred Crown won't be proposed if you have no soul slot
-[Fix] You can now reload your shotgun after the flying shell animation
-[Fix] Boss killed by grenade death animation now display correctly


x-retry button on menu
? Subtle poison kill king's mistress effect


--]]


