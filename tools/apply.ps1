# SK-REWORK apply script
# Deploys our mod folder (modded/sk-rework/) into the game's mods/ directory.
#
# File placement in the repo: tools\apply.ps1 (inside the tools\ subfolder,
# NOT at the root of the main branch).
#
# Usage — full path (works from ANY folder in PowerShell, recommended):
#   powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\game" -List
#   powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\ShotgunKing-Modded" -GetLog
#   powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\apply.ps1" -GameDir "E:\testing\ShotgunKing-Modded" -GetInsights
#
# Usage — relative path (depends on where your PowerShell prompt is):
#   from repo root (PS E:\testing\repo>):        powershell -ExecutionPolicy Bypass -File .\tools\apply.ps1 -GameDir "E:\testing\game" -List
#   from tools\    (PS E:\testing\repo\tools>):  powershell -ExecutionPolicy Bypass -File .\apply.ps1 -GameDir "E:\testing\game" -List
param(
    [string]$GameDir = "",
    [string]$ModName = "sk-rework",
    [string]$Modded  = "",
    [switch]$List,
    [switch]$GetLog,      # just copy the game's log.txt into uploads/game-insights/
    [switch]$GetInsights  # log.txt + mods/modlist.lua + the whole save/ folder
)

$ErrorActionPreference = "Stop"

function Resolve-RepoRoot {
    $candidates = @(
        $PSScriptRoot,
        (Join-Path $PSScriptRoot ".."),
        (Get-Location).Path,
        (Join-Path (Get-Location).Path ".."),
        "E:\testing\repo",
        "E:\testing\repo\shotgun-king-anew-main",
        "E:\testing\shotgun-king-anew-main"
    )
    foreach ($base in $candidates) {
        if (-not $base) { continue }
        try { $full = [System.IO.Path]::GetFullPath($base) } catch { continue }
        if (Test-Path -LiteralPath (Join-Path $full "modded\sk-rework")) {
            return $full
        }
        if (Test-Path -LiteralPath $full) {
            $nested = Get-ChildItem -LiteralPath $full -Directory -Filter "shotgun-king-anew*" -ErrorAction SilentlyContinue |
                Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "modded\sk-rework") } |
                Select-Object -First 1
            if ($nested) { return $nested.FullName }
        }
    }
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
}

function Resolve-GameDir([string]$Dir) {
    if (-not $Dir -or -not (Test-Path -LiteralPath $Dir)) { return $Dir }
    if ((Test-Path -LiteralPath (Join-Path $Dir "data.sgr")) -or
        (Get-ChildItem -LiteralPath $Dir -Filter *.exe -File -ErrorAction SilentlyContinue)) {
        return $Dir
    }
    $sub = Get-ChildItem -LiteralPath $Dir -Directory -ErrorAction SilentlyContinue |
        Where-Object {
            (Test-Path -LiteralPath (Join-Path $_.FullName "data.sgr")) -or
            (Get-ChildItem -LiteralPath $_.FullName -Filter *.exe -File -ErrorAction SilentlyContinue)
        } | Select-Object -First 1
    if ($sub) {
        Write-Host "NOTE: found game files inside subfolder '$($sub.FullName)' - using that as -GameDir." -ForegroundColor Yellow
        return $sub.FullName
    }
    return $Dir
}

$RepoRoot = Resolve-RepoRoot
if (-not $Modded) { $Modded = Join-Path $RepoRoot "modded" }

if ($GetLog) {
    if (-not $GameDir) { Write-Error "Pass -GameDir to use -GetLog (e.g. -GameDir `"E:\testing\ShotgunKing-Modded`")" }
    $GameDir = Resolve-GameDir $GameDir
    $src = Join-Path $GameDir "log.txt"
    if (-not (Test-Path -LiteralPath $src)) { Write-Error "No log.txt in $GameDir (launch the game from $GameDir once first)" }
    $dst = Join-Path $RepoRoot "uploads\game-insights"
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    $dstFile = Join-Path $dst "log.txt"
    Copy-Item -LiteralPath $src -Destination $dstFile -Force
    Write-Host "Fetched log -> $dstFile"
    exit 0
}

if ($GetInsights) {
    # Collect a new, self-contained snapshot and replace the previous one only
    # after every required/available source has copied successfully.
    if (-not $GameDir) {
        Write-Error "Pass -GameDir to use -GetInsights (e.g. -GameDir `"E:\testing\ShotgunKing-Modded`")"
    }
    if (-not (Test-Path -LiteralPath $GameDir -PathType Container)) {
        Write-Error "Game folder not found: $GameDir"
    }
    $GameDir = Resolve-GameDir $GameDir
    if (-not (Test-Path -LiteralPath $GameDir -PathType Container)) {
        Write-Error "Resolved game folder not found: $GameDir"
    }
    $GameDir = (Get-Item -LiteralPath $GameDir -ErrorAction Stop).FullName

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
    $oldMoved = $false

    try {
        New-Item -ItemType Directory -Path $stage -ErrorAction Stop | Out-Null
        Copy-Item -LiteralPath $logSrc -Destination (Join-Path $stage "log.txt") -Force -ErrorAction Stop

        $modlistSrc = Join-Path $GameDir "mods\modlist.lua"
        if (Test-Path -LiteralPath $modlistSrc -PathType Leaf) {
            Copy-Item -LiteralPath $modlistSrc -Destination (Join-Path $stage "modlist.lua") -Force -ErrorAction Stop
        } else {
            Write-Host "skip (not present): mods\modlist.lua" -ForegroundColor Yellow
        }

        $saveSrc = Join-Path $GameDir "save"
        if (Test-Path -LiteralPath $saveSrc -PathType Container) {
            $saveSrc = (Get-Item -LiteralPath $saveSrc -ErrorAction Stop).FullName
            $saveFiles = @(Get-ChildItem -LiteralPath $saveSrc -Recurse -File -Force -ErrorAction Stop)
            foreach ($file in $saveFiles) {
                $relative = $file.FullName.Substring($saveSrc.Length + 1)
                $target = Join-Path (Join-Path $stage "save") $relative
                $targetDir = Split-Path -Parent $target
                New-Item -ItemType Directory -Path $targetDir -Force -ErrorAction Stop | Out-Null
                Copy-Item -LiteralPath $file.FullName -Destination $target -Force -ErrorAction Stop
            }
            if ($saveFiles.Count -gt 0) {
                Write-Host "Fetched save\ -> $stage\save"
            } else {
                Write-Host "skip (empty): save\" -ForegroundColor Yellow
            }
        } else {
            Write-Host "skip (not present): save\ (launch the game once first)" -ForegroundColor Yellow
        }

        if (Test-Path -LiteralPath $dst) {
            Move-Item -LiteralPath $dst -Destination $old -ErrorAction Stop
            $oldMoved = $true
        }
        try {
            Move-Item -LiteralPath $stage -Destination $dst -ErrorAction Stop
        } catch {
            $swapError = $_
            if ($oldMoved) {
                try {
                    if (Test-Path -LiteralPath $dst) {
                        Remove-Item -LiteralPath $dst -Recurse -Force -ErrorAction Stop
                    }
                    Move-Item -LiteralPath $old -Destination $dst -ErrorAction Stop
                    $oldMoved = $false
                } catch {
                    $rollbackError = $_
                    throw "Snapshot swap failed ($($swapError.Exception.Message)); rollback also failed ($($rollbackError.Exception.Message)). The previous snapshot is retained at '$old'."
                }
            }
            throw $swapError
        }

        if ($oldMoved) {
            try {
                Remove-Item -LiteralPath $old -Recurse -Force -ErrorAction Stop
                $oldMoved = $false
            } catch {
                Write-Warning "New snapshot installed; previous snapshot was retained at '$old'."
            }
        }
    } finally {
        if (Test-Path -LiteralPath $stage) {
            Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "Fetched current insight pack -> $dst"
    exit 0
}

$ModDir = Join-Path $Modded $ModName
if (-not (Test-Path -LiteralPath $ModDir)) {
    Write-Error "Mod folder not found: $ModDir (keep tools\ inside the extracted repo folder alongside modded\)"
}

if (-not $GameDir) {
    # Try to auto-locate a testing or Steam folder with the game installed
    $roots = @(
        "E:\testing\game",
        "C:\Program Files (x86)\Steam\steamapps\common\Shotgun King",
        "D:\SteamLibrary\steamapps\common\Shotgun King"
        # add your library path here or pass -GameDir
    )
    $GameDir = $roots | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $GameDir) {
        Write-Error "Game folder not found. Pass -GameDir `"E:\testing\game`""
    }
}

$GameDir = Resolve-GameDir $GameDir
if (-not (Test-Path -LiteralPath $GameDir)) {
    Write-Error "Game folder does not exist: $GameDir"
}

# Sanity: game folder should contain the game exe (any name) — warn if not.
if (-not (Get-ChildItem -LiteralPath $GameDir -Filter *.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "No .exe found in $GameDir - is this really the game install folder?"
}

$modsRoot = Join-Path $GameDir "mods"
$dest     = Join-Path $modsRoot $ModName

if ($List) {
    Write-Host "[dry-run] would copy $ModDir -> $dest"
    Get-ChildItem -LiteralPath $ModDir -Recurse -File |
        ForEach-Object { Write-Host ("  " + $_.FullName.Substring($ModDir.Length + 1)) }
    exit 0
}

New-Item -ItemType Directory -Path $dest -Force | Out-Null

# Mirror-copy: remove stale files, then copy everything (idempotent deploy)
if (Test-Path -LiteralPath $dest) {
    Get-ChildItem -LiteralPath $dest -Recurse -File |
        Where-Object { -not (Test-Path -LiteralPath (Join-Path $ModDir $_.FullName.Substring($dest.Length + 1))) } |
        ForEach-Object {
            Write-Host "  del (stale) $($_.FullName.Substring($dest.Length + 1))"
            Remove-Item -LiteralPath $_.FullName -Force
        }
}

$count = 0
Get-ChildItem -LiteralPath $ModDir -Recurse -File | ForEach-Object {
    $rel  = $_.FullName.Substring($ModDir.Length + 1)
    $to   = Join-Path $dest $rel
    $dir  = Split-Path -Parent $to
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -LiteralPath $_.FullName -Destination $to -Force
    $count++
}

Write-Host "Done: deployed $count file(s) to $dest"
Write-Host "Launch the game, enable '$ModName' in the mod menu, then check log.txt if anything misbehaves (tools/mod-dev.md)."
