# notes/changelog.md — what we changed and why

Every kept change gets an entry. Newest first. `res://` paths only (the same
file lives in `modded/` at that path).

## Format

```
## YYYY-MM-DD — Phase N: <short title>
- `res://path/to/file.gd` — what changed (with `# SK-REWORK:` markers inside)
- why: <reason / which design option from PLANNING.md §5>
- status: <shipped / playtest-pending / reverted>
```

---

## 2026-10-03 — Phase 0 prep: embedded-pack handling

- `tools/recover.md`, `tools/repack.md`, `PLANNING.md` §8 updated: the game
  ships with its pack **embedded in the exe** (owner confirmed: no loose .pck
  in the install folder). Recovery points `--recover` at the exe; repack uses
  an export preset with "Embed Pck" ticked (or gdre_tools `--pck-patch
  --embed`) and installs by replacing the exe under its original filename.
- why: `--recover` accepts pck/apk/embedded-exe natively (gdsdecomp docs);
  an exe-embedded game ignores a dropped-in .pck, so install must swap the exe.
- status: shipped (docs only, no game files touched)

## 2026-10-03 — Phase -1: repo scaffold

- No game files touched. Created the PLANNING.md §2 structure:
  `.gitignore`, `README.md`, `tools/` (recover.md, apply.ps1, repack.md),
  `modded/`, `notes/` (map.md, changelog.md), `game-dump/` (ignored).
- Renamed the handoff file `2026-10-02-shotgun-king-plan.md` → `PLANNING.md`
  as the plan itself prescribes (§2).
- why: working structure must exist before Phase 0 so nothing we keep ever
  lands outside `modded/`.
- status: shipped
