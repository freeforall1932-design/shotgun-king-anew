#!/usr/bin/env python3
"""Build-5 smoke test — run sk-rework against a fake SUGAR environment.

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
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
MOD = os.path.join(REPO, "modded", "sk-rework", "script.lua")

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


def build_env(L, all_mode="value"):
    """Install Lua wrapper functions so fake engine APIs have Lua type=function."""
    g = L.globals()
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
    L.execute(ALL_VALUE if all_mode == "value" else ALL_PAIR)

    g.MODLIST = to_lua(L, [
        {"title": "Glacies Module Terminal", "name": "glac terminal", "active": False},
        {"title": "SK Rework", "name": "sk-rework", "folder": "mods/sk-rework", "active": True},
    ])
    g.CARDS = to_lua(L, [
        {"id": "Peace", "gid": 12, "ext": 0, "pwe": 4, "sac": [1], "gain": [2, 2]},
        {"id": "Right-hand", "gid": 157, "ext": 2, "pwe": 1, "special": "strafe"},
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
    ]
    replaceable_names = ["hero", "stack", "ammo", "chamber", "scepters"]

    def gimme(which):
        if which == "global": return to_lua(L, global_names)
        if which == "replaceable": return to_lua(L, replaceable_names)
        if which == "forbidden": return to_lua(L, ["data_sgr"])
        return to_lua(L, [])
    bind("gimme", gimme)

    def register(target, fn, hook_id=None):
        hooks[target] = fn
        if hook_id:
            appends.setdefault(target, []).append(hook_id)

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
    g.stack = to_lua(L, {"special": "strafe", "pierce": 30, "ammo_max": 6, "chamber_max": 2})
    g.bads = to_lua(L, [1, 2, 3])
    g.bullets = to_lua(L, [
        {"dmg": 1, "pierce": 30, "shot": True, "x": 10, "y": 20, "life": 8},
        {"dmg": 1, "pierce": 0, "shot": True, "x": 12, "y": 22, "life": 8},
    ])
    squares = [
        {"px": 3, "py": 6, "x": 48, "y": 96},
        {"px": 4, "py": 6, "x": 64, "y": 96},
        {"px": 5, "py": 6, "x": 80, "y": 96},
    ]
    g.squares = to_lua(L, squares)
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

    def engine_pick(filters):
        # First dynamic black card; the real game selects a random eligible card.
        ca = g.CARDS[1]
        if "pick" in hooks: hooks["pick"](filters)
        return ca
    bind("pick", engine_pick)

    def engine_add_card(ca):
        if "add_card" in hooks: hooks["add_card"](ca)
    bind("add_card", engine_add_card)

    def engine_add_soul(a1, a2=None, a3=None, a4=None):
        if "add_soul" in hooks: hooks["add_soul"](a1, a2, a3, a4)
    bind("add_soul", engine_add_soul)

    def engine_add_scepter(a1=None, a2=None):
        if "add_scepter" in hooks: hooks["add_scepter"](a1, a2)
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
        if "init_menu" in hooks: hooks["init_menu"]()
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
            hooks["add"](g.ents, ent)
        if "mk_menu_but" in hooks:
            hooks["mk_menu_but"](ident, x, y, w, h)
    bind("mk_menu_but", engine_mk_menu_but)

    def engine_level_up(data, next_fn=None):
        if "level_up" in hooks: hooks["level_up"](data, next_fn)
    bind("level_up", engine_level_up)

    def engine_is_card_available(ca):
        if "is_card_available" in hooks: hooks["is_card_available"](ca)
        return True
    bind("is_card_available", engine_is_card_available)

    def engine_fire():
        if "fire" in hooks: hooks["fire"]()
    bind("fire", engine_fire)

    def engine_fx_damage(target, amount):
        if "fx_dmg" in hooks: hooks["fx_dmg"](target, amount)
    bind("fx_dmg", engine_fx_damage)

    def engine_ev_hit(target, amount):
        if "ev_hit" in hooks: hooks["ev_hit"](target, amount)
    bind("ev_hit", engine_ev_hit)

    def engine_xpl(target):
        if "xpl" in hooks: hooks["xpl"](target)
    bind("xpl", engine_xpl)

    return {
        "captured": captured,
        "hooks": hooks,
        "prepends": prepends,
        "appends": appends,
        "native_buttons": native_buttons,
        "bank_store": bank_store,
        "init_menu_calls": init_menu_calls,
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
        fn = hooks.get(name)
        if fn is None:
            print(f"FAIL[{mode}]: hook '{name}' was never registered")
            return False
        fn(*args)

    # Simulate mod-menu native buttons and validate the Back action.
    pre_menu = prepends.get("init_menu")
    if pre_menu: pre_menu()
    g.mk_menu_but("SK Rework", 0, 0, 80, 12)
    back = call_button(env, "< BACK")

    # Fire init_game, open the Dev panel, then click each safe control.
    if "init_game" not in hooks:
        print(f"FAIL[{mode}]: init_game hook was not registered")
        return False
    hooks["init_game"]()
    header = find_button(env, "SK DEV")
    if header is None:
        print(f"FAIL[{mode}]: native SK DEV button was not created")
        return False
    # Header toggles action buttons.
    header["fn"]()
    for label in ("+3 AMMO", "RANDOM CARD", "SPAWN ALLY", "GOD MODE", "DMG GATED"):
        if find_button(env, label) is None:
            print(f"FAIL[{mode}]: native Dev action was not created: {label}")
            return False
    # Trigger actions individually. `CLOSE` is not clicked until assertions read its marker.
    before_ammo = g.ammo
    env["native_buttons"][[i for i, b in enumerate(env["native_buttons"]) if b["label"] == "+3 AMMO"][-1]]["fn"]()
    ammo_after = g.ammo
    env["native_buttons"][[i for i, b in enumerate(env["native_buttons"]) if b["label"] == "RANDOM CARD"][-1]]["fn"]()
    env["native_buttons"][[i for i, b in enumerate(env["native_buttons"]) if b["label"] == "SPAWN ALLY"][-1]]["fn"]()
    env["native_buttons"][[i for i, b in enumerate(env["native_buttons"]) if b["label"] == "GOD MODE"][-1]]["fn"]()
    env["native_buttons"][[i for i, b in enumerate(env["native_buttons"]) if b["label"] == "DMG GATED"][-1]]["fn"]()

    # A God Mode hit should leave hero HP unchanged in the fake engine.
    hp_before_hit = g.hero.hp
    g.hit(g.hero, 2, to_lua(L, {}))
    hp_after_hit = g.hero.hp
    close_button = find_button(env, "CLOSE")
    if close_button is not None:
        close_button["fn"]()

    # Simulate an actual menu button ID from MODLIST; the hook adds Back + legend.
    g.mk_menu_but("2. SK Rework", 0, 0, 80, 12)
    text = "\n".join(FAKE_ENGINE_LINES + captured) + "\n"

    def has(fragment):
        return any(fragment in line for line in captured)

    # Ensure the promised marker precedes every static §0.7 dump.
    ready_idx = next((i for i, line in enumerate(captured) if "READY build=6" in line), -1)
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
        ("build-6 load banner", has("SK-REWORK: BUILD=6 loaded (mod_index=2)")),
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
        ("menu button ID probe", has("SKI|menu_button|n=1|id=SK Rework")
                                 and has("SKI|menu_but|n=1|id=SK Rework")),
        ("native panel controls", has("SKUI|panel|available=true|native=mk_text_but")
                                  and has("SKE|cheat_ammo|amount=3")
                                  and has("SKE|cheat_card|id=Peace")
                                  and has("SKE|cheat_spawn|type=0|name=pawn")
                                  and has("SKUI|panel|god_mode=true")
                                  and has("SKUI|panel|open=false")
                                  and env["bank_store"].get((0, 0)) == 505
                                  and env["bank_store"].get((1, 0)) == 1),
        ("God Mode hook basic path", hp_after_hit == hp_before_hit),
        ("native mod-menu Back + legend", has("SKUI|menu|widgets_added=true|entry=SK Rework|back=true")
                                          and back is not None),
        ("back click returns through init_menu", has("SKUI|menu|back_clicked=true")
                                                 and env["init_menu_calls"][0] == 1),
        ("damage control clearly gated", has("SKUI|panel|damage_controls=deferred_until_live_damage_probe")),
        ("READY precedes SKCF probes", ready_idx >= 0 and probe_idx > ready_idx),
        ("loadfile absence logged", has("SKA2|loadfile=no")),
        ("probe block checkpoints", has("SKA2|probe|cards=done") and has("SKA2|probe|exclude=done")
                                    and has("SKA2|probe|souls=done") and has("SKA2|probe|bank=done")
                                    and has("SKA2|probe|input=done")),
        ("probe done marker", has("SK-REWORK: PROBE done build=6")),
        ("ammo cheat changes state", ammo_after == before_ammo + 3),
    ]
    bad = [name for name, ok in checks if not ok]

    sys.path.insert(0, HERE)
    import parse_log
    d = parse_log.parse_text(text)
    parser_checks = [
        ("parser build/READY", d["banner"] is not None and d["banner"]["build"] == 6
                              and d["ready"] is not None and d["ready"]["build"] == 6),
        ("parser hooks", len(d["hooks"]) >= 15),
        ("parser world samples", len(d["world"]) == 2),
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

    md = parse_log.render_markdown(d, "<smoketest-build-6>")
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
        print("lupa is not installed (dev-only dependency):\n"
              "    pip install lupa\n"
              "Skipping the Lua smoke test; parser selftest still runs:\n"
              "    python tools/parse_log.py --selftest")
        return 0

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
                L.execute(src)
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
