#!/usr/bin/env python3
"""Build-8 smoke test — run sk-rework against a fake SUGAR environment.

The real engine can't run here (no Windows/game), but Lua load-time logic,
additive hook registration, parser compatibility, native-button callbacks,
and the safe dev-cheat actions can be exercised with lupa. The test runs
under both value-yielding and (index, value)-yielding `all()` semantics, using
LuaJIT 2.1 as well when the installed `lupa` package provides it.

Dev dependency:
    pip install lupa

Usage:
    python tools/mod_smoketest.py
    python tools/mod_smoketest.py --dump
"""
import math
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
MOD = os.path.join(REPO, "modded", "sk-rework", "script.lua")
# the build number the mod declares (`local BUILD = N`); log checks follow it
BUILD_NO = int(re.search(r"^local BUILD = (\d+)", open(MOD, encoding="utf-8").read(), re.M).group(1))

FAKE_ENGINE_LINES = ["SUGAR v0.0.8f (LuaJIT 2.1) boot", "loaded lang/english.txt"]


def to_lua(L, obj):
    """Recursively convert Python dicts/lists into real Lua tables."""
    if isinstance(obj, dict):
        return L.table_from({k: to_lua(L, v) for k, v in obj.items() if v is not None})
    if isinstance(obj, (list, tuple)):
        return L.table_from([to_lua(L, v) for v in obj])
    return obj


ALL_VALUE = """
function all(t)
    local i = 0
    return function()
        i = i + 1
        if t[i] ~= nil then return t[i] end
    end
end
"""

ALL_PAIR = """
function all(t)
    local i = 0
    return function()
        i = i + 1
        if t[i] ~= nil then return i, t[i] end
    end
end
"""


# The engine's REAL mod sandbox (game/decoded/code/mods.lua safe_require):
# a write reaches the engine only for keys in this list; a write to any other
# EXISTING global is refused with a red rlog ("Not allowed to change value
# for index ..."); a write to an unused name stays in the mod's own table.
ENGINE_REPLACEABLE = [
    "DEV", "START_LVL", "FORCE_WHITE_ARMY", "DUMMY", "FRAGILE", "SHOW_BUTS", "TEST_CARDS",
    "TEST_SOULS", "OVERWEIGHT", "BOOT", "game_mode", "CARDS", "PIECES", "EXCLUDE",
    "AUTO_REPLACE", "FIRST_ARMY", "HERO_INIT", "TAGS",
    "hero", "heir", "leader", "pentasquares", "waypoint", "ammo", "chamber", "grenades",
    "stack", "scepters", "menu", "bg", "white_army", "perm", "mode", "cards",
    "mx", "my", "mcl", "mlb", "mcr", "mMenu", "VISION",
]

# Faithful copy of the engine's mod-list screen (game code/menu.lua:
# open_menu "mods" branch layout, act_menu's inmods branch verbatim,
# close_menu). Wrapped the way the real append() wraps a global: the
# original runs, then every appended hook with the same arguments - and
# internal recursive calls go through the wrapped global too.
FAKE_MODMENU_LUA = r"""
inmods = nil
__fake = {closes = 0, play_opened = 0, reboots = 0}
local function get_lang(s) return s end   -- code/lang.lua: unknown id -> id
local function mkb(id, lock)
  local e = {id = id, name = get_lang(id), lock = lock, dp = 6}
  menu[#menu + 1] = e
  return e
end
local function core_open(a, kind)
  menu = {}
  menu[1] = {eraser = true}
  if kind == "mods" then
    inmods = true
    for i, mod in ipairs(MODLIST) do
      local name = (mod.empty and "EMP | " or (mod.active and " ON | " or "OFF | ")) .. i .. ". " .. mod.title
      mkb("\195\169", i == 1)
      mkb("\195\168", i == #MODLIST)
      local m = mkb(name)
      m.labelc = mod.active and 4 or 2
    end
    local res = mkb("reset", true); res.name = "Reset"
    local bck = mkb("back"); bck.name = "Back"
  end
end
open_menu = function(a, kind) core_open(a, kind); __sk_fire("open_menu", a, kind) end
close_menu = function(f)
  if not menu then return end
  for _, e in ipairs(menu) do e.dead = true end
  menu = nil
  inmods = nil
  __fake.closes = __fake.closes + 1
  if f then f() end            -- the engine waits 16 frames first
end
local function core_act(id)
  if not menu then return end
  if inmods then
    if id == "back" then
      inmods = nil
      return act_menu("play")
    elseif id == "reset" then
      local list = {}
      for i, mod in ipairs(MODLIST) do
        mod.active = mod.loaded
        list[mod.num] = mod
      end
      MODLIST = list
      inmods = nil
      act_menu("mods")
      return
    elseif id == "reboot" then
      __fake.reboots = __fake.reboots + 1
      return
    end
    for i, b in ipairs(menu) do
      if b.over then
        local i = i - 1
        local mid = math.ceil(i / 3)
        local mac = i % 3
        if mac == 0 then
          local mod = MODLIST[mid]
          if mod.empty then return end
          mod.active = not mod.active
          b.id = (mod.active and " ON | " or "OFF | ") .. mid .. ". " .. mod.title
          b.labelc = mod.active and 4 or 2
        elseif mac == 1 then
          MODLIST[mid], MODLIST[mid - 1] = MODLIST[mid - 1], MODLIST[mid]
          menu[1 + mid * 3], menu[1 + mid * 3 - 3] = menu[1 + mid * 3 - 3], menu[1 + mid * 3]
          menu[1 + mid * 3].id = (MODLIST[mid].active and " ON | " or "OFF | ") .. mid .. ". " .. MODLIST[mid].title
          menu[1 + mid * 3 - 3].id = (MODLIST[mid - 1].active and " ON | " or "OFF | ") .. (mid - 1) .. ". " .. MODLIST[mid - 1].title
        elseif mac == 2 then
          MODLIST[mid], MODLIST[mid + 1] = MODLIST[mid + 1], MODLIST[mid]
          menu[1 + mid * 3], menu[1 + mid * 3 + 3] = menu[1 + mid * 3 + 3], menu[1 + mid * 3]
          menu[1 + mid * 3].id = (MODLIST[mid].active and " ON | " or "OFF | ") .. mid .. ". " .. MODLIST[mid].title
          menu[1 + mid * 3 + 3].id = (MODLIST[mid + 1].active and " ON | " or "OFF | ") .. (mid + 1) .. ". " .. MODLIST[mid + 1].title
        end
        menu[#MODLIST * 3 + 2].lock = nil
        menu[#MODLIST * 3 + 3].id = "reboot"
        menu[#MODLIST * 3 + 3].name = "Save and Reboot"
        return
      end
    end
    return
  end
  if id == "play" then
    close_menu(function() __fake.play_opened = __fake.play_opened + 1; menu = {{eraser = true}} end)
  elseif id == "mods" then
    close_menu(function() open_menu(nil, "mods") end)
  end
end
act_menu = function(id) local r = core_act(id); __sk_fire("act_menu", id); return r end
-- what mk_menu_but's draw shows: e.name = lang[e.id] or e.name or e.id
function __fake_text(e) return e.name or e.id end
"""

SANDBOX_LUA = """
function __sk_sandbox_load(src, replaceable)
    local env = _G
    local can = {}
    for _, k in ipairs(replaceable) do can[k] = true end
    local ctrl = setmetatable({}, {
        __newindex = function(t, k, v)
            if can[k] then env[k] = v
            elseif env[k] == nil then rawset(t, k, v)
            else __sk_violation(k) end
        end,
        __index = function(t, k) return env[k] end,
    })
    local f, e
    if setfenv then
        f, e = loadstring(src, "=script.lua")
        if f then setfenv(f, ctrl) end
    else
        f, e = load(src, "=script.lua", "t", ctrl)
    end
    if not f then error(e) end
    return f()
end
"""


def build_env(L, all_mode="value"):
    """Install Lua wrapper functions so fake engine APIs have Lua type=function."""
    g = L.globals()
    same_lua_table = L.eval("function(a, b) return rawequal(a, b) end")
    captured = []
    hooks = {}
    prepends = {}
    appends = {}
    native_buttons = []
    bank_store = {}
    init_menu_calls = [0]
    entity_count = [0]

    def bind(name, fn):
        g["__py_" + name] = fn
        L.execute(f"{name} = function(...) return __py_{name}(...) end")

    bind("_log", lambda s: captured.append(str(s)))
    violations = []
    bind("__sk_violation", lambda k: violations.append(str(k)))
    L.execute(SANDBOX_LUA)
    g["__sk_fire"] = lambda name, *a: [fn(*a) for fn in hooks.get(name, [])]
    L.execute(FAKE_MODMENU_LUA)
    L.execute(ALL_VALUE if all_mode == "value" else ALL_PAIR)

    g.MODLIST = to_lua(L, [
        {"title": "Glacies Module Terminal", "name": "glac terminal", "active": False},
        {"title": "SK Rework", "name": "sk-rework", "folder": "mods/sk-rework", "active": True},
    ])
    g.CARDS = to_lua(L, [
        {"id": "Peace", "gid": 12, "ext": 0, "pwe": 4, "sac": [1], "gain": [2, 2]},
        {"id": "Right-hand", "gid": 157, "ext": 2, "pwe": 1, "special": "strafe", "allies": [1]},
        {"id": "Unjust Decree", "gid": 22, "ext": 0, "pwe": 2, "special": "decree"},
        {"id": "Wand of Frenzy", "gid": 14, "ext": 0, "pwe": 1, "wand": [1]},
    ])
    g.EXCLUDE = to_lua(L, [["Royal Loafers", "Sawed-off Justice"]])
    g.PIECES = to_lua(L, [
        {"type": 0, "name": "pawn", "hp": 3, "tempo": 5, "danger": 1, "behavior": [{"id": "line"}]},
        {"type": 1, "name": "knight", "hp": 3, "tempo": 3, "danger": 3, "behavior": [{"id": "jump"}]},
        {"type": 2, "name": "bishop", "hp": 4, "tempo": 3, "danger": 3, "behavior": [{"id": "line"}]},
    ])
    g.TEST_SOULS = to_lua(L, [{"type": 1, "sanctity": 0}, {"type": 2, "sanctity": 1}])
    # Live run 4 (2026-10-04): `scepters` is NOT in gimme("global") (only in
    # gimme("replaceable")), MOUSE is a boolean and INPUT_ASSIGNEMENT is a
    # formatted *string* dump. Keep the fake env faithful to that evidence.
    g.MOUSE = True
    g.INPUT_ASSIGNEMENT = ("\t\t\tvalidate> c:a, m:lb\n"
                           "\t\t\tcancel> c:b, k:escape\n"
                           "\t\t\tshoot> c:rtrigger\n"
                           "\t\t\tspecial> c:x, m:rb\n"
                           "\t\t\treload> c:y, k:space\n"
                           "\t\t\tunsafe> c:ltrigger, k:lshift\n"
                           "\t\t\tmx> m:x\n"
                           "\t\t\tmy> m:y\n"
                           "\t\t\tlb> m:lb\n"
                           "\t\t\trb> m:rb\n"
                           "\t\t\tmouse_move> m:x, m:y\n"
                           "\t\t\tmouse> m:lb, m:rb, m:mb, k:escape, k:return, "
                           "k:space, k:lshift, k:lalt, k:ralt\n"
                           "\t\t\tctrlr> c:lstick:left, c:lstick:right, c:lstick:up, "
                           "c:lstick:down, c:rstick:left, c:rstick:right, c:rstick:up, "
                           "c:rstick:down, c:a, c:b, c:x, c:dpad:left, c:dpad:right, "
                           "c:dpad:up, c:dpad:down, c:start, c:back, c:touchpad, "
                           "c:rshoulder, c:lshoulder\n"
                           "\t\t")
    g.loadfile = None  # the real mod sandbox does not expose loadfile
    g.SHOOT_BUTTON = "left"
    g.RELOAD_BUTTON = "right"
    g.SPECIAL_BUTTON = "right"
    g.CONFIRM_BUTTON = "left"
    g.SNAP_KEY = "unsafe"

    global_names = [
        "_log", "concat", "add", "del", "all", "get_slot_cards", "gsq", "ammo_spend",
        "mk_menu_but", "mk_text_but", "mk_but", "init_menu", "spawn_pieces",
        "new_piece", "setup_piece", "new_turn", "new_level", "add_card", "new_card",
        "CARDS", "EXCLUDE", "PIECES", "get_disp_stats", "draw_mode", "goto_sq",
        "get_range", "throw_grenade", "spend_hop", "uplift", "check_cards_auto_flip",
        "flip_card", "unflip_card", "set_mode", "init_game", "init_codex", "opp_turn",
        "wait", "inc_ammo", "give_ammo", "reload", "pick", "add_any_card", "level_up",
        "is_card_available", "newbnk", "bget", "bset", "savbnk", "defbtn", "btn",
        "btnp", "btnr", "fire", "mk_bullet", "hit", "ev_hit", "damage", "damages",
        "fx_dmg", "bleed_dmg", "hop_dmg", "xpl", "xpl_king", "add_soul",
        "activate_soul", "add_soul_slot", "remove_soul_slot", "exhaust_soul",
        "add_scepter", "activate_scepter", "recal_scepters", "get_scepter",
        "TEST_SOULS", "MOUSE", "PIECES_NAMES", "get_free_squares", "is_free",
        "remove_buts", "get_allies", "get_nearest_free_square", "black_mist_check",
        "get_dodge", "goto_sq", "refill_ammo", "can_reload", "need_reload", "clip",
        "flr", "t", "chamber", "stack", "hero", "mk_text_but", "mk_menu_but",
        "add", "del", "savbnk", "bget", "bset", "newbnk", "fx_spawn",
    ]
    replaceable_names = ["hero", "stack", "ammo", "chamber", "scepters"]

    def gimme(which):
        if which == "global": return to_lua(L, global_names)
        if which == "replaceable": return to_lua(L, replaceable_names)
        if which == "forbidden": return to_lua(L, ["data_sgr"])
        return to_lua(L, [])
    bind("gimme", gimme)

    def register(target, fn, hook_id=None):
        # The real engine chains EVERY append on a target, so the fake must
        # keep an ordered list (Build 7 appends mk_bullet twice; the old
        # single-slot dict silently dropped the damage hook).
        hooks.setdefault(target, []).append(fn)
        if hook_id:
            appends.setdefault(target, []).append(hook_id)

    def fire(name, *args):
        for fn in hooks.get(name, []):
            fn(*args)

    def register_pre(target, fn, hook_id=None):
        prepends[target] = fn
        if hook_id:
            appends.setdefault("PRE:" + target, []).append(hook_id)

    bind("append", register)
    bind("prepend", register_pre)

    g.ammo = 5
    g.chamber = 2
    g.grenades = 0
    g.menu = "mods"
    g.mMenu = "mods"
    g.hero = to_lua(L, {"hp": 3, "ammo": 5, "free_souls": 1, "sq": {"px": 4, "py": 7}})
    g.stack = to_lua(L, {"special": "strafe", "pierce": 30, "ammo_max": 6, "chamber_max": 1})
    g.bads = to_lua(L, [1, 2, 3])
    g.bullets = to_lua(L, [
        {"dmg": 1, "pierce": 30, "shot": True, "x": 10, "y": 20, "life": 8},
        {"dmg": 1, "pierce": 0, "shot": True, "x": 12, "y": 22, "life": 8},
    ])
    squares = [
        {"px": 3, "py": 6, "x": 48, "y": 96},
        {"px": 4, "py": 6, "x": 64, "y": 96},
        {"px": 5, "py": 6, "x": 80, "y": 96},
        {"px": 4, "py": 7, "x": 64, "y": 112},
    ]
    g.squares = to_lua(L, squares)
    hero_start_sq = g.squares[4]
    hero_start_sq.p = g.hero
    g.hero.sq = hero_start_sq
    g.ents = L.table()
    g.board_y = 16
    g.MCW = 320
    g.MCH = 180

    def add_entity(entity):
        entity_count[0] = len(g.ents) + 1
        g.ents[entity_count[0]] = entity

    def lua_del(tbl, value):
        if tbl is None: return
        n = len(tbl)
        for i in range(1, n + 1):
            if tbl[i] == value:
                for j in range(i, n): tbl[j] = tbl[j + 1]
                tbl[n] = None
                entity_count[0] = len(tbl)
                return

    bind("del", lua_del)
    bind("inc_ammo", lambda n: setattr(g, "ammo", (g.ammo or 0) + n))
    bind("give_ammo", lambda source, n: setattr(g, "ammo", (g.ammo or 0) + n))
    bind("reload", lambda one=False: setattr(g, "chamber", (g.chamber or 0) + 1))
    bind("uplift", lambda data: None)
    bind("newbnk", lambda w, h, d: None)
    bind("bget", lambda x, y: bank_store.get((x, y), 0))
    bind("bset", lambda x, y, v: bank_store.__setitem__((x, y), int(v)))
    bind("savbnk", lambda: None)
    bind("defbtn", lambda name, idx, spec: None)

    # The real engine's btn() is FATAL on ids it cannot resolve: an unknown
    # name falls through to the input-id parser and a malformed id quits the
    # game (live run 4: btn("left") -> "ERR Button left for player 0 doesn't
    # exist"). The fake engine reproduces that contract so the smoke test
    # fails loudly if the mod ever blind-probes an unconfirmed button again.
    confirmed_buttons = {"validate", "cancel", "shoot", "special", "reload",
                         "unsafe", "ctrl", "m:lb", "m:rb", "m:mb"}

    def engine_btn(name):
        s = "" if name is None else str(name)
        if s in confirmed_buttons:
            return False
        captured.append(f"!! Not recognizing button '{s}', attempting to parse it as input code.")
        captured.append(f"!! Malformed input id '{s}': must be '[k/m/c]:[key/button/[axis:direction]]'.")
        raise RuntimeError(f"Button {s} for player 0 doesn't exist.")

    bind("btn", engine_btn)
    bind("btnp", engine_btn)
    bind("btnr", engine_btn)
    bind("fx_spawn", lambda p: None)
    # Build 7 engine surface (live-registered globals in run 5).
    def engine_remove_buts():
        # engine: deletes every entity with the `button` flag (code.lua:15107)
        native_buttons.clear()
        n = len(g.ents)
        keep = [g.ents[i] for i in range(1, n + 1) if not g.ents[i].button]
        for i in range(1, n + 1):
            g.ents[i] = None
        for i, e in enumerate(keep, 1):
            g.ents[i] = e
    bind("remove_buts", engine_remove_buts)

    # ---- Build 8 panel surface: frame input, entities, drawing ------------
    g.ingame = True
    hw = {"x": 0, "y": 0, "click": False}
    board_clicks = []
    draw_log = []

    def engine_gamepad_ctrl():
        # MOUSE branch of the real gamepad_ctrl: read the mouse, then the
        # append() chain runs; mk_but buttons update AFTER this and see mcl.
        g.mx, g.my = hw["x"], hw["y"]
        g.mcl, g.mlb, g.mcr = hw["click"], hw["click"], False
        fire("gamepad_ctrl")
        if g.mcl and 96 <= hw["x"] < 224 and 30 <= hw["y"] < 158:
            board_clicks.append((hw["x"], hw["y"]))
    bind("gamepad_ctrl", engine_gamepad_ctrl)

    def engine_mke(fr=0, x=0, y=0):
        e = L.table()
        e.fr, e.x, e.y, e.dp = fr, x, y, 3
        add_entity(e)
        return e
    bind("mke", engine_mke)

    def engine_kl(e):
        if e is None: return
        e.dead = True
        lua_del(g.ents, e)
    bind("kl", engine_kl)

    font_state = {"cur": "Terminus"}

    def engine_font(name=None):
        if name is None: return font_state["cur"]
        font_state["cur"] = name
    bind("font", engine_font)
    bind("lprint", lambda s, x, y, c=None, align=None, o=None:
         draw_log.append(("t", str(s), x, y, font_state["cur"])))
    bind("rectfill", lambda x1, y1, x2, y2, c=None: draw_log.append(("r", x1, y1, x2, y2, c)))
    bind("rect", lambda x1, y1, x2, y2, c=None: draw_log.append(("o", x1, y1, x2, y2, c)))
    bind("sfx", lambda name, vol=None: None)
    bind("flr", lambda v: int(math.floor(float(v))))
    g.t = 12345.678
    g.get_nearest_free_square = None  # NOT a function in the fake: exercises the fallback
    bind("get_allies", lambda: g.ents)
    bind("black_mist_check", lambda e: False)
    bind("get_dodge", lambda e: None)

    goto_sq_calls = []

    def engine_goto_sq(a, b):
        # Verbatim relevant engine contract: goto_sq(piece, square) updates
        # the piece's square reference and both squares' `.p` occupancy.
        goto_sq_calls.append((a, b))
        if same_lua_table(a, g.hero) and b is not None and b.px is not None and b.p is None:
            old_sq = a.sq
            if old_sq is not None and same_lua_table(old_sq.p, a):
                old_sq.p = None
            a.sq = b
            b.p = a
            return True
        return False
    bind("goto_sq", engine_goto_sq)
    bind("refill_ammo", lambda: setattr(g, "chamber", g.stack.chamber_max or 1))
    bind("can_reload", lambda: (g.chamber or 0) < (g.stack.chamber_max or 1))
    g.need_reload = False
    g.clip = 1

    def engine_pick(filters):
        # First dynamic black card; the real game selects a random eligible card.
        ca = g.CARDS[1]
        if "pick" in hooks: fire("pick", filters)
        return ca
    bind("pick", engine_pick)

    def engine_add_card(ca):
        if "add_card" in hooks: fire("add_card", ca)
    bind("add_card", engine_add_card)

    def engine_add_soul(a1, a2=None, a3=None, a4=None):
        if "add_soul" in hooks: fire("add_soul", a1, a2, a3, a4)
    bind("add_soul", engine_add_soul)

    def engine_add_scepter(a1=None, a2=None):
        if "add_scepter" in hooks: fire("add_scepter", a1, a2)
    bind("add_scepter", engine_add_scepter)

    def engine_hit(target, damage, tags=None):
        if "hit" in prepends: prepends["hit"](target, damage, tags)
        # Fake original engine application, to show the pre-hook hit cancels damage.
        if target is not None:
            target.hp = (target.hp or 0) - damage
    bind("hit", engine_hit)

    def engine_init_menu():
        init_menu_calls[0] += 1
        if "init_menu" in prepends: prepends["init_menu"]()
        if "init_menu" in hooks: fire("init_menu")
    bind("init_menu", engine_init_menu)

    def engine_gsq(px, py):
        for i in range(1, len(g.squares) + 1):
            sq = g.squares[i]
            if sq.px == px and sq.py == py:
                return sq
        return None
    bind("gsq", engine_gsq)
    bind("is_free", lambda sq: sq.p is None)

    def engine_new_piece(piece_type, bad, sq):
        return to_lua(L, {"type": piece_type, "bad": bad, "hp": 3, "sq": {"px": sq.px, "py": sq.py}})
    bind("new_piece", engine_new_piece)

    def engine_mk_text_but(x, y, w, label, fn):
        ent = L.table()
        ent.x, ent.y, ent.w, ent.label, ent.button = x, y, w, label, True
        ent.left_clic = fn
        add_entity(ent)
        group = L.table()
        list_table = L.table()
        list_table[1] = ent
        group.ents = list_table
        native_buttons.append({"x": x, "y": y, "w": w, "label": str(label), "fn": fn, "entity": ent})
        return group
    bind("mk_text_but", engine_mk_text_but)
    bind("mk_but", lambda x, y, w, h, fn: engine_mk_text_but(x, y, w, "", fn))

    def engine_mk_menu_but(ident, x, y, w, h):
        if "mk_menu_but" in prepends:
            prepends["mk_menu_but"](ident, x, y, w, h)
        ent = L.table()
        ent.id, ent.x, ent.y, ent.w, ent.h, ent.button = ident, x, y, w, h, True
        ent.left_clic = L.eval("function() end")
        ent.right_clic = L.eval("function() end")
        add_entity(ent)
        if "add" in hooks:
            fire("add", g.ents, ent)
        if "mk_menu_but" in hooks:
            fire("mk_menu_but", ident, x, y, w, h)
    bind("mk_menu_but", engine_mk_menu_but)

    def engine_level_up(data, next_fn=None):
        if "level_up" in hooks: fire("level_up", data, next_fn)
    bind("level_up", engine_level_up)

    def engine_is_card_available(ca):
        if "is_card_available" in hooks: fire("is_card_available", ca)
        return True
    bind("is_card_available", engine_is_card_available)

    def engine_fire():
        if "fire" in hooks: fire("fire")
    bind("fire", engine_fire)

    def engine_mk_bullet(x, y, angle, life):
        b = to_lua(L, {"dmg": 1, "pierce": 30, "shot": True, "x": x, "y": y, "life": life})
        g.bullets[len(g.bullets) + 1] = b
        fire("mk_bullet", x, y, angle, life)
        return b
    bind("mk_bullet", engine_mk_bullet)

    def engine_fx_damage(target, amount):
        if "fx_dmg" in hooks: fire("fx_dmg", target, amount)
    bind("fx_dmg", engine_fx_damage)

    def engine_ev_hit(target, amount):
        if "ev_hit" in hooks: fire("ev_hit", target, amount)
    bind("ev_hit", engine_ev_hit)

    def engine_xpl(target):
        if "xpl" in hooks: fire("xpl", target)
    bind("xpl", engine_xpl)

    return {
        "captured": captured,
        "fire": fire,
        "hooks": hooks,
        "prepends": prepends,
        "appends": appends,
        "native_buttons": native_buttons,
        "bank_store": bank_store,
        "violations": violations,
        "hw": hw,
        "board_clicks": board_clicks,
        "draw_log": draw_log,
        "init_menu_calls": init_menu_calls,
        "hero_start_sq": hero_start_sq,
        "goto_sq_calls": goto_sq_calls,
        "same_lua_table": same_lua_table,
        "globals": g,
    }


def find_button(env, label):
    for button in reversed(env["native_buttons"]):
        if button["label"] == label and button["fn"] is not None:
            return button
    return None


def call_button(env, label):
    button = find_button(env, label)
    if button is not None:
        button["fn"]()
    return button


def run_scenario(L, env, mode, dump=False):
    g = env["globals"]
    captured, hooks, prepends = env["captured"], env["hooks"], env["prepends"]
    fire = env["fire"]

    calls = [
        ("new_turn", []), ("new_turn", []),
        ("new_level", []),
        ("setup_piece", [to_lua(L, {"type": 0, "hp": 2, "name": "pawn"})]),
        ("add_card", [to_lua(L, {"id": "Peace", "pwe": 4, "gid": 12})]),
        ("pick", [to_lua(L, {"team": 0, "special": True})]),
        ("level_up", [to_lua(L, {"id": "level_up", "choices": [[{"team": 0}, {"team": 1}]]}), None]),
        ("is_card_available", [to_lua(L, {"id": "Right-hand", "special": "strafe"})]),
        ("fire", []),
        ("fx_dmg", [to_lua(L, {"name": "rook", "hp": 4, "bad": True}), 1]),
        ("ev_hit", [to_lua(L, {"name": "rook", "hp": 4, "bad": True}), 1]),
        ("xpl", [to_lua(L, {"name": "pawn", "type": 0, "bad": True})]),
        ("add_soul", [1, None, None, True]),
        ("add_scepter", [1, None]),
    ]
    for name, args in calls:
        if not hooks.get(name):
            print(f"FAIL[{mode}]: hook '{name}' was never registered")
            return False
        fire(name, *args)

    # Menu-button id probe (read-only) still logs the real ids.
    g.mk_menu_but("SK Rework", 0, 0, 80, 12)

    # ---- Build 8 panel: drive it the way the engine does -------------------
    # Every interaction goes through the fake gamepad_ctrl (mouse read ->
    # append chain -> what the board's mk_but buttons would see), and every
    # button is located from what the panel actually DRAWS.
    hw, board_clicks, draw_log = env["hw"], env["board_clicks"], env["draw_log"]
    g.menu = None

    def frame(x, y, click=False):
        hw["x"], hw["y"], hw["click"] = x, y, click
        g.gamepad_ctrl()

    def draw():
        del draw_log[:]
        n = len(g.ents)
        for i in range(1, n + 1):
            e = g.ents[i]
            if e is not None and e.dr is not None:
                e.dr(e, e.x, e.y)
        rects, last = {}, None
        for d in draw_log:
            if d[0] == "r":
                last = d
            elif d[0] == "t" and last is not None:
                rects[d[1]] = (last[1], last[2], last[3], last[4])
        return rects

    def click(label, double_lp=False):
        r = draw().get(label)
        if r is None:
            return False
        cx, cy = (r[0] + r[2]) // 2, (r[1] + r[3]) // 2
        frame(cx, cy, True)
        if double_lp:              # fast-forward: lp() twice in one frame
            frame(cx, cy, True)
        frame(cx, cy, False)       # release / next frame
        return True

    def panel_ents():
        n = len(g.ents)
        return [g.ents[i] for i in range(1, n + 1)
                if g.ents[i] is not None and g.ents[i].sk_panel]

    if "init_game" not in hooks:
        print(f"FAIL[{mode}]: init_game hook was not registered")
        return False
    fire("init_game")
    frame(5, 5)
    labels0 = draw()
    tab = labels0.get("SK DEV")
    if tab is None:
        print(f"FAIL[{mode}]: SK DEV tab was not drawn")
        return False
    tab_off_board = tab[1] >= 158 and tab[2] < 96
    pico_font = any(d[0] == "t" and d[4] == "pico" for d in draw_log)
    font_restored = g.font() == "Terminus"
    click("SK DEV")
    labels1 = draw()
    page1 = ("+3 AMMO", "RELOAD", "CLIP+", "SAFE:off", "CARD:AUTO", "CARD NOW", "CARDS >",
             "SPAWN >", "GOD:off", "DMG:off", "DMG+ 1-1", "CRIT+ 0%", "CLOSE")
    missing = [lb for lb in page1 if lb not in labels1]
    if missing:
        print(f"FAIL[{mode}]: panel page 1 missing {missing}")
        return False
    small_buttons = all((labels1[lb][3] - labels1[lb][1] + 1) <= 9 for lb in page1)
    clip_over_board = 96 <= labels1["CLIP+"][0] < 224 and 30 <= labels1["CLIP+"][1] < 158

    # The run-6 bug: CLIP+ sits over the board; its click must NOT reach a square.
    clip_before = g.stack.chamber_max
    click("CLIP+")
    clip_after = g.stack.chamber_max
    clicks_after_clip = len(board_clicks)
    still_open_after_clip = "+3 AMMO" in draw()

    before_ammo = g.ammo
    click("+3 AMMO")
    ammo_after = g.ammo
    chamber_before = g.chamber
    click("RELOAD")
    chamber_after = g.chamber
    click("CARD NOW")

    # Live label + fast-forward guard: lp() twice with one click = ONE toggle.
    n_mode_logs = sum(1 for l in captured if "SKUI|panel|card_mode=" in l)
    click("CARD:AUTO", double_lp=True)
    card_toggled_once = sum(1 for l in captured if "SKUI|panel|card_mode=" in l) == n_mode_logs + 1
    labels_now = draw()
    label_live = "CARD:LIST" in labels_now and "CARD:AUTO" not in labels_now
    click("CARD:LIST")

    click("DMG:off")
    dmg_label_live = "DMG:on" in draw()
    bullet = g.mk_bullet(10, 20, 0, 8)
    bullet_dmg = bullet.dmg
    click("DMG+ 1-1")
    click("CRIT+ 0%")

    click("GOD:off")
    god_label_live = "GOD:on" in draw()
    g.hero.hp = 1
    hero_sq_before = g.hero.sq
    hero_px_before, hero_py_before = hero_sq_before.px, hero_sq_before.py
    g.hit(g.hero, 5, to_lua(L, {}))
    hp_after_hit = g.hero.hp
    same_lua_table = env["same_lua_table"]
    hero_moved = not same_lua_table(g.hero.sq, hero_sq_before)
    hero_occupancy_consistent = (same_lua_table(g.hero.sq.p, g.hero)
                                 and hero_sq_before.p is None)

    click("CARDS >")
    click("FILT:ALL")
    click("Right-hand")
    filt_label_live = "FILT:PIECE" in draw()
    click("< BACK")

    # Restore a coherent starting-square relationship after the dodge so the
    # following spawn placement test starts from the same baseline.
    hero_start_sq = env["hero_start_sq"]
    if not same_lua_table(g.hero.sq, hero_start_sq) and same_lua_table(g.hero.sq.p, g.hero):
        g.hero.sq.p = None
    hero_start_sq.p = g.hero
    g.hero.sq = hero_start_sq
    click("SPAWN >")
    click("knight")
    click("< BACK")
    back_to_page1 = "CLIP+" in draw()

    # Modal: a click inside the box but on no button is swallowed, panel stays.
    draw()
    box_fill = next(d for d in draw_log if d[0] == "r" and d[5] == 0)
    n_board = len(board_clicks)
    frame(box_fill[1] + 2, box_fill[2] + 1, True)
    frame(box_fill[1] + 2, box_fill[2] + 1, False)
    modal_swallow = len(board_clicks) == n_board and "CLIP+" in draw()

    # Hidden during a card choice: draws nothing and leaves clicks alone.
    g.leveling = True
    hidden_draw = draw() == {}
    frame(150, 100, True)
    level_click_passes = len(board_clicks) == n_board + 1
    frame(150, 100, False)
    g.leveling = None
    visible_again = "CLIP+" in draw()

    # remove_buts() (the engine runs it ~40x per turn) must not touch us.
    g.remove_buts()
    survives_remove_buts = len(panel_ents()) == 1 and "CLIP+" in draw()

    click("SAFE:off")
    safe_before = g.ammo
    click("+3 AMMO")
    click("+3 AMMO")
    safe_after = g.ammo

    # Once the one SAFE-mode action is spent, a lethal hit must not fall back
    # to coordinate writes; the king's square and every grid tile stay intact.
    safe_dodge_sq = g.hero.sq
    safe_dodge_px, safe_dodge_py = safe_dodge_sq.px, safe_dodge_sq.py
    board_before_blocked_dodge = [
        (g.squares[i].px, g.squares[i].py, g.squares[i].p)
        for i in range(1, len(g.squares) + 1)
    ]
    g.hero.hp = 1
    g.hit(g.hero, 5, to_lua(L, {}))
    board_after_blocked_dodge = [
        (g.squares[i].px, g.squares[i].py, g.squares[i].p)
        for i in range(1, len(g.squares) + 1)
    ]
    board_unchanged = all(
        (before[0], before[1]) == (after[0], after[1])
        and ((before[2] is None and after[2] is None)
             or same_lua_table(before[2], after[2]))
        for before, after in zip(board_before_blocked_dodge, board_after_blocked_dodge)
    )
    safe_dodge_blocked_unchanged = (
        same_lua_table(g.hero.sq, safe_dodge_sq)
        and (safe_dodge_sq.px, safe_dodge_sq.py) == (safe_dodge_px, safe_dodge_py)
        and same_lua_table(safe_dodge_sq.p, g.hero)
        and board_unchanged
        and any("SKE|call|goto_sq_hero=blocked|reason=safe_mode" in line for line in captured)
        and any("SKUI|dodge|from=4,7|to=3,6|route=diagonal|moved=false|reason=lethal_hit" in line
                for line in captured)
    )
    click("SAFE:on")

    click("CLOSE")
    closed_labels = draw()
    closed_ok = list(closed_labels) == ["SK DEV"]
    n_board = len(board_clicks)
    frame(150, 100, True)          # closed panel: board clicks pass through
    frame(150, 100, False)
    closed_click_passes = len(board_clicks) == n_board + 1

    # Click outside the box closes it (open again first).
    click("SK DEV")
    frame(10, 40, True)
    frame(10, 40, False)
    outside_closes = list(draw()) == ["SK DEV"]

    # New run: reset() replaces ents; the panel must come back (run 6: gone).
    old_ent = panel_ents()[0]
    g.ents = L.table()
    fire("init_game")
    frame(5, 5)
    new_run_ok = len(panel_ents()) == 1 and panel_ents()[0] != old_ent and "SK DEV" in draw()
    total_board_clicks_on_panel = clicks_after_clip


    def has(fragment):
        return any(fragment in line for line in captured)

    # ---- Build 8 item 5: the mod-list screen (run-6 complaints) ------------
    g.ingame = False
    saved_modlist = g.MODLIST
    titles = ["SK Rework", "Disgraced Justice", "Glacies Module Terminal",
              "Glacies' Collection", "The Magnificent Quartz Army",
              "Military Tactics -The Art of War-"]
    active0 = [True, True, False, False, False, True]
    g.MODLIST = to_lua(L, [
        {"title": t, "name": t.lower(), "num": i + 1, "active": a, "loaded": (True if a else None)}
        for i, (t, a) in enumerate(zip(titles, active0))])
    nmods = len(titles)

    def mm_ents():
        n = len(g.ents)
        return [g.ents[i] for i in range(1, n + 1)
                if g.ents[i] is not None and g.ents[i].sk_modmenu and not g.ents[i].dead]

    def legend_texts():
        del draw_log[:]
        for e in mm_ents():
            e.dr(e, e.x, e.y)
        return [d for d in draw_log if d[0] == "t"]

    def row(k):          # the visible row entry of mod position k
        return g.menu[3 * k + 1]

    def back_btn():
        return g.menu[nmods * 3 + 3]

    def press(entry):    # what a click does: entry.over, then act_menu(id)
        entry.over = True
        g.act_menu(entry.id)
        if g.menu is not None:
            for i in range(1, len(g.menu) + 1):
                if g.menu[i] is not None: g.menu[i].over = None

    g.open_menu(None, "mods")
    frame(200, 100)
    legend_created = len(mm_ents()) == 1 and not mm_ents()[0].button
    texts = legend_texts()
    tstr = [t[1] for t in texts]
    legend_layout = ("WHITE = ON" in tstr and "DARK = OFF" in tstr and "CLICK A NAME" in tstr
                     and all(t[2] < 104 for t in texts) and all(t[4] == "pico" for t in texts)
                     and all(" " not in t[1] or len(t[1]) <= 23 for t in texts)
                     and g.font() != "pico")
    # far-left, vertically centred around MCH/2
    ys = [t[3] for t in texts]
    legend_centred = bool(ys) and abs((min(ys) + max(ys)) / 2 - 90) <= 12
    predicted = "E1 TERMINAL IS OFF" in tstr and "E3 COLLECTION IS OFF" in tstr and "AUTO-FIX" in tstr

    # (1) click a mod name -> its ON/OFF TEXT follows (run 6: only the colour did)
    quartz_row = row(5)
    press(quartz_row)
    toggled_text_on = g.__fake_text(row(5)).startswith(" ON | 5. The Magnificent")
    back_after_on = back_btn().id == "reboot"
    # (2) back to the boot state -> Back is Back again (run 6: stuck on reboot)
    press(row(5))
    toggled_text_off = g.__fake_text(row(5)).startswith("OFF | 5. The Magnificent")
    back_restored = (back_btn().id == "back" and g.__fake_text(back_btn()) == "Back"
                     and g.menu[nmods * 3 + 2].lock is True)
    press(back_btn())
    frame(200, 100)
    back_returns = (g.__fake.play_opened == 1 and g.__fake.reboots == 0
                    and len(mm_ents()) == 0)

    # (3) reorder arrows: names follow positions; undo restores Back
    g.open_menu(None, "mods")
    press(g.menu[3])                       # down arrow of mod 1
    moved_names = (g.__fake_text(row(1)).startswith(" ON | 1. Disgraced Justice")
                   and g.__fake_text(row(2)).startswith(" ON | 2. SK Rework")
                   and back_btn().id == "reboot")
    press(g.menu[5])                       # up arrow of mod 2
    move_undone = (g.__fake_text(row(1)).startswith(" ON | 1. SK Rework")
                   and back_btn().id == "back")

    # (4) AUTO-FIX through the gamepad_ctrl hook (no engine button involved)
    closes_before = g.__fake.closes
    ok_click = click("AUTO-FIX")
    order = [g.MODLIST[i].title for i in range(1, nmods + 1)]
    autofix_order = order == ["SK Rework", "Glacies' Collection", "Military Tactics -The Art of War-",
                              "Disgraced Justice", "The Magnificent Quartz Army",
                              "Glacies Module Terminal"]
    autofix_enabled = (g.MODLIST[2].active is True and g.MODLIST[6].active is True
                       and g.MODLIST[5].active is False)
    frame(200, 100)
    tstr2 = [t[1] for t in legend_texts()]
    autofix_ok = (ok_click and autofix_order and autofix_enabled
                  and g.__fake.closes == closes_before + 1 and len(mm_ents()) == 1
                  and back_btn().id == "reboot" and "DEPENDENCIES OK" in tstr2
                  and "AUTO-FIX" not in tstr2 and g.mcl is False)
    # (5) engine Reset restores the boot list and Back
    press(g.menu[nmods * 3 + 2])
    reset_ok = ([g.MODLIST[i].title for i in range(1, nmods + 1)] == titles
                and g.MODLIST[3].active is None and back_btn().id == "back")
    # (6) order-only problems: Terminal ON but above Art of War, Collection below it
    g.MODLIST = to_lua(L, [
        {"title": "Glacies Module Terminal", "num": 1, "active": True, "loaded": True},
        {"title": "Military Tactics -The Art of War-", "num": 2, "active": True, "loaded": True},
        {"title": "Glacies' Collection", "num": 3, "active": True, "loaded": True}])
    nmods = 3
    act_menu_close = g.close_menu(None)
    g.open_menu(None, "mods")
    order_codes = has("SKUI|modmenu|sync=open|back=back|issues=2|codes=E2,E4")
    g.close_menu(None)
    frame(200, 100)
    # (7) silent Terminal clients (audit): Quartz and Extra Features print no
    # red text of their own, so the legend must name them; and the worst
    # realistic legend (every Terminal client ON, Terminal OFF, Collection
    # below Art of War, list changed) must still fit the 180-px screen.
    all_titles = ["SK Rework", "Glacies' Extra Features", "Military Tactics -The Art of War-",
                  "Glacies' Collection", "Disgraced Justice", "Retry after Death",
                  "Royal Card Lab", "Grenade Predictor", "Better Codex", "Nightmare Mode",
                  "Fairy Pieces for SGK", "The Magnificent Quartz Army",
                  "Shootout: the Rifle King Adventure", "Glacies Module Terminal"]
    g.MODLIST = to_lua(L, [
        {"title": t, "num": i + 1,
         "active": t not in ("Glacies Module Terminal", "Better Codex"),
         "loaded": (True if t != "Glacies Module Terminal" else None)}
        for i, t in enumerate(all_titles)])
    nmods = len(all_titles)
    g.open_menu(None, "mods")
    frame(10, 10)
    texts7 = legend_texts()
    t7 = [t[1] for t in texts7]
    silent_clients = ("E1 TERMINAL IS OFF" in t7 and any("QUARTZ" in t for t in t7)
                      and any("EXTRA FEAT" in t for t in t7) and "E4 COLLECTION BELOW" in t7
                      and "SAVE AND REBOOT" in t7)
    fix7 = [d for d in draw_log if d[0] == "r"]
    ys7 = [t[3] for t in texts7] + [d[4] for d in fix7]
    legend_fits = bool(texts7) and min(ys7) >= 0 and max(ys7) <= 179
    g.close_menu(None)
    frame(200, 100)
    g.MODLIST = saved_modlist
    g.menu = None
    g.ingame = True
    text = "\n".join(FAKE_ENGINE_LINES + captured) + "\n"

    def has(fragment):
        return any(fragment in line for line in captured)

    # Ensure the promised marker precedes every static §0.7 dump.
    ready_idx = next((i for i, line in enumerate(captured) if f"READY build={BUILD_NO}" in line), -1)
    probe_idx = next((i for i, line in enumerate(captured) if line.startswith("SKCF|")), -1)

    # Model self-check: the fake engine MUST reject unconfirmed buttons the
    # same fatal way the real engine does, otherwise the regression check
    # below is meaningless. btn("left") is exactly what killed run 4.
    try:
        g.btn("left")
        fatal_button_model = False
    except Exception:
        fatal_button_model = True

    checks = [
        ("fake engine models the fatal btn() contract", fatal_button_model),
        ("build-6 load banner", has(f"SK-REWORK: BUILD={BUILD_NO} loaded (mod_index=2)")),
        ("MODLIST self-check", has("SKA2|mod_found=yes|active=true")),
        ("MODLIST entry dump", has("SKM|2|title=SK Rework")),
        ("Lua function wrappers/API checks", has("SKA|append|no") and has("SKA|_log|YES")
                                             and has("SKA|mk_text_but|YES")),
        ("global map and five base hooks", has("SKG|ammo_spend") and has("SKH|init_game|sk-rework:init_game")),
        ("offer probes", has("SKOF|pick|n=1") and has("SKOF|level_up|n=1")
                         and has("SKOF|is_card_available|n=1")),
        ("full card fields + EXCLUDE", has("SKCF|Right-hand|special=strafe")
                                       and has("SKCF|__EXCLUDE__|pair=Royal Loafers<>Sawed-off Justice")),
        ("soul/scepter schema + runtime", has("SKS|piece|type=1|name=knight")
                                         and has("SKS|add_soul|n=1|a1=1")
                                         and has("SKS|add_scepter|n=1|a1=1")
                                         and has("SKS|scepters|available=false")),
        ("damage/bullet probes", has("SKD|bullet|shot_n=1|idx=1|dmg=1|pierce=30")
                                  and has("SKD|fx_dmg|n=1") and has("SKD|ev_hit|n=1")),
        ("input probe uses only confirmed ids", has("SKI|btn|validate=false")
                                               and has("SKI|btn|ctrl=false")
                                               and has("SKI|btncode|m:lb=false")
                                               and has("SKI|input|probed=10|source=confirmed_list|status=done")
                                               and not has("SKI|btn|left=")
                                               and not has("SKI|btn|mouse4=")
                                               and not has("SKI|btn|wheel=")),
        ("menu button ID probe", has("SKI|menu_button|n=1|id=SK Rework")),
        ("mod sandbox: no refused global writes", env["violations"] == []),
        ("panel controls (Build 8)", has("SKUI|panel|entity=created|fresh_run=true")
                                  and has("SKUI|panel|open=true|via=tab")
                                  and has("SKE|cheat_ammo|kind=reserve|amount=3")
                                  and has("SKE|cheat_card|mode=auto|id=Peace")
                                  and has("SKE|cheat_reload|")
                                  and has("SKE|cheat_clip|chamber_max=2")
                                  and has("SKUI|panel|god_mode=true")
                                  and env["bank_store"].get((0, 0)) == 505
                                  and env["bank_store"].get((1, 0)) == 1),
        ("ammo buttons change state", ammo_after == before_ammo + 3
                                      and chamber_after == chamber_before + 1
                                      and clip_after == clip_before + 1),
        ("panel never calls remove_buts", not has("SKE|call|remove_buts")
                                          and not has("clear=remove_buts")),
        ("RUN-6 BUG: CLIP+ over the board never reaches a square",
         clip_over_board and total_board_clicks_on_panel == 0 and still_open_after_clip),
        ("tab sits off the board (bottom-left)", tab_off_board),
        ("small pico-font buttons, font restored", small_buttons and pico_font and font_restored),
        ("labels follow state live (CARD/DMG/GOD/FILT)", label_live and dmg_label_live
                                                       and god_label_live and filt_label_live),
        ("fast-forward double lp() runs ONE action", card_toggled_once),
        ("modal: stray click inside the box is swallowed", modal_swallow),
        ("hidden while leveling, clicks pass, returns after", hidden_draw and level_click_passes
                                                             and visible_again),
        ("survives the engine's remove_buts()", survives_remove_buts),
        ("CLOSE leaves only the tab; board clicks pass", closed_ok and closed_click_passes
                                                       and has("SKUI|panel|open=false|via=close")),
        ("outside click closes", outside_closes and has("SKUI|panel|open=false|via=outside_click")),
        ("RUN-6 BUG: panel comes back on a new run (ents reset)", new_run_ok
                                                     and has("SKUI|panel|reset=init_game")),
        ("pages return to page 1", back_to_page1),
        ("damage/crit roll applied to bullets", has("SKD|dmg|n=1|before=1|after=2|crit=true|pierce=30")
                                                and bullet_dmg == 2),
        ("damage knobs cycle + persist", has("SKUI|cfg|on=1|dmg=1-2")
                                         and env["bank_store"].get((2, 0)) == 1),
        ("God Mode dodge relocates the king and preserves square occupancy",
         hero_moved and hero_occupancy_consistent and hp_after_hit and hp_after_hit > 0
         and has("SKUI|dodge|from=4,7|to=3,6|route=diagonal|moved=true")
         and has("SKE|call|goto_sq_hero=ok")
         and not has("SKE|call|goto_sq_sq=")),
        ("fake goto_sq models the verified (piece, square) API",
         len(env["goto_sq_calls"]) == 1
         and same_lua_table(env["goto_sq_calls"][0][0], g.hero)
         and same_lua_table(env["goto_sq_calls"][0][1], g.squares[1])),
        ("card LIST page + take by id", has("SKUI|card|page=1/1|pool=4")
                                        and has("SKE|cheat_card|mode=list|id=Right-hand")
                                        and has("via=card:Right-hand")),
        ("piece-card filter (FILT:PIECE)", has("SKUI|card|filter=piece|kept=1|of=4")
                                           and has("SKUI|panel|card_filter=piece")),
        ("spawn page picks the piece", has("SKUI|spawn|page=1/1|choices=3")
                                       and has("via=panel_pick")),
        ("spawn prefers a diagonal (never blocks the king)", has("SKUI|spawn|type=1|px=3|py=6|route=diagonal|via=panel_pick")),
        ("SAFE mode blocks the 2nd mutating call", safe_after == safe_before + 3
                                                   and has("SKE|call|inc_ammo=blocked|reason=safe_mode")),
        ("SAFE-blocked King dodge preserves coordinates and occupancy",
         safe_dodge_blocked_unchanged),
        ("engine-call intent logging", has("SKE|call|inc_ammo=start")
                                       and has("SKE|call|inc_ammo=ok|r=")),
        ("mod menu: legend is a plain far-left entity (no button)", legend_created
                                    and legend_layout and legend_centred
                                    and has("SKUI|modmenu|legend=created|dp=4")),
        ("RUN-6 BUG: clicking a mod name updates its ON/OFF text", toggled_text_on
                                    and toggled_text_off and back_after_on),
        ("RUN-6 BUG: on->off again restores Back (no forced reboot)", back_restored
                                    and back_returns and has("SKUI|modmenu|legend=removed")),
        ("reorder arrows keep names in sync; undo restores Back", moved_names and move_undone),
        ("dependency check predicts the red boot texts", predicted
                                    and has("SKUI|modmenu|sync=open|back=back|issues=2|codes=E1,E3")
                                    and has("SKUI|modcheck|boot|issues=0|codes=none")),
        ("AUTO-FIX: dependency order + needed mods ON, menu rebuilt", autofix_ok
                                    and has("SKUI|modmenu|autofix=true|moved=")
                                    and has("enabled=COLLECTION,TERMINAL")),
        ("engine Reset restores boot list and Back", reset_ok),
        ("order-only problems flagged (Terminal not last, Collection below)", order_codes),
        ("silent Terminal clients (Quartz, Extra Features) named in E1", silent_clients),
        ("worst-case legend + AUTO-FIX fits the 180-px screen", legend_fits),
        ("READY precedes SKCF probes", ready_idx >= 0 and probe_idx > ready_idx),
        ("loadfile absence logged", has("SKA2|loadfile=no")),
        ("probe block checkpoints", has("SKA2|probe|cards=done") and has("SKA2|probe|exclude=done")
                                    and has("SKA2|probe|souls=done") and has("SKA2|probe|bank=done")
                                    and has("SKA2|probe|input=done")),
        ("probe done marker", has(f"SK-REWORK: PROBE done build={BUILD_NO}")),
        ("ammo cheat changes state", ammo_after == before_ammo + 3),
    ]
    bad = [name for name, ok in checks if not ok]

    sys.path.insert(0, HERE)
    import parse_log
    d = parse_log.parse_text(text)
    parser_checks = [
        ("parser build/READY", d["banner"] is not None and d["banner"]["build"] == BUILD_NO
                              and d["ready"] is not None and d["ready"]["build"] == BUILD_NO),
        ("parser hooks", len(d["hooks"]) >= 15),
        ("parser world samples", len(d["world"]) >= 2),
        ("parser cards", len(d["cards"]) == 4),
        ("parser all card fields", d["card_fields"]["Right-hand"].get("special") == "strafe"
                                and "__CARD_COUNT__" not in d["card_fields"]),
        ("parser EXCLUDE pairs", d["exclude_pairs"] == ["Royal Loafers<>Sawed-off Justice"]),
        ("parser offer records", len(d["offers"]) >= 4),
        ("parser soul probe", len(d["souls"]) >= 6),
        ("parser damage probe", len(d["damage"]) >= 6),
        ("parser input probe", len(d["input"]) >= 10),
        ("parser UI probe", len(d["ui"]) >= 4),
        ("parser replaceable", "hero" in d["replaceable"]),
        ("parser ammo candidates", "ammo_spend" in parse_log._candidates(
            d["globals"], parse_log.GROUPS["ammo / shells (map.md: spend & refill TBD)"])),
    ]
    bad += [name for name, ok in parser_checks if not ok]

    md = parse_log.render_markdown(d, "<smoketest-build-8>")
    if ("Did the mod load?" not in md or "Full card fields & EXCLUDE pairs" not in md
            or "Offer-roll choices & filters" not in md):
        bad.append("parser Build-6 markdown rendering")

    if dump:
        print("--- Build-6 captured mod log lines ---")
        for line in captured:
            print(line)
        print("--- end ---")

    total = len(checks) + len(parser_checks) + 1
    print(f"smoke test [{mode}]: {total - len(bad)}/{total} checks passed")
    for name in bad:
        print(f"  FAILED [{mode}]: {name}")
    out = os.path.join(tempfile.gettempdir(), f"sk-rework-smoketest-log-{mode}.txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"captured log -> {out}")
    return not bad


def main(argv):
    try:
        import lupa
    except ImportError:
        print("SKIP: Lua smoke test requires the dev-only 'lupa' package; install it with:", flush=True)
        print("    python -m pip install lupa", flush=True)
        print("Running the independent parser selftest; this does not replace the Lua checks.", flush=True)
        parser = subprocess.run(
            [sys.executable, os.path.join(HERE, "parse_log.py"), "--selftest"],
            check=False,
        )
        if parser.returncode != 0:
            print(f"FAIL: parser selftest exited with status {parser.returncode}")
            return 1
        print("Lua smoke test: SKIPPED (lupa unavailable); parser selftest: PASSED")
        print("Exit status 2 means SKIPPED; do not report this run as a Lua pass.")
        return 2

    try:
        src = open(MOD, encoding="utf-8").read()
    except OSError as exc:
        print(f"FAIL: can't read mod script: {exc}")
        return 1

    runtimes = [("default", lupa.LuaRuntime)]
    try:
        from lupa.luajit21 import LuaRuntime as LuaJIT21Runtime
        runtimes.append(("luajit21", LuaJIT21Runtime))
    except ImportError:
        print("LuaJIT 2.1 backend not bundled by this lupa install; testing default backend only.")

    results = {}
    for runtime_name, runtime_cls in runtimes:
        for semantics in ("value", "pair"):
            mode = f"{runtime_name}-{semantics}"
            L = runtime_cls(unpack_returned_tuples=True)
            env = build_env(L, semantics)
            try:
                L.globals().__sk_sandbox_load(src, to_lua(L, ENGINE_REPLACEABLE))
            except Exception as exc:
                print(f"FAIL[{mode}]: mod raised an error at load: {exc}")
                return 1
            results[mode] = run_scenario(L, env, mode, dump=("--dump" in argv))

    ok = all(results.values())
    runtimes_run = ", ".join(name for name, _ in runtimes)
    print(f"all()-semantics variants: value/pair passed for {runtimes_run}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
