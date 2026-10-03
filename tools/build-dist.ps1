# SK-REWORK dist builder — turns a game folder into a playable MODDED COPY.
#
# Assembles a READY-TO-PLAY copy of Shotgun King with all mods pre-installed:
#   1. copies your game folder (exe, data.sgr, dlls, lang, ...) -> OutDir
#   1b. normalizes any existing mod\ or mods\ inside the copy (merges mod\ ->
#       mods\, unpacks .zips, renames unpacked mod folders to match info.lua
#       name=, removes .rars / legacy folders without info.lua)
#   2. overlays dist-overlay/mods/*  (13 workshop mods, load-ready names)
#   3. adds our own modded/sk-rework
#   3b. writes mods\modlist.lua so the copy starts with sk-rework ENABLED
#       (workshop mods start OFF; -AllModsOn starts everything ON) - no
#       in-game toggling needed
# The original game folder is only READ, never written.
#
# File placement in the repo: E:\testing\repo\tools\build-dist.ps1
#
# Usage:
#   cd E:\testing\repo\tools
#   powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\build-dist.ps1" `
#       -GameDir "E:\testing\game" -OutDir "E:\testing" -Clean
#   (canonical layout + full walkthrough: INSTALL.md)
#
# Options worth knowing:
#   -Clean          wipe a previous copy in OutDir first
#   -NoInheritMods  ignore any mod\ or mods\ folder from the source game and
#                   install only the 14 mods from this repo
#   -AllModsOn      pre-enable EVERY injected mod in mods\modlist.lua
#                   (default: only sk-rework is pre-enabled)
param(
    [Parameter(Mandatory=$true)][string]$GameDir,
    [string]$OutDir  = "",
    [string]$Overlay = "",
    [string]$OurMod  = "",
    [switch]$Clean,
    # start the copy with an EMPTY mods\ folder instead of inheriting the
    # source game's mods\ (guarantees exactly the 14 known-good mods)
    [switch]$NoInheritMods,
    # write mods\modlist.lua with every mod set to true instead of only
    # sk-rework (format live-verified 2026-10-03: return { {'name', bool}, ... })
    [switch]$AllModsOn
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
    if (Test-Path -LiteralPath (Join-Path $Dir "data.sgr")) { return $Dir }
    $sub = Get-ChildItem -LiteralPath $Dir -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "data.sgr") } |
        Select-Object -First 1
    if ($sub) {
        Write-Host "NOTE: found data.sgr inside subfolder '$($sub.FullName)' - using that as -GameDir." -ForegroundColor Yellow
        return $sub.FullName
    }
    return $Dir
}

$RepoRoot = Resolve-RepoRoot
$GameDir  = Resolve-GameDir $GameDir
if (-not $OutDir)  { $OutDir  = Join-Path $RepoRoot "dist" }
if (-not $Overlay) { $Overlay = Join-Path $RepoRoot "dist-overlay\mods" }
if (-not $OurMod)  { $OurMod  = Join-Path $RepoRoot "modded\sk-rework" }

if (-not (Test-Path -LiteralPath (Join-Path $GameDir "data.sgr"))) {
    Write-Error "No data.sgr in $GameDir - point -GameDir at the folder containing the game .exe and data.sgr."
}
if (-not (Test-Path -LiteralPath $Overlay)) { Write-Error "overlay missing: $Overlay (keep tools\ inside the extracted repo alongside dist-overlay\)" }
if (-not (Test-Path -LiteralPath $OurMod))  { Write-Error "our mod missing: $OurMod (keep tools\ inside the extracted repo alongside modded\)" }

$dest = Join-Path $OutDir "ShotgunKing-Modded"
if ($Clean -and (Test-Path -LiteralPath $dest)) { Remove-Item $dest -Recurse -Force }
New-Item -ItemType Directory -Path $dest -Force | Out-Null

Write-Host "1/3 copying game -> $dest  (this copies ~100 MB, be patient)"
robocopy $GameDir $dest /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null

$modsRoot        = Join-Path $dest "mods"
$singularModRoot = Join-Path $dest "mod"

if ($NoInheritMods) {
    foreach ($p in @($modsRoot, $singularModRoot)) {
        if (Test-Path -LiteralPath $p) {
            Write-Host "1b/3 dropping inherited '$((Split-Path -Leaf $p))\' folder (-NoInheritMods)"
            Remove-Item -LiteralPath $p -Recurse -Force
        }
    }
    New-Item -ItemType Directory -Path $modsRoot -Force | Out-Null
} else {
    New-Item -ItemType Directory -Path $modsRoot -Force | Out-Null

    # If the source game had 'mod\' (singular) instead of 'mods\', merge it into 'mods\'
    if (Test-Path -LiteralPath $singularModRoot) {
        Write-Host "1b/3 moving items from 'mod\' -> 'mods\' (game reads 'mods\')"
        Get-ChildItem -LiteralPath $singularModRoot -Force -ErrorAction SilentlyContinue | ForEach-Object {
            $target = Join-Path $modsRoot $_.Name
            if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
            Move-Item -LiteralPath $_.FullName -Destination $target -Force
        }
        Remove-Item -LiteralPath $singularModRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Unpack any .zip archives already placed in game\mod or game\mods and rename by info.lua name=
    $inheritedZips = @(Get-ChildItem -LiteralPath $modsRoot -Filter *.zip -File -ErrorAction SilentlyContinue)
    foreach ($z in $inheritedZips) {
        $stage = Join-Path $env:TEMP ("sk-dist-zip-" + $z.BaseName)
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
        try {
            Expand-Archive -LiteralPath $z.FullName -DestinationPath $stage -Force
            $info = Get-ChildItem -LiteralPath $stage -Recurse -Filter info.lua -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($info) {
                $infoText = Get-Content -Raw -LiteralPath $info.FullName
                if ($infoText -match '(?m)^\s*name\s*=\s*"([^"]+)"') {
                    $modName = $Matches[1]
                    $to = Join-Path $modsRoot $modName
                    if (Test-Path -LiteralPath $to) { Remove-Item -LiteralPath $to -Recurse -Force }
                    Move-Item -LiteralPath $info.Directory.FullName -Destination $to -Force
                    Write-Host "   ~ unpacked inherited '$($z.Name)' -> mods/$modName"
                }
            }
        } catch {
            Write-Host "   ! could not unpack '$($z.Name)': $($_.Exception.Message)" -ForegroundColor Yellow
        }
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $z.FullName -Force -ErrorAction SilentlyContinue
    }

    # Normalize any already-unpacked folders in game\mod or game\mods (fix folder name != info.lua name=, or double-nested)
    $inheritedDirs = @(Get-ChildItem -LiteralPath $modsRoot -Directory -ErrorAction SilentlyContinue)
    foreach ($d in $inheritedDirs) {
        $info = Get-ChildItem -LiteralPath $d.FullName -Recurse -Filter info.lua -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $info) {
            Write-Host "   ! removing '$($d.Name)' from copy's mods\ (no info.lua - legacy 2022 or non-mod folder)"
            Remove-Item -LiteralPath $d.FullName -Recurse -Force -ErrorAction SilentlyContinue
            continue
        }
        $infoText = Get-Content -Raw -LiteralPath $info.FullName
        if ($infoText -match '(?m)^\s*name\s*=\s*"([^"]+)"') {
            $modName = $Matches[1]
            $realDir = $info.Directory.FullName
            $to      = Join-Path $modsRoot $modName
            if (($d.Name -ne $modName) -or ($realDir -ne $d.FullName)) {
                $tmpMove = Join-Path $env:TEMP ("sk-dist-dir-" + [guid]::NewGuid().ToString("N"))
                Move-Item -LiteralPath $realDir -Destination $tmpMove -Force
                if (Test-Path -LiteralPath $d.FullName) { Remove-Item -LiteralPath $d.FullName -Recurse -Force }
                if (Test-Path -LiteralPath $to) { Remove-Item -LiteralPath $to -Recurse -Force }
                Move-Item -LiteralPath $tmpMove -Destination $to -Force
                Write-Host "   ~ renamed inherited folder '$($d.Name)' -> mods/$modName"
            }
        }
    }
}

Write-Host "2/3 injecting workshop mods (dist-overlay)"
Get-ChildItem -LiteralPath $Overlay -Directory | ForEach-Object {
    $to = Join-Path $modsRoot $_.Name
    if (Test-Path -LiteralPath $to) { Remove-Item -LiteralPath $to -Recurse -Force }
    Copy-Item -LiteralPath $_.FullName -Destination $to -Recurse
    Write-Host "   + mods/$($_.Name)"
}

Write-Host "3/3 injecting sk-rework (our mod)"
$ourDest = Join-Path $modsRoot "sk-rework"
if (Test-Path -LiteralPath $ourDest) { Remove-Item -LiteralPath $ourDest -Recurse -Force }
Copy-Item -LiteralPath $OurMod -Destination $ourDest -Recurse -Force
Write-Host "   + mods/sk-rework"

# a stale rar/zip left in mods/ from manual installs would only confuse
Get-ChildItem -LiteralPath $modsRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in ".rar", ".zip" } |
    ForEach-Object {
        Write-Host "   ! removing stray archive $($_.Name) (mods must be unpacked folders)"
        Remove-Item -LiteralPath $_.FullName -Force
    }

# ---- 3b/3 pre-enable mods: write mods\modlist.lua --------------------------
# On-disk format live-verified 2026-10-03 (run-2 harvest of the game's own
# file): a Lua chunk `return { {'<mod name>', <bool>}, ... }` with CRLF line
# endings, one tab indent, a trailing comma on EVERY entry (including the
# last) and a closing brace with no trailing newline. Without this file the
# game starts mods OFF (black text in the mod menu) - writing it means the
# copy boots with sk-rework already ON, no in-game toggling needed.
$modNames = @(Get-ChildItem -LiteralPath $modsRoot -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "info.lua") } |
    Sort-Object -Property @{Expression = { if ($_.Name -eq "sk-rework") { "" } else { $_.Name } }} |
    Select-Object -ExpandProperty Name)
if ($modNames.Count -gt 0) {
    $lines = @("return {")
    foreach ($mn in $modNames) {
        $on = "false"
        if ($AllModsOn -or $mn -eq "sk-rework") { $on = "true" }
        $lines += "`t{ '$mn', $on },"
    }
    $lines += "}"
    $modlistPath = Join-Path $modsRoot "modlist.lua"
    [System.IO.File]::WriteAllText($modlistPath, ($lines -join "`r`n"))
    if ($AllModsOn) {
        Write-Host "3b/3 wrote mods/modlist.lua - ALL $($modNames.Count) mods start ON (-AllModsOn)"
    } else {
        $others = $modNames.Count - 1
        Write-Host "3b/3 wrote mods/modlist.lua - sk-rework starts ON, $others workshop mods start OFF"
        Write-Host "     (add -AllModsOn to start everything ON; toggle any time in the in-game mod menu)"
    }
}

$applyScript = Join-Path $RepoRoot "tools\apply.ps1"
if (-not (Test-Path -LiteralPath $applyScript)) { $applyScript = Join-Path $PSScriptRoot "apply.ps1" }
$saveScript  = Join-Path $RepoRoot "tools\make_100pct_save.py"
if (-not (Test-Path -LiteralPath $saveScript))  { $saveScript  = Join-Path $PSScriptRoot "make_100pct_save.py" }

$readme = @"
SHOTGUN KING - MODDED BUILD (private, personal use)
====================================================
WHAT THIS IS: a full COPY of the game with mods added inside this folder.
Copied from: $GameDir
That source folder was NOT modified - only this copy has the mods.

PLAY: double-click the game's .exe in this folder.

MOD MENU: this build writes mods\modlist.lua, so sk-rework starts ON and the
workshop mods start OFF - no in-game toggling needed. The menu is NOT on the
title screen: click Play - the mod menu is the TOP entry of that screen.
There, BLACK text = OFF and WHITE text = ON; clicking a mod flips it, and the
change survives restarts. The up/down arrows do NOT toggle on/off - they
change load priority (which mod overrides which), so odd numbering after
sorting is cosmetic. If you change anything, restart the game to be safe.

TITLE BAR: "MODDED: ON - ACHIEVEMENTS: OFF" appears while a mod is ACTIVE -
that pauses Steam achievement tracking only. The achievements written into
this copy's save stay unlocked (live-verified: all 128 still unlocked after
a full modded session). Your original install is never touched.

Included: 13 workshop mods (by their authors, from the official Discord /
Steam Workshop) + sk-rework (this project - currently a debug stub that
logs the game's function map to log.txt; it changes no gameplay).

UNLOCK EVERYTHING IN THIS COPY (optional):
  1. launch this copy once, then quit (so the save folder exists)
  2. open PowerShell and run:
       cd E:\testing\repo\tools
       python "$saveScript" --game-dir "$dest"
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
Write-Host "NEXT -> launch that .exe (sk-rework is pre-enabled), play a couple of turns, then quit."
Write-Host "LOG  -> to collect log.txt afterwards, run in PowerShell:"
Write-Host "        cd E:\testing\repo\tools"
Write-Host "        powershell -ExecutionPolicy Bypass -File `"$applyScript`" -GameDir `"$dest`" -GetLog"
Write-Host "Your original game folder ($GameDir) was not touched."
