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
| Python 3 (recommended: Step 4 uses it for the automatic 100% unlock; also Step 6 preview) | in PowerShell: `python --version` — if it opens the Microsoft Store or errors, install from python.org and **tick "Add python.exe to PATH"**. Without it the build still works — it prints the manual unlock command instead. |

---

## 3. Steps (do them in order)

> **Re-running this after a repo update (e.g. the second live test)?**
> First bring `E:\testing\repo` up to date with the newest code (re-download
> the ZIP and overwrite, or `git pull`), then simply redo Steps 4 → 5 → 6 → 7.
> Every command here is safe to re-run; the unlock step is idempotent (running it again
> only adds what is missing).

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

*Which folder goes where:* `-GameDir` is your **base game folder** — it is
only the *destination* the dry run prints. The mod files it "would copy"
come from the repo itself (`repo\modded\sk-rework`, found automatically next
to the script). The game folder needs no mods for this step.

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
command. The build also writes `mods\modlist.lua` (step 3b/3, `sk-rework`
starts ON) and applies the 100% unlock to the copy's save (step 4/4); add
`-NoUnlockAll` if you want the copy to keep its inherited save progress.)*

**Which to pick:**

| Flag | Copy contains | Use when |
|---|---|---|
| `-NoInheritMods` | exactly the 14 repo mods — a sanitized run | testing whether *this repo's* mods/tools work (fewest variables) — **use for the harvest run** |
| *(no flag)* | the 14 repo mods **plus** your `game\mod`/`game\mods` mods (zips unpacked, names fixed, legacy/`.rar` removed) | everyday play, once everything is proven |

Both only read `E:\testing\game`, never modify it. Note: `.rar`-packed mods
and mods without a readable `info.lua` are removed from the copy — the game
itself silently ignores those too.

**Check:**
- `E:\testing\ShotgunKing-Modded\mods\` contains the **14 mod folders**
  (13 workshop mods + `sk-rework`, plus any extra `info.lua` mods you had in
  `game\mod` or `game\mods`)
- `E:\testing\ShotgunKing-Modded\mods\modlist.lua` exists — that is the build
  pre-enabling `sk-rework` for you (add `-AllModsOn` to the command above if
  you want every mod to start ON)
- `E:\testing\ShotgunKing-Modded\PLAY-THIS.txt` exists
- `E:\testing\game` was only read from, never modified

---

### Step 5 — launch the copy and play a minute (Build-8 live test)

1. Double-click the game `.exe` inside `E:\testing\ShotgunKing-Modded`
   (Step 4 printed its exact path).
2. To open the **mod menu**, click **Play** — it is the **top entry** of
   that screen.
3. **Mod menu states (verified live, run 2):** mods start **OFF by default**
   — **black text = OFF, white text = ON**. The build writes
   `mods\modlist.lua`, so `SK Rework` / `sk-rework` should already show white
   (ON) and the 13 workshop mods black (OFF). The **up/down arrows only
   change load priority**. The list is now in dependency order, with
   `Glac Terminal` last (Build 8). Turn **all** mods ON once, go back, and
   note any red warning text: there should be none about load order, and no
   `didn't match any files` lines in `log.txt`. The legend/Back polish is a
   later item, so only note how they behave.
4. Start a run and play a couple of turns. **Build 8 panel:** a small
   **`SK DEV`** tab sits in the **bottom-left corner** of the screen. Click
   it, and a box opens over the board, like the card-choice screen. While
   it is open, **every click belongs to the panel**: nothing on the board
   reacts, and clicking outside the box (or `CLOSE`) returns you to the game.
   **Page 1:** `+3 AMMO` · `RELOAD` · `CLIP+` · `SAFE:off/on` ·
   `CARD:AUTO/LIST` · `CARD NOW` · `CARDS >` · `SPAWN >` · `GOD:off/on` ·
   `DMG:off/on` · `DMG+ 1-1` · `CRIT+ 0%` · `CLOSE`.
   Labels change the moment you click (ON/OFF, the damage range, the crit %).
   Click each one **once**, in this order if convenient:
   1. `CLIP+` first (the run-6 bug): the king must **not** move, and the
      panel must stay open. Then `+3 AMMO` (reserve +3) and `RELOAD`
      (chamber fills).
   2. `CARD NOW` (takes a card), then `CARDS >` → take any card from the
      list → `FILT:ALL`/`FILT:PIECE` filters to piece/summon cards (e.g.
      Right-hand) → the summoned piece arrives on a neighbouring square →
      `< BACK`.
   3. `SPAWN >` → pick `knight`/`bishop`/etc. The ally should appear on a
      DIAGONAL neighbour → `< BACK`.
   4. `GOD:on`, then let a piece hit you lethally: the king should dodge to a
      free square instead of dying.
   5. `DMG:on`, then `DMG+`/`CRIT+` and fire a few shots: damage rolls (and
      crits on piercing shots) appear in the log as `SKD|dmg|…`.
   6. `SAFE:on` limits a boot to ONE gameplay-mutating call (use it if a
      control ever crashes the game — it makes the culprit obvious).
   7. `CLOSE`: only the tab remains, and your turn continues normally (move
      the king, shoot).
   8. Level up once with the panel open or closed: the tab must disappear
      during the card choice and come back afterwards. Die or resign and
      start a **new run**: the tab must be there again (run 6: it vanished
      for good).
   Every engine-mutating control logs an intent line (`SKE|call|<name>=start`)
   before it runs, so if the game dies, `log.txt` names the control. Note
   crashes, overlap with the HUD (especially around the bottom-left tab), or
   wrong behaviour. Then quit normally.

Build 8 writes its load/hook proof plus the card/offer/soul/damage/input/UI
probes and the engine-call trace to `log.txt`. The game prefixes every line with `  . ` — that is normal.

> **Build 5 crashed at boot (run 4)** — it probed an input name the engine did
> not know, and SUGAR treats that as fatal. Build 6 (run 5: booted and played
> 22 min cleanly), Build 7 and Build 8 only probe inputs the game
> itself published, so that crash cannot repeat; if the game ever quits at boot
> again, send me `log.txt` **and** the newest `crash_log_*.txt` — the last
> `ERR`/`Stack traceback` block names the exact line.

| Line/prefix in `log.txt` | Meaning |
|---|---|
| `SK-REWORK: BUILD=8 loaded (mod_index=…)` | the mod loaded |
| `SKA2\|mod_found=yes\|active=true` | it found itself enabled in the mod list |
| `SKH\|…` | additive hook registrations |
| `SKW\|turn=1\|…` | first per-turn state sample |
| `SKA2\|probe\|<block>=done` | a probe block finished (cards/exclude/souls/bank/input) |
| `SKCF\|…`, `SKOF\|…`, `SKS\|…`, `SKD\|…`, `SKI\|…`, `SKUI\|…` | card, offer, soul/scepter, damage, input and UI probes (static dumps follow READY) |
| `SKUI\|panel\|…`, `SKUI\|card\|…`, `SKUI\|spawn\|…`, `SKUI\|dodge\|…`, `SKUI\|cfg\|…` | panel state (`entity=created`, `open=…\|via=tab/close/outside_click`, `click=<label>`), card/spawn pickers, dodge routes and the live damage config |
| `SKE\|call\|<name>=start` … `=ok` | an engine-mutating control ran; a `=start` with no matching `=ok` names the control that crashed the game |
| `SKD\|dmg\|before=…\|after=…\|crit=…` | the configured damage/crit roll applied to a fired bullet |
| `SK-REWORK: READY build=8 hooks=…` | load and registrations reached the marker |

---

### Step 6 (PowerShell) — collect & send the insight pack

Copy-paste into PowerShell:

```powershell
cd E:\testing\repo\tools
powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\ShotgunKing-Modded" -GetInsights
```

This copies into `E:\testing\repo\uploads\game-insights\`:

- `log.txt` — the game log (same thing `-GetLog` fetches),
- `modlist.lua` — the game's own "which mods are on, in which order" notepad,
- the copy's whole `save\` folder.

**Attach everything from that folder in chat** (or upload the folder to the
repo, like last time).

*(Only need the log? `-GetLog` instead of `-GetInsights` copies just
`log.txt`.)*

**Optional preview (needs Python):** to generate `E:\testing\repo\notes\game-map-draft.md`
on your own PC right away:

```powershell
cd E:\testing\repo\tools
python "E:\testing\repo\tools\parse_log.py" "E:\testing\repo\uploads\game-insights\log.txt"
```

---

### Step 7 (Automatic since run 3) — unlock everything in the copy only

**You usually don't run anything for this anymore.** `build-dist.ps1` (Step 4)
now applies the 100% unlock itself as its **step 4/4** — right after building
the copy you should have seen:

```
4/4 applying the 100% unlock to the copy (achievements/shotguns/modes/codex)
backup  -> E:\testing\ShotgunKing-Modded\save_backup_<timestamp>
achievements: 128 set True
...
```

So the copy boots with everything unlocked from the start, and the pre-unlock
save is backed up inside the copy (`save_backup_<timestamp>\`). Your original
game's save is never touched.

Manual use is only needed if:

- Step 4 printed `4/4 unlock-all skipped` (no `save\` in the copy yet — happens
  when the source game was never launched). Then: launch the copy once, quit,
  and run the command below with the game **closed**.
- You want to re-apply (idempotent), dry-run, or undo:

```powershell
cd E:\testing\repo\tools
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded"            # apply / re-apply
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --dry-run  # show, don't write
python "E:\testing\repo\tools\make_100pct_save.py" --game-dir "E:\testing\ShotgunKing-Modded" --restore  # undo (newest backup)
```

**Two things that look wrong but are not:**

- The title screen says `MODDED: ON - ACHIEVEMENTS: OFF` while a mod is
  active. That pauses *Steam* achievement tracking only — the achievements
  in this copy's save stay unlocked (run-2 live check: all 128 still True
  after a full modded session). Nothing to fix.
- The codex shows **100%**. The tool writes the complete live-verified card
  set — all 186 real cards plus the 9 special codex keys the game tracks
  (195 total, exactly what the game itself records). It is idempotent.

---

## 4. Success checklist (what to report back)

| # | Check | Pass looks like |
|---|---|---|
| 1 | Step 3 dry run | prints `[dry-run] would copy ...`, nothing written |
| 2 | Step 4 build | `E:\testing\ShotgunKing-Modded\mods\` has the 14 mod folders; `E:\testing\game` unchanged |
| 3 | Step 5 launch & mod menu | click Play → mod menu on top; 14 mods visible, `sk-rework` white/ON (pre-enabled), workshop mods black/OFF; note Build-6 Back/legend if shown |
| 4 | Step 5 in-run panel | `SK DEV` tab (bottom-left) opens the box; `CLIP+` does NOT move the king; labels change live; card (AUTO/LIST/FILT), spawn (piece + square), God Mode dodge, damage/crit rolls, SAFE; `CLOSE` leaves only the tab and the turn continues; tab hides during a card choice and is back on a new run; all-mods-ON shows no load-order warnings; report crashes |
| 5 | Step 6 insight pack | `uploads\game-insights\` (log + modlist.lua + save\) attached; log contains `READY build=8`, `SK-REWORK: PROBE done build=8`, `SKUI\|panel\|entity=created`, the `SKCF/SKOF/SKS/SKD/SKI/SKUI` probe lines, and the `SKE\|call`/`SKD\|dmg` traces |
| 6 | Step 4's 4/4 + Step 7 | build console shows `4/4 applying the 100% unlock...`; copy boots with achievements/shotguns/codex 100%; `ACHIEVEMENTS: OFF` title label is normal (Steam tracking paused; save-side achievements stay unlocked) |

Report anything that failed **at which step**, plus the end of `log.txt` if
the game crashed.

---

## 5. Where live testing ends and the roadmap begins

**Your part = Steps 1–7 above. That is all that is expected of you right now.**

| Phase | What | Status |
|---|---|---|
| 0–2a | engine identified, tooling + save tools + parser + smoke test built | ✅ done |
| 2b | read your `log.txt` → complete the game's function map (`notes/map.md`) | ✅ live map promoted (runs 1–4); Build-6 probes target the remaining unknowns |
| 2c | in-game dev/cheat panel + mod-menu legend/Back | 🟡 Build 7 ran live in run 6 (bank + menu widgets proven; the panel click also moved the king). **Build 8** rebuilds the panel as a click-consuming overlay against the decoded game source — sandbox-tested 59/59, owner live run pending |
| 3 | ammo rework, staged A → B → C | ⛔ queued after Build-6 live probes/playtest |
| 4 | card picker + enemy picker | ⛔ queued after Build-6 live probes/playtest |
| 5 | extra shot mechanics (knockback/pierce/bleed — vanilla internals) | ⛔ queued after Build-6 live probes/playtest |
| 6 | balance knobs + final packaging (+ zero-arg auto-discovery on waitlist) | ⛔ queued

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
| the 100% save "did nothing" | Step 4 prints `4/4 unlock-all skipped` when the copy has no `save\` yet (source game never launched) — launch the copy once, quit, then run the Step 7 command manually. The game must be closed while it runs. |
| title bar says `ACHIEVEMENTS: OFF` | Normal with mods active (Steam tracking paused; the save-side achievements stay unlocked — live-verified). |
| codex stuck below 100% | Old save tool version — re-run Step 7 with the updated repo (now writes the live-verified 195-card set). |
| mod menu numbering looks scrambled after moving mods | Up/down = load priority, not on/off; the renumbering is cosmetic. |
| `parse_log.py` says "no SK-REWORK lines" | You ran an old copy of the parser on a real log — update the repo; the parser now strips the game's `  . ` line prefix. |

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
