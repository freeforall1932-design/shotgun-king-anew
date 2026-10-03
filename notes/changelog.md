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

## 2026-10-03 — Phase -1: repo scaffold

- No game files touched. Created the PLANNING.md §2 structure:
  `.gitignore`, `README.md`, `tools/` (recover.md, apply.ps1, repack.md),
  `modded/`, `notes/` (map.md, changelog.md), `game-dump/` (ignored).
- Renamed the handoff file `2026-10-02-shotgun-king-plan.md` → `PLANNING.md`
  as the plan itself prescribes (§2).
- why: working structure must exist before Phase 0 so nothing we keep ever
  lands outside `modded/`.
- status: shipped
