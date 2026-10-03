# 🔫👑 Shotgun King: Reworked

> A private, personal-use **mod project** for *Shotgun King: The Final Checkmate*
> (PUNKCAKE Délicieux) — ammo rework, pick-anything tools, built-in dev cheats,
> and a ready-to-play modded build of the game.
>
> Engine: **SUGAR** (the studio's custom Lua engine) · Game version: **v1.623b** ·
> Mod system: official (`info.lua` format)

---

## ✨ What this gives you

| Feature | Status |
|---|---|
| 🎮 Ready-to-play game build with 13 workshop mods pre-installed | ✅ shipped (`tools/build-dist.ps1`) |
| 🔓 100% casual save — all achievements, all 9 shotguns, all modes, full codex | ✅ shipped (`tools/make_100pct_save.py`) |
| 🧩 Mods toggle on/off in the in-game mod menu (nothing is forced) | ✅ by design |
| 💾 Save file codec — read/edit/write any `.sav` | ✅ shipped, roundtrip-verified |
| 🛠️ Dev/cheat panel inside the game (give ammo/cards, god mode, spawners) | 🔜 next phase |
| 🧪 Ammo rework — A: simple scale → B: shell economy → C: shell types | 🔜 phased |
| 🃏 Card picker (pick ANY card / random from all / ban list) | 🔜 planned |
| ♟️ Enemy picker (choose or randomize spawns) | 🔜 planned |
| ⚖️ Balance knobs (`damage_taken_mult`, `damage_dealt_mult`) | 🔜 planned |

---

## 🚀 Quick Start

You need: Windows, PowerShell, Python 3 (for the save tools), and your own
copy of the game. Pick the path that matches your mood:

### "I just want to play with everything unlocked"

```powershell
# 1. build a modded copy of the game (original folder untouched)
pwsh tools/build-dist.ps1 -GameDir "E:\games\Shotgun.King.The.Final.Checkmate.v1.623b" -Clean

# 2. unlock everything in YOUR save (auto-backs up first)
python tools/make_100pct_save.py --game-dir "E:\games\Shotgun.King.The.Final.Checkmate.v1.623b"

# 3. play!
dist\ShotgunKing-Modded\shotgun_king.exe
```

Mods not active? Open the **mod menu** in-game and flip them on — every
injected mod appears there individually and can be toggled any time.

Just want the unlocks, no mods? Skip step 1 — the save tool works on a
vanilla install too.

### "A workshop mod I downloaded won't load"

```powershell
pwsh tools/install-mods.ps1 -GameDir "<game folder>" -ZipsDir "<folder with the mod zips>"
```

It unzips each mod into `mods/` and renames the folder to the `name=` field
inside its `info.lua` — the #1 reason mods silently fail to load (plus: mods
must be *unpacked folders*, never `.zip`/`.rar`).

### "I'm developing the mod"

```powershell
git clone <this repo>; cd shotgun-king-anew
pwsh tools/apply.ps1 -GameDir "<game folder>"     # deploy modded/sk-rework/ only
# play, then fetch the game's log for analysis:
pwsh tools/apply.ps1 -GameDir "<game folder>" -GetLog
```

Dev loop, SUGAR API notes, hooking patterns: **[`tools/mod-dev.md`](tools/mod-dev.md)**

---

## 📁 Repository layout

```
├── modded/sk-rework/      🔧 our mod (the deliverable — info.lua, script.lua, …)
├── dist-overlay/mods/     🧩 13 workshop mods, vendored (folder names verified)
├── tools/
│   ├── build-dist.ps1         build the ready-to-play modded game copy
│   ├── install-mods.ps1       fix-and-install workshop mod zips
│   ├── apply.ps1              deploy our mod only (+ fetch game log)
│   ├── save_codec.py          .sav container + PUNKCAKE serializer (lossless)
│   ├── make_100pct_save.py    unlock-all save generator (backup/dry-run/restore)
│   ├── mod-dev.md             the mod dev loop + SUGAR API cheat-sheet
│   └── recover.md             game archive handling & intel notes
├── notes/
│   ├── map.md                 code map: what we know about the game's internals
│   ├── mods.md                the 13 workshop mods + the mod format they prove
│   ├── data-sgr-filelist.txt  all 278 files inside data.sgr
│   └── changelog.md           every change, dated, with reasons
├── PLANNING.md            📜 the full plan, corrections & owner decisions
└── uploads/               📦 (gitignored) game archives, extracted mods, tools
```

---

## 🎮 How mods work here (and why they can't "break" your game)

Shotgun King loads mods from `<game folder>/mods/<mod name>/`. Each mod is a
plain folder with an `info.lua`. The game's own **mod menu** lists every mod
found — you switch each one on or off there, per playthrough. Our build
*injects* mods into a **copy** of the game; your original install is never
modified, and deleting the `mods/` folder returns the copy to vanilla.

Mod facts worth knowing (details in [`notes/mods.md`](notes/mods.md)):

- the folder name **must** equal the `name=` field inside `info.lua`
- mods must be unpacked — a `.zip`/`.rar` in `mods/` is silently ignored
- load order is controlled by `priority_hint` in `info.lua`

## 💾 Save tools

Saves (`save/*.sav`) are `[4-byte length][zlib][PUNKCAKE text]` — fully
readable and writable:

```powershell
# inspect any save as text
python tools/save_codec.py "save/prog.sav"

# what's inside (v1.623b):
#   prog.sav         progression: weapons, ranks, badges, endless floor
#   achievements.sav achievement flags          stats.sav  per-card history
#   reg.sav          file registry             misc.sav / runs.sav  misc+runs
```

`make_100pct_save.py` sets: all achievements · weapons 1–9 · throne rank 20 ·
rank-20 badge per weapon · endless floor 15 (unlocks Chase) · every vanilla
card marked played (codex 100%). It **never** touches best times or run
history, backs up your save first, and `--restore` undoes it.

---

## 🗺️ Roadmap

- [x] **Phase 0** — game analyzed; engine identified (SUGAR, not Godot!)
- [x] **Phase 1** — pre-source recon: vanilla card data, mod API, save format
- [x] **Phase 2a** — tooling shipped (dist builder, mod installer, save tools)
- [ ] **Phase 2b** — runtime recon: run the stub mod once, harvest the game's
      full function map from `log.txt`
- [ ] **Phase 2c** — in-game dev/cheat panel (native-feel, mod-menu toggleable)
- [ ] **Phase 3** — ammo rework, staged: **A** simple scale → **B** shell
      economy → **C** shell types
- [ ] **Phase 4** — card picker + enemy picker
- [ ] **Phase 5** — extra shot mechanics (vanilla `knockback`/`pierce` fields
      already confirmed — this is mostly exposure + UI)
- [ ] **Phase 6** — balance knobs + final packaging (repo goes private here)

Full detail & decision log: [`PLANNING.md`](PLANNING.md)

---

## 🩺 Troubleshooting

| Symptom | Fix |
|---|---|
| Mod doesn't show up in the mod menu | folder name ≠ `name=` in `info.lua`, or it's still zipped — run `install-mods.ps1` |
| Game crashes after the intro logos | Lua error — open `log.txt` next to the exe, the error is at the **end** |
| Everything feels vanilla | mods are toggled off — check the in-game mod menu |
| 100% save didn't apply | game was running while writing; close it and re-run |
| `pwsh` not found | use `powershell` (Windows built-in) instead |
| Want my old save back | `python tools/make_100pct_save.py --game-dir <path> --restore` |

---

## ⚖️ Legal & credits

- *Shotgun King: The Final Checkmate* is by **PUNKCAKE Délicieux** (Benjamin
  Soulé & Rémy Devaux). This repo is a **private, personal-use** mod project —
  no game assets are redistributed in the tracked repository, and nothing here
  is for public release.
- Vendored workshop mods in `dist-overlay/mods/` belong to their authors
  (Glacies, sub122, Lorina Sonetto & Bob Qwerty, Willhart, …) and are mirrored
  here only to assemble the owner's personal build. Removed on author request.
- Modding guide & SUGAR manual: `TRASEVOL-DOG/Shotgun-King-Modding-Guide`.
