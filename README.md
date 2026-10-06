# 🔫👑 Shotgun King: Reworked

> **👉 Installing or testing for the first time? Follow [`INSTALL.md`](INSTALL.md).**
> It is the one canonical, click-by-click path (folder layout, exact commands,
> what to report back). This README explains *what the project is* and *why*.

A private, personal-use **mod project** for *Shotgun King: The Final
Checkmate* v1.623b (PUNKCAKE Délicieux). Two separate things live here:

1. **A ready-to-play modded copy of the game** — 13 workshop mods plus our own
   mod, assembled for you by a script.
2. **Our own mod** (`sk-rework`) — Build 8 has an overlay dev panel (an
   `SK DEV` tab bottom-left that opens a modal box over the board: ammo/
   reload/clip, card picker pages, spawn picker, damage/crit knobs, God-Mode
   dodge, SAFE mode), an in-menu legend/Back affordance, and probes for the
   remaining gameplay APIs. Build 8 is the first build written against the
   decoded game source (`game/decoded/`, `notes/game-internals.md`).
   The advanced ammo rework, pickers, crit tuning, soul deck, and remapping
   remain planned follow-up work.

Engine: **SUGAR** (the studio's custom Lua engine) · Mod system: the game's
official `info.lua` folder format.

---

## ❓ Does this touch my real game install?

**Short answer: the play path builds a copy. Nothing here patches, repacks or
replaces `shotgun_king.exe` or `data.sgr` — ever.**

"Injecting mods" in this repo means no more than *adding folders under
`mods/`*, which is the game's own supported mod mechanism. Here is every tool,
what it writes, and how to undo it:

| Tool | Where it writes | Undo |
|---|---|---|
| `tools/build-dist.ps1` | **A copy**: `<OutDir>\ShotgunKing-Modded\` (default `dist\`, `INSTALL.md` uses `E:\testing\`) | delete that folder — your install was never touched |
| `tools/apply.ps1` | Your real install: adds **one folder**, `<game>\mods\sk-rework\` | delete that one folder |
| `tools/install-mods.ps1` | Your real install: adds mod folders under `<game>\mods\` | delete those folders |
| `tools/make_100pct_save.py` | `save\*.sav` **in the game folder you point it at** (auto-backup first) | `--restore` (or the `save_backup_*` folder it creates) |

So, concretely:

- **"I just want to play"** → `build-dist.ps1` copies the game to a new folder
  (`E:\testing\ShotgunKing-Modded` in `INSTALL.md`) and puts the mods inside
  that copy. Play the copy. Your install stays clean.
- **"I'm developing the mod"** → `apply.ps1` copies only our mod folder into
  your real install's `mods\` so you can iterate in place.
- The save tool is the only thing that *edits* something — and only the save
  files, only in the folder you name, with a backup and a one-command undo.

---

## 📊 What is actually ready today

Honest status, because "it's written" is not the same as "it's been run":

| Thing | Status | Meaning |
|---|---|---|
| 13 workshop mods vendored in `dist-overlay/mods/` | ✅ live-proven | all 13 loaded and ran in the owner's live test (2026-10-03) |
| `sk-rework` Build 8 (overlay dev panel + damage/crit + pickers + diagnostics) | 🟡 sandbox-tested (smoke 59/59 ×4, mod sandbox modelled); live run pending | build 7 ran live (run 6): bank read-back + menu widgets proven, but the panel's click also moved the king and the panel vanished on a new run. Both are root-caused in the decoded game source and fixed in build 8 |
| `tools/parse_log.py` log parser | ✅ live-proven + Build-7 extensions tested | parses runs 1–5 with multi-boot dedup, crashed logs, `SKA2\|probe\|<block>=done` checkpoints, and the new `SKE\|call` trace — a crashed run names the engine call that started and never finished; selftest 44/44 |
| `tools/mod_smoketest.py` | ✅ tested | runs Build 8 without the game (needs `lupa`); 59/59 checks under each `all()` semantics on default Lua + LuaJIT 2.1. The mod runs inside a copy of the engine's real sandbox (writes reach the engine only for replaceable keys); the fake engine re-raises the fatal `btn()` error, chains appends, and models `gamepad_ctrl`'s mouse read, `remove_buts`, `reset()` and board clicks |
| `tools/build-dist.ps1` | ✅ live-proven | ran on the owner's machine (runs 1–3, incl. `-NoInheritMods`); pre-enables `sk-rework` via `mods\modlist.lua` (run-3-verified: booted ON with no toggling) and auto-applies the 100% unlock (step 4/4) |
| `tools/save_codec.py` | ✅ verified | real-save text roundtrip was previously checked on all 6 saves; `--selftest` now also runs 2 built-in parse/container checks without needing a save directory |
| `tools/make_100pct_save.py` | ✅ game-accepted | live test: achievements 100% (still 100% after a full modded session), weapons/ranks/chase unlocked; now writes the live-verified full card set (186 cards + 9 special keys = 195) |
| Dev-cheat panel | 🟡 Build 8 sandbox-tested (59/59); owner run pending | run 6: Build 7's panel click also hit the board square under it and `remove_buts()` broke the turn. Build 8 owns no engine buttons, consumes its clicks in a `gamepad_ctrl` hook, and re-creates itself on every new run |
| Damage/crit system, reload/clip, card picker pages, God-Mode dodge | 🟡 sandbox-tested; owner run pending (run 6 never got past CLIP+) | the run-5 log pinned the live route (`mk_bullet` → `bullet.dmg` → `hit` → `fx_dmg`; `ev_hit` never fires), so these ship as real controls instead of gated placeholders |
| Right-click ability cap removal, soul deck, button-remap menu | 🟢 scoped; queued | still need live data: the offer-cap enforcement point, soul-slot internals (`add_soul`/`add_soul_slot` ran in run 5), and the isolated mouse4/mouse5 experiment |

**The three pre-live unknowns — all resolved on 2026-10-03:**

1. PowerShell scripts: executed successfully on the owner's machine
   (build-dist, apply -GetLog, both parse runs).
2. 100% save acceptance: **accepted** — achievements/codex/unlocks showed up
   in game; the only gap (6 special cards) is fixed.
3. Mods enabled by default: **no — mods start OFF** (run 2 verified: the mod
   menu shows black text = OFF until clicked, and the game's own
   `mods/modlist.lua` stores `false` for untouched mods). Solved instead:
   `build-dist.ps1` now **writes `mods/modlist.lua` itself**, so a built copy
   boots with `sk-rework` already ON (`-AllModsOn` for everything on).

---

## 🚦 Setup & live testing

**Follow [`INSTALL.md`](INSTALL.md)** — one canonical path, no choices to make.
In 20 seconds, it goes:

| Step | What happens | Writes |
|---|---|---|
| 1 | copy the base game to `E:\testing\game` | your copy only |
| 2 | put this repo at `E:\testing\repo` | — |
| 3 | dry run (`apply.ps1 -List`) | nothing |
| 4 | `build-dist.ps1` → `E:\testing\ShotgunKing-Modded` | the copy only |
| 5 | launch the copy, play a couple of turns, note the mod menu, quit | game's own files |
| 6 | `apply.ps1 -GetLog` → send me `log.txt` ← **the blocker** | a text file in the repo |
| 7 | automatic: the build's 4/4 step unlock-alls the copy (manual only if skipped) | copy's `save\` (backed up) |

Step 6 collects the live validation for Build 8: the mod writes its load/hook
proof plus the game API, state, object, card-field, offer, soul/scepter,
damage/roll, input, UI and engine-call probes into `log.txt` (`SKG|`, `SKCF|`,
`SKOF|`, `SKS|`, `SKD|`, `SKI|`, `SKUI|`, `SKE|call|`…). `tools/parse_log.py` turns that into
`notes/game-map-draft.md`; the new live data will validate the panel and unblock
the queued ammo rework and pickers.

### What to download

The **whole repository** (~8.5 MB, no game files inside) — there is no
single-file patch, and nothing here patches or modifies the game's `.exe` or
`data.sgr`. Mods are folders; the tools need each other; the 13 workshop mods
ship as folders too.

---

## 🎮 Playing & mods

- Mods start **OFF by default** (live-verified run 2) — but `build-dist.ps1`
  writes `mods/modlist.lua` so a built copy boots with `sk-rework` already ON
  (`-AllModsOn` flips everything on). To open the in-game **mod menu**,
  click **Play** (top entry). In it, **black text = OFF, white text = ON**;
  clicking flips a mod and the change survives
  restarts; the up/down arrows only change load priority (which mod overrides
  which). While a mod is active the title bar shows
  `MODDED: ON - ACHIEVEMENTS: OFF` — that pauses *Steam* achievement tracking
  only; the achievements written into the copy's save stay unlocked
  (live-verified run 2).
- A mod folder **must be unpacked** and its folder name must **equal the
  `name=` field** in its `info.lua`. A `.zip`/`.rar` in `mods\` is silently
  ignored. (`install-mods.ps1` fixes both cases for downloaded mods.)
- Deleting a mod's folder uninstalls it. Deleting `mods\` entirely returns
  that game folder to vanilla.

```powershell
# a downloaded mod that won't load (zips live in one folder; works from any folder in PowerShell):
powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\install-mods.ps1" -GameDir "E:\testing\game" -ZipsDir "C:\Users\you\Downloads"
```

---

## 💾 Save tools

Saves (`save/*.sav`) are `[4-byte length][zlib][PUNKCAKE text]` — fully
readable and writable. Files: `prog.sav` (weapons, ranks, badges, endless
floor) · `achievements.sav` · `stats.sav` (per-card history) · `reg.sav`,
`misc.sav`, `runs.sav`.

```powershell
# Full paths below work from ANY folder in PowerShell (adjust E:\testing if needed):
python "E:\testing\repo\tools\save_codec.py" "E:\testing\ShotgunKing-Modded\save\prog.sav"                 # decode any save to text
python "E:\testing\repo\tools\save_codec.py" "E:\testing\ShotgunKing-Modded\save" --scan                   # check a whole save folder
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded"              # unlock-all (backup first)
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --dry-run    # show, don't write
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --restore    # undo
```

The unlock-all sets: every achievement · shotguns 2–9 · throne rank 20 +
rank-20 badge per shotgun · endless floor 15 (unlocks Chase) · all 170 cards
marked played (164 regular + 6 special — codex 100%). It never touches best
times or run history, and the game must be closed while it runs.

---

## 🧰 Repository layout

```
├── INSTALL.md             👉 setup + live testing, start to finish
├── modded/sk-rework/      🔧 our mod — the deliverable
├── dist-overlay/mods/     🧩 the 13 workshop mods, vendored, name-verified
├── tools/                 · build-dist.ps1   build the modded copy
│                          · apply.ps1        deploy our mod (+ -List, -GetLog)
│                          · install-mods.ps1 fix & install workshop zips
│                          · save_codec.py    .sav reader/writer
│                          · make_100pct_save.py  unlock-all generator
│                          · parse_log.py     log -> draft game map
│                          · mod_smoketest.py run our mod without the game
│                          · mod-dev.md       dev loop + log-line reference
├── notes/                 map.md (game internals), mods.md (inventory + API),
│                          review-2026-10-03.md (readiness review), changelog.md
├── PLANNING.md            full plan & decision log (dev-facing)
├── HANDOFF.md             session state — resume here
├── WORKLIST.md            pending tasks + live-test tracker
└── uploads/               ⚠ NOT in a fresh clone (gitignored): game archives,
                           extracted mods, modding guide, collected logs
```

---

## 🩺 Troubleshooting

| Symptom | Fix |
|---|---|
| Mod doesn't show up in the mod menu | folder name ≠ `name=` in `info.lua`, or still zipped — run `install-mods.ps1` |
| Game crashes after the intro logos | Lua error — open `log.txt` next to the exe, the error is at the **end** |
| Everything feels vanilla | mods toggled off — mod menu: click **Play**, top entry; white text = ON, black = OFF |
| 100% save didn't apply | game was running while writing, or you pointed at the wrong folder (the copy has its own `save\`) — close it, re-run |
| `pwsh` not found | use `powershell` instead |

---

## 🗺️ Where the project is going (short)

**Live testing (yours, next):** rebuild, click each SK DEV control once in
play (`CLIP+` first: the king must not move), turn all mods ON once in the
mod menu, then collect `log.txt` with `-GetInsights` as in `INSTALL.md`
(the test list starts at Step 4). Run 6 (build 7) already proved the bank
read-back and the menu widgets.

**Development (current):** Build 8 is the first build written against the
decoded game source. The dev panel is rebuilt as a click-consuming overlay,
the seven workshop mods that loaded nothing on v1.623b are patched (asset
loader argument order), and the build writes the mods in dependency order
with Glac Terminal last. The Build 7 feature set (damage/crit, reload/clip,
card + spawn pickers, God-Mode dodge, SAFE, intent logging) is unchanged.
Smoke test 59/59 across both `all()` semantics on default Lua and LuaJIT
2.1. That is not a replacement for the game run. The right-click ability cap
removal, the soul deck and the full button-remap menu remain queued behind the
next live data (offer-cap enforcement point, soul-slot internals, and the
isolated mouse-button experiment).

Full plan and phase checkboxes: [`PLANNING.md`](PLANNING.md) ·
current tasks: [`WORKLIST.md`](WORKLIST.md) · what changed when:
[`notes/changelog.md`](notes/changelog.md).

---

## ⚖️ Legal & credits

- *Shotgun King: The Final Checkmate* is by **PUNKCAKE Délicieux**. This is a
  private, personal-use mod project — no game assets are redistributed in the
  tracked repository, and nothing here is for public release.
- Vendored workshop mods in `dist-overlay/mods/` belong to their authors
  (Glacies, sub122, Lorina Sonetto & Bob Qwerty, Willhart, …), mirrored only
  to assemble the owner's personal build. Removed on author request.
- Modding guide & SUGAR manual: `TRASEVOL-DOG/Shotgun-King-Modding-Guide`.
