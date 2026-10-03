do
    local pal = palette()
    add(pal, 0xffa300)
    palette(pal)
end

newsrf("tmqa_title.png", "title")
newsrf("tmqa_gfx.png", "gfx")
newsrf("tmqa_tutorial.png", "tutorial")
newsrf("tmqa_cards.png", "cards")
newsrf("tmqa_pieces.png", "pieces")

newbnk(128,64,4)

watchtowerSetter=1


local tbl = gimme("global")
for k in all(tbl) do
	-- _log prints stuff in the log file
	--_log(k)
end


function add_content(tbl, new_content)

	for _,v in ipairs(new_content) do
		add(tbl, v)
	end
	
end


append("setup_piece",function(e)

	if e.name == "tmqaplaguedoctor" then
		e.plague_bearer = 1
	elseif e.name == "tmqacatapult" then 
		e.catapult = 1
	elseif e.name == "tmqawraith" then
		e.flying = 1
		e.sanctity = 1
	elseif e.name == "tmqalieutenant" then
		e.promote = 1
	elseif e.name == "tmqatanuki" then	
		e.wraith = 1
	elseif e.name == "tmqawatchtower" then
		e.sanctity = 1
	elseif e.name == "tmqabowman" then
		e.bow = 2

	elseif e.name == "tmqastatue" then
		e.rep = 8
	elseif e.name == "tmqacaduceus" then
		e.healer = 3

	elseif e.name == "tmqaluckycat" then
		e.emergency = 1
	elseif e.name == "tmqakitsune" then
		e.wraith = 1
	elseif e.name == "tmqahellhound" then
		e.bodyguard = 1
	elseif e.name == "tmqaguardianangel" then
		e.plague_bearer = 2
		e.healer=2
	elseif e.name == "tmqaironcladmortar" then 
		e.catapult = 1
		e.iron=1
	elseif e.name == "tmqacolonel" then 
		e.militia = 1
		e.pike=1
	elseif e.name == "tmqapoltergeist" then
		e.flying = 1
		e.sanctity = 1
	elseif e.name == "tmqadogspirit" then
		e.flying = 1
		e.protect=1
	elseif e.name == "tmqayokai" then	
		e.wraith = 1
		e.armorgap = 2
	elseif e.name == "tmqawarmachine" then
		e.sanctity = 1
		e.bow=1
	elseif e.name == "tmqaballista" then
		e.bow = 2
		e.catapult = 1
	end
	
end)


lang["tag_rats"] = "rats"
lang["effect_rats"] = "$1 rats"
lang["effect_descstatueleader"] = "Statues are inert pieces replaced with <leaders> after they die"
lang["effect_desccaduceus"] = "Caduceuses are non-moving pieces that heal other pieces in a wide area"
lang["effect_descelitemedallion"] = "The next card will turn a normal quartz piece into its elite variant!"
lang["effect_descelitemedallionactivated"] = "The power of the medallion resonates within the elite..."
plural.wolf="wolves"
plural.fox="foxes"
plural.caduceus="caduceuses"


function on_bad_spawn(p)

	if p.type == tmqawatchtower or tmqawarmachine then
		if watchtowerSetter == 1 then
			goto_sq(p,squares[28],0)
			watchtowerSetter = 2
		elseif watchtowerSetter == 2 then
			goto_sq(p,squares[29],0)
			watchtowerSetter = 3
		elseif watchtowerSetter == 3 then
			goto_sq(p,squares[36],0)
			watchtowerSetter = 4
		elseif watchtowerSetter == 4 then
			goto_sq(p,squares[37],0)
			watchtowerSetter = 1
		end	
	end
	
end


-- PIECE types 0 to 9 are used by vanilla game
morkitechunk = #PIECES -- We don't want to use a type already in use by the game or another mod.
lang["piece_"..morkitechunk] = "Morkite Chunk"
lang["short_piece_"..morkitechunk] = "Mrkite"

add(PIECES, {type=morkitechunk,
	name="Morkite Chunk", hp=5, tempo=3, seek="wdist",
	give_soul=false,
	hdy=0,
	unliftlift=1,
	nocarry=1,
    behavior={
        { id="line",4,7,8,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 1 or 0, x, y, angle)
		else
			spr(e.iron and 1 or 0, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(16, x, y, 1.5, 1.5)
	end
})

tmqacat = #PIECES
lang["piece_"..tmqacat] = "Cat"
lang["short_piece_"..tmqacat] = "Cat"
add(PIECES, {type=tmqacat,
	name="tmqacat", hp=3, tempo=2, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",0,3,8,  move=1 },
		{ id="line",4,7,1,  atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 3 or 2, x, y, angle)
		else
			spr(e.iron and 3 or 2, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqafox = #PIECES
lang["piece_"..tmqafox] = "Fox"
lang["short_piece_"..tmqafox] = "Fox"
add(PIECES, {type=tmqafox,
	name="tmqafox", hp=4, tempo=3, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="jump", move=1, atk=1, 0,2, 2,2, 2,0, 2,-2, 0,-2, -2,-2, -2,0, -2,2 }
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 5 or 4, x, y, angle)
		else
			spr(e.iron and 5 or 4, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqawolf = #PIECES
lang["piece_"..tmqawolf] = "Wolf"
lang["short_piece_"..tmqawolf] = "Wolf"
add(PIECES, {type=tmqawolf,
	name="tmqawolf", hp=5, tempo=3, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",7,7,8,  move=1, atk=1 },
		{ id="line",6,6,8,  move=1, atk=1 },
		{ id="line",1,1,8,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 7 or 6, x, y, angle)
		else
			spr(e.iron and 7 or 6, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqaplaguedoctor = #PIECES
lang["piece_"..tmqaplaguedoctor] = "Plague Doctor"
lang["short_piece_"..tmqaplaguedoctor] = "Pldoc"
add(PIECES, {type=tmqaplaguedoctor,
	name="tmqaplaguedoctor", hp=5, tempo=4, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",0,3,1,  move=1, atk=1 },
		{ id="line",0,3,2,  move=1 },
		{ id="line",4,7,1,  move=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 9 or 8, x, y, angle)
		else
			spr(e.iron and 9 or 8, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqacatapult = #PIECES
lang["piece_"..tmqacatapult] = "Catapult"
lang["short_piece_"..tmqacatapult] = "Catap"
add(PIECES, {type=tmqacatapult,
	name="tmqacatapult", hp=5, tempo=3, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",1,1,1,  move=1, atk=1 },
		{ id="line",3,3,1,  move=1, atk=1 },
		{ id="line",0,0,8,  move=1, atk=1 },
		{ id="line",2,2,8,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 11 or 10, x, y, angle)
		else
			spr(e.iron and 11 or 10, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqalieutenant = #PIECES
lang["piece_"..tmqalieutenant] = "Lieutenant"
lang["short_piece_"..tmqalieutenant] = "Lieut"
add(PIECES, {type=tmqalieutenant,
	name="tmqalieutenant", hp=4, tempo=2, danger=3, promote=1, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",1,1,2,  move=1, atk=1 },
		{ id="line",0,2,1,  move=1, atk=1 },
		{ id="line",4,5,1,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 13 or 12, x, y, angle)
		else
			spr(e.iron and 13 or 12, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqabulwark = #PIECES
lang["piece_"..tmqabulwark] = "Bulwark"
lang["short_piece_"..tmqabulwark] = "Blwrk"
add(PIECES, {type=tmqabulwark,
	name="tmqabulwark", hp=7, tempo=4, danger=3, seek="gdist",
	give_soul=true,
	behavior={
        { id="line",4,7,2,  move=11 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 15 or 14, x, y, angle)
		else
			spr(e.iron and 15 or 14, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqawraith = #PIECES
lang["piece_"..tmqawraith] = "Wraith"
lang["short_piece_"..tmqawraith] = "Wrath"
add(PIECES, {type=tmqawraith,
	name="tmqawraith", hp=3, tempo=2, danger=3, flying=1, sanctity=1, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",0,7,8,  move=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 49 or 48, x, y, angle)
		else
			spr(e.iron and 49 or 48, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqadog = #PIECES
lang["piece_"..tmqadog] = "Dog"
lang["short_piece_"..tmqadog] = "Dog"
add(PIECES, {type=tmqadog,
	name="tmqadog", hp=4, tempo=3, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",4,5,8,  move=1 },
		{ id="line",0,0,8,  move=1, atk=1 },
		{ id="line",2,3,8,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 51 or 50, x, y, angle)
		else
			spr(e.iron and 51 or 50, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqatanuki = #PIECES
lang["piece_"..tmqatanuki] = "Tanuki"
lang["short_piece_"..tmqatanuki] = "Tanuk"
add(PIECES, {type=tmqatanuki,
	name="tmqatanuki", hp=5, tempo=3, danger=3, wraith=1, seek="rdist",
	give_soul=true,
	behavior={
        { id="line",0,7,1,  move=1, atk=1 },
		{ id="line",0,3,8,  move=1 }
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 53 or 52, x, y, angle)
		else
			spr(e.iron and 53 or 52, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqawatchtower = #PIECES
lang["piece_"..tmqawatchtower] = "Watchtower"
lang["short_piece_"..tmqawatchtower] = "Watch"
lang["effect_descwatchtowercenter"] = "Watchtowers always appear on one of the middle squares"
add(PIECES, {type=tmqawatchtower,
	name="tmqawatchtower", hp=10, tempo=6, danger=3, sanctity=1, seek="wdist",
	give_soul=true,
	behavior={
        { id="jump", atk=1, 0,3, 1,2, 2,1, 3,0, 2,-1, 1,-2, 0,-3, -1,-2, -2,-1, -3,0, -2,1, -1,2 }
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 55 or 54, x, y, angle)
		else
			spr(e.iron and 55 or 54, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqabowman = #PIECES
lang["piece_"..tmqabowman] = "Bowman"
lang["short_piece_"..tmqabowman] = "Bowmn"
add(PIECES, {type=tmqabowman,
	name="tmqabowman", hp=3, tempo=4, danger=3, seek="qdist",
	give_soul=true,
	behavior={
        { id="line",0,0,1,  move=1 },
		{ id="line",2,2,1,  move=1 },
		{ id="line",1,1,1,  atk=1 },
		{ id="line",4,5,1,  atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 57 or 56, x, y, angle)
		else
			spr(e.iron and 57 or 56, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqastatue = #PIECES
lang["piece_"..tmqastatue] = "Statue"
lang["short_piece_"..tmqastatue] = "Statue"
add(PIECES, {type=tmqastatue,
	name="tmqastatue", hp=2, tempo=4, danger=3, seek="qdist",
	give_soul=false, inert=true,
	behavior={

    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 59 or 58, x, y, angle)
		else
			spr(e.iron and 59 or 58, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqacaduceus = #PIECES
lang["piece_"..tmqacaduceus] = "Caduceus"
lang["short_piece_"..tmqacaduceus] = "Caduc"
add(PIECES, {type=tmqacaduceus,
	name="tmqacaduceus", hp=10, tempo=4, danger=3, seek="qdist",
	give_soul=false,
	behavior={

    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 61 or 60, x, y, angle)
		else
			spr(e.iron and 61 or 60, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqaluckycat = #PIECES
lang["piece_"..tmqaluckycat] = "Lucky Cat"
lang["short_piece_"..tmqaluckycat] = "Lucky"
add(PIECES, {type=tmqaluckycat,
	name="tmqaluckycat", hp=5, tempo=3, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",0,3,8,  move=1 },
		{ id="line",4,7,3,  atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 99 or 98, x, y, angle)
		else
			spr(e.iron and 99 or 98, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqakitsune = #PIECES
lang["piece_"..tmqakitsune] = "Kitsune"
lang["short_piece_"..tmqakitsune] = "Kitsu"
add(PIECES, {type=tmqakitsune,
	name="tmqakitsune", hp=4, tempo=2, danger=3, seek="wdist",
	give_soul=true,
	behavior={
		{ id="jump", move=1, 0,2, 1,2, -1,2, 2,0, 2,1, 2,-1, 0,-2, 1,-2, -1,-2, -2,0, -2,1, -2,-1 },
        { id="jump", move=1, atk=1, 0,2, 2,2, 2,0, 2,-2, 0,-2, -2,-2, -2,0, -2,2 }
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 101 or 100, x, y, angle)
		else
			spr(e.iron and 101 or 100, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqahellhound = #PIECES
lang["piece_"..tmqahellhound] = "Hellhound"
lang["short_piece_"..tmqahellhound] = "HHound"
add(PIECES, {type=tmqahellhound,
	name="tmqahellhound", hp=7, tempo=3, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",7,7,8,  move=1, atk=1 },
		{ id="line",6,6,8,  move=1, atk=1 },
		{ id="line",1,1,8,  move=1, atk=1 },
		{ id="jump", move=1, 3,-3, -3,-3, 0,3, 6,-6, -6,-6, 0,6 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 103 or 102, x, y, angle)
		else
			spr(e.iron and 103 or 102, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqaguardianangel = #PIECES
lang["piece_"..tmqaguardianangel] = "Guardian Angel"
lang["short_piece_"..tmqaguardianangel] = "Angel"
add(PIECES, {type=tmqaguardianangel,
	name="tmqaguardianangel", hp=7, tempo=4, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",0,3,1,  move=1, atk=1 },
		{ id="line",0,3,2,  move=1 },
		{ id="line",4,7,1,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 105 or 104, x, y, angle)
		else
			spr(e.iron and 105 or 104, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqaironcladmortar = #PIECES
lang["piece_"..tmqaironcladmortar] = "Ironclad Mortar"
lang["short_piece_"..tmqaironcladmortar] = "Mortar"
add(PIECES, {type=tmqaironcladmortar,
	name="tmqaironcladmortar", hp=5, tempo=2, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",1,1,2,  move=1, atk=1 },
		{ id="line",3,3,2,  move=1, atk=1 },
		{ id="line",0,0,8,  move=1, atk=1 },
		{ id="line",2,2,8,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 107 or 106, x, y, angle)
		else
			spr(e.iron and 107 or 106, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqacolonel = #PIECES
lang["piece_"..tmqacolonel] = "Colonel"
lang["short_piece_"..tmqacolonel] = "Colonl"
add(PIECES, {type=tmqacolonel,
	name="tmqacolonel", hp=4, tempo=2, danger=3, promote=1, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",1,1,2,  move=1, atk=1 },
		{ id="line",0,2,1,  move=1, atk=1 },
		{ id="line",4,5,1,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 109 or 108, x, y, angle)
		else
			spr(e.iron and 109 or 108, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqabastion = #PIECES
lang["piece_"..tmqabastion] = "Bastion"
lang["short_piece_"..tmqabastion] = "Bastin"
add(PIECES, {type=tmqabastion,
	name="tmqabastion", hp=99, tempo=4, danger=3, seek="gdist",
	give_soul=true,
	behavior={
        { id="line",4,7,2,  move=1 },
		{ id="line",0,7,1,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 111 or 110, x, y, angle)
		else
			spr(e.iron and 111 or 110, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqapoltergeist = #PIECES
lang["piece_"..tmqapoltergeist] = "Poltergeist"
lang["short_piece_"..tmqapoltergeist] = "Polter"
add(PIECES, {type=tmqapoltergeist,
	name="tmqapoltergeist", hp=4, tempo=2, danger=3, flying=1, sanctity=1, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",0,7,8,  move=1 },
		{ id="line",0,3,1,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 145 or 144, x, y, angle)
		else
			spr(e.iron and 145 or 144, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqadogspirit = #PIECES
lang["piece_"..tmqadogspirit] = "Dog Spirit"
lang["short_piece_"..tmqadogspirit] = "Spirit"
add(PIECES, {type=tmqadogspirit,
	name="tmqadogspirit", hp=4, tempo=2, danger=3, seek="wdist",
	give_soul=true,
	behavior={
        { id="line",4,5,8,  move=1, atk=1 },
		{ id="line",0,0,8,  move=1, atk=1 },
		{ id="line",2,3,8,  move=1, atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 147 or 146, x, y, angle)
		else
			spr(e.iron and 147 or 146, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqayokai = #PIECES
lang["piece_"..tmqayokai] = "Yokai"
lang["short_piece_"..tmqayokai] = "Yokai"
add(PIECES, {type=tmqayokai,
	name="tmqayokai", hp=6, tempo=3, danger=3, wraith=1, seek="rdist",
	give_soul=true,
	behavior={
        { id="line",0,7,1,  move=1, atk=1 },
		{ id="line",0,3,8,  move=1 },
		{ id="jump", move=1, atk=1, 0,6, 0,-6, 6,0, -6,0 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 149 or 148, x, y, angle)
		else
			spr(e.iron and 149 or 148, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqawarmachine = #PIECES
lang["piece_"..tmqawarmachine] = "War Machine"
lang["short_piece_"..tmqawarmachine] = "WMach"
lang["effect_descwatchtowercenter"] = "Watchtowers always appear on one of the middle squares"
add(PIECES, {type=tmqawarmachine,
	name="tmqawarmachine", hp=10, tempo=4, danger=3, sanctity=1, seek="wdist",
	give_soul=true,
	behavior={
		{ id="line",0,3,1,  move=1 },
        { id="jump", atk=1, 0,3, 1,2, 2,1, 3,0, 2,-1, 1,-2, 0,-3, -1,-2, -2,-1, -3,0, -2,1, -1,2 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 151 or 150, x, y, angle)
		else
			spr(e.iron and 151 or 150, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})

tmqaballista = #PIECES
lang["piece_"..tmqaballista] = "Ballista"
lang["short_piece_"..tmqaballista] = "Balist"
add(PIECES, {type=tmqaballista,
	name="tmqaballista", hp=5, tempo=4, danger=3, seek="qdist",
	give_soul=true,
	behavior={
        { id="line",0,0,2,  move=1 },
		{ id="line",2,2,2,  move=1 },
		{ id="line",1,1,2,  atk=1 },
		{ id="line",4,5,2,  atk=1 },
    },
	custom_dr = function(e,x,y,angle)
		spritesheet("pieces")
		if angle then
			aspr(e.iron and 153 or 152, x, y, angle)
		else
			spr(e.iron and 153 or 152, x, y)
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("pieces")
		sspr(24,16,8,8,x-4,y-4)
	end,
	custom_move_dr = function(x,y)
		spritesheet("pieces")
		spr(18, x, y, 2, 2)
	end
})


local new_cards = {

	{ gid=180, 	spsheet="cards", 	team=1, 	n=1, id="Cat Lady",					need={tmqacat,tmqacat}, gain={4}, queen_peace=1, flip_on="no_tmqacat"	},
	{ gid=181, 	spsheet="cards", 	team=1, 	n=2, id="Kingly Kitty",				pwe=5, need={5}, gain={tmqacat}, king_hp=1	},
	{ gid=182, 	spsheet="cards", 	team=1, 	n=1, id="Yarn Ball",				need={tmqacat}, tmqacat_tempo=1, tmqacat_shield=1	},
	{ gid=183, 	spsheet="cards", 	team=1, 	n=1, id="Faithful Leap",			need={tmqacat}, tmqacat_flying=1, tmqacat_cage=4	},
	{ gid=184, 	spsheet="cards", 	team=1, 	n=2, id="Adoption Center",			need={3}, sac={3}, gain={tmqacat,tmqacat}, tmqacat_hp=1	},
	
	{ gid=185, 	spsheet="cards", 	team=1, 	n=2, id="Vicious Vulpes",			pwe=5, need={2}, sac={2}, gain={tmqafox,tmqafox} },
	{ gid=186, 	spsheet="cards", 	team=1, 	n=1, id="Fathomless Den",			delay=10, gain={tmqafox}, cycle=1 },
	{ gid=187, 	spsheet="cards", 	team=1, 	n=1, id="Shedding Season",			tmqafox_tempo=-2, tmqawolf_tempo=-2, dog_tempo=-2, tmqafox_hp=-1, wolf_hp=-1, dog_hp=-1 },
	{ gid=188, 	spsheet="cards", 	team=1, 	n=1, id="Burrowing",				tmqafox_wraith=1, tmqafox_hp=2, tmqafox_rep=9, need_card="King's Shoulders" },
	{ gid=189, 	spsheet="cards", 	team=1, 	n=2, id="Furcoat Fashion",			need={2,tmqafox}, tmqafox_hp=-2, bishop_hp=1, choose_bishop_plumed=1 },
	
	{ gid=190, 	spsheet="cards", 	team=1, 	n=2, id="Beast's Call",				pwe=5, need={1}, sac={1}, gain={tmqawolf,tmqawolf} },
	{ gid=191, 	spsheet="cards", 	team=1, 	n=1, id="Heart of the Pack",		need={tmqawolf}, all_hp=2, tmqawolf_curse=1 },
	{ gid=192, 	spsheet="cards", 	team=1, 	n=1, id="Silverhound",				need={tmqawolf}, tmqawolf_iron=1, tmqawolf_cage=2, flip_on="only_tmqawolf" },
	{ gid=193, 	spsheet="cards", 	team=1, 	n=1, id="Scavenging",				need={tmqawolf}, tmqawolf_hp=2, tmqawolf_shell=1 },
	{ gid=194, 	spsheet="cards", 	team=1, 	n=2, id="Winter's Jeaopardy",		tmqawolf_tempo=-1, delay=20, gain={tmqawolf,tmqawolf,tmqawolf,tmqawolf} },
	
	{ gid=195, 	spsheet="cards", 	team=1, 	n=2, id="Doctor's Orders",			pwe=5, gain={tmqaplaguedoctor}, leader_hp=-1 },
	{ gid=196, 	spsheet="cards", 	team=1, 	n=1, id="Quarantine",				gain={tmqaplaguedoctor}, pawn_prison=tmqaplaguedoctor, tmqaplaguedoctor_tempo=-1 },
	{ gid=197, 	spsheet="cards", 	team=1, 	n=1, id="Addressing Problems",		need={tmqaplaguedoctor}, tmqaplaguedoctor_orth=1, tmqaplaguedoctor_cage=2 },
	{ gid=198, 	spsheet="cards", 	team=1, 	n=1, id="Miracle Cure",				need={tmqaplaguedoctor}, tmqaplaguedoctor_healer=2, tmqaplaguedoctor_tempo=-2 },
	{ gid=199, 	spsheet="cards", 	team=1, 	n=1, id="Scapegoating",				need={tmqaplaguedoctor}, all_tempo=-2, tmqaplaguedoctor_curse=1 },
	
	{ gid=200, 	spsheet="cards", 	team=1, 	n=2, id="Heavy Artillery",			pwe=5, need={3}, sac={3}, gain={tmqacatapult,tmqacatapult} },
	{ gid=201, 	spsheet="cards", 	team=1, 	n=2, id="Afield Reinforcement",		delay=15, gain={tmqacatapult,tmqacatapult} },
	{ gid=202, 	spsheet="cards", 	team=1, 	n=1, id="Flanking Manoeuvre",		need={1,tmqacatapult}, tmqacatapult_flying=1, knight_swap={tmqacatapult}, tmqacatapult_swap={1} },
	{ gid=203, 	spsheet="cards", 	team=1, 	n=1, id="Frontline Dispatcher",		need={tmqacatapult}, alarm=2, tmqacatapult_tempo=-1, flip_on="no_tmqacatapult"	},
	{ gid=204, 	spsheet="cards", 	team=1, 	n=2, id="Fowardice Rusher",			need={tmqacatapult}, knight_tempo=-1, bishop_tempo=-1, tmqacatapult_hp=-2	},
	
	{ gid=205, 	spsheet="cards", 	team=1, 	n=2, id="Noteworthy Promotion",		pwe=5, need={0,0,0}, sac={0,0}, gain={tmqalieutenant,tmqalieutenant} },
	{ gid=206, 	spsheet="cards", 	team=1, 	n=2, id="Delayed Action",			tmqalieutenant_hp=1, delay=5, gain={tmqalieutenant} },
	{ gid=207, 	spsheet="cards", 	team=1, 	n=1, id="Hardened Position",		need={tmqalieutenant}, pawn_iron=1, pawn_tempo=1, flip_on="no_tmqalieutenant" },
	{ gid=208, 	spsheet="cards", 	team=1, 	n=1, id="Assault Position",			need={tmqalieutenant}, pawn_tempo=-5, pawn_hp=1, flip_on="no_tmqalieutenant" },
	{ gid=209, 	spsheet="cards", 	team=1, 	n=1, id="Independance Position",	need={tmqalieutenant}, pawn_healer=0, pawn_tempo=-1, flip_on="no_tmqalieutenant" },
	
	{ gid=210, 	spsheet="cards", 	team=1, 	n=2, id="Fortify the Army",			pwe=5, need={0}, sac={0}, gain={tmqabulwark,tmqabulwark} },
	{ gid=211, 	spsheet="cards", 	team=1, 	n=1, id="Meatshield",				need={2}, bishop_rep=tmqabulwark, rook_rep=tmqabulwark, tmqabulwark_tempo=1 },
	{ gid=212, 	spsheet="cards", 	team=1, 	n=1, id="Precariousness",			need={tmqabulwark,8}, tmqabulwark_castle=1, leader_tempo=1 },
	{ gid=213, 	spsheet="cards", 	team=1, 	n=1, id="Shot Deflector",			need={tmqabulwark,1}, sac={1}, tmqabulwark_protect=1, tmqabulwark_hp=-2 },
	{ gid=214, 	spsheet="cards", 	team=1, 	n=1, id="Communal Protection",		need={tmqabulwark,bulwark}, all_hp=1, tmqabulwark_hp=-3 },
	
	{ gid=215, 	spsheet="cards", 	team=1, 	n=1, id="Vengeful Spirits",			pwe=5, need={1,2}, knight_rep=tmqawraith, bishop_rep=tmqawraith, bad_shells=1 },
	{ gid=216, 	spsheet="cards", 	team=1, 	n=1, id="Sacrilegious Spirits",		pwe=5, need={3,4}, rook_rep=tmqawraith, queen_rep=tmqawraith, bad_shells=2 },
	{ gid=217, 	spsheet="cards", 	team=1, 	n=1, id="Death's Benediction",		gain={tmqawraith,tmqawraith}, tmqawraith_healer=1, tmqawraith_tempo=1 },
	{ gid=218, 	spsheet="cards", 	team=1, 	n=1, id="Limbo State",				gain={tmqawraith}, pawn_tmqawraith=1, flip_on="no_tmqawraith" },
	{ gid=219, 	spsheet="cards", 	team=1, 	n=1, id="Whispers from Beyond",		gain={tmqawraith}, spread=30, flip_on="no_tmqawraith" },
	
	{ gid=220, 	spsheet="cards", 	team=1, 	n=2, id="Monarch's Best Friend",	pwe=5, need={5}, gain={tmqadog}, king_hp=2, queen_tempo=-1 },
	{ gid=221, 	spsheet="cards", 	team=1, 	n=2, id="Beyong Fetch Game",		gain={tmqadog,tmqadog}, tmqadog_hp=3, soul_slot=1 },
	{ gid=222, 	spsheet="cards", 	team=1, 	n=1, id="Inscribed Collar",			need={tmqadog}, tmqadog_sanctity=1, tmqadog_tempo=-1, descremember=1 },
	{ gid=223, 	spsheet="cards", 	team=1, 	n=1, id="Preposterous Zoomer",		need={tmqadog}, tmqadog_orth=1, tmqadog_leaderbond=-2 },
	--{ gid=224, 	spsheet="cards", 	team=1, 	n=1, id="Doghood's Grip",		need={tmqadog}, descrise=1, descsomething=1, need_card={"Inscribed Collar","Anthropomorphism"} },
	
	{ gid=225, 	spsheet="cards", 	team=1, 	n=2, id="Unistone Creature",		pwe=5, need={3}, sac={3}, gain={tmqatanuki} },
	{ gid=226, 	spsheet="cards", 	team=1, 	n=1, id="Illusion of Defeat",		need={0,0}, pawn_rep=tmqatanuki, tmqatanuki_hp=-2 },
	{ gid=227, 	spsheet="cards", 	team=1, 	n=1, id="Bract Shield",				need={tmqatanuki}, tmqatanuki_shield=1 },
	{ gid=228, 	spsheet="cards", 	team=1, 	n=1, id="Switcheroo",				need={tmqatanuki,8}, tmqatanuki_castle=1, tmqatanuki_hp=1 },
	{ gid=229, 	spsheet="cards", 	team=1, 	n=1, id="Leaf in the Wind",			need={tmqatanuki}, tmqatanuki_tempo=-3, tmqatanuki_cage=3 },
	
	{ gid=230, 	spsheet="cards", 	team=1, 	n=3, id="Lookout Settlement",		pwe=5, gain={tmqawatchtower}, descwatchtowercenter=1 },
	{ gid=231, 	spsheet="cards", 	team=1, 	n=1, id="Midfield Campsite",		gain={tmqawatchtower,tmqawatchtower}, descwatchtowercenter=1, tmqawatchtower_peace=1, flip_on="first-reload" },
	{ gid=232, 	spsheet="cards", 	team=1, 	n=1, id="Nursebay",					need={tmqawatchtower}, tmqawatchtower_healer=1 },
	{ gid=233, 	spsheet="cards", 	team=1, 	n=1, id="Secret Hideout",			need={tmqawatchtower}, tmqawatchtower_bodyguard=1, tmqawatchtower_hp=-3 },
	{ gid=234, 	spsheet="cards", 	team=1, 	n=2, id="Calling for Backups",		need={tmqawatchtower}, alarm=1, delay=4, cycle=1, gain={0}, flip_on="no_tmqawatchtower" },
	
	{ gid=235, 	spsheet="cards", 	team=1, 	n=2, id="Ranging Opportunities",	pwe=5, need={2}, sac={2}, gain={tmqabowman} },
	{ gid=236, 	spsheet="cards", 	team=1, 	n=2, id="Archer Tower",				need={3}, sac={3}, gain={tmqabowman,tmqabowman}, tmqabowman_cage=1 },
	{ gid=237, 	spsheet="cards", 	team=1, 	n=1, id="Selfish Cares",			need={tmqabowman}, tmqabowman_healer=0 },
	{ gid=238, 	spsheet="cards", 	team=1, 	n=1, id="Iron Crossbow",			need={tmqabowman}, tmqabowman_iron=1, tmqabowman_tempo=3, flip_on="only_tmqabowman" },
	{ gid=239, 	spsheet="cards", 	team=1, 	n=1, id="Gattling Bow",				need={tmqabowman}, tmqabowman_bow=3, rook_tempo=-2, flip_on="first-reload" },
	
	{ gid=300, 	spsheet="cards", 	team=1, 	n=2, id="Anthropomorphism",			tmqacat_hp=1, tmqafox_hp=1, tmqawolf_hp=1, tmqadog_hp=1, tmqatanuki_hp=1, bishop_hp=-1 },
	{ gid=301, 	spsheet="cards", 	team=1, 	n=2, id="Constru-Polisher",			rook_tempo=-1, tmqabulwark_tempo=1, tmqatanuki_tempo=1, tmqawatchtower_hp=2, tmqabowman_hp=1 },
	{ gid=302, 	spsheet="cards", 	team=1, 	n=2, id="Fursome Cleaning",			pwe=5, gain={2,2}, tmqacat_hp=-1, tmqadog_hp=-1 },
	{ gid=303, 	spsheet="cards", 	team=1, 	n=1, id="Royal Family",				need={5}, gain={tmqadog,tmqacat,tmqalieutenant}, queen_hp=-2, king_hp=-2 },
	{ gid=304, 	spsheet="cards", 	team=1, 	n=2, id="Outsiding Army",			pwe=5, delay=15, gain={tmqalieutenant,tmqawatchtower,tmqabowman} },
	{ gid=305, 	spsheet="cards", 	team=1, 	n=1, id="Like Cats and Dogs",		need={tmqacat,tmqadog}, tmqacat_hp=1, tmqadog_hp=1, tmqacat_swap={tmqadog}, tmqadog_swap={tmqacat} },
	{ gid=306, 	spsheet="cards", 	team=1, 	n=1, id="Sniffin' Snoot",			gain={tmqadog}, tmqadog_tempo=-1, tmqadog_uncover=1, need_tag={"cloak"}  },
	{ gid=307, 	spsheet="cards", 	team=1, 	n=1, id="The Scab",					need={0,0,tmqatanuki}, tmqatanuki_investigate=1, tmqatanuki_swap={0}, need_tag={"mission"} },
	{ gid=308, 	spsheet="cards", 	team=1, 	n=1, id="Off-Leash",				gain={tmqadog}, tmqadog_carry=1, tmqadog_tempo=1 },
	{ gid=309, 	spsheet="cards", 	team=1, 	n=1, id="Domestication",			gain={tmqafox, tmqawolf}, tmqafox_rep=tmqadog, tmqawolf_rep=tmqadog, tmqafox_hp=-1, tmqawolf_hp=-1 },
	{ gid=310, 	spsheet="cards", 	team=1, 	n=2, id="Back to Bones",			gain={tmqawolf, tmqawolf, tmqadog}, mist=1 },
	{ gid=311, 	spsheet="cards", 	team=1, 	n=1, id="Plaguebringer",			gain={tmqaplaguedoctor}, tmqaplaguedoctor_hp=1, rats=1 },
	{ gid=312, 	spsheet="cards", 	team=1, 	n=2, id="Bottom of the Food Chain",	gain={tmqacat}, rats=-1, tmqacat_poison=5, need_tag={"rats"} },
	{ gid=313, 	spsheet="cards", 	team=1, 	n=1, id="Surprise Promotion",		need={tmqalieutenant}, gain={0}, tmqalieutenant_emergency=1 },
	{ gid=314, 	spsheet="cards", 	team=1, 	n=1, id="Bloodvision",				gain={tmqawolf}, tmqawolf_vampire=1, need_tag="bleed" },
	{ gid=315, 	spsheet="cards", 	team=1, 	n=1, id="Sticky Furball",			gain={tmqacat}, paralysis=3, tmqacat_catapult=1 },
	{ gid=316, 	spsheet="cards", 	team=1, 	n=2, id="Hoarder",					gain={tmqafox}, delay=10, cycle=1, delayed={ammo_max=-1} },
	{ gid=317, 	spsheet="cards", 	team=1, 	n=1, id="Bullseye",					gain={tmqabowman}, tmqabowman_tempo=-1, bad_shells=2, tmqabowman_curse=1 },
	{ gid=318, 	spsheet="cards", 	team=1, 	n=1, id="Superior Intellect",		ai_lvl=1, ammo_max=-1, search=1, need_card={"Anthropomorphism"} },
	{ gid=319, 	spsheet="cards", 	team=1, 	n=1, id="Vixens", 					gain={tmqafox, tmqafox}, tmqafox_killprom=4, queen_hp=-1 },
	{ gid=320, 	spsheet="cards", 	team=1, 	n=1, id="Shelf Knocker", 			delay=10, delayed={gain={tmqacat}, soul_sink=1, tmqacat_hp=-1}	 },
	{ gid=321, 	spsheet="cards", 	team=1, 	n=1, id="9 lives", 					need={tmqacat, tmqacat}, tmqacat_rep=tmqacat, tmqacat_tempo=2, flip_on="only_tmqacat" },
	{ gid=322, 	spsheet="cards", 	team=1, 	n=1, id="Monarchic Statue", 		gain={tmqatanuki}, tmqatanuki_hp=-2, tmqatanuki_rep=tmqastatue, descstatueleader=1 },
	{ gid=323, 	spsheet="cards", 	team=1, 	n=1, id="Incessant Geckering", 		need={tmqafox}, spread=20, firerange=-1, flip_on="no_tmqafox" },
	{ gid=324, 	spsheet="cards", 	team=1, 	n=1, id="Archery Class", 			sac={0,0}, gain={tmqabowman,tmqabowman}, delay=15 },
	{ gid=325, 	spsheet="cards", 	team=1, 	n=1, id="Centaur", 					sac={1}, gain={tmqabowman}, tmqabowman_hp=-1, tmqabowman_tempo=-1 },
	{ gid=326, 	spsheet="cards", 	team=1, 	n=1, id="Pack Hunting", 			sac={3}, gain={tmqawolf,tmqawolf,tmqawolf}, tmqawolf_carry=1, tmqawolf_tempo=2 },
	{ gid=327, 	spsheet="cards", 	team=1, 	n=1, id="Beast Rider", 				need={tmqawolf}, gain={0}, pawn_hp=1, pawn_tempo=-1, flip_on="no_tmqawolf" },
	{ gid=328, 	spsheet="cards", 	team=1, 	n=1, id="Relocation", 				need={0,0,0}, tmqawatchtower_orth=1, flip_on="no_pawn" },
	{ gid=329, 	spsheet="cards", 	team=1, 	n=1, id="Shinto Shrine", 			tmqafox_rep=tmqawraith, tmqatanuki_rep=tmqawraith, tmqafox_tempo=-1, tmqatanuki_tempo=-1 },
	{ gid=330, 	spsheet="cards", 	team=1, 	n=1, id="Frightening Visage", 		gain={tmqawraith}, tmqawraith_pike=1, tmqawraith_despair=1 },
	{ gid=331, 	spsheet="cards", 	team=1, 	n=1, id="Phasmophobia", 			need={tmqawraith}, gain={tmqacat,tmqacat}, tmqacat_tempo=-99, tmqacat_peace=1, tmqawraith_curse=1 },
	{ gid=332, 	spsheet="cards", 	team=1, 	n=1, id="Cursed Tombstone", 		delay=10, gain={tmqawraith}, cycle=1 },
	{ gid=333, 	spsheet="cards", 	team=1, 	n=1, id="Canine Ambush", 			delay=25, gain={tmqadog,tmqafox,tmqawolf,tmqatanuki} },
	{ gid=334, 	spsheet="cards", 	team=1, 	n=1, id="Marche Avant", 			need={0,0}, tmqalieutenant_push=2, tmqalieutenant_tempo=-1 },
	{ gid=335, 	spsheet="cards", 	team=1, 	n=1, id="Pocket Knife", 			need={tmqabowman}, tmqabowman_pike=1 },
	{ gid=336, 	spsheet="cards", 	team=1, 	n=1, id="The Caduceus", 			need={tmqaplaguedoctor}, tmqaplaguedoctor_rep=tmqacaduceus, desccaduceus=1 },

	{ gid=337, 	spsheet="cards", 	team=1, 	n=1, id="Elite Medallion", 			pwe=6, descelitemedallion=1 },
	{ gid=338, 	spsheet="cards", 	team=1, 	n=1, id="Activated Elite Medallion",	pwe=0, descelitemedallionactivated=1 },
	{ gid=340, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Luck",			pwe=100000, sac={tmqacat}, gain={tmqaluckycat}, need_card={"Elite Medallion"} },
	{ gid=341, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Tail",			pwe=100000, sac={tmqafox}, gain={tmqakitsune}, need_card={"Elite Medallion"} },
	{ gid=342, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Hell",			pwe=100000, sac={tmqawolf}, gain={tmqahellhound}, need_card={"Elite Medallion"} },
	{ gid=343, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Heaven",			pwe=100000, sac={tmqaplaguedoctor}, gain={tmqaguardianangel}, need_card={"Elite Medallion"} },
	{ gid=344, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Plating",			pwe=100000, sac={tmqacatapult}, gain={tmqaironcladmortar}, need_card={"Elite Medallion"} },
	{ gid=345, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Promotion",		pwe=100000, sac={tmqalieutenant}, gain={tmqacolonel}, need_card={"Elite Medallion"} },
	{ gid=346, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Wall",			pwe=100000, sac={tmqabulwark}, gain={tmqabastion}, need_card={"Elite Medallion"} },
	{ gid=347, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Manor",			pwe=100000, sac={tmqawraith}, gain={tmqapoltergeist}, need_card={"Elite Medallion"} },
	{ gid=348, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Death",			pwe=100000, sac={tmqadog}, gain={tmqadogspirit}, need_card={"Elite Medallion"} },
	{ gid=349, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Trickster",		pwe=100000, sac={tmqatanuki}, gain={tmqayokai}, need_card={"Elite Medallion"} },
	{ gid=350, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Machine",			pwe=100000, sac={tmqawatchtower}, gain={tmqawarmachine}, need_card={"Elite Medallion"} },
	{ gid=351, 	spsheet="cards", 	team=1, 	n=1, id="Elitism: Trebuchet",		pwe=100000, sac={tmqabowman}, gain={tmqaballista}, need_card={"Elite Medallion"} },
}


for i,ca in pairs(new_cards) do
	ca.played = 1  -- These stats will be used in the codex.
	ca.ignored = 0 -- You may save them and retrieve them yourself with your mod's save bank if you'd like.
end


add_content(CARDS, new_cards)


add_content(EXCLUDE, {


	{"Heart of the Pack", "Silverhound"},
	{"Guillotine", "Silverhound"},
	{"Castle", "Precariousness","Switcheroo"},
	{"Undead Armies", "Meatshield","Vengeful Spirits","Sacrilegious Spirits"},
	{"Domestication", "Shinto Shrine"},
	{"Monarchic Statue", "Shinto Shrine"},
	{"Guillotine", "Elitism: Plating"}
	
	
})

add_content(TAGS, {


	{ id="rats", 		attributes={"rats"} },


})

add_content(AUTO_REPLACE, {

	{"Elite Medallion","Elitism: Luck","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Tail","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Hell","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Heaven","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Plating","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Promotion","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Wall","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Manor","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Death","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Trickster","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Machine","Activated Elite Medallion"},
	{"Elite Medallion","Elitism: Trebuchet","Activated Elite Medallion"},

})


--[[ This is the complete vanilla sets of cards and pieces:

CARDS={
	{ gid=0, ext=0, n=3, id="Ermine Belt", 				ammo_max=3,  }, --need_tag={"bleed","stealth"}
	{ gid=1, ext=0, n=2, id="Rightful Curtsy", 		ammo_max=1, knockback=50 },
	{ gid=2, ext=0, n=1, id="Elite Gem", 					firerange=1, ammo_regen=1 },
	{ gid=3, ext=0, n=3, id="Extra Barrel", 			pwe=6, spread=7, chamber_max=1 },
	{ gid=4, ext=0, n=1, id="Royal Loafers", 			special="strafe"	},	
	{ gid=5, ext=0, n=1, id="Majestic Censer",		soul_slot=1,ammo_max=1  },
	{ gid=6, ext=0, n=1, id="Sacred Crown",				need_soul=1, crown=1  }, 
	{ gid=7, ext=0, n=2, id="Blunderbuss",				spread=30, firepower=2  },
	{ gid=8, ext=0, n=1, id="Engraved Scope",			search=1, special="scope" },	
	{ gid=9, ext=0, n=2, id="Holy Gunpowder",			firepower=1,  },
	{ gid=10, ext=0, n=1, id="Ritual Dagger",			blade=1, leader_hp=-2, firerange=-1 },
	{ gid=11, ext=0, n=1, id="August Presence",		presence=1  },
	{ gid=12, ext=0, n=1, id="Crow's Blessing",		firerange=2 },				
	{ gid=13, ext=0, n=1, id="Wand of Downpour",	wand={0,10}  },
	{ gid=14, ext=0, n=1, id="Wand of Frenzy",		wand={1} },
	{ gid=15, ext=0, n=1, id="Wand of Wrath",			wand={2,"firepower"} },
	{ gid=16, ext=0, n=1, id="Wand of Wings",			wand={3,3}},
	{ gid=17, ext=0, n=1, id="The Moat",					moat=4 },
	{ gid=18, ext=0, n=2, id="Gradual Absolution", need_soul=2,pwe=2,absolution=1 },	
	{ gid=19, ext=0, n=2, id="Taunting Hop", 			hop=1, hop_dmg=1},	
	{ gid=20, ext=0, n=1, id="Wand of Gust",			wand={4} },	
	{ gid=21, ext=0, n=1, id="Unfaithful Steed",	need=1,steed=1, flip_on="no_knight"},	
	{ gid=22, ext=0, n=1, id="Unjust Decree", 		pwe=2,need_chamber_max=2, firepower=-1, special="decree" },
	{ gid=23, ext=0, n=3, id="Kingly Alms", 			grenades_max=1, grenade_center_dmg=2, special="grenade" },
	{ gid=24, ext=0, n=1, id="Subtle Poison", 		pwe=2,queen_hp=-1,leader_hp=-1, queen_poison=15}, 
	{ gid=25, ext=0, n=1, id="Kingdom Wealth", 		pwe=3,ammo_max=6,	leader_hp=2 },
	{ gid=26, ext=0, n=2, id="Small Fry Harvest", pwe=2,pawn_shell=1,blade=1}, 
	{ gid=27, ext=0, n=2, id="A Piercing Truth", 	pierce=30},	--firepower=-1
	{ gid=28, ext=0, n=2, id="Black Mist", 				mist=1,firerange=-1 },
	{ gid=29, ext=0, n=1, id="King's Shoulders",	pwe=2,grab=1 },
	{ gid=30, ext=0, n=2, id="High Focus", 				spread=-18,firepower=1,flip_on="contact"},
	{ gid=31, ext=0, n=1, id="Courteous Jousting",need=1, knight_joust=1, spread=-10 },	
	{ gid=32, ext=0, n=1, id="Cornered Despot", 	firepower=2, flip_on="inner" },	

	{ gid=33, ext=1, n=1, id="Sawed-off Justice", firepower=2, firerange=-1, recoil=1 },
	{ gid=34, ext=1, n=1, id="Welcome Gift", 			firepower=4, flip_on="first-reload", welcome=1 },	
	{ gid=35, ext=1, n=1, id="Cannon Fodder", 		pawnreap=1 },
	{ gid=36, ext=1, n=1, id="Possessed", 				soul_slot=2, gain=2, need_card={"Conclave","Unholy Call"}},
	{ gid=37, ext=1, n=1, id="Philanthropy", 			grenades_max=2, grenade_dmg=-1, special="grenade" },
	{ gid=38, ext=1, n=3, id="Imperial Shot Put", cannonball=1, ammo_max=-1, need_card="King's Shoulders"	},
	{ gid=39, ext=1, n=1, id="Egotic Maelstrom",	delay=10, cycle=1, delayed={firepower=1} },
	{ gid=40, ext=1, n=1, id="Church Organ", 			ammo_max=2, chamber_max=2, need_card="Cathedral"	},
	{ gid=41, ext=1, n=1, id="Black Plague",			plague=1,	firerange=-1, need_card={"Crow's Blessing","Ravenous Rats"}	},
	{ gid=42, ext=1, n=1, id="Ravenous Rats",			rats=1 },
	{ gid=43, ext=1, n=1, id="Deep Water",				deepwater=1, need_card="The Moat" },
	{ gid=44, ext=1, n=1, id="Unholy Call",				pentagrams=3	},
	{ gid=45, ext=1, n=1, id="Undercover Mission",waypoint=1 },
	{ gid=46, ext=1, n=2, id="Caltrops",					caltrops=15, bleed_slow=1	}, --delay_mult=-50
	{ gid=47, ext=1, n=1, id="Nightbane",					blade=3	},
	{ gid=48, ext=1, n=1, id="Bushido",						blade=2, bushido=1, firepower=-1	},
	{ gid=49, ext=1, n=1, id="Bloodless Coups",		pawn_peace=1, pawn_curse=1	},
	{ gid=50, ext=1, n=1, id="Wand of Hypnosis",	wand={5}	},	
	{ gid=51, ext=1, n=1, id="Presbyopia",				queen_bishop_minr=2, need_card="Golden Aging"	},
	{ gid=52, ext=1, n=1, id="Golden Aging",			need={4,8}, delay=10, cycle=1, leader_queen_hp=-1,delayed={leader_queen_tempo=1}	},
	{ gid=53, ext=1, n=1, id="Fool Companion",		jester_guard=1,	need_card="The Jester"		},
	{ gid=54, ext=1, n=1, id="Force-feeding",			overload=1, full_firepower=1		},
	
	{ gid=55, ext=2, n=1, id="Seer's Orb",				special="orb", search=1, orb=1			},
	{ gid=56, ext=2, n=2, id="Fearsome", 					fearsome=1, ammo_max=1 },	
	{ gid=57, ext=2, n=1, id="Human Shield", 			humanshield=1, need_card="Fearsome", ammo_max=2 },
	{ gid=58, ext=2, n=1, id="Reign of Terror", 	terrorism=1, need_card="Fearsome", ammo_max=-2 },
	{ gid=59, ext=2, n=1, id="Selective Listening", 	tactic=2 },
	{ gid=60, ext=2, n=1, id="Monarch's Confidence", need_chamber_max=2, confidence=1 },
	{ gid=61, ext=2, n=2, id="The Mole", 					ammo_max=1, spy=1, need={0,0,0,0,0,0,0} },
	{ gid=62, ext=2, n=1, id="Elusive", 					hop=1, elusive=1 },
	{ gid=63, ext=2, n=1, id="Holoking", 					holoking=1 },
	{ gid=64, ext=2, n=1, id="Cloaking Device",		holocloak=1, holoreveal=1, need_card="Holoking" },	
	{ gid=65, ext=2, n=2, id="Low-Cost Disguise",	pawn_disguise=2 },	
	{ gid=66, ext=2, n=1, id="Wand of Souls",			wand={6} },
	{ gid=67, ext=2, n=1, id="Wand of Execution", wand={7} },
	{ gid=68, ext=2, n=2, id="Patience",					ammo_max=1, browse=1, floor_max=9 },
	{ gid=69, ext=2, n=3, id="Bold Plan",					replace_white_card=1 },
	{ gid=70, ext=2, n=1, id="Silencer",					silencer=1, firerange=-1, need_tag="cloak", },
	{ gid=71, ext=2, n=1, id="Ambush",						grenade_dmg=1, firerange=2, need_tag="cloak", flip_on="not_cloaked" },
	{ gid=72, ext=2, n=1, id="Ancient Flagstone",	flagstones=1 },
	{ gid=73, ext=2, n=1, id="Tearing Bullets",		tearing=1 },
	{ gid=74, ext=2, n=1, id="Indelible Memories",	grenades_max=1,	grenade_bleed=1, special="grenade" },
	{ gid=75, ext=2, n=1, id="Mystic Shackles",		shackles=1, need_tag="orb"	},
	{ gid=76, ext=2, n=1, id="Secret Move",				hop=1, botte=2, need_tag="jump" }, -- Botte Secrete
	{ gid=77, ext=2, n=1, id="Sacred Light",			grenades_max=1, grenade_dmg=-2, grenade_stun=2, grenade_proof=1, special="grenade" },
	{ gid=78, ext=2, n=1, id="Workshop",					delay=8, cycle=1, delayed={mk_grenades=1,mk_ammo=2}, need_tag="grenade" },
	
	
	
	-- White cards
	{ gid=80, ext=0, id="Backups", 					gain={0,0,0}, n=3, team=1  },
	{ gid=81, ext=0, id="Cavalry", 					delay=15, gain={1,1} },
	{ gid=82, ext=0, id="Conclave", 				delay=15, gain={2,2}  },	
	{ gid=83, ext=0, id="Entitle", 					sac=0, gain=1, ammo_max=-1  },
	{ gid=84, ext=0, id="Cardinal", 				sac=0, gain=2, ammo_max=-1 },	
	{ gid=85, ext=0, id="Remparts",  				sac={0,0}, gain={3}, n=2  },	
	{ gid=86, ext=0, id="Pillage",  				sac=3, gain={0,0,0,0,0}, pawn_hp=1  },	
	{ gid=87, ext=0, id="Crusades",  				sac=2, gain={1,1}  },		
	{ gid=88, ext=0, id="Peace",  					sac=1, gain={2,2}  },	
	{ gid=89, ext=0, id="King's Mistress",	need=4, gain=4, queen_cage=3  },
	{ gid=90, ext=0, id="Revolution",  			sac=2, gain={0,0,0,0,0,0},  },	
	{ gid=91, ext=0, id="Bodyguard",  			need={1,8}, knight_bodyguard=1, knight_hp=1 },	
	{ gid=92, ext=0, id="Ruins",  					gain={3,0,0}, rook_hp=-2  },	
	{ gid=93, ext=0, id="Assault",  				need={0,0,0,0,0}, gain=0, pawn_assault=1  },
	{ gid=94, ext=0, id="Kite Shield",  		need={1,1}, gain=0, knight_shield=1 },
	{ gid=95, ext=0, id="Zealots", 					need=2, pawn_tempo=-1, bishop_tempo=-1, flip_on="no_bishop"  },
	{ gid=96, ext=0, id="Militia", 					need={0,0,0}, gain=0, pawn_militia=1 },
	{ gid=97, ext=0, id="Ammunition Depot",	n=2, gain=3, rook_shell=2	},
	{ gid=98, ext=0, id="Scouting",					sac=1, gain={0,0}, pawn_tempo=-1 },	
	{ gid=99, ext=0, id="Pikemen",					need={0,0}, pawn_hp=1, pawn_pike=1, pawn_reformed=1 },
	{ gid=100, ext=0,	id="Ascension",				need={2,2}, bishop_flying=1 },
	{ gid=101, ext=0,	id="Castle",					need={3,8}, rook_castle=1, rook_hp=1 },	
	{ gid=102, ext=0,	id="Conscription",		n=2, gain=0, delay=5, cycle=1 },
	{ gid=103, ext=0,	id="Theocracy",				sac=5, gain=2, need={2,2}, bishop_hp=2, theocracy=1, ruler=2, no_ruler=1},
	{ gid=104, ext=0,	id="Fallen Dynasty", 	fallen=1, pwe=0	},
	{ gid=105, ext=0,	id="Iron Maiden",			need={4,4}, sac=4, queen_iron=1, queen_tempo=2, flip_on="only_queen" },	
	{ gid=106, ext=0,	id="Court of the King",	n=2, gain={1,1,2,3},all_tempo=1  },
	{ gid=107, ext=0,	id="The Red Book",		gain=2, bishop_orth=1, },
	{ gid=108, ext=0,	id="Saboteur",				n=2, sac={0,0}, gain=2, bad_shells=1  },	
	{ gid=109, ext=0,	id="Homecoming",			n=1, gain={4}, pwe=0	},
	{ gid=110, ext=0,	id="Lookout Tower",		n=2, gain=3, delay=20, alarm=1 },	
	{ gid=111, ext=0,	id="Throne Room",			need=5, leader_hp=2, queen_hp=1 },
	{ gid=112, ext=0,	id="The Secret Heir",	gain=0, heir=1 },
	{ gid=113, ext=0,	id="Genderqueer",			sac=2, gain=4, delay=10 },

	{ gid=114, ext=1, id="Karma", 						sqb_spread=30, sqw_firepower=-1, reversable=1  },
	{ gid=115, ext=1, id="Undead Armies",			knight_bishop_rook_rep=0, pawn_hp=-1  },
	{ gid=116, ext=1, id="Shortage", 					sac=0, ammo_max=-3, grenades_max=-1, need_tag="grenade"	},
	{ gid=117, ext=1, id="Succubus", 					gain=4, soul_slot=1	},
	{ gid=118, ext=1, id="Bunker", 						need={0,0,0}, sac=3, leader_pawn_hp=1, grenade_dmg=-1, need_tag="grenade"	},
	{ gid=119, ext=1, id="Sanctity", 					gain=2, bishop_sanctity=1, need_card="Conclave"	},
	{ gid=120, ext=1, id="Knightmare", 				gain=1, knight_wraith=1, knight_hp=-1, need_card="Black Mist"	},
	{ gid=121, ext=1, id="Highest Dungeon", 	need={3}, all_hp=1, flip_on="no_rook",need_card="Remparts" },
	{ gid=122, ext=1, id="Cathedral",					sac=2, gain=3, rook_protect=1, need_card="Cardinal"},
	{ gid=123, ext=1, id="The Bridge",				bridge=1, delay=10, gain=1, need_card="The Moat" },
	{ gid=124, ext=1, id="Divine Healing",		need={2}, bishop_hp=1, bishop_healer=2 },
	{ gid=125, ext=1, id="Last Guardian",			need={0,0}, pawn_lastg=1},
	{ gid=126, ext=1, id="Trowel",						need={3,0}, rook_hp=4, flip_on="no_pawn"},
	{ gid=127, ext=1, id="Full Plate Armor",	blade=-1, all_hp=1, all_tempo=1 },
	{ gid=128, ext=1, id="Military Academy",	delay=10, gain=1, cycle=1 },
	{ gid=129, ext=1, id="Witch's Curse",			need=4, firepower=-1, firerange=-1, spread=10, queen_curse=1 },
	{ gid=130, ext=1, id="Saddle",						need=1, knight_carry=1, knight_tempo=1 },
	{ gid=131, ext=1, id="The Jester",				need=0, gain=0, jester=1, need_card="Throne Room" },
	{ gid=132, ext=1, id="Guillotine",				sac=5, need_card="Revolution", exclude_tag="leader" },
	{ gid=133, ext=1, id="Analysis Paralysis", n=2, paralysis=6, search=1, need_card="High Focus" },

	{ gid=134, ext=2, id="Plumed Knight",			need=1, choose_knight_plumed=1			},
	{ gid=135, ext=2, id="Emergency Call",		need={0,0}, leader_emergency=1, gain=0			},
	{ gid=136, ext=2, id="Mangonel",					gain=3, rook_catapult=1, rook_tempo=1		},
	{ gid=137, ext=2, id="Governess",					gain=2, force_promote=4			},
	{ gid=138, ext=2, id="Mausoleum",					gain=3, rook_leaderbond=2			},
	{ gid=139, ext=2, id="Reverend Mother",		gain=4, queen_despair=1, need_card="Theocracy"	},
	{ gid=140, ext=2, id="Sokoban",						gain={0,0}, need={3,3}, rook_push=3 	},
	{ gid=141, ext=2, id="Tag Team",					need={2,3}, bishop_swap={3}, rook_swap={2}, rook_bishop_hp=1 }, --
	{ gid=142, ext=2, id="Unicorn",						knight_charge=1, gain=1 }, --
	{ gid=143, ext=2, id="Lady in the Tower", gain=3,	rook_killprom=4	 }, --
	{ gid=144, ext=2, id="Final Countdown", 	deathcount=12, deathcount_trig=6 }, 	
	{ gid=145, ext=2, id="Nomad Life", 				n=2, sac=3, gain={1,1,2}, knight_promote=1 }, 	
	{ gid=146, ext=2, id="Prison",						need={1,2,3},	gain={2,1}, knight_bishop_prison=3 },
	{ gid=147, ext=2, id="Inquisition",				gain=2, sac=0, bishop_uncover=1, bishop_investigate=1, need_tag={"mission","cloak"}	}, -- bishop can kill spy and cancel missions
	{ gid=148, ext=2, id="King's Look-alike", n=2, gain=5, false_king=1, leader_hp=1, no_ruler=1 },
	{ gid=149, ext=2, id="The Royal Hunt",		n=2, leader_bow=2 },	
	{ gid=150, ext=2, id="Tragic Homecoming",	n=1, gain={4}, pwe=0, queen_hp=2 },
	{ gid=151, ext=2, id="Buckler of Limos",	leader_armorgap=3, leader_tempo=1, need_firepower=5 },
	{ gid=152, ext=2, id="Vampirism",					leader_queen_vampire=1, leader_queen_hp=1, need_tag="bleed" }, --false_king=1,
	{ gid=153, ext=2, id="Commoner's Reign", 	sac=5, ruler=1, knight_hp=2, pwe=0 },
	{ gid=154, ext=2, id="Bouncy Castle", 		need_knockback=100, rook_hp=-2, trampoline=1 }, 
	
	{ gid=155, ext=2, id="Self-Defense", 			knight_hp=2, pwe=0 }, 
	{ gid=156, ext=2, id="Unsettled Throne", 	need_heir=1, heir=1, heirprom=1 }, 

}



EXCLUDE={
	{"Royal Loafers","Sawed-off Justice"},
	{"Militia","Bloodless Coups"},
	{"Guillotine","The Secret Heir"},
	--
	{"The Red Book","The Royal Hunt"},
	{"The Red Book","Buckler of Limos"},
}

AUTO_REPLACE={
	{"Bodyguard","Commoner's Reign","Self-Defense"},
}

TAGS={
	{ id="leader", 		attributes={"leader","king"} },
	{ id="mission", 	attributes={"waypoint","spy"} },
	{ id="cloak", 		attributes={"holocloak","disguise"}},
	{ id="bleed", 		attributes={"grenade_bleed","tearing","caltrops"}},
	{ id="orb", 			attributes={"orb"}},
	{ id="jump", 			attributes={"hop"}},
	{ id="grenade",	attributes={"freegren","grenade"}},
}

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


-- Have fun!
