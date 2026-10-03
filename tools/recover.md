# recover.md — turn the shipped .pck back into source

One-time setup per game version (and again after any game update).

## 0. Get the tool

Download **gdre_tools** (gdsdecomp) from the releases page:

    https://github.com/GDRETools/gdsdecomp/releases

Grab the build for your OS (e.g. `gdre_tools-windows.zip`), unpack it somewhere
outside this repo. Supports Godot 2.x–4.x; Shotgun King is Godot 3/4 — the tool
detects the version from the pck.

## 1. Locate the game files & BACK UP

Steam → right-click *Shotgun King* → **Manage → Browse local files**, e.g.

    D:\SteamLibrary\steamapps\common\Shotgun King\

**Two possible layouts — both fine:**

| You see | Meaning | Recovery target | Back this up |
|---|---|---|---|
| `ShotgunKing.pck` + exe | external pack | the `.pck` | `copy ShotgunKing.pck ShotgunKing.pck.orig` |
| only a big `.exe` (no .pck) | **pack embedded in the exe** (Godot "Embed Pck") | the `.exe` itself | `copy ShotgunKing.exe ShotgunKing.exe.orig` |

**Before anything else, make that backup** and keep it forever. It is the
"verify integrity" escape hatch and the clean baseline to re-diff against.
(`*.pck` / `*.orig` are gitignored — backups stay on disk, never in the repo.)

## 2. Run recovery (from the repo root)

Point `--recover` at whichever you have — a `.pck` OR the exe with the embedded
pack:

    # external pack:
    gdre_tools --headless --recover="C:\path\to\ShotgunKing.pck" --output-dir=game-dump

    # embedded pack (no .pck in the folder — this is the normal case):
    gdre_tools --headless --recover="C:\path\to\ShotgunKing.exe" --output-dir=game-dump

This decompiles all GDScript to readable source, restores resources (.tres,
scenes) and recovers `project.godot`. Wait for `Recovery complete` / similar.

## 3. Prove the loop works

1. Open the Godot editor (a Godot version matching the game's — check the
   recovered `project.godot` header; the editor will warn on mismatch).
2. **Import** → select `game-dump/project.godot`.
3. Press **F5** (Run Project). The game should boot to the intro screens.

If it crashes right after the Sugar intro but before the PUNKCAKE intro →
script syntax error in the recovery; re-run recovery and report.

## 4. Then

- Phase 1 (recon) works entirely inside `game-dump/` — findings go to
  `notes/map.md`.
- To apply our changes on top: `tools/apply.ps1`.
- To ship: `tools/repack.md`.

## Re-recovery after a game update

Steam "verify integrity" or an update overwrites the .pck. If the game version
changes: re-backup the new .pck, wipe `game-dump/`, re-run recovery, re-apply
`modded/`, then check `notes/map.md` against the new files for anything that
moved.
