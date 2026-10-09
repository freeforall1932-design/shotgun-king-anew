# mod-dev.md — the build/test loop for our mod

> Replaces the old repack pipeline (no .pck, no Godot — PLANNING.md §0.5).
> Our deliverable is a normal SGK mod folder: `modded/sk-rework/`.

## 1. The mod skeleton (created 2026-10-03)

```
modded/sk-rework/
├── info.lua        # name="sk-rework", title="SK Rework", cover.png
├── script.lua      # Build 7: live-test helpers + post-READY API probes
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
2. Mods start **OFF by default** (black text). To enable: click **Play**
   (top entry); click = on/off (white text = ON, black = OFF);
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

## 3. Build 7 testability update, probes & the log parser

`modded/sk-rework/script.lua` is **Build 7** in the current working tree.
Build 6's unknown-button crash fix and runtime probes were confirmed in Run 5:
the game booted and completed the probe checkpoints. Run 5 owner feedback also
confirms that the mod-menu Back button worked; the absent
`SKUI|menu|widgets_added` marker is not evidence that it failed.

Build 7 adds native buttons for `+3 AMMO`, `RELOAD`, experimental `CHAMBER +1`,
`RANDOM CARD`, one adjacent pawn summon, and `TEST SOUL/WAND` (direct grants for
Majestic Censer and Wand of Souls). It also strengthens native-entity cleanup
when the panel closes or a new run starts. **Build 7 has not been live-tested.**
Follow the checklist in `INSTALL.md`; in particular, the chamber uplift, direct
card grants, and close/reopen cleanup remain to be confirmed in the game.

Run 5 did not test mod-toggle → Save & Reboot or use/activate a soul or scepter.
The Build-7 card grants avoid depending on rare random offers; the player still
needs to collect a soul and use the game's normal activation controls. God Mode
is unreliable and marked **DO NOT TEST YET**; the Mist-style escape, damage/crit
controls, ammo rework, pickers, soul-deck overhaul, and remapping are not
implemented. Buttons use the game's native text API; no draw overlay or global
`upd`/`on_*` dispatcher is defined.

> 🛑 **Never call `btn()`/`btnp()`/`btnr()`/`defbtn()` with an unconfirmed
> string.** Build 5 called `btn("left")` at load and the game quit with
> `ERR Button left for player 0 doesn't exist.` — unknown names fall through to
> the input-id parser, a malformed id is fatal, and the mod sandbox has no
> `pcall` to catch it. Only ids the live game published may be used:
> `INPUT_ASSIGNEMENT` actions (`validate`, `cancel`, `shoot`, `special`,
> `reload`, `unsafe`), `unsafe`/`cancel`/`ctrl`, and the bound mouse codes
> `m:lb`, `m:rb`, `m:mb`. Probe blocks are ordered safe-first and each logs an
> `SKA2|probe|<name>=done` checkpoint; the fake engine in `mod_smoketest.py`
> raises on unconfirmed ids so the smoke test reproduces that fatal.

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
| `SKI\|<tag>\|…` | mouse/buttons, confirmed `btn()`/`btncode` probes, menu-button IDs |
| `SKUI\|<tag>\|…` | panel/menu actions and mod-bank persistence state |
| `SKA2\|probe\|<block>=done` | probe-block checkpoint (cards/exclude/souls/bank/input) |
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
