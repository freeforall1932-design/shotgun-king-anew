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

12. **One canonical path, alternatives quarantined.** `INSTALL.md` is now the
    only place with steps; the README summarizes and links instead of
    repeating (duplicate instructions are how contradictions are born).
    Variations (different paths, unlocks-only, modding the real install, dev
    loop) live in a clearly-marked section at the end, so the main flow can't
    be confused with an edge case. Boundaries are explicit: the owner's job
    is Steps 1–7; everything else is development that will arrive with its
    own instructions.

## 2026-10-03 — Session 2b (self-logging diagnostics)

13. **The patch proves itself.** Instead of asking the owner to trust that a
    silent mod loaded, the diagnostics build now emits its own verdict chain:
    load banner → API existence check → hook registration lines → heartbeat →
    `SK-REWORK: READY`. A failed load is now diagnosable from the log alone
    (and `parse_log.py` says so explicitly, with the log tail).
14. **Logging designed for a parser, not for humans.** Every line has a stable
    prefix and `k=v` payload, so `tools/parse_log.py` can rebuild the function
    map, the live object model and per-TBD candidate lists automatically —
    the "map fills itself" step, with zero manual grepping.
15. **A fake game engine in CI.** `mod_smoketest.py` runs the real `script.lua`
    against a synthetic SUGAR environment (lupa) under **both** possible
    `all()` semantics, then pipes the output through the parser. It caught a
    boolean-concatenation crash and a nested-table blind spot before the owner
    ever ran the game — the class of bug that would otherwise waste a live
    test cycle.
16. **Engine facts pinned from usage, not assumption.** Reading how the 13
    shipped mods actually call things (all() yields values; on_* dispatch comes
    from the Terminal mod; append() on globals is the reliable hook) turned
    guesswork into a design the live log will confirm or refute explicitly.

## 2026-10-03/04 — Sessions 5–6 (live runs 2–3 absorbed → toolchain completed → consolidated)

17. **Evidence beat documentation, twice.** Run 2's harvested
    `modlist.lua` disproved run 1's "mods are ON by default" claim (they
    start OFF/black — the owner had been right), and run 3's saves
    explained "no all-unlock" (the separate tool step was simply never
    run). Both times the fix followed the evidence, not the previous doc.
18. **The toolchain finished itself.** Knowing the modlist format turned
    `build-dist.ps1` into a one-command experience: pre-enable mods (3b,
    byte-identical to the game's own file), inject 14 mods, **and** apply
    the 100% unlock automatically (4/4) — the owner's "why isn't it just
    unlocked from the start" became the default behavior.
19. **Logs from rebooted sessions parse correctly.** The mod menu's
    save-and-reboot turned out to soft-reboot inside the same log.txt
    (mods dump twice; in-flight `_log()` lines can be truncated mid-line —
    a missing READY line is the collision, not a mod failure). The parser
    now dedupes multi-boot logs instead of miscounting.
20. **Analysis bugs are caught by re-verification, not shipped.** A
    bool-vs-string comparison briefly suggested "modded sessions wipe
    achievements"; cross-checking against the owner's full console
    timeline (tool → modded session → fetch; all 128 still True) killed
    the wrong conclusion before it reached the docs as fact.
21. **Specs are mined from the owner's words + the vendored mods, not
    guessed.** The right-click ability system mapped to the `special=`
    card field (10 cards), the vanilla caps were found documented verbatim
    in Better Codex's info.lua, and Royal Card Lab / disgraced_justice /
    glacies collection supplied working blueprints for the picker,
    summons, and soul effects. Owner's standing design rule recorded:
    *nothing hardcoded that can't be confirmed — universal, soft-coded,
    adaptable as I play.*
22. **Raw evidence is disposable once distilled.** After every finding
    from runs 1–3 landed in map.md / the draft / PLANNING §0.7 / the
    changelog, the screenshots, logs and save packs were deleted and
    replaced by a single `live testing result/SUMMARY.md` — the repo
    carries knowledge, not baggage.

## 2026-10-04 — Session 7 (Build 5 + map/tooling improvements)

23. **Build 5 is probe-first, not guess-first.** The Phase-2c panel uses only
    live/reference-backed UI and game APIs; uncertain damage multipliers stay
    gated until the new `SKD|` live trace. Offer, card-field, soul/scepter,
    input, and menu behavior are harvested without modifying those systems.
24. **The fake engine now tests behavior, not just load.** `mod_smoketest.py`
    models Lua function types, both `all()` semantics, hook calls, button
    callbacks, cheat actions, and parser handoff (33/33 per `all()` mode on
    default Lua and LuaJIT 2.1). It also intentionally hides `loadfile`,
    matching the live mod sandbox.
25. **`notes/map.md` distinguishes confirmed, reference-derived, owner-reported,
    and still-unknown facts.** It now promotes the best vendor patterns while
    preventing static guesses (e.g. exact scepter semantics / universal hit
    point) from becoming false runtime claims.
26. **Save-codec selftest no longer needs real game files.** Two built-in
    synthetic saves exercise nested tables, empty tables, strings/booleans,
    decimal numbers, and container encode/decode; an optional save directory
    retains the real-file roundtrip check.
27. **The placeholder cover became a project-matched pixel-art asset** (320×180,
    custom crown and shells; no game art copied).
28. **Warning-prefixed game log lines are now tested too.** The parser stripped
    the common `. ` info prefix but missed the actual `!! ` warning prefix; a
    regression case now requires warning-wrapped `SKG|` lines to parse (31/31).

## Improvement ideas parked for later

- In-game UI for save editing (cheat panel covers most of it)
- Auto-update check for game version vs. known map.md version
- A "verify my install" doctor script (folder names, archives, game closed)
- CI-style selftest run before each commit that touches tools/
