#!/usr/bin/env python3
"""Mod smoke test — run modded/sk-rework/script.lua against a FAKE SUGAR game.

The real engine can't run here (no Windows, no game), but the mod's *logic*
can: this builds a fake Lua environment with the globals the shipped workshop
mods prove exist (MODLIST, gimme, all, append, _log, hero/bads/bullets…),
runs our script, fires the hooks the way the game would, and then feeds the
captured log lines to tools/parse_log.py.

What it catches: load-time errors, nil/boolean crashes in the logging helpers,
wrong log-line formats (parser compatibility), hooks that never register.

Needs `lupa` (dev-only dependency):
    pip install lupa        # or run with a venv that has it

Usage:
    python tools/mod_smoketest.py            # run + report
    python tools/mod_smoketest.py --dump     # also show the captured lines
"""
import os, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
MOD = os.path.join(REPO, "modded", "sk-rework", "script.lua")

FAKE_ENGINE_LINES = [
    "SUGAR v0.0.8f (LuaJIT 2.1) boot",
    "loaded lang/english.txt",
]


def to_lua(L, obj):
    """Recursively convert Python dicts/lists into real Lua tables."""
    if isinstance(obj, dict):
        return L.table_from({k: to_lua(L, v) for k, v in obj.items()})
    if isinstance(obj, (list, tuple)):
        return L.table_from([to_lua(L, v) for v in obj])
    return obj


ALL_VALUE = """
-- shipped mods do `for x in all(t) do f(x) end`, so all() yields VALUES
function all(t)
    local i = 0
    return function()
        i = i + 1
        if t[i] ~= nil then return t[i] end
    end
end
"""

ALL_PAIR = """
-- alternative semantics: yields (index, value); the mod must survive this too
function all(t)
    local i = 0
    return function()
        i = i + 1
        if t[i] ~= nil then return i, t[i] end
    end
end
"""


def build_env(L, all_mode="value"):
    """Fake game globals — only names/patterns the workshop mods prove."""
    g = L.globals()
    captured = []
    hooks = {}
    g._log = lambda s: captured.append(str(s))

    L.execute(ALL_VALUE if all_mode == "value" else ALL_PAIR)

    g.MODLIST = to_lua(L, [
        {"title": "Glacies Module Terminal", "active": False},
        {"title": "SK Rework", "active": True},
    ])
    # build 4 dumps the card id map — card.id == display name (live-verified)
    g.CARDS = to_lua(L, [
        {"id": "Peace", "gid": 12, "ext": 0, "pwe": 4},
        {"id": "Right-hand", "gid": 157, "ext": 2, "pwe": 1, "special": True},
    ])
    # globals gimme() should report — mirrors the LIVE v1.623b result:
    # append/prepend/gimme/edit_disp_stats are NOT gimme globals (they are
    # mod-environment functions / Terminal callbacks), so they stay absent
    # here too and exercise the "no" branch of the API check.
    names = [
         "_log", "concat", "add", "del", "all",
         "get_slot_cards", "gsq", "mk_menu_but", "init_menu", "spawn_pieces",
         "new_piece", "setup_piece", "new_turn", "new_level", "add_card",
         "new_card", "CARDS", "get_disp_stats", "draw_mode",
         "goto_sq", "get_range", "throw_grenade", "mk_hint_but",
         "spend_hop", "uplift",
         "check_cards_auto_flip", "flip_card", "unflip_card",
         "set_mode", "init_game", "init_codex", "opp_turn", "wait",
         # map-relevant names the parser should group as candidates
         "ammo_spend", "shell_refill", "damage_piece", "xpl", "on_bad_hurt",
         "offer_card", "flip_card", "new_level", "spend_hop", "sort_spawn",
         "build_stack", "hero_death", "save_game", "mk_menu_but"]
    g.gimme = lambda what: to_lua(
        L,
        names if what == "global" else
        ["hero"] if what == "replaceable" else
        ["data_sgr"] if what == "forbidden" else [])

    def _append(target, fn, hook_id):
        hooks[target] = fn
        return None

    g.append = _append
    g.prepend = _append
    # fake game state (types chosen to be hostile: bools, nils, nested tables)
    g.hero = to_lua(L, {"hp": 3, "ammo": 5, "sq": {"px": 4, "py": 7}})
    g.bads = to_lua(L, [1, 2, 3])
    g.bullets = to_lua(L, [1, 2])
    return captured, hooks


def main(argv):
    try:
        import lupa
    except ImportError:
        print("lupa is not installed (dev-only dependency):\n"
              "    pip install lupa\n"
              "Skipping the Lua smoke test; the parser selftest still runs:\n"
              "    python tools/parse_log.py --selftest")
        return 0

    src = open(MOD, encoding="utf-8").read()
    results = []
    for mode in ("value", "pair"):
        L = lupa.LuaRuntime(unpack_returned_tuples=True)
        captured, hooks = build_env(L, mode)
        try:
            L.execute(src)
        except Exception as e:
            print(f"FAIL[{mode}]: the mod raised an error at load:", e)
            return 1
        results.append(run_scenario(L, hooks, captured, mode,
                                          dump=("--dump" in argv)))
    _, ok_value = results[0]
    _, ok_pair = results[1]
    print(f"all()-semantics variants: value={ok_value} pair={ok_pair}")
    if not (ok_value and ok_pair):
        return 1
    return 0


def run_scenario(L, hooks, captured, mode, dump=False):

    # fire the hooks the way the engine would, then some callback probes
    calls = [
        ("init_game", []), ("new_level", []),
        ("new_turn", []), ("new_turn", []),
        ("setup_piece", [to_lua(L, {"type": 0, "hp": 2, "name": "pawn"})]),
        ("add_card", [to_lua(L, {"id": "Peace", "pwe": 4, "gid": 12})]),
    ]
    for name, args in calls:
        fn = hooks.get(name)
        if fn is None:
            print(f"FAIL: hook '{name}' was never registered")
            return 1
        fn(*args) if args else fn()

    # build 4 defines NO on_*/upd/edit_disp_stats globals (the live run proved
    # the engine never calls them for plain mods) — nothing extra to fire.

    text = "\n".join(FAKE_ENGINE_LINES + captured) + "\n"

    # ── assertions on the captured output ──────────────────────────────────
    def has(frag):
        return any(frag in ln for ln in captured)

    checks = [
        ("load banner", has("SK-REWORK: BUILD=4 loaded (mod_index=2)")),
        ("modlist self-check", has("SKA2|mod_found=yes|active=true")),
        ("modlist entry dump", has("SKM|2|title=SK Rework")
                              and has("SKM|2|active=true")),
        ("api check", has("SKA|append|no") and has("SKA|_log|YES")),
        ("global dump", has("SKG|ammo_spend") and has("SK-REWORK: SKG count=")),
        ("replaceable/forbidden", has("SKR|hero") and has("SKF|data_sgr")),
        ("hook registrations", has("SKH|new_turn|sk-rework:turn")
                              and has("SKH|add_card|sk-rework:add_card")),
        ("turn state line", has("SKW|turn=1|bads=3|bullets=2|hero_px=4|hero_py=7")),
        ("object dumps", has("SKO|hero|hp=3") and has("SKO|hero|ammo=5")),
        ("piece event", has("SKE|setup_piece|n=1|type=0|hp=2")),
        ("card event", has("SKE|add_card|n=1|id=Peace|pwe=4")),
        ("card id map", has("SKC|Peace|gid=12") and has("SKC|Right-hand|gid=157")),
        ("no on_* probes (build 4)", not has("SKE2|")),
        ("loadfile probe logged", has("SKA2|loadfile=")),
        ("ready marker", has("SK-REWORK: READY build=4")),
        ("probe-done marker", has("SK-REWORK: PROBE done build=4")),
    ]
    bad = [n for n, ok in checks if not ok]

    # ── parser compatibility: feed the captured lines to parse_log.py ─────
    sys.path.insert(0, HERE)
    import parse_log
    d = parse_log.parse_text(text)
    parser_checks = [
        ("parser: banner", d["banner"] is not None),
        ("parser: ready", d["ready"] is not None),
        ("parser: api", d["api"].get("append") is False and
                        d["api"].get("_log") is True and
                        d["api"].get("throw_grenade") is True),
        ("parser: globals", len(d["globals"]) >= 40),
        ("parser: hooks", len(d["hooks"]) == 5),
        ("parser: append events", d["events"]["init_game"] == 1 and
                                  d["events"]["new_level"] == 1 and
                                  d["events"]["setup_piece"] == 1),
        ("parser: world rows", len(d["world"]) == 2),
        ("parser: modlist", d["modlist"]["2"].get("title") == "SK Rework"),
        ("parser: cards", [c["id"] for c in d["cards"]] ==
                          ["Peace", "Right-hand"]),
        ("parser: objects", d["objects"]["hero"]["ammo"] == "5"),
        ("parser: world", d["world"][0]["bads"] == "3"),
        ("parser: candidates", "ammo_spend" in
            parse_log._candidates(d["globals"], parse_log.GROUPS[
                "ammo / shells (map.md: spend & refill TBD)"])),
    ]
    bad += [n for n, ok in parser_checks if not ok]

    md = parse_log.render_markdown(d, "<smoketest>")
    if "Did the mod load?" not in md or "READY line" not in md:
        bad.append("parser: markdown incomplete")

    if dump:
        print("--- captured mod log lines ---")
        for ln in captured:
            print(ln)
        print("--- end ---")

    total = len(checks) + len(parser_checks) + 1
    print(f"smoke test [{mode}]: {total - len(bad)}/{total} checks passed")
    for b in bad:
        print(f"  FAILED [{mode}]:", b)

    # a real, parseable log artifact for eyeballing the markdown output
    out = os.path.join(tempfile.gettempdir(), f"sk-rework-smoketest-log-{mode}.txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"captured log -> {out}")
    return text, (not bad)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
