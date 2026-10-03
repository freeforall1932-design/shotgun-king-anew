# 🔫👑 Shotgun King: Reworked

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
| `tools/build-dist.ps1` | **A copy**: `dist\ShotgunKing-Modded\` (full game copy + `mods\`) | delete `dist\` — your install was never touched |
| `tools/apply.ps1` | Your real install: adds **one folder**, `<game>\mods\sk-rework\` | delete that one folder |
| `tools/install-mods.ps1` | Your real install: adds mod folders under `<game>\mods\` | delete those folders |
| `tools/make_100pct_save.py` | `save\*.sav` **in the game folder you point it at** (auto-backup first) | `--restore` (or the `save_backup_*` folder it creates) |

So, concretely:

- **"I just want to play"** → `build-dist.ps1` copies the game to `dist\` and
  puts the mods inside that copy. Play the copy. Your install stays clean.
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
| `sk-rework` mod stub | 🟡 code ready, unproven | Lua compiles, uses only patterns seen in shipped mods; **has never been loaded by the game yet** |
| `tools/build-dist.ps1` | 🟡 code ready, unproven | syntax-checked, but no PowerShell exists in the dev sandbox — first real execution is on your machine |
| `tools/save_codec.py` | ✅ verified | byte-identical parse/serialize on all 6 real saves (earlier session); re-tested end-to-end now |
| `tools/make_100pct_save.py` | ✅ mechanics · 🟡 game acceptance | dry-run/write/backup/restore all tested; whether the game *accepts* the edited save is only provable in-game |
| Ammo rework, card/enemy pickers, cheat panel | ⛔ blocked | needs one live run of the stub mod to harvest the game's function map first |

**Before your first run, know these three unknowns** (details:
[`notes/review-2026-10-03.md`](notes/review-2026-10-03.md)):

1. The PowerShell scripts have never been executed anywhere — syntax is
   checked, behaviour is not. That's why step 1 below is a no-write dry run.
2. Whether the game accepts the edited 100% save is unproven — it's reversible.
3. Whether mods are enabled by default is unproven — if not, it's one toggle
   in the in-game mod menu.

---

## 🚦 First run: a safe, ordered checklist

Do these in order; each step only gets riskier than the last, and all of them
are reversible.

```powershell
# 1. dry run — prints what would be copied, writes nothing
pwsh tools/apply.ps1 -GameDir "E:\games\Shotgun.King.The.Final.Checkmate.v1.623b" -List

# 2. build the modded COPY (your install is only read, never written)
pwsh tools/build-dist.ps1 -GameDir "E:\games\Shotgun.King.The.Final.Checkmate.v1.623b" -Clean
#    then check: dist\ShotgunKing-Modded\mods\ should contain 14 folders

# 3. launch dist\ShotgunKing-Modded\shotgun_king.exe
#    → mod menu: the mods should be listed and toggleable → quit the game

# 4. collect the log the project needs (this is the current blocker)
pwsh tools/apply.ps1 -GameDir "dist\ShotgunKing-Modded" -GetLog
#    → uploads/game-insights/log.txt  (gitignored; attach it in chat / upload to the repo)

# 5. optional: unlock everything, in the COPY (needs one launch first, so save\ exists)
python tools/make_100pct_save.py --game-dir "dist\ShotgunKing-Modded"
```

Step 4 is what unblocks all feature work: our stub mod writes the game's
function map into `log.txt` (`SKG|`/`SKR|`/`SKF|` lines), which can't be
obtained any other way. Step 5 is the "casual Sunday" unlock.

`pwsh` not found? Use `powershell` (Windows built-in) instead.

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
# a downloaded mod that won't load (zips live in one folder):
pwsh tools/install-mods.ps1 -GameDir "<game folder>" -ZipsDir "<folder with mod zips>"
```

---

## 💾 Save tools

Saves (`save/*.sav`) are `[4-byte length][zlib][PUNKCAKE text]` — fully
readable and writable. Files: `prog.sav` (weapons, ranks, badges, endless
floor) · `achievements.sav` · `stats.sav` (per-card history) · `reg.sav`,
`misc.sav`, `runs.sav`.

```powershell
python tools/save_codec.py "save\prog.sav"                 # decode any save to text
python tools/save_codec.py save --scan                      # check a whole save folder
python tools/make_100pct_save.py --game-dir "<game folder>" # unlock-all (backup first)
python tools/make_100pct_save.py --game-dir "<game folder>" --dry-run   # show, don't write
python tools/make_100pct_save.py --game-dir "<game folder>" --restore   # undo
```

The unlock-all sets: every achievement · shotguns 2–9 · throne rank 20 +
rank-20 badge per shotgun · endless floor 15 (unlocks Chase) · every vanilla
card marked played (codex 100%). It never touches best times or run history,
and the game must be closed while it runs.

---

## 🧰 Repository layout

```
├── modded/sk-rework/      🔧 our mod — the deliverable
├── dist-overlay/mods/     🧩 the 13 workshop mods, vendored, name-verified
├── tools/                 · build-dist.ps1   build the modded copy
│                          · apply.ps1        deploy our mod (+ -List, -GetLog)
│                          · install-mods.ps1 fix & install workshop zips
│                          · save_codec.py    .sav reader/writer
│                          · make_100pct_save.py  unlock-all generator
│                          · mod-dev.md       dev loop + SUGAR API notes
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

The mod's gameplay features — ammo rework, card picker, enemy picker, extra
shot mechanics, balance knobs, dev/cheat panel — are **not started**: they
need the function map from step 4's `log.txt`. The stub mod currently only
logs that map; it changes nothing in the game.

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
