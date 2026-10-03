#!/usr/bin/env python3
"""SK-REWORK log parser — turns the diagnostics mod's log lines into a map.

The stub mod (`modded/sk-rework/`) writes greppable lines into the game's
`log.txt` during a live run. This reads that file and produces a draft of
`notes/map.md`'s unknowns: the global function map, the API surface, the live
object model, and candidate functions for each TBD area (ammo, damage, spawn,
card offers).

Line formats it understands (see modded/sk-rework/script.lua):
    SK-REWORK: BUILD=3 loaded (mod_index=2)
    SKA2|mod_found=yes|active=true
    SK-REWORK: globals visible = 452
    SKA|<name>|YES|no            API availability
    SKG|<name>  SKR|<name>  SKF|<name>    global / replaceable / forbidden
    SKH|<target>|<id>            hook registered
    SKE|<event>|k=v|...          event seen via append() hook
    SKE2|<event>|k=v|...         event seen via on_* callback probe
    SKO|<obj>|<key>=<value>      object field dump
    SKW|k=v|...                  per-turn world state
    SK-REWORK: READY build=3 hooks=5 globals=452

Usage:
    python tools/parse_log.py uploads/game-insights/log.txt
    python tools/parse_log.py <log> --out notes/game-map-draft.md
    python tools/parse_log.py <log> --print          # markdown to stdout
    python tools/parse_log.py <log> --json out.json  # machine-readable
    python tools/parse_log.py --selftest             # parser self-check

If the log contains no SK-REWORK lines, the tool explains what that means and
shows the tail of the log (the game writes its Lua error at the END).
"""
import sys, os, re, json, collections, datetime

MAGIC = "SK-REWORK:"
EVENT_APPEND = "SKE|"
EVENT_CALLBACK = "SKE2|"

# search groups distilled from notes/map.md's "search: ..." hints
GROUPS = {
    "ammo / shells (map.md: spend & refill TBD)": [
        "ammo", "shell", "chamber", "reload", "magazine", "mag", "spend",
        "refill", "reserve", "cartridge", "shot"],
    "damage / health / death (map.md: single entry point TBD)": [
        "dmg", "damage", "hurt", "hp", "health", "bleed", "kill", "death",
        "die", "xpl", "poison", "caltrops", "wound", "shield"],
    "spawn / pieces / floors (map.md: spawn decision TBD)": [
        "spawn", "piece", "bad", "wave", "floor", "level", "roster",
        "sort_spawn", "setup_piece"],
    "cards / offers / codex (map.md: offer roll TBD)": [
        "card", "offer", "draft", "pick", "codex", "flip", "deck", "pool",
        "pwe", "claim"],
    "turn flow / game loop": [
        "turn", "round", "opp", "wait", "init_game", "new_game", "end_level"],
    "UI / menu / buttons (for the cheat panel + pickers)": [
        "menu", "but", "hint", "panel", "draw_", "mk_", "cursor", "select"],
    "save / persistence": ["save", "load", "backup", "bank", "ev_", "sav"],
    "shots / bullets / aim (for ammo & shot mechanics)": [
        "fire", "shoot", "shotgun", "pellet", "bullet", "spread", "recoil",
        "knock", "pierce", "grenade", "throw", "aim"],
}
STRONG_VERBS = ("new_", "init_", "add_", "get_", "set_", "do_", "spend_",
                "mk_", "on_", "upd", "check_", "build_", "draw_")


# ── parsing ─────────────────────────────────────────────────────────────────
def parse_text(text: str) -> dict:
    d = {
        "banner": None, "ready": None, "warnings": [], "globals_visible": None,
        "mod_found": None, "mod_active": None, "api": {}, "hooks": [],
        "globals": [], "replaceable": [], "forbidden": [],
        "events": collections.Counter(), "event_samples": {},
        "callbacks": collections.Counter(), "callback_samples": {},
        "event_total": {}, "callback_total": {},
        "objects": collections.defaultdict(dict), "object_order": [],
        "world": [], "counts_reported": {}, "other_lines": 0, "tail": [],
    }
    lines = text.splitlines()
    for ln in lines:
        s = ln.strip()
        if s.startswith(MAGIC):
            body = s[len(MAGIC):].strip()
            m = re.match(r"BUILD=(\d+) loaded \(mod_index=(-?\d+)\)", body)
            if m:
                d["banner"] = {"build": int(m.group(1)), "mod_index": int(m.group(2))}
                continue
            if body.startswith("WARNING"):
                d["warnings"].append(body)
                continue
            m = re.match(r"globals visible = (\d+)", body)
            if m:
                d["globals_visible"] = int(m.group(1)); continue
            m = re.match(r"(SK[GRF]) count=(\d+)", body)
            if m:
                d["counts_reported"][m.group(1)] = int(m.group(2)); continue
            m = re.match(r"READY build=(\d+) hooks=(\d+) globals=(\d+)", body)
            if m:
                d["ready"] = {"build": int(m.group(1)), "hooks": int(m.group(2)),
                              "globals": int(m.group(3))}
                continue
            continue
        if s.startswith("SKA2|"):
            for part in s.split("|")[1:]:
                if "=" in part:
                    k, v = part.split("=", 1)
                    if k == "mod_found": d["mod_found"] = (v == "yes")
                    elif k == "active": d["mod_active"] = (v == "true")
            continue
        if s.startswith("SKA|"):
            parts = s.split("|")
            if len(parts) >= 3:
                d["api"][parts[1]] = (parts[2] == "YES")
            continue
        if s.startswith("SKH|"):
            parts = s.split("|")
            if len(parts) >= 3:
                d["hooks"].append({"target": parts[1], "id": parts[2]})
            continue
        if s.startswith("SKG|") or s.startswith("SKR|") or s.startswith("SKF|"):
            key = {"SKG": "globals", "SKR": "replaceable", "SKF": "forbidden"}[s[:3]]
            d[key].append(s[4:].strip())
            continue
        if s.startswith(EVENT_APPEND) or s.startswith(EVENT_CALLBACK):
            cb = s.startswith(EVENT_CALLBACK)
            payload = s.split("|")[1:]
            name = payload[0] if payload else "?"
            fields = {}
            for part in payload[1:]:
                if "=" in part:
                    k, v = part.split("=", 1)
                    fields[k] = v
            target = d["callbacks"] if cb else d["events"]
            samples = d["callback_samples"] if cb else d["event_samples"]
            totals = d["callback_total"] if cb else d["event_total"]
            target[name] += 1
            samples.setdefault(name, fields)
            if fields.get("n", "").isdigit():
                totals[name] = max(totals.get(name, 0), int(fields["n"]))
            continue
        if s.startswith("SKO|"):
            parts = s.split("|")
            if len(parts) >= 3:
                obj = parts[1]
                if obj not in d["objects"]:
                    d["object_order"].append(obj)
                for part in parts[2:]:
                    if "=" in part:
                        k, v = part.split("=", 1)
                        d["objects"][obj][k] = v
            continue
        if s.startswith("SKW|"):
            row = {}
            for part in s.split("|")[1:]:
                if "=" in part:
                    k, v = part.split("=", 1)
                    row[k] = v
            d["world"].append(row)
            continue
        d["other_lines"] += 1
    d["tail"] = [l for l in lines[-40:]]
    return d


# ── markdown rendering ──────────────────────────────────────────────────────
def _candidates(names, keywords):
    """names matching any keyword, strong-verb matches first."""
    hits = []
    for n in names:
        low = n.lower()
        if any(k in low for k in keywords):
            strong = low.startswith(STRONG_VERBS)
            hits.append((0 if strong else 1, low, n))
    hits.sort()
    return [h[2] for h in hits]


def render_markdown(d: dict, src: str) -> str:
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    out = []
    w = out.append
    w(f"# Draft game map — generated from `{os.path.basename(src)}`")
    w("")
    w(f"> Generated {now} by `tools/parse_log.py`. **Draft**: everything here "
      "comes from the diagnostics mod's live log; promote confirmed facts into "
      "`notes/map.md` by hand.")
    w("")

    # verdict
    w("## 1. Did the mod load?")
    w("")
    if d["banner"]:
        w(f"- ✅ mod loaded — build {d['banner']['build']}, "
          f"mod_index {d['banner']['mod_index']}")
    else:
        w("- ⛔ no load banner found — the mod did not run (check INSTALL.md step 5)")
    if d["mod_found"] is True:
        w(f"- ✅ found itself in MODLIST; active={d['mod_active']}")
    elif d["mod_found"] is False:
        w("- ⛔ loaded but could NOT find itself in MODLIST")
    if d["ready"]:
        r = d["ready"]
        w(f"- ✅ READY line: build {r['build']}, {r['hooks']} hooks registered, "
          f"{r['globals']} globals visible")
    for warn in d["warnings"]:
        w(f"- ⚠️ {warn}")
    w("")

    # API
    if d["api"]:
        have = [k for k, v in d["api"].items() if v]
        miss = [k for k, v in d["api"].items() if not v]
        w("## 2. API availability (planned functions)")
        w("")
        w(f"- available ({len(have)}): " + ", ".join(f"`{x}`" for x in have))
        if miss:
            w(f"- **not found** ({len(miss)}): " + ", ".join(f"`{x}`" for x in miss))
            w("- Not found = not in `gimme(\"global\")`: either the name is wrong "
              "or it is engine-internal. Adjust plans before coding against those.")
        w("")

    # hooks + dispatch verdict
    w("## 3. Hooks & event dispatch")
    w("")
    if d["hooks"]:
        w("Registered (append) hooks:")
        for h in d["hooks"]:
            w(f"- `{h['target']}` (id `{h['id']}`)")
    else:
        w("- ⛔ no hooks registered — script may not have reached that section")
    w("")
    app = d["events"]; cb = d["callbacks"]
    at = d["event_total"]; ct = d["callback_total"]

    def cell(lines, totals, name):
        if not lines.get(name):
            return "—"
        total = totals.get(name)
        if total is None or total == lines[name]:
            return str(lines[name])
        return f"{total} (sampled: {lines[name]} lines)"

    if app or cb:
        w("| event | via append() hook | via on_* callback probe |")
        w("|---|---|---|")
        for k in sorted(set(app) | set(cb)):
            w(f"| {k} | {cell(app, at, k)} | {cell(cb, ct, k)} |")
        if app and not cb:
            w("")
            w("- **Verdict:** append() hooks fire, `on_*` probes do not → for "
              "plain mods, events must be hooked with `append()` on game "
              "globals (the `on_*` dispatch comes from the Glacies Module "
              "Terminal mod, matching what the workshop mods show).")
        elif cb and not app:
            w("")
            w("- **Verdict:** `on_*` callbacks DO fire for plain mods — simpler "
              "callbacks are available than expected.")
        elif app and cb:
            w("")
            w("- **Verdict:** both mechanisms fire — careful about double "
              "counting when implementing features.")
        if app.get("heartbeat"):
            w("- ✅ heartbeat seen → the mod is alive during gameplay.")
    else:
        w("- ⚠️ no events fired — the mod loaded but the run may have been "
          "too short (start a floor and take a few turns).")
    w("")

    # world/state
    if d["world"]:
        w("## 4. Live state samples")
        w("")
        w("| " + " | ".join(d["world"][0].keys()) + " |")
        w("|" + "---|" * len(d["world"][0]))
        rows = d["world"] if len(d["world"]) <= 10 else \
            d["world"][:5] + [{k: "…" for k in d["world"][0]}] + d["world"][-5:]
        for row in rows:
            w("| " + " | ".join(str(v) for v in row.values()) + " |")
        w("")
    if d["objects"]:
        w("## 5. Object model (real field names from the running game)")
        w("")
        for obj in d["object_order"]:
            fields = d["objects"][obj]
            if not fields:
                continue
            w(f"- **{obj}**: " + ", ".join(f"`{k}={v}`" for k, v in
                                           list(fields.items())[:20]))
        w("")

    # function map
    globals_ = sorted(set(d["globals"]))
    w("## 6. Function map (candidates for the TBD areas)")
    w("")
    w(f"`gimme(\"global\")` returned {len(globals_)} names.")
    w("")
    for title, kws in GROUPS.items():
        hits = _candidates(globals_, kws)
        w(f"### {title}")
        if hits:
            w(", ".join(f"`{h}`" for h in hits[:80]) +
              (f" … (+{len(hits)-80} more)" if len(hits) > 80 else ""))
        else:
            w("_(no names matched — widen the search or inspect manually)_")
        w("")

    if d["replaceable"]:
        w("## 7. Replaceable globals (mods may replace these outright)")
        w("")
        w(", ".join(f"`{x}`" for x in sorted(set(d["replaceable"]))))
        w("")
    if d["forbidden"]:
        w("## 8. Forbidden globals (do not touch)")
        w("")
        w(", ".join(f"`{x}`" for x in sorted(set(d["forbidden"]))))
        w("")

    w("## 9. Full global list")
    w("")
    w("```")
    for i in range(0, len(globals_), 6):
        w("  ".join(f"{n:<26}" for n in globals_[i:i + 6]).rstrip())
    w("```")
    w("")
    w("## 10. Next step")
    w("")
    w("- Promote confirmed entries into `notes/map.md` (replace the TBD lines).")
    w("- Pick the dev-cheat panel targets from the ammo/UI candidate lists.")
    w(f"- Lines from other systems in the log: {d['other_lines']} "
      "(ignored; raise an issue if the game seems noisy).")
    return "\n".join(out) + "\n"


# ── CLI ─────────────────────────────────────────────────────────────────────
SELFTEST_LOG_APPEND = """\
SK-REWORK: BUILD=3 loaded (mod_index=2)
SKA2|mod_found=yes|active=true
SK-REWORK: globals visible = 5
SKA|append|YES
SKA|nope_missing|no
SKH|new_turn|sk-rework:turn
SKG|ammo_spend
SKG|damage_piece
SKG|xpl
SKG|spawn_pieces
SKG|offer_card
SKG|mk_menu_but
SK-REWORK: SKG count=6
SKR|hero
SKF|data_sgr
SKE|init_game|n=1
SKE|new_level|n=1
SKE|heartbeat|frames=900|turn=3
SKW|turn=1|bads=3|bullets=2|hero_px=4|hero_py=7
SKO|hero|hp=3
SKO|hero|ammo=5
SKE|setup_piece|n=1|type=0|hp=2
SK-REWORK: READY build=3 hooks=5 globals=5
"""

SELFTEST_LOG_CALLBACK = """\
SK-REWORK: BUILD=3 loaded (mod_index=2)
SKG|foo
SK-REWORK: SKG count=1
SKE2|on_fire|n=1
SKE2|on_bad_hurt|n=2|type=3|hp=1
SK-REWORK: READY build=3 hooks=5 globals=1
"""


def selftest() -> int:
    d = parse_text(SELFTEST_LOG_APPEND)
    checks = [
        ("banner", d["banner"] and d["banner"]["build"] == 3),
        ("mod found", d["mod_found"] is True),
        ("api yes/no", d["api"].get("append") is True and d["api"].get("nope_missing") is False),
        ("hooks", len(d["hooks"]) == 1 and d["hooks"][0]["target"] == "new_turn"),
        ("globals", len(d["globals"]) == 6),
        ("replaceable", d["replaceable"] == ["hero"]),
        ("forbidden", d["forbidden"] == ["data_sgr"]),
        ("append events", d["events"]["new_level"] == 1),
        ("no callback events", sum(d["callbacks"].values()) == 0),
        ("objects", d["objects"]["hero"]["hp"] == "3"),
        ("world", d["world"][0]["turn"] == "1"),
        ("ready", d["ready"] is not None),
    ]
    md = render_markdown(d, "<selftest-append>")
    for needle in ("Did the mod load?", "append() hooks fire", "heartbeat seen",
                   "ammo / shells", "Object model", "Full global list"):
        if needle not in md:
            bad_needle = needle
            checks.append((f"markdown missing: {bad_needle}", False))

    d2 = parse_text(SELFTEST_LOG_CALLBACK)
    md2 = render_markdown(d2, "<selftest-callback>")
    checks.append(("callback verdict", "on_*` callbacks DO fire" in md2))
    checks.append(("callback total from n=", d2["callback_total"]["on_bad_hurt"] == 2))
    checks.append(("callback lines counted", d2["callbacks"]["on_bad_hurt"] == 1))
    checks.append(("sampling shown in table", "sampled: 1 lines" in md2))

    bad = [name for name, ok in checks if not ok]
    print(f"selftest: {len(checks) - len(bad)}/{len(checks)} checks passed")
    for b in bad:
        print("  FAILED:", b)
    return 1 if bad else 0


def main(argv):
    if "--selftest" in argv:
        return selftest()
    if not argv[1:] or argv[1] in ("-h", "--help"):
        print(__doc__)
        return 0

    src = argv[1]
    if not os.path.isfile(src):
        raise SystemExit(
            f"log file not found: {src}\n"
            "  collect it first with:\n"
            "    tools/apply.ps1 -GameDir \"<game folder>\" -GetLog\n"
            "  (writes uploads/game-insights/log.txt in the repo)")
    text = open(src, encoding="utf-8", errors="replace").read()
    d = parse_text(text)

    if not d["banner"] and not d["globals"]:
        print("This log contains no SK-REWORK lines -> the mod did not run.")
        print("Check: mods\\sk-rework exists in the game folder you launched, "
              "and it is enabled in the in-game mod menu (INSTALL.md step 5).")
        print("\n--- last 15 lines of the log (Lua errors appear at the end) ---")
        for ln in [l for l in text.splitlines() if l.strip()][-15:]:
            print("   " + ln)
        return 2

    md = render_markdown(d, src)
    out = argv[argv.index("--out") + 1] if "--out" in argv else \
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "..",
                     "notes", "game-map-draft.md")
    if "--json" in argv:
        jp = argv[argv.index("--json") + 1]
        with open(jp, "w", encoding="utf-8") as f:
            json.dump({k: v for k, v in d.items() if k not in ("tail",)},
                      f, indent=2, default=str)
        print(f"json    -> {jp}")
    if "--print" in argv:
        sys.stdout.write(md)
    else:
        with open(out, "w", encoding="utf-8") as f:
            f.write(md)
        print(f"draft   -> {os.path.relpath(out)}")

    g = len(set(d["globals"]))
    print(f"loaded: {'yes' if d['banner'] else 'NO'} · "
          f"hooks: {len(d['hooks'])} · globals: {g} · "
          f"append-events: {sum(d['events'].values())} · "
          f"callback-events: {sum(d['callbacks'].values())} · "
          f"object tables: {len(d['objects'])}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
