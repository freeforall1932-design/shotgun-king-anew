# notes/changelog.md — what we changed and why

Every kept change gets an entry. Newest first. `res://` paths only (the same
file lives in `modded/` at that path).

## Format

```
## YYYY-MM-DD — Phase N: <short title>
- `modded/sk-rework/<file>` — what changed (with `-- SK-REWORK:` markers inside)
- why: <reason / which design option from PLANNING.md §5>
- status: <shipped / playtest-pending / reverted>
```

---

## 2026-10-03 — Owner decisions locked + repo slim-down

- **Decisions recorded in PLANNING.md §0.6**: ammo = A→B→C progressive;
  native-feel UI principle (reuse game's own button code); built-in
  dev/cheat mode + save-modification tools (Phase 2 scope expanded);
  repo public during dev, private at deployment.
- **Removed the 3 game rar parts from the branch** (git rm) — extracted
  keep-list instead into `uploads/game-extracted-lite/` (exe, lang/ 18
  string tables, save/ samples for the save tools, mods/, settings, bats —
  no dlls/steam_settings/data.sgr). `main` still holds part4 + mod zips
  (owner to delete via web UI or covered by private flip). Rars remain in
  git history until a deployment-time scrub.
- **NEW tools/install-mods.ps1**: unzips workshop-mod zips into
  `<game>/mods/`, auto-renames each folder to its `name=` field (the #1
  "mod won't load" cause), skips old-format mods without info.lua.
- why: owner confirmed strategy; repo slimming requested ("remove the rar
  and zip if its already unpacked"); mod-loading failures were killing
  motivation to play.
- status: shipped

## 2026-10-03 — Phase 0 complete: game obtained + ENGINE CORRECTION + strategy pivot

**Findings (owner uploaded the game in 4 rar parts + 13 workshop mods to
GitHub; all parts recovered, extracted, analyzed):**

- **Engine is SUGAR, not Godot** (custom Pico-8-style Lua engine by Rémy
  Devaux; runtime v0.0.8f, LuaJIT 2.1/Lua 5.1, SDL3). No .pck, no gdre_tools,
  no repacking — ever. PLANNING.md §0.5 correction added; §2/§8 updated.
- **Strategy pivot: build the rework AS A MOD.** The game has a first-class
  mod system (official guide by the dev, `append`/`prepend` any function,
  `on_*` events, custom cards/pieces/modes, save banks, `gimme()` runtime
  introspection). `tools/repack.md` deleted → `tools/mod-dev.md` created;
  `tools/apply.ps1` rewritten to deploy `modded/sk-rework/` → `<game>/mods/`.
- **13 workshop mods inventoried** (`notes/mods.md`) incl. Royal Card Lab
  (≈ our card picker) and Glac Terminal (modder debug tool). Dev's modding
  guide cloned to `uploads/modding-guide/` (has SUGAR_manual.txt +
  vanilla `CARDS` table in vanilla_stuff/).
- **Game copy analyzed**: v1.623b, Goldberg-emu repack. `data.sgr` = 79 MB
  compressed package holding all 278 game files (full list:
  `notes/data-sgr-filelist.txt`); contents not plaintext — decision: don't
  crack it, introspect at runtime via debug mod instead. Loose `lang/*.txt`
  = readable string tables (saved to uploads/game-insights/).
- **"Mod won't load" mystery SOLVED**: owner's `King's Court.rar` sat
  unextracted in mods/, AND it's a pre-info.lua 2022 mod (see notes/mods.md).
- Sandbox tooling: compiled unrar 7.20 from source (kept at
  `uploads/tools/unrar`); GitHub raw/release URLs blocked but git+api work.
- why: the entire Phase 0/1 premise changed once real files were examined.
- status: shipped (docs + tooling; no game files modified)

## 2026-10-03 — Phase 0 prep: embedded-pack handling

- `tools/recover.md`, `tools/repack.md`, `PLANNING.md` §8 updated: the game
  ships with its pack **embedded in the exe** (owner confirmed: no loose .pck
  in the install folder). Recovery points `--recover` at the exe; repack uses
  an export preset with "Embed Pck" ticked (or gdre_tools `--pck-patch
  --embed`) and installs by replacing the exe under its original filename.
- why: `--recover` accepts pck/apk/embedded-exe natively (gdsdecomp docs);
  an exe-embedded game ignores a dropped-in .pck, so install must swap the exe.
- status: shipped (docs only, no game files touched)

## 2026-10-03 — Phase -1: repo scaffold

- No game files touched. Created the PLANNING.md §2 structure:
  `.gitignore`, `README.md`, `tools/` (recover.md, apply.ps1, repack.md),
  `modded/`, `notes/` (map.md, changelog.md), `game-dump/` (ignored).
- Renamed the handoff file `2026-10-02-shotgun-king-plan.md` → `PLANNING.md`
  as the plan itself prescribes (§2).
- why: working structure must exist before Phase 0 so nothing we keep ever
  lands outside `modded/`.
- status: shipped
