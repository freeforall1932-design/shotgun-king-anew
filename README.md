# Shotgun King — Ammo & Gameplay Rework

A private, personal-use mod project for **Shotgun King: The Final Checkmate**
(PUNKCAKE Délicieux, engine: **SUGAR** — custom Lua, NOT Godot; see
PLANNING.md §0.5). The game has an official mod system, so **our deliverable
is a mod**, not a patched exe.

**⚠️ This repo must be PRIVATE.** It currently contains ripped game archives
(creator's IP) on `main` + the arena branch. Flip it: *GitHub → repo →
Settings → General → Danger Zone → Change visibility → Private.* (The agent
token lacks admin; owner must click it.)

## What the mod will do (full plan: `PLANNING.md`)

1. Reworked ammo system (design A/B/C pending owner's pick — §5)
2. Card picker: manually pick any card / random from ALL cards
3. Enemy picker: manually pick or randomize spawns
4. New shot mechanics: knockback, pierce, bleed, … (many exist as vanilla
   card fields already — mostly exposing + combining)
5. Balance knobs: `damage_taken_mult`, `damage_dealt_mult`

## Layout

```
PLANNING.md     the plan + 2026-10-03 engine correction (§0.5) — read first
tools/          recover.md · mod-dev.md · apply.ps1 — the pipeline
uploads/        owner's archives + modding-guide + insights (IGNORED BY GIT)
modded/sk-rework/   OUR MOD: info.lua, script.lua, modes/…  (the deliverable)
notes/          map.md · mods.md · changelog.md · data-sgr-filelist.txt
```

## The pipeline (no repacking — mods are the product)

```
edit modded/sk-rework/*  →  pwsh tools/apply.ps1 -GameDir "<game folder>"
→  launch game, enable "sk-rework" in mod menu  →  play; check log.txt
```

Debugging inside the mod: `_log()`, `gimme("global")`, crashlogs land next to
the exe (see `tools/mod-dev.md`). Reference mods + dev's guide live in
`uploads/` (inventoried in `notes/mods.md`).

## The "injected" ready-to-play build (game genes, per owner request)

```powershell
pwsh tools/build-dist.ps1 -GameDir "<your game folder>" -Clean
```

Copies your game → `dist/ShotgunKing-Modded/` and injects everything:
13 workshop mods (`dist-overlay/mods/`, names verified against `info.lua`)
+ our `sk-rework`. Play by running the exe inside `dist/` — your original
folder is never touched. (First launch may need one mod-menu toggle; live
test will confirm whether present mods auto-enable.)

Save editing (cheat-adjacent, format cracked): `tools/save_codec.py` —
decode any `save/*.sav` to text, edit, pack back. `prog.sav` = progression
(unlock weapons/badges/ranks), `stats.sav` = per-card played/ignored memory.

## Status

| Phase | What | State |
|---|---|---|
| 0 | Game obtained, analyzed, engine identified | **done** (2026-10-03) |
| 1 | Recon — code map (`notes/map.md`) | **mostly done pre-source** (guide + mods); runtime dump pending |
| 2 | Debug toolchain mod (F-keys + `gimme()` dump) | next up |
| 3 | Ammo rework (owner picks design §5) | pending |
| 4 | Card + enemy pickers | pending |
| 5 | New shot mechanics | pending (vanilla `knockback`/`pierce` fields confirmed) |
| 6 | Balance knobs + packaging | pending |

## Owner's to-do

1. **Test mission (NOW, before more features get built)** — the Phase 2 stub
   is already pushed:
   ```
   pwsh tools/apply.ps1 -GameDir "<your game folder>"
   ```
   → launch game → mod menu → enable **SK Rework** → quit → upload the game's
   `log.txt` to the repo (like the rar parts). The log contains the full
   function map (`SKG|…` lines) that the real features get built on.
2. *(Optional, fixes "boring game")* install the 13 workshop mods properly:
   ```
   pwsh tools/install-mods.ps1 -GameDir "<game folder>" -ZipsDir "<folder with the mod zips>"
   ```
3. Delete `Shotgun...part4.rar` + the 13 mod zips from **main** via web UI
   (each file → trash icon) — or just flip the repo private at deployment.
4. Pick nothing else for now — ammo design is decided (A→B→C progressive,
   PLANNING.md §0.6); playtest each phase build and report back.

## Warnings

- The analyzed game copy is a Goldberg-emu repack, not a vanilla Steam
  install — fine for mod dev, but the in-game Steam Workshop UPLOAD button
  won't work there. Modding itself is unaffected.
- A **game update** may change internals — mods keep working (that's the
  point), but re-check `notes/map.md` TBDs against a fresh runtime dump.
- Crash with no log or right after intros = Lua error; the error text is at
  the END of `log.txt` next to the exe.
