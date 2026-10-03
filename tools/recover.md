# recover.md — get the game + (optional) its source

> Engine correction (2026-10-03): the game is **SUGAR** (custom Lua engine),
> not Godot — see PLANNING.md §0.5. No gdre_tools, no .pck, ever.

## 0. What we have / what's missing

- Owner uploaded the game to the GitHub repo as a **split RAR**:
  `Shotgun.King.The.Final.Checkmate.v1.623b.part4.rar` — **parts 1–3 are
  missing**, and a split RAR needs ALL parts to extract anything.
- 13 workshop mods + the dev's modding guide are already secured in
  `uploads/` (inventoried in `notes/mods.md`).

**Owner action needed:** upload the remaining parts (or a single zip of the
game folder) — GitHub **Release** attachments are best (no 25 MB web-UI cap);
see README "Owner's to-do".

## 1. Once we have all parts

1. Extract the split RAR (any machine with WinRAR/7-Zip:
   right-click part1 → Extract Here).
2. Locate the game folder (exe + whatever data ships alongside).
3. **Back the whole thing up** (`ShotgunKing-backup/` — stays out of git).
4. Run the game once — confirms v1.623b boots and creates its save/log dirs.

## 2. Install mods (the 13 downloads)

Mods go in `<game folder>/mods/<mod folder>/` — the folder name MUST equal the
`name=` field inside that mod's `info.lua` (e.g. `show exclude`, NOT
"Better Codex"). Enable in the in-game mod menu. Full details + pitfalls:
`notes/mods.md`.

## 3. (Optional) source extraction for recon

The game's Lua scripts ship inside the distribution (exact packaging TBD from
the full archive — likely embedded in/near the exe). When we have it:

- Try `7z l` / `unzip -l` on the exe and any data files — an appended zip is
  the common pattern.
- Whatever we extract goes to `uploads/game-src/` (gitignored) and is
  **reference only** — our deliverable is a mod, not a patched game.
- Re-check `notes/map.md` "TBD" entries against the real source.

## 4. If a game update lands

Mods keep working (that's the point of mod-first). Re-do step 3 only if we
need fresh recon; note the new version in `notes/map.md`.
