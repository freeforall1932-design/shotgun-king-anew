# SK-REWORK mod installer — makes workshop-mod zips actually load.
#
# Failure modes it fixes (see notes/mods.md):
#   1. zip left unextracted in mods/            -> extracts properly
#   2. folder name != name= in info.lua         -> RENAMES folder to match
#   3. double-nested folders                    -> finds the real mod folder
#
# Usage (from repo root):
#   pwsh tools/install-mods.ps1 -GameDir "E:\...\Shotgun.King.The.Final.Checkmate.v1.623b" `
#                               -ZipsDir "C:\Users\you\Downloads"
#   (any folder containing the mod .zips works; uploads/mods also has copies
#    if you have the full workspace, not just the git clone)
param(
    [Parameter(Mandatory=$true)][string]$GameDir,
    [string]$ZipsDir = (Join-Path $PSScriptRoot "..\uploads\mods")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $GameDir)) { Write-Error "Game folder not found: $GameDir" }
if (-not (Test-Path -LiteralPath $ZipsDir)) { Write-Error "Zips folder not found: $ZipsDir" }

$modsRoot = Join-Path $GameDir "mods"
New-Item -ItemType Directory -Path $modsRoot -Force | Out-Null

$tmp = Join-Path $env:TEMP "sk-mod-install"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null

$installed = 0
Get-ChildItem -LiteralPath $ZipsDir -Filter *.zip | ForEach-Object {
    $zip = $_
    $stage = Join-Path $tmp $zip.BaseName
    Write-Host "`n== $($zip.Name)"
    try {
        Expand-Archive -LiteralPath $zip.FullName -DestinationPath $stage -Force
    } catch {
        Write-Host "   SKIP (cannot unzip): $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    # find the mod's real folder = the one containing info.lua
    $info = Get-ChildItem -LiteralPath $stage -Recurse -Filter info.lua | Select-Object -First 1
    if (-not $info) {
        Write-Host "   SKIP: no info.lua inside (old-format or not a mod - see notes/mods.md)" -ForegroundColor Yellow
        return
    }

    # folder name MUST equal the name= field in info.lua
    $infoText = Get-Content -Raw -LiteralPath $info.FullName
    if ($infoText -notmatch '(?m)^\s*name\s*=\s*"([^"]+)"') {
        Write-Host "   SKIP: no name= field in info.lua" -ForegroundColor Yellow
        return
    }
    $modName = $Matches[1]
    $srcDir  = $info.Directory.FullName
    $dest    = Join-Path $modsRoot $modName

    if (Test-Path -LiteralPath $dest) {
        Write-Host "   UPDATE existing: $modName"
        Remove-Item -LiteralPath $dest -Recurse -Force
    } else {
        Write-Host "   INSTALL as: mods/$modName"
    }
    Move-Item -LiteralPath $srcDir -Destination $dest
    $installed++
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`nDone: $installed mod(s) in $modsRoot"
Write-Host "Launch the game -> mod menu -> enable them. If one still fails, check the END of log.txt next to the exe."
