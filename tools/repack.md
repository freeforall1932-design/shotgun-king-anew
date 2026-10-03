# repack.md — build a modded game from game-dump/

**First figure out which layout the game shipped with** (see tools/recover.md):
an external `ShotgunKing.pck`, or the pack **embedded in the exe**. The install
step differs; the preset setup is the same.

## 0. One-time: create the export preset

`--export-pack` needs a named export preset inside the project.

1. Open `game-dump/` in the Godot editor.
2. **Project → Export → Add...** → pick the preset matching the game's desktop
   platform (Windows Desktop for a Windows install).
3. Name the preset **`SK-Rework`**.
4. **If the game's pack is embedded in its exe: tick "Embed Pck"** in the
   preset (the whole point is producing an exe, not a loose .pck).
5. Leave the export path as-is (we override it on the command line).

This writes `export_presets.cfg` into `game-dump/`. That file is part of the
dump (gitignored) — if you re-recover after an update you must re-create the
preset once. If you want it kept, copy it to `modded/export_presets.cfg` so
`apply.ps1` restores it automatically.

## 1. Repack (from repo root)

```bash
# External-pack game → produces build/sk-rework.pck:
godot --headless --path game-dump --export-pack "SK-Rework" build/sk-rework.pck

# Embedded-pack game ("Embed Pck" ticked in preset) → produces a new EXE:
godot --headless --path game-dump --export-pack "SK-Rework" build/SK-Rework.exe
```

Requires a `godot` binary on PATH (or give the full path to the editor exe).
Outputs land in `build/` (gitignored).

Alternative without the Godot editor — gdre_tools can rebuild/patch and
re-embed for you:

```bash
# patch just the files we changed back into a copy of the original exe:
gdre_tools --headless --pck-patch="ShotgunKing.exe" \
  --patch-file="modded/scripts/foo.gd=res://scripts/foo.gd" \
  --embed="ShotgunKing.exe" --output=build/SK-Rework.exe
```

(If the game's scripts ship as compiled `.gdc`, patch files must be compiled
first: `--compile=<file.gd> --bytecode=<engine-version>`.)

## 2. Install into the game (careful zone)

1. Confirm the untouched backup still sits next to the game
   (`ShotgunKing.pck.orig` or `ShotgunKing.exe.orig`).
2. Copy the ORIGINAL aside if you haven't (see tools/recover.md step 1).
3. Overwrite the live file with ours:

```bat
:: external-pack game:
copy build\sk-rework.pck  "D:\...\steamapps\common\Shotgun King\ShotgunKing.pck"

:: embedded-pack game — replace the EXE, keeping the exact same filename:
copy build\SK-Rework.exe  "D:\...\steamapps\common\Shotgun King\ShotgunKing.exe"
```

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
