# SK-REWORK dist builder — turns a game folder into a playable MODDED COPY.
#
# Assembles a READY-TO-PLAY copy of Shotgun King with all mods pre-installed:
#   1. copies your game folder (exe, data.sgr, dlls, lang, ...) -> OutDir
#   2. overlays dist-overlay/mods/*  (13 workshop mods, load-ready names)
#   3. adds our own modded/sk-rework
# The original game folder is only READ, never written.
#
# Usage (from repo root, on your Windows machine):
#   powershell -ExecutionPolicy Bypass -File tools\build-dist.ps1 `
#       -GameDir "E:\testing\game" -OutDir "E:\testing" -Clean
#   (canonical layout + full walkthrough: INSTALL.md)
#
# Options worth knowing:
#   -Clean          wipe a previous copy in OutDir first
#   -NoInheritMods  start with an empty mods\ in the copy (exactly 14 mods,
#                   nothing inherited from the source game's mods\ folder)
#
# Note: first launch may still ask you to toggle mods ON once in the mod menu
# (unconfirmed whether v1.623b enables present mods by default - live test
# will tell). After that one toggle it's zero-hassle forever.
param(
    [Parameter(Mandatory=$true)][string]$GameDir,
    [string]$OutDir = (Join-Path $PSScriptRoot "..\dist"),
    [string]$Overlay = (Join-Path $PSScriptRoot "..\dist-overlay\mods"),
    [string]$OurMod  = (Join-Path $PSScriptRoot "..\modded\sk-rework"),
    [switch]$Clean,
    # start the copy with an EMPTY mods\ folder instead of inheriting the
    # source game's mods\ (guarantees exactly the 14 known-good mods)
    [switch]$NoInheritMods
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

if ($NoInheritMods) {
    $inherited = Join-Path $dest "mods"
    if (Test-Path -LiteralPath $inherited) {
        Write-Host "1b/3 dropping the inherited mods\ folder (-NoInheritMods)"
        Remove-Item -LiteralPath $inherited -Recurse -Force
    }
}

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

$readme = @"
SHOTGUN KING - MODDED BUILD (private, personal use)
====================================================
WHAT THIS IS: a full COPY of the game with mods added inside this folder.
Copied from: $GameDir
That source folder was NOT modified - only this copy has the mods.

PLAY: double-click the game's .exe in this folder.

TOGGLES: mods are NOT forced on. Open the in-game MOD MENU (from the
main menu) to switch each mod ON or OFF individually - injected mods
appear there like any other mod. Changes apply on your next run.

Included: 13 workshop mods (by their authors, from the official Discord /
Steam Workshop) + sk-rework (this project - currently a debug stub that
logs the game's function map to log.txt; it changes no gameplay).

UNLOCK EVERYTHING IN THIS COPY (optional):
  1. launch this copy once, then quit (so the save folder exists)
  2. open PowerShell in the repo folder and run:
       python tools\make_100pct_save.py --game-dir "$dest"
  3. play. (Automatic backup; undo with the same command + --restore)

UNDO: delete this whole folder. Your base game and your Steam install are
untouched either way.
"@
Set-Content -LiteralPath (Join-Path $dest "PLAY-THIS.txt") -Value $readme

$exes = @(Get-ChildItem -LiteralPath $dest -Filter *.exe -File -ErrorAction SilentlyContinue)
$exe = $exes | Where-Object { $_.Name -match "shotgun|king" } | Select-Object -First 1
if (-not $exe) { $exe = $exes | Select-Object -First 1 }

Write-Host "`nDone -> $dest"
if ($exe) { Write-Host "PLAY -> $($exe.FullName)" }
Write-Host "NEXT -> launch that .exe, open the in-game MOD MENU, then quit the game."
Write-Host "LOG  -> to send the project its required log.txt, run from this repo:"
Write-Host "        powershell -ExecutionPolicy Bypass -File tools\apply.ps1 -GameDir `"$dest`" -GetLog"
Write-Host "Your original game folder ($GameDir) was not touched."
