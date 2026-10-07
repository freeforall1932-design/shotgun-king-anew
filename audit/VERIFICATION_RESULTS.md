# Audit Finding Verification — Current Checkout

- **Reviewed:** 2026-10-07 (UTC)
- **Repository:** `freeforall1932-design/shotgun-king-anew`
- **Working branch:** `arena/51c078d1-shotgun-king-anew`
- **Verified revision:** `a0b09e410ecce315ca08659a0980828a9330d449`

## Scope and result

I read both supplied audit pages, then cross-checked their findings against the local `audit/` reports, proof notes, patch proposals, and the source in this checkout. The two reports contain **14 distinct topics** after treating A-03 and SEC-01 as overlapping Robocopy findings.

The first page pins its review to `192674d0c2e7d2f83f7cca1736f668d09ed195f9`, but that commit is not in this checkout's Git object database. The current public `main` resolves to `a0b09e410ecce315ca08659a0980828a9330d449`, matching the revision reviewed here. Accordingly, verdicts below describe the **current checkout**, not a re-verification of the older pinned tree. The first site's advertised `/audit/*.md` download links returned “Not found”; the matching local audit files were available and read.

**Baseline note:** the finding verdicts below describe the checkout at `a0b09e4` before this turn's fixes. After the user explicitly asked to apply correct fixes, the supported items listed in the final sections were implemented in the working tree; runtime limits and remaining checks are recorded separately.

**Bottom line:** several operational findings were confirmed, two claims were false or stale in the baseline source, and several others needed narrower wording. The second page's “all 8 verified & patched” headline did not describe the baseline checkout. Its patch files were reviewed as proposals; only the independently verified fixes were applied.

## Findings

### First report: A-01 through A-07

#### A-01 — Public repository tracks game payload and decoded files
**Verdict: CONFIRMED (repository-policy / exposure risk; not a legal conclusion).**

GitHub reports the repository as public (`isPrivate: false`). The current tree tracks 368 paths under `game/`, including `game/data.sgr` (82,821,343 bytes), `game/decoded/code.lua` (301,700 bytes), `game/log.txt`, and save files. `.gitignore:23–29` explicitly re-includes `game/` after the earlier ignore rules. This conflicts with `README.md:111–114` (“~8.5 MB, no game files inside”) and `README.md:232–234` (“no game assets are redistributed in the tracked repository”). The finding establishes a public-tree/documentation mismatch and potential distribution/privacy risk; it does **not** establish whether distribution is authorized. I checked tracked names and sizes, not the contents of logs or saves. `HANDOFF.md` records an explicit owner decision to retain `game/`, so I did not remove it or rewrite history; that needs an owner decision.

#### A-02 — `-Clean` can delete the source game on overlapping paths
**Verdict: CONFIRMED by static control-flow review.**

`tools/build-dist.ps1:102–107` builds `$dest` from `-OutDir` and recursively removes it for `-Clean` without first normalizing or checking overlap with `$GameDir`. Since `$OutDir` is caller-controlled, `$dest` can equal the source game directory (or overlap it). The earlier `data.sgr` check did not protect the source from the later deletion. **Applied fix:** `build-dist.ps1` now normalizes the source and destination and rejects equal/ancestor/descendant paths before `-Clean` can delete anything. This is a lexical guard only; junction/reparse-point targets are not resolved. PowerShell is unavailable here, so Windows path fixtures remain pending.

#### A-03 — Robocopy failure is not checked
**Verdict: CONFIRMED; overlaps SEC-01.**

`tools/build-dist.ps1:107` invokes Robocopy and discards its output. There is no immediate capture or interpretation of `$LASTEXITCODE` before the script proceeds to mod injection and eventually prints `Done` (`:109–197`, `:351`). A failed copy could therefore leave a partial output and continue. **Applied fix:** the script immediately captures `$LASTEXITCODE`, temporarily disables `PSNativeCommandUseErrorActionPreference` when available, accepts 0–7, and throws on 8+. No Windows/Robocopy runtime test was possible; test both preference settings on Windows.

The related SEC-01 report overstates the specific PowerShell failure mechanism: this script sets `$ErrorActionPreference = "Stop"`, but does not set or normalize `$PSNativeCommandUseErrorActionPreference`; without a PowerShell runtime/configuration test, the claim that a successful Robocopy code of 1 necessarily terminates this script is not established. The separate claim that Robocopy's `$LASTEXITCODE` “bleeds” into the step-4 Python check is contradicted by the code: Python is invoked at `:295`, immediately before the `$LASTEXITCODE` test at `:296`, so that test sees Python's result when Python ran. These qualifications do not remove the underlying missing Robocopy-status check in A-03.

#### A-04 — Missing Lupa is reported as a successful smoke test
**Verdict: CONFIRMED and reproduced.**

`tools/mod_smoketest.py:1099–1107` catches `ImportError`, prints a parser-selftest command, then returns `0`; it never launches that command. In this environment Lupa is absent: `python3 tools/mod_smoketest.py` exited **0** while reporting that the Lua smoke test was skipped. Running the printed command separately, `python3 tools/parse_log.py --selftest`, passed **49/49**. Thus the parser test was healthy, but the smoke-test command gave a green exit without running either test in its missing-Lupa branch. **Applied fix:** missing Lupa now runs the parser selftest, prints `SKIPPED`, and exits 2 (documented in `tools/mod-dev.md`). Regression tests force both missing and present paths: skip status 2 with parser checks, and the full Lua scenarios when Lupa is installed.

#### A-05 — `--restore --dry-run` still overwrites the save
**Verdict: CONFIRMED and reproduced; the report's stated ordering is stale.**

The current file computes `dry` at `tools/make_100pct_save.py:97`, *before* the restore branch (`:99–110`), contrary to the audit's explanation. However, the restore branch never checks `dry`: it unconditionally removes `save/` and copies the backup. In a temporary fixture, the baseline `--restore --dry-run` exited **0**, removed the current-save sentinel, and copied the backup into `save/`. The root cause was the missing dry-run guard inside the restore branch, not the order in which `dry` is assigned. **Applied fix:** restore now prints a preview and returns before filesystem writes; regression tests compare the complete current/backup fixture hashes before and after.

#### A-06 — `-GetInsights` can succeed on a bad path and preserve stale files
**Verdict: CONFIRMED by static control-flow review.**

For a non-empty but nonexistent `-GameDir`, `Resolve-GameDir` returns the path (`tools/apply.ps1:52–68`); the `-GetInsights` branch does not validate it before creating the destination. Missing source files are printed as skips and the branch exits 0 (`:86–116`). It also copies into the persistent `uploads/game-insights/` directory without clearing or staging it, so source files omitted on a later collection can remain from an earlier one. **Applied fix:** `-GetInsights` now validates the source folder and required `log.txt`, copies into a fresh stage, and replaces the old pack only after collection succeeds; a failed stage-to-destination move attempts to restore the old snapshot. PowerShell is unavailable here, so missing-path, stale-file, copy-failure, and rollback cases still require Windows tests.

#### A-07 — Generated `PLAY-THIS.txt` describes an obsolete debug stub
**Verdict: CONFIRMED by text/source comparison.**

The generated text in `tools/build-dist.ps1:329–331` calls `sk-rework` a debug stub that “changes no gameplay.” Current `modded/sk-rework/info.lua` and `README.md:12–20, 61–71` describe Build 9's game-state controls and explicitly distinguish sandbox tests from pending live validation. The generated instructions were stale. **Applied fix:** the `PLAY-THIS.txt` template now describes Build 9's SK DEV game-state controls and distinguishes completed sandbox tests from pending live-game validation. The Windows build script was not run here.

### Second report: SEC-01 through SEC-08

#### SEC-01 — Robocopy bitmask trapped by PowerShell
**Verdict: PARTLY CONFIRMED; duplicate of A-03, with unsupported details.**

The missing status check is confirmed under A-03. The stronger assertion that `$ErrorActionPreference = "Stop"` alone necessarily turns a successful Robocopy code into a terminating error is not established by this script; its native-command preference is not configured here. The claimed stale-code bleed into the later Python check is contradicted by the direct Python invocation immediately before that check. PowerShell was unavailable, so no version-specific behavior was exercised.

#### SEC-02 — `mod.loaded` is undefined, forcing “Save and Reboot” on clean boot
**Verdict: NOT CONFIRMED; contradicted by the decoded engine source.**

The audit stops before the relevant assignment. `game/decoded/code/mods.lua:655–725` sets `mod.loaded = true` for each active mod in `run_mods()` (line 723). Inactive mods have no true `loaded` value, which is equivalent to false in the expression used by `modlist_changed()` at `modded/sk-rework/script.lua:1201–1209`. This matches `mod.active` for a normally completed boot; the “field is never set” proof is incorrect for this tree.

#### SEC-03 — God Mode dodge fallback mutates the board grid
**Verdict: PARTLY CONFIRMED; unsafe fallback exists, but the report overstates when it runs.**

The fallback at `modded/sk-rework/script.lua:412–415` writes `px/py` through `hero.sq`, which is a reference to a board square. The engine uses those coordinates for grid lookup (`game/decoded/code.lua:4161–4179`), so if that fallback runs it changes the square object rather than relocating the King. The current dodge code first tries `goto_sq(hero.sq, sq)` and then `goto_sq(hero, sq)` (`script.lua:404–410`). The engine signature is `goto_sq(e, sq, ...)` (`code.lua:5824`), and its normal movement path updates the square pointer (`:5837–5842`); therefore the second attempt is correctly ordered and should bypass the fallback when it succeeds. The fallback is nevertheless reachable if both calls are blocked or do not move the King; for example, `ecall()` returns without calling the engine when SAFE mode's budget is exhausted (`script.lua:264–280`).

The audited proof also names the square occupancy field `piece`; this engine uses `.p` (`code.lua:5840–5842, 5933–5945`). **Applied fix:** `dodge_king()` now calls only the verified `goto_sq(hero, sq)` API and reports success only when `hero.sq` is the target and `sq.p == hero`; the coordinate fallback is removed. The fake engine models square-pointer/occupancy updates and verifies that a SAFE-blocked dodge leaves board coordinates/occupants unchanged; the smoke suite passes 68/68 in all four default/LuaJIT and `all()`-semantics variants. Live-game validation remains pending.

#### SEC-04 — Flat workshop ZIPs cause staging-root self-move/file-lock failures
**Verdict: NOT SUBSTANTIATED by the current source.**

A flat ZIP can make `$info.Directory.FullName` equal `$stage` (`tools/build-dist.ps1:137–155`; similarly `tools/install-mods.ps1:70–103`). The script then moves that staging directory to a different destination under `mods/<name>`; it does not move the directory onto itself. The later cleanup targets the old staging path and suppresses missing-path errors. The install script likewise moves the extracted folder out of its temp tree before cleaning the temp root. I found no source-level self-move or open-handle cycle that proves a lockout. Windows execution is still needed to rule out platform-specific behavior, but the stated failure is not verified.

#### SEC-05 — Filtering the card list leaves the page index out of range
**Verdict: NOT PRESENT in the current checkout (already handled in source).**

The current filter toggle explicitly sets `card_page = 1` (`modded/sk-rework/script.lua:867–872`), and the list builder clamps the page to the available range (`:847–849`). The current page size is 15 (`:769`), unlike the audit's 8-item calculation. The finding may refer to an older revision, but it does not describe the checked revision.

#### SEC-06 — `save_codec.py --pack` accepts invalid PUNKCAKE text
**Verdict: CONFIRMED and reproduced.**

Before the fix, the `--pack` branch read text and passed it straight to `encode_text()`; a temporary invalid input exited **0** and wrote a container. **Applied fix:** `--pack` now calls `parse()` before opening the destination and returns 1 with a concise error on invalid input. The parser now requires a root table and rejects unmatched closing braces and entries outside the root. Regression tests verify malformed inputs and prove a pre-existing destination remains byte-identical; `save_codec.py --selftest game/save` passes 12/12 checks.

#### SEC-07 — Dictionary-shaped `prog["endless"]` can crash the unlock tool
**Verdict: CONDITIONAL finding confirmed; the current tracked save does not trigger it.**

At baseline, `make_100pct_save.py` indexed `prog.get("endless", ...)[1]` without checking its type. A dictionary raised `KeyError: 1`; the checked-in `game/save/prog.sav` instead stores the verified scalar tuple `('n', '7')`. **Applied fix:** the tool accepts that numeric-scalar shape (and the existing missing-key default), but rejects unsupported/invalid shapes before backup or save writes rather than guessing nested fields. Temporary fixtures confirm both the supported scalar dry-run and fail-closed behavior with unchanged save hashes.

#### SEC-08 — Right-click ability cap removal is missing
**Verdict: ABSENT as claimed, but it is a documented queued feature rather than an unacknowledged regression.**

The current `is_card_available` hook is an `append` observer that only logs fields (`modded/sk-rework/script.lua:1530–1574`); it does not change card availability. `PLANNING.md:45–73` specifies the feature, while `README.md:71` and `:219–222` mark it queued pending live data. The implementation gap is real, but the project already documents it as unfinished. The proposed override is not applied or runtime-validated.

## Review of proposed fixes (reviewed; applied selectively)

The audit folder does include implementation guides, so I reviewed the unique proposals before putting follow-ups on `WORKLIST.md`. The individual `sec-*` diffs, `PATCH_ALL_UNIFIED.diff`, and the complete bundle duplicate much of the same code; applying them wholesale would be unsafe.

- **`audit/PATCHES.md`, patches 1–4 and 6:** The path-overlap guard, explicit Robocopy result check, missing-Lupa skip status, restore dry-run guard, staged Insights refresh, and updated play text were sound directions and have now been implemented selectively. Python regressions cover the Lupa-present/absent branches and restore no-write behavior. PowerShell runtime tests remain outstanding. The path helper is lexical and does not resolve junctions. The Robocopy code temporarily disables PowerShell's native-command error preference when available, then interprets 0–7 versus 8+; the shorter variants did not. For restore, `dry` was already assigned before the branch—the needed change was the missing `if ($dry)` guard. The Insights staging/swap/rollback logic still needs Windows failure-path tests.
- **`PATCHES.md` patch 5 (game/history cleanup):** Do not apply without explicit owner approval. It removes tracked game files and proposes a force mirror push/history rewrite, while `HANDOFF.md` explicitly says not to remove `game/` without an owner instruction.
- **`PATCH_BUILD_DIST.md` / the unified diff:** The short Robocopy patch does not account for native-command error preference being enabled. The SEC-04 workaround is unnecessary based on the source review; moreover, `Copy-Item -LiteralPath` with a `*` path does not expand the wildcard, so that hunk is not safe to apply as written.
- **`PATCH_SCRIPT_LUA.md` / SEC-02, SEC-03, SEC-05, SEC-08 diffs:** SEC-02 is based on a false premise (`mod.loaded` is set by the engine), and its snapshot loop also breaks when it finds `SK Rework`, leaving later mods unsnapshotted. SEC-03's proposed fallback writes `.piece`, but the engine uses `.p`; that hunk was rejected in favor of the verified `goto_sq(hero, sq)` call with no direct coordinate mutation, now covered by the smoke harness. SEC-05 was already implemented in the baseline. SEC-08's proposed `prepend` callback returns `true`, but the engine wrapper discards prepend return values and then calls the original function; it would not bypass availability. Its broad `ca.special` condition is also not a demonstrated ability classifier.
- **`PATCH_SAVE_TOOLS.md` / SEC-06 and SEC-07:** The SEC-06 direction was adopted only after adding the missing-root invariant and malformed-input tests; the destination is now validated before it is opened. The SEC-07 nested `lvl`/`floor` guess was rejected; the tool now supports the verified scalar and fails before writes on unknown shapes.
- **First-report patches 2, 3, 4, and 6:** The Lupa-missing path now documents exit code 2 as skip and runs the parser test; restore dry-run now guards its writes; Insights staging was implemented but still needs Windows failure-path tests; and the Build 9 play text was refreshed.

**Disposition:** I reviewed the existing patch guides before editing, applied only fixes whose behavior was supported by current code/engine evidence, and rejected the flawed/stale proposals. The remaining platform checks are tracked in `WORKLIST.md`. The owner has since approved removing `game/` from the current tree; the PR/merge and any history rewrite are tracked separately. The unified patch bundle was not applied.

## Checks run and limits

- `gh repo view ... --json nameWithOwner,isPrivate,defaultBranchRef,url`: repository is public.
- `git ls-remote origin refs/heads/main`: current remote `main` is `a0b09e410ecce315ca08659a0980828a9330d449`.
- `PYTHONPATH=/tmp/sk-audit-lupa python3 tools/mod_smoketest.py`: **68/68 passed in each of four variants** (default Lua and LuaJIT 2.1, each with both `all()` semantics). Lupa 2.8 was installed only under `/tmp` for verification; it is not a repository runtime dependency.
- `python3 -S tools/mod_smoketest.py`: missing-Lupa path reports `SKIPPED`, runs `parse_log.py --selftest`, and returns documented status **2**.
- `PYTHONPATH=/tmp/sk-audit-lupa python3 -m unittest discover -s tests -v`: **7/7 passed**, including present/missing Lupa, temporary restore/schema fixtures, and invalid-pack output preservation.
- `python3 tools/parse_log.py --selftest`: **49/49 passed**.
- Before the later owner-approved removal of `game/`, `python3 tools/save_codec.py --selftest game/save` passed **12/12** (synthetic saves, malformed syntax, and tracked game-save text roundtrips; no save files were modified).
- Python byte-compilation passed for the edited Python files and regression tests.
- Temporary-only fixtures reproduced and then guarded the restore dry-run overwrite, invalid `--pack`, and unsupported `endless` schema cases. Tests did not modify tracked game saves.
- No `pwsh`/`powershell` executable, Windows Robocopy run, or live game runtime was available. PowerShell changes are source-reviewed but not executed; `-GetInsights` copy/swap rollback and path overlap still need Windows tests. The Lua smoke fake is not a substitute for Build 9 live-game validation.

## Action taken

Applied the reviewed fixes in `tools/build-dist.ps1`, `tools/apply.ps1`, `tools/mod_smoketest.py`, `tools/make_100pct_save.py`, `tools/save_codec.py`, and `modded/sk-rework/script.lua`; added Python regression coverage under `tests/`; refreshed `tools/mod-dev.md`, the generated `PLAY-THIS.txt` template, `WORKLIST.md`, and this report.

## Follow-up: owner-approved current-tree removal (2026-10-07)

The owner subsequently superseded the earlier `HANDOFF.md` instruction to retain `game/` and explicitly approved removing it from the current branch tree. The 368 tracked paths (about 115 MB) were removed from this working tree, `/game/` was added to `.gitignore`, and README/HANDOFF/WORKLIST/changelog wording was updated. The owner says another copy remains available outside this branch.

This is not a Git-history rewrite: commits before the removal still contain the game blobs. The session branch is fixed; `main` will lose the current `game/` tree only after the cleanup PR is merged. A history scrub (needed to reclaim clone/history storage) remains separate and was not performed.

Post-removal checks: `git ls-files game` reports zero indexed paths; the worktree has no `game/` directory; and `.gitignore` matches a root-level `game/` probe. The regression suite passed **7/7**; Lua smoke passed **68/68** in all four Lua/`all()` variants; parser passed **49/49**; and `save_codec.py --selftest` without deleted game saves passed **6/6**. The missing-Lupa branch produced the documented skip and exit status **2**; Python compilation and whitespace checks passed. A post-removal attempt to run `mode_guns_check.py` cannot pass because its required source `game/decoded/code/modes/throne.lua` was intentionally removed; the recorded **37/37** run was completed before the removal. Windows/PowerShell-only tests remain unavailable.
