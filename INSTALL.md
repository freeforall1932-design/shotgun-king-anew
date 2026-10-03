# INSTALL.md — setup & live testing, start to finish

> This is the **only** file you need to follow for installing and testing.
> It is written for your exact folder layout under `E:\testing\`:
> - **Steps 1 & 2 are manual (File Explorer)** — no broken `mkdir` or Steam
>   `Copy-Item` commands.
> - **Steps 3–7 are copy-and-paste PowerShell commands** that point directly to
>   **`E:\testing\repo\tools`** (where `apply.ps1`, `build-dist.ps1`,
>   `parse_log.py`, and `make_100pct_save.py` actually live).
>
> Concepts and background: [`README.md`](README.md). Readiness review:
> [`notes/review-2026-10-03.md`](notes/review-2026-10-03.md).

---

## 0. First: what do I download? (the whole repo, not one file)

**Download the entire repository** (Code → **Download ZIP**, or `git clone`).
There is **no "one patch file"** in this project, and nothing here ever
patches, injects into, or modifies your game's `.exe` or `data.sgr`.

Why the whole repo:
- Mods are *folders* (with an `info.lua` inside),
- All scripts (`apply.ps1`, `build-dist.ps1`, `install-mods.ps1`, `parse_log.py`,
  `make_100pct_save.py`) sit inside **`E:\testing\repo\tools\`** and read
  `E:\testing\repo\modded\sk-rework\` and `E:\testing\repo\dist-overlay\mods\`.

---

## 1. Your exact folder layout under `E:\testing\`

```
E:\testing\
├── game\                          ← 1:1 your base game folder (manual, Step 1)
│   ├── shotgun_king.exe           ← (or your repack's .exe name)
│   ├── data.sgr
│   └── mod\ or mods\              ← (optional) any compressed or unpacked mods you already put here
│
├── repo\                          ← 1:1 root of the main branch (manual, Step 2)
│   ├── INSTALL.md
│   ├── README.md
│   ├── modded\
│   │   └── sk-rework\             ← our mod folder
│   ├── dist-overlay\
│   │   └── mods\                  ← the 13 workshop mod folders (pre-unpacked & name-verified)
│   └── tools\                     ← ⚠️ ALL SCRIPTS ARE IN HERE (E:\testing\repo\tools)
│       ├── apply.ps1
│       ├── build-dist.ps1
│       ├── install-mods.ps1
│       ├── parse_log.py
│       └── make_100pct_save.py
│
└── ShotgunKing-Modded\            ← created automatically in Step 4; this is the copy YOU PLAY
```

| Folder | What it is | Who writes to it |
|---|---|---|
| `E:\testing\game` | your untouched copy of the game (1:1 with the `.exe` + `data.sgr`) | you, manually in File Explorer (Step 1) |
| `E:\testing\repo` | 1:1 root of the `main` branch (`tools\` is inside here) | you, manually in File Explorer (Step 2) |
| `E:\testing\ShotgunKing-Modded` | the playable modded build | `build-dist.ps1` (Step 4) |

---

## 2. Before you start

| Need | How to check |
|---|---|
| Windows + PowerShell | built into Windows — no install |
| `E:\testing\game` and `E:\testing\repo` placed manually | see Steps 1 & 2 below |
| Python 3 (optional, only for Step 6 preview & Step 7 save unlock) | in PowerShell: `python --version` — if it opens the Microsoft Store or errors, install from python.org and **tick "Add python.exe to PATH"** |

---

## 3. Steps (do them in order)

### Step 1 (Manual in File Explorer) — put your game files in `E:\testing\game`

1. In File Explorer, create `E:\testing\game` (if you haven't already).
2. Put your game files inside `E:\testing\game` so it is **1:1 with the folder
   where the game `.exe` and `data.sgr` sit** (just like in PR #1).

> **Already put your mods inside `E:\testing\game\mod` or `E:\testing\game\mods`
> (either as `.zip`/`.rar` archives or already unpacked into their own folder
> names)?**
> Leave them right where they are — you do **not** need to delete or rename
> them. In Step 4, `build-dist.ps1` automatically:
> 1. Recognizes both `mod\` (singular) and `mods\` (plural) and merges into `mods\` in the copy,
> 2. Unpacks any `.zip` archives found there and names the folder after `name=` in `info.lua`,
> 3. Checks any already-unpacked mod folders (even if named after the zip or double-nested) and renames them to match `name=` in `info.lua` so nothing duplicates or fails to load,
> 4. Removes `.rar`/`.zip` archives and legacy non-`info.lua` folders from the copy's `mods\`,
> 5. Overlays the 13 verified workshop mods + `sk-rework`.
> *(Your original `E:\testing\game` folder is never modified.)*

**Check in File Explorer:** `E:\testing\game\` directly contains the game `.exe`
and `data.sgr`.

---

### Step 2 (Manual in File Explorer) — put the repo in `E:\testing\repo`

1. In File Explorer, create `E:\testing\repo` (if you haven't already).
2. Extract the downloaded repository so `E:\testing\repo` is **1:1 the root of
   the `main` branch** — meaning `tools\`, `modded\`, `dist-overlay\`,
   `INSTALL.md`, and `README.md` sit directly inside `E:\testing\repo\` (not
   inside an extra `shotgun-king-anew-main\` subfolder).

**Check in File Explorer:** `E:\testing\repo\tools\apply.ps1` exists.

---

### Step 3 (PowerShell) — dry run from `E:\testing\repo\tools` (writes nothing)

Open PowerShell (`Win` → type `PowerShell` → `Enter`) and copy-paste:

```powershell
cd E:\testing\repo\tools
powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\game" -List
```

**Check:** it prints `[dry-run] would copy ...` and lists `cover.png`,
`info.lua`, `script.lua`. Nothing on disk changes.

---

### Step 4 (PowerShell) — build the modded copy (`E:\testing\ShotgunKing-Modded`)

Copy-paste into PowerShell:

```powershell
cd E:\testing\repo\tools
powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\build-dist.ps1" -GameDir "E:\testing\game" -OutDir "E:\testing" -Clean
```

*(What this does: copies `E:\testing\game` to `E:\testing\ShotgunKing-Modded`,
normalizes any compressed or unpacked mods that were in `game\mod` or
`game\mods`, and injects the 13 workshop mods from `dist-overlay\mods` plus our
`sk-rework` mod. If you prefer to completely ignore `game\mod` / `game\mods` and
only install the 14 mods from `repo`, add `-NoInheritMods` to the end of the
command.)*

**Check:**
- `E:\testing\ShotgunKing-Modded\mods\` contains the **14 mod folders**
  (13 workshop mods + `sk-rework`, plus any extra `info.lua` mods you had in
  `game\mod` or `game\mods`)
- `E:\testing\ShotgunKing-Modded\PLAY-THIS.txt` exists
- `E:\testing\game` was only read from, never modified

---

### Step 5 — launch the copy and play a minute (5 minutes of live testing)

1. Double-click the game `.exe` inside `E:\testing\ShotgunKing-Modded`
   (Step 4 printed its exact path).
2. From the main menu, open the **mod menu**.
3. **Look and note:** are all 14 mods listed? Are they ON or OFF by default?
   (Make sure `SK Rework` / `sk-rework` is ON.)
4. **Start a run and play a couple of turns** — this is what makes the log
   useful. The `sk-rework` mod is a diagnostics build: it watches the game
   and writes what it sees to `log.txt` (it changes nothing in gameplay).
   Even 30 seconds of play is enough.
5. Quit the game normally.

The `sk-rework` mod reports on itself — if you open
`E:\testing\ShotgunKing-Modded\log.txt`, these lines mean it worked:

| Line in `log.txt` | Meaning |
|---|---|
| `SK-REWORK: BUILD=3 loaded (mod_index=…)` | the mod loaded |
| `SKA\|append\|YES` (a list of these) | the game API it plans to use exists |
| `SKH\|new_turn\|…` (5 of these) | its hooks registered |
| `SKE\|heartbeat\|frames=900` | it is alive and watching during play |
| `SK-REWORK: READY build=3 hooks=5` | everything above succeeded |

If the game crashes after the intro logos, don't worry — the reason is at the
**end** of `E:\testing\ShotgunKing-Modded\log.txt`. Continue to Step 6.

---

### Step 6 (PowerShell) — collect & send `log.txt` (the one blocker for feature work)

Copy-paste into PowerShell:

```powershell
cd E:\testing\repo\tools
powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\ShotgunKing-Modded" -GetLog
```

This copies `E:\testing\ShotgunKing-Modded\log.txt` to
`E:\testing\repo\uploads\game-insights\log.txt`.
**Attach that `log.txt` file in chat** (or attach
`E:\testing\ShotgunKing-Modded\log.txt` directly — they are identical).

**Optional preview (needs Python):** to generate `E:\testing\repo\notes\game-map-draft.md`
on your own PC right away:

```powershell
cd E:\testing\repo\tools
python "E:\testing\repo\tools\parse_log.py" "E:\testing\repo\uploads\game-insights\log.txt"
```

---

### Step 7 (Optional, PowerShell) — unlock everything in the copy only

Only do this **after Step 5** (the game must have launched once so
`E:\testing\ShotgunKing-Modded\save\` exists) and with the game **closed**:

```powershell
cd E:\testing\repo\tools
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded"
```

- **Dry run first (writes nothing):**
  ```powershell
  cd E:\testing\repo\tools
  python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --dry-run
  ```
- **Undo / restore automatic backup:**
  ```powershell
  cd E:\testing\repo\tools
  python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --restore
  ```

---

## 4. Success checklist (what to report back)

| # | Check | Pass looks like |
|---|---|---|
| 1 | Step 3 dry run | prints `[dry-run] would copy ...`, nothing written |
| 2 | Step 4 build | `E:\testing\ShotgunKing-Modded\mods\` has the 14 mod folders; `E:\testing\game` unchanged |
| 3 | Step 5 launch & mod menu | game reaches main menu; 14 mods visible; note whether they start ON or OFF |
| 4 | Step 6 log | `log.txt` collected and attached, containing `SK-REWORK: READY` |
| 5 | Step 7 (optional) | achievements/shotguns/codex unlocked in the copy |

Report anything that failed **at which step**, plus the end of `log.txt` if
the game crashed.

---

## 5. Where live testing ends and the roadmap begins

**Your part = Steps 1–7 above. That is all that is expected of you right now.**

| Phase | What | Status |
|---|---|---|
| 0–2a | engine identified, tooling + save tools + parser + smoke test built | ✅ done |
| 2b | read your `log.txt` → complete the game's function map (`notes/map.md`) | ⛔ blocked on Step 6 |
| 2c | in-game dev/cheat panel (give ammo/cards, god mode, spawns) | ⛔ after 2b |
| 3 | ammo rework, staged A → B → C | ⛔ after 2b |
| 4 | card picker + enemy picker | ⛔ after 2b |
| 5 | extra shot mechanics (knockback/pierce/bleed — vanilla internals) | ⛔ after 2b |
| 6 | balance knobs + final packaging (+ zero-arg auto-discovery on waitlist) | ⛔ after 2b |

---

## 6. Undo / cleanup

| To undo | Do this |
|---|---|
| the modded copy | delete `E:\testing\ShotgunKing-Modded` |
| the whole testing area | delete `E:\testing` |
| the 100% save | `python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --restore` |
| mods in your *real* install (only if you ever use the variations below) | delete `<game>\mods\<mod name>` |

---

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| `The argument '...\apply.ps1' to the -File parameter does not exist` | Make sure `E:\testing\repo` is 1:1 the root of the `main` branch so `apply.ps1` is at `E:\testing\repo\tools\apply.ps1` (not nested inside an extra `shotgun-king-anew-main` folder). |
| `running scripts is disabled on this system` | Use the exact `powershell -ExecutionPolicy Bypass -File "..."` command shown; don't double-click `.ps1` files. |
| `robocopy` fails partway ("file in use") | Close the game (and any Explorer window inside `ShotgunKing-Modded`), then re-run Step 4. |
| `python` opens the Microsoft Store / not recognized | Install Python from python.org with "Add python.exe to PATH" ticked, or replace `python` with `py` in Steps 6–7. |
| build script says `No data.sgr in …` | Make sure `E:\testing\game` contains the game `.exe` **and** `data.sgr`. |
| game crashes after the intro logos | Lua error — the reason is at the **end** of `E:\testing\ShotgunKing-Modded\log.txt`; send it via Step 6. |
| the 100% save "did nothing" | The game must be closed while running Step 7, and `--game-dir` must point at `E:\testing\ShotgunKing-Modded` (not `E:\testing\game`). |

---

## 8. Variations (only if you want them — ignore otherwise)

- **Different drive or parent folder** — keep the same three-folder structure
  (`game\`, `repo\`, `ShotgunKing-Modded\`) and replace `E:\testing` in the
  commands.
- **Unlocks only, no mods** — skip Step 4; launch your game once in
  `E:\testing\game`, close it, then run:
  ```powershell
  cd E:\testing\repo\tools
  python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\game"
  ```
- **Fix/install mods directly inside `E:\testing\game\mods` (compressed `.zip`s or unpacked folders)** —
  ```powershell
  cd E:\testing\repo\tools
  powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\install-mods.ps1" -GameDir "E:\testing\game" -ZipsDir "E:\testing\game\mods"
  ```
- **Deploy only our `sk-rework` mod into a game folder (dev loop)** —
  ```powershell
  cd E:\testing\repo\tools
  powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\ShotgunKing-Modded"
  ```
