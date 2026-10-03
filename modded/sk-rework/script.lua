-- SK-REWORK diagnostics build 3 — 2026-10-03
-- =====================================================================
-- Purpose of this build (it still changes NOTHING in the game):
--   1. prove the mod loaded and hooks registered    -> SK-REWORK markers, SKA|, SKH|
--   2. dump the game's function map                 -> SKG|, SKR|, SKF|
--   3. trace live game state during play            -> SKW|, SKE|, SKO|
-- The Python side of the project reads these lines with
--   python tools/parse_log.py <logfile>            -> notes/game-map-draft.md
--
-- Hook strategy (chosen after reading the 13 shipped mods):
--   * primary hooks use append() on game globals that real mods already wrap
--     (new_turn, new_level, setup_piece, add_card, init_game)
--   * on_* callbacks are only *probed* (SKE2| prefix): independent mods never
--     rely on them; the "Glacies Module Terminal" mod provides that dispatch
--     for its dependants. Comparing SKE| vs SKE2| counts tells us whether the
--     engine calls on_* by itself — useful intel, zero gameplay impact.
--   * no pcall exists in this engine (no shipped mod uses it) -> every line
--     is written nil-safe, values go through sv(), loops are capped.
--
-- Volume control: the first CAP_FIRST hits of each event are logged, then
-- every CAP_EVERY-th, so a long session cannot flood log.txt.
-- Line prefixes for grepping: SKG=global names, SKR=replaceable, SKF=forbidden,
--   SKA=api availability, SKH=hook registered, SKE=event (append hooks),
--   SKE2=event (on_* callback probe), SKO=object field, SKW=world state,
--   SKC=candidate tally.
-- =====================================================================

local BUILD = 3
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
-- One level of nesting is expanded (key.sub=value): the displayed-stats table
-- is a list of subtables ({id=, name=, value=}), and that is where the real
-- stat names (ammo/health/...) live.
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

-- ---------- 2. which globals exist? (membership test on gimme list) ------
local known = {}
local n_global = 0
for a, b in all(gimme("global")) do
	local name = sv(pick(a, b))
	known[name] = true
	n_global = n_global + 1
end
log("SK-REWORK: globals visible = " .. sv(n_global))

-- API self-check: names the project intends to use, plus useful extras
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

-- ---------- 3. the function map (unchanged from build 2) ----------------
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
-- (every id is stable and prefixed so it can be unregistered later)
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

-- ---------- 5. on_* callback probes (SKE2| prefix: see header) ----------
-- If these ever fire, the engine dispatches them to plain mods; if they never
-- fire while the SKE| hooks above do, event dispatch is Terminal-provided.
function on_fire()
	local n = capped("cb_fire")
	if not n then return end
	log("SKE2|on_fire|n=" .. sv(n))
end
function on_bad_hurt(p)
	local n = capped("cb_hurt")
	if not n then return end
	log("SKE2|on_bad_hurt|n=" .. sv(n) .. "|type=" .. sv(p and p.type) .. "|hp=" .. sv(p and p.hp))
end
function on_bad_death(p)
	local n = capped("cb_death")
	if not n then return end
	log("SKE2|on_bad_death|n=" .. sv(n) .. "|type=" .. sv(p and p.type))
end
function on_bad_spawn(p)
	local n = capped("cb_spawn")
	if not n then return end
	log("SKE2|on_bad_spawn|n=" .. sv(n) .. "|type=" .. sv(p and p.type))
end
function on_new_turn()
	local n = capped("cb_turn")
	if not n then return end
	log("SKE2|on_new_turn|n=" .. sv(n))
end
function on_empty()
	local n = capped("cb_empty")
	if not n then return end
	log("SKE2|on_empty|n=" .. sv(n))
end
-- the displayed-stats table is the fastest route to the real stat names
function edit_disp_stats(stats)
	if capped("cb_disp") == 1 then dump_fields("disp_stats", stats, 20) end
end
-- frame heartbeat: proves the mod is alive even if nothing else fires
local frames = 0
function upd()
	frames = frames + 1
	if (frames % 900) == 0 then
		log("SKE|heartbeat|frames=" .. sv(frames) .. "|turn=" .. sv(counts["turn"] or 0))
	end
end

-- ---------- 6. ready line (the "patch worked" marker for the owner) -----
log("SK-REWORK: READY build=" .. sv(BUILD) .. " hooks=" .. sv(hooks_ok)
	.. " globals=" .. sv(n_global))

-- SK-REWORK: TODO (next phases, once the harvested map is parsed):
--   F-key/panel debug UI (mk_menu_but patterns from the reference mods)
--   ammo rework A -> B -> C, card picker, enemy picker, balance knobs
