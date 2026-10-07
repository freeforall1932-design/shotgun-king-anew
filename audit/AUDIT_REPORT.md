# Shotgun King: Reworked - Repository Audit

## Review target

- Repository: [freeforall1932-design/shotgun-king-anew](https://github.com/freeforall1932-design/shotgun-king-anew)
- Visibility: public
- Branch: `main`
- Reviewed commit: [`192674d0c2e7d2f83f7cca1736f668d09ed195f9`](https://github.com/freeforall1932-design/shotgun-king-anew/commit/192674d0c2e7d2f83f7cca1736f668d09ed195f9)
- Commit date: 2026-10-06
- Review type: static source and repository-policy review

The findings below refer to that pinned revision. The GitHub `main` branch may have moved since this review.

## Executive summary

The highest-risk issue is that a public repository contradicts its own no-game-assets policy: the tracked tree includes an 82,821,343-byte `game/data.sgr`, decoded game source/assets, game DLLs, a log, and a save directory. The `.gitignore` explicitly re-includes `game/**`, while the README says the tracked repository contains no game files and is about 8.5 MB. This review cannot determine the owner's distribution rights; it can prove the content is publicly tracked and that the repository's own policy/docs disagree.

The build script also has a destructive path configuration case: `-Clean` deletes the output directory before checking whether it is the source game directory or overlaps it. The subsequent `robocopy` exit status is not checked, so a failed copy can be followed by mod injection and a success-looking completion message.

Seven findings are documented: three high priority, three medium priority, and one low-priority documentation mismatch. The companion [patch pack](PATCHES.md) contains proposed fixes and a regression checklist. No changes were pushed to the GitHub repository: the provided workspace did not contain its source tree, so the upstream changes are supplied as Markdown patches rather than represented as already applied.

## Findings

### A-01 - Public repository includes game payload and decoded assets

**Priority: High / P1 - contain before further public distribution**

**Evidence**

- GitHub reports the repository as public. The current tree includes [`game/data.sgr`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/game/data.sgr), size 82,821,343 bytes.
- The same tree contains `game/decoded/code.lua` (301,700 bytes), decoded `code/`, `lang/`, `libs/`, `punkcake/`, and `assets/` directories, plus game DLLs, `game/log.txt`, and `game/save/`.
- [`.gitignore`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/.gitignore) first says never commit game assets, then adds `!game/` and `!game/**` to include them.
- The [README](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/README.md) says no game assets are redistributed in the tracked repository and describes the whole repository as approximately 8.5 MB.
- [HANDOFF.md](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/HANDOFF.md) explicitly describes `game/` as the owner's game copy and the decoded source as committed content.

**Impact**

The current public tree makes the game payload and derived files downloadable and makes the repository much larger than the README claims. Logs and saves are also present in that tree. This is a distribution, licensing, privacy, and repository-governance risk; this finding is not a legal opinion and does not assert that any specific permission is absent.

**Fix**

Stop treating the local game copy as a repository fixture. Ignore `/game/`, remove tracked `game/` content, keep only sanitized small test fixtures, correct the README, and remove `game/` from Git history. A normal deletion commit or `.gitignore` change alone does not remove old blobs from history.

**Proof**

See [PROOF_AND_METHOD.md](PROOF_AND_METHOD.md), section "A-01". The pinned GitHub contents API returns the tracked blob size and decoded file list; the repository metadata reports public visibility.

### A-02 - `-Clean` can delete the source game when paths overlap

**Priority: High / P1 - fix before using custom output paths**

**Evidence**

In [`tools/build-dist.ps1`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/build-dist.ps1), the script constructs `$dest` from `-OutDir`, then runs `Remove-Item $dest -Recurse -Force` when `-Clean` is set. There is no source/destination equality or overlap guard before that deletion. The script checks that `$GameDir/data.sgr` exists before the `-Clean` block, but that does not protect the source from being deleted afterward.

**Impact**

If the caller sets `-GameDir` to `...\\ShotgunKing-Modded` and `-OutDir` to its parent, `$dest` equals `$GameDir`. With `-Clean`, the script deletes the source game tree and only then attempts to copy from that path. A destination inside the source can also cause the build to write into the source tree.

**Fix**

Normalize both paths and reject equal, ancestor, or descendant pairs before the `-Clean` block. Include a test that uses a disposable fixture and verifies that the script rejects the configuration before deleting its sentinel `data.sgr`.

**Proof**

The current order is `data.sgr` check -> `$dest` assignment -> optional recursive deletion -> `robocopy`. No containment check is present in that control path. Proposed PowerShell code is in [PATCHES.md](PATCHES.md), patch 1.

### A-03 - `robocopy` failure is not checked

**Priority: High / P1 - failed game copies can look successful**

**Evidence**

The same [`tools/build-dist.ps1`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/build-dist.ps1) runs:

```powershell
robocopy $GameDir $dest /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
```

The script does not capture or validate `$LASTEXITCODE` before it proceeds to create `mods/`, inject mods, write `modlist.lua`, and print `Done`.

**Impact**

Robocopy uses non-zero exit codes for normal successful copy states, but codes 8 and above report copy failures. Ignoring the code can leave a partial game copy and allow the script to continue as if the output is playable. `$ErrorActionPreference = "Stop"` is not a substitute for interpreting robocopy's documented exit codes across supported PowerShell versions.

**Fix**

Capture `$LASTEXITCODE` immediately after `robocopy`; accept 0-7 and throw on 8 or higher. Do not inject mods or write the play instructions after a failed copy.

**Proof**

The source call is followed by `$modsRoot` setup without a native exit-code check. Patch 1 in [PATCHES.md](PATCHES.md) adds the check.

### A-04 - Smoke test returns success when Lua dependency is missing

**Priority: Medium / P2 - false-green test result**

**Evidence**

In [`tools/mod_smoketest.py`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/mod_smoketest.py), `main()` catches `ImportError` for `lupa`, prints that the parser self-test still runs, prints a command for the user, and returns `0`. That branch does not invoke `parse_log.py` or another test process.

**Impact**

A CI job or developer machine without `lupa` can report a successful process exit even though none of the Lua smoke scenarios ran and the claimed parser self-test was not executed. This makes a skipped check indistinguishable from a passing check.

**Fix**

Run the parser self-test in that branch, propagate its failure, and return a distinct non-zero skip code (for example, 2) when the parser passes but the Lua smoke test is skipped. Alternatively, use a test runner that reports an explicit skipped test.

**Proof**

The `ImportError` branch terminates directly with `return 0`; the parser command appears only as printed text. Patch 2 in [PATCHES.md](PATCHES.md) makes the branch execute the parser and identify the skip.

### A-05 - `--restore --dry-run` still restores and overwrites the save

**Priority: Medium / P2 - destructive CLI flag interaction**

**Evidence**

In [`tools/make_100pct_save.py`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/make_100pct_save.py), `main()` handles `--restore` before it assigns `dry = "--dry-run" in argv`. The restore branch unconditionally removes the current `save/` directory with `shutil.rmtree()` and copies the backup into place.

**Impact**

Passing `--dry-run` alongside `--restore` does not protect the current save. The tool accepts both flags and silently performs the destructive restore.

**Fix**

Compute `dry` before the restore branch. When both flags are supplied, print which backup would be restored and return before `rmtree` or `copytree`.

**Proof**

The restore branch returns before the current dry-run assignment and contains unconditional filesystem writes. Patch 3 in [PATCHES.md](PATCHES.md) adds a no-write restore preview.

### A-06 - `-GetInsights` can report success for an invalid path and mix old evidence into a new pack

**Priority: Medium / P2 - unreliable diagnostics snapshot**

**Evidence**

In [`tools/apply.ps1`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/apply.ps1), the `-GetInsights` branch does not validate that `$GameDir` exists or require `log.txt`. Missing files are printed as `skip`, then the branch exits `0`. It also copies into the existing `uploads/game-insights/` directory without removing files that disappeared from the source.

**Impact**

A typo in `-GameDir` can produce an empty pack with a success exit code. On a later collection, a deleted save or missing modlist can leave an older copy in the destination, so the pack can combine files from different runs.

**Fix**

Require an existing game directory and current `log.txt`. Build each collection into a unique staging directory, then replace the previous pack only after all copy operations succeed. Keep `modlist.lua` and `save/` optional if the game has not generated them, but never retain their previous snapshot's versions.

**Proof**

The current branch skips absent source files, writes into the persistent destination, and exits `0`; there is no cleanup or staging step. Patch 4 in [PATCHES.md](PATCHES.md) shows a transactional snapshot replacement.

### A-07 - Generated `PLAY-THIS.txt` describes Build 9 as an obsolete debug stub

**Priority: Low / P3 - user-facing status mismatch**

**Evidence**

The `$readme` here-string in [`tools/build-dist.ps1`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/build-dist.ps1) says `sk-rework` is "currently a debug stub" and "changes no gameplay." The current [README](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/README.md) and [`modded/sk-rework/info.lua`](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/modded/sk-rework/info.lua) describe Build 9 controls that mutate game state, and identify live validation as pending.

**Impact**

The generated instructions are stale and understate what the panel can change. They also obscure the important distinction between sandbox-tested and game-live-tested behavior.

**Fix**

Update the generated text to name Build 9, disclose the mutating development controls, and state that live-game validation remains pending. Patch 6 in [PATCHES.md](PATCHES.md) provides replacement copy.

**Proof**

Compare the literal generated text in `build-dist.ps1` with the current Build 9 `info.lua` description and the README's readiness table.

## Recommended order

1. Remove the game payload and decoded assets from the public repository and its Git history; update the README and `.gitignore`.
2. Add the build source/output overlap guard before `-Clean` can run.
3. Check robocopy's exit code and abort on codes 8 and above.
4. Fix the save restore dry-run and smoke-test skip semantics.
5. Make `-GetInsights` validate and replace a snapshot transactionally.
6. Refresh the generated `PLAY-THIS.txt` status text.

## Verification boundary

This is a static audit of a pinned public GitHub source tree. The GitHub repo was not cloned into the provided workspace. I did not run the PowerShell scripts, install `lupa`, execute the remote Python test suite, launch Shotgun King, or validate the mod in-game. The findings above are demonstrated by the source control flow and repository tree, not by a claim that the proposed patches have already passed a live run. See [PROOF_AND_METHOD.md](PROOF_AND_METHOD.md) for reproducible checks and limits.