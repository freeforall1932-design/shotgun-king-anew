# mod-dev.md — the build/test loop for our mod

> Replaces the old repack pipeline (no .pck, no Godot — PLANNING.md §0.5).
> Our deliverable is a normal SGK mod folder: `modded/sk-rework/`.

## 1. The mod skeleton (created 2026-10-03)

```
modded/sk-rework/
├── info.lua        # name="sk-rework", title="SK Rework", cover.png
├── script.lua      # Build 5: native Dev panel + post-READY API probes
├── modes/…         # (later) custom modes for the pickers, if needed
├── lang/…          # (later) strings
└── cover.png       # 16:9 png, required for workshop upload
```

`name=` must match the folder name (`sk-rework`). Copy patterns from
`uploads/modding-guide/sample_mod/` and the 13 mods (`notes/mods.md`).

## 2. Deploy + test loop

```bash
# from repo root (Windows pwsh):
pwsh tools/apply.ps1 -GameDir "D:\...\Steamapps\common\Shotgun King"
```

That copies `modded/sk-rework/` → `<game>/mods/sk-rework/` (idempotent).
Then:

1. Launch the game (Steam).
2. Mods start **OFF by default** (black text). To enable: mod menu = **Play
   screen, top entry**; click = on/off (white text = ON, black = OFF);
   up/down = load priority only. (A `build-dist.ps1` copy skips this — it
   pre-enables sk-rework via `mods/modlist.lua`.)
3. Play / trigger the feature.
4. On crash or weirdness: read `<game folder>/log.txt` and the crashlog
   (SUGAR writes crashlogs; the error is at the END of the log).

In-mod debugging:

```lua
_log("hello")                        -- writes to log.txt
for a,b in all(gimme("global")) do _log("G|"..(b or a)) end   -- global names
append("new_turn", function(...) _log("turn!") end, "dbg")    -- trace calls
```

> `all(t)` yields **values** (shipped mods do `for f in all(t) do f() end`).
> Our mod reads it defensively (`for a,b in all(t)`, prefer `b`) so it works
> under either semantics.

## 3. Build 5 dev panel, probes & the log parser

`modded/sk-rework/script.lua` is **Build 5**. Builds 3–4 are live-proven;
Build 5 is sandbox-tested but still needs one owner game run. It retains the
load proof and base `append()` hooks, adds native `mk_text_but` cheat controls,
and harvests the §0.7 unknowns after its `READY` line. It does not yet ship the
later gameplay modules (ammo rework A/B, crit tuning, ability rebinding, soul
deck, or free-choice picker); those remain queued behind the live probes.

Build 5 controls: `+3 AMMO`, random eligible card, spawn an ally using a live
`PIECES` entry/free adjacent square, God Mode toggle (best-effort through the
confirmed `hit(p,dmg,tags)` helper + HP refill), and a clearly gated damage
control placeholder until the hit pipeline is live-confirmed. Buttons use the
game's native text-button API; no custom draw overlay or global `upd`/`on_*`
dispatcher is defined. God Mode and menu behavior still need game validation.

| Prefix | Meaning |
|---|---|
| `SK-REWORK: BUILD=… loaded`, `SK-REWORK: READY …` | load + registration proof |
| `SKA\|<name>\|YES/no` | which globals we plan to use actually exist |
| `SKG\|` `SKR\|` `SKF\|` | global / replaceable / forbidden names |
| `SKH\|<target>\|<id>` | an append/prepend hook was registered |
| `SKE\|<event>\|…` | event seen through an `append()` hook |
| `SKO\|<obj>\|key=value` | real field names of a game object |
| `SKW\|turn=…` | per-turn world state line |
| `SKM\|<i>\|k=v` | MODLIST entry dump (mod menu state) |
| `SKC\|<id>\|…` | full CARDS id map (card.id = display name) |
| `SKCF\|<id>\|…` | full card-field dump + `EXCLUDE` pairs |
| `SKOF\|<kind>\|…` | offer inputs, `level_up` choices, eligibility calls |
| `SKS\|<tag>\|…` | `PIECES`, `TEST_SOULS`, scepters, soul/scepter calls |
| `SKD\|<tag>\|…` | bullet fields and candidate damage function arguments |
| `SKI\|<tag>\|…` | mouse/buttons, `btn()` candidates, menu-button IDs |
| `SKUI\|<tag>\|…` | panel/menu actions and mod-bank persistence state |
| `SKA2\|loadfile=no` | confirms the old file probe cannot run in the mod sandbox |

Note: the game wraps every log line in `  . ` / ` !! ` — the parser strips
that; grep accordingly.

Volume is capped (first 30 hits of an event, then every 25th).

Parsing a log into a draft map:

```bash
python tools/parse_log.py uploads/game-insights/log.txt   # -> notes/game-map-draft.md
python tools/parse_log.py <log> --print                   # markdown to stdout
python tools/parse_log.py --selftest                      # parser checks
```

Sandbox-testing the mod **without the game** (fake SUGAR environment):

```bash
pip install lupa           # dev-only
python tools/mod_smoketest.py      # loads script.lua, fires hooks, checks output
python tools/mod_smoketest.py --dump
```

The smoke test runs the mod under **both** possible `all()` semantics and,
when bundled by `lupa`, the real LuaJIT 2.1 backend; it then feeds the captured
lines through the parser so mod format and parser can't drift apart unnoticed.

## 4. Dev etiquette (survives game updates)

- Only use documented mod APIs (`SUGAR_manual.txt`, guide README) and
  patterns proven by the workshop mods.
- `append`/`prepend` always with a stable id string; unregister cleanly.
- Every hook we add gets a `-- SK-REWORK:` comment in `script.lua`.
- Log discoveries into `notes/map.md` as you find them.

## 5. Sharing (optional, later)

In-game mod menu → type **UPLOAD** on the keyboard → button next to our mod
uploads it to Steam Workshop (needs the cover.png, 16:9). See guide README
"Uploading to the Steam Workshop".
