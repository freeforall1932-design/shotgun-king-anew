
local muppetbishop_p = nil
local dj_summon, dj_defect, dj_raise, dj_soul_split
local expire_all_graves, expire_all_hatred_graves, bishop_is_threatened
local resolve_unending_servitude, consume_pending_unending_swap

local hatred_count = 0
local lingering_hatred_count = 0

local pending_tainted_book_swap = false

local pending_unending_swap = false --- holds "Repentance" or "Echoes" once resolved, consumed at floor start

local hatred_typ, lingering_hatred_typ

local hatred_graves = {}
local hatred_grave_markers = {}
local hatred_grave_squares = {}

local warn = true
for mod in all(MODLIST) do if mod.title == "Glacies' Collection" and mod.active then warn = false end end
if warn then
	log("Glacies' Collection must be turned on!")
	wlog("Glacies' Collection must be turned on!")
	append("init_menu",bind(sfx,"wrong"),"glacies warning")
end


local extra_active = false
for mod in all(MODLIST) do
	if mod.title == "SGK Extra" and mod.active then extra_active = true end
end
local RED_BOOK_ID = extra_active and "Extra's The Red Book" or "The Red Book"

local graves = {}

local DJ_SUMMON_COST = 6
local DJ_DEFECT_COST = 8
local DJ_RAISE_COST = 10
local DJ_SOUL_SPLIT_COST = 12

append("init_game", function()
	muppetbishop_p = nil
	hatred_count = 0
	lingering_hatred_count = 0
	pending_tainted_book_swap = false
	pending_unending_swap = false
	add(upgrades, {muppetbishop_black_peace=1})
	expire_all_graves()
	expire_all_hatred_graves()
end, "disgraced justice run reset")

append("clean_up", function()
	expire_all_graves()
	expire_all_hatred_graves()
	resolve_unending_servitude()

	if pending_tainted_book_swap then
		if has_card("Stolen Scriptures") then
			replace_card("Stolen Scriptures", "Tainted Book")
		end
		pending_tainted_book_swap = false
	end

	if pending_unending_swap then
		if has_card("Unending Servitude") then
			replace_card("Unending Servitude", pending_unending_swap)
		end
		pending_unending_swap = false
	end
end, "disgraced justice cleanup")

function on_card_but_init(but, ca)
	if ca.id == "Vow of Fealty" then
		local left_clic = but.left_clic
		function but.left_clic()
			if left_clic then left_clic() end
			if ca.flipped then return end

			for p in all(hero.sq.danger) do
				if p.type == 2 then
					convert(p, function() end)
					flip_card(ca)
					break
				end
			end
			remove_buts()
			wait(5, play)
		end

	elseif ca.id == "Red Book: Summon" then
		local right_clic = but.right_clic
		function but.right_clic()
			if right_clic then right_clic() end
			if ca.flipped then return end
			if (hero.book_power or 0) < DJ_SUMMON_COST then sfx("wrong") return end
			dj_summon()
			remove_buts()
			wait(5, play)
		end

	elseif ca.id == "Red Book: Defect" then
		local right_clic = but.right_clic
		function but.right_clic()
			if right_clic then right_clic() end
			if ca.flipped then return end
			if (hero.book_power or 0) < DJ_DEFECT_COST then sfx("wrong") return end
			dj_defect()
			remove_buts()
			wait(5, play)
		end

	elseif ca.id == "Red Book: Raise" then
		local right_clic = but.right_clic
		function but.right_clic()
			if right_clic then right_clic() end
			if ca.flipped then return end
			if (hero.book_power or 0) < DJ_RAISE_COST then sfx("wrong") return end
			dj_raise()
			remove_buts()
			wait(5, play)
		end

	elseif ca.id == "Red Book: Soul Split" then
		local right_clic = but.right_clic
		function but.right_clic()
			if right_clic then right_clic() end
			if ca.flipped then return end
			if (hero.book_power or 0) < DJ_SOUL_SPLIT_COST then sfx("wrong") return end
			dj_soul_split()
			remove_buts()
			wait(5, play)
		end

	elseif ca.id == "Unending Servitude" then
		local left_clic = but.left_clic
		function but.left_clic()
			if left_clic then left_clic() end
			if ca.flipped then return end

			hatred_count = hatred_count + 1
			add(upgrades, {gain={hatred_typ}})
			remove_buts()
			replace_card("Unending Servitude", "Disgraced Justice", play)
		end

		local right_clic = but.right_clic
		function but.right_clic()
			if right_clic then right_clic() end
			if ca.flipped then return end
			resolve_unending_servitude()
			consume_pending_unending_swap()
		end
	end
end

--- CARDS

newsrf("disgraced_justice_cards","disgraced_justice_cards.png")

local function dj_tag_card(t, side_field, rarity_field)
	if extra_active then
		t[side_field] = 1
		t[rarity_field] = 1
	end
	return t
end

add(CARDS, dj_tag_card({
	gid=0, team=1, n=1, pwe=0, spsheet="disgraced_justice_cards",
	id="Stolen Scriptures",
	bishop_tempo=-1,
}, "isWhiteCard", "aa_rarity_s"))

add(CARDS, dj_tag_card({
	gid=1, team=1, n=1, pwe=0, spsheet="disgraced_justice_cards",
	id="Tainted Book",
	bishop_orth=1,
	bishop_cage=3,
	dj_tainted_flavor=1,
}, "isWhiteCard", "aa_rarity_s"))
lang["effect_dj_tainted_flavor"] = "\"Found its way back dripping with Sin\""

lang["effect_dj_sided"] = "Left click: change ability"
lang["effect_dj_sided_s"] = "Click to activate"

add(CARDS, dj_tag_card({
	gid=2, team=0, n=1, pwe=0, dj_sided_s=1, spsheet="disgraced_justice_cards",
	id="Disgraced Justice",
	dj_ability=1,
	disgraced_fake=1,
	click_not_if_ca_flipped_replace="Red Book: Summon",
}, "isBlackCard", "aa_rarity_uk"))

lang["effect_disgraced_fake"] = "Add the Black Bishop. On his death: you may lose him forever"

add(CARDS, dj_tag_card({
	gid=3, team=0, n=1, pwe=0, dj_sided=1, spsheet="disgraced_justice_cards",
	id="Red Book: Summon",
	dj_ability=1,
	dj_summon_desc=1,
	click_not_if_ca_flipped_replace="Red Book: Defect",
	played=get_stats("Disgraced Justice","played"),
	ignored=get_stats("Disgraced Justice","ignored"),
}, "isBlackCard", "aa_rarity_dh"))
lang["effect_dj_summon_desc"] = "Right click: summon a black piece near the Black Bishop (-"..DJ_SUMMON_COST.." Book Power)"

add(CARDS, dj_tag_card({
	gid=4, team=0, n=1, pwe=0, dj_sided=1, spsheet="disgraced_justice_cards",
	id="Red Book: Defect",
	dj_ability=1,
	dj_defect_desc=1,
	click_not_if_ca_flipped_replace="Red Book: Raise",
	played=get_stats("Disgraced Justice","played"),
	ignored=get_stats("Disgraced Justice","ignored"),
}, "isBlackCard", "aa_rarity_dh"))
lang["effect_dj_defect_desc"] = "Right click: convert a piece nearby the Black Bishop to your side (-"..DJ_DEFECT_COST.." Book Power)"

add(CARDS, dj_tag_card({
	gid=5, team=0, n=1, pwe=0, dj_sided=1, spsheet="disgraced_justice_cards",
	id="Red Book: Raise",
	dj_ability=1,
	dj_raise_desc=1,
	click_not_if_ca_flipped_replace="Red Book: Soul Split",
	played=get_stats("Disgraced Justice","played"),
	ignored=get_stats("Disgraced Justice","ignored"),
}, "isBlackCard", "aa_rarity_dh"))
lang["effect_dj_raise_desc"] = "Right click: resurrect all black pieces that died in the last 15 turns on their squares, if unoccupied (marked by graves) (-"..DJ_RAISE_COST.." Book Power)"

add(CARDS, dj_tag_card({
	gid=6, team=0, n=1, pwe=0, dj_sided=1, spsheet="disgraced_justice_cards",
	id="Red Book: Soul Split",
	dj_ability=1,
	dj_soul_split_desc=1,
	click_not_if_ca_flipped_replace="Red Book: Summon",
	played=get_stats("Disgraced Justice","played"),
	ignored=get_stats("Disgraced Justice","ignored"),
}, "isBlackCard", "aa_rarity_dh"))
lang["effect_dj_soul_split_desc"] = "Right click: spawn an allied Black King next to the Black Bishop.|On death: Possess the allied Black King (-"..DJ_SOUL_SPLIT_COST.." Book Power)"

add(CARDS, dj_tag_card({
	gid=8, team=0, n=1, pwe=(extra_active and 8 or 4), spsheet="disgraced_justice_cards",
	id="Vow of Fealty",
	fealty_desc=1,
	need=2,
}, "isBlackCard", "aa_rarity_uc"))

lang["effect_fealty_desc"] = "\"I shall be thine Right Hand until ends of time\"|Click this card while checked by a bishop: convert one checking bishop. Flip this card"

add(CARDS, dj_tag_card({
	gid=9, team=0, n=1, pwe=0, spsheet="disgraced_justice_cards",
	id="Unending Servitude",
	dj_unending_desc=1,
}, "isBlackCard", "aa_rarity_uk"))
lang["effect_dj_unending_desc"] = "\"His Vow binds us beyond death\"|Left click: don't let his soul go (returns next floor, his Hatred increases)|Right click: let his soul go|You must make a choice soon"

add(CARDS, dj_tag_card({
	gid=10, team=0, n=1, pwe=0, spsheet="disgraced_justice_cards",
	id="Repentance",
	dj_repentance_desc=1,
}, "isBlackCard", "aa_rarity_uk"))
lang["effect_dj_repentance_desc"] = "His soul is free at last"

add(CARDS, dj_tag_card({
	gid=11, team=0, n=1, pwe=0, spsheet="disgraced_justice_cards",
	id="Echoes",
	dj_echoes_desc=1,
}, "isBlackCard", "aa_rarity_uk"))
lang["effect_dj_echoes_desc"] = "His Hatred lingers"

--- PIECES

newsrf("disgraced_justice_pieces", "disgraced_justice_pieces.png")
newsrf("disgraced_justice_grave", "disgraced_justice_grave.png")
newsrf("disgraced_justice_sweat", "sweat.png")

local muppetbishop_typ = #PIECES

lang["piece_"..muppetbishop_typ] = "Bishop"
lang["short_piece_"..muppetbishop_typ] = "Bishop"

add(PIECES, {
	type=muppetbishop_typ, name="muppetbishop",
	hp=4, tempo=3,
	behavior={
		{ id="line",4,7,8, move=1, atk=1 },
		{ id="line",0,7,1,  move=1, atk=1 },
	},
	danger=3, seek="bdist", hdy=0,

	custom_dr=function(e,x,y,angle)
		spritesheet("disgraced_justice_pieces")
		sprgrid(17,16)
		if angle then
			aspr(0, x, y, angle)
		else
			spr(0, x, y)
		end
		spritesheet("gfx")

		if e.sq and abs(x-e.sq.x) < 2 and abs(y-e.sq.y) < 3 and bishop_is_threatened(e.sq) then
			spritesheet("disgraced_justice_sweat")
			sprgrid(19,12)
			spr(cyc(4,8), x-1, y-8)
			spritesheet("gfx")
		end
	end,
	custom_debris = function(p,x,y)
		spritesheet("disgraced_justice_pieces")
		sspr(0,17,8,8,x-4,y-4)
	end,
})

function bishop_is_threatened(sq)
	for bad in all(bads) do
		if tbl_has(get_range(bad, {atk=1}), sq) then return true end
	end
	return false
end

hatred_typ = #PIECES

lang["piece_"..hatred_typ] = "Hatred"
lang["short_piece_"..hatred_typ] = "Hatred"

add(PIECES, {
	type=hatred_typ, name="hatred",
	hp=6, tempo=3,
	behavior={
		{ id="line",4,7,8, move=1, atk=1 },
		{ id="line",0,7,1,  move=1, atk=1 },
	},
	danger=3, seek="bdist", hdy=0,

	custom_dr=function(e,x,y,angle)
		spritesheet("disgraced_justice_pieces")
		sprgrid(17,16)
		if angle then
			aspr(1, x, y, angle)
		else
			spr(1, x, y)
		end
		spritesheet("gfx")
	end,
	custom_debris = function(p,x,y)
		spritesheet("disgraced_justice_pieces")
		sspr(9,17,8,8,x-4,y-4)
	end,
})

lingering_hatred_typ = #PIECES

lang["piece_"..lingering_hatred_typ] = "Lingering Hatred"
lang["short_piece_"..lingering_hatred_typ] = "Echo"

add(PIECES, {
	type=lingering_hatred_typ, name="lingering_hatred",
	hp=4, tempo=3,
	behavior={
		{ id="line",4,7,8, move=1, atk=1 },
		{ id="line",0,7,1, move=1, atk=1 },
	},
	danger=3, seek="bdist", hdy=0,

	custom_dr=function(e,x,y,angle)
		spritesheet("disgraced_justice_pieces")
		sprgrid(17,16)
		if angle then
			aspr(2, x, y, angle)
		else
			spr(2, x, y)
		end
		spritesheet("gfx")
	end,
	custom_debris = function(p,x,y)
		spritesheet("disgraced_justice_pieces")
		sspr(18,17,8,8,x-4,y-4)
	end,
})


local function find_slot_card(id)
	for ca in all(get_slot_cards(true)) do
		if ca.id == id then return ca end
	end
	return nil
end

local function muppetbishop_alive()
	return muppetbishop_p and muppetbishop_p.sq and not muppetbishop_p.dead
end

local function has_dj_ability_card()
	for ca in all(get_slot_cards(true)) do
		if ca.dj_ability then return true end
	end
	return false
end

local function neighbor_squares(p)
	local sqs = {}
	for dx=-1,1 do
		for dy=-1,1 do
			if dx~=0 or dy~=0 then
				local sq = gsq(p.sq.px+dx, p.sq.py+dy)
				if sq then add(sqs,sq) end
			end
		end
	end
	return sqs
end

-- Piece types Summon can spawn (knight/bishop/rook)
local SUMMON_TYPES = {1,2,3}

-- Piece types Defect can't target
local DEFECT_EXCLUDED_TYPES = {[5]=true,[6]=true,[9]=true,[10]=true,[11]=true,[hatred_typ]=true,[lingering_hatred_typ]=true}

if extra_active then
	local EXTRA_DEFECT_IMMUNE_SET = {
		exfool=true, exmemorial=true, exrubble=true, exheir=true, exbody=true, exhead=true,
		exshade=true, hellmare=true, exhero=true, exmimic=true, exmimick=true, exmimicb=true,
		exmimicr=true, exmimicq=true, exfalsegod=true, exkitsune=true, exwisp=true,
		exstatue=true, exprophet=true, exdarkmoon=true, exlightmoon=true,
	}
	for pd in all(PIECES) do
		if EXTRA_DEFECT_IMMUNE_SET[pd.name] then
			DEFECT_EXCLUDED_TYPES[pd.type] = true
		end
	end
end

function dj_summon()
	if not muppetbishop_alive() then sfx("wrong") return end

	local free_sqs = {}
	for sq in all(neighbor_squares(muppetbishop_p)) do
		if is_free(sq) then add(free_sqs, sq) end
	end
	if #free_sqs == 0 then sfx("wrong") return end

	local sq = rnd(free_sqs)
	local typ = rnd(SUMMON_TYPES)
	local p = new_piece(typ, false, sq)
	fx_spawn(p)

	hero.book_power = hero.book_power - DJ_SUMMON_COST
end

function dj_defect()
	if not muppetbishop_alive() then sfx("wrong") return end

	local targets = {}
	for sq in all(neighbor_squares(muppetbishop_p)) do
		if sq.p and sq.p.bad and not DEFECT_EXCLUDED_TYPES[sq.p.type] then
			add(targets, sq.p)
		end
	end
	if #targets == 0 then sfx("wrong") return end

	local target = rnd(targets)
	convert(target, function() end)

	hero.book_power = hero.book_power - DJ_DEFECT_COST
end

function dj_soul_split()
	if not muppetbishop_alive() then sfx("wrong") return end

	local free_sqs = {}
	for sq in all(neighbor_squares(muppetbishop_p)) do
		if is_free(sq) then add(free_sqs, sq) end
	end
	if #free_sqs == 0 then sfx("wrong") return end

	local sq = rnd(free_sqs)
	local p = new_piece(5, false, sq) -- type 5 = king
	fx_spawn(p)

	hero.book_power = hero.book_power - DJ_SOUL_SPLIT_COST
end

function resolve_unending_servitude()
	if not has_card("Unending Servitude") then return end

	if hatred_count > 0 then
		local sac_list = {}
		local gain_list = {}
		for i=1,hatred_count do
			add(sac_list, hatred_typ)
			add(gain_list, lingering_hatred_typ)
		end
		add(upgrades, {sac=sac_list, gain=gain_list})

		lingering_hatred_count = lingering_hatred_count + hatred_count
		hatred_count = 0
		pending_unending_swap = "Echoes"
	else
		pending_unending_swap = "Repentance"
	end

	pending_tainted_book_swap = true
end

function consume_pending_unending_swap()
	if not pending_unending_swap then return end
	if has_card("Unending Servitude") then
		remove_buts()
		replace_card("Unending Servitude", pending_unending_swap, play)
	end
	pending_unending_swap = false
end

lang["stat_book_power"] = "Use it to activate the abilities of the Red Book.|*Each ability has a cost specified in its card|*Every turn: +1 Book Power|*Non-pawn white piece death: +1 Book Power|*Black Bishop move: +1 Book Power"

function edit_disp_stats(stats)
	if muppetbishop_alive() then
		add(stats, {id="book_power", name="Book Pow", value=""..(hero.book_power or 0)})
	end
end

local function spawn_grave_marker(sq)
	local e = mke(0, sq.x+11, sq.y)
	e.dr = function(e,x,y)
		spritesheet("disgraced_justice_grave")
		sprgrid(6,5)
		spr(0, x, y)
		spritesheet("gfx")
	end
	return e
end

function expire_all_graves()
	for grave in all(graves) do
		if grave.e then del(ents, grave.e) end
	end
	graves = {}
end

local function spawn_hatred_grave_marker(sq)
	local e = mke(0, sq.x, sq.y)
	e.dr = function(e,x,y)
		local list = hatred_graves[sq]
		if not list or #list == 0 then return end

		local imminent = false
		for rec in all(list) do
			if rec.imminent then imminent = true end
		end

		spritesheet("disgraced_justice_grave")
		sprgrid(6,5)
		spr(imminent and 2 or 1, x, y)
		spritesheet("gfx")
	end
	return e
end

function expire_all_hatred_graves()
	for sq in all(hatred_grave_squares) do
		if hatred_grave_markers[sq] then del(ents, hatred_grave_markers[sq]) end
	end
	hatred_graves = {}
	hatred_grave_markers = {}
	hatred_grave_squares = {}
end

local function process_hatred_graves()
	for sq in all(hatred_grave_squares) do
		local list = hatred_graves[sq]

		for rec in all(list) do
			rec.imminent = ((mode.turns or 0) - rec.turn) >= 7
		end

		local revived = false
		for rec in all(list) do
			if not revived and (mode.turns or 0) - rec.turn >= 8 and is_free(sq) then
				local p = new_piece(hatred_typ, true, sq)
				p.c_raise = 60
				del(list, rec)
				revived = true
				remove_buts()
				wait(5, play)
				break
			end
		end

		if #list == 0 then
			hatred_graves[sq] = nil
			if hatred_grave_markers[sq] then del(ents, hatred_grave_markers[sq]) end
			hatred_grave_markers[sq] = nil
			del(hatred_grave_squares, sq)
		end
	end
end

function on_piece_move(p)
	if p == muppetbishop_p then
		hero.book_power = (hero.book_power or 0) + 1
	end
end

function on_bad_death(p)
	if p.bad then
		if p.type ~= 0 then
			hero.book_power = (hero.book_power or 0) + 1
		end

		if p.type == hatred_typ then
			local sq = get_square_at(p.x, p.y)
			if sq then
				if not hatred_graves[sq] then
					hatred_graves[sq] = {}
					hatred_grave_markers[sq] = spawn_hatred_grave_marker(sq)
					add(hatred_grave_squares, sq)
				end
				add(hatred_graves[sq], {turn=mode.turns, imminent=false})
			end
		end

		return
	end

	if p == muppetbishop_p then
		expire_all_graves()

		for ca in all(get_slot_cards(true)) do
			if ca.dj_ability then
				replace_card(ca.id, "Unending Servitude")
				break
			end
		end

		muppetbishop_p = nil
		return
	end

	if not muppetbishop_alive() then return end

	local sq = get_square_at(p.x, p.y)
	if not sq then return end

	for old_grave in all(graves) do
		if old_grave.sq == sq then 
			if old_grave.e then del(ents, old_grave.e) end
			del(graves, old_grave)
			break
		end
	end

	local grave = {sq=sq, type=p.type, turn=mode.turns}
	grave.e = spawn_grave_marker(sq)
	add(graves, grave)
end

local function expire_graves()
	for grave in all(graves) do
		if (mode.turns or 0) - grave.turn >= 15 then
			if grave.e then del(ents, grave.e) end
			del(graves, grave)
		end
	end
end

function dj_raise()
	if not muppetbishop_alive() then sfx("wrong") return end
	if #graves == 0 then sfx("wrong") return end

	for grave in all(graves) do
		if is_free(grave.sq) then
			local p = new_piece(grave.type, false, grave.sq)
			p.c_raise = 60
		end
		if grave.e then del(ents, grave.e) end
	end
	graves = {}

	hero.book_power = hero.book_power - DJ_RAISE_COST
end

local function fx_strike(p)
	screen_shake(4)
	fx_red_flash()

	local e = mke(0, p.x+8, p.y+10)

	local a = {}
	local x,y = e.x, e.y
	local ec = 8
	while y > -32 do
		add(a,{x=x,y=y})
		x = x + hrnd(ec)
		y = y - 8 - rnd(16+ec)
		ec = ec*1.5
	end
	e.life = 10
	e.dp = DP_FX
	e.dr = function(e,x,y)
		for p in all(a) do
			line(x,y,p.x,p.y,sget(e.life,1))
			x,y = p.x,p.y
		end
	end

	for i=0,8 do
		local e = mke(0, e.x, e.y)
		impulse(e, rnd(1), 2)
		e.frict = .75+rnd(.23)
		e.life = 8+rnd(32)
		e.vz = -rnd(3)
		e.we = rnd(.05)
		e.dr = function(e,x,y)
			pset(x,y,5)
		end
		e.drs = function()
			local x,y = e.x,e.y
			pset(x,y,bright(pget(x,y),-1))
		end
	end

	rumble(0, 0.4, 0.75, 0.12)
end

local function update_codex()
	for ca in all(CARDS) do
		if ca.dj_ability then
			ca.played = 1
			ca.ignored = 0
		end
	end
end

function on_new_turn()
	if hero.book_power then
		hero.book_power = hero.book_power + 1
	end

	expire_graves()
	process_hatred_graves()

	if (mode.turns or 0) ~= 0 then return end

	if has_dj_ability_card() then
		local sq = gsq(hero.sq.px+1, hero.sq.py)
		if not sq then return end
		hero.book_power = 0
		local p = new_piece(muppetbishop_typ, false, sq)
		muppetbishop_p = p
		fx_spawn(p)
		if extra_active then sfx("spawn") end --- why is this needed with Extra???
		remove_buts()
		wait(5, play)
	end

	local red_book = find_slot_card(RED_BOOK_ID)
	local vow = find_slot_card("Vow of Fealty")
	if not (red_book and vow) then return end

	local bishops = get_pieces(2)
	if #bishops == 0 then return end

	local sq = gsq(hero.sq.px+1, hero.sq.py)
	if not sq then return end

	local target = rnd(bishops)

	add_event(function()
		wait(30, function()
			fx_strike(target)
			target.bad = false
			setup_piece(target)
			sfx("bishop_resist")
		end)

		wait(100, function() fx_ascend(target) end)

		wait(150, function() 
			replace_card("Vow of Fealty", "Disgraced Justice")
			replace_card(RED_BOOK_ID, "Stolen Scriptures")
			update_codex()
			hero.book_power = 0
		end)
		wait(260, function ()
			local p = new_piece(muppetbishop_typ, false, sq)
			muppetbishop_p = p
			fx_spawn(p)
			if extra_active then sfx("spawn") end --- for some reason Extra needs this
			remove_buts()
			wait(5, play)
			event_nxt()
		end)
	end)
end

prepend("fx_crumb", function(p, i) 
	if p.type==hatred_typ then
		p.bad = false
		setup_piece(p)
	end
end)

append("fx_crumb", function(p, i) 
	if p.type==hatred_typ then
		p.bad = true
		setup_piece(p)
	end
end)