# notes/mods.md — the 13 uploaded mods + what they teach us

> Source: owner's uploads (on `origin/main`, downloaded to `uploads/mods/`,
> extracted to `uploads/mods/extracted/` — both gitignored). These are Steam
> Workshop mods for SGK; `info.lua` ids = workshop item ids, so they can also
> be installed by subscribing in Steam.

**Engine truth (supersedes PLANNING.md §1):** Shotgun King runs on **SUGAR**,
PUNKCAKE's own Pico-8-flavored Lua engine (SUGAR v0.0.6b, by Rémy Devaux /
@trasevol_dog). NOT Godot. No `.pck`, no gdre_tools. Full engine API doc:
`uploads/modding-guide/SUGAR_manual.txt`. Official modding guide (by the dev):
`uploads/modding-guide/README.md` (github.com/TRASEVOL-DOG/Shotgun-King-Modding-Guide).

## Inventory

| Mod (zip name) | Folder (`name=`) | By | What it is / why we care |
|---|---|---|---|
| Better Codex | `show exclude` | Glacies | Codex UI rework; documents card-eligibility rules (max 1 right-click ability, 5 soul slots, 3 scepters, can't have 0 max ammo...) |
| Disgraced Justice | `disgraced_justice` | Lorina Sonetto & Bob Qwerty | **Custom ally**: recruit the Black Bishop via The Red Book; requires Glacies' Collection; ships an alt `sgk extra compatible script.lua` for Etilon's SGK Extra. Modern format (has info.lua) |
| Fairy Pieces for SGK (Custom) | `some_fairy_pieces` | sub122 | **Custom chess pieces** (Centaur, Archbishop, Amazon, Prince...) + custom mode `Fairy Endless` + a big custom card pack — richest reference for pieces & cards |
| Glac Terminal | `glac terminal` | Glacies | **Modder debug tool** ("DOESN'T ADD ANY CONTENT") — likely a console/inspector; study this for our debug toolchain (Phase 2) |
| Glacies' Collection | `glacies collection` | Glacies | Card/content collection |
| Glacies' Extra Features | `extra features` | Glacies | QoL extras |
| Grenade Predictor | `grenade predictor` | ? | Trajectory/aim prediction UI — reference for reading shot mechanics (`throw_grenade`, aim code) |
| Nightmare Mode | `nightmare` | Glacies | Difficulty rebalance + custom mode; reference for our balance knobs (§5) |
| Retry after Death | `retry` | ? | Retry hook — uses `on_hero_death` presumably; smallest mod, good first read |
| Royal Card Lab | `royal card lab` | Glacies | **Pick-any-card lab** — wild cards that open the codex to pick ANY card, + `card lab` / `endless lab` modes. This is basically our Phase 4 card picker, already solved — study, then borrow patterns (with credit) |
| Shootout | `Shootout` | ? | Gameplay variant |
| The Art of War | `the art of war` | ? | Big content pack (5 MB; ships `.ase` Aseprite sources!) |
| The Magnificent Quartz Army | `the_magnificient_quartz_army` | ? | Custom piece army — another pieces reference |

## The official mod format (proven by these files)

```
<mod folder>/            ← folder name MUST equal name= in info.lua
├── info.lua             ← id (workshop), name, title, by, description,
│                          cover="cover.png" (16:9), priority_hint (load order),
│                          mode_description = { ["Mode Name"]="Title|Desc" },
│                          mode_record = { ... } (highscore banks)
├── script.lua           ← runs at load; full access to game globals
├── modes/<mode>.lua     ← custom game modes (mode table, spawn rules, heroes)
├── lang/<lang>.txt      ← localization
├── cards.png, gfx.png…  ← sprites (newsrf() registers spritesheets)
└── cover.png            ← workshop preview
```

Install: `<game folder>/mods/<mod folder>/` (folder next to the game exe), or
Steam Workshop subscribe. Enable via the in-game mod menu. Old-style throne
mods needed `load_mod("name")` inside throne code (per the old Steam guide);
current versions use the mod menu.

## Game API surface seen in the mods (pre-source recon)

**Mod-facing globals:** `MODLIST`, `CARDS`, `EXCLUDE`, `SAVE`, `mode`, `cards`,
`pieces`, `squares`, `ents`, `codex`, `board`, `lang`, `current_lang`.

**Engine (SUGAR):** `palette`, `newsrf`, `newbnk`/`bset`/`bget`/`savbnk`
(mod save banks, 128x64 depth-4, no negatives), `add`, `del`, `concat`,
`bind`, `exe`, `btn`, `tbl_import`, `_log` (debug logging; crash → crashlog.txt
in game folder), `gimme("global"/"forbidden"/"replaceable"/"autocall")`
(introspection!), `append`/`prepend` (see below).

**Hooking mechanism — the core trick:**
```lua
append("new_turn", my_fn, "my_id")   -- call my_fn(...) AFTER every game new_turn
prepend("xpl", my_fn, "my_id")       -- call my_fn(...) BEFORE every piece explosion
append("new_turn", nil, "my_id")     -- unregister
```
Can wrap ANY global game function (list via `gimme("global")`); appended fns
get the args but can't intercept returns.

**Event callbacks mods define:** `on_empty`, `on_hero_death`, `on_boss_death`,
`on_new_turn`, `on_card_but_init`, `on_bad_spawn`, `on_bad_death`,
`on_sq_but_init`, `on_piece_move`, `on_menu_but_init`, `on_fire`,
`on_bad_hurt`, `init_tear`, `init_squares`.

**Game functions mods wrap (append/prepend targets seen in the wild):**
`load_lang, init_menu, set_mode, setup_piece, new_level, goto_sq, get_range,
get_lang, sfx, new_turn, new_piece, init_game, init_codex, ev_backup, add_card,
add, ach_event, spawn_pieces, show_hint, rectshade, opp_turn, on_death,
new_card, mk_menu_but, init_new_turn, gsq, get_disp_stats, get_desc,
end_level, dr_movemap, dr_flip_card, check_cards_auto_flip, build_stack, wait,
uplift, unflip_card, flip_card, throw_grenade, tbl_import, start_lvl_music,
spend_hop, pal_inc, pal, mk_hint_but, format_gameplay_datas, draw_mode,
custom_sort, check_collections`.

**Custom cards:** `concat(CARDS, new_cards)` / `add(CARDS, {...})` with fields:
`gid, ext, n, id, pwe (offer weight, default 4), team, spsheet, played,
need / need_card / need_tag / need_soul / need_chamber_max / need_knockback /
need_firepower / need_heir, exclude_tag, wild, special, flip_on, gain, sac,
delay / cycle / delayed` + effect fields (see map.md glossary).

**Custom modes:** `modes/<name>.lua`; heroes defined with
`{name, chamber_max, firepower, firerange, spread, ammo_max, knockback, pierce,
blade, ...}` (see Fairy Endless). `mode_description` in info.lua registers them.

**Language:** `add_lang(s)` + `append("load_lang", add_lang, "id")`; keys like
`[mod_index..". mode_name"]`.

## Known loading pitfalls (likely why a downloaded mod "doesn't load")

1. Folder name ≠ `name=` in info.lua (e.g. `Better Codex.zip` extracts to
   `show exclude/` — renaming the folder to "Better Codex" BREAKS it).
2. Mod not in a `mods/` folder **inside the game's install folder**.
3. Mod not enabled in the in-game mod menu (or old-version throne mods missing
   `load_mod("name")` registration).
4. Mod built for a different game version (we have v1.623b).
5. Nested folder from double extraction (`mods/Better Codex/Better Codex/`).
6. **Asset loader argument order** (decoded source, session 10): inside a mod,
   `newsrf/newsfx/newmus/newfnt` must be `(name, "file.ext")`. The reversed
   order loads a file literally named `mods/<mod>/<name>` and fails with
   `didn't match any files`. Seven vendored mods had it; they are patched
   (`dist-overlay/README.md`, "Local patches").
7. **Load order** — `MODS[]` fills top to bottom, so a dependency must sit
   ABOVE its dependents, and Glac Terminal must be LAST (it collects hook
   functions only from mods loaded before it). `build-dist.ps1` writes the
   verified order. From Build 9, the mod menu shows load-order problems as
   red `E1`–`E4` lines with an **AUTO-FIX** button.
   Terminal's clients: Collection, Extra Features, Art of War, Disgraced
   Justice, Retry, Card Lab, Grenade Predictor, Quartz Army. Extra Features
   and Quartz print **no** red text without it; they just lose features.
8. **Red text = error** (owner rule): any red line a turned-on mod prints on
   the main menu or mod menu means a clash or a malfunction. Every known text
   has a code (`T1`…`B1`) in `notes/red-warnings.md`, and
   `parse_log.py --print` lists them in section 1b.
9. **Throne-like modes with stale gun lists** (Build 9): Quartz Throne,
   Fairy Endless, Nightmare and Card Lab had old partial copies of the Throne
   guns, and Quartz never saved its bank. Fixed in the overlay; see
   `dist-overlay/README.md`, "Local patches (Build 9…)".

## King's Court — the "mod that wouldn't load", diagnosed 2026-10-03

Found in the game's `mods/` folder as **`King's Court.rar` — never extracted**
(the game can't read rars). After extraction it turned out to be a **June 2022
pre-`info.lua` mod** by Willhart: just `script.lua` + pngs + `english.txt` +
its own install guide ("unzip → put folder in mods/"). Its `script.lua` opens
with a self-documented mini-API (`pawn_`/`knight_`/… identifiers, variables,
functions) from the era before the official mod system.

Two independent reasons it never loaded: (1) left as .rar, (2) format predates
`info.lua` (v1.623b expects the current format). If the owner wants it, it can
be ported: wrap in `info.lua` (name/title/cover), keep script.lua, adapt the
2022 API calls to current ones (compare against these 13 mods). Files kept at
`uploads/game-insights/kings-court/`.

## Mods still to study when needed

- Phase 2 debug toolchain → **Glac Terminal** first, then Retry after Death (smallest).
- Phase 3 ammo rework → Fairy Endless hero stat blocks; vanilla card fields.
- Phase 4 card picker → **Royal Card Lab** (wild-card → codex → pick any card).
- Phase 4 enemy picker → Fairy Pieces / Quartz Army (custom piece spawning).
- Phase 5 mechanics → vanilla `knockback` / `pierce` card fields already exist;
  Grenade Predictor for shot/trajectory reading.
- Phase 6 balance knobs → Nightmare Mode; `prepend` on damage functions.

> Note: mod archives live in `uploads/mods/*.zip` (gitignored). The extracted
> trees were trimmed to save space — re-extract any time:
> `unzip "uploads/mods/Royal Card Lab.zip" -d uploads/mods/extracted/`
