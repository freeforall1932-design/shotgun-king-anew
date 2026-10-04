# notes/map.md — code map of Shotgun King

**Game version:** v1.623b (from owner's archive name) · **Engine: SUGAR v0.0.8f**
(custom Lua engine by Rémy Devaux — NOT Godot; runtime version from live logs,
see PLANNING.md §0.5) · **Scripting:** LuaJIT 2.1 / Lua 5.1.

**Status: live-verified runs 1–4 + vendored-mod cross-referenced.** Run 4
(2026-10-04, build 5) harvested the full card/piece/soul dump but **crashed at
load** in the input probe — root cause and the permanent safety rule are in
§"Input, UI & Persistence" below. Build 6 fixes it and is pending a new live
run. Sources: `notes/game-map-draft.md`, `live testing result/SUMMARY.md`, and
the 13 mods in `dist-overlay/mods/` (`notes/mods.md`).

---

## Where the knowledge lives right now

| Source | Location | Contents |
|---|---|---|
| Live game map draft | `notes/game-map-draft.md` | 920 globals, 41 replaceable, 26 forbidden, 14 MODLIST entries, 186 CARDS entries, live object fields |
| Workshop mods (vendored) | `dist-overlay/mods/` | 13 real mods; verified API usage patterns (`notes/mods.md`) + full vanilla `CARDS`/`EXCLUDE`/`PIECES` tables in `Shootout/script.lua` |
| Modding guide (owner machine) | `uploads/modding-guide/` | info.lua format, SUGAR_manual.txt, vanilla mode scripts |

## Ammo / shells (`ammo`, `chamber`, `grenades`, `stack`)

Known stat fields (vanilla card data): `ammo_max`, `ammo_regen`, `chamber_max`,
`pawn_shell`, `rook_shell`, `bad_shells`, `spread`, `firepower`, `firerange`,
`recoil`. Hero stat block (Fairy Endless / Card Lab): `{name, chamber_max,
firepower, firerange, spread, ammo_max, knockback, pierce, blade}`.

- **Runtime count globals (live map + reference usage):**
  - `ammo` (replaceable global) is the reserve-shell counter: `glacies collection`
    reads it in conditions and updates it directly for negative ammo effects.
  - `chamber` (replaceable global) is the loaded-shell counter; `reload(true)`
    loads one shell and `reload()` performs the standard reload.
  - `grenades` is a live global; `shields` appears in Glacies effect code, but
    its storage/replaceable status is not established by the live dump.
  - `hero.ammo` and `hero.hp` are live-observed fields. Whether `hero.ammo`
    mirrors reserve `ammo` throughout every state is not yet pinned down.
- **Spend / refill / stat functions** (`glacies collection/script.lua:1079–1209`):
  - `give_ammo(from_ent, n)` is used when the effect has a source card/piece;
    otherwise the same effect calls `inc_ammo(n)`. Negative ammo effects do
    `ammo = ammo + n` directly.
  - `reload(true)` loads one shell; `reload()` does a full reload;
    `add_event(ev_reload, true)` queues the delayed single-shell load;
    `add_event(ev_reload)` queues the ordinary reload.
  - `can_reload()`, `need_reload()`, `refill_ammo()` are present in the live
    global map; exact call contracts need source/runtime confirmation.
  - **Stat changes:** run-persistent effects use
    `add(upgrades, { [stat] = val })` then `build_stack()`; floor-temporary
    effects call `uplift({ [stat] = val })`; turn/shot effects call
    `boost(stat, val)`. These are reference-mod patterns, not all independent
    owner-facing cheat APIs.
- Card data includes caps/modifiers such as `ammo_max`, `ammo_regen`,
  `chamber_max`, `grenades_max`, `firepower`, `firerange`, `spread`, and
  `recoil`; each only contributes when the matching card/stack logic is active.
- Vanilla rules from Better Codex: can't have 0 max ammo; ≤5 soul slots;
  ≤3 scepters; ≤1 right-click ability; no grab+blade combo.

## Cards / perks / drafting (`CARDS`, `EXCLUDE`, `level_up`, `get_slot_cards`)

- **Data:** global `CARDS` table — 186 cards in v1.623b (`gid` 0–192, `ext` 0–3;
  base definitions preserved in `dist-overlay/mods/Shootout/script.lua` lines 53–169).
  Fields: `gid, ext, n (copies), id (display name), pwe (offer weight, default 4),
  team (0=black, 1=white), played, ignored, need/need_card/need_tag/need_soul/
  need_chamber_max/need_grenade, exclude_tag, special, wand, flip_on, wild,
  gain/sac, delay/cycle/delayed` + effect fields.
- **`EXCLUDE`** = mutual-exclusion pairs (`{"Royal Loafers","Sawed-off Justice"}`,
  `{"Militia","Bloodless Coups"}`, `{"Guillotine","The Secret Heir"}`,
  `{"The Red Book","The Royal Hunt"}`, `{"The Red Book","Buckler of Limos"}`).
- **Right-click abilities (`special=`):** the owner reports 10 vanilla cards
  (values include `strafe`, `scope`, `decree`, `grenade`, `orb`, `dig`), and
  live `stack.special` is observed. The checked-in `Shootout/script.lua`
  contains representative base definitions, but its `special=` entries alone
  do not account for the full owner-reported set. Build-5 `SKCF|` will dump all
  live card fields and settle the exact card IDs/count.
- **Wands / scepters (`wand=`):** the vanilla card table has `wand={...}`
  definitions (e.g. Downpour `{0,10}`, Frenzy `{1}`, Wrath `{2,"firepower"}`,
  Wings `{3,3}`, Gust `{4}`, Hypnosis `{5}`). The live map confirms a
  replaceable global named `scepters` and functions named `add_scepter`,
  `activate_scepter`, `get_scepter`, `recal_scepters`; their runtime shape,
  activation arguments, and relationship to `wand=` are **still unverified**
  (Build-5 `SKS|` probe).
- **Card/offer functions & flow:**
  - `new_card(id)`, `add_card(ca)`, `replace_card(old_id, new_id, cb)`,
    `tear_apart(ca, cb)`, `init_codex()`. Royal Card Lab and disgraced_justice
    call `get_slot_cards(true)` to enumerate cards currently in owned slots;
    `card_slots` holds physical slot records `sl.ca` / `sl.team`.
  - `level_up(data, next_fn)` receives draft config with `choices`/`force`
    (Nightmare mode reference); `pick({team=...})` selects an eligible card
    (also used in Nightmare examples), while the exact vanilla offer filters
    are still unknown. `add_any_card({team=...}, cb)` is used by Royal Card
    Lab to reopen a choice from the pool. Build-5 `SKOF|` probes `level_up`,
    `pick`, and `is_card_available` without changing the roll.

## Enemies / spawning / floors (`PIECES`, `new_piece`, `spawn_pieces`, `gsq`)

- **Data:** global `PIECES` table (replaceable; 12 vanilla entries `type=0..11`:
  `0=pawn`, `1=knight`, `2=bishop`, `3=rook`, `4=queen`, `5=king`, `6=boss`,
  `7=all`, `8=leader`, `9=cannonball`, `10=queen mother`, `11=horseman`; full
  schema in `Shootout/script.lua` lines 179–245). `PIECES_NAMES[name]` maps a
  piece name to its entry (`PIECES_NAMES["knight"].type == 1`).
- **Spawning & conversion (confirmed in `disgraced_justice`):**
  - `new_piece(type, is_bad, sq)` — spawns piece of `type` on square `sq`
    (`is_bad = true` for white enemy, `is_bad = false` for black ally!).
  - `fx_spawn(p)` — spawn animation; `convert(target_p, cb)` — converts an
    enemy piece to an ally (`target.bad = false; setup_piece(target)`).
  - `spawn_pieces()` — floor army spawn (`custom_sort` hooks the spawn list).
- **Board squares:** `squares` global table, `gsq(px, py)` (0..7, 0..7),
  `is_free(sq)`, `get_free_squares()`, `get_square_at(x, y)`.

## Damage / health / death & Bullets (`bullets`, `hit`, `xpl`, `mk_bullet`)

- **Bullets (`bullets` global + `mk_bullet`)**: `glacies collection`'s
  `on_fire()` reads/writes fields including `b.dmg`, `b.pierce`, `b.shot`,
  `b.vx`, `b.vy`, `b.x`, `b.y`, `b.t`, `b.life`, and `b.upd`; its fragment
  effect constructs bullets with `mk_bullet(x, y, angle, speed)` and sets
  damage/pierce. This proves the reference mod relies on those fields, but
  does **not** prove which engine event applies every bullet hit.
- **Direct damage helpers** (reference calls): `hit(p, dmg, tags)` is used
  directly (e.g. aura damage and hook damage); `xpl(p)` explodes/kills a piece;
  `mode.heal(p, hp)` is provided by Glac Terminal and used by Glacies
  Collection. `inflict(p, "bleed")` and `stun_piece(p, turns)` also appear in
  the live global map/reference API. These helpers are confirmed to exist or
  be used, but `hit()` being the universal bullet/king damage path is **not**
  established.
- **Build-5 `SKD|` probes** are configured to hook `fire`, `mk_bullet`, `hit`,
  `ev_hit`, `damage`, `damages`, `fx_dmg`, `bleed_dmg`, `hop_dmg`, `xpl`, and
  `xpl_king` when present. They will log post-fire bullet fields and damage
  arguments; no multipliers/crit logic runs yet. Their output still needs the
  owner's live run before any insertion point can be called verified.
- Vanilla card fields include `knockback`, `pierce`, bleed tags, `recoil`,
  and leech-like `leader_queen_vampire`; numeric meanings are card-specific.

## Input, UI & Persistence (`btn`, `mk_text_but`, `mk_menu_but`, `newbnk`)

- 🛑 **`btn()` IS A LANDMINE — live-proven, run 4 (build 5 crashed the game at
  load).** `btn(name)` / `btnp` / `btnr` accept (a) named actions the game has
  registered and (b) input ids of the form `[k/m/c]:[key/button/[axis:direction]]`.
  Any other string falls through to the input-id parser and its failure is
  **FATAL**: the game logs `!! Not recognizing button '<x>'…`, `!! Malformed
  input id '<x>'…`, then `ERR Button <x> for player 0 doesn't exist.` and quits
  ("Quitting required"). There is **no pcall in the mod sandbox**, so a wrong
  probe cannot be caught — it ends the run. Never call `btn*()` with a string
  that a live dump has not already published. Run 4 died on `btn("left")`
  (`modded/sk-rework/script.lua:817`); `btn("left"/"right"/"middle"/"mouse4"/
  "wheel"…)` are exactly the unsafe class.
- **Confirmed callable (non-fatal) named buttons:** `unsafe`, `cancel`,
  `ctrl` (all returned `false` at load in run 4), plus the registered actions
  from the live assignment dump: `validate`, `cancel`, `shoot`, `special`,
  `reload`, `unsafe`.
- **`INPUT_ASSIGNEMENT` is a formatted STRING** (not a table), dumped live as:
  `validate> c:a, m:lb` · `cancel> c:b, k:escape` · `shoot> c:rtrigger` ·
  `special> c:x, m:rb` · `reload> c:y, k:space` · `unsafe> c:ltrigger, k:lshift` ·
  `mx> m:x` · `my> m:y` · `lb> m:lb` · `rb> m:rb` · `mouse_move> m:x, m:y` ·
  `mouse> m:lb, m:rb, m:mb, k:escape, k:return, k:space, k:lshift, k:lalt, k:ralt` ·
  `ctrlr> c:lstick:left … c:lshoulder`. It is the authoritative list of what
  the running game answers to.
- **Mouse code space published by the engine: `m:lb`, `m:rb`, `m:mb`
  (+ `m:x`, `m:y` axes).** No mouse4/mouse5/wheel ids appear anywhere in the
  live dump. Binding the owner's two side buttons is therefore **unproven** and
  must be attacked as a deliberate, isolated experiment (a build that tries one
  candidate binding on its own, restartable) — never as a blind load-time
  probe. Phase-4 remap design: offer confirmed codes first; treat extra buttons
  as experimental until a run proves they exist.
- `MOUSE` is a **boolean** (`true`), not a table; `mx`, `my`, `mcl`, `mcr`,
  `mlb` are `nil` at load (per-frame values). `SHOOT_BUTTON=RT`,
  `RELOAD_BUTTON=Y`, `SPECIAL_BUTTON=X`, `CONFIRM_BUTTON=A`, `SNAP_KEY=k:f1`.
- `defbtn(name, player_idx, key_spec)` exists live (Glacies uses
  `defbtn("…", 0, "k:grave")`) — but see the landmine: a bad `key_spec` may be
  just as fatal. Only pass codes copied from the live dump.
- **Native UI:** live globals include `mk_text_but(x, y, w, label, fn)`,
  `mk_but(x, y, w, h, fn)`, `mk_menu_but(id, x, y, w, h)`, and
  `mk_hint_but(x, y, w, h, text, colors)`. Royal Card Lab modes use
  `mk_text_but`/`mk_but`; Glac Terminal exposes `on_menu_but_init(but,id)` as
  a Terminal-dispatched mod callback, but Build 5 uses additive hooks and
  native `mk_text_but` controls rather than defining a global `on_*` name.
- **Per-frame/update APIs:** `loop(function() … end)` and entity `mke()` are
  available in the game, but sk-rework avoids global `upd`/`on_*` dispatchers.
  Its Build-5 Dev panel is native-button-driven; it does not draw an overlay.
- **Mod-specific persistent settings:** Royal Card Lab uses
  `newbnk(128,64,4)` + `bget`/`bset`/`savbnk()`; Nightmare mode demonstrates
  a `SAVE.nightmare` preference table. Build 5 uses the bank pattern for its
  God Mode toggle if those functions exist. The game also writes
  `save/mods/<mod>.sav` + registry; direct `SAVE.<mod>` usage is mode-specific,
  not yet confirmed as a universal script API.

## Introspection cheat-sheet

```lua
_log(ser(gimme("global")))      -- all global names (functions + vars)
gimme("forbidden")              -- what mods may NOT touch
gimme("replaceable")            -- globals mods may replace outright
gimme("autocall")
append("fn_name", nil, "id")    -- unregister a hook
```

---

## Open questions / next intel steps

**Build 6 status (2026-10-04):** run 4 harvested the full load-time probe
chain (cards, EXCLUDE, pieces, souls, offer candidates — see the run-4 section
below) and then crashed in the `btn()` probe; build 6 fixes that probe and adds
per-block checkpoints. The **next owner run must happen in play**, because
everything runtime-only is still unobserved: `SKD|` damage traces (fire/hit),
`SKOF|` live offer rolls, `SKS|` soul/scepter activation, `SKI|menu_button/`
`menu_but` IDs (mod-menu detection + Back/legend), Dev-panel clicks, and
`SKUI|bank` config persistence. Do not promote results from the fake SUGAR
smoke test as game facts.

1. ~~game archive incomplete~~ → **SOLVED 2026-10-03**: all 4 parts uploaded,
   extracted (see changelog). Game copy analyzed; full file list in
   `notes/data-sgr-filelist.txt`.
2. `data.sgr` (79 MB) is a compressed/encrypted SUGAR package — no public
   format docs (SUGAR engine is not open-source; only `sugarcoat`, a Lua
   interface for Castle/Love2D, is). **Decision: don't crack it.** We get the
   same intel at runtime via the live diagnostic mod (`gimme("global")` +
   `_log`); the Build-5 follow-up probes now cover remaining feature unknowns.
3. **SAVE FORMAT FULLY CRACKED 2026-10-03** (see tools/save_codec.py):
   `save/*.sav` = `[4-byte BE plaintext length][zlib stream]`; payload is
   PUNKCAKE serializer text (`PUNKCAKE\nt{ ... }\nFOREVER`; types: t table,
   s"key"~: (0x1F before colon), n number, bTrue/bFalse, f"file", s"str").
   Verified decode+encode on all 6 saves. Files: reg.sav (registry: which
   files exist), prog.sav (progression: throne lvl, best_time, badges,
   weapon_unl — the cheat target), stats.sav (per-card played/ignored — the
   card-offer memory; picker phase can edit it), achievements.sav, runs.sav,
   misc.sav (codexitems). No mod-enable state anywhere in saves → **resolved
   by the live tests: mod support is always active, but each mod's on/off
   state lives in `mods/modlist.lua` (absent entry/false = OFF — run 2
   corrected run 1's guess), which the game writes itself at boot** (§live).
   Zlib note (audit 2026-10-04): the game's own writer emits FLEVEL-0
   deflate whose exact bytes python-zlib cannot reproduce (game sizes sit
   between zlib L0 and L1 on every real save). The game READS any valid
   zlib stream — our tool's level-9 output was read back fine in live
   runs 2–3 (unlock persisted). Byte-exactness is guaranteed at the TEXT
   layer (`save_codec.py --selftest`), not the container bytes.
4. Game internals known from its log: runtime SUGAR **v0.0.8f**, LuaJIT 2.1 /
   Lua 5.1, SDL 3.4.12. Top-level files: exe, data.sgr, `lang/*.txt` (18
   languages, readable string tables — copy in `uploads/game-insights/`),
   `mods/`, `save/`, `settings.txt`.
5. `code.lua`, `code/gameplay.lua`, `code/data.lua`, `code/mods.lua`,
   `code/modes/*.lua`, `code/codex.lua`, `code/save.lua`, `code/grid.lua`
   exist INSIDE data.sgr (names + paths known; contents not extractable
   without cracking the format — see 2).
6. This game copy is a Goldberg-emu repack (steam_settings/, steam_api.dll
   9 MB) — not a vanilla Steam install. Fine for mod dev; just don't expect
   Steam Workshop features to work in THIS copy (UPLOAD button needs real
   Steam).
7. Reference repos spotted, worth mining later: modderongithub/shotgun-king-mods,
   Shotgun-King-Puzzle-Developers/Shotgun-King-Puzzle-Mod.

---

## Live-verified facts — run 4 (2026-10-04, build 5, v1.623b)

The load-time probe chain ran to completion for cards/EXCLUDE/pieces/souls/
offers, then the run died in the input probe (see the btn() landmine above).
Everything below is from the real game, not the smoke test.

- **Full live API surface — `gimme("global")` intersects the planned list at
  63 names**, including the whole gameplay-API set the §0.7 features need:
  `inc_ammo`, `give_ammo`, `reload`, `pick`, `add_any_card`, `level_up`,
  `is_card_available`, `fire`, `mk_bullet`, `hit`, `ev_hit`, `xpl`,
  `add_soul`, `activate_soul`, `add_soul_slot`, `remove_soul_slot`,
  `exhaust_soul`, `add_scepter`, `activate_scepter`, `recal_scepters`,
  `get_scepter`, `newbnk`, `bget`, `bset`, `defbtn`, `btn`, `btnp`, `btnr`,
  `mk_text_but`, `mk_but`, `mk_menu_but`, `EXCLUDE`, `PIECES`, `TEST_SOULS`,
  `MOUSE`.
  **Absent (5):** `append`, `prepend`, `gimme` (mod-env functions, never in
  the global list), `savbnk` (bank saving is the engine's automatic
  `save/mods/sk-rework.sav` write — run 4's exit did write that file), and
  `scepters` (not a global; scepter state is reached through the scepter
  functions above — it is only in `gimme("replaceable")`).
- **Cards: 186, every field dumped** (`SKCF|`, 3353 lines — full dump in
  `notes/game-map-draft.md`). The `special=` (right-click ability) set is
  exactly **10 cards**: `strafe` Royal Loafers · `scope` Engraved Scope ·
  `decree` Unjust Decree · `grenade` Kingly Alms, Philanthropy, Indelible
  Memories, Sacred Light, Guerilla Tactics · `orb` Seer's Orb · `dig` Shovel —
  confirming the owner's count and the cap-removal probe target. Other card
  fields seen: `wand` (table; the Wand-* family), `soul_slot` (1/2),
  `need_soul` (1/2), `pwe`, `gid`, `ext`, `sac`, `gain`, `need`, `need_card`,
  `need_tag`, `exclude_tag`, `tags`, `team`, `terrorism`, `ammo_max`.
- **Offer-eligible candidates** (`SKOF|` at load): 25 cards carrying
  `special`/`wand`/`soul_slot`/`need_soul` — e.g. Majestic Censer (`soul_slot=1`),
  Sacred Crown (`need_soul=1`), Possessed (`soul_slot=2`), Gradual Absolution
  (`need_soul=2`), the Wand family (`wand=tbl`). These are the cards a
  free-choice picker must respect.
- **Pieces: 14 live definitions** (`SKS|piece_*`), fields `type`, `name`,
  `hp`, `tempo`, `danger`, `seek` (`wdist`/`kdist`), `reap`, `sided`, `hdy`,
  `index`, and a `behavior` table of vectors (`{native=1, move=1, id="line"}`,
  `{native=1, atk=1, …}`). This is the schema the ally-summon and soul-piece
  features must construct.
- **`TEST_SOULS` exists but is empty at load** (`fields_shown=0`) and
  `hero.free_souls` is a live field — soul contents are runtime state; the
  `SKS|` activation hooks (never reached in run 4) are the live path.
- `MOUSE=true` (boolean) and `INPUT_ASSIGNEMENT` is a formatted string — see
  the input section for the full text.
- **Damage/bullet path: still unobserved.** No `SKD|` line was ever emitted
  (run 4 never reached gameplay). Damage multipliers stay gated.

## Live-verified facts — live tests 1–3 (2026-10-03, builds 3–4, v1.623b)

Source: live runs 1–3, 2026-10-03 (raw evidence since consolidated into
`live testing result/SUMMARY.md`; run 1: inherited-mods + `-NoInheritMods`
builds; run 2: full `-GetInsights` pack — log, `mods/modlist.lua`, whole
`save\` folder; run 3: pre-enable verification + save-and-reboot path) +
parsed draft `notes/game-map-draft.md`. These are
OBSERVED facts — prefer them over anything guessed above.

### Engine / log
- Every game log line is wrapped in `  . ` (info) or ` !! ` (warning)
  markers; `_log()` output included. `tools/parse_log.py` strips them now
  (the first live test exposed that missing this = false "mod did not run").
- Lua errors appear at the END of log.txt (confirmed pattern).
- **Mod-menu "save and reboot" = soft reboot inside the SAME log.txt**
  (run 3): subsystems shut down (`Deleting window… main loop exit`), then
  data.sgr + all mods RELOAD (every mod script runs a second time → all
  dumps appear twice) — there is no second `Starting log.` line.
- **Log-write collision on that reboot path** (run 3): the engine's writes
  landed on top of an in-flight mod `_log()` line (boot 1's SKC dump was
  truncated mid-line at card 177 and its tail — 9 cards, `SKC count`,
  `READY`, `loadfile`, `PROBE done` — was lost; line order around the
  transition is non-chronological). So **a missing READY line in a
  rebooted session does NOT mean the mod failed** — check the BUILD banner
  and the post-reboot load. `parse_log.py` now dedupes multi-boot dumps
  (cards by id, hooks by target+id; last occurrence wins).
- The engine looks for `save/mods/<mod>.bnk` at each boot
  (`!! Could not open file … .bnk` warning, benign — the per-mod save slot
  works without it; related globals: `bank`, `_savbnk`, `MODSAV`).

### Mod loading & enable state (run 2 corrected run 1's guess)
- **Mods start OFF by default.** The mod menu shows untouched mods in black
  text; the owner's run-2 `modlist.lua` stores `false` for all 13 workshop
  mods (only `sk-rework` is `true` — toggled manually by the owner). Run 1's
  "ON by default" conclusion was wrong.
- `mods/modlist.lua` **on-disk format (byte-verified)**: a Lua chunk
  `return {` CRLF `\t{ '<mod name>', <bool> },` … `}` — tab indent, trailing
  comma on EVERY entry incl. the last, CRLF line endings, closing brace,
  no trailing newline, no BOM. Order = load priority. The game writes the
  file itself at boot/after menu interaction; `build-dist.ps1` now writes it
  too (verified byte-identical to the game's own file for the same states),
  pre-enabling `sk-rework` (`-AllModsOn` = everything on).
- `loadfile` does **not exist** in the mod environment (`SKA2|loadfile=no`,
  run 2) — the build-4 `SKML|` in-log probe could never fire; the harvested
  file (via `apply.ps1 -GetInsights`) is the way to learn the format.
- Per-mod saves exist: `save/mods/<mod-save-name>.sav` + `save/mods/reg.sav`
  (registry mapping save-name → file path, e.g.
  `s"sk-rework"\x1f: f"save/mods/sk-rework.sav"`). Written by the engine at
  quit. **Container differs from main saves: raw PUNKCAKE plaintext, no
  `[u32 len][zlib]` wrapper** (sk-rework.sav = 24 bytes:
  `PUNKCAKE\nt{\n}\nFOREVER`). An active mod gets its slot automatically
  (MODLIST entry field `save=`); `MODSAV`/`save` globals exist — candidate
  API for sk-rework's own persistent config (cheat panel / balance knobs).
- The game keeps `.sav.bak` snapshots (one generation) next to saves it
  rewrites (run 2: `achievements.sav.bak` = the owner's original 27; our
  tools never write `.bak` files, and `apply.ps1 -GetInsights` only copies).
  Useful as a free extra safety net.
- `MODLIST` entry fields (build-4 `SKM|` dump): `title, name, folder, save,
  active, priority_hint, author, cover, desc, num, here, exists, id,
  script, modes, langs, mode_description, mode_record`. `priority_hint`
  comes from info.lua; `num` = menu position; `here` = folder present.
- In-game mod menu: click **Play** — top entry. **Black
  text = OFF, white text = ON** (click toggles; survives restarts);
  up/down arrows = load priority (override order), renumbering is cosmetic.
- Title bar with an active mod: `MODDED: ON - ACHIEVEMENTS: OFF` = *Steam*
  achievement tracking paused. Save-side achievements are **preserved** —
  proven end-to-end by the owner's full console log: unlock-all ran
  22:49:38 (128 set True) → modded session (sk-rework active, build 4) →
  quit → `-GetInsights` fetched the save AFTER all that, and the fetched
  `achievements.sav` still has all 128 True. ⚠️ Analysis footnote: an early
  read of run 2's `achievements.sav` claimed a "wipe" — that was a
  bool-vs-string comparison bug in the analysis script, not the game;
  `save_codec` parses `bTrue` as Python `True`.

### Mod API (what actually exists)
- `append`, `prepend`, `gimme` are **mod-environment functions**: they work
  but are NOT listed by `gimme("global")` (SKA said `no` while hooks
  registered fine).

#### API patterns from the vendored reference mods (read 2026-10-04)
- **`get_slot_cards(true)`** — reference mods use it to enumerate cards in
  the player's owned slots (Royal Card Lab copies this list for its picker;
  disgraced_justice searches it by `ca.id`). It is not the list of cards
  eligible for the next offer. The vanilla offer roll and its filtering remain
  unverified until Build-5 `SKOF|` is live-tested.
- **`on_card_but_init(but, ca)`** — Glac Terminal gathers this named callback
  from each mod's private `mod.env` and calls it when a card-offer button is
  created; Royal Card Lab wraps `but.left_clic` this way. This is a Terminal
  callback, not an engine `on_*` dispatcher to define in the shared globals;
  sk-rework itself continues to use additive hooks.
- **Input**: mods read `but.left_clic` / `but.right_clic` (state + wrappable
  handlers) and `btn("unsafe")` (named-button query). NO vendored mod uses
  middle click / mouse4 / mouse5 — remap-menu feasibility needs a probe
  (`MOUSE` global, `but` table fields, `btn()` argument space).
- **Souls** (= piece types): `add_soul(type, …)` + `stack.replace_soul`
  (glacies collection `effects.soul`), `activate_soul` global. Custom card
  pattern for soul effects: `concat(CARDS, { … })` with effect fields.
- **Custom cards** (Shootout / fairy pieces defs): fields incl. `gid, n, id,
  pwe, special=, need_card=, need_chamber_max=, need_grenade=, grenades_max=,
  freegren=, firepower=, wild=` — `need_card="Kingly Alms"` shows cards can
  require other cards; `special=` = the right-click ability slot (10 vanilla
  cards carry one: scope, grenade×5, strafe, orb, dig, decree).
- **Vanilla offer caps, documented verbatim by Better Codex** (`show
  exclude` mod info.lua): max **1 right-click ability, 5 soul slots,
  3 scepters**; no 0 max ammo; can't remove so many pieces that hand
  requirements break; no grabbing ability + blade together. These caps are
  what filters the offer roll — the exclusion system the owner wants
  relaxed (right-click cap + scepter cap) is one of these general rules.
  Owner-identified: the "fire whole magazine in 1 turn" right-click card =
  **Unjust Decree** (`special=decree`) — the 10 `special=` cards likely
  cover ALL right-click abilities in v1.623b (correction of an earlier
  speculation that it might be a separate implementation). What scepters
  actually are/how they activate: still unknown → build-5 probe.
- **Soul system** (owner-confirmed semantics): a soul = turn the king into
  a piece type and move like it for 1 turn. Card fields: `soul_slot=N`
  (add slots: Majestic Censer +1, Possessed +2, Succubus +1), `need_soul=N`
  (require filled souls: Sacred Crown 1, Gradual Absolution 2), `gain=N`.
  `hero.free_souls` = empty slots (live-seen = 0 at start). API:
  `add_soul(type, p, sanctity, replace)` (glacies `effects.soul`),
  `activate_soul`, `stack.replace_soul`, `PIECES_NAMES[x].type`,
  `TEST_SOULS`. Summon-family cards (temporary per-floor allies): ext=3
  block Right-hand/Warhorse/Onboarding Party/Rapunzel/Small Key; hologram
  cards Holoking / Soul Projection.
- **Pawn power route (card-driven)**: pawns → ammo is done by CARDS, not
  by the soul system — card fields `pawn_shell=1` (Small Fry Harvest, also
  `ammo_max=1`) and `pawnreap=1` (Cannon Fodder) convert pawns/pawn-souls
  into shells. Related: `PIECES` is a global, moddable table (disgraced_
  justice does `add(PIECES, {…})` to add piece types; type = index).
  **Open (build-5 soul probe): what using a stored PAWN soul actually does
  — movement route (king moves like a pawn 1 turn, the general soul rule)
  vs power route, or both. The soul deck must expose whichever routes the
  game supports — no hardcoded choice (owner 2026-10-04).**
- **Summon blueprint** (disgraced_justice `dj_summon`): find free squares
  (`is_free(sq)`), `new_piece(typ, false, sq)`, `fx_spawn(p)`, pay from a
  hero field (`hero.book_power -= cost`); `convert(target, cb)` turns an
  enemy. `spawn_pieces` / `new_piece` / `setup_piece` are mod-env-callable.
- **`stack` global** = aggregate of owned cards' effect fields (live uses:
  `stack.pierce`, `stack.knockback`, `stack.blade`, `stack.fearsome`,
  `stack.special`, `stack.replace_soul`) — read it to know what the player
  owns without scanning cards.
- **Shot-modifier pipeline** (glac terminal's `get_disp_stats`
  interception): the next-shot stat id is picked by priority
  `jump > fearsome > blade > pierce > knock > f_arc`; `pierce` and
  `knockback` are PERCENTAGES (card fields: A Piercing Truth `pierce=30`,
  Rightful Curtsy `knockback=50`), `blade` a count (Ritual Dagger 1,
  Nightbane 3, Bushido 2), `firepower` = per-bullet damage stat
  (`firepower=-1` on several cards). Interception pattern for the stats
  display: `prepend("get_disp_stats", …)` + `append("add", …)` +
  `edit_disp_stats` callback list. Live globals include candidate damage
  functions `ev_hit`, `damage`, `damages`, `fx_dmg`, `bleed_dmg`, `hop_dmg`;
  Build 5 hooks them for logging, but their exact role/ordering awaits the
  owner's live Build-5 run.
- `edit_disp_stats` is NOT a global either — it is a Glac-Terminal-dispatched
  callback name.
- **`on_*` globals and `upd()` are NEVER called by the engine for plain
  mods** (SKE2 = 0 and no heartbeat during real gameplay). `append()` on
  game globals is the only proven hook mechanism. Do NOT define global
  `on_*`/`upd` names in sk-rework — they can shadow the Terminal's
  dispatchers.
- Counts: 920 globals, 41 replaceable, 26 forbidden (full lists in
  `notes/game-map-draft.md` §6–9).

### Live object model (real field names, from SKO dumps)
- **piece**: `type, hp, hp_max, bad, danger, seek, still, prison_bar,
  vx, vy, x, y, piece, hdy, dp, ysort_dy` + `sq.{x, vy, dp, cl, frict, dcx, fr}`.
- **card**: `id` (= display name, e.g. `A Piercing Truth`), `pwe`, `index`,
  `n`, `dp`, `t`, `chosen`, `ext`, plus effect fields (`pawn_assault`,
  `pawn_hp`, …) and `exclude.N` lists.
- **hero**: `hp`, `ammo`, `sq.px`, `sq.py` (+ full dump in the draft §5).
- **world/turn**: `SKW|turn|bads|bullets|hero_px|hero_py` — bads count drops
  as kills happen; bullets=0 outside shots.

### Cards / codex / saves
- Codex/stats keys = card display names (same as `card.id`).
- **Complete live-verified card set (run 2): the game's CARDS table holds
  186 cards** (build-4 `SKC|` dump: `id|gid|ext|pwe` per card; gid 0–192,
  ext 0–3). The game itself writes **195 entries** to `stats.sav` — the 186
  CARDS names **plus 9 special codex keys tracked outside CARDS**:
  `bleed, cloak, grenade, jump, leader, line, mission, orb,
  Unfaithful Steed`. `tools/make_100pct_save.py` now writes exactly those
  195 (run-2's harvested `stats.sav` key set matches 1:1). The old "170
  cards" list missed 25 real cards (Anarchy, Stoning, Vendetta, Warhorse,
  Shovel, Sprint, … mostly the ext=3 block).
- `SKC|` also exposes a `special=` field on 10 cards: `strafe` (Royal
  Loafers), `scope` (Engraved Scope), `decree` (Unjust Decree), `grenade`
  (Kingly Alms, Philanthropy, Indelible Memories, Sacred Light, Guerilla
  Tactics), `orb` (Seer's Orb), `dig` (Shovel) — these are the special
  *mechanics* cards (matching several of the lowercase codex keys).
- Offer events observed through `add_card` append hook; `pwe` present on
  live cards (4 common, 3 seen once) — offer roll candidates in draft §6.
