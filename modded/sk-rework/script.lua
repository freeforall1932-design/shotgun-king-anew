-- SK-REWORK diagnostics build 4 — 2026-10-03 (after live test #1)
-- =====================================================================
-- Build 3's live run proved the concept; build 4 harvests what build 3
-- missed and drops what the live run proved dead. It still changes NOTHING
-- in the game.
--
-- Lessons applied from the live log (live testing result/game-insights/):
--   * The game wraps every log line in "  . " / " !! " markers — harmless
--     here; tools/parse_log.py now strips them.
--   * append() hooks fired; on_* globals and upd() NEVER fired during real
--     gameplay (SKE2 count = 0, no heartbeat). Defining global on_* names is
--     also risky: those names belong to the Glacies Module Terminal's
--     dispatch, and a mod defining them can shadow the dispatcher.
--     -> build 4 removes all on_*/upd probes and keeps append() only.
--   * The game writes mods/modlist.lua itself at boot (mods ON by default).
--     -> build 4 probes that file (loadfile) and dumps every MODLIST entry
--     so the toolchain can learn its format (SKML| / SKM|).
--   * Card objects carry id = display name -> dump the full CARDS id map
--     (SKC|) for the save tool and the future card picker.
--
-- Line prefixes: SKG=global names, SKR=replaceable, SKF=forbidden,
--   SKA=api availability, SKH=hook registered, SKE=event (append hooks),
--   SKO=object field, SKW=world state, SKM=MODLIST entry dump,
--   SKC=CARDS id map, SKML=mods/modlist.lua probe.
-- Volume control: first CAP_FIRST hits of each event, then every CAP_EVERY-th.
-- Safety: no pcall in this engine -> everything nil/boolean-safe (sv()),
--   loops capped, the modlist.lua probe runs AFTER the READY line so even a
--   probe error cannot cost us the harvest.
-- =====================================================================

local BUILD = 4
local CAP_FIRST = 30          -- log the first N hits of every event
local CAP_EVERY = 25          -- after that, every Nth hit
local MAX_FIELDS = 12         -- fields dumped per object

-- ---------- tiny helpers (nil-safe, no stdlib beyond what mods already use)
local function sv(v)
	if v == nil then return "nil" end
	local t = type(v)
	if t == "table" then return "tbl" end
	if t == "function" then return "fn" end
	if t == "boolean" then return v and "true" or "false" end
	return "" .. v   -- numbers and strings are safe to concatenate
end

local function log(s) _log(s) end

-- The shipped mods write `for x in all(tbl)` and then use x as an element
-- (e.g. call it), so all() yields VALUES. If an engine build ever yielded
-- (index, value) instead, this still picks the element either way:
--   all yields one value   -> for a,b -> a=value, b=nil   -> a
--   all yields index+value -> for a,b -> a=index, b=value -> b
local function pick(a, b)
	if b ~= nil then return b end
	return a
end

-- append-only auto-incrementing event counters
local counts = {}
local function capped(tag)
	local n = (counts[tag] or 0) + 1
	counts[tag] = n
	if n <= CAP_FIRST or (n % CAP_EVERY) == 0 then
		return n
	end
	return nil
end

-- dump up to MAX_FIELDS fields of a table: SKO|tag|key=value
-- One level of nesting is expanded (key.sub=value).
local MAX_SUB = 8
local function dump_fields(tag, t, max)
	if t == nil then log("SKO|" .. tag .. "|nil=true") return end
	local i, shown = 0, 0
	for k, v in pairs(t) do
		i = i + 1
		if i > (max or MAX_FIELDS) then break end
		local tv = type(v)
		if tv == "table" then
			local j = 0
			for k2, v2 in pairs(v) do
				j = j + 1
				if j > MAX_SUB then break end
				local tv2 = type(v2)
				if tv2 ~= "table" and tv2 ~= "function" then
					log("SKO|" .. tag .. "|" .. sv(k) .. "." .. sv(k2) .. "=" .. sv(v2))
					shown = shown + 1
				end
			end
		elseif tv ~= "function" then
			log("SKO|" .. tag .. "|" .. sv(k) .. "=" .. sv(v))
			shown = shown + 1
		end
	end
	log("SKO|" .. tag .. "|fields_shown=" .. sv(shown))
end

-- ---------- 1. find ourselves in the mod list (canonical pattern) --------
local mod_index, mod = -1, nil
for i, v in ipairs(MODLIST) do
	if v.title == "SK Rework" then
		mod_index, mod = i, v
		break
	end
end

log("SK-REWORK: BUILD=" .. sv(BUILD) .. " loaded (mod_index=" .. sv(mod_index) .. ")")
if mod == nil then
	log("SK-REWORK: WARNING could not find 'SK Rework' in MODLIST - load order or title changed")
else
	log("SKA2|mod_found=yes|active=" .. sv(mod.active))
end

-- ---------- 1b. dump EVERY MODLIST entry (mod menu state, build 4) -------
-- Live test showed the game writes mods/modlist.lua at boot and the menu's
-- up/down = load priority. Dump each entry's scalar fields so the format of
-- that file and the menu's on/off field can be matched up offline.
local mi = 0
for i, v in ipairs(MODLIST) do
	mi = mi + 1
	if mi > 40 then break end
	if type(v) == "table" then
		local j = 0
		for k2, v2 in pairs(v) do
			j = j + 1
			if j > 12 then break end
			local tv2 = type(v2)
			if tv2 ~= "function" then
				log("SKM|" .. sv(i) .. "|" .. sv(k2) .. "=" .. sv(v2))
			end
		end
	end
end
log("SK-REWORK: SKM entries=" .. sv(mi))

-- ---------- 2. which globals exist? (membership test on gimme list) ------
local known = {}
local n_global = 0
for a, b in all(gimme("global")) do
	local name = sv(pick(a, b))
	known[name] = true
	n_global = n_global + 1
end
log("SK-REWORK: globals visible = " .. sv(n_global))

-- API self-check: names the project intends to use, plus useful extras.
-- (live note: append/prepend/gimme are NOT in gimme("global") yet work —
-- they are mod-environment functions, not game globals.)
local api_wanted = {
	"append", "prepend", "gimme", "_log", "concat", "add", "del", "all",
	"get_slot_cards", "gsq", "mk_menu_but", "init_menu", "spawn_pieces",
	"new_piece", "setup_piece", "new_turn", "new_level", "add_card",
	"new_card", "CARDS", "get_disp_stats", "edit_disp_stats", "draw_mode",
	"goto_sq", "get_range", "throw_grenade", "spend_hop", "uplift",
	"check_cards_auto_flip", "flip_card", "unflip_card", "mk_hint_but",
	"set_mode", "init_game", "init_codex", "opp_turn", "wait",
}
for _, name in ipairs(api_wanted) do
	log("SKA|" .. name .. "|" .. (known[name] and "YES" or "no"))
end

-- ---------- 3. the function map ------------------------------------------
local function dump(tag, tbl)
	local n = 0
	for a, b in all(tbl) do
		log(tag .. "|" .. sv(pick(a, b)))
		n = n + 1
	end
	log("SK-REWORK: " .. tag .. " count=" .. sv(n))
end
dump("SKG", gimme("global"))
dump("SKR", gimme("replaceable"))
dump("SKF", gimme("forbidden"))

-- ---------- 4. hook registration: append() to proven game globals -------
-- (on_* probes removed in build 4: the live run proved they never fire for
-- plain mods — append() is the mechanism. See header.)
local hooks_ok = 0
local function hookf(target, fn, id)
	append(target, fn, id)
	hooks_ok = hooks_ok + 1
	log("SKH|" .. target .. "|" .. id)
end

-- turn counter + compact world state (once per turn: cheap, low volume)
hookf("new_turn", function()
	local n = capped("turn")
	if not n then return end
	local bads_n, bullets_n = 0, 0
	if bads then for _a, _b in all(bads) do bads_n = bads_n + 1 end end
	if bullets then for _a, _b in all(bullets) do bullets_n = bullets_n + 1 end end
	local px, py = "?", "?"
	if hero and hero.sq then px, py = sv(hero.sq.px), sv(hero.sq.py) end
	log("SKW|turn=" .. sv(n) .. "|bads=" .. sv(bads_n) .. "|bullets=" .. sv(bullets_n)
		.. "|hero_px=" .. px .. "|hero_py=" .. py)
	-- first turn of each game: dump the hero's real field names (cheap, once)
	if n == 1 then
		dump_fields("hero", hero)
		if hero and hero.sq then dump_fields("hero.sq", hero.sq) end
	end
end, "sk-rework:turn")

-- floor changes
hookf("new_level", function(...)
	local n = capped("level")
	if not n then return end
	log("SKE|new_level|n=" .. sv(n))
end, "sk-rework:level")

-- piece spawns: dump the first few pieces' fields (learn the piece model)
hookf("setup_piece", function(e, ...)
	local n = capped("setup_piece")
	if not n then return end
	local typ, hp = "?", "?"
	if e then typ = sv(e.type) hp = sv(e.hp) end
	log("SKE|setup_piece|n=" .. sv(n) .. "|type=" .. typ .. "|hp=" .. hp)
	if n <= 3 then dump_fields("piece", e) end
end, "sk-rework:setup_piece")

-- cards being added/offered: dump the first few card tables (card picker intel)
hookf("add_card", function(ca, ...)
	local n = capped("add_card")
	if not n then return end
	local id, pwe = "?", "?"
	if ca then id = sv(ca.id) pwe = sv(ca.pwe) end
	log("SKE|add_card|n=" .. sv(n) .. "|id=" .. id .. "|pwe=" .. pwe)
	if n <= 5 then dump_fields("card", ca) end
end, "sk-rework:add_card")

-- game start marker
hookf("init_game", function(...)
	local n = capped("init_game")
	if not n then return end
	log("SKE|init_game|n=" .. sv(n))
end, "sk-rework:init_game")

-- ---------- 5. card id map (save tool + card picker intel, build 4) ------
-- live log proved card.id == display name; dump the whole table so the
-- special cards' ids (Right-hand, Gatehouse, ...) are known offline.
local nc = 0
if CARDS then
	for a, b in all(CARDS) do
		local c = pick(a, b)
		nc = nc + 1
		if nc <= 400 and type(c) == "table" then
			log("SKC|" .. sv(c.id) .. "|gid=" .. sv(c.gid) .. "|ext=" .. sv(c.ext)
				.. "|pwe=" .. sv(c.pwe) .. "|name=" .. sv(c.name)
				.. "|special=" .. sv(c.special))
		end
	end
end
log("SK-REWORK: SKC count=" .. sv(nc))

-- ---------- 6. ready line (the "patch worked" marker for the owner) ------
log("SK-REWORK: READY build=" .. sv(BUILD) .. " hooks=" .. sv(hooks_ok)
	.. " globals=" .. sv(n_global))

-- ---------- 7. mods/modlist.lua probe (AFTER READY: cannot cost harvest) --
-- The game wrote this file at boot in the live run; its format decides
-- whether the toolchain can pre-enable mods. loadfile may or may not exist
-- in the mod environment — check, and log whatever it returns.
log("SKA2|loadfile=" .. (type(loadfile) == "function" and "yes" or "no"))
if type(loadfile) == "function" then
	local chunk = loadfile("mods/modlist.lua")
	log("SKML|load|" .. sv(type(chunk)))
	if type(chunk) == "function" then
		local r = chunk()
		log("SKML|type|" .. sv(type(r)))
		if type(r) == "table" then
			local i = 0
			for k, v in pairs(r) do
				i = i + 1
				if i > 60 then break end
				local tv = type(v)
				if tv ~= "table" and tv ~= "function" then
					log("SKML|e|" .. sv(k) .. "=" .. sv(v))
				else
					log("SKML|e|" .. sv(k) .. "=" .. tv)
				end
			end
			log("SKML|count|" .. sv(i))
		end
	end
end
log("SK-REWORK: PROBE done build=" .. sv(BUILD))

-- SK-REWORK: TODO (next phases, once the harvested map is parsed):
--   F-key/panel debug UI (mk_menu_but patterns from the reference mods)
--   ammo rework A -> B -> C, card picker, enemy picker, balance knobs
