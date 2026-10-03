# SK-REWORK apply script
# Dumb-copies modded/ over the recovered project in game-dump/.
# modded/ mirrors res:// exactly: modded\scripts\foo.gd -> game-dump\scripts\foo.gd
#
# Usage (from repo root):
#   pwsh tools/apply.ps1          # apply everything
#   pwsh tools/apply.ps1 -List    # dry-run: just show what would be copied
#   pwsh tools/apply.ps1 -GameDump D:\other\recovery   # alternate target
param(
    [string]$GameDump = (Join-Path $PSScriptRoot "..\game-dump"),
    [string]$Modded   = (Join-Path $PSScriptRoot "..\modded"),
    [switch]$List
)

$ErrorActionPreference = "Stop"

# Normalize to absolute paths so -Relative math stays honest
$GameDump = [System.IO.Path]::GetFullPath($GameDump)
$Modded   = [System.IO.Path]::GetFullPath($Modded)

if (-not (Test-Path -LiteralPath $Modded)) {
    Write-Error "modded/ folder not found: $Modded"
}
if (-not (Test-Path -LiteralPath $GameDump)) {
    Write-Error "game-dump/ not found: $GameDump - run recovery first (see tools/recover.md)"
}
if (-not (Test-Path -LiteralPath (Join-Path $GameDump "project.godot"))) {
    Write-Warning "$GameDump has no project.godot - is this really a recovered project root?"
}

$files = Get-ChildItem -LiteralPath $Modded -Recurse -File
if (-not $files) {
    Write-Warning "modded/ is empty - nothing to apply."
    exit 0
}

$applied = 0
$newFiles = 0
foreach ($f in $files) {
    # Path relative to modded\  ==  path relative to res://
    $rel  = $f.FullName.Substring($Modded.Length).TrimStart('\', '/')
    $dest = Join-Path $GameDump $rel

    if ($List) {
        Write-Host "[dry-run] $rel"
        continue
    }

    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $dest)) {
        # Not an error: brand-new files (new autoload, new scenes) are legit.
        Write-Host "  NEW      $rel"
        $newFiles++
    } else {
        Write-Host "  patched  $rel"
    }

    Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
    $applied++
}

if ($List) {
    Write-Host "`n(dry run - $($files.Count) file(s) would be touched; nothing copied)"
} else {
    Write-Host "`nDone: $applied file(s) copied ($newFiles new)."
    Write-Host "Repack next? See tools/repack.md - or press F5 in the Godot editor to test."
}
