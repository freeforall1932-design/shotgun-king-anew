# Red text = error codes

**Owner rule (session 10):** any red text on the main menu or mod menu that
comes from a mod that is turned on is an **error**: that mod clashes with
another one, or is not working as intended. Never treat it as cosmetic.

Mods print red text with `wlog(...)`, usually through a local
`warn()` = `log()` + `wlog()` + the "wrong" sound. The game copies every one
into `log.txt` as a ` !! <text>` line. Two tools turn them into codes:

| Where | What it shows |
|---|---|
| In game: SK Rework's legend on the **mod menu** (far left, centred) | `E1`–`E4` (load-order problems), computed live from the ON/OFF flags and row order. The red lines go away as you fix them; the **AUTO-FIX** button fixes all four. |
| After a run: `python tools/parse_log.py <log.txt> --print`, section **1b** | Every red line in the log as a `T/A/D/C/S/L/B` code, grouped by the mod that printed it, with the fix. |

Expected harmless ` !! ` lines (engine noise, **not** errors):

- `Could not open file 'save/mods/<id>.bnk'` (the first run of a mod, before its save exists)
- `Bank '<id>' already exists, deleting it`
- `Surface '<x>' already exists, deleting it`
- `Couldn't find '<u>' uniform in shader`
- `Not recognizing button 'm:lb'`
- `You need an existing window for mouse('lock')`
- `Setting overlay...`

`parse_log.py` ignores these.

## 1. In-game codes (mod menu legend, `SKUI|modcheck` / `SKUI|modmenu` in the log)

| Code | Legend text | Meaning | Red boot text it predicts |
|---|---|---|---|
| **E1** | `TERMINAL IS OFF` / `TERMINAL MISSING` · `FOR <mods>` | a mod that needs Glac Terminal is ON, but Terminal is OFF or not installed | T1, T2, A2. Quartz Army and Extra Features print **nothing**; they just lose features, so E1 is their only warning. |
| **E2** | `TERMINAL NOT LAST` · `FOR <mods>` | a Terminal-dependent mod is loaded **below** Glac Terminal | T3, A3, (T1) |
| **E3** | `COLLECTION IS OFF` / `COLLECTION MISSING` · `FOR <mods>` | Art of War or Disgraced Justice is ON, but Glacies' Collection is OFF or not installed | D1, A1 |
| **E4** | `COLLECTION BELOW` · `FOR <mods>` | Art of War is loaded **above** Glacies' Collection | A1 |

**AUTO-FIX** (shown only when there is an issue):

1. Sorts the list into the canonical order (below), keeping unknown mods in place relative to each other.
2. Turns ON every dependency that is installed.
3. Reopens the menu.

Back then reads **Save and Reboot**, as for any change.

## 2. Log codes (`parse_log.py` section 1b)

| Code | Red text (exact start) | Printed by | Meaning | Fix |
|---|---|---|---|---|
| **T1** | `Glac Terminal is not loaded correctly!` | Glacies' Collection, Royal Card Lab, Grenade Predictor | the mod can't see Glac Terminal (off, or loaded after it) | Terminal ON and last (AUTO-FIX) |
| **T2** | `Retry after Death: Glac Terminal is not active` | Retry | Terminal is OFF | Terminal ON (AUTO-FIX) |
| **T3** | `Retry after Death must be loaded above Glac Terminal` | Retry | Retry is below Terminal | Terminal last (AUTO-FIX) |
| **A1** | `Glacies' Collection needs to be loaded above The Art of War!` | The Art of War | Collection is OFF or below Art of War | Collection ON, above Art of War (AUTO-FIX) |
| **A2** | `The Art of War: Glac Terminal is not active` | The Art of War | Terminal is OFF | Terminal ON (AUTO-FIX) |
| **A3** | `The Art of War must be loaded above Glac Terminal` | The Art of War | Art of War is below Terminal | Terminal last (AUTO-FIX) |
| **D1** | `Glacies' Collection must be turned on!` | Disgraced Justice | Collection is OFF | Collection ON, above Disgraced Justice (AUTO-FIX) |
| **C1** | `Argument X not found. Process terminated.` | Glacies' Collection (terminal command) | a console command named an unknown argument | re-check the command; this doesn't affect other mods |
| **C2** | `Glacies' Collection is not loaded correctly!` | (older mod versions) | a mod can't see Collection | Collection ON, above its dependents |
| **S1** | `Not allowed to change value for index '…'` / `Attempt to use forbidden …` | the engine's mod sandbox | a mod wrote a protected value or used a forbidden function | that mod is broken on v1.623b; report the index named in the text |
| **L1** | `'mods/<folder>/<name>' didn't match any files.` | the engine's asset loader | a mod loaded art or sound with the old `newsrf("file", name)` argument order, so nothing loaded (run 6: 21 lines across 8 mods; fixed in our `dist-overlay` copies in Build 8) | an unpatched workshop copy got in: rebuild with `build-dist.ps1 -Clean` |
| **B1** | `Save seems to be corrupted, duplicating to 'save/corrupted_save.bnk'.` | the engine's save loader | the main save failed its checksum | restore `save/` from a backup; never hand-edit `.bnk` files |

Codes T*, A* and D* are matched only on ` !! ` lines, because each mod also
`log()`s the same text on a normal line. S1 is matched on any line, because
the engine prints it through `rlog`.

## 3. Dependency rules (source of E1–E4 and AUTO-FIX)

- **Glac Terminal** is needed by: Glacies' Collection, Glacies' Extra
  Features, The Art of War, Disgraced Justice, Retry after Death, Royal Card
  Lab, Grenade Predictor and The Magnificent Quartz Army. Each `info.lua`
  says so. Terminal collects their hook functions (`on_bad_spawn`,
  `draw_N`, `upd`, …) only from mods loaded **above** it, so Terminal goes
  last. Extra Features and Quartz print no red text when Terminal is
  missing; they silently lose features (for Quartz, the watchtower
  placement).
- **Glacies' Collection** is needed by: The Art of War and Disgraced Justice.
  It must be loaded above both.
- **Canonical order** (what AUTO-FIX and `build-dist.ps1` §3b write):

  sk-rework → glacies collection → extra features → the art of war →
  disgraced_justice → retry → royal card lab → grenade predictor → codex →
  nightmare → fairy pieces → quartz army → shootout → **glac terminal**

Not tracked (only affects achievements): The Art of War's achievements
need the separate *Achievement Centre* mod, which isn't installed.

Run 6 (Build 7) hit T1 ×3, T3, A3 and L1 ×21. The order problems came from
the old alphabetical `modlist.lua`; Build 8 §3b writes the canonical order.
The L1 lines came from the argument-order bug fixed in Build 8 item 2.
