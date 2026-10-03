# repack.md — build a modded .pck from game-dump/

## 0. One-time: create the export preset

`--export-pack` needs a named export preset inside the project.

1. Open `game-dump/` in the Godot editor.
2. **Project → Export → Add...** → pick the preset matching the game's desktop
   platform (Windows Desktop for a Windows install).
3. Name the preset **`SK-Rework`**.
4. Leave the export path as-is (we override it on the command line).

This writes `export_presets.cfg` into `game-dump/`. That file is part of the
dump (gitignored) — if you re-recover after an update you must re-create the
preset once. If you want it kept, copy it to `modded/export_presets.cfg` so
`apply.ps1` restores it automatically.

## 1. Repack (from repo root)

    godot --headless --path game-dump --export-pack "SK-Rework" build/sk-rework.pck

Requires a `godot` binary on PATH (or give the full path to the editor exe).
Output lands in `build/sk-rework.pck` (gitignored).

## 2. Install into the game (careful zone)

1. Confirm `ShotgunKing.pck.orig` (the untouched backup) still sits next to the
   game.
2. Copy the ORIGINAL .pck aside if you haven't:
       copy ShotgunKing.pck ShotgunKing.pck.orig
3. Overwrite the live .pck with ours:
       copy build\sk-rework.pck  "D:\...\Steamapps\common\Shotgun King\ShotgunKing.pck"
4. Launch from Steam.

## 3. Warnings

- **Steam "Verify integrity of game files" deletes our .pck** and restores the
  stock one. That's fine - just redo step 3 (or re-run the whole pipeline after
  a game UPDATE, since the dump itself went stale).
- Crash after the Sugar intro but before the PUNKCAKE intro = script syntax
  error. Fix in `modded/`, re-apply, re-pack.
- Keep `build/` and any `.pck` out of git (already in .gitignore).

## Quick sanity check before shipping

Optionally validate a changed script without launching the game:

    godot --headless --path game-dump --check-only --script res://scripts/changed_file.gd
