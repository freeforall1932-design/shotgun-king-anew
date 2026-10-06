-- Code here will affect the whole game, including changes from other mods.

-- Loading and writing files is authorized but only within your mod's folder. Paths should be relative to the mod folder.

-- These will replace the vanilla game's surfaces. If multiple mods do this for the same surfaces, only the last one loaded will take effect. Here we're doing it to give the Black King a moustache.
newsrf("title_sfps", "title_sfps.png")
newsrf("gfx_sfps", "gfx_sfps.png")

-- Make sure your mod's unique surfaces have unique names so they don't unintentionally replace each other.
newsrf("fairy_cards", "cards_fairys.png")
newsrf("fairy_pieces", "pieces_fairys.png")

-- You may create a save bank for your mod with this function:
-- newbnk(128,64,4)
-- It acts as a grid where you can set and retrieve values with bset and bget respectively.
-- 128 and 64 are the dimensions of that bank, 4 is the depth which defines how big numbers can be in this bank. A depth of 1 means numbers above 255 cannot be stored in this bank. In doubt, set it to 4, it's the maximum value and it allows numbers up to 4,294,967,295. Banks cannot store negative values however.
-- You can save your bank to a file in the player's save folder by calling savbnk(). Each mod gets one bank and a corresponding save file.

-- This is a simple utility function which adds a table's content into another table.
function add_content(tbl, new_content)
	for _,v in ipairs(new_content) do
		add(tbl, v)
	end
end

function _log_tbl(tbl, max_iter)
	if (max_iter) then
		_log(str_tbl(tbl, 0, max_iter))
	else
		_log(str_tbl(tbl, 0, 6))
	end
end

function str_tbl(tbl, iter, maxiter)
	local tbl_str = "{ "
	local key_typ
	for k, v in pairs(tbl) do
		if type(k) == "table" then
			key_typ = "[table]"
		else
			key_typ = k
		end
		if type(v) == "table" and iter < maxiter then
			tbl_str = tbl_str..key_typ.."="..str_tbl(v, iter+1, maxiter)..", "
		elseif type(v) == "number" or type(v) == "string" then
			tbl_str = tbl_str..key_typ.."="..v..", "
		else
			tbl_str = tbl_str..key_typ.."=["..type(v).."], "
		end
	end
	tbl_str = tbl_str.." }"
	return tbl_str
end

function add_bsq(e, sq, m, a)
	local x, y
	if m == nil then
		m = 1
	end
	if a == nil then
		a = 1
	end
	if not e.sq then
		x, y = hero.sq.px, hero.sq.py
	else
		x, y = e.sq.px, e.sq.py
	end
	if (sq) then
		add(e.behavior, {id="jump", move=m, atk=a, sq.px - x, sq.py - y})
	end
end

centaur_orth_val = 0

-- Adding a custom piece.
centaur_typ = #PIECES
lang["piece_"..centaur_typ] = "Centaur"
lang["short_piece_"..centaur_typ] = "Centar"

add(PIECES, {type=centaur_typ,
	name="centaur", hp=3, tempo=3, danger=6, orth=0, seek="wdist",
	give_soul=true, hdy=1,
	behavior={
		{ id="line",0,7,1,  move=1, atk=1 },
		{ id="jump", move=1, atk=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 3 or 2, x, y)
	end
})

archbishop_typ = #PIECES
lang["piece_"..archbishop_typ] = "Archbishop"
lang["short_piece_"..archbishop_typ] = "Archbs"

add(PIECES, {type=archbishop_typ,
	name="archbishop", hp=4, tempo=3, danger=6, seek="kdist",
	give_soul=true, hdy=1,
	behavior={
		{ id="line",4,7,8,  move=1, atk=1 },
		{ id="jump", move=1, atk=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 5 or 4, x, y)
	end
})

chancellor_typ = #PIECES
lang["piece_"..chancellor_typ] = "Chancellor"
lang["short_piece_"..chancellor_typ] = "Chanc"

add(PIECES, {type=chancellor_typ,
	name="chancellor", hp=4, tempo=3, danger=6, seek="rdist",
	give_soul=true, hdy=1,
	behavior={
		{ id="line",0,3,8,  move=1, atk=1 },
		{ id="jump", move=1, atk=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 7 or 6, x, y)
	end
})

amazon_typ = #PIECES
lang["piece_"..amazon_typ] = "Amazon"
lang["short_piece_"..amazon_typ] = "Amazon"

add(PIECES, {type=amazon_typ,
	name="amazon", hp=2, tempo=5, danger=9, seek="wdist",
	give_soul=true, hdy=2,
	behavior={
		{ id="line",0,7,8,  move=1, atk=1 },
		{ id="jump", move=1, atk=1, 2,-1,2,1, 1,2,-1,2, -2,-1,-2,1, -1,-2,1,-2 }
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 9 or 8, x, y)
	end
})

commoner_typ = #PIECES
lang["piece_"..commoner_typ] = "Commoner"
lang["short_piece_"..commoner_typ] = "Common"

add(PIECES, {type=commoner_typ,
	name="commoner", hp=3, tempo=3, danger=3, seek="wdist",
	give_soul=true, hdy=2,
	behavior={
		{ id="line",0,7,1,  move=1, atk=1 },
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 11 or 10, x, y)
	end
})

gryphon_typ = #PIECES
lang["piece_"..gryphon_typ] = "Gryphon"
lang["short_piece_"..gryphon_typ] = "Gryphn"

add(PIECES, {type=gryphon_typ,
	name="gryphon", hp=4, tempo=4, danger=9, seek="rdist",
	give_soul=true, hdy=0, cus_move=true,
	behavior={
		{ id="offset",0,1,8, move=1, atk=1, off={1,1}},
		{ id="offset",1,2,8, move=1, atk=1, off={-1,1}},
		{ id="offset",2,3,8, move=1, atk=1, off={-1,-1}},
		{ id="offset",0,0,8, move=1, atk=1, off={1,-1}},
		{ id="offset",3,3,8, move=1, atk=1, off={1,-1}},
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 13 or 12, x, y)
	end,
	custom_move_dr2 = function(x,y)
		spritesheet("fairy_pieces")
		spr(30, x, y, 2, 2)
	end
})

prince_typ = #PIECES
lang["piece_"..prince_typ] = "Prince"
lang["short_piece_"..prince_typ] = "Prince"

add(PIECES, {type=prince_typ,
	name="prince", hp=6, tempo=4, danger=6, seek="wdist",
	give_soul=false, hdy=0,
	behavior={
		{ id="line",0,7,1,  move=1, atk=1 },
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 15 or 14, x, y)
	end
})

banner_typ = #PIECES
lang["piece_"..banner_typ] = "Banner"
lang["short_piece_"..banner_typ] = "Banner"

add(PIECES, {type=banner_typ,
	name="banner", hp=6, tempo=99, danger=6, seek="wdist",
	give_soul=false, hdy=0,
	behavior={},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 17 or 16, x, y)
	end,
	custom_move_dr2 = function(x,y)
		spritesheet("fairy_pieces")
		spr(34, x, y, 2, 2)
	end
})

-- Random pieces
-- OFFSET moves
manticore_typ = #PIECES
lang["piece_"..manticore_typ] = "Manticore"
lang["short_piece_"..manticore_typ] = "Mnticr"

add(PIECES, {type=manticore_typ,
	name="manticore", hp=5, tempo=4, danger=9, seek="bdist",
	give_soul=true, hdy=0, cus_move=true,
	behavior={
		{ id="offset",4,5,8,  move=1, atk=1, off={0,1} },
		{ id="offset",5,6,8,  move=1, atk=1, off={-1,0} },
		{ id="offset",6,7,8,  move=1, atk=1, off={0,-1} },
		{ id="offset",7,7,8,  move=1, atk=1, off={1,0} },
		{ id="offset",4,4,8,  move=1, atk=1, off={1,0} },
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 1 or 0, x, y)
	end
})

-- SEQ moves
nightrider_typ = #PIECES
lang["piece_"..nightrider_typ] = "Nightrider"
lang["short_piece_"..nightrider_typ] = "NitRdr"

add(PIECES, {type=nightrider_typ,
	name="nightrider", hp=4, tempo=5, danger=6, seek="kdist",
	give_soul=true, hdy=0, cus_move=true,
	behavior={
		{ id="seq", move=1, atk=1, 1,2, 2,4, 3,6, 4,8 },
		{ id="seq", move=1, atk=1, 2,1, 4,2, 6,3, 8,4 },
		{ id="seq", move=1, atk=1, 2,-1, 4,-2, 6,-3, 8,-4 },
		{ id="seq", move=1, atk=1, 1,-2, 2,-4, 3,-6, 4,-8 },
		{ id="seq", move=1, atk=1, -1,-2, -2,-4, -3,-6, -4,-8 },
		{ id="seq", move=1, atk=1, -2,-1, -4,-2, -6,-3, -8,-4 },
		{ id="seq", move=1, atk=1, -2,1, -4,2, -6,3, -8,4 },
		{ id="seq", move=1, atk=1, -1,2, -2,4, -3,6, -4,8 },
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 1 or 0, x, y)
	end
})

-- CUSTOM with jump combo
minknight_typ = #PIECES
lang["piece_"..minknight_typ] = "Mino Knight"
lang["short_piece_"..minknight_typ] = "MinKni"

add(PIECES, {type=minknight_typ,
	name="minknight", hp=4, tempo=4, danger=3, seek="wdist",
	give_soul=true, hdy=0, cus_move=true,
	behavior={
		{ id="offset",4,5,8, move=1, atk=1, off={0,1}},
		{ id="jumpc", move=1, atk=1, -2,-1, -1,-2, 1,-2, 2,-1},
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 1 or 0, x, y)
	end
})

-- CUSTOM with line combo
hydra_typ = #PIECES
lang["piece_"..hydra_typ] = "Hydra"
lang["short_piece_"..hydra_typ] = "Hydra"

add(PIECES, {type=hydra_typ,
	name="hydra", hp=1, tempo=4, danger=15, seek="rdist",
	give_soul=true, hdy=0, cus_move=true,
	behavior={
		{ id="offset",0,1,8, move=1, atk=1, off={1,1}},
		{ id="offset",1,2,8, move=1, atk=1, off={-1,1}},
		{ id="offset",2,3,8, move=1, atk=1, off={-1,-1}},
		{ id="offset",0,0,8, move=1, atk=1, off={1,-1}},
		{ id="offset",3,3,8, move=1, atk=1, off={1,-1}},
		{ id="line",0,3,8, move=1, atk=1}
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 1 or 0, x, y)
	end
})

-- OFFSET with long off
longg_typ = #PIECES
lang["piece_"..longg_typ] = "Long Gryphon"
lang["short_piece_"..longg_typ] = "LGryph"

add(PIECES, {type=longg_typ,
	name="longg", hp=4, tempo=4, danger=9, seek="rdist",
	give_soul=true, hdy=0, cus_move=true,
	behavior={
		{ id="offset",0,1,8, move=1, atk=1, off={1,1, 2,2}},
		{ id="offset",1,2,8, move=1, atk=1, off={-1,1, -2,2}},
		{ id="offset",2,3,8, move=1, atk=1, off={-1,-1, -2,-2}},
		{ id="offset",0,0,8, move=1, atk=1, off={1,-1, 2,-2}},
		{ id="offset",3,3,8, move=1, atk=1, off={1,-1, 2,-2}},
	},
	custom_dr = function(e,x,y,angle)
		spritesheet("fairy_pieces")
		spr(e.iron and 1 or 0, x, y)
	end
})

local tbl = gimme("global") -- "replaceable" -- "forbidden" --"autocall"
for k in all(tbl) do
    -- _log(k) -- _log prints stuff in the log file
end

function test_banner(e, sq) 
	local x,y
	if (sq) then
		x,y = sq.px, sq.py
	else
		x,y = e.sq.px, e.sq.py
	end
	local pc_sq
	for xx=-1,1 do
		for yy=-1,1 do
			if xx~=0 or yy~=0 then
				if (gsq(x+xx, y+yy)) then
					pc_sq=gsq(x+xx, y+yy)
					if (pc_sq.p ~= nil) then
						if (pc_sq.p.type == banner_typ) then
							e.banner=true
							return
						end
					end
				end
			end
		end
	end
end

prepend("on_death", function(e)
	local boss_found = false
	local heir_found = false
	local no_royal_enabled = stack.ruler == 1 or stack.ruler == 2
	for piece in all(bads) do
		if (piece.type == 6) then
			boss_found = true
		end
		if (piece.heir) then
			heir_found = true
		end
	end
	local royal_piece = (no_royal_enabled and stack.ruler) or 5
	if not boss_found then
		if not heir_found then
			if (e.type == royal_piece) then
				for piece in all(bads) do
					if (piece.type == prince_typ and #get_pieces(royal_piece) == 0) then
						piece.type = royal_piece
						break
					end
				end
			end
		end
	end
	if (e.type == banner_typ) then
		for piece in all(bads) do
			if (piece.can_banner) then
				piece.banner = false
				piece.behavior = piece.defbe
			end
		end
	end
end, "some_fairy_pieces:test_prnc")

append("setup_piece",function(e)
	local ruler
	if (get_leader_name() == "king") then
		ruler = 5
	elseif(get_leader_name() == "bishop") then
		ruler = 2
	elseif(get_leader_name() == "knight") then
		ruler = 1
	end
	if (e.banner == nil) then
		e.banner = false
	end
	if (e.can_banner == nil) then
		e['can_banner'] = true
	end
	if (e.type == 0 or e.type == 4 or e.type == 6 or e.type == banner_typ or e.type == ruler) then
		e['can_banner'] = false
	end
	if (e.turret) then
		e['can_banner'] = false
	end
	if (e.type == centaur_typ) then
		centaur_orth_val = e.orth
	end
	if (e.defbe == nil) then
		e.defbe = e.behavior
	end
end, "some_fairy_pieces:banner")

prepend("new_turn", function ()
	for piece in all(bads) do
		if (piece.can_banner) then
			test_banner(piece)
		end
	end
end, "some_fairy_pieces:new_tn")

function checksq(x, y, e, ss, m, a)
	if ss == nil then
		ss = e.sq
	end
	xx2 = ss.px + x
	yy2 = ss.py + y
	if (gsq(xx2, yy2)) then
		sq = gsq(xx2, yy2)
	else
		return false
	end
	if(sq.moat and not ss.moat) then
		add_bsq(e, sq, m, a)
		if e.flying then
			return true
		end
		return false
	elseif (sq.p == nil or sq.p == hero) then
		add_bsq(e, sq, m, a)
		return true
	else
		if e.flying then
			add_bsq(e, sq, m, a)
			return true
		end
		return false
	end
end

hop_squares = {}

function check_hop(x, y, e, ss, x2, y2)
	local xx1 = ss.px + x
	local yy1 = ss.py + y
	local xx2 = ss.px + x2
	local yy2 = ss.py + y2
	if (gsq(xx1, yy1) and gsq(xx2, yy2)) then
		sq1 = gsq(xx1,yy1)
		sq2 = gsq(xx2,yy2)
	else
		return
	end
	if (sq1.p and sq1.p ~= hero) then
		add(hop_squares, sq2)
		add_bsq(e, sq2)
		sq2["hop_trg"] = sq1.p
	end
end

function clear_hops()
	for hs in all(hop_squares) do
		if (hs.hop_trg) then
			hs.hop_trg = nil
		end
	end
	hop_squares = {}
end

function shallow_copy(tbl)
	a = {}
	for k, v in pairs(tbl) do
		a[k] = v
	end
	return a
end

function mod_range(e, sq, hero_check)
	if sq == nil then
		sq = e.sq
	end
	hero_check = hero_check and stack.hop
	for beh in all(e.behavior) do
		-- Line move offsetted by a sequence of moves
		if (beh.id == "offset") then
			dirs = {1,0, 0,1, -1,0, 0,-1, 1,1, -1,1, -1,-1, 1,-1}
			lin_start = true
			dummy_piece = {sq = sq, flying = e.flying, behavior = {}}
			spos = {0, 0}
			lstart = beh[1] * 2 + 2
			lfin = beh[2] * 2 + 2
			max_r = min(e.cage or beh[3], beh[3]) - 1
			for i = 2, #beh.off, 2 do
				if not checksq(beh.off[i - 1], beh.off[i], dummy_piece, sq, beh.move, beh.atk) then
					lin_start = false
					break
				end
				spos = {beh.off[i - 1], beh.off[i]}
			end
			if (hero_check and beh.move) then
				local j = #beh.off
				if #beh.off >= 4 then
					check_hop(beh.off[j - 3], beh.off[j - 2], e, sq, beh.off[j - 1], beh.off[j])
				end
				for i = lstart, lfin, 2 do
					check_hop(beh.off[j - 1], beh.off[j], e, sq, beh.off[j - 1] + dirs[i-1], beh.off[j] + dirs[i])
				end
			end
			if (lin_start) then
				checksq(spos[1], spos[2], e, sq, beh.move, beh.atk)
				for i = lstart, lfin, 2 do
					xx,yy = spos[1], spos[2]
					xxx = dirs[i-1]
					yyy = dirs[i]
					for j = 1, max_r do
						xx = xx + xxx
						yy = yy + yyy
						if (hero_check and beh.move) then
							check_hop(xx, yy, e, sq, xx + xxx, yy + yyy)
						end
						if not checksq(xx, yy, e, sq, beh.move, beh.atk) then
							break
						end
					end
				end
			end
		-- Sequence of moves
		elseif (beh.id == "seq") then
			range = min(e.cage or #beh / 2, #beh / 2) * 2
			for i = 2, range, 2 do
				if (hero_check and beh.move) then
					if i <= range - 2 then
						check_hop(beh[i - 1], beh[i], e, sq, beh[i + 1], beh[i + 2])
					end
				end
				if not checksq(beh[i - 1], beh[i], e, sq, beh.move, beh.atk) then
					break
				end
			end
		-- Jump moves for custom pieces using the previous sets, will not be deleted after get_range()
		elseif (beh.id == "jumpc") then
			beh2 = shallow_copy(beh)
			beh2.id = "jump"
			add(e.behavior, beh2)
		end
	end
end

function clear_range(e)
	dellist = {}
	if (e.behavior) then
		for k, beh in pairs(e.behavior) do
			if (beh.id == "jump") then
				add(dellist, k)
			end
		end
		for l = #dellist, 1, -1 do
			deli(e.behavior, dellist[l])
		end
	end
end

prepend("get_range", function(e, b)
	-- Custom behavior
	-- If a piece has "cus_move=true", then use the following move defs, then delete all "jump" moves after move calculation
	if (e.cus_move and e.behavior) then
		mod_range(e)
	end

	if (b == "move") then
		if (e == hero and e.sq) then
			for piece in all(PIECES) do
				if (piece.behavior and piece.cus_move) then
					mod_range(piece, e.sq, true)
				end
			end
		end
	end
	if (e.banner) then
		e.behavior = {{id="line",0,7,8,move=1,atk=1}}
	end
	if (centaur_orth_val == 1 and e.type == centaur_typ) then
		if (e.behavior[3] == nil) then
			add(e.behavior, { id="line",0,3,8,  move=1 })
		end
	end
end, "some_fairy_pieces:gr")

append("get_range", function(e, b)
	if (e.cus_move and e.behavior) then
		clear_range(e)
	end
	if (b == "move") then
		if (e == hero and e.sq) then
			for piece in all(PIECES) do
				if (piece.behavior and piece.cus_move) then
					clear_range(piece)
				end
			end
		end
	end
end, "some_fairy_pieces:gr2")

append("spend_hop", function()
	-- clear_hops()
	for sq in all(hop_squares) do
		_log(sq.hop_trg)
	end
end, "some_fairy_pieces:spendhop")

prepend("goto_sq", function (e, sq)
	if (e.banner ~= nil) then
		e.banner = false
		e.behavior = e.defbe
	end
	if e.can_banner then
		test_banner(e, sq)
	end
end, "some_fairy_pieces:gt_sq")

prepend("dr_movemap", function(e,x,y)
	if e.custom_move_dr2 then
		if e.banner then
			spritesheet("fairy_pieces")
			spr(54, x, y, 2, 2)
		else
			print(e.custom_move_dr2(x,y))
		end
		spritesheet("gfx_sfps")
	end
end, "some_fairy_pieces:dmm")

-- You may retrieve a list of the global variable names in use inside the game's code at any moment with this function.
local tbl = gimme("global")
-- You may also use this function with "replaceable" and "forbidden" to get lists of replaceable and forbidden variable names respectively. Use it with Autocall and you will get a list of function names you may use in your mod's game modes, if you do they will be called automatically by the game.
for k in all(tbl) do
	-- _log prints stuff in the log file
	-- _log(k)
end


-- Some example code to remove a specific card from the pre-existing set.
--for i,ca in ipairs(CARDS) do
--	-- Removes Black Mist from the original cards
--	if ca.id == "Black Mist" then
--		deli(CARDS, i)
--		break
--	end
--end

-- Adding new custom cards.
local new_cards = {
	{ gid=10, spsheet="fairy_cards", team=1, n=1, id="Test F", sac = {0, 0, 0, 0, 0, 0, 1, 2, 3}, gain={manticore_typ, nightrider_typ, minknight_typ, hydra_typ, longg_typ}, firerange=4, hop=5 },
	-- Centaur type
	{ gid=10, spsheet="fairy_cards", team=1, n=1, id="Strongest of Knights", need={1, 1}, sac={1}, gain={centaur_typ}, knight_hp=-1},
	{ gid=11, spsheet="fairy_cards", team=1, id="The Jumpers", need={4}, sac={4}, gain={centaur_typ, centaur_typ}, centaur_tempo=1, centaur_hp=1},
	{ gid=12, spsheet="fairy_cards", team=1, pwe=5, n=1, id="Knightage", need={archbishop_typ, 2}, sac={archbishop_typ, 2}, gain={centaur_typ, 1}, knight_hp=1},
	{ gid=13, spsheet="fairy_cards", team=1, n=2, id="Wall Builder", need={centaur_typ}, sac={centaur_typ}, gain={3}, rook_hp=2},
	{ gid=14, spsheet="fairy_cards", team=1, pwe=3, id="Chaotic Entrance", gain={centaur_typ}, pawn_hp=-1, knight_hp=-1, leader_hp=-1},
	{ gid=15, spsheet="fairy_cards", team=1, pwe=5, n=1, id="The Four Horsemen", need={1, 1, 2, 2, 3, 3, 4}, sac={1, 1, 2, 2, 3, 3, 4}, gain={centaur_typ, archbishop_typ, chancellor_typ, amazon_typ}, amazon_hp=1},
	{ gid=16, spsheet="fairy_cards", team=1, n=1, id="Mythology", need={gryphon_typ}, sac={gryphon_typ}, gain={centaur_typ, 1, 2}, bishop_hp=-1},
	{ gid=17, spsheet="fairy_cards", team=1, need={centaur_typ}, id="Pathways", centaur_orth=1, soul_slot=1},
	-- Archbishop type
	{ gid=18, spsheet="fairy_cards", team=1, n=1, id="Vatican", need={2, 2}, sac={2}, gain={archbishop_typ}, bishop_hp=-1},
	{ gid=19, spsheet="fairy_cards", team=1, pwe=5, n=1, id="The Church", need={centaur_typ, 1}, sac={centaur_typ, 1}, gain={archbishop_typ, 2}},
	{ gid=20, spsheet="fairy_cards", team=1, n=1, id="Archpriest", need={archbishop_typ}, archbishop_healer=3},
	{ gid=21, spsheet="fairy_cards", team=1, id="Atheism", need={archbishop_typ}, sac={archbishop_typ}, gain={3, 3}},
	{ gid=22, spsheet="fairy_cards", team=1, pwe=3, id="Dragon's Breath", gain={archbishop_typ}, bishop_hp=-1, rook_hp=-1, leader_hp=-1},
	{ gid=23, spsheet="fairy_cards", team=1, id="Book of Everything", gain={2, archbishop_typ}, spread=-20, firerange=1},
	-- Chancellor type
	{ gid=24, spsheet="fairy_cards", team=1, n=1, id="Towering Knight", need={3, 3}, sac={3}, gain={chancellor_typ}, rook_tempo=1},
	{ gid=25, spsheet="fairy_cards", team=1, pwe=3, id="Chigorin", need={4}, sac={4}, gain={chancellor_typ, 1}},
	{ gid=26, spsheet="fairy_cards", team=1, id="Knook", need={1, 3}, sac={1, 3}, gain={0, 0, chancellor_typ}, pawn_tempo=-1},
	{ gid=27, spsheet="fairy_cards", team=1, id="Piece Splitter", need={centaur_typ}, sac={centaur_typ}, gain={chancellor_typ}, knight_hp=1},
	{ gid=28, spsheet="fairy_cards", team=1, id="Unknightly", gain={3}, knight_hp=-1, archbishop_hp=-1, chancellor_hp=-1},
	{ gid=29, spsheet="fairy_cards", team=1, pwe=3, id="Heaviest Knight", gain={chancellor_typ}, delay=25, cycle=1},
	-- Amazon type
	{ gid=30, spsheet="fairy_cards", team=1, n=1, id="Queen of the Night", need={4, 4}, sac={4}, gain={amazon_typ}, amazon_hp=1, queen_hp=-1},
	{ gid=31, spsheet="fairy_cards", team=1, n=1, id="Fusion Power", need={3, 2, 1}, sac={3, 2, 1}, gain={amazon_typ}, all_hp=1, amazon_hp=1},
	{ gid=32, spsheet="fairy_cards", team=1, pwe=3, id="Spare Crown", need={1, 0, 0, 0}, sac={1, 0, 0, 0}, gain={amazon_typ}},
	{ gid=33, spsheet="fairy_cards", team=1, n=1, id="Lion Cage", need={1}, sac={1}, gain={amazon_typ}, amazon_cage=2, amazon_tempo=-1},
	{ gid=34, spsheet="fairy_cards", team=1, pwe=4, id="Stampede", need={amazon_typ}, sac={amazon_typ}, gain={1, 1, 1, 1, 1, 1}, delay=15},
	{ gid=35, spsheet="fairy_cards", team=1, n=1, id="Glass Cannons", gain={amazon_typ, amazon_typ}, amazon_hp=-1, delay=20},
	-- Commoner type
	{ gid=36, spsheet="fairy_cards", team=1, n=1, id="Working Class", need={0, 0}, sac={0}, gain={commoner_typ}, spread=15},
	{ gid=37, spsheet="fairy_cards", team=1, id="Peasants", need={0, 0, 0, 0}, sac={0, 0, 0}, gain={commoner_typ, commoner_typ}},
	{ gid=38, spsheet="fairy_cards", team=1, pwe=3, id="Invasion", need={1, 2}, sac={1, 2}, gain={commoner_typ, 0, 0, 0, 0, 0}},
	{ gid=39, spsheet="fairy_cards", team=1, id="Farmlands", need={2, 3}, sac={2, 3}, gain={0, 0, commoner_typ, commoner_typ, commoner_typ}},
	{ gid=40, spsheet="fairy_cards", team=1, n=3, id="Royal Gates", need={commoner_typ}, sac={commoner_typ}, gain={1, 2}},
	{ gid=41, spsheet="fairy_cards", team=1, id="Powder Thief", need={commoner_typ}, sac={commoner_typ}, gain={4}, firepower=1},
	{ gid=42, spsheet="fairy_cards", team=1, pwe=3, id="Log Cabin", gain={commoner_typ}, banner_hp=-1},
	-- Gryphon type
	{ gid=43, spsheet="fairy_cards", team=1, n=1, id="Occupied", need={3, 3}, sac={3}, gain={gryphon_typ}, leader_hp=-1},
	{ gid=44, spsheet="fairy_cards", team=1, id="Joyride", need={0, 0, 0, 0, 0, 0, 0}, sac={0, 0, 0, 0, 0, 0}, gain={gryphon_typ}},
	{ gid=45, spsheet="fairy_cards", team=1, n=1, id="Lord Phoenix", need={3, 4}, sac={3, 4}, gain={gryphon_typ}, gryphon_hp=10, gryphon_tempo=-1, delay=10},
	{ gid=46, spsheet="fairy_cards", team=1, pwe=3, id="Twin Rooks", need={gryphon_typ}, sac={gryphon_typ}, gain={3, 3}, rook_tempo=-1, king_hp=1},
	{ gid=47, spsheet="fairy_cards", team=1, pwe=3, id="Collapse", need={3}, sac={3}, gain={0, 0, gryphon_typ}, gryphon_tempo=1, pawn_tempo=1},
	{ gid=48, spsheet="fairy_cards", team=1, pwe=2, id="Reinforced Towers", rook_hp=1, rook_tempo=-1, chancellor_hp=1, queen_hp=1, gryphon_hp=1},
	{ gid=49, spsheet="fairy_cards", team=1, id="Bird's Nest", gain={gryphon_typ}, gryphon_hp=-1, rook_hp=-1, rook_tempo=1},
	-- Prince type
	{ gid=50, spsheet="fairy_cards", team=1, n=1, id="Brave Heir", need={0, 0, 0, 0, 0}, sac={0, 0, 0, 0}, gain={prince_typ}, pawn_tempo=-1},
	{ gid=51, spsheet="fairy_cards", team=1, id="This is SPARTA", need={4}, sac={4}, gain={prince_typ, archbishop_typ}},
	{ gid=52, spsheet="fairy_cards", team=1, id="Grounded", need={prince_typ}, sac={prince_typ}, gain={1, 1}, king_tempo=-1},
	{ gid=53, spsheet="fairy_cards", team=1, n=1, id="King me", need={prince_typ}, prince_hp=2, commoner_hp=1},
	{ gid=54, spsheet="fairy_cards", team=1, n=1, id="Guards Out", need={prince_typ}, sac={prince_typ}, gain={2, 3}},
	-- Banner type
	{ gid=55, spsheet="fairy_cards", team=1, n=1, id="Augmentation", gain={banner_typ}},
	{ gid=56, spsheet="fairy_cards", team=1, pwe=3, id="Castle Walls", need={4, 1, 2, 0, 0}, sac={1, 2, 0, 0}, gain={3, banner_typ}, rook_hp=2, rook_tempo=2},
	{ gid=57, spsheet="fairy_cards", team=1, pwe=12, id="Fairy's Gift", need={centaur_typ, archbishop_typ, chancellor_typ}, spread=5, centaur_hp=1, archbishop_hp=1, chancellor_hp=1, amazon_tempo=-1, banner_hp=1},
	{ gid=58, spsheet="fairy_cards", team=1, pwe=6, id="Fairy's Other Gift", need={commoner_typ, gryphon_typ, prince_typ}, ammo_max=-1, commoner_hp=1, gryphon_hp=1, prince_hp=1, banner_hp=1},
	{ gid=59, spsheet="fairy_cards", team=1, id="Reinforced Base", need={banner_typ}, banner_hp=5},
	{ gid=60, spsheet="fairy_cards", team=1, id="Flyers", need={2}, sac={2}, gain={banner_typ, banner_typ}},
	{ gid=61, spsheet="fairy_cards", team=1, pwe=5, id="Projection", need={banner_typ}, sac={banner_typ}, gain={3}},
}


for i,ca in pairs(new_cards) do
	ca.played = 1  -- These stats will be used in the codex.
	ca.ignored = 0 -- You may save them and retrieve them yourself with your mod's save bank if you'd like.
end

add_content(CARDS, new_cards)
-- Each of these two cards can never appear if the other is present.
add_content(EXCLUDE, {
	{"Knightage","The Church"},
	{"Brave Heir", "Guillotine"},
	{"This is SPARTA", "Guillotine"},
	{"Lord Phoenix", "Twin Rooks"}
})

-- TESTING
-- Uncomment things as needed.

-- BOOT="GAME" -- This will skip the menu and throw you directly in a new game
-- game_mode="throne"
--START_LVL=5
--FORCE_WHITE_ARMY = {[0]=6}

-- Use the OVERWEIGHT table to make cards much more likely to appear in game as a random choice
-- add(OVERWEIGHT, "Voodoo Doll")
-- add(OVERWEIGHT, "Training")

-- Use the TEST_CARDS table to start runs with these cards right away
-- add(TEST_CARDS, "Augmentation")
add(TEST_CARDS, "Test F")
-- add(TEST_CARDS, "Training")


--[[ This is the complete vanilla set of pieces and cards:

PIECES={
	{type=0, name="pawn", 		hp=3, tempo=5, danger=1, seek="wdist" },
	{type=1, name="knight", 	hp=3, tempo=3, danger=3, seek="kdist", nocarry=1 },
	{type=2, name="bishop", 	hp=4, tempo=3, danger=3, seek="bdist" },
	{type=3, name="rook", 		hp=5, tempo=4, danger=6, seek="rdist", nocarry=1 },	
	{type=4, name="queen", 		hp=5, tempo=4, danger=9, seek="qdist" },
	{type=5, name="king", 		hp=8, tempo=4, danger=6, seek="wdist" },
	{type=6, name="boss", 		hp=24, tempo=3, danger=16, big=true, seek="wdist", nocarry=1 }, 
	{type=7, name="all", 		 	}, 
	{type=8, name="leader", 	},
	{type=9, name="cannonball", 	hp=99, tempo=4, seek="wdist", inert=true, freelift=1, nocarry=1 },
}

CARDS={
	{ gid=0, n=3, id="Ermine Belt", 				ammo_max=3 },
	{ gid=1, n=2, id="Rightful Curtsy", 		ammo_max=1, knockback=50 },
	{ gid=2, n=1, id="Elite Gem", 					firerange=1, ammo_regen=1 },
	{ gid=3, n=3, id="Extra Barrel", 				pwe=6, spread=7, chamber_max=1 },
	{ gid=4, n=1, id="Royal Loafers", 			special="strafe"	},	
	{ gid=5, n=1, id="Majestic Censer",			soul_slot=1,ammo_max=1  },
	{ gid=6, n=1, id="Sacred Crown",				need_soul=1, crown=1  }, 
	{ gid=7, n=2, id="Blunderbuss",					spread=30, firepower=2  },
	{ gid=8, n=1, id="Engraved Scope",			special="scope" },	
	{ gid=9, n=2, id="Holy Gunpowder",			firepower=1,  },
	{ gid=10, n=1, id="Ritual Dagger",			blade=1, king_hp=-2, firerange=-1 },
	{ gid=11, n=1, id="August Presence",		presence=1  },
	{ gid=12, n=1, id="Crow's Blessing",		firerange=2 },	
	{ gid=17, n=1, id="The Moat",						moat=4 },		
	{ gid=13, n=1, id="Wand of Downpour",		wand={0,10}  },
	{ gid=14, n=1, id="Wand of Frenzy",			wand={1} },
	{ gid=15, n=1, id="Wand of Wrath",			wand={2,"firepower"} },
	{ gid=16, n=1, id="Wand of Wings",			wand={3,3}},
	{ gid=20, n=1, id="Wand of Gust",				wand={4} },	
	{ gid=25, n=1, id="Kingdom Wealth", 		pwe=3,ammo_max=6,	leader_hp=2 },	
	{ gid=18, n=2, id="Gradual Absolution", need_soul=2,pwe=2,absolution=1 },	
	{ gid=19, n=1, id="Taunting Hop", 			hop=1},		
	{ gid=21, n=1, id="Unfaithful Steed",		need=1,steed=1, flip_on="no_knight"},	
	{ gid=22, n=1, id="Unjust Decree", 			pwe=2,need_chamber_max=2, firepower=-1, special="decree" },
	{ gid=23, n=3, id="Kingly Alms", 				grenades_max=2, special="grenade" },
	{ gid=24, n=1, id="Subtle Poison", 			pwe=2,queen_hp=-1,leader_hp=-1, queen_poison=15}, 
	{ gid=26, n=2, id="Small Fry Harvest",  pwe=2,ammo_max=1,pawn_shell=1}, 
	{ gid=27, n=2, id="A Piercing Truth", 	pierce=30},	--firepower=-1
	{ gid=28, n=2, id="Black Mist", 				mist=1,firerange=-1 },
	{ gid=29, n=1, id="King's Shoulders",		pwe=2,grab=1 },
	{ gid=30, n=2, id="High Focus", 				spread=-18,firepower=1,flip_on="contact"},
	{ gid=31, n=1, id="Courteous Jousting", need=1, knight_joust=1, spread=-10 },	
	{ gid=32, n=1, id="Cornered Despot", 		firepower=2, flip_on="inner" },	

	{ gid=33, n=1, id="Sawed-off Justice", 	firepower=2, firerange=-1, recoil=1 },
	{ gid=34, n=1, id="Welcome Gift", 			firepower=4, flip_on="first-reload" },	
	{ gid=35, n=1, id="Cannon Fodder", 			pawnreap=1 },
	{ gid=36, n=1, id="Possessed", 					soul_slot=2, gain=2, need_card={"Conclave","Unholy Call"}},
	{ gid=37, n=1, id="Philanthropy", 			need_grenade=1, grenades_max=1, freegren=1, special="grenade", need_card="Kingly Alms"	},
	{ gid=38, n=3, id="Imperial Shot Put", 	cannonball=1, ammo_max=-1, need_card="King's Shoulders"	},
	{ gid=39, n=1, id="Egotic Maelstrom",		delay=10, cycle=1, delayed={firepower=1} },
	{ gid=40, n=1, id="Church Organ", 			ammo_max=2, chamber_max=2, need_card="Cathedral"	},
	{ gid=41, n=1, id="Black Plague",				plague=1,	firerange=-1, need_card={"Crow's Blessing","Ravenous Rats"}	},
	{ gid=42, n=1, id="Ravenous Rats",			rats=1 },
	{ gid=43, n=1, id="Deep Water",					deepwater=1, need_card="The Moat" },
	{ gid=44, n=1, id="Unholy Call",				pentagrams=3	},
	{ gid=45, n=1, id="Undercover Mission",	waypoint=1	},
	{ gid=46, n=2, id="Caltrops",						caltrops=1, delay_mult=-50	},
	{ gid=47, n=1, id="Nightbane",					blade=3	},
	{ gid=48, n=1, id="Bushido",						blade=2, bushido=1, firepower=-1	},
	{ gid=49, n=1, id="Bloodless Coups",		pawn_peace=1, pawn_curse=1	},

	{ gid=50, n=1, id="Wand of Hypnosis",		wand={5}	},	
	{ gid=51, n=1, id="Presbyopia",					queen_minr=2, bishop_minr=2, need_card="Golden Aging"	},
	{ gid=52, n=1, id="Golden Aging",				need={4,8}, delay=10, cycle=1, queen_hp=-1, king_hp=-1, delayed={queen_tempo=1,leader_tempo=1}	},
	{ gid=53, n=1, id="Fool Companion",			need=8,	jester_guard=1,	need_card="The Jester"		},
	{ gid=54, n=1, id="Force-feeding",			overload=1, ammo_max=1			},

	--
	
	
	
	--
	{ gid=60, id="Backups", 					gain={0,0,0}, n=3  },
	{ gid=61, id="Cavalry", 					delay=15, gain={1,1} },
	{ gid=62, id="Conclave", 					delay=15, gain={2,2}  },	
	{ gid=63, id="Entitle", 					sac=0, gain=1, ammo_max=-1  },
	{ gid=64, id="Cardinal", 					sac=0, gain=2, ammo_max=-1 },	
	{ gid=65, id="Remparts",  				sac={0,0}, gain={3}, n=2  },	
	{ gid=66, id="Pillage",  					sac=3, gain={0,0,0,0,0}, pawn_hp=1  },	
	{ gid=67, id="Crusades",  				sac=2, gain={1,1}  },		
	{ gid=68, id="Peace",  						sac=1, gain={2,2}  },	
	{ gid=69, id="King's Mistress",		need=4, gain=4, queen_cage=3  },
	{ gid=70, id="Revolution",  			sac=2, gain={0,0,0,0,0,0},  },	
	{ gid=71, id="Bodyguard",  				need={1,8}, knight_bodyguard=1, knight_hp=1 },	
	{ gid=72, id="Ruins",  						gain={3,0,0}, rook_hp=-2  },	
	{ gid=73, id="Assault",  					need={0,0,0,0,0}, gain=0, assault=1  },
	{ gid=74, id="Kite Shield",  			need={1,1}, gain=0, knight_shield=1 },
	{ gid=75, id="Zealots", 					need=2, pawn_tempo=-1, bishop_tempo=-1, flip_on="no_bishop"  },
	{ gid=76, id="Militia", 					need={0,0,0}, gain=0, militia=1 },
	{ gid=77, id="Ammunition Depot",	n=2, gain=3, rook_shell=2	},
	{ gid=78, id="Scouting",					sac=1, gain={0,0}, pawn_tempo=-1 },	
	{ gid=79,	id="Pikemen",						need={0,0}, pawn_hp=1, pikemen=1 },
	{ gid=80,	id="Ascension",					need={2,2}, bishop_flying=1 },
	{ gid=81,	id="Castle",						need={3,8}, rook_castle=1, rook_hp=1 },	
	{ gid=82,	id="Conscription",			n=2, gain=0, delay=5, cycle=1 },
	{ gid=83,	id="Theocracy",					sac=5, gain=2, need=2, bishop_hp=2, theocracy=1, },
	{ gid=85,	id="Iron Maiden",				need=4, queen_iron=1, queen_tempo=2, flip_on="only_queen" },	
	{ gid=86,	id="Court of the King",	n=2, gain={1,1,2,3},all_tempo=1  },
	{ gid=87,	id="The Red Book",			gain=2, bishop_orth=1  },
	{ gid=88,	id="Saboteur",					n=2, sac={0,0}, gain=2, bad_shells=1  },	
	{ gid=89, id="Homecoming",				n=1, gain={4}, pwe=0	},
	{ gid=90,	id="Lookout Tower",			n=2, gain=3, delay=20, alarm=1 },	
	{ gid=91,	id="Throne Room",				need=5, king_hp=2, queen_hp=1 },
	{ gid=92,	id="The Secret Heir",		gain=0, heir=1 },
	{ gid=93,	id="Genderqueer",				sac=2, gain=4, delay=10 },
	
	{ gid=94, id="Karma", 						sqb_spread=30, sqw_firepower=-1  },
	{ gid=95, id="Undead Armies",			knight_rep=0, rook_rep=0, bishop_rep=0, pawn_hp=-1  },
	{ gid=96, id="Shortage", 					sac=0, ammo_max=-3, grenades_max=-1	},
	{ gid=97, id="Succubus", 					gain=4, soul_slot=1	},
	{ gid=98, id="Bunker", 						need={0,0,0}, sac=3, need_grenade=1, pawn_hp=1, king_hp=1, grenade_dmg=-1, need_card="Kingly Alms"	},
	{ gid=99, id="Sanctity", 					gain=2, bishop_sanctity=1, need_card="Conclave"	},
	{ gid=100, id="Knightmare", 			gain=1, knight_wraith=1, knight_hp=-1, need_card="Black Mist"	},
	{ gid=101, id="Highest Dungeon", 	need={3}, all_hp=1, flip_on="no_rook",need_card="Remparts" },
	{ gid=102, id="Cathedral",				sac=2, gain=3, rook_protect=1, need_card="Cardinal"},
	{ gid=103, id="The Bridge",				bridge=1, delay=10, gain=1, need_card="The Moat" },
	{ gid=104, id="Divine Healing",		need={2}, bishop_hp=1, bishop_healer=2 },
	{ gid=105, id="Last Guardian",		need={0,0}, pawn_lastg=1},
	{ gid=106, id="Trowel",						need={3,0}, rook_hp=4, flip_on="no_pawn"},
	{ gid=107, id="Full Plate Armor",	blade=-1, all_hp=1, all_tempo=1 },
	{ gid=108, id="Military Academy",	delay=10, gain=1, cycle=1 },
	{ gid=109, id="Witch's Curse",		need=4, firepower=-1, firerange=-1, spread=10, queen_curse=1 },

	{ gid=110, id="Saddle",						knight_carry=1, knight_tempo=1, need_card="Cavalry" }, --
	{ gid=111, id="The Jester",				need=0, gain=0, jester=1, need_card="Throne Room" }, --
	{ gid=112, id="Guillotine",				sac=5, need_card="Revolution" }, --
	{ gid=113, id="Analysis Paralysis", n=2, paralysis=6, need_card="High Focus" },
}

EXCLUDE={
	{"Throne Room","Theocracy"},
	{"Ritual Dagger","Theocracy"},
	{"Royal Loafers","Unjust Decree","Kingly Alms","Engraved Scope"},
	{"Royal Loafers","Sawed-off Justice"},
	{"Militia","Bloodless Coups"},
	{"Guillotine","The Secret Heir"},
}

--]]


-- Have fun!

