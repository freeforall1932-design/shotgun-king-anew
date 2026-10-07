# Game internals — read from the decoded game source (session 10)

> Source: the owner's own game copy, once stored unpacked in this branch under
> `game/` and decoded with `tools/sgr_extract.py` into `game/decoded/`. That
> payload was removed from the current tree at the owner's request
> (2026-10-07, HANDOFF §2b), so the line numbers below refer to the historical
> `game/decoded/…` revision and cannot be re-checked from this checkout unless
> the decoded sources are supplied again. **These are facts read from the
> code, not guesses.** Where they contradict older live-test inferences
> (HANDOFF §3), this file is the more reliable one, though the code still
> beats any note.

## 0. data.sgr container (implemented in `tools/sgr_extract.py`)

```
python3 tools/sgr_extract.py game/data.sgr game/decoded           # code + gfx + lang (~24 s)
python3 tools/sgr_extract.py game/data.sgr out --all              # + fonts, sfx, music (~92 MB)
python3 tools/sgr_extract.py game/data.sgr --list                 # entry table only
```

- Whole-file and per-entry cipher: seed = BE32(last 4 bytes) ^ 0x550f0f55 →
  xorwow PRNG; discard `r&15` draws; XOR every EVEN byte below `len-4` with
  `next()&0xff`. Located in the exe at loader 0x4aa050 / decrypt 0x49d550 /
  PRNG 0x4181a0, 0x4181f0.
- Outer layer: BE32 uncompressed size + zlib over `[4 : len-4]`.
- Container: `str title, str dev, str main_file` (`str` = u16 BE length +
  bytes), then repeated `str path, u8 flag, BE32 size, blob` (blob encrypted
  like the file; strip its last 4 bytes after decrypting). 279 entries; 3 with
  flag 1 are glob manifests (`assets/gfx/*.png`, …); `assets/gfx/gfx.png`
  appears twice; paths may start with `../`.

## 1. Main loop, entities, buttons (code.lua ~14955–15420, libs/ents.lua)

- `_update()` (15322): `_t+=1`, **`cancel_but=nil`**, then `lp()` (1× per frame,
  N× when `fast` is set — fast-forward): **`gamepad_ctrl()` first**, then
  `foreach(ents, upe)` in insertion order (children update inside the
  parent's `upe`). Then the pause menu (`open_menu`) handling.
- `gamepad_ctrl()` (code/gamepad.lua:789), MOUSE branch (~900): `mx,my =
  btnv"mx",btnv"my"`, **`mcl = btnr("validate")`** (click fires on RELEASE),
  `mcr = btnr("special")`, **`mlb = btn("validate")`** (held), then `return`.
  The engine's own "consume this click" idiom is `mcl=false` (menu.lua:39,
  1561, 1768, 1781).
- `mke(fr,x,y)` (15149) appends to `ents`; `kl(e)` (15300) sets `e.dead` and
  deletes `e` from `e.par.ents or ents`; `add_child` puts a child in `e.ents`.
- `draw_game()` (957): entities are bucketed by `e.dp` (**16 buckets, 0..15**;
  `DP_BG=0 … DP_FX=4, DP_INTER=5, DP_TOP=6`, code/data.lua:44) and drawn in
  bucket order — dp 15 draws above everything. Pause darkens buckets below
  DP_TOP. Screen `MCW=320, MCH=180` (data.lua:38); board 8×16 px squares →
  `board_x=96`, `board_y=30` (code.lua:336) → board = x 96..223, y 30..157.
  The speedrun chrono uses the bottom-right corner.
- `mk_but(x,y,w,h,f)` (14958): `e.button=true`, `dp=DP_INTER`; its `upd`
  returns early if `btn"force_aim"` or **`cancel_but`**; hit test adds parent
  offsets; on `mcl` (and `ctrl_mode~="aim"`) runs `left_clic`. `e.cover` +
  hover sets `cancel_but=1`, which blocks only buttons updated LATER in the
  same frame. **Every overlapping button fires on one click** — that is how
  run 6's CLIP+ also moved the king.
- `mk_sq_but(sq,…)` = board-square buttons (`dp=DP_FX`, `issq`), recreated
  every turn.
- `mk_text_but(x,y,ww,str,f)` (code/menu.lua:1862): a VISUAL entity `e`
  (no `button` flag, 11 px tall, colours: fill 3 / hover 5 / text 4, locked
  2/1) with a child `b=mk_but(…)` stored as `e.but`. Remove it with `kl(e)`.
- `remove_buts()` (15107) — called ~40× per turn by the game itself: deletes
  entities with `e.button` (recursing into `e.ents`), AND sets
  `selecting/timerun/playing/leveling/aiming=false`, clears every square's
  `selectable/show/imprint/pad_but`, kills `pad_cursor`, `mode.track_but=nil`.
  **A mod must never call it** — it ends the player's turn state.
- `reset()` (290, called by `init_game` 310) does **`ents={}`**: everything a
  mod created is gone at every new run. Only `reset()` and `remove_buts()`
  bulk-remove entities.
- Text: `local sav=font(); font("pico"); lprint(s,x,y,col,align); font(sav)` —
  pico = 3×5 PICO-8 font, 4 px advance; `lprint(…, align=1)` centres on x
  (libs/hdtext.lua:57).
- Screen-state globals: `ingame` (true in a run), `pause`, `menu` (non-nil
  while a menu is open; `close_menu` → nil; game-over sets `menu={}`),
  `leveling` (card-choice overlay; `level_up` 2034 sets it, only
  `remove_buts` clears it), `any_card_menu`, `codex` (main menu only).

## 2. Mod sandbox (code/mods.lua)

- `safe_require(folder, file, replaceable, allow)` (173). Mod globals live
  in a `ctrl` table: **reads** fall through to the engine `_G`; **writes**
  reach `_G` ONLY for keys in the replaceable list (run_mods, ~700):
  `DEV START_LVL FORCE_WHITE_ARMY DUMMY FRAGILE SHOW_BUTS TEST_CARDS TEST_SOULS
  OVERWEIGHT BOOT game_mode CARDS PIECES EXCLUDE AUTO_REPLACE FIRST_ARMY
  HERO_INIT TAGS hero heir leader pentasquares waypoint ammo chamber grenades
  stack scepters menu bg white_army perm mode cards mx my mcl mlb mcr mMenu
  VISION`. A write to any OTHER existing global → red rlog "Not allowed to
  change value for index …"; a write to an unused (nil) name is stored in the
  mod's own table and the engine never sees it (e.g. `cancel_but=1` from a mod
  does nothing). Table FIELDS (`hero.hp=…`, `stack.x=…`) are unaffected.
- Forbidden (61): `safe_require rm cd delsfx delmus delsrf logdupe setfenv
  getfenv steam steamws discord load stop execute export help man changelog
  mantxt url progress _G _S DEN MODSAV`. `pcall` is NOT on the list (no
  shipped mod uses it; sk-rework Build 8 guards it with a type check).
- **Asset loaders** `newsrf/newsfx/newmus/newfnt` are wrapped (75–95):
  `(name, "file.ext")` → `_G[k](name, "mods/<mod>/file.ext")` ✓;
  `newsrf(name, w, h)` (number) passes through; any other shape falls to
  `_G[k]("mods/<mod>/"..second_arg)` with ONE argument — so the old
  `newsrf("file.png", "name")` order tries to load a file literally called
  `mods/<mod>/name` → `'… didn't match any files'` and the surface never
  exists (fairy: "Cannot set inexistent surface"). Seven vendored mods had
  that order; fixed in Build 8 (see `notes/mods.md`).
- `append(name, after, id)` (101): wraps the global; `after(...)` runs after
  the original **even if it returned early**, with the same args; same id
  replaces, `after=nil` removes. `prepend` analogous.
- Banks: `newbnk/bget/bset/savbnk` are per-mod (`save/mods/<folder>.bnk` +
  `.bnk_bak`); `SAVE` = `MODSAV[folder]`.
- `load_mods` / `run_mods` (~560–720): `mods/modlist.lua` = ordered
  `{name, active}`; mods load **top to bottom**; `MODS[name]=mod` is filled as
  each one loads (so a mod sees only mods ABOVE it in `MODS`, and `mod.env`
  only for those). New folders are inserted by `priority_hint`, and default
  to active only if they have no `script.lua`.

## 3. Weapons (code/modes/throne.lua)

- `weapons={…}` at the top of throne.lua lists the 9 base guns (gid 0
  Solomon, 1 Victoria, 2 Ramesses II, …); the mode's initialize re-registers
  `newsrf("weapons", "assets/gfx/weapons.png")` (line 69) — per-mode weapon
  sheets are the intended pattern (Nightmare / Quartz Throne do the same).
- Mod modes keep their own unlocks in `save/mods/<mod>.bnk`: `bget(i,4)==1`
  = weapon i unlocked, `bget(0,1)+1` = max rank (Quartz/Nightmare/Card Lab
  ship 7 guns, Fairy 5). Completing those lists = Build 8 item 4 (not yet
  approved).

## 4. How Build 8's panel uses these facts

See the header of section 4 in `modded/sk-rework/script.lua`: one plain
entity at dp 15 draws the panel (no `button` flag → `remove_buts` can't touch
it; re-created when `ents` is replaced); an `append("gamepad_ctrl", …)` hook
hit-tests the tab/panel and consumes the click with `mcl/mcr/mlb=false`
before any `mk_but` updates. The panel hides while `leveling`, `pause`,
`menu`, `any_card_menu` or a live `codex` is set.
