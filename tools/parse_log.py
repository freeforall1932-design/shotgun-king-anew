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
    SKM|<i>|k=v|...              MODLIST entry dump (build 4+)
    SKC|<id>|k=v|...             CARDS id map (build 4+)
    SKML|...                     mods/modlist.lua probe (build 4+)
    SKCF|<id>|k=v|...            Full card fields & EXCLUDE pairs (build 5+)
    SKOF|<kind>|k=v|...           Offer-roll choices/filters (build 5+)
    SKS|<tag>|k=v|...            Souls, scepters & PIECES dump (build 5+)
    SKD|<tag>|k=v|...            Damage & bullet pipeline dump (build 5+)
    SKI|<tag>|k=v|...            Input, mouse & btn() probe (build 5+)
    SKUI|<tag>|k=v|...           Dev panel, mod menu & bank persistence (build 5+)
    " !! <red text>"               mod error codes T1..B1 (see notes/red-warnings.md)
    SK-REWORK: READY build=5 hooks=15 globals=920

The game wraps every log line in a "  . " (info) / " !! " (warning) marker;
this parser strips that marker first, so both raw mod output and a real
log.txt parse identically (bug found by the first live test).

Usage (full paths — works from ANY folder in PowerShell):
    python "E:\\testing\\repo\\tools\\parse_log.py" "E:\\testing\\repo\\uploads\\game-insights\\log.txt"
    python "E:\\testing\\repo\\tools\\parse_log.py" <log> --out notes/game-map-draft.md
    python "E:\\testing\\repo\\tools\\parse_log.py" <log> --print          # markdown to stdout
    python "E:\\testing\\repo\\tools\\parse_log.py" <log> --json out.json  # machine-readable
    python "E:\\testing\\repo\\tools\\parse_log.py" --selftest             # parser self-check

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
# ── red text = error codes (owner rule, session 10) ─────────────────────────
# Every red line a turned-on mod prints on the main menu / mod menu means that
# mod clashes or is not working as intended. The game writes them to log.txt
# as " !! <text>" (wlog). Code table, causes and fixes: notes/red-warnings.md.
# (code, regex, meaning, fix)
RED_CODES = [
    ("T1", r"^Glac Terminal is not loaded correctly!",
     "a Terminal-based mod (Collection / Card Lab / Grenade Predictor) can't see Glac Terminal",
     "turn Glac Terminal ON and move it to the LAST row (mod menu AUTO-FIX)"),
    ("T2", r"^Retry after Death: Glac Terminal is not active",
     "Retry is on but Glac Terminal is off", "turn Glac Terminal ON (AUTO-FIX)"),
    ("T3", r"^Retry after Death must be loaded above Glac Terminal",
     "Retry sits below Glac Terminal", "move Glac Terminal to the last row (AUTO-FIX)"),
    ("A1", r"^Glacies' Collection needs to be loaded above The Art of War",
     "Art of War sits above Glacies' Collection (or Collection is off)",
     "Collection ON and above Art of War (AUTO-FIX)"),
    ("A2", r"^The Art of War: Glac Terminal is not active",
     "Art of War is on but Glac Terminal is off", "turn Glac Terminal ON (AUTO-FIX)"),
    ("A3", r"^The Art of War must be loaded above Glac Terminal",
     "Art of War sits below Glac Terminal", "move Glac Terminal to the last row (AUTO-FIX)"),
    ("D1", r"^Glacies' Collection must be turned on",
     "Disgraced Justice is on but Glacies' Collection is off",
     "turn Glacies' Collection ON, above Disgraced Justice (AUTO-FIX)"),
    ("C1", r"^Argument .* not found\. Process terminated",
     "a Glac Terminal command named an argument that does not exist",
     "re-check the console command; harmless to other mods"),
    ("C2", r"^Glacies' Collection is not loaded correctly",
     "a mod can't see Glacies' Collection", "turn Collection ON, above its dependents"),
    ("S1", r"(Not allowed to change value for index|Attempt to use forbidden)",
     "a mod touched a value the engine sandbox protects",
     "that mod is broken on this game version; report the index named in the text"),
    ("L1", r"didn't match any files",
     "a mod loaded its art/sound with the old newsrf(\"file\", name) order, so nothing loaded "
     "(fixed in our dist-overlay copies since Build 8)",
     "an unpatched workshop copy got in: rebuild with build-dist.ps1 -Clean (Step 4) so the "
     "dist-overlay copy replaces it"),
    ("B1", r"^Save seems to be corrupted",
     "the main save failed its checksum; the game copied it to save/corrupted_save.bnk",
     "restore save/ from a backup; never hand-edit .bnk files"),
]
_RED_RX = [(c, re.compile(rx), m, f) for c, rx, m, f in RED_CODES]
# codes that only count when printed as a warning (" !! ") — their log()
# twin on a "  . " line would double-count
_RED_ANYLINE = {"S1"}


def classify_red(text: str):
    """the RED_CODES entry for one warning text, or None (engine noise)."""
    for c, rx, m, f in _RED_RX:
        if rx.search(text):
            return c, m, f
    return None


def parse_text(text: str) -> dict:
    d = {
        "banner": None, "ready": None, "warnings": [], "globals_visible": None,
        "mod_found": None, "mod_active": None, "api": {}, "hooks": [],
        "globals": [], "replaceable": [], "forbidden": [],
        "events": collections.Counter(), "event_samples": {},
        "callbacks": collections.Counter(), "callback_samples": {},
        "event_total": {}, "callback_total": {},
        "modlist": collections.OrderedDict(), "cards": [], "modlist_raw": [],
        "card_fields": collections.OrderedDict(), "exclude_pairs": [],
        "offers": [], "souls": [], "damage": [], "input": [], "ui": [],

        "checkpoints": [],
        "calls": [], "dmg_rolls": [], "panel": [],
        "crash": {"error": None, "frames": [], "quitting": False, "trace_seen": False,
                  "pending_call": None},
        "red": [], "loading": None, "modmenu": [], "modcheck": [],
        "objects": collections.defaultdict(dict), "object_order": [],
        "world": [], "counts_reported": {}, "other_lines": 0, "tail": [],
    }
    lines = text.splitlines()
    for ln in lines:
        s = ln.strip()
        # The game wraps info lines as "  . " and warnings as " !! ".
        # After strip(), these are ". …" and "!! …"; handle both so raw and
        # game-wrapped SK-prefixed lines parse identically.
        is_warn = False
        if s.startswith(". "):
            s = s[2:].strip()
        elif s.startswith("!! "):
            s = s[3:].strip(); is_warn = True
        elif s.startswith("! "):
            s = s[2:].strip(); is_warn = True
        m = re.match(r"Loading '(.+)' mod\.$", s)
        if m:
            d["loading"] = m.group(1)
        hit = classify_red(s)
        if hit and (is_warn or hit[0] in _RED_ANYLINE):
            code, meaning, fix = hit
            who = d["loading"]
            mm = re.search(r"'mods/([^/']+)/", s)
            if code == "L1" and mm:
                who = mm.group(1)
            d["red"].append({"code": code, "text": s, "mod": who,
                             "meaning": meaning, "fix": fix})
            continue
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
            # SKA2|probe|<name>=done — one marker per probe block, so a run
            # that dies mid-chain still shows how far it got (run 4 lost the
            # bank/persistence data because nothing marked the earlier blocks).
            m = re.match(r"SKA2\|probe\|([A-Za-z_]+)=done$", s)
            if m:
                if m.group(1) not in d["checkpoints"]:
                    d["checkpoints"].append(m.group(1))
                continue
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
        if s.startswith("SKE|call|"):
            # Build 7 logs intent BEFORE every engine-mutating call, so a
            # crashed log names the control that killed the game: the last
            # "=start" that never reached "=ok".
            payload = s[len("SKE|call|"):]
            name, _, rest = payload.partition("=")
            status = rest.split("|", 1)[0] if rest else "?"
            d["calls"].append({"name": name, "status": status})
            if status == "start":
                d["crash"]["pending_call"] = name
            elif d["crash"]["pending_call"] == name:
                d["crash"]["pending_call"] = None
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
        if s.startswith("SKM|"):
            parts = s.split("|")
            if len(parts) >= 3:
                entry = d["modlist"].setdefault(parts[1],
                                                collections.OrderedDict())
                for part in parts[2:]:
                    if "=" in part:
                        k, v = part.split("=", 1)
                        entry[k] = v
            continue
        if s.startswith("SKC|"):
            parts = s.split("|")
            if len(parts) >= 2:
                fields = {}
                for part in parts[2:]:
                    if "=" in part:
                        k, v = part.split("=", 1)
                        fields[k] = v
                fields["id"] = parts[1]
                d["cards"].append(fields)
            continue
        if s.startswith("SKML|"):
            d["modlist_raw"].append(s[5:])
            continue
        if s.startswith("SKCF|"):
            parts = s.split("|")
            if len(parts) >= 3:
                cid = parts[1]
                if cid == "__EXCLUDE__":
                    for part in parts[2:]:
                        if part.startswith("pair="):
                            pair_val = part.split("=", 1)[1]
                            if pair_val not in d["exclude_pairs"]:
                                d["exclude_pairs"].append(pair_val)
                else:
                    entry = d["card_fields"].setdefault(cid, collections.OrderedDict())
                    for part in parts[2:]:
                        if "=" in part:
                            k, v = part.split("=", 1)
                            entry[k] = v
            continue
        if s.startswith("SKOF|"):
            parts = s.split("|")
            if len(parts) >= 2:
                rec = {"kind": parts[1]}
                for part in parts[2:]:
                    if "=" in part:
                        k, v = part.split("=", 1)
                        rec[k] = v
                d["offers"].append(rec)
            continue
        if s.startswith("SKS|"):
            d["souls"].append(s[4:])
            continue
        if s.startswith("SKD|"):
            d["damage"].append(s[4:])
            if s.startswith("SKD|dmg|"):
                d["dmg_rolls"].append(s[8:])
            continue
        if s.startswith("SKI|"):
            d["input"].append(s[4:])
            continue
        if s.startswith("SKUI|"):
            d["ui"].append(s[5:])
            tag = s[5:].split("|", 1)[0]
            if tag in ("panel", "card", "spawn", "dodge", "cfg", "api", "menu"):
                d["panel"].append(s[5:])
            if tag in ("modmenu", "modcheck"):
                d[tag].append(s[5:])
            continue
        # Crash detection (run 4): a fatal engine error prints "ERR <msg>",
        # a tab-indented Stack traceback, then "Quitting required.". Without
        # this, a crashed run's draft looked like a successful harvest.
        if s.startswith("ERR "):
            d["crash"]["error"] = s[4:].strip()
            d["crash"]["frames"] = []
            continue
        if s.startswith("Stack traceback"):
            d["crash"]["trace_seen"] = True
            continue
        if s.startswith("Quitting required"):
            d["crash"]["quitting"] = True
            continue
        if (d["crash"]["trace_seen"] and ln.startswith("\t")
                and ": in " in s and len(d["crash"]["frames"]) < 12):
            # Tab-indented Lua traceback frame; stop at 12 or on any other
            # line so unrelated indented output is not swallowed.
            d["crash"]["frames"].append(s)
            continue
        d["other_lines"] += 1
    # Multi-boot logs: the mod-menu's "save and reboot" reloads every mod in
    # the SAME log.txt, so all dumps appear twice (run-3 live finding; the
    # reboot can even truncate the first boot's dump mid-line). Merge: keep
    # one entry per card id / hook target+id, last occurrence wins (the
    # later boot's dump is the complete one).
    _by_key = {}
    for c in d["cards"]:
        _by_key[c["id"]] = c
    d["cards"] = list(_by_key.values())
    _by_key = {}
    for h in d["hooks"]:
        _by_key[(h["target"], h["id"])] = h
    d["hooks"] = list(_by_key.values())
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
    if d["crash"]["error"]:
        w(f"- ⛔ **the game CRASHED during this run:** `{d['crash']['error']}`"
          + (" (Quitting required)" if d["crash"]["quitting"] else ""))
        if d["crash"].get("pending_call"):
            w(f"- ⛔ **last engine call that started but never finished:** "
              f"`{d['crash']['pending_call']}` — that control is the crash suspect "
              "(every mutating call logs `=start` before it runs and `=ok` after).")
        mod_frames = [f for f in d["crash"]["frames"] if "mods/" in f]
        if mod_frames:
            w(f"- ⛔ crash inside a mod — `{mod_frames[-1]}`")
        for frame in d["crash"]["frames"][:8]:
            w(f"    - `{frame}`")
        w("- A crashed run can still contain a full harvest (run 4 did): read the "
          "sections below, but treat runtime traces as absent.")
    if d["checkpoints"]:
        w(f"- ✅ probe blocks completed: " + ", ".join(f"`{c}`" for c in d["checkpoints"]))
        if "input" not in d["checkpoints"] and "cards" in d["checkpoints"]:
            w("- ⚠️ the chain stopped before the input block — a crash there is "
              "the run-4 failure mode; check the log tail for `ERR`/`Quitting required`")
    for warn in d["warnings"]:
        w(f"- ⚠️ {warn}")
    w("")

    # red text = error codes
    w("## 1b. Red text from mods (error codes)")
    w("")
    if not d["red"]:
        w("- ✅ no mod red text in this log")
    else:
        groups = collections.OrderedDict()
        for r in d["red"]:
            key = (r["code"], r["mod"] or "?")
            groups.setdefault(key, {"n": 0, "r": r})["n"] += 1
        w(f"- ⛔ **{len(d['red'])} red line(s) = {len(groups)} distinct error(s)** — "
          "each means a turned-on mod clashes or is not working as intended "
          "(code table: `notes/red-warnings.md`)")
        w("")
        w("| code | from mod | times | meaning | fix |")
        w("|---|---|---|---|---|")
        for (code, who), g in groups.items():
            r = g["r"]
            w(f"| **{code}** | `{who}` | {g['n']} | {r['meaning']} | {r['fix']} |")
    for ln in d["modcheck"]:
        w(f"- mod-order check (SK Rework): `SKUI|{ln}`")
    for ln in d["modmenu"][-6:]:
        w(f"- mod menu: `SKUI|{ln}`")
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
    # mod list state (build 4+: SKM| dumps every MODLIST entry)
    if d["modlist"]:
        w("## 10. Mod list (live MODLIST dump)")
        w("")
        for idx, fields in d["modlist"].items():
            w(f"- entry {idx}: " + ", ".join(f"`{k}={v}`"
                                             for k, v in fields.items()))
        w("")

    # card id map (build 4+: SKC| dumps CARDS)
    if d["cards"]:
        w("## 11. Card id map (live CARDS dump)")
        w("")
        w(f"{len(d['cards'])} cards. `id` is the display name (confirmed live: "
          "`SKE|add_card|id=A Piercing Truth`); stats.sav codex keys use the "
          "same names.")
        w("")
        w("| id | gid | ext | pwe |")
        w("|---|---|---|---|")
        for c in d["cards"]:
            w(f"| {c.get('id', '?')} | {c.get('gid', '—')} | "
              f"{c.get('ext', '—')} | {c.get('pwe', '—')} |")
        w("")

    # mods/modlist.lua probe (build 4+: SKML|)
    if d["modlist_raw"]:
        w("## 12. mods/modlist.lua (live probe)")
        w("")
        w("```")
        for ln in d["modlist_raw"]:
            w(ln)
        w("```")
        w("")

    # Build 5+: complete card fields and offer-roll observations.
    if d["card_fields"] or d["exclude_pairs"]:
        w("## 12b. Full card fields & EXCLUDE pairs (build 5+)")
        w("")
        for cid, fields in d["card_fields"].items():
            w(f"- **{cid}**: " + ", ".join(f"`{k}={v}`" for k, v in fields.items()))
        if d["exclude_pairs"]:
            w("- **EXCLUDE pairs**: " + ", ".join(f"`{p}`" for p in d["exclude_pairs"]))
        w("")

    if d["offers"]:
        w("## 12c. Offer-roll choices & filters (build 5+)")
        w("")
        for rec in d["offers"][:160]:
            kind = rec.get("kind", "?")
            rest = ", ".join(f"`{k}={v}`" for k, v in rec.items() if k != "kind")
            w(f"- **{kind}**" + (f": {rest}" if rest else ""))
        if len(d["offers"]) > 160:
            w(f"- _(showing 160 of {len(d['offers'])} logged offer records)_")
        w("")

    if d["souls"]:
        w("## 12d. Souls, scepters & pieces probe (build 5+)")
        w("")
        for ln in d["souls"][:40]:
            w(f"- `{ln}`")
        w("")

    if d["damage"]:
        w("## 12e. Damage & bullet pipeline probe (build 5+)")
        w("")
        for ln in d["damage"][:30]:
            w(f"- `{ln}`")
        w("")

    if d["input"]:
        w("## 12f. Input & button-remap probe (build 5+)")
        w("")
        for ln in d["input"][:40]:
            w(f"- `{ln}`")
        w("")

    if d["ui"]:
        w("## 12g. Dev panel, Mod Menu & Save persistence (build 5+)")
        w("")
        for ln in d["ui"][:30]:
            w(f"- `{ln}`")
        w("")

    if d["panel"] or d["calls"] or d["dmg_rolls"]:
        w("## 12h. Build 7 — panel v2, damage/crit, dodge & engine-call trace")
        w("")
        if d["calls"]:
            started = [c for c in d["calls"] if c["status"] == "start"]
            blocked = [c for c in d["calls"] if c["status"] == "blocked"]
            ok = [c for c in d["calls"] if c["status"] == "ok"]
            w(f"- engine calls: **{len(started)} started · {len(ok)} ok · "
              f"{len(blocked)} blocked by SAFE**")
            names = collections.OrderedDict()
            for c in started:
                names[c["name"]] = names.get(c["name"], 0) + 1
            if names:
                w("- call names: " + ", ".join(f"`{k}`×{v}" for k, v in list(names.items())[:20]))
            if blocked:
                w("- SAFE-blocked: " + ", ".join(f"`{c['name']}`" for c in blocked[:10])
                  + " (turn SAFE off in the panel to allow them)")
        rolls = d["dmg_rolls"][:12]
        if rolls:
            crits = sum(1 for r in rolls if "crit=true" in r)
            w(f"- damage rolls: {len(d['dmg_rolls'])} logged, {crits} crit in the first "
              f"{len(rolls)} sampled")
            for r in rolls[:6]:
                w(f"  - `{r}`")
        for ln in d["panel"][:24]:
            w(f"- `SKUI|{ln}`")
        w("")

    w("## 13. Next step")
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

    # regression (live test 2026-10-03): real game logs wrap every line in a
    # "  . " / " !! " marker — the parser must strip it before matching.
    d3 = parse_text(
        "  . SK-REWORK: BUILD=3 loaded (mod_index=9)\r\n"
        "  . SKA2|mod_found=yes|active=true\r\n"
        "  . SKA|append|no\r\n"
        " !! Could not open file 'save/mods/x.bnk': No such file or directory'.\r\n"
        " !! SKG|warning_prefixed_global\r\n"
        "  . SKG|ammo_spend\r\n"
        "  . SKM|1|title=SK Rework|active=true\r\n"
        "  . SKC|Peace|gid=12|pwe=4\r\n"
        "  . SKCF|Engraved Scope|gid=8|special=scope|pwe=4\r\n"
        "  . SKCF|__EXCLUDE__|pair=Royal Loafers<>Sawed-off Justice\r\n"
        "  . SKOF|is_card_available|id=Engraved Scope|special=scope|wand=nil\r\n"
        "  . SKOF|choice_1|team=0|need_soul=1\r\n"
        "  . SKS|piece|type=1|name=knight|hp=3\r\n"
        "  . SKD|bullet|shot_n=1|idx=1|dmg=2|pierce=30|shot=true\r\n"
        "  . SKI|btn|unsafe=false\r\n"
        "  . SKUI|bank|ready=true|magic=505\r\n"
        "  . SKML|load|function\r\n"
        "  . SKA2|probe|cards=done\r\n"
        "  . SKA2|probe|bank=done\r\n"
        "  . SK-REWORK: READY build=5 hooks=15 globals=1\r\n")
    checks.append(("prefixed banner", d3["banner"] is not None))
    checks.append(("prefixed api-no", d3["api"].get("append") is False))
    checks.append(("prefixed info globals", d3["globals"] == ["warning_prefixed_global", "ammo_spend"]))
    checks.append(("warning text remains other line", d3["other_lines"] == 1))
    checks.append(("prefixed ready", d3["ready"] is not None))
    checks.append(("modlist dump", d3["modlist"]["1"].get("title") == "SK Rework"))
    checks.append(("card map", d3["cards"][0]["id"] == "Peace"
                   and d3["cards"][0]["gid"] == "12"))
    checks.append(("modlist probe", d3["modlist_raw"] == ["load|function"]))
    checks.append(("card fields SKCF", d3["card_fields"]["Engraved Scope"].get("special") == "scope"))
    checks.append(("exclude pairs SKCF", d3["exclude_pairs"] == ["Royal Loafers<>Sawed-off Justice"]))
    checks.append(("offer probe SKOF", len(d3["offers"]) == 2 and d3["offers"][0]["id"] == "Engraved Scope"))
    checks.append(("souls SKS", len(d3["souls"]) == 1))
    checks.append(("damage SKD", len(d3["damage"]) == 1))
    checks.append(("input SKI", len(d3["input"]) == 1))
    checks.append(("ui SKUI", len(d3["ui"]) == 1))
    checks.append(("probe checkpoints SKA2", d3["checkpoints"] == ["cards", "bank"]))
    d7 = parse_text(
        "  . SK-REWORK: BUILD=7 loaded (mod_index=1)\r\n"
        "  . SK-REWORK: READY build=7 hooks=30 globals=920\r\n"
        "  . SKE|call|inc_ammo=start\r\n"
        "  . SKE|call|inc_ammo=ok|r=nil|budget=1\r\n"
        "  . SKE|call|add_card=start\r\n"
        "  . SKE|call|new_piece=blocked|reason=safe_mode|hint=SAFE off in the panel\r\n"
        "  . SKD|dmg|n=1|before=1|after=2|crit=true|pierce=30|range=1-2|critpct=10|critdmg=2\r\n"
        "  . SKUI|panel|open=true|page=1|buttons=13\r\n"
        "  . SKUI|spawn|type=1|px=3|py=6|route=diagonal|via=panel_pick|piece=tbl\r\n"
        "  . SKUI|dodge|from=4,7|to=3,6|route=diagonal|moved=true|reason=lethal_hit\r\n"
        "  . SKUI|cfg|on=1|dmg=1-2|crit=10%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=1|god_mode=false\r\n"
        "  . SKUI|bank|ready=true|magic=505|budget=1\r\n"
        "  . SKE|call|add_card=ok|r=nil|budget=0\r\n"
        "  . SRCH|rm -rf /tmp/nonexistent-path\r\n")
    md7 = render_markdown(d7, "<selftest-build-7>")
    checks.append(("build-7 calls parsed", [c["name"] for c in d7["calls"]] == [
        "inc_ammo", "inc_ammo", "add_card", "new_piece", "add_card"]))
    checks.append(("SAFE-blocked call recorded", any(
        c["name"] == "new_piece" and c["status"] == "blocked" for c in d7["calls"])))
    checks.append(("damage roll parsed", len(d7["dmg_rolls"]) == 1
                   and "crit=true" in d7["dmg_rolls"][0]))
    checks.append(("panel lines parsed", "panel|open=true|page=1|buttons=13" in d7["panel"]
                   and any(x.startswith("spawn|type=1") for x in d7["panel"])))
    checks.append(("build-7 section rendered", "Build 7 — panel v2, damage/crit, dodge & engine-call trace" in md7
                   and "blocked by SAFE" in md7))
    checks.append(("mutation-command line ignored", "rm -rf" not in md7))

    d8 = parse_text(
        "  . SK-REWORK: READY build=7 hooks=30 globals=920\r\n"
        "  . SKE|call|new_piece=start\r\n"
        "  . ERR Button left for player 0 doesn't exist.\r\n"
        "  . Quitting required.\r\n")
    md8 = render_markdown(d8, "<selftest-build-7-crash>")
    checks.append(("dangling call names the culprit", d8["crash"]["pending_call"] == "new_piece"
                   and "that control is the crash suspect" in md8))

    d4 = parse_text(
        "  . SK-REWORK: BUILD=5 loaded (mod_index=1)\r\n"
        "  . SK-REWORK: READY build=5 hooks=30 globals=920\r\n"
        "  . SKI|btn|unsafe=false\r\n"
        " !! Not recognizing button 'left', attempting to parse it as input code.\r\n"
        " !! Malformed input id 'left': must be '[k/m/c]:[key/button/[axis:direction]]'.\r\n"
        "ERR Button left for player 0 doesn't exist.\r\n"
        "\r\n"
        "Stack traceback: \r\n"
        "\t[string \"code.lua\"]:197: in function <[string \"code.lua\"]:45>\r\n"
        "\tmods/sk-rework/script.lua:817: in main chunk\r\n"
        "\r\n"
        "  . Quitting required.\r\n")
    checks.append(("crash detected", d4["crash"]["error"] == "Button left for player 0 doesn't exist."))
    checks.append(("crash traceback captured", len(d4["crash"]["frames"]) == 2
                   and d4["crash"]["quitting"] is True))
    md4 = render_markdown(d4, "<selftest-crash>")
    checks.append(("crash rendered in verdict", "the game CRASHED during this run" in md4
                   and "crash inside a mod" in md4 and "script.lua:817" in md4))
    md3 = render_markdown(d3, "<selftest-checkpoints>")
    checks.append(("checkpoints in markdown", "probe blocks completed" in md3
                   and "`cards`" in md3 and "`bank`" in md3))
    checks.append(("crashed-chain warning for run-4 pattern",
                   "stopped before the input block" in md3))

    # red text = error codes (session 10): attribute to the loading mod,
    # L1 to the folder named in the path, ignore engine noise and log() twins
    d9 = parse_text(
        "  . Loading 'glacies collection' mod.\r\n"
        " !! 'mods/glacies collection/collection_gfx' didn't match any files.\r\n"
        "  . Glac Terminal is not loaded correctly!\r\n"
        " !! Glac Terminal is not loaded correctly!\r\n"
        "  . Loading 'retry' mod.\r\n"
        " !! Retry after Death must be loaded above Glac Terminal\r\n"
        " !! Surface 'weapons' already exists, deleting it.\r\n"
        " !! Could not open file 'save/mods/Shootout.bnk': No such file or directory'.\r\n"
        "  . Loading 'the art of war' mod.\r\n"
        " !! Glacies' Collection needs to be loaded above The Art of War!\r\n"
        "  . Loading 'disgraced_justice' mod.\r\n"
        " !! 'mods/the art of war/drum1' didn't match any files.\r\n"
        " !! Glacies' Collection must be turned on!\r\n"
        "Attempt to use forbidden index 'DEN'\r\n"
        "  . SKUI|modcheck|boot|issues=2|codes=E1,E3\r\n"
        "  . SKUI|modmenu|sync=open|back=back|issues=2|codes=E1,E3\r\n"
    )
    codes9 = [(r["code"], r["mod"]) for r in d9["red"]]
    checks.append(("red codes classified + attributed", codes9 == [
        ("L1", "glacies collection"), ("T1", "glacies collection"), ("T3", "retry"),
        ("A1", "the art of war"), ("L1", "the art of war"), ("D1", "disgraced_justice"),
        ("S1", "disgraced_justice")]))
    md9 = render_markdown(d9, "<selftest-red>")
    checks.append(("red table in markdown", "Red text from mods" in md9 and "| **T3** | `retry`" in md9
                   and "7 red line(s)" in md9))
    checks.append(("modcheck/modmenu SKUI lines", len(d9["modcheck"]) == 1 and len(d9["modmenu"]) == 1
                   and "mod-order check" in md9))
    md10 = render_markdown(parse_text("  . Loading 'sk-rework' mod.\r\n !! Surface 'x' already exists, deleting it.\r\n"), "<clean>")
    checks.append(("clean log says no red text", "no mod red text" in md10))
    checks.append(("every RED_CODES code is unique", len({c[0] for c in RED_CODES}) == len(RED_CODES)))

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
            "  collect it first with (works from any folder in PowerShell):\n"
            "    powershell -ExecutionPolicy Bypass -File \"E:\\testing\\repo\\tools\\apply.ps1\" "
            "-GameDir \"E:\\testing\\ShotgunKing-Modded\" -GetLog\n"
            "  (writes E:\\testing\\repo\\uploads\\game-insights\\log.txt)")
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
    here = os.path.dirname(os.path.abspath(__file__))
    repo_root = here if os.path.isdir(os.path.join(here, "modded")) else os.path.dirname(here)
    out = argv[argv.index("--out") + 1] if "--out" in argv else \
        os.path.join(repo_root, "notes", "game-map-draft.md")
    if "--json" in argv:
        jp = argv[argv.index("--json") + 1]
        with open(jp, "w", encoding="utf-8") as f:
            json.dump({k: v for k, v in d.items() if k not in ("tail",)},
                      f, indent=2, default=str)
        print(f"json    -> {jp}")
    if "--print" in argv:
        sys.stdout.write(md)
    else:
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
        with open(out, "w", encoding="utf-8") as f:
            f.write(md)
        print(f"draft   -> {os.path.abspath(out)}")

    g = len(set(d["globals"]))
    print(f"loaded: {'yes' if d['banner'] else 'NO'} · "
          f"hooks: {len(d['hooks'])} · globals: {g} · "
          f"append-events: {sum(d['events'].values())} · "
          f"callback-events: {sum(d['callbacks'].values())} · "
          f"object tables: {len(d['objects'])}"
          + (f" · mods: {len(d['modlist'])}" if d["modlist"] else "")
          + (f" · cards: {len(d['cards'])}" if d["cards"] else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
