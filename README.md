# 🔫👑 Shotgun King: Reworked

> **👉 Installing or testing for the first time? Follow [`INSTALL.md`](INSTALL.md).**
> It is the one canonical, click-by-click path (folder layout, exact commands,
> what to report back). This README explains *what the project is* and *why*.

A private, personal-use **mod project** for *Shotgun King: The Final
Checkmate* v1.623b (PUNKCAKE Délicieux). Two separate things live here:

1. **A ready-to-play modded copy of the game** — 13 workshop mods plus our own
   mod, assembled for you by a script.
2. **Our own mod** (`sk-rework`) — currently a debug stub; the actual ammo
   rework / pickers / cheat panel are future work.

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
| 13 workshop mods vendored in `dist-overlay/mods/` | ✅ files verified | every folder name matches its `info.lua` (`name=`) — the #1 reason mods silently fail |
| `sk-rework` diagnostics mod (build 3) | 🟡 code ready, unproven | logs its own load + hooks + live game state; smoke-tested against a fake engine under both `all()` semantics, but **never loaded by the real game yet** |
| `tools/parse_log.py` log parser | ✅ tested | turns the mod's log lines into `notes/game-map-draft.md`; selftest 16/16 + end-to-end against the smoke-test log |
| `tools/mod_smoketest.py` | ✅ tested | runs the mod without the game (needs `lupa`); 27/27 checks under both engine semantics |
| `tools/build-dist.ps1` | 🟡 code ready, unproven | syntax-checked, but no PowerShell exists in the dev sandbox — first real execution is on your machine |
| `tools/save_codec.py` | ✅ verified | byte-identical parse/serialize on all 6 real saves (earlier session); re-tested end-to-end now |
| `tools/make_100pct_save.py` | ✅ mechanics · 🟡 game acceptance | dry-run/write/backup/restore all tested; whether the game *accepts* the edited save is only provable in-game |
| Ammo rework, card/enemy pickers, cheat panel | ⛔ blocked | needs one live run of the stub mod to harvest the game's function map first |

**Before your first run, know these three unknowns** (details:
[`notes/review-2026-10-03.md`](notes/review-2026-10-03.md)):

1. The PowerShell scripts have never been executed anywhere — syntax is
   checked, behaviour is not. That's why `INSTALL.md` starts with a no-write
   dry run.
2. Whether the game accepts the edited 100% save is unproven — it's reversible.
3. Whether mods are enabled by default is unproven — if not, it's one toggle
   in the in-game mod menu.

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
| 7 | *optional:* `make_100pct_save.py` unlock-all, in the copy | copy's `save\` (backed up) |

Step 6 is what unblocks all feature work: our diagnostics mod writes its own
load/hook proof plus a live dump of the game's functions, state and objects
into `log.txt` (`SKG|`, `SKA|`, `SKH|`, `SKW|`… lines). `tools/parse_log.py`
then turns that into `notes/game-map-draft.md` — the raw material for the
cheat panel, ammo rework and pickers.

### What to download

The **whole repository** (~8.5 MB, no game files inside) — there is no
single-file patch, and nothing here patches or modifies the game's `.exe` or
`data.sgr`. Mods are folders; the tools need each other; the 13 workshop mods
ship as folders too.

---

## 🎮 Playing & mods

- Mods are **not forced on**. The in-game **mod menu** lists every mod found in
  `mods\`; flip each one on/off per playthrough.
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
rank-20 badge per shotgun · endless floor 15 (unlocks Chase) · every vanilla
card marked played (codex 100%). It never touches best times or run history,
and the game must be closed while it runs.

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
| Everything feels vanilla | mods are toggled off — check the in-game mod menu |
| 100% save didn't apply | game was running while writing, or you pointed at the wrong folder (the copy has its own `save\`) — close it, re-run |
| `pwsh` not found | use `powershell` instead |

---

## 🗺️ Where the project is going (short)

**Live testing (yours, now):** `INSTALL.md` steps 1–7. Nothing else is asked
of you, and nothing below needs you to run or configure anything.

**Development (mine, after your `log.txt` arrives):** the mod's gameplay
features — ammo rework, card picker, enemy picker, extra shot mechanics,
balance knobs, dev/cheat panel — are **not started**: they need the function
map that only a live run can produce. The stub mod currently only logs that
map; it changes nothing in the game.

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
