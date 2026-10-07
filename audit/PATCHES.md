# Shotgun King: Reworked - Proposed Fix Pack

These fixes target the pinned commit listed in [AUDIT_REPORT.md](AUDIT_REPORT.md). They are proposed upstream changes, not changes already applied to GitHub. Apply each patch in a clean clone and review the diff before running it.

## Patch 1 - Guard build paths and check Robocopy

**File:** `tools/build-dist.ps1`

Place these helpers before the `$dest` assignment. Then add the path check immediately after `$dest` is assigned and before the `-Clean` block.

```powershell
function Normalize-FullPath([string]$Path) {
    $full = [System.IO.Path]::GetFullPath($Path)
    $root = [System.IO.Path]::GetPathRoot($full)
    if ($full.Length -gt $root.Length) {
        $full = $full.TrimEnd([char[]]@('\', '/'))
    }
    return $full
}

function Test-SameOrNestedPath([string]$Parent, [string]$Candidate) {
    if ($Parent.Equals($Candidate, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $prefix = $Parent
    $separator = [System.IO.Path]::DirectorySeparatorChar.ToString()
    if (-not $prefix.EndsWith($separator)) {
        $prefix += $separator
    }
    return $Candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}
```

```powershell
$dest = Join-Path $OutDir "ShotgunKing-Modded"
$sourceFull = Normalize-FullPath $GameDir
$destFull = Normalize-FullPath $dest

# The source and output must be disjoint. This check must run before -Clean.
if ((Test-SameOrNestedPath $sourceFull $destFull) -or
    (Test-SameOrNestedPath $destFull $sourceFull)) {
    throw "Source and output paths overlap. Choose a separate -OutDir; source='$sourceFull' output='$destFull'."
}

if ($Clean -and (Test-Path -LiteralPath $dest)) {
    Remove-Item $dest -Recurse -Force
}
```

Replace the existing `robocopy` call with this block. Codes 0-7 are successful Robocopy outcomes; 8 and above indicate at least one copy failure.

```powershell
$nativeErrorPref = Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue
if ($nativeErrorPref) {
    $savedNativeErrorPref = $nativeErrorPref.Value
    $PSNativeCommandUseErrorActionPreference = $false
}
try {
    robocopy $GameDir $dest /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
    $copyExitCode = $LASTEXITCODE
} finally {
    if ($nativeErrorPref) {
        $PSNativeCommandUseErrorActionPreference = $savedNativeErrorPref
    }
}
if ($copyExitCode -ge 8) {
    throw "robocopy failed with exit code $copyExitCode while copying '$GameDir' to '$dest'."
}
```

The native-command preference is temporarily disabled when PowerShell 7 exposes it, so valid non-zero Robocopy statuses reach the explicit 0-7/8+ check instead of becoming generic errors under `$ErrorActionPreference = "Stop"`. The path guard checks normalized ordinary filesystem paths. If this tool is expected to accept arbitrary junctions or symbolic links, add a reparse-point policy too; `GetFullPath()` does not resolve junction targets.

## Patch 2 - Make skipped Lua smoke tests explicit

**File:** `tools/mod_smoketest.py`

Add `subprocess` to the imports:

```diff
 import re
 import sys
 import tempfile
+import subprocess
```

Replace the `except ImportError` branch in `main()`:

```python
    except ImportError:
        print("lupa is not installed (dev-only dependency).")
        print("Running the parser self-test; the Lua smoke test will be skipped.")
        parser = subprocess.run(
            [sys.executable, os.path.join(HERE, "parse_log.py"), "--selftest"],
            check=False,
        )
        if parser.returncode != 0:
            return parser.returncode
        # Exit 2 is an explicit skip, not a green Lua smoke-test result.
        return 2
```

The current behavior returns 0 without running the printed parser command. After this patch, a runner must treat exit 2 as "Lua test skipped" and must not count it as a pass. The parser self-test's own non-zero result still fails the command.

## Patch 3 - Honor `--dry-run` during restore

**File:** `tools/make_100pct_save.py`

Move the dry-run flag read to before the restore branch and add a no-write return before `rmtree`:

```diff
     if not os.path.isdir(game_dir):
         raise SystemExit(f"game folder not found: {game_dir}")
+    dry = "--dry-run" in argv
     if "--restore" in argv:
         backups = sorted(d for d in os.listdir(game_dir) if d.startswith("save_backup_"))
         if not backups:
             raise SystemExit(f"no save_backup_* folder found in {game_dir}")
         src = os.path.join(game_dir, backups[-1])
         dst = save_dir_for(game_dir)
+        if dry:
+            print(f"(dry run - would restore {src} -> {dst}; nothing written)")
+            return 0
         print(f"restoring {src} -> {dst}")
         if os.path.isdir(dst):
             shutil.rmtree(dst)
         shutil.copytree(src, dst)
         return 0
-    dry = "--dry-run" in argv
```

## Patch 4 - Make `-GetInsights` a validated, clean snapshot

**File:** `tools/apply.ps1`

Replace the body of the `if ($GetInsights) { ... }` branch with the following. It rejects a missing folder/log before writing, stages each pack in a new directory, and swaps it into place only after collection. `modlist.lua` and `save/` remain optional; an older version of either is never retained in a newer pack.

```powershell
if ($GetInsights) {
    if (-not $GameDir) {
        Write-Error "Pass -GameDir to use -GetInsights."
    }
    if (-not (Test-Path -LiteralPath $GameDir -PathType Container)) {
        Write-Error "Game folder not found: $GameDir"
    }

    $GameDir = Resolve-GameDir $GameDir
    $logSrc = Join-Path $GameDir "log.txt"
    if (-not (Test-Path -LiteralPath $logSrc -PathType Leaf)) {
        Write-Error "No log.txt in $GameDir (launch the game from this folder first)."
    }

    $dst = Join-Path $RepoRoot "uploads\game-insights"
    $parent = Split-Path -Parent $dst
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $token = [guid]::NewGuid().ToString("N")
    $stage = Join-Path $parent ("game-insights.stage-" + $token)
    $old = Join-Path $parent ("game-insights.old-" + $token)
    New-Item -ItemType Directory -Path $stage -Force | Out-Null

    try {
        Copy-Item -LiteralPath $logSrc -Destination (Join-Path $stage "log.txt") -Force

        $modlistSrc = Join-Path $GameDir "mods\modlist.lua"
        if (Test-Path -LiteralPath $modlistSrc -PathType Leaf) {
            Copy-Item -LiteralPath $modlistSrc -Destination (Join-Path $stage "modlist.lua") -Force
        } else {
            Write-Host "skip (not present): mods\modlist.lua" -ForegroundColor Yellow
        }

        $saveSrc = Join-Path $GameDir "save"
        if (Test-Path -LiteralPath $saveSrc -PathType Container) {
            Get-ChildItem -LiteralPath $saveSrc -Recurse -File -ErrorAction Stop | ForEach-Object {
                $relative = $_.FullName.Substring($saveSrc.Length + 1)
                $target = Join-Path (Join-Path $stage "save") $relative
                $targetDir = Split-Path -Parent $target
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                Copy-Item -LiteralPath $_.FullName -Destination $target -Force
            }
        } else {
            Write-Host "skip (not present): save\" -ForegroundColor Yellow
        }

        if (Test-Path -LiteralPath $dst) {
            Move-Item -LiteralPath $dst -Destination $old
        }
        try {
            Move-Item -LiteralPath $stage -Destination $dst
        } catch {
            if (Test-Path -LiteralPath $old) {
                Move-Item -LiteralPath $old -Destination $dst
            }
            throw
        }
        if (Test-Path -LiteralPath $old) {
            Remove-Item -LiteralPath $old -Recurse -Force
        }
    } finally {
        if (Test-Path -LiteralPath $stage) {
            Remove-Item -LiteralPath $stage -Recurse -Force
        }
    }

    Write-Host "Fetched current insight pack -> $dst"
    exit 0
}
```

## Patch 5 - Stop tracking the game payload

**File:** `.gitignore`

Remove the `!game/` and `!game/**` negations. Replace the exception block with:

```diff
-# EXCEPTION: game/ is the owner's game copy and is committed intentionally.
-!game/
-!game/**
+# Keep the purchased game, decoded proprietary data, saves and runtime logs local.
+/game/
```

Then remove the currently tracked directory from the next commit while leaving the local working copy available:

```bash
git rm -r --cached game/
git add .gitignore README.md HANDOFF.md
git commit -m "Stop tracking local game files"
```

This fixes the current tree, not prior commits. To remove the game blobs from all reachable Git history, use a fresh mirror clone, review the rewritten object list, coordinate collaborators, and force-update the repository only after a backup and owner approval:

```bash
git clone --mirror https://github.com/freeforall1932-design/shotgun-king-anew.git shotgun-king-anew-clean.git
cd shotgun-king-anew-clean.git
git filter-repo --path game/ --invert-paths
git remote add origin https://github.com/freeforall1932-design/shotgun-king-anew.git
git push --force --mirror origin
```

After rewriting, ask GitHub support about cached views and coordinate fresh clones. Also remove/sanitize tracked logs and save data if they contain anything that should not be public. Update the README's repository size and no-game-assets statements only after verifying the rewritten tree. This is a repository-owner action; it was not executed by this audit.

## Patch 6 - Correct the generated play instructions

**File:** `tools/build-dist.ps1`

In the `$readme` here-string that writes `PLAY-THIS.txt`, replace the obsolete sentence:

```diff
-Included: 13 workshop mods (by their authors, from the official Discord / Steam Workshop) + sk-rework (this project - currently a debug stub that logs the game's function map to log.txt; it changes no gameplay).
+Included: 13 workshop mods (by their authors, from the official Discord / Steam Workshop) + sk-rework Build 9. Its SK DEV panel contains game-state controls; use them deliberately. Build 9 is sandbox-tested, but live-game validation is still pending.
```

Keep the new copy consistent with `modded/sk-rework/info.lua`, the README readiness table, and the actual live-test status.

## Regression checklist

- **Path overlap:** create a disposable source folder containing a sentinel `data.sgr`; set `-OutDir` so `ShotgunKing-Modded` equals or nests in that source; invoke with `-Clean`; the patched script must throw before the sentinel is deleted.
- **Robocopy failure:** in a disposable Windows VM, make the copy operation return a Robocopy code of 8 or higher; the script must stop before creating `mods/` or printing `Done`.
- **Smoke-test skip:** run in an environment without `lupa`; the parser self-test must execute and the script must return the documented skip status rather than 0.
- **Restore dry-run:** create a backup and a current save containing a sentinel; run `python tools/make_100pct_save.py --game-dir <fixture> --restore --dry-run`; the sentinel and current save must remain byte-identical.
- **Insight validation:** pass a nonexistent `-GameDir` and a folder without `log.txt`; both must fail without producing a new pack.
- **Insight freshness:** capture pack A with a save file, remove that file from the source, capture pack B; pack B must not contain the stale file from A.
- **Repository cleanup:** verify `/game/` is ignored, the rewritten tree contains no `game/` blobs, and the tracked file list no longer includes game binaries, decoded assets, logs, or saves.
- **Generated instructions:** run the builder and inspect `PLAY-THIS.txt`; it must describe Build 9 and mark live testing as pending.

## Apply order

Apply patch 5 as an owner-approved repository incident response first. Apply patches 1-4 before the next build/test cycle. Apply patch 6 before distributing any freshly built copy.