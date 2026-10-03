# INSTALL.md — setup & live testing, start to finish

> This is the **only** file you need to follow for installing and testing.
> It is written for your exact setup: everything lives under `E:\testing\`.
> If your path differs, replace `E:\testing` everywhere — nothing else changes.
> Concepts and background: [`README.md`](README.md). Review of what is proven
> vs unproven: [`notes/review-2026-10-03.md`](notes/review-2026-10-03.md).

---

## 0. First: what do I download? (the whole repo, not one file)

**Download the entire repository.** There is **no "one patch file"** in this
project, and nothing here ever patches, injects into, or modifies your game's
`.exe` or `data.sgr`.

Why the whole repo: mods are *folders* (with an `info.lua` inside), the tools
call each other, and the 13 workshop mods are stored as folders too. The whole
download is ~8.5 MB (mostly mod artwork) — it does **not** contain the game.

Two ways to get it (either is fine):

- **Download ZIP** (easiest): open the repo page on GitHub → green **Code**
  button → **Download ZIP** → right-click the zip → *Extract All* → you get a
  folder like `shotgun-king-anew-main` (contents: `tools\`, `modded\`,
  `dist-overlay\`, `README.md`, `INSTALL.md` …).
- **git clone**: `git clone <repo-url> E:\testing\repo`

---

## 1. The layout we are going to build

```
E:\testing\
├── game\                    ← YOUR copy of the base game (never modified)
├── repo\                    ← the repository you just downloaded
└── ShotgunKing-Modded\      ← created in Step 4; this is the copy YOU PLAY
```

Three separate folders, three separate roles — this is the whole mental model:

| Folder | What it is | Who writes to it |
|---|---|---|
| `E:\testing\game` | your untouched copy of the game | you, once (Step 1) |
| `E:\testing\repo` | tools + mods + docs | you, once (Step 2) |
| `E:\testing\ShotgunKing-Modded` | the playable build (game + mods) | the build script (Step 4) |

Your **real install** (the Steam/repack folder you copied from) is never
written to by any step below. Deleting any of these three folders undoes its
part — nothing else on the PC is affected.

---

## 2. Before you start (2 minutes)

| Need | How to check |
|---|---|
| Windows + PowerShell | built into Windows — no install |
| Your game installed | you can open its folder and see the game `.exe` and `data.sgr` together |
| Python 3 (optional, only for Step 7) | in PowerShell: `python --version` — if it opens the Microsoft Store or errors, install it from python.org and **tick "Add python.exe to PATH"** |

Open PowerShell: press `Win`, type `PowerShell`, press `Enter`. Paste commands
with `Ctrl+V`, run them with `Enter`, one line at a time.

> Every command below is written as
> `powershell -ExecutionPolicy Bypass -File …` — this avoids the
> "running scripts is disabled on this system" error. If you have PowerShell 7
> (`pwsh`), `pwsh` works identically.

---

## 3. Steps (do them in order)

### Step 1 — create the testing area and copy your base game

In File Explorer:

1. Make the folder `E:\testing`.
2. Make the folder `E:\testing\game`.
3. Open your game's install folder, select **everything** inside it
   (`Ctrl+A`), copy (`Ctrl+C`), then paste into `E:\testing\game` (`Ctrl+V`).

Or in PowerShell (adjust the first path to your real install):

```powershell
mkdir E:\testing
Copy-Item "C:\Program Files (x86)\Steam\steamapps\common\Shotgun King\*" E:\testing\game -Recurse
```

**Check:** `E:\testing\game\` contains the game `.exe` and `data.sgr`.

### Step 2 — put the repository at `E:\testing\repo`

- If you downloaded the ZIP: `E:\testing\repo` should contain the *contents*
  of the extracted folder (`tools\`, `modded\`, … directly inside `repo`,
  not another nested `shotgun-king-anew-main` folder).
- If you cloned: `git clone <repo-url> E:\testing\repo`

**Check:** `E:\testing\repo\INSTALL.md` (this file) exists.

### Step 3 — dry run: see what will be copied, write nothing

```powershell
cd E:\testing\repo
powershell -ExecutionPolicy Bypass -File tools\apply.ps1 -GameDir "E:\testing\game" -List
```

**Check:** it prints a list of files it *would* copy. Nothing on disk changes.

### Step 4 — build the modded copy (your install stays untouched)

```powershell
powershell -ExecutionPolicy Bypass -File tools\build-dist.ps1 -GameDir "E:\testing\game" -OutDir "E:\testing" -Clean
```

It copies the game (~100 MB, give it a minute), then adds the 13 workshop mods
plus our `sk-rework` mod inside the copy. At the end it prints the exact path
of the playable `.exe`.

**Check:**
- `E:\testing\ShotgunKing-Modded\mods\` contains at least the **14 expected
  folders** (13 workshop mods + `sk-rework`)
- `E:\testing\ShotgunKing-Modded\PLAY-THIS.txt` exists
- `E:\testing\game` still looks exactly as you copied it (the script only
  reads from it — nothing is written there)

**Note:** if your base game has its own `mods\` folder (older/extra mods), the
copy inherits it. For a guaranteed-clean build with *exactly* the 14 known-good
mods, add `-NoInheritMods` to the Step 4 command. Either is fine; inherited
extras can simply be toggled off in the mod menu afterwards.

> Windows may warn that the copied `.exe` is from an unknown publisher —
> it's the same file you already own, just copied to a new folder.

### Step 5 — launch the copy and play a minute (5 minutes of live testing)

1. Double-click the game `.exe` inside `E:\testing\ShotgunKing-Modded`
   (the script prints its exact path when Step 4 finishes).
2. From the main menu, open the **mod menu**.
3. **Look and note:** are all 14 mods listed? Are they ON or OFF?
   (This answers an open question the project can't answer without you.)
4. **Start a run and play a couple of turns** — this is what makes the log
   useful. The `sk-rework` mod is a diagnostics build: it watches the game
   and writes what it sees to `log.txt` (it changes nothing in the game).
   Even 30 seconds of play is enough.
5. Quit the game normally.

The `sk-rework` mod reports on itself — you don't need to read the log, but if
you're curious, these lines mean it worked:

| Line in `log.txt` | Meaning |
|---|---|
| `SK-REWORK: BUILD=3 loaded (mod_index=…)` | the mod loaded |
| `SKA\|append\|YES` (a list of these) | the game API it plans to use exists |
| `SKH\|new_turn\|…` (5 of these) | its hooks registered |
| `SKE\|heartbeat\|frames=900` | it is alive and watching during play |
| `SK-REWORK: READY build=3 hooks=5` | everything above succeeded |

If the game crashes after the intro logos, don't worry — the reason is at the
**end** of `E:\testing\ShotgunKing-Modded\log.txt`. Continue to Step 6.

### Step 6 — send the log (this is the one thing blocking all development)

```powershell
powershell -ExecutionPolicy Bypass -File tools\apply.ps1 -GameDir "E:\testing\ShotgunKing-Modded" -GetLog
```

This copies the game log to `E:\testing\repo\uploads\game-insights\log.txt`.
**Attach that file in chat** (or upload it to the repo the same way the game
archives were uploaded before). That file contains the diagnostics mod's dump
of the game — the raw material every feature needs.

**Check:** the file exists and contains lines starting with `SK-REWORK:`,
`SKG|`, `SKA|`, `SKH|`, `SKE|`.

You can preview what the project will extract from it (optional, needs
Python):

```powershell
python tools\parse_log.py uploads\game-insights\log.txt
```

That writes `notes\game-map-draft.md`: the mod-load verdict, the API list, the
live object model, and candidate functions for the ammo/damage/spawn/card
systems. If it says "this log contains no SK-REWORK lines", the mod didn't
run — the tool then shows the end of the log where the reason is.

### Step 7 (optional) — unlock everything, in the copy only

Only do this **after Step 5** (the game must have created its save folder) and
with the game **closed**:

```powershell
python tools\make_100pct_save.py --game-dir "E:\testing\ShotgunKing-Modded"
```

It backs up the copy's saves into a `save_backup_<timestamp>` folder first.
Undo at any time with the same command plus `--restore`.
Prefer to see what it would do without writing? Add `--dry-run`.

---

## 4. Success checklist (what to report back)

| # | Check | Pass looks like |
|---|---|---|
| 1 | Step 3 dry run | a list of files, nothing else happened |
| 2 | Step 4 build | `ShotgunKing-Modded\mods\` has the 14 expected folders; `game\` unchanged |
| 3 | Step 5 launch | game reaches the main menu |
| 4 | Step 5 mod menu | 14 mods visible; note ON/OFF state |
| 5 | Step 6 log | `log.txt` collected and attached, containing `SK-REWORK: READY` |
| 6 | Step 7 (optional) | achievements/shotguns/codex unlocked in the copy |

Report anything that failed **at which step**, plus the end of `log.txt` if
the game crashed.

---

## 5. Where live testing ends and the roadmap begins

**Your part = Steps 1–7 above. That is all that is expected of you right now.**
Nothing on the roadmap below requires you to run, install, or configure
anything until a feature is ready — each one will arrive with its own test
steps in this file.

**My part (development), after your log arrives:**

| Phase | What | Status |
|---|---|---|
| 0–2a | engine identified, tooling + save tools built | ✅ done |
| 2b | read your `log.txt` → complete the game's function map (`notes/map.md`) | ⛔ blocked on Step 6 |
| 2c | in-game dev/cheat panel (give ammo/cards, god mode, spawns) | ⛔ after 2b |
| 3 | ammo rework, staged A → B → C | ⛔ after 2b |
| 4 | card picker + enemy picker | ⛔ after 2b |
| 5 | extra shot mechanics (knockback/pierce/bleed — vanilla internals) | ⛔ after 2b |
| 6 | balance knobs + final packaging | ⛔ after 2b |

Work that is **not** blocked (mine, no action needed from you): better cover
art, polish on the tools, and pre-building the panel/picker code against the
candidate names the parser finds. The `log.txt` parser
(`tools/parse_log.py`) and the `-NoInheritMods` build option are already done.

**One question your run settles:** whether plain mods get `on_*` callbacks
directly, or only through the "Glacies Module Terminal" mod. The diagnostics
build probes both and the log's verdict line tells us which — it decides how
the cheat panel and pickers will be wired.

Scaffolding already in place: the mod skeleton (`modded/sk-rework/`), the
build/install/save tools, the 13 vendored mods, the save codec, the log parser
(`tools/parse_log.py`) and the no-game smoke test (`tools/mod_smoketest.py`),
plus the docs in `notes/`. No extra folders need to be created by you — a
Shotgun King mod is just files, so there is nothing to "set up" beyond the
steps above.

---

## 6. Undo / cleanup

| To undo | Do this |
|---|---|
| the modded copy | delete `E:\testing\ShotgunKing-Modded` |
| the whole testing area | delete `E:\testing` |
| the 100% save | `python tools\make_100pct_save.py --game-dir "E:\testing\ShotgunKing-Modded" --restore` |
| mods in your *real* install (only if you ever use the variations below) | delete `<game>\mods\<mod name>` |

Nothing in this guide writes outside `E:\testing` (plus the backup folder
inside the copy when you run Step 7).

---

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| `running scripts is disabled on this system` | use the exact `powershell -ExecutionPolicy Bypass -File …` command shown; don't double-click `.ps1` files |
| `robocopy` fails partway ("file in use") | close the game (and any Explorer window showing the copy), then re-run the same Step 4 command |
| `pwsh` not found | use `powershell` instead — every command above already does |
| `python` opens the Microsoft Store / not recognized | install Python from python.org with "Add python.exe to PATH" ticked, or use `py` instead of `python` |
| build script says `No data.sgr in …` | you pointed `-GameDir` at the wrong folder — it must be the one with the game `.exe` **and** `data.sgr` |
| mods don't appear in the mod menu | they are toggled off (check the mod menu), or the folder names were changed (the vendored set is pre-verified) |
| game crashes after the intro logos | Lua error — the reason is at the **end** of the copy's `log.txt`; send it |
| the 100% save "did nothing" | the game must be closed, and you must point at the folder you actually play (`ShotgunKing-Modded`, not `game`) |

---

## 8. Variations (only if you want them — ignore otherwise)

- **Different paths** — keep the same three-folder structure on any drive;
  replace `E:\testing` in the commands. **Do not** build into the repo folder
  or into the `game` folder itself.
- **Unlocks only, no mods** — skip Step 4; launch your normal game once, then
  run Step 7 pointed at `E:\testing\game`. The save tool works on a vanilla
  install.
- **Install the mods into your real install too** — `tools\install-mods.ps1
  -GameDir "<real game folder>" -ZipsDir "<folder with mod zips>"`. It still
  only adds folders under `mods\`; delete them to undo.
- **Develop the mod** (the dev loop, not needed for testing) — deploy our mod
  alone into a game folder with `tools\apply.ps1`, then read
  `tools/mod-dev.md` for the edit → play → read-log cycle.
