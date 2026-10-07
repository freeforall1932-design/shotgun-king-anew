# Audit Method and Proof Notes

## Snapshot and source

The review is pinned to commit [`192674d0c2e7d2f83f7cca1736f668d09ed195f9`](https://github.com/freeforall1932-design/shotgun-king-anew/commit/192674d0c2e7d2f83f7cca1736f668d09ed195f9), resolved from the repository's `main` branch. Pinning the commit prevents later `main` updates from silently changing what a finding refers to.

The remote repository is publicly visible. The files inspected include [README.md](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/README.md), [INSTALL.md](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/INSTALL.md), [.gitignore](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/.gitignore), [tools/build-dist.ps1](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/build-dist.ps1), [tools/apply.ps1](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/apply.ps1), [tools/mod_smoketest.py](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/mod_smoketest.py), [tools/make_100pct_save.py](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/tools/make_100pct_save.py), and [modded/sk-rework/info.lua](https://github.com/freeforall1932-design/shotgun-king-anew/blob/192674d0c2e7d2f83f7cca1736f668d09ed195f9/modded/sk-rework/info.lua).

## How the findings were found

1. Resolved `main` to a specific commit using the GitHub repository API and recorded that SHA in the report.
2. Read the README and install guide to identify promises about privacy, copy safety, build behavior, test status, and output artifacts.
3. Checked the pinned repository tree and file metadata against those promises. This exposed that `game/` is both tracked and explicitly re-included by `.gitignore`.
4. Followed write/destructive paths in the PowerShell and Python scripts, rather than relying on comments: where paths are computed, when `Remove-Item` or `shutil.rmtree` runs, how native return values are handled, and when branches return success.
5. Compared generated `PLAY-THIS.txt` text in the build script with the current Build 9 description and status in the repository's README and `info.lua`.
6. For each issue, wrote an observable regression condition and a minimal fix in [PATCHES.md](PATCHES.md).

## Static evidence by finding

### A-01 - Public game payload

- The GitHub repository metadata says `visibility: public` and `default_branch: main`.
- The pinned [`game/data.sgr` contents API response](https://api.github.com/repos/freeforall1932-design/shotgun-king-anew/contents/game/data.sgr?ref=192674d0c2e7d2f83f7cca1736f668d09ed195f9) reports an 82,821,343-byte tracked blob.
- The pinned [`game/decoded/` contents API response](https://api.github.com/repos/freeforall1932-design/shotgun-king-anew/contents/game/decoded?ref=192674d0c2e7d2f83f7cca1736f668d09ed195f9) lists `code.lua`, decoded code, language, libraries, assets, and other data directories. The `code.lua` blob is 301,700 bytes.
- The pinned [game directory listing](https://api.github.com/repos/freeforall1932-design/shotgun-king-anew/contents/game?ref=192674d0c2e7d2f83f7cca1736f668d09ed195f9) includes game DLLs, `log.txt`, `save/`, and `settings.txt` in addition to `data.sgr`.
- The `.gitignore` exception negates earlier binary-ignore patterns with `!game/` and `!game/**`.
- The README simultaneously says the tracked repository has no game files and estimates a whole-repository download of about 8.5 MB.

These are direct tree and metadata checks; no game binary was downloaded as part of this audit.

### A-02 - Destructive output overlap

The build script checks for `data.sgr`, assigns `$dest = Join-Path $OutDir "ShotgunKing-Modded"`, and then conditionally runs `Remove-Item $dest -Recurse -Force`. There is no normalized path equality/containment check between `$GameDir` and `$dest` first. Thus when `$dest` is the game folder, `-Clean` deletes the directory that just passed the `data.sgr` validation.

**Safe reproduction**

Use only a disposable fixture, never a real game installation. Create a fixture directory with `data.sgr`, arrange `-OutDir` so its `ShotgunKing-Modded` child is exactly that fixture directory, and invoke the builder with `-Clean`. The existing code reaches the recursive delete; the patched code must reject the overlap before deletion. The full command depends on the local repository path and should only be run in a disposable Windows test directory.

### A-03 - Robocopy exit status ignored

The builder pipes Robocopy output to `Out-Null` and then immediately starts mod-folder operations. It never stores `$LASTEXITCODE` or branches on it. Microsoft documents that Robocopy values 0-7 are non-failure statuses and any value 8 or greater means at least one copy failure: [Robocopy exit codes](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy#exit-return-codes). PowerShell stores native exit codes in `$LASTEXITCODE`: [about_Error_Handling](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_error_handling).

This finding is proved by the missing control-flow check, not by claiming that a failed Robocopy run was executed here.

### A-04 - Missing Lupa returns a false-green status

The smoke test's `except ImportError` branch prints a parser self-test command but ends by returning `0`. It does not invoke `parse_log.py`, and it does not run the Lua scenario. Since the module is optional, this is the normal path in any environment without `lupa`.

**Safe reproduction**

In a clean Python environment where `import lupa` fails, run `python tools/mod_smoketest.py`. The current branch exits 0 after printing the instruction. The patch executes the parser self-test and returns 2 to identify the Lua checks as skipped.

### A-05 - Restore ignores dry-run

In `make_100pct_save.py`, argument handling enters `if "--restore" in argv` before assigning the `dry` flag. The restore branch then executes `shutil.rmtree(dst)` and `shutil.copytree(src, dst)` without a dry-run guard.

**Safe reproduction**

Use a temporary fixture with a `save_backup_test/` directory and a `save/` directory containing a sentinel file. Run the tool with both `--restore --dry-run`; compare the current save tree before and after. The current implementation writes; the proposed implementation must leave the sentinel byte-identical.

### A-06 - Insights can be empty-success or stale

The `-GetInsights` branch in `apply.ps1` checks each source file with `Test-Path`, prints `skip` for missing files, copies any present files directly into the long-lived output folder, and finally exits 0. It never first validates the directory/log and never clears or stages the destination. This proves both failure modes by control flow:

- A nonexistent game path makes each source check false and reaches `exit 0`.
- A file from a prior snapshot remains in `uploads/game-insights/` if the corresponding source file is absent in the next run.

**Safe reproduction**

Use a temporary repo copy and disposable game folders. First pass an invalid folder and verify the current script's exit status. Then capture a first pack containing `save/old.sav`, remove `old.sav` from the source, and capture again. The current implementation can leave the old destination file; the staging patch must replace the pack without it.

### A-07 - Generated instructions are stale

The generated `$readme` here-string says the mod is a debug stub and does not change gameplay. The current Build 9 `info.lua` describes an overlay panel with ammo, reload, clip, card, spawn, God Mode, damage, and crit controls, and the README says live validation is still pending. This is a direct text mismatch; no runtime behavior needs to be inferred.

## What has and has not been executed

**Static checks completed:** pinned current commit; inspected current public repository metadata/tree; read the cited docs and source paths; traced the affected branches; compared the generated status text with Build 9 documentation.

**Not executed:** a local clone of the target repository; PowerShell parse or runtime tests; Python tests from the target repository; Lupa smoke tests; game launch or live mod playtest; proposed code patches.

The provided local workspace contains only a React/Vite starter app, not the GitHub repository. The downloadable fixes are therefore proposals, not an upstream commit or a claim of passing Windows/game tests. The Vite build verifies the audit viewer only.

## Post-patch evidence to collect

- Save the output of each Windows regression in [PATCHES.md](PATCHES.md).
- Attach the Robocopy code observed in the forced-failure test and show that no `Done` message was printed.
- Record the smoke test's exit 2 when `lupa` is absent, and the parser self-test's output.
- Hash the before/after save fixture for the restore dry-run test.
- Compare the manifest of the insight staging directory with the prior pack, proving deleted files do not persist.
- After repository history cleanup, run `git rev-list --objects --all` and verify no `game/` paths remain in reachable refs. Check GitHub's public tree again after the owner-approved force push.