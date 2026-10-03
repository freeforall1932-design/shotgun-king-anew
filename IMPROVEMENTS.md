# IMPROVEMENTS — session-level improvement log

> What got *better than originally planned* and why. File-by-file changes
> live in `notes/changelog.md`; this is the arc of the project.

## 2026-10-03 — Session 1 (planning → shipped toolchain)

1. **Engine identification: Godot → SUGAR.** The original plan (gdre_tools
   recovery, .pck repacking, exe swapping) was built on a wrong assumption
   from the old session notes. Examining the actual game files killed the
   entire repack pipeline before any effort was wasted on it — replaced by
   the game's *official* mod system. Cheaper, safer, update-proof, legal.
2. **Strategy: patch-the-game → ship-a-mod.** Direct file-editing would have
   died on every game update and every Steam verify. The mod deliverable
   survives updates, is toggleable per-mod in the vanilla mod menu (owner
   requirement), and never touches the original install (dist builds copy).
3. **"Mod won't load" mystery solved** — not one bug but a class of them:
   unextracted archives in mods/ (owner's King's Court.rar), folder-name ≠
   `name=` (disgraced_justice), and pre-mod-system legacy formats (2022
   King's Court). Codified into `install-mods.ps1` (auto-fix) + docs.
4. **Save format reverse-engineered, losslessly.** From raw hex to a
   byte-identical parser/serializer in one session (`save_codec.py`,
   selftest-proven). Enabled the unlock-all generator (achievements,
   9 shotguns, chase mode, codex) — the "casual Sunday player" feature —
   with backup/restore safety.
5. **Repo hygiene evolution.** Started as a plan doc + rars on main; now:
   zero game assets tracked, .gitignore guards (archives/binaries/caches),
   vendored-mods provenance documented, main-cleanup PR instead of 14
   manual web deletions, professional README with three audience-specific
   quick-starts.
6. **Zero-trust tooling checks.** The save codec selftest caught three real
   parser bugs before they could corrupt a save (empty tables, 0x1F string
   suffix, indentation assumption). The audit sweep caught two PowerShell
   defects (auto-locate paths, -GetLog error flow) and one silent gap
   (.rar mods). Every "done" in this project now has a mechanical check
   behind it where possible.
7. **Sandbox capability bootstrap.** No unrar → compiled UnRAR 7.20 from
   upstream source; no apt/pypi wheels route → worked around; downloads
   blocked → git-plumbing pulls. The unrecoverable-looking 4-part split
   archive became fully extractable inside the agent workspace.

## 2026-10-03 — Session 2 (review before live testing)

8. **Confidence replaced with evidence.** Instead of adding features on top of
   unverified docs, the session produced a verification matrix: what is
   mechanically proven in-sandbox (save tooling E2E, name-matching, Lua
   syntax, PowerShell parse), what is code-complete but unproven in-game, and
   what is blocked. Overclaims ("✅ shipped") were removed.
9. **The README now answers the only question that blocked the owner** —
   "does this patch my install or build a clone?" — in the first screen, with
   a per-tool target/undo table. Roadmap noise moved out of the play path.
10. **Review paid for itself immediately**: two real defects found and fixed
    (a quick-start ordering bug that would have made the 100% save *look*
    broken — unlocking the original install while playing the copy — and a
    latent `throne`-table data loss in the save tool), plus three robustness
    fixes. All fixes carry tests run in-sandbox.
11. **Static analysis where execution is impossible.** No PowerShell runtime
    exists here, so the `.ps1` files are now syntax-parsed with
    tree-sitter-powershell (available via pip); it caught the one ambiguous
    construct in `build-dist.ps1`.

## Improvement ideas parked for later

- In-game UI for save editing (cheat panel covers most of it)
- Auto-update check for game version vs. known map.md version
- A "verify my install" doctor script (folder names, archives, game closed)
- CI-style selftest run before each commit that touches tools/
