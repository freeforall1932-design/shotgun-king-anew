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
   misc.sav (codexitems). No mod-enable state anywhere in saves → mods in
   mods/ are probably enabled by default (unconfirmed; live test will tell).
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
