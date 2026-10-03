# SK-REWORK dist builder — "inject the mods into the game's genes".
#
# Assembles a READY-TO-PLAY copy of Shotgun King with all mods pre-installed:
#   1. copies your game folder (exe, data.sgr, dlls, lang, ...) -> dist/
#   2. overlays dist-overlay/mods/*  (13 workshop mods, load-ready names)
#   3. adds our own modded/sk-rework
# Result: double-click dist\ShotgunKing-Modded\shotgun_king.exe and play.
#
# Usage (from repo root, on your Windows machine):
#   pwsh tools/build-dist.ps1 -GameDir "E:\...\Shotgun.King.The.Final.Checkmate.v1.623b"
#   pwsh tools/build-dist.ps1 -GameDir "..." -Clean   # wipe previous dist first
#
# Note: first launch may still ask you to toggle mods ON once in the mod menu
# (unconfirmed whether v1.623b enables present mods by default - live test
# will tell). After that one toggle it's zero-hassle forever.
param(
    [Parameter(Mandatory=$true)][string]$GameDir,
    [string]$OutDir = (Join-Path $PSScriptRoot "..\dist"),
    [string]$Overlay = (Join-Path $PSScriptRoot "..\dist-overlay\mods"),
    [string]$OurMod  = (Join-Path $PSScriptRoot "..\modded\sk-rework"),
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath (Join-Path $GameDir "data.sgr"))) {
    Write-Error "No data.sgr in $GameDir - that's not the game folder."
}
if (-not (Test-Path -LiteralPath $Overlay)) { Write-Error "overlay missing: $Overlay" }
if (-not (Test-Path -LiteralPath $OurMod))  { Write-Error "our mod missing: $OurMod" }

$dest = Join-Path $OutDir "ShotgunKing-Modded"
if ($Clean -and (Test-Path -LiteralPath $dest)) { Remove-Item $dest -Recurse -Force }
New-Item -ItemType Directory -Path $dest -Force | Out-Null

Write-Host "1/3 copying game -> $dest  (this copies ~100 MB, be patient)"
robocopy $GameDir $dest /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null

Write-Host "2/3 injecting workshop mods (dist-overlay)"
$modsRoot = Join-Path $dest "mods"
New-Item -ItemType Directory -Path $modsRoot -Force | Out-Null
Get-ChildItem -LiteralPath $Overlay -Directory | ForEach-Object {
    $to = Join-Path $modsRoot $_.Name
    if (Test-Path -LiteralPath $to) { Remove-Item $to -Recurse -Force }
    Copy-Item -LiteralPath $_.FullName -Destination $to -Recurse
    Write-Host "   + mods/$($_.Name)"
}

Write-Host "3/3 injecting sk-rework (our mod)"
Copy-Item -LiteralPath $OurMod -Destination (Join-Path $modsRoot "sk-rework") -Recurse -Force
Write-Host "   + mods/sk-rework"

# a stale rar/zip left in mods/ from manual installs would only confuse
Get-ChildItem -LiteralPath $modsRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in ".rar", ".zip" } |
    ForEach-Object {
        Write-Host "   ! removing stray archive $($_.Name) (mods must be unpacked folders)"
        Remove-Item -LiteralPath $_.FullName -Force
    }

$readme = @'
SHOTGUN KING - MODDED BUILD (private, personal use)
====================================================
WHAT THIS IS: a full COPY of the game with mods added inside this folder.
Your original install was NOT touched - verify it yourself: all this
script did was copy your game folder here and add a mods\ folder.

Play:  run shotgun_king.exe

TOGGLES: mods are NOT forced on. Open the in-game MOD MENU (from the
main menu) to switch each mod ON or OFF individually - injected mods
appear there like any other mod. Changes apply on your next run.

Included: 13 workshop mods (by their authors, from the official Discord /
Steam Workshop) + sk-rework (this project - currently a debug stub that
logs the game's function map to log.txt).

UNLOCK EVERYTHING IN THIS COPY (optional):
  1. launch this copy once, then quit (so save\ exists)
  2. in the repo:  python tools\make_100pct_save.py --game-dir "dist\ShotgunKing-Modded"
  3. play. (Backup + undo: --restore)

Restore vanilla: turn mods off in the mod menu, or delete the mods\
folder. To remove this whole build, delete dist\ - nothing else changed.
'@
Set-Content -LiteralPath (Join-Path $dest "PLAY-THIS.txt") -Value $readme

Write-Host "`nDone -> $dest"
Write-Host "Your original game folder was not touched. Play by running shotgun_king.exe inside dist\ShotgunKing-Modded."
