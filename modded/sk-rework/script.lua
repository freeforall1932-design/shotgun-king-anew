-- SK-REWORK build 7 — Dev Panel v2, damage/crit, ammo, dodge, pickers
-- =====================================================================
-- Build 6 was run live on 2026-10-04 (run 5, ~22 min, clean shutdown) and
-- every Build-6 question was answered. Build 7 absorbs that evidence:
--   * PANEL (run 5 finding): the panel rendered and all cheats fired, but
--     mk_text_but groups were deleted with del(ents, e), which the engine
--     ignores -> `open=true` immediately followed by `open=false` and ghost
--     buttons (owner: "close doesn't close, button frozen brown"). Build 7
--     uses the engine's own remove_buts() (proven in disgraced_justice and
--     glac terminal) and rebuilds the header on the next turn.
--   * DAMAGE/CRIT: run 5 logged the live route (mk_bullet x30, bullets carry
--     dmg/pierce, hit(p,dmg,tags) x30, fx_dmg(p,dmg) x30, ev_hit NEVER fires).
--     The gated "DMG" button is now real: configurable per-bullet damage,
--     crit chance/damage, pierce auto-crit by default, persisted in the bank.
--   * AMMO: +3 stays reserve (owner: "more like ammo regeneration"); new
--     RELOAD button uses the `reload` global and CLIP+ bumps
--     stack.chamber_max (live: stack.chamber_max=1). chamber/value readouts.
--   * SPAWN: pick the piece type (page 3) and the square (prefers a DIAGONAL
--     neighbour so the ally never blocks the king's 1-tile move -- the run-5
--     complaint), logs both, still fx_spawn'd.
--   * GOD MODE: HP refill + Mist-style dodge to a free square via goto_sq
--     (signature guessed; logs which route worked and falls back to a direct
--     hero.sq field write).
--   * CARD: AUTO (game pick()) or LIST (browse every card, click to take;
--     summon-family cards also spawn their `allies` piece).
--   * MENU: legend/Back attach on the real mod-list ids harvested in run 5
--     ("mods"/"save_back"/" ON "/"OFF "); the previous MODLIST-title compare
--     could never match, which is why widgets_added never appeared.
--   * SAFE mode: one engine-mutating action per boot (bank-stored), plus a
--     SKE|call|<name>=start line before every mutating engine call, so a
--     crash still names the failing control.
-- ---------------------------------------------------------------------
-- Build 5 was run live on 2026-10-04 (run 4) and CRASHED AT BOOT: the input
-- probe called btn("left") on a name the engine does not know, which falls
-- through to the input-id parser and is a FATAL game error ("Button left for
-- player 0 doesn't exist", script.lua:817). Build 6 fixed that:
--   * btn() is only ever called with strings the running game has already
--     published (named buttons from INPUT_ASSIGNEMENT + the bound mouse
--     codes). Unknown ids are never blind-probed — there is no pcall here.
--   * probe blocks are reordered (safe blocks first) and each one logs a
--     completion marker, so one failure can no longer hide the rest.
-- Everything else from Build 5 is unchanged (live evidence in run 4: the
-- card/piece/soul/offer harvest below ran to completion before the crash).
-- ---------------------------------------------------------------------
-- Build 4 was live-proven (runs 1–3): load proof, MODLIST/CARDS map, and
-- five append() hooks. Build 6 keeps that harvest and adds the queued work:
--   * Native-button Dev panel: +ammo, a random eligible card, summon ally,
--     and a God Mode toggle. Settings use the standard per-mod bank API.
--   * Mod-menu legend + Back button, attached only when a menu button ID
--     matches a live MODLIST entry (no guessed screen-state constants).
--     v7: run 5 proved that compare can never match (ids are play/mods/
--     save_back/" ON "/"OFF "); the trigger is now the real live ids.
--   * §0.7 probes after READY: SKCF (all card fields + EXCLUDE), SKOF
--     (offer filters/choices), SKS (souls/scepters/pieces), SKD
--     (bullet/damage path), SKI (mouse/buttons/input/menu IDs), SKUI
--     (native UI + config persistence).
--
-- Safety rules:
--   * No pcall/loadfile. Every value is nil/boolean-safe via sv().
--   * ENGINE CALLS TAKE ONLY CONFIRMED ARGUMENTS. A wrong argument to some
--     engine functions is fatal and unrecoverable (run 4: btn("left")).
--   * No global on_* or upd dispatcher. Engine integration is append() /
--     prepend() only; `e.upd` is not used.
--   * Probe loops and output are capped. Static §0.7 probes run only after
--     the READY marker so their failure cannot hide the load verdict, and
--     every block ends with an SKA2|probe|<name>=done checkpoint.
--   * The gameplay buttons are opt-in. No gameplay code runs unless clicked.
-- =====================================================================

local BUILD = 7
local CAP_FIRST = 30
local CAP_EVERY = 25
local MAX_FIELDS = 16
local MAX_SUB = 12
local MAX_CARD_FIELDS = 128
local MAX_CARD_SUBFIELDS = 48
local MAX_CARDS = 400
local MAX_PIECES = 128
local MAX_EXCLUDES = 512
local MAX_ENTS_SCAN = 2000
local PANEL_PAGE_BUTTONS = 6
local SPAWN_PICK_BUTTONS = 6

-- ---------- tiny helpers (nil-safe; no dependencies on unavailable APIs)
local function sv(v)
	if v == nil then return "nil" end
	local t = type(v)
	if t == "table" then return "tbl" end
	if t == "function" then return "fn" end
	if t == "boolean" then return v and "true" or "false" end
	if t == "number" or t == "string" then return "" .. v end
	return t
end

local function log(s)
	if type(_log) == "function" then _log(s) end
end

-- SUGAR's `all()` yields values; this also handles iterator,index,value.
-- flr() is a live engine global, but never assume it: if it is missing the
-- helper returns the value unchanged instead of raising.
local function ifloor(v)
	if type(flr) == "function" then return flr(v) end
	return v
end

local function iter_value(a, b)
	if b ~= nil then return b end
	return a
end

local counts = {}
local function capped(tag)
	local n = (counts[tag] or 0) + 1
	counts[tag] = n
	if n <= CAP_FIRST or (n % CAP_EVERY) == 0 then return n end
	return nil
end

local function dump_fields(tag, t, max, prefix)
	local pfx = prefix or "SKO"
	if t == nil then log(pfx .. "|" .. tag .. "|nil=true") return end
	if type(t) ~= "table" then
		log(pfx .. "|" .. tag .. "|value=" .. sv(t))
		return
	end
	local i, shown = 0, 0
	for k, v in pairs(t) do
		i = i + 1
		if i > (max or MAX_FIELDS) then
			log(pfx .. "|" .. tag .. "|truncated=true")
			break
		end
		local vt = type(v)
		log(pfx .. "|" .. tag .. "|" .. sv(k) .. "=" .. sv(v))
		shown = shown + 1
		if vt == "table" then
			local j = 0
			for k2, v2 in pairs(v) do
				j = j + 1
				if j > MAX_SUB then
					log(pfx .. "|" .. tag .. "|" .. sv(k) .. ".truncated=true")
					break
				end
				log(pfx .. "|" .. tag .. "|" .. sv(k) .. "." .. sv(k2) .. "=" .. sv(v2))
				if type(v2) == "table" then
					local k3n = 0
					for k3, v3 in pairs(v2) do
						k3n = k3n + 1
						if k3n > 8 then
							log(pfx .. "|" .. tag .. "|" .. sv(k) .. "." .. sv(k2) .. ".truncated=true")
							break
						end
						log(pfx .. "|" .. tag .. "|" .. sv(k) .. "." .. sv(k2) .. "." .. sv(k3) .. "=" .. sv(v3))
					end
				end
			end
		end
	end
	log(pfx .. "|" .. tag .. "|fields_shown=" .. sv(shown))
end

local function log_target(prefix, tag, target, dmg, extra)
	local name, hp, bad = "?", "?", "?"
	if type(target) == "table" then
		name = sv(target.name or target.type)
		hp = sv(target.hp)
		bad = sv(target.bad)
	end
	log(prefix .. "|" .. tag .. "|target=" .. name .. "|dmg=" .. sv(dmg)
		.. "|hp=" .. hp .. "|bad=" .. bad .. (extra or ""))
end

-- ---------- 1b. Build 7 state, config, safety budget & helpers ----------
-- All state that section 4/5/6 closures touch lives here so the upvalues
-- resolve (a local declared later would silently become a global).
local cfg = { on = 0, dmg_min = 1, dmg_max = 1, crit = 0, crit_dmg = 2, pierce_crit = 1 }
local card_mode = "auto"          -- "auto" (game pick) | "list" (browse + take)
local card_filter = "all"         -- "all" | "piece" (piece/summon-related cards)
local offer_active = false        -- level-up/offer screen open: never touch buttons
local safe_mode = 0               -- 1 = one engine-mutating action per boot
local safe_budget = 1
local safe_used = {}
local bank_ready = false
local bank_dirty = false
local bank_flush_gate = 0
local god_mode = false
local rand_state = 20261005
local dev_actions = {}
local dev_open = false
local dev_page = 1
local card_page = 1
local spawn_pick = nil
local panel_present = false
local dev_header = nil
local dev_y = nil
local panel_creation_logged = false
local make_dev_actions
local make_card_page
local make_spawn_page
local ensure_dev_panel
local reopen_page

local function prand()
	rand_state = (rand_state * 48271) % 2147483647
	if rand_state <= 0 then rand_state = 1 end
	return rand_state
end

local function seed_rand()
	if type(t) == "number" and type(flr) == "function" then
		rand_state = (rand_state + flr(t * 1000)) % 2147483647
		if rand_state <= 0 then rand_state = 1 end
	end
end

-- Configured per-bullet damage + crit roll (W3). pierce > 0 auto-crits by
-- default unless the owner turns pierce_crit off in the panel.
local function roll_damage(pierce)
	local lo, hi = cfg.dmg_min, cfg.dmg_max
	if type(lo) ~= "number" or lo < 0 then lo = 1 end
	if type(hi) ~= "number" or hi < lo then hi = lo end
	lo, hi = ifloor(lo), ifloor(hi)
	local dmg = lo
	if hi > lo then dmg = lo + (prand() % (hi - lo + 1)) end
	local crit = false
	if type(cfg.crit) == "number" and cfg.crit > 0 and (prand() % 100) < cfg.crit then crit = true end
	if cfg.pierce_crit == 1 and type(pierce) == "number" and pierce > 0 then crit = true end
	if crit then
		local cd = cfg.crit_dmg
		if type(cd) ~= "number" or cd < 1 then cd = 2 end
		dmg = dmg * cd
	end
	return dmg, crit
end

local function cfg_line()
	return "SKUI|cfg|on=" .. sv(cfg.on) .. "|dmg=" .. sv(cfg.dmg_min) .. "-" .. sv(cfg.dmg_max)
		.. "|crit=" .. sv(cfg.crit) .. "%|crit_dmg=" .. sv(cfg.crit_dmg)
		.. "|pierce_crit=" .. sv(cfg.pierce_crit) .. "|card_mode=" .. sv(card_mode)
		.. "|safe=" .. sv(safe_mode) .. "|god_mode=" .. sv(god_mode)
end

-- EFcall: every engine-mutating call goes through here. It logs intent
-- BEFORE the call (so a crash still names the control that caused it) and
-- enforces the optional SAFE budget (one mutating call per boot).
-- Proven-safe calls (run-5 evidence: they wrote/read the bank and removed
-- buttons without incident) bypass the SAFE budget; gameplay mutators do not.
local SAFE_EXEMPT = {savbnk = true, newbnk = true, bget = true, bset = true,
	remove_buts = true, init_menu = true, get_nearest_free_square = true}

local function ecall(name, fn, ...)
	if type(fn) ~= "function" then
		log("SKE|call|" .. name .. "=skipped|reason=not_a_function")
		return nil
	end
	if safe_mode == 1 and safe_budget <= 0 and not SAFE_EXEMPT[name] then
		log("SKE|call|" .. name .. "=blocked|reason=safe_mode|hint=SAFE off in the panel")
		return nil
	end
	log("SKE|call|" .. name .. "=start")
	local a, b, c = fn(...)
	if safe_mode == 1 and not SAFE_EXEMPT[name] and not safe_used[name] then
		safe_used[name] = true
		safe_budget = safe_budget - 1
	end
	log("SKE|call|" .. name .. "=ok|r=" .. sv(a) .. "|budget=" .. sv(safe_budget))
	return a, b, c
end

local function bank_set(x, y, v)
	if not bank_ready or type(bset) ~= "function" then return end
	bset(x, y, v)          -- proven live in run 5 (write path + savbnk)
	bank_dirty = true
end

local function bank_flush(force)
	if not (bank_ready and bank_dirty) then return end
	if type(savbnk) ~= "function" then return end
	if force or bank_flush_gate <= 0 then
		ecall("savbnk", savbnk)
		bank_dirty = false
		bank_flush_gate = 12
	end
	bank_flush_gate = bank_flush_gate - 1
end

local function persist_cfg(force)
	bank_set(0, 0, 505)
	bank_set(1, 0, god_mode and 1 or 0)
	bank_set(2, 0, cfg.on)
	bank_set(3, 0, cfg.dmg_min)
	bank_set(4, 0, cfg.dmg_max)
	bank_set(5, 0, cfg.crit)
	bank_set(6, 0, cfg.crit_dmg)
	bank_set(7, 0, cfg.pierce_crit)
	bank_set(8, 0, card_mode == "list" and 1 or 0)
	bank_set(9, 0, safe_mode)
	bank_flush(force)
end

-- Square picker (W5): diagonal neighbours first, because the king moves one
-- orthogonal tile per turn and a diagonal ally never blocks that move (the
-- run-5 complaint: "spawn ally blocks my 1 tile movement").
local function free_square_at(x, y)
	if type(gsq) ~= "function" then return nil end
	local sq = gsq(x, y)
	if sq == nil then return nil end
	if type(is_free) == "function" then
		if is_free(sq) then return sq end
		return nil
	end
	if sq.p == nil and sq.op == nil then return sq end
	return nil
end

local function choose_spawn_square()
	if not (hero and hero.sq) then return nil, "no_hero" end
	local px, py = hero.sq.px, hero.sq.py
	if type(px) ~= "number" or type(py) ~= "number" then return nil, "no_hero_pos" end
	local diag = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}}
	local orth = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	local i, sq
	for i = 1, 4 do
		sq = free_square_at(px + diag[i][1], py + diag[i][2])
		if sq then return sq, "diagonal" end
	end
	for i = 1, 4 do
		sq = free_square_at(px + orth[i][1], py + orth[i][2])
		if sq then return sq, "orthogonal" end
	end
	if type(get_nearest_free_square) == "function" then
		-- GUESSED signature: (px, py) -> square. Guarded by type() and the
		-- result is validated before use, so a wrong guess degrades, not dies.
		local guess = ecall("get_nearest_free_square", get_nearest_free_square, px, py)
		if type(guess) == "table" and type(guess.px) == "number" then
			return guess, "engine_nearest"
		end
	end
	for r = 2, 6 do
		for dx = -r, r do
			for dy = -r, r do
				if dx == -r or dx == r or dy == -r or dy == r then
					sq = free_square_at(px + dx, py + dy)
					if sq then return sq, "ring" .. sv(r) end
				end
			end
		end
	end
	return nil, "none"
end

local function spawn_ally(ptype, via)
	if type(new_piece) ~= "function" then
		log("SKUI|spawn|status=new_piece_missing")
		return
	end
	local sq, how = choose_spawn_square()
	if sq == nil then
		log("SKUI|spawn|status=no_free_square|route=" .. sv(how))
		return
	end
	local px, py = sq.px, sq.py
	local p = ecall("new_piece", new_piece, ptype, false, sq)
	if type(p) == "table" then
		-- plain field writes only (no engine call): the engine keys allies
		-- off `bad`; these are peace-keeping hints for other code paths.
		p.team = 0
		p.ally = true
		if type(fx_spawn) == "function" then ecall("fx_spawn", fx_spawn, p) end
	end
	log("SKUI|spawn|type=" .. sv(ptype) .. "|px=" .. sv(px) .. "|py=" .. sv(py)
		.. "|route=" .. sv(how) .. "|via=" .. sv(via) .. "|piece=" .. sv(p))
end

-- God Mode dodge (W6): move the king to a free square instead of relying on
-- HP alone. goto_sq's signature is unverified, so both plausible argument
-- orders are tried and validated; if neither moved the king, a direct
-- hero.sq write is used (plain table data). Every route logs what happened.
local function dodge_king(reason)
	if not (hero and hero.sq) then
		log("SKUI|dodge|status=no_hero|reason=" .. sv(reason))
		return false
	end
	local sq, how = choose_spawn_square()
	if sq == nil then
		log("SKUI|dodge|status=no_square|reason=" .. sv(reason))
		return false
	end
	local bx, by = sv(hero.sq.px), sv(hero.sq.py)
	local ok = false
	if type(goto_sq) == "function" then
		ecall("goto_sq_sq", goto_sq, hero.sq, sq)          -- GUESS #1
		if hero.sq and hero.sq.px == sq.px and hero.sq.py == sq.py then ok = true end
		if not ok then
			ecall("goto_sq_hero", goto_sq, hero, sq)       -- GUESS #2
			if hero.sq and hero.sq.px == sq.px and hero.sq.py == sq.py then ok = true end
		end
	end
	if not ok and hero.sq then
		hero.sq.px, hero.sq.py = sq.px, sq.py
		ok = hero.sq.px == sq.px
	end
	log("SKUI|dodge|from=" .. bx .. "," .. by .. "|to=" .. sv(sq.px) .. "," .. sv(sq.py)
		.. "|route=" .. sv(how) .. "|moved=" .. sv(ok) .. "|reason=" .. sv(reason))
	return ok
end

-- ---------- 1. find ourselves in MODLIST -------------------------------
local mod_index, mod = -1, nil
if type(MODLIST) == "table" then
	for i, v in ipairs(MODLIST) do
		if i > 40 then break end
		if type(v) == "table" and v.title == "SK Rework" then
			mod_index, mod = i, v
			break
		end
	end
end

log("SK-REWORK: BUILD=" .. sv(BUILD) .. " loaded (mod_index=" .. sv(mod_index) .. ")")
if mod == nil then
	log("SK-REWORK: WARNING could not find 'SK Rework' in MODLIST - load order or title changed")
else
	log("SKA2|mod_found=yes|active=" .. sv(mod.active))
end

local mi = 0
if type(MODLIST) == "table" then
	for i, v in ipairs(MODLIST) do
		mi = mi + 1
		if mi > 40 then break end
		if type(v) == "table" then
			local j = 0
			for k2, v2 in pairs(v) do
				j = j + 1
				if j > 12 then break end
				if type(v2) ~= "function" then
					log("SKM|" .. sv(i) .. "|" .. sv(k2) .. "=" .. sv(v2))
				end
			end
		end
	end
end
log("SK-REWORK: SKM entries=" .. sv(mi))

-- ---------- 2. global availability + function map ----------------------
local known = {}
local n_global = 0
if type(gimme) == "function" and type(all) == "function" then
	for a, b in all(gimme("global")) do
		local name = sv(iter_value(a, b))
		known[name] = true
		n_global = n_global + 1
		if n_global >= 2000 then break end
	end
end
log("SK-REWORK: globals visible = " .. sv(n_global))

local api_wanted = {
	"append", "prepend", "gimme", "_log", "concat", "add", "del", "all",
	"get_slot_cards", "gsq", "mk_menu_but", "mk_text_but", "mk_but",
	"init_menu", "spawn_pieces", "new_piece", "setup_piece", "new_turn",
	"new_level", "add_card", "new_card", "CARDS", "EXCLUDE", "PIECES",
	"get_disp_stats", "draw_mode", "goto_sq", "get_range", "throw_grenade",
	"spend_hop", "uplift", "check_cards_auto_flip", "flip_card", "unflip_card",
	"set_mode", "init_game", "init_codex", "opp_turn", "wait", "inc_ammo",
	"give_ammo", "reload", "pick", "add_any_card", "level_up",
	"is_card_available", "newbnk", "bget", "bset", "savbnk", "defbtn",
	"btn", "btnp", "btnr", "fire", "mk_bullet", "hit", "ev_hit", "xpl",
	"add_soul", "activate_soul", "add_soul_slot", "add_scepter",
	"activate_scepter", "recal_scepters", "scepters", "TEST_SOULS", "MOUSE",
	"remove_buts", "get_allies", "get_free_squares", "get_nearest_free_square",
	"black_mist_check", "get_dodge", "refill_ammo", "can_reload", "need_reload",
	"clip", "is_free", "flr", "t", "chamber", "stack", "hero",
}
for _, name in ipairs(api_wanted) do
	log("SKA|" .. name .. "|" .. (known[name] and "YES" or "no"))
end

local function dump(tag, tbl)
	local n = 0
	if type(tbl) == "table" and type(all) == "function" then
		for a, b in all(tbl) do
			log(tag .. "|" .. sv(iter_value(a, b)))
			n = n + 1
			if n >= 2000 then break end
		end
	end
	log("SK-REWORK: " .. tag .. " count=" .. sv(n))
end
if type(gimme) == "function" then
	dump("SKG", gimme("global"))
	dump("SKR", gimme("replaceable"))
	dump("SKF", gimme("forbidden"))
end

-- ---------- 3. stable hook registration -------------------------------
local hooks_ok = 0
local function hookf(target, fn, id, use_prepend)
	if use_prepend then
		if type(prepend) ~= "function" then return false end
		prepend(target, fn, id)
	else
		if type(append) ~= "function" then return false end
		append(target, fn, id)
	end
	hooks_ok = hooks_ok + 1
	log("SKH|" .. target .. "|" .. id)
	return true
end

local function destroy_group(group)
	if type(group) ~= "table" or type(group.ents) ~= "table" then return end
	if type(del) ~= "function" or type(ents) ~= "table" then return end
	for i = 1, 8 do
		local e = group.ents[i]
		if e ~= nil then del(ents, e) end
	end
end

-- ---------- 4. Dev panel v2: pages, real CLOSE, live actions ----------
-- Run 5 proved the engine ignores del(ents, e) on mk_text_but groups: the
-- panel "closed" itself while its visuals stayed (open=true then open=false
-- in the same frame, frozen brown buttons for the owner). The engine's own
-- remove_buts() is the proven primitive (disgraced_justice, glac terminal),
-- so v2 clears through it and rebuilds the header on the next turn.
local function native_button(x, y, w, label, fn, store)
	if type(mk_text_but) ~= "function" then return nil end
	local group = mk_text_but(x, y, w, label, fn)
	if store and type(group) == "table" then
		store[#store + 1] = group
	end
	if type(group) == "table" and type(group.ents) == "table" and group.ents[1] then
		local n = capped("native_button_fields")
		if n then dump_fields("dev_button_" .. sv(n), group.ents[1], 8, "SKI") end
	end
	return group
end

local function clear_native_buttons(reason)
	if offer_active and reason ~= "offer_guard" then
		-- An offer/level-up screen owns the button layer right now: clearing
		-- here would delete the engine's own card buttons. Defer instead.
		local n = capped("panel_offer_guard")
		if n then log("SKUI|panel|deferred=offer_active|reason=" .. sv(reason)) end
		return
	end
	if type(remove_buts) == "function" then
		ecall("remove_buts", remove_buts)
		log("SKUI|panel|clear=remove_buts|reason=" .. sv(reason))
	else
		if type(del) == "function" and type(ents) == "table" then
			for i = 1, 24 do
				local g = dev_actions[i]
				if g and type(g.ents) == "table" then
					for j = 1, 8 do
						if g.ents[j] then del(ents, g.ents[j]) end
					end
				end
			end
		end
		log("SKUI|panel|clear=del_fallback|reason=" .. sv(reason))
	end
	dev_open = false
	panel_present = false
	dev_header = nil
	for i = 1, 24 do dev_actions[i] = nil end
end

-- --- actions -----------------------------------------------------------
local function cheat_ammo_reserve()
	local before = ammo
	ecall("inc_ammo", inc_ammo, 3)
	log("SKE|cheat_ammo|kind=reserve|amount=3|ammo_before=" .. sv(before)
		.. "|ammo=" .. sv(ammo) .. "|hero_ammo=" .. sv(hero and hero.ammo))
end

local function cheat_reload()
	local before = chamber
	if type(reload) == "function" then
		ecall("reload", reload)
	elseif type(refill_ammo) == "function" then
		ecall("refill_ammo", refill_ammo)
	end
	log("SKE|cheat_reload|chamber_before=" .. sv(before) .. "|chamber=" .. sv(chamber)
		.. "|ammo=" .. sv(ammo) .. "|need_reload=" .. sv(need_reload))
end

local function cheat_clip()
	if type(stack) ~= "table" then
		log("SKE|cheat_clip|status=no_stack")
		return
	end
	-- GUESSED fields (live stack dump shows chamber_max=1, ammo_regen,
	-- grenades_max; ammo_max is a card field). Plain field writes only.
	if type(stack.chamber_max) == "number" then
		stack.chamber_max = stack.chamber_max + 1
	end
	if type(stack.ammo_max) == "number" then
		stack.ammo_max = stack.ammo_max + 1
	end
	log("SKE|cheat_clip|chamber_max=" .. sv(stack.chamber_max)
		.. "|ammo_max=" .. sv(stack.ammo_max) .. "|grenades_max=" .. sv(stack.grenades_max))
end

local function eligible_cards()
	local pool = {}
	if type(CARDS) ~= "table" or type(all) ~= "function" then return pool end
	local n = 0
	for a, b in all(CARDS) do
		local ca = iter_value(a, b)
		n = n + 1
		if n > MAX_CARDS then break end
		if type(ca) == "table" and ca.id ~= nil then
			local ok = true
			if type(is_card_available) == "function" then
				local r = is_card_available(ca)
				if r == false then ok = false end
			end
			if ok then pool[#pool + 1] = ca end
		end
	end
	log("SKUI|card|pool=" .. sv(#pool) .. "|of=" .. sv(n))
	return pool
end

-- Piece-related cards (the owner's "card from pieces, say knight" ask): a card
-- whose id mentions a PIECES name, or that carries a summon-family field.
local function card_is_piece_related(ca)
	if type(ca) ~= "table" then return false end
	if type(ca.allies) == "table" then return true end
	local summon_fields = {"summoner", "holoking", "onboarding", "rapunzel", "small_key"}
	for i = 1, #summon_fields do
		if ca[summon_fields[i]] ~= nil then return true end
	end
	local id_s = sv(ca.id)
	if id_s == "nil" then return false end
	local lower = id_s:lower()
	if type(PIECES) == "table" and type(all) == "function" then
		local n = 0
		for a, b in all(PIECES) do
			local p = iter_value(a, b)
			n = n + 1
			if n > MAX_PIECES then break end
			if type(p) == "table" and type(p.name) == "string" and #p.name > 2 then
				if lower:find(p.name:lower(), 1, true) ~= nil then return true end
			end
		end
	end
	return false
end

local function apply_card_filter(pool)
	if card_filter ~= "piece" then return pool end
	local out = {}
	for i = 1, #pool do
		if card_is_piece_related(pool[i]) then out[#out + 1] = pool[i] end
	end
	log("SKUI|card|filter=piece|kept=" .. sv(#out) .. "|of=" .. sv(#pool))
	return out
end

local function take_card_by_id(card_id)
	if type(CARDS) ~= "table" or type(all) ~= "function" or type(add_card) ~= "function" then
		log("SKE|cheat_card|status=api_unavailable")
		return
	end
	local n = 0
	for a, b in all(CARDS) do
		local ca = iter_value(a, b)
		n = n + 1
		if n > MAX_CARDS then break end
		if type(ca) == "table" and sv(ca.id) == sv(card_id) then
			ecall("add_card", add_card, ca)
			log("SKE|cheat_card|mode=list|id=" .. sv(ca.id))
			-- summon-family cards (W8): if the card carries an `allies` list,
			-- bring the piece in as the game's own summon-family would.
			if type(ca.allies) == "table" and type(ca.allies[1]) == "number" then
				spawn_ally(ca.allies[1], "card:" .. sv(ca.id))
			end
			return
		end
	end
	log("SKE|cheat_card|mode=list|status=id_not_found|id=" .. sv(card_id))
end

local function cheat_random_card()
	local pool = eligible_cards()
	if #pool == 0 then
		log("SKE|cheat_card|status=no_eligible_card")
		return
	end
	if card_mode == "list" then
		-- deterministic-but-varying index; the owner can page through and
		-- pick instead of this roll (LIST page in the panel).
		local pick_i = (prand() % #pool) + 1
		local ca = pool[pick_i]
		ecall("add_card", add_card, ca)
		log("SKE|cheat_card|mode=roll|id=" .. sv(ca and ca.id) .. "|pool=" .. sv(#pool))
		return
	end
	if type(pick) == "function" then
		local ca = ecall("pick", pick, {team = 0})
		if type(ca) == "table" then
			ecall("add_card", add_card, ca)
			log("SKE|cheat_card|mode=auto|id=" .. sv(ca.id) .. "|pool=" .. sv(#pool))
			return
		end
		-- cardless fallback (run-5 ask: "when i dont have card theres no
		-- random card i get"): browse the pool ourselves.
		log("SKE|cheat_card|mode=auto|status=pick_returned_nil|fallback=pool")
	else
		log("SKE|cheat_card|mode=auto|status=pick_missing|fallback=pool")
	end
	local ca = pool[(prand() % #pool) + 1]
	ecall("add_card", add_card, ca)
	log("SKE|cheat_card|mode=fallback|id=" .. sv(ca and ca.id) .. "|pool=" .. sv(#pool))
end

local function cheat_god_mode()
	god_mode = not god_mode
	if god_mode and hero and type(hero.hp) == "number" then hero.hp = 99 end
	persist_cfg(true)
	log("SKUI|panel|god_mode=" .. sv(god_mode))
	reopen_page(1)
end

-- damage/crit knobs (W3): cycle presets, persisted immediately.
local DMG_PRESETS = {{1, 1}, {1, 2}, {1, 3}, {2, 3}, {1, 5}}
local CRIT_PRESETS = {0, 10, 25, 50, 100}
local dmg_preset_i, crit_preset_i = 1, 1

local function cheat_dmg_toggle()
	cfg.on = (cfg.on == 1) and 0 or 1
	if cfg.on == 1 then
		cfg.dmg_min, cfg.dmg_max = DMG_PRESETS[dmg_preset_i][1], DMG_PRESETS[dmg_preset_i][2]
		cfg.crit = CRIT_PRESETS[crit_preset_i]
		cfg.pierce_crit = 1
	end
	persist_cfg(true)
	log(cfg_line())
	reopen_page(1)
end

local function cheat_dmg_cycle()
	dmg_preset_i = dmg_preset_i + 1
	if dmg_preset_i > #DMG_PRESETS then dmg_preset_i = 1 end
	cfg.dmg_min, cfg.dmg_max = DMG_PRESETS[dmg_preset_i][1], DMG_PRESETS[dmg_preset_i][2]
	cfg.on = 1
	persist_cfg(true)
	log(cfg_line())
	reopen_page(1)
end

local function cheat_crit_cycle()
	crit_preset_i = crit_preset_i + 1
	if crit_preset_i > #CRIT_PRESETS then crit_preset_i = 1 end
	cfg.crit = CRIT_PRESETS[crit_preset_i]
	cfg.on = 1
	persist_cfg(true)
	log(cfg_line())
	reopen_page(1)
end

local function cheat_card_mode()
	card_mode = (card_mode == "list") and "auto" or "list"
	persist_cfg(true)
	log("SKUI|panel|card_mode=" .. sv(card_mode))
	reopen_page(1)
end

local function cheat_safe_toggle()
	safe_mode = (safe_mode == 1) and 0 or 1
	safe_budget = 1
	safe_used = {}
	persist_cfg(true)
	log("SKUI|panel|safe=" .. sv(safe_mode) .. "|budget=" .. sv(safe_budget))
	reopen_page(1)
end

-- --- page builders -----------------------------------------------------
-- Rebuild the panel on a given page. Used after every state change so the
-- button labels always show the CURRENT state (run-5 ask: "when I press it
-- it doesnt change state to on or off in text").
reopen_page = function(page)
	dev_page = page or 1
	clear_native_buttons("reopen_page" .. sv(dev_page))
	ensure_dev_panel()
	make_dev_actions()
end

local function pager_rows()
	dev_page = 1
	card_page = 1
	reopen_page(1)
end

make_dev_actions = function()
	if type(mk_text_but) ~= "function" then return end
	if offer_active then
		local n = capped("panel_offer_guard_open")
		if n then log("SKUI|panel|deferred=offer_active|action=open") end
		return
	end
	dev_open = true
	panel_present = true
	local sw = (type(MCW) == "number" and MCW) or 320
	local width, gap = 62, 5
	local total = width * 3 + gap * 2
	local x0 = (sw - total) / 2
	x0 = ifloor(x0)
	local y = (dev_y or 0) + 10
	local y2 = y + 10
	local y3 = y + 20
	local y4 = y + 30
	if dev_page == 2 then
		make_card_page(x0, y, width, gap)
		return
	end
	if dev_page == 3 then
		make_spawn_page(x0, y, width, gap)
		return
	end
	local cols, cw, cg = 4, 55, 4
	local total_w = cols * cw + (cols - 1) * cg
	local cx = ifloor((sw - total_w) / 2)
	local cx2, cx3, cx4 = cx + cw + cg, cx + 2 * (cw + cg), cx + 3 * (cw + cg)
	native_button(cx, y, cw, "+3 AMMO", cheat_ammo_reserve, dev_actions)
	native_button(cx2, y, cw, "RELOAD", cheat_reload, dev_actions)
	native_button(cx3, y, cw, "CLIP+", cheat_clip, dev_actions)
	native_button(cx4, y, cw, safe_mode == 1 and "SAFE:on" or "SAFE:off", cheat_safe_toggle, dev_actions)
	native_button(cx, y2, cw, card_mode == "list" and "CARD:LIST" or "CARD:AUTO", cheat_card_mode, dev_actions)
	native_button(cx2, y2, cw, "CARD NOW", cheat_random_card, dev_actions)
	native_button(cx3, y2, cw, "CARDS>", function()
		card_page = 1
		reopen_page(2)
	end, dev_actions)
	native_button(cx4, y2, cw, "SPAWN...", function()
		spawn_pick = nil
		reopen_page(3)
	end, dev_actions)
	native_button(cx, y3, cw, god_mode and "GOD:on" or "GOD:off", cheat_god_mode, dev_actions)
	native_button(cx2, y3, cw, cfg.on == 1 and "DMG:on" or "DMG:off", cheat_dmg_toggle, dev_actions)
	native_button(cx3, y3, cw, "DMG+", cheat_dmg_cycle, dev_actions)
	native_button(cx4, y3, cw, "CRIT+", cheat_crit_cycle, dev_actions)
	native_button(cx, y4, cw, "CLOSE", function()
		clear_native_buttons("close_clicked")
		log("SKUI|panel|open=false")
	end, dev_actions)
	log("SKUI|panel|open=true|page=1|buttons=" .. sv(#dev_actions))
	log(cfg_line())
end

make_card_page = function(x0, y, width, gap)
	local pool = apply_card_filter(eligible_cards())
	local sw = (type(MCW) == "number" and MCW) or 320
	local pages = 1
	if #pool > PANEL_PAGE_BUTTONS then
		pages = ifloor((#pool + PANEL_PAGE_BUTTONS - 1) / PANEL_PAGE_BUTTONS)
	end
	if card_page > pages then card_page = pages end
	if card_page < 1 then card_page = 1 end
	local first = (card_page - 1) * PANEL_PAGE_BUTTONS + 1
	local per_row = 3
	local card_w, card_gap = 100, 5
	local card_x0 = ifloor((sw - (per_row * card_w + (per_row - 1) * card_gap)) / 2)
	if card_x0 < 0 then card_x0 = 0 end
	for i = 0, PANEL_PAGE_BUTTONS - 1 do
		local ca = pool[first + i]
		if ca == nil then break end
		local col = i % per_row
		local row = ifloor(i / per_row)
		local label = sv(ca.id)
		if #label > 13 then label = label:sub(1, 13) end
		local card_id = sv(ca.id)
		native_button(card_x0 + col * (card_w + card_gap), y + row * 10, card_w, label, function()
			take_card_by_id(card_id)
			reopen_page(2)
		end, dev_actions)
	end
	local y4 = y + 22
	native_button(x0, y4, width, "<PREV", function()
		card_page = card_page - 1
		reopen_page(2)
	end, dev_actions)
	native_button(x0 + width + gap, y4, width, "NEXT>", function()
		card_page = card_page + 1
		reopen_page(2)
	end, dev_actions)
	native_button(x0 + 2 * (width + gap), y4, width, "<BACK", pager_rows, dev_actions)
	native_button(x0 + 3 * (width + gap), y4, width,
		card_filter == "piece" and "FILT:PIECE" or "FILT:ALL", function()
			card_filter = (card_filter == "piece") and "all" or "piece"
			card_page = 1
			log("SKUI|panel|card_filter=" .. sv(card_filter))
			reopen_page(2)
		end, dev_actions)
	log("SKUI|card|page=" .. sv(card_page) .. "/" .. sv(pages) .. "|pool=" .. sv(#pool)
		.. "|filter=" .. sv(card_filter))
end

make_spawn_page = function(x0, y, width, gap)
	local sw = (type(MCW) == "number" and MCW) or 320
	local names = {}
	if type(PIECES) == "table" and type(all) == "function" then
		local n = 0
		for a, b in all(PIECES) do
			local p = iter_value(a, b)
			n = n + 1
			if n > MAX_PIECES then break end
			if type(p) == "table" and type(p.type) == "number" and p.name ~= nil then
				names[#names + 1] = p
			end
		end
	end
	local shown = 0
	for i = 1, #names do
		if shown >= SPAWN_PICK_BUTTONS * 2 then break end
		local p = names[i]
		local col = (i - 1) % SPAWN_PICK_BUTTONS
		local row = ifloor((i - 1) / SPAWN_PICK_BUTTONS)
		local ptype = p.type
		local label = sv(p.name)
		if #label > 11 then label = label:sub(1, 11) end
		local pw, pg = 50, 2
		local px0 = ifloor((sw - (SPAWN_PICK_BUTTONS * pw + (SPAWN_PICK_BUTTONS - 1) * pg)) / 2)
		if px0 < 0 then px0 = 0 end
		native_button(px0 + (i - 1) * (pw + pg), y, pw, label, function()
			spawn_pick = ptype
			spawn_ally(ptype, "panel_pick")
			reopen_page(3)
		end, dev_actions)
		shown = shown + 1
	end
	native_button(x0, y + 12, width, "<BACK", pager_rows, dev_actions)
	log("SKUI|spawn|page=1|choices=" .. sv(shown) .. "|selected=" .. sv(spawn_pick))
end

ensure_dev_panel = function()
	if offer_active then
		local n = capped("panel_offer_guard_hdr")
		if n then log("SKUI|panel|deferred=offer_active|action=header") end
		return
	end
	if type(mk_text_but) ~= "function" then
		if not panel_creation_logged then
			log("SKUI|panel|available=false|reason=mk_text_but_missing")
			panel_creation_logged = true
		end
		return
	end
	if panel_present and dev_header ~= nil then
		return
	end
	dev_header = nil
	panel_present = false
	local screen_h = (type(MCH) == "number" and MCH) or 180
	dev_y = ((type(board_y) == "number" and board_y) or 0) + 16 * 8 + 3
	-- 4 action rows below the header need ~42 px of headroom, so clamp higher
	-- than build 6 did (run 5: y=148 with 2 rows fit, 4 rows would not).
	local last_y = screen_h - 52
	if dev_y > last_y then dev_y = last_y end
	if dev_y < 0 then dev_y = 0 end
	local screen_w = (type(MCW) == "number" and MCW) or 320
	local title = native_button(4, dev_y, 44, "SK DEV", function()
		if dev_open then
			clear_native_buttons("header_close")
			log("SKUI|panel|open=false")
		else
			make_dev_actions()
		end
	end)
	dev_header = title
	panel_present = title ~= nil
	if not panel_creation_logged then
		log("SKUI|panel|available=true|native=mk_text_but")
		panel_creation_logged = true
	end
	if dev_header and type(dev_header.ents) == "table" and dev_header.ents[1] then
		log("SKUI|panel|width=" .. sv(screen_w) .. "|y=" .. sv(dev_y))
	end
end


-- ---------- 5. Mod-menu legend + Back via native menu hook -------------
-- Run 5 harvested the REAL menu button ids: play, options, codex, credits,
-- quit, mods, throne, endless, chase, charnier, tutorial, back, save_back,
-- plus the mod-list rows " ON "/"OFF " and the arrow glyphs. The Build-6
-- trigger compared MODLIST titles to ids, which can never match (that is
-- why SKUI|menu|widgets_added never appeared in the log). v7 arms on the
-- ids that actually exist, so the legend finally shows up.
local menu_widgets_created = false
local menu_widget_groups = {}
local pending_menu_button = false
local pending_menu_button_id = nil
local menu_armed = false

local MENU_ARM_IDS = {["mods"] = true, ["save_back"] = true, [" ON "] = true,
	["OFF "] = true, ["é"] = true, ["è"] = true, ["back"] = true}
local MENU_DISARM_IDS = {["play"] = true, ["options"] = true, ["codex"] = true,
	["credits"] = true, ["quit"] = true, ["throne"] = true, ["endless"] = true,
	["chase"] = true, ["charnier"] = true, ["tutorial"] = true}

local function menu_id_is(id, set)
	if id == nil then return false end
	local id_s = sv(id)
	if set[id_s] then return true end
	-- tolerate a numeric prefix like "2. mods" or a trimmed variant
	local trimmed = id_s:gsub("^%d+%.%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
	return set[trimmed] == true
end

local function clear_menu_widgets()
	for i = 1, 4 do
		local group = menu_widget_groups[i]
		if group == nil then break end
		-- Only ever our own text buttons: the del() route is used here (NOT
		-- remove_buts, which would wipe the engine's own menu buttons).
		destroy_group(group)
		menu_widget_groups[i] = nil
	end
	menu_widgets_created = false
end

local function add_mod_menu_widgets(id)
	if menu_widgets_created then return end
	if not menu_armed then return end
	if type(mk_text_but) ~= "function" then return end
	menu_widgets_created = true
	local sw = (type(MCW) == "number" and MCW) or 320
	local back = native_button(2, 2, 42, "< BACK", function()
		if type(init_menu) == "function" then
			ecall("init_menu", init_menu)
		end
		log("SKUI|menu|back_clicked=true")
	end, menu_widget_groups)
	local legend = native_button(48, 2, sw - 52, "WHITE=ON  BLACK=OFF  (UP/DN=LOAD ORDER)",
		function() end, menu_widget_groups)
	-- The Terminal/Royal-Card-Lab pattern for a non-interactive native label.
	if legend and type(legend.ents) == "table" and legend.ents[1] then
		legend.ents[1].button = false
	end
	log("SKUI|menu|widgets_added=true|entry=" .. sv(id) .. "|back=" .. sv(back ~= nil))
end

-- ---------- 6. base diagnostic hooks ----------------------------------
-- SK-REWORK: append new_turn for world state, panel recovery, and God Mode HP refresh.
hookf("new_turn", function()
	offer_active = false
	ensure_dev_panel()
	bank_flush(false)
	if god_mode and hero and type(hero.hp) == "number" and hero.hp < 99 then hero.hp = 99 end
	local n = capped("turn")
	if not n then return end
	local bads_n, bullets_n = 0, 0
	if bads and type(all) == "function" then
		for _a, _b in all(bads) do bads_n = bads_n + 1; if bads_n >= 2000 then break end end
	end
	if bullets and type(all) == "function" then
		for _a, _b in all(bullets) do bullets_n = bullets_n + 1; if bullets_n >= 2000 then break end end
	end
	local px, py = "?", "?"
	if hero and hero.sq then px, py = sv(hero.sq.px), sv(hero.sq.py) end
	log("SKW|turn=" .. sv(n) .. "|bads=" .. sv(bads_n) .. "|bullets=" .. sv(bullets_n)
		.. "|hero_px=" .. px .. "|hero_py=" .. py .. "|ammo=" .. sv(ammo)
		.. "|chamber=" .. sv(chamber) .. "|free_souls=" .. sv(hero and hero.free_souls))
	if n == 1 then
		dump_fields("hero", hero)
		if hero and hero.sq then dump_fields("hero.sq", hero.sq) end
		if type(stack) == "table" then dump_fields("stack", stack) end
		if type(scepters) == "table" then dump_fields("scepters", scepters, 12, "SKS") end
	end
end, "sk-rework:turn")

-- SK-REWORK: append new_level to timestamp floor transitions.
hookf("new_level", function(...)
	local n = capped("level")
	if n then log("SKE|new_level|n=" .. sv(n)) end
end, "sk-rework:level")

-- SK-REWORK: append setup_piece to capture real piece fields.
hookf("setup_piece", function(e, ...)
	local n = capped("setup_piece")
	if not n then return end
	local typ, hp = "?", "?"
	if e then typ, hp = sv(e.type), sv(e.hp) end
	log("SKE|setup_piece|n=" .. sv(n) .. "|type=" .. typ .. "|hp=" .. hp)
	if n <= 3 then dump_fields("piece", e) end
end, "sk-rework:setup_piece")

-- SK-REWORK: append add_card to observe granted/selected cards.
hookf("add_card", function(ca, ...)
	local n = capped("add_card")
	if not n then return end
	local id, pwe = "?", "?"
	if type(ca) == "table" then id, pwe = sv(ca.id), sv(ca.pwe)
	elseif ca ~= nil then id = sv(ca) end
	log("SKE|add_card|n=" .. sv(n) .. "|id=" .. id .. "|pwe=" .. pwe)
	if n <= 5 and type(ca) == "table" then dump_fields("card", ca) end
end, "sk-rework:add_card")

-- SK-REWORK: append init_game to install native panel buttons in a run.
hookf("init_game", function(...)
	offer_active = false
	dev_open = false
	for i = 1, 16 do dev_actions[i] = nil end
	ensure_dev_panel()
	local n = capped("init_game")
	if n then log("SKE|init_game|n=" .. sv(n)) end
end, "sk-rework:init_game")

-- God Mode protects against the confirmed hit(p,dmg,tags) route; a huge HP
-- refill also covers normal turns. Other death routes remain a live-probe item.
if known["hit"] then
	-- SK-REWORK: prepend hit for God Mode (HP refill + Mist-style dodge on a
	-- lethal hit, run-5 ask) and for damage tracing.
	hookf("hit", function(p, dmg, tags, ...)
		local amt = (type(dmg) == "number") and dmg or 0
		if god_mode and p == hero and type(p.hp) == "number" then
			local lethal = amt >= p.hp
			p.hp = p.hp + amt
			if lethal then dodge_king("lethal_hit") end
		end
		local n = capped("god_hit")
		if n then
			log_target("SKD", "hit", p, dmg, "|god_mode=" .. sv(god_mode)
				.. "|hp=" .. sv(type(p) == "table" and p.hp or nil))
		end
	end, "sk-rework:god-mode-hit", true)
end

-- Offer flow probes (observation only; no cap or offer behavior is changed).
local function offer_probe(name, a1, a2, a3)
	local n = capped("offer_" .. name)
	if not n then return end
	log("SKOF|" .. name .. "|n=" .. sv(n) .. "|a1=" .. sv(a1)
		.. "|a2=" .. sv(a2) .. "|a3=" .. sv(a3))
	if type(a1) == "table" then dump_fields(name .. "_arg1", a1, 20, "SKOF") end
	if type(a2) == "table" then dump_fields(name .. "_arg2", a2, 20, "SKOF") end
	if type(a3) == "table" then dump_fields(name .. "_arg3", a3, 16, "SKOF") end
	if name == "level_up" and type(a1) == "table" and type(a1.choices) == "table" then
		for i = 1, 20 do
			local choice = a1.choices[i]
			if choice == nil then break end
			if type(choice) == "table" then
				dump_fields("choice_" .. sv(i), choice, 20, "SKOF")
			end
		end
	end
end
if known["level_up"] then
	-- SK-REWORK: append level_up to observe draft filters/choices and to
	-- protect the engine's offer buttons from our panel's remove_buts().
	hookf("level_up", function(data, next_fn, ...)
		offer_active = true
		offer_probe("level_up", data, next_fn, nil)
	end, "sk-rework:offer-level-up")
end
if known["pick"] then
	-- SK-REWORK: append pick to observe offer eligibility filters.
	hookf("pick", function(filters, ...)
		offer_probe("pick", filters, nil, nil)
	end, "sk-rework:offer-pick")
end
if known["is_card_available"] then
	-- SK-REWORK: append is_card_available to log candidate card requirements.
	hookf("is_card_available", function(ca, ...)
		local n = capped("offer_available")
		if not n then return end
		local id = type(ca) == "table" and sv(ca.id) or sv(ca)
		log("SKOF|is_card_available|n=" .. sv(n) .. "|id=" .. id
			.. "|special=" .. sv(type(ca) == "table" and ca.special)
			.. "|wand=" .. sv(type(ca) == "table" and ca.wand)
			.. "|soul_slot=" .. sv(type(ca) == "table" and ca.soul_slot)
			.. "|need_soul=" .. sv(type(ca) == "table" and ca.need_soul))
		if type(ca) == "table" and n <= 10 then dump_fields("availability", ca, 16, "SKOF") end
	end, "sk-rework:offer-availability")
end

-- Dynamic soul / scepter flow probes; never modify their arguments.
local function hook_soul_scepter(name)
	if not known[name] then return end
	-- SK-REWORK: append soul/scepter functions for read-only flow tracing.
	hookf(name, function(a1, a2, a3, a4, ...)
		local n = capped("soul_" .. name)
		if not n then return end
		log("SKS|" .. name .. "|n=" .. sv(n) .. "|a1=" .. sv(a1)
			.. "|a2=" .. sv(a2) .. "|a3=" .. sv(a3) .. "|a4=" .. sv(a4)
			.. "|free_souls=" .. sv(hero and hero.free_souls))
		if type(a1) == "table" then dump_fields(name .. "_arg1", a1, 16, "SKS") end
		if type(a2) == "table" then dump_fields(name .. "_arg2", a2, 16, "SKS") end
	end, "sk-rework:" .. name)
end
for _, fn_name in ipairs({"add_soul", "activate_soul", "add_soul_slot", "remove_soul_slot",
	"exhaust_soul", "add_scepter", "activate_scepter", "recal_scepters", "get_scepter"}) do
	hook_soul_scepter(fn_name)
end

-- Damage / bullet pipeline probes (observation only).
if known["fire"] then
	-- SK-REWORK: append fire to sample bullets after a shotgun fire call.
	hookf("fire", function(...)
		local n = capped("damage_fire")
		if not n then return end
		log("SKD|fire|n=" .. sv(n) .. "|ammo=" .. sv(ammo) .. "|chamber=" .. sv(chamber)
			.. "|bullets=" .. sv(type(bullets) == "table" and #bullets or "?"))
		if type(bullets) == "table" and type(all) == "function" then
			local i = 0
			for a, b in all(bullets) do
				local bullet = iter_value(a, b)
				i = i + 1
				if type(bullet) == "table" then
					log("SKD|bullet|shot_n=" .. sv(n) .. "|idx=" .. sv(i)
						.. "|dmg=" .. sv(bullet.dmg) .. "|pierce=" .. sv(bullet.pierce)
						.. "|shot=" .. sv(bullet.shot) .. "|x=" .. sv(bullet.x)
						.. "|y=" .. sv(bullet.y) .. "|life=" .. sv(bullet.life))
				end
				if i >= 30 then break end
			end
		end
	end, "sk-rework:damage-fire")
end

-- W3: the configured damage/crit roll. Run 5 proved bullets carry dmg/pierce
-- and that mk_bullet(x, y, angle, life) is the creation point, so the roll is
-- applied to the freshly created bullet (last entry of the live `bullets`).
if known["mk_bullet"] then
	-- SK-REWORK: append mk_bullet to apply the configured damage/crit values.
	hookf("mk_bullet", function(a1, a2, a3, a4, ...)
		if cfg.on ~= 1 then return end
		local n = capped("dmg_apply")
		if not n then return end
		local b = (type(bullets) == "table") and bullets[#bullets] or nil
		if type(b) ~= "table" then
			log("SKD|dmg|n=" .. sv(n) .. "|status=no_bullet_table")
			return
		end
		local before = b.dmg
		local dmg, crit = roll_damage(b.pierce)
		b.dmg = dmg
		log("SKD|dmg|n=" .. sv(n) .. "|before=" .. sv(before) .. "|after=" .. sv(b.dmg)
			.. "|crit=" .. sv(crit) .. "|pierce=" .. sv(b.pierce)
			.. "|range=" .. sv(cfg.dmg_min) .. "-" .. sv(cfg.dmg_max)
			.. "|critpct=" .. sv(cfg.crit) .. "|critdmg=" .. sv(cfg.crit_dmg))
	end, "sk-rework:damage-config")
end

local function hook_damage_probe(name)
	if not known[name] or name == "hit" or name == "fire" then return end
	-- SK-REWORK: append the named damage function for read-only argument tracing.
	hookf(name, function(a1, a2, a3, a4, ...)
		local n = capped("damage_" .. name)
		if not n then return end
		log("SKD|" .. name .. "|n=" .. sv(n) .. "|a1=" .. sv(a1)
			.. "|a2=" .. sv(a2) .. "|a3=" .. sv(a3) .. "|a4=" .. sv(a4))
		if type(a1) == "table" then dump_fields(name .. "_arg1", a1, 12, "SKD") end
		if type(a2) == "table" then dump_fields(name .. "_arg2", a2, 12, "SKD") end
	end, "sk-rework:damage-" .. name)
end
for _, fn_name in ipairs({"mk_bullet", "ev_hit", "damage", "damages", "fx_dmg",
	"bleed_dmg", "hop_dmg", "xpl", "xpl_king"}) do
	hook_damage_probe(fn_name)
end

-- Menu state probe + direct native menu button hook. The ID is logged so the
-- live run can validate detection of actual MODLIST-entry buttons.
if known["init_menu"] then
	-- SK-REWORK: init_menu hooks log menu state and clear stale native helper buttons.
	hookf("init_menu", function(...)
		local n = capped("menu_state")
		if n then
			log("SKUI|menu_state|n=" .. sv(n) .. "|menu=" .. sv(menu) .. "|mMenu=" .. sv(mMenu))
			if type(menu) == "table" then dump_fields("menu", menu, 16, "SKUI") end
			if type(mMenu) == "table" then dump_fields("mMenu", mMenu, 16, "SKUI") end
		end
	end, "sk-rework:menu-state")
	-- SK-REWORK: init_menu hooks log menu state and clear stale native helper buttons.
	hookf("init_menu", function(...)
		clear_menu_widgets()
	end, "sk-rework:menu-clear", true)
end
if known["mk_menu_but"] then
	-- SK-REWORK: prepend mk_menu_but to capture the upcoming native menu button.
	hookf("mk_menu_but", function(id, x, y, w, h, ...)
		pending_menu_button = true
		pending_menu_button_id = id
	end, "sk-rework:menu-button-before", true)
	-- SK-REWORK: append add to inspect the actual menu button fields (Terminal pattern).
	if known["add"] then
		-- SK-REWORK: cap the actual menu-button field probe while preserving the captured ID.
		hookf("add", function(tbl, e, ...)
			if not pending_menu_button then return end
			pending_menu_button = false
			local n = capped("menu_button_fields")
			if not n then return end
			log("SKI|menu_but|n=" .. sv(n) .. "|id=" .. sv(pending_menu_button_id))
			dump_fields("menu_but_" .. sv(n), e, 24, "SKI")
		end, "sk-rework:menu-button-fields")
	end
	-- SK-REWORK: append mk_menu_but to probe IDs and attach native Back/legend widgets.
	hookf("mk_menu_but", function(id, x, y, w, h, ...)
		local n = capped("menu_button")
		if n then
			log("SKI|menu_button|n=" .. sv(n) .. "|id=" .. sv(id) .. "|x=" .. sv(x)
				.. "|y=" .. sv(y) .. "|w=" .. sv(w) .. "|h=" .. sv(h))
		end
		pending_menu_button = false
		if menu_id_is(id, MENU_DISARM_IDS) then
			clear_menu_widgets()
			menu_armed = false
		elseif menu_id_is(id, MENU_ARM_IDS) then
			-- the mod-list scene is on screen (or being built): show helper
			menu_armed = true
			add_mod_menu_widgets(id)
		end
	end, "sk-rework:mod-menu-ui")
end

-- ---------- 7. READY — anything below is post-marker probe work --------
log("SK-REWORK: READY build=" .. sv(BUILD) .. " hooks=" .. sv(hooks_ok)
	.. " globals=" .. sv(n_global))

-- ---------- 8. §0.7 static probes (post-READY) -------------------------
local card_count = 0
if type(CARDS) == "table" and type(all) == "function" then
	for a, b in all(CARDS) do
		local c = iter_value(a, b)
		card_count = card_count + 1
		if type(c) == "table" and card_count <= MAX_CARDS then
			local card_id = sv(c.id)
			log("SKC|" .. card_id .. "|gid=" .. sv(c.gid) .. "|ext=" .. sv(c.ext)
				.. "|pwe=" .. sv(c.pwe) .. "|name=" .. sv(c.name)
				.. "|special=" .. sv(c.special) .. "|wand=" .. sv(c.wand))
			local field_count = 0
			for k, v in pairs(c) do
				field_count = field_count + 1
				if field_count > MAX_CARD_FIELDS then
					log("SKCF|" .. card_id .. "|truncated=true|top_fields=" .. sv(field_count - 1))
					break
				end
				log("SKCF|" .. card_id .. "|" .. sv(k) .. "=" .. sv(v))
				if type(v) == "table" then
					local sub_count = 0
					for k2, v2 in pairs(v) do
						sub_count = sub_count + 1
						if sub_count > MAX_CARD_SUBFIELDS then
							log("SKCF|" .. card_id .. "|" .. sv(k) .. ".truncated=true")
							break
						end
						log("SKCF|" .. card_id .. "|" .. sv(k) .. "." .. sv(k2) .. "=" .. sv(v2))
						if type(v2) == "table" then
							local deep_count = 0
						for k3, v3 in pairs(v2) do
							deep_count = deep_count + 1
							if deep_count > 16 then
								log("SKCF|" .. card_id .. "|" .. sv(k) .. "." .. sv(k2) .. ".truncated=true")
								break
							end
							log("SKCF|" .. card_id .. "|" .. sv(k) .. "." .. sv(k2) .. "." .. sv(k3) .. "=" .. sv(v3))
						end
						end
					end
				end
			end
			if c.special ~= nil or c.wand ~= nil or c.soul_slot ~= nil or c.need_soul ~= nil then
				log("SKOF|candidate|id=" .. card_id .. "|special=" .. sv(c.special)
					.. "|wand=" .. sv(c.wand) .. "|soul_slot=" .. sv(c.soul_slot)
					.. "|need_soul=" .. sv(c.need_soul))
			end
		end
		if card_count >= MAX_CARDS then break end
	end
end
log("SK-REWORK: SKC count=" .. sv(card_count))
log("SKA2|probe|cards=done")

if type(EXCLUDE) == "table" and type(all) == "function" then
	local ex_count = 0
	for a, b in all(EXCLUDE) do
		local pair = iter_value(a, b)
		ex_count = ex_count + 1
		if type(pair) == "table" then
			log("SKCF|__EXCLUDE__|pair=" .. sv(pair[1]) .. "<>" .. sv(pair[2]))
		end
		if ex_count >= MAX_EXCLUDES then break end
	end
	log("SKCF|__EXCLUDE__|count=" .. sv(ex_count))
end
log("SKA2|probe|exclude=done")

-- Soul, scepter, and piece schemas; no game state is altered.
if type(PIECES) == "table" and type(all) == "function" then
	local piece_count = 0
	for a, b in all(PIECES) do
		local p = iter_value(a, b)
		piece_count = piece_count + 1
		if type(p) == "table" then
			log("SKS|piece|type=" .. sv(p.type) .. "|name=" .. sv(p.name)
				.. "|hp=" .. sv(p.hp) .. "|tempo=" .. sv(p.tempo)
				.. "|danger=" .. sv(p.danger))
			if piece_count <= 20 then dump_fields("piece_" .. sv(p.type), p, 12, "SKS") end
		end
		if piece_count >= MAX_PIECES then break end
	end
	log("SKS|pieces|count=" .. sv(piece_count))
end
if type(TEST_SOULS) == "table" then dump_fields("TEST_SOULS", TEST_SOULS, 32, "SKS") end
if type(scepters) == "table" then dump_fields("scepters", scepters, 24, "SKS")
else log("SKS|scepters|available=false") end
if type(hero) == "table" then
	log("SKS|hero|free_souls=" .. sv(hero.free_souls) .. "|hp=" .. sv(hero.hp))
end

log("SKA2|probe|souls=done")

-- Persistence probe and configuration read. Runs BEFORE the input probe
-- because it is safe and its data was lost when run 4 crashed later in the
-- chain (no SKUI|bank line ever reached the log).
if type(newbnk) == "function" and type(bget) == "function" and type(bset) == "function" then
	ecall("newbnk", newbnk, 128, 64, 4)
	bank_ready = true
	local magic = bget(0, 0)
	local stored_safe = 0
	if magic == 505 then
		god_mode = (bget(1, 0) == 1)
		local on = bget(2, 0)
		if on == 0 or on == 1 then cfg.on = on end
		local lo = bget(3, 0)
		if type(lo) == "number" and lo >= 0 then cfg.dmg_min = lo end
		local hi = bget(4, 0)
		if type(hi) == "number" and hi >= 0 then cfg.dmg_max = hi end
		local cr = bget(5, 0)
		if type(cr) == "number" and cr >= 0 then cfg.crit = cr end
		local cd = bget(6, 0)
		if type(cd) == "number" and cd >= 1 then cfg.crit_dmg = cd end
		local pc = bget(7, 0)
		if pc == 0 or pc == 1 then cfg.pierce_crit = pc end
		card_mode = (bget(8, 0) == 1) and "list" or "auto"
		local sm = bget(9, 0)
		if sm == 0 or sm == 1 then stored_safe = sm end
		log("SKUI|bank|restored=true|magic=" .. sv(magic))
	else
		log("SKUI|bank|restored=false|magic=" .. sv(magic))
	end
	seed_rand()
	-- Write the magic + config so the NEXT boot restores everything (this is
	-- the read-back the run-5 report could not confirm yet).
	persist_cfg(true)
	safe_mode = stored_safe
	if safe_mode == 1 then safe_budget = 1 end
	log("SKUI|bank|ready=true|magic=" .. sv(bget(0, 0)) .. "|budget=" .. sv(safe_budget))
	log(cfg_line())
else
	log("SKUI|bank|ready=false")
end
local function tf(v) return (type(v) == "function") and "fn" or sv(v) end
log("SKUI|api|remove_buts=" .. tf(remove_buts) .. "|goto_sq=" .. tf(goto_sq)
	.. "|get_allies=" .. tf(get_allies) .. "|get_free_squares=" .. tf(get_free_squares)
	.. "|get_nearest_free_square=" .. tf(get_nearest_free_square)
	.. "|black_mist_check=" .. tf(black_mist_check) .. "|get_dodge=" .. tf(get_dodge)
	.. "|fx_spawn=" .. tf(fx_spawn) .. "|reload=" .. tf(reload)
	.. "|refill_ammo=" .. tf(refill_ammo) .. "|can_reload=" .. tf(can_reload)
	.. "|need_reload=" .. tf(need_reload) .. "|clip=" .. sv(clip)
	.. "|chamber=" .. sv(chamber) .. "|is_free=" .. tf(is_free) .. "|flr=" .. tf(flr))
if type(defbtn) == "function" then
	log("SKI|defbtn_api=available")
else
	log("SKI|defbtn_api=unavailable")
end
log("SKA2|probe|bank=done")

-- Input/button ecosystem. SAFETY CONTRACT (learned the hard way in run 4):
-- btn(<unknown>) is NOT a harmless false — it falls through to the engine's
-- input-id parser and a malformed id is a FATAL error that quits the game
-- ("ERR Button left for player 0 doesn't exist"; no pcall exists here).
-- Therefore btn() may only ever be called with strings the running game has
-- already published itself:
--   * named buttons seen live in INPUT_ASSIGNEMENT: validate cancel shoot
--     special reload unsafe — plus ctrl/unsafe/cancel, which run 4 already
--     confirmed return false without error.
--   * mouse codes bound in that same live dump: m:lb, m:rb, m:mb.
-- Anything else (left/right/middle/mouse4/mouse5/wheel/...) must NOT be
-- probed until a live dump confirms it. If the button space ever looks
-- different, this list is updated from evidence, never guessed.
local CONFIRMED_BTN_NAMES = {"validate", "cancel", "shoot", "special", "reload",
	"unsafe", "ctrl"}
local CONFIRMED_BTN_CODES = {"m:lb", "m:rb", "m:mb"}
local btn_probed = 0
if type(btn) == "function" then
	for _, name in ipairs(CONFIRMED_BTN_NAMES) do
		log("SKI|btn|" .. name .. "=" .. sv(btn(name)))
		btn_probed = btn_probed + 1
	end
	for _, code in ipairs(CONFIRMED_BTN_CODES) do
		log("SKI|btncode|" .. code .. "=" .. sv(btn(code)))
		btn_probed = btn_probed + 1
	end
	log("SKI|input|probed=" .. sv(btn_probed) .. "|source=confirmed_list|status=done")
else
	log("SKI|input|probed=0|btn_api=missing")
end

local input_globals = {"MOUSE", "INPUT_ASSIGNEMENT", "SHOOT_BUTTON", "RELOAD_BUTTON",
	"SPECIAL_BUTTON", "CONFIRM_BUTTON", "SNAP_KEY", "mcl", "mcr", "mlb", "mx", "my"}
for _, gname in ipairs(input_globals) do
	local gv = nil
	if gname == "MOUSE" then gv = MOUSE
	elseif gname == "INPUT_ASSIGNEMENT" then gv = INPUT_ASSIGNEMENT
	elseif gname == "SHOOT_BUTTON" then gv = SHOOT_BUTTON
	elseif gname == "RELOAD_BUTTON" then gv = RELOAD_BUTTON
	elseif gname == "SPECIAL_BUTTON" then gv = SPECIAL_BUTTON
	elseif gname == "CONFIRM_BUTTON" then gv = CONFIRM_BUTTON
	elseif gname == "SNAP_KEY" then gv = SNAP_KEY
	elseif gname == "mcl" then gv = mcl
	elseif gname == "mcr" then gv = mcr
	elseif gname == "mlb" then gv = mlb
	elseif gname == "mx" then gv = mx
	elseif gname == "my" then gv = my end
	if type(gv) == "table" then dump_fields(gname, gv, 24, "SKI")
	else log("SKI|global|" .. gname .. "=" .. sv(gv)) end
end
log("SKA2|probe|input=done")
log("SKA2|loadfile=" .. (type(loadfile) == "function" and "yes" or "no"))
log("SK-REWORK: PROBE done build=" .. sv(BUILD))
