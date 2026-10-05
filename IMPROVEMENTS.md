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

## 2026-10-04 — Session 8 (run 4 absorbed; the crash that taught the rule)

29. **A crash became the best documentation in the repo.** Build 5 died at boot
    (`btn("left")` → fatal engine error), but the load-time harvest had already
    completed: all 186 cards field-by-field, 14 piece schemas, 25 offer
    candidates, the 63-name live API surface (including the entire soul/scepter
    family nobody was sure existed), and the input dump. The fix and the
    promotion happened in the same session as the failure — no round trip
    wasted.
30. **"Nothing hardcoded that can't be confirmed" became a mechanical rule.**
    The owner's design principle turned into a concrete safety contract in the
    code (a comment block naming the fatal path), in map.md (a 🛑 section with
    the exact error text), in mod-dev.md, and in HANDOFF — because the failure
    mode is un-`pcall`-able and costs a live run every time it is forgotten.
31. **The fake engine now fails like the real one — the test that should have
    caught this.** `mod_smoketest.py` used to return `false` for any `btn()`
    call, so 33/33 passed while the game quit. It now raises on unconfirmed ids,
    logs the engine's own `!!` messages, and self-checks that `btn("left")`
    still raises. Re-injecting the run-4 bug produces the exact live error
    string — the regression is proven by construction, not by assertion.
32. **Crashed logs now parse *and* say they crashed.** `parse_log.py` gained
    crash detection: `ERR` message, the tab-indented traceback, `Quitting
    required`, and a highlight of the frame inside a mod — so a draft generated
    from a dead run can never again look like a successful harvest (that
    mistake was made once, by hand, when reading run 4).
33. **Probe chains are checkpointed and ordered safe-first.** The blocks now
    run cards → exclude → souls → bank → input, each ending with
    `SKA2|probe|<name>=done`. When the next failure happens, the log itself
    pinpoints the block and the draft lists exactly which blocks completed.
    Run 4 lost the bank/input data purely because nothing marked the boundary.
34. **The owner's wording note was treated as a bug, not a style nit.** "It
    should simply point to the play button" — every mention of the mod-menu
    location in README/INSTALL/HANDOFF/map/mod-dev now says *click Play*, with
    no title-screen or main-menu contrast anywhere.

## 2026-10-05 — Session 9 (run 5 absorbed; the bugs the playtest found; Build 7)

35. **A 22-minute playtest is worth more than ten boot tests.** Run 4 proved a
    build could boot; run 5 proved what a build *does*: every probe block ran,
    the panel rendered, all four cheats fired, 30 shots traced, souls/scepters
    flowed, the bank got written — and, crucially, the owner's hands found three
    bugs no sandbox could: a panel that would not close, a legend that could
    never attach, and a spawn that only ever made pawns in the king's way.
    The cheap lesson: harvest at boot, judge in play.
36. **The log answered its own questions and the tests lied about one.**
    `ev_hit` was registered as a global and hooked for damage work — the run
    showed it never fires on the bullet route (`mk_bullet` → `bullet.dmg` →
    `hit` → `fx_dmg`). A name existing in `gimme("global")` is not evidence that
    a code path uses it; only a trace line is.
37. **`del(ents, e)` is not a UI API.** The panel's "close" deleted its own
    button entities, so the mod's state said closed while the engine kept
    drawing the buttons — the owner's frozen-brown-button report. The fix was
    sitting in the vendored mods all along (`remove_buts()`, used by
    disgraced_justice and glac terminal): when two independent sources in the
    repo already solve a problem, check them before inventing a third way.
38. **A find-predicate that cannot match is worse than none.** The legend
    attach compared MODLIST *titles* against menu *ids* (`play`, `mods`,
    `save_back`…), so it silently did nothing every run. Build 7 now logs the
    attach attempt and its entry id, and the parser looks for the marker — a
    no-op feature must be visible as a no-op in evidence.
39. **Engine-call intent logging turns any crash into a one-run fix.**
    `SKE|call|<name>=start` before every mutating call, `=ok` after: if the game
    dies, the last dangling `=start` names the control, and the parser prints
    "that control is the crash suspect". Combined with `SAFE:on` (one mutating
    call per boot), a bad guess now costs a click instead of a run — the run-4
    lesson turned into a mechanism instead of a rule to remember.
40. **Guesses are allowed, blind guesses are not.** Three signatures are still
    unknown (`goto_sq` argument order, `get_nearest_free_square`, the
    `stack.chamber_max`/`ammo_max` fields). Each is marked GUESS in the source,
    called through a wrapper that validates the result and falls back, and logs
    which route worked — so the next live pass replaces a guess with a fact
    without a crash.
41. **Test fidelity is a moving target.** The fake engine kept ONE handler per
    hook target, so Build 7's second `mk_bullet` append was silently dropped
    (36→45 checks still passed). It now chains ordered hook lists like the real
    engine, and the harness models the new engine surface (`remove_buts`,
    `goto_sq`, `flr`, `mk_bullet`) — every time the mod grows a hook on a live
    function, the fake must grow the same contract or the tests quietly diverge.
42. **The owner's questions got designed answers, not deferrals.** "Is +3 ammo
    a slot or regeneration?" → the panel now has both (reserve + RELOAD + CLIP+).
    "Card from pieces, can you summon, give me a list or a fair roll?" → card
    pages with AUTO/LIST, a uniform roll over the eligible pool, and a
    piece/summon filter (FILT:PIECE). "God mode should dodge like mist instead
    of being invulnerable" → the lethal-hit dodge with a logged route.
43. **Safety guards should fail closed, visibly.** While a level-up/offer
    screen is open, the panel refuses to clear the button layer (clearing would
    delete the engine's own card buttons) and logs
    `SKUI|panel|deferred=offer_active`. A guard that silently does nothing is
    indistinguishable from a bug; a guard that logs is a diagnosis.

## Improvement ideas parked for later

- In-game UI for save editing (cheat panel covers most of it)
- Auto-update check for game version vs. known map.md version
- A "verify my install" doctor script (folder names, archives, game closed)
- CI-style selftest run before each commit that touches tools/
- Timeline scrub for the card LIST page (currently PREV/NEXT only)
- A balance-config panel page once the damage/crit knobs are live-verified
- Free tile placement for the spawn picker (click a square) — blocked on the
  `get_free_squares` signature being confirmed
