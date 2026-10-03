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
the exe (see `tools/mod-dev.md`). The 13 reference mods + dev's guide live in
`uploads/` (inventoried in `notes/mods.md`).

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

1. **Flip the repo to private** (see warning above) — 1 minute.
2. Pick the ammo design (A simple scale / B shell economy / C shell types).
3. Playtest each phase build and report back ("repack crashed after intro" /
   "feels right").

*(Game files no longer needed from you — all 4 rar parts are in the repo and
were extracted & analyzed. Keep them or delete them from GitHub after going
private; the agent works from `uploads/`.)*

## Warnings

- The analyzed game copy is a Goldberg-emu repack, not a vanilla Steam
  install — fine for mod dev, but the in-game Steam Workshop UPLOAD button
  won't work there. Modding itself is unaffected.
- A **game update** may change internals — mods keep working (that's the
  point), but re-check `notes/map.md` TBDs against a fresh runtime dump.
- Crash with no log or right after intros = Lua error; the error text is at
  the END of `log.txt` next to the exe.
