# modded/ — our changes only, mirroring res://

Every file we change or add lives here at its **exact `res://` path**, e.g.

    game-dump/scripts/player.gd   (original, never committed)
    modded/scripts/player.gd      (our version, committed)

so `tools/apply.ps1` is a dumb folder copy. Nothing else goes in here.

## Rules (from PLANNING.md §3.4)

1. **Additive over invasive** — bolt onto existing functions rather than
   rewriting them, so game updates break less.
2. **Never delete original logic** — comment it out with a `# SK-REWORK:` marker
   and put the new logic next to it.
3. New files (debug autoload, new scenes) are fine — they're simply NEW when
   applied.
4. If you edited a file directly inside `game-dump/` while experimenting,
   copy it back here BEFORE committing, or the change is lost on the next
   re-recovery.

## Status

Empty — nothing modified yet. First entries arrive in Phase 2 (debug autoload).
