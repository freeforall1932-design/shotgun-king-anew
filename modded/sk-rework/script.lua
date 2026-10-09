-- SK-REWORK build 7 — live-test helpers + §0.7 probes
-- =====================================================================
-- Build 5 crashed at boot in run 4 (btn("left") is fatal); Build 6 fixed
-- that, and Run 5 confirmed the probe chain completes in the real game.
-- Build 7 keeps the evidence-gated input probes and adds targeted test aids:
--   * reserve ammo, reload, and temporary chamber-capacity controls;
--   * direct live-card grants for Majestic Censer + Wand of Souls so the
--     owner can exercise soul/scepter paths without waiting for random offers;
--   * more careful native-button cleanup when the panel closes or a run starts.
-- ---------------------------------------------------------------------
-- Build 4 was live-proven (runs 1–3): load proof, MODLIST/CARDS map, and
-- five append() hooks. Build 7 keeps that harvest and improves testability:
--   * Native-button Dev panel: +ammo, a random eligible card, summon ally,
--     and a God Mode toggle. Settings use the standard per-mod bank API.
--   * Mod-menu legend + Back button, attached only when a menu button ID
--     matches a live MODLIST entry (no guessed screen-state constants).
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
local MAX_GROUP_ENTS = 32

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

local function is_live_entity(e)
	if e == nil then return false end
	if type(ents) ~= "table" or type(all) ~= "function" then return true end
	local n = 0
	for a, b in all(ents) do
		n = n + 1
		if iter_value(a, b) == e then return true end
		if n >= MAX_ENTS_SCAN then break end
	end
	return false
end

local function group_alive(group)
	if type(group) ~= "table" then return false end
	if type(group.ents) ~= "table" then return true end
	if type(all) == "function" then
		local scanned = 0
		for a, b in all(group.ents) do
			local e = iter_value(a, b)
			if e ~= nil then
				scanned = scanned + 1
				if is_live_entity(e) then return true end
				if scanned >= MAX_GROUP_ENTS then break end
			end
		end
		return false
	end
	for i = 1, MAX_GROUP_ENTS do
		local e = group.ents[i]
		if e ~= nil and is_live_entity(e) then return true end
	end
	return false
end

local function destroy_group(group)
	if type(group) ~= "table" or type(group.ents) ~= "table" then return end
	if type(del) ~= "function" or type(ents) ~= "table" then return end
	if type(all) == "function" then
		local scanned = 0
		for a, b in all(group.ents) do
			local e = iter_value(a, b)
			if e ~= nil then
				del(ents, e)
				scanned = scanned + 1
				if scanned >= MAX_GROUP_ENTS then break end
			end
		end
		return
	end
	for i = 1, MAX_GROUP_ENTS do
		local e = group.ents[i]
		if e ~= nil then del(ents, e) end
	end
end

-- ---------- 4. Phase 2c native-button Dev panel -----------------------
local dev_header = nil
local dev_actions = {}
local dev_open = false
local dev_y = nil
local god_mode = false
local bank_ready = false
local panel_creation_logged = false
local make_dev_actions

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

local function clear_dev_actions()
	for i = 1, 16 do
		local group = dev_actions[i]
		if group ~= nil then destroy_group(group) end
		dev_actions[i] = nil
	end
	dev_open = false
end

local function remove_dev_actions()
	clear_dev_actions()
	log("SKUI|panel|open=false")
end

local function nearby_free_square()
	if not (hero and hero.sq and type(gsq) == "function" and type(is_free) == "function") then return nil end
	local px, py = hero.sq.px, hero.sq.py
	if type(px) ~= "number" or type(py) ~= "number" then return nil end
	for dx = -1, 1 do
		for dy = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				local sq = gsq(px + dx, py + dy)
				if sq and (type(is_free) ~= "function" or is_free(sq)) then
					return sq
				end
			end
		end
	end
	return nil
end

local function first_spawnable_piece()
	if type(PIECES) ~= "table" or type(all) ~= "function" then return nil end
	local n = 0
	for a, b in all(PIECES) do
		local p = iter_value(a, b)
		n = n + 1
		if type(p) == "table" and type(p.type) == "number" and p.name ~= nil
			and type(p.behavior) == "table" then
			return p
		end
		if n >= MAX_PIECES then break end
	end
	return nil
end

local function cheat_ammo()
	if type(inc_ammo) == "function" then
		inc_ammo(3)
	elseif type(ammo) == "number" then
		ammo = ammo + 3
	end
	log("SKE|cheat_ammo|amount=3|ammo=" .. sv(ammo) .. "|hero_ammo=" .. sv(hero and hero.ammo))
end

local function cheat_reload()
	if type(reload) ~= "function" then
		log("SKE|cheat_reload|status=api_unavailable")
		return
	end
	if ammo == 0 then
		log("SKE|cheat_reload|status=no_reserve|ammo=0|chamber=" .. sv(chamber))
		return
	end
	reload()
	log("SKE|cheat_reload|status=called|ammo=" .. sv(ammo) .. "|chamber=" .. sv(chamber)
		.. "|chamber_max=" .. sv(stack and stack.chamber_max))
end

local function cheat_chamber_slot()
	if type(uplift) ~= "function" then
		log("SKE|cheat_chamber|status=api_unavailable")
		return
	end
	uplift({chamber_max=1})
	log("SKE|cheat_chamber|amount=1|chamber=" .. sv(chamber)
		.. "|chamber_max=" .. sv(stack and stack.chamber_max))
end

local function grant_debug_card(id)
	if type(new_card) ~= "function" or type(add_card) ~= "function" then
		log("SKE|cheat_test_card|id=" .. sv(id) .. "|status=api_unavailable")
		return false
	end
	local ca = new_card(id)
	if ca == nil then
		log("SKE|cheat_test_card|id=" .. sv(id) .. "|status=not_found")
		return false
	end
	add_card(ca)
	local actual_id = type(ca) == "table" and ca.id or id
	log("SKE|cheat_test_card|id=" .. sv(actual_id) .. "|status=add_card_called")
	return true
end

local function cheat_test_soul_wand()
	-- Both card IDs are present in the live v1.623b CARDS dump (Run 5).
	-- Majestic Censer opens a soul slot; Wand of Souls enables a scepter test.
	grant_debug_card("Majestic Censer")
	grant_debug_card("Wand of Souls")
end

local function cheat_random_card()
	if type(pick) ~= "function" or type(add_card) ~= "function" then
		log("SKE|cheat_card|status=api_unavailable")
		return
	end
	local ca = pick({team=0})
	if ca == nil then
		log("SKE|cheat_card|status=no_eligible_card")
		return
	end
	local id = type(ca) == "table" and sv(ca.id) or sv(ca)
	add_card(ca)
	log("SKE|cheat_card|id=" .. id)
end

local function cheat_spawn_ally()
	local pdef = first_spawnable_piece()
	local sq = nearby_free_square()
	if pdef == nil or sq == nil or type(new_piece) ~= "function" then
		log("SKE|cheat_spawn|status=no_piece_or_free_square")
		return
	end
	local p = new_piece(pdef.type, false, sq)
	if p and type(fx_spawn) == "function" then fx_spawn(p) end
	log("SKE|cheat_spawn|type=" .. sv(pdef.type) .. "|name=" .. sv(pdef.name))
end

local function cheat_god_mode()
	god_mode = not god_mode
	if god_mode and hero and type(hero.hp) == "number" then hero.hp = 99 end
	if bank_ready and type(bset) == "function" then
		bset(0, 0, 505)
		bset(1, 0, god_mode and 1 or 0)
		if type(savbnk) == "function" then savbnk() end
	end
	log("SKUI|panel|god_mode=" .. sv(god_mode))
end

make_dev_actions = function()
	if dev_open or type(mk_text_but) ~= "function" then return end
	dev_open = true
	local sw = (type(MCW) == "number" and MCW) or 320
	local width, gap = 62, 4
	local total = width * 4 + gap * 3
	local x0 = (sw - total) / 2
	if type(flr) == "function" then x0 = flr(x0) end
	local x1 = x0 + width + gap
	local x2 = x1 + width + gap
	local x3 = x2 + width + gap
	local y = (dev_y or 0) + 10
	local y2 = y + 10
	native_button(x0, y, width, "+3 AMMO", cheat_ammo, dev_actions)
	native_button(x1, y, width, "RELOAD", cheat_reload, dev_actions)
	native_button(x2, y, width, "CHAMBER +1", cheat_chamber_slot, dev_actions)
	native_button(x3, y, width, "RANDOM CARD", cheat_random_card, dev_actions)
	native_button(x0, y2, width, "SPAWN ALLY", cheat_spawn_ally, dev_actions)
	native_button(x1, y2, width, "TEST SOUL/WAND", cheat_test_soul_wand, dev_actions)
	native_button(x2, y2, width, "GOD MODE", cheat_god_mode, dev_actions)
	native_button(x3, y2, width, "CLOSE", remove_dev_actions, dev_actions)
	log("SKUI|panel|open=true|buttons=" .. sv(#dev_actions))
end

local function ensure_dev_panel()
	if type(mk_text_but) ~= "function" then
		if not panel_creation_logged then
			log("SKUI|panel|available=false|reason=mk_text_but_missing")
			panel_creation_logged = true
		end
		return
	end
	if dev_header then
		if group_alive(dev_header) then return end
		dev_header = nil
		if dev_open then remove_dev_actions() end
	end
	local screen_h = (type(MCH) == "number" and MCH) or 180
	dev_y = ((type(board_y) == "number" and board_y) or 0) + 16 * 8 + 3
	local last_y = screen_h - 32
	if dev_y > last_y then dev_y = last_y end
	if dev_y < 0 then dev_y = 0 end
	local screen_w = (type(MCW) == "number" and MCW) or 320
	local title = native_button(4, dev_y, 44, "SK DEV", function()
		if dev_open then remove_dev_actions() else make_dev_actions() end
	end)
	dev_header = title
	if not panel_creation_logged then
		log("SKUI|panel|available=true|native=mk_text_but")
		panel_creation_logged = true
	end
	if dev_header and type(dev_header.ents) == "table" and dev_header.ents[1] then
		log("SKUI|panel|width=" .. sv(screen_w) .. "|y=" .. sv(dev_y))
	end
end

-- ---------- 5. Mod-menu legend + Back via native menu hook -------------
local menu_widgets_created = false
local menu_widget_groups = {}
local pending_menu_button = false
local pending_menu_button_id = nil

local function is_modlist_entry_id(id)
	if id == nil or type(MODLIST) ~= "table" then return false end
	local id_s = sv(id)
	for i, entry in ipairs(MODLIST) do
		if i > 40 then break end
		if type(entry) == "table" then
			local fields = {"title", "name", "folder"}
			for _, field in ipairs(fields) do
				local val = entry[field]
				if val ~= nil then
					local value = sv(val)
					if id_s == value or id_s == (sv(i) .. ". " .. value) then return true end
				end
			end
		end
	end
	return false
end

local function clear_menu_widgets()
	for i = 1, 4 do
		local group = menu_widget_groups[i]
		if group == nil then break end
		destroy_group(group)
		menu_widget_groups[i] = nil
	end
	menu_widgets_created = false
end

local function add_mod_menu_widgets(id)
	if menu_widgets_created or not is_modlist_entry_id(id) then return end
	if type(mk_text_but) ~= "function" then return end
	menu_widgets_created = true
	local sw = (type(MCW) == "number" and MCW) or 320
	local back = native_button(2, 2, 42, "< BACK", function()
		if type(init_menu) == "function" then init_menu() end
		log("SKUI|menu|back_clicked=true")
	end, menu_widget_groups)
	local legend = native_button(48, 2, sw - 52, "WHITE=ON  BLACK=OFF  (UP/DN=LOAD ORDER)", function() end, menu_widget_groups)
	-- This follows Royal Card Lab's proven way to make a native text label
	-- non-interactive while preserving its own rendering.
	if legend and type(legend.ents) == "table" and legend.ents[1] then
		legend.ents[1].button = false
	end
	log("SKUI|menu|widgets_added=true|entry=" .. sv(id) .. "|back=" .. sv(back ~= nil))
end

-- ---------- 6. base diagnostic hooks ----------------------------------
-- SK-REWORK: append new_turn for world state, panel recovery, and God Mode HP refresh.
hookf("new_turn", function()
	ensure_dev_panel()
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
	clear_dev_actions()
	ensure_dev_panel()
	local n = capped("init_game")
	if n then log("SKE|init_game|n=" .. sv(n)) end
end, "sk-rework:init_game")

-- God Mode protects against the confirmed hit(p,dmg,tags) route; a huge HP
-- refill also covers normal turns. Other death routes remain a live-probe item.
if known["hit"] then
	-- SK-REWORK: prepend hit only for best-effort God Mode + damage tracing.
	hookf("hit", function(p, dmg, tags, ...)
		if god_mode and p == hero and type(p.hp) == "number" and type(dmg) == "number" then
			p.hp = p.hp + dmg
		end
		local n = capped("god_hit")
		if n then log_target("SKD", "hit", p, dmg, "|god_mode=" .. sv(god_mode)) end
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
	-- SK-REWORK: append level_up to observe draft filters/choices.
	hookf("level_up", function(data, next_fn, ...)
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
		if id ~= nil then add_mod_menu_widgets(id) end
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
	newbnk(128, 64, 4)
	bank_ready = true
	local magic = bget(0, 0)
	if magic == 505 then god_mode = (bget(1, 0) == 1) end
	log("SKUI|bank|ready=true|magic=" .. sv(magic) .. "|god_mode=" .. sv(god_mode))
else
	log("SKUI|bank|ready=false")
end
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
