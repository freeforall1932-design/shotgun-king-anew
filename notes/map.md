# notes/map.md — code map of Shotgun King

**Game version:** v1.623b (from owner's archive name) · **Engine: SUGAR v0.0.6b**
(custom Lua engine by Rémy Devaux — NOT Godot; correction 2026-10-03, see
PLANNING.md §0.5) · **Scripting:** Pico-8-flavored Lua (no full stdlib)

**Status: pre-source.** Everything below comes from the official modding guide
(uploads/modding-guide/) and the 13 workshop mods (notes/mods.md). Re-verify
against actual game scripts once the full game archive arrives (parts 1–3
missing; see README to-do).

---

## Where the knowledge lives right now

| Source | Location | Contents |
|---|---|---|
| Modding guide (by the dev) | `uploads/modding-guide/README.md` | info.lua format, custom cards/pieces/modes, saving, append/prepend, workshop upload |
| SUGAR engine manual | `uploads/modding-guide/SUGAR_manual.txt` | full engine API (58 KB) |
| **Vanilla card + piece data** | `uploads/modding-guide/vanilla_stuff/cards_n_pieces.lua` | the full `CARDS` table (gid 0–156, ext 0/1/2) + `EXCLUDE` pairs + piece-related tables |
| Vanilla modes | `uploads/modding-guide/vanilla_stuff/{chase,endless,throne,tutorial}.lua` | stock game-mode scripts — spawn flow reference |
| Sample mod | `uploads/modding-guide/sample_mod/` | canonical minimal example (info.lua, script.lua, modes/skirmish.lua, lang/) |
| Workshop mods | `uploads/mods/extracted/` | 13 real mods; API usage patterns (notes/mods.md) |

## Ammo / shells (search when source arrives: `ammo`, `shell`, `reload`, `chamber`)

Known stat fields (vanilla card data): `ammo_max`, `ammo_regen`, `chamber_max`,
`pawn_shell`, `rook_shell`, `bad_shells`, `spread`, `firepower`, `firerange`,
`recoil`. Hero stat block (Fairy Endless mode): `{name, chamber_max, firepower,
firerange, spread, ammo_max, knockback, pierce, blade}`.

- Where is the shell count stored? → **TBD (need source)**
- Spend/refill functions? → **TBD** (candidates to wrap: `on_fire`,
  `new_turn`, `spend_hop`-style spenders)
- Vanilla rules from Better Codex: can't have 0 max ammo; ≤5 soul slots;
  ≤3 scepters; ≤1 right-click ability; no grab+blade combo.

## Cards / perks / drafting (search: `card`, `perk`, `offer`, `pwe`, `codex`)

- Data: global `CARDS` table — vanilla copy already in hand (157 cards).
  Fields: `gid, ext, n (copies), id, pwe (offer weight, default 4), team,
  played, need/need_card/need_tag/... (requirements), exclude_tag, special,
  flip_on, wild, gain/sac, delay/cycle/delayed` + effect fields.
- `EXCLUDE` = mutual-exclusion pairs (e.g. Royal Loafers vs Sawed-off Justice).
- Functions (from mods): `new_card(id)`, `add_card(ca)`, `init_codex()`,
  `get_slot_cards()`, `cards.pool`, `flip_card`, `unflip_card`,
  `check_cards_auto_flip`, `dr_flip_card`, `tear_apart`, `on_card_but_init`.
- Offer roll location → **TBD** (wrap candidates: `new_level`, `add_card`).
- Royal Card Lab already implements pick-any-card via wild cards + codex —
  reuse the pattern.

## Enemies / spawning / floors (search: `spawn`, `piece`, `floor`, `wave`)

- Functions (from mods): `spawn_pieces`, `new_piece`, `setup_piece`,
  `new_level`, `end_level`, `opp_turn`, `on_piece_move`, `on_bad_spawn`,
  `on_bad_death`, `init_squares`, `gsq`, `goto_sq`, `get_range`.
- Piece stat fields (Fairy Pieces): `<type>_hp`, `<type>_tempo`,
  `commoner_typ`, etc.; custom pieces get custom movement/attack/draw/debris
  (game update ≥2026-04).
- Spawn decision point → **TBD** (`spawn_pieces` prepend is the obvious hook).

## Damage / health / death (search: `damage`, `hp`, `hit`, `xpl`, `die`)

- Events: `on_bad_hurt`, `on_bad_death`, `on_hero_death`, `on_boss_death`,
  `on_fire`, `on_piece_move`.
- Functions: `xpl` (piece explosion), `uplift`, `hop_dmg`, `grenade_dmg`,
  `queen_poison`, `bleed_slow`, `caltrops` (DoT-ish vanilla fields!).
- Single damage entry point? → **TBD** — once found, `prepend`/`append` it for
  `damage_taken_mult` / `damage_dealt_mult` (Phase 6).
- Vanilla already has: `knockback` (0–100), `pierce` (25/30), bleed tags,
  `recoil`, leech-like `leader_queen_vampire` — Phase 5 is largely
  *exposing existing internals*, not inventing mechanics.

## Debug toolchain (Phase 2) — now mostly "build a mod"

Deliverable = a mod folder (`modded/sk-rework/`) with F-key/debug handling via
`script.lua`. Study Glac Terminal (modder console) before writing anything.
`gimme("global")` at runtime lists all game functions — run once with `_log`
dump to bootstrap this map.

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

1. ~~game archive incomplete~~ → **SOLVED 2026-10-03**: all 4 parts uploaded,
   extracted (see changelog). Game copy analyzed; full file list in
   `notes/data-sgr-filelist.txt`.
2. `data.sgr` (79 MB) is a compressed/encrypted SUGAR package — no public
   format docs (SUGAR engine is not open-source; only `sugarcoat`, a Lua
   interface for Castle/Love2D, is). **Decision: don't crack it.** We get the
   same intel at runtime via a debug mod (`gimme("global")` + `_log`) — that's
   Phase 2's first deliverable anyway.
3. **SAVE FORMAT FULLY CRACKED 2026-10-03** (see tools/save_codec.py):
   `save/*.sav` = `[4-byte BE plaintext length][zlib stream]`; payload is
   PUNKCAKE serializer text (`PUNKCAKE\nt{ ... }\nFOREVER`; types: t table,
   s"key"~: (0x1F before colon), n number, bTrue/bFalse, f"file", s"str").
   Verified decode+encode on all 6 saves. Files: reg.sav (registry: which
   files exist), prog.sav (progression: throne lvl, best_time, badges,
   weapon_unl — the cheat target), stats.sav (per-card played/ignored — the
   card-offer memory; picker phase can edit it), achievements.sav, runs.sav,
   misc.sav (codexitems). No mod-enable state anywhere in saves → **resolved
   by the live test: mods ARE enabled by default; the enable state lives in
   `mods/modlist.lua`, which the game writes itself at boot** (see §live).
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

## Live-verified facts — live tests 1 & 2 (2026-10-03, builds 3–4, v1.623b)

Source: `live testing result/` (run 1: inherited-mods + `-NoInheritMods`
builds; run 2: full `-GetInsights` pack — log, `mods/modlist.lua`, whole
`save\` folder) + parsed draft `notes/game-map-draft.md`. These are
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
- In-game mod menu: NOT on the title screen — **Play → top entry**. **Black
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
- **`get_slot_cards(true)`** — returns the offer-eligible card list; with
  `true` it includes everything (Royal Card Lab builds its full picker from
  it; disgraced_justice searches it by `ca.id`). "Slot cards" = the offered
  cards. The vanilla offer roll (which 2 appear, and the right-click-slot
  filtering) is still TBD — prime probe target.
- **`on_card_but_init(but, ca)`** — define this global in a mod and the game
  calls it when a card-offer button is created; wrap `but.left_clic` to
  intercept picks (Royal Card Lab's whole picker works this way, incl. its
  `mode.unlimited` free-choice mode = our Phase 4 blueprint).
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
  relaxed (right-click cap) is one of these general rules.
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
- **Summon blueprint** (disgraced_justice `dj_summon`): find free squares
  (`is_free(sq)`), `new_piece(typ, false, sq)`, `fx_spawn(p)`, pay from a
  hero field (`hero.book_power -= cost`); `convert(target, cb)` turns an
  enemy. `spawn_pieces` / `new_piece` / `setup_piece` are mod-env-callable.
- **`stack` global** = aggregate of owned cards' effect fields (live uses:
  `stack.pierce`, `stack.knockback`, `stack.blade`, `stack.fearsome`,
  `stack.special`, `stack.replace_soul`) — read it to know what the player
  owns without scanning cards.
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
