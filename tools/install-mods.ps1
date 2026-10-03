# SK-REWORK mod installer — makes workshop-mod zips or unpacked folders load.
#
# Failure modes it fixes (see notes/mods.md):
#   1. zip left unextracted in mods/            -> extracts properly
#   2. folder name != name= in info.lua         -> RENAMES folder to match
#   3. double-nested folders                    -> finds the real mod folder
#
# File placement in the repo: E:\testing\repo\tools\install-mods.ps1
#
# Usage:
#   cd E:\testing\repo\tools
#   powershell -ExecutionPolicy Bypass -File "E:\testing\repo\tools\install-mods.ps1" `
#       -GameDir "E:\testing\game" -ZipsDir "E:\testing\game\mods"
param(
    [Parameter(Mandatory=$true)][string]$GameDir,
    [string]$ZipsDir = ""
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

$RepoRoot = Resolve-RepoRoot
if (-not $ZipsDir) { $ZipsDir = Join-Path $RepoRoot "uploads\mods" }

if (-not (Test-Path -LiteralPath $GameDir)) { Write-Error "Game folder not found: $GameDir" }
if (-not (Test-Path -LiteralPath $ZipsDir)) { Write-Error "Source mods folder not found: $ZipsDir" }

$modsRoot = Join-Path $GameDir "mods"
New-Item -ItemType Directory -Path $modsRoot -Force | Out-Null

$tmp = Join-Path $env:TEMP "sk-mod-install"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null

$installed = 0
$zips = @(Get-ChildItem -LiteralPath $ZipsDir -Filter *.zip -File -ErrorAction SilentlyContinue)
$rars = @(Get-ChildItem -LiteralPath $ZipsDir -Filter *.rar -File -ErrorAction SilentlyContinue)
if ($rars.Count -gt 0) {
    Write-Host "NOTE: .rar mods are not auto-installed (e.g. $($rars[0].Name))." -ForegroundColor Yellow
    Write-Host "      Extract them manually (right-click -> Extract with WinRAR/7-Zip),"
    Write-Host "      then re-run with -ZipsDir pointing at the EXTRACTED folder." -ForegroundColor Yellow
}
$zips | ForEach-Object {
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

# Also process any already-unpacked mod folders inside ZipsDir
$dirs = @(Get-ChildItem -LiteralPath $ZipsDir -Directory -ErrorAction SilentlyContinue)
$dirs | ForEach-Object {
    $d = $_
    $info = Get-ChildItem -LiteralPath $d.FullName -Recurse -Filter info.lua -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $info) {
        Write-Host "`n== $($d.Name)/ (SKIP: no info.lua inside)" -ForegroundColor Yellow
        return
    }
    $infoText = Get-Content -Raw -LiteralPath $info.FullName
    if ($infoText -notmatch '(?m)^\s*name\s*=\s*"([^"]+)"') {
        Write-Host "`n== $($d.Name)/ (SKIP: no name= field in info.lua)" -ForegroundColor Yellow
        return
    }
    $modName = $Matches[1]
    $srcDir  = $info.Directory.FullName
    $dest    = Join-Path $modsRoot $modName
    if ($srcDir -eq $dest) {
        Write-Host "`n== $($d.Name)/ (already named '$modName')"
        $installed++
        return
    }
    Write-Host "`n== $($d.Name)/ -> mods/$modName"
    $tmpCopy = Join-Path $tmp ("dir-" + [guid]::NewGuid().ToString("N"))
    Copy-Item -LiteralPath $srcDir -Destination $tmpCopy -Recurse -Force
    if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    Move-Item -LiteralPath $tmpCopy -Destination $dest -Force
    $installed++
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`nDone: $installed mod(s) ready in $modsRoot"
Write-Host "Launch the game -> mod menu -> enable them. If one still fails, check the END of log.txt next to the exe."
