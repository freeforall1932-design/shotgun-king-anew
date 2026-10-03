# SK-REWORK apply script
# Deploys our mod folder (modded/sk-rework/) into the game's mods/ directory.
#
# Usage (from repo root):
#   pwsh tools/apply.ps1 -GameDir "D:\SteamLibrary\steamapps\common\Shotgun King"
#   pwsh tools/apply.ps1 -List    # dry-run (still needs -GameDir to make sense)
param(
    [string]$GameDir = "",
    [string]$ModName = "sk-rework",
    [string]$Modded  = (Join-Path $PSScriptRoot "..\modded"),
    [switch]$List,
    [switch]$GetLog   # just copy the game's log.txt into uploads/game-insights/
)

if ($GetLog) {
    if (-not $GameDir) { Write-Error "Pass -GameDir to use -GetLog" }
    $src = Join-Path $GameDir "log.txt"
    if (-not (Test-Path -LiteralPath $src)) { Write-Error "No log.txt in $GameDir" }
    $dst = Join-Path $PSScriptRoot "..\uploads\game-insights"
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    Copy-Item -LiteralPath $src -Destination (Join-Path $dst "log.txt") -Force
    Write-Host "Fetched log -> uploads/game-insights/log.txt"
    exit 0
}

$ErrorActionPreference = "Stop"

$ModDir = Join-Path $Modded $ModName
if (-not (Test-Path -LiteralPath $ModDir)) {
    Write-Error "Mod folder not found: $ModDir (create it per tools/mod-dev.md)"
}

if (-not $GameDir) {
    # Try to auto-locate a Steam library with the game installed
    $roots = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Shotgun King",
        "D:\SteamLibrary\steamapps\common\Shotgun King"
        # add your library path here or pass -GameDir
    )
    $GameDir = $roots | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $GameDir) {
        Write-Error "Game folder not found. Pass -GameDir `"...path...\Shotgun King`""
    }
}

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
