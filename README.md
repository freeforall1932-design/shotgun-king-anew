# Shotgun King — Ammo & Gameplay Rework

A private, personal-use mod project for **Shotgun King: The Final Checkmate**
(PUNKCAKE Délicieux). We recover the game's source from its `.pck`, edit
GDScript directly, and repack — no mod loader involved.

**⚠️ Never publish anything from this repo.** The recovered game files are the
creator's IP. Everything from `game-dump/` and `build/` is gitignored; keep it
that way. Personal use only.

## What the mod will do (see `PLANNING.md` for the full plan)

1. Reworked ammo system (design A/B/C pending owner's pick — §5)
2. Card picker: manually pick any card / random from ALL cards
3. Enemy picker: manually pick or randomize spawns
4. New shot mechanics: knockback, pierce, bleed, …
5. Balance knobs: `damage_taken_mult`, `damage_dealt_mult`

## Layout

```
PLANNING.md     the full plan + agent handoff (read this first)
tools/          recover.md · apply.ps1 · repack.md   — the pipeline
game-dump/      recovered game project  (IGNORED BY GIT)
modded/         our changed files only, mirroring res:// paths  (committed)
notes/          map.md (code map) · changelog.md (what & why)
build/          repacked .pck output  (IGNORED BY GIT)
```

## The pipeline (the whole mod in 4 commands)

```bash
# 1. Recover source from the .pck  (backup the .pck first! — see tools/recover.md)
gdre_tools --headless --recover="path/to/ShotgunKing.pck" --output-dir=game-dump

# 2. Apply our changes on top of the recovery
pwsh tools/apply.ps1            # add -List for a dry run

# 3. (optional) quick script sanity check
godot --headless --path game-dump --check-only --script res://scripts/foo.gd

# 4. Repack + install into the game folder  (see tools/repack.md)
godot --headless --path game-dump --export-pack "SK-Rework" build/sk-rework.pck
```

Iterate: edit in `modded/` → `apply.ps1` → F5 in the Godot editor → when happy,
repack. Never edit `game-dump/` directly without copying the file back to
`modded/` (a re-recovery would eat it).

## Status

| Phase | What | State |
|---|---|---|
| 0 | Setup & recovery — game running from source | **blocked: needs game files / .pck path from owner** |
| 1 | Recon — code map (`notes/map.md`) | pending Phase 0 |
| 2 | Debug toolchain (F-key autoload) | pending |
| 3 | Ammo rework (owner picks design §5) | pending |
| 4 | Card + enemy pickers | pending |
| 5 | New shot mechanics | pending |
| 6 | Balance knobs + final packaging | pending |

## Owner's to-do (the only human-required steps)

1. **Provide the game's install folder / `.pck` path** (Steam → right-click →
   Manage → Browse local files) → unblocks Phase 0.
2. Let the agent make the `.pck` backup (or make one yourself: `ShotgunKing.pck.orig`).
3. *(Optional)* hand over the downloaded mod that fails to load, for diffing.
4. Pick the ammo design (A simple scale / B shell economy / C shell types).
5. Playtest repacked builds after each phase and report back.

## Warnings

- Steam **"Verify integrity"** wipes the modded .pck — keep `ShotgunKing.pck.orig`,
  re-copy, re-pack as needed.
- A **game update** invalidates the whole `game-dump/` — re-recover, re-apply
  (`tools/apply.ps1`), check `notes/map.md` for moved code.
- Crash right after the Sugar intro, before the PUNKCAKE intro = script syntax
  error. Always check that first.
