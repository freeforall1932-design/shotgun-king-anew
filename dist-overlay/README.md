# dist-overlay/ — what gets injected into a game copy

`mods/` here holds the **13 workshop mods** the owner collected (from the
official PUNKCAKE Discord / Steam Workshop — freely distributed, free to use).
`tools/build-dist.ps1` copies them into a fresh game copy so everything works
out of the box.

Every folder name matches its `name=` field in `info.lua` (verified — this is
the #1 load-failure cause; `disgraced_justice` needed a rename).

| Folder | Mod | Author |
|---|---|---|
| show exclude | Better Codex | Glacies |
| disgraced_justice | Disgraced Justice | Lorina Sonetto & Bob Qwerty (requires glacies collection) |
| some_fairy_pieces | Fairy Pieces for SGK | sub122 |
| glac terminal | Glac Terminal (modder tool) | Glacies |
| glacies collection | Glacies' Collection | Glacies |
| extra features | Glacies' Extra Features | Glacies |
| grenade predictor | Grenade Predictor | ? |
| nightmare | Nightmare Mode | Glacies |
| retry | Retry after Death | ? |
| royal card lab | Royal Card Lab | Glacies |
| Shootout | Shootout | ? |
| the art of war | The Art of War | ? |
| the_magnificient_quartz_army | The Magnificent Quartz Army | ? |

## Local patches (Build 8, session 10) — the only edits to the authors' files

The game's mod sandbox only accepts asset loaders as `newsrf(name, "file.ext")`
(decoded `code/mods.lua`, see `notes/game-internals.md` §2). Seven mods used
the old `newsrf("file.ext", name)` order. Under v1.623b that loads nothing:
run 6 logged `'mods/<mod>/<name>' didn't match any files`, and Fairy crashed
with "Cannot set inexistent surface". The arguments are swapped in:

| Mod | Call(s) |
|---|---|
| Shootout | `script.lua` gfx: registered as **`shootout_gfx`** (see note) |
| glacies collection | `script.lua` `collection_gfx` |
| nightmare | `script.lua` `nightmare` cards; `modes/nightmare.lua` `weapons` |
| royal card lab | `script.lua` `wild_card` |
| some_fairy_pieces | `script.lua` `title_sfps`, `gfx_sfps`, `fairy_cards`, `fairy_pieces` |
| the art of war | `script.lua` cards + gfx surfaces and the `shout`/`drum1`/`drum2` sounds |
| the_magnificient_quartz_army | `script.lua` 5 sheets, registered as **`tmqa_title/tmqa_gfx/tmqa_tutorial/tmqa_cards/tmqa_pieces`**, with its own cards → `spsheet="tmqa_cards"` and `spritesheet("tmqa_pieces")`; `modes/Quartz Throne.lua` `weapons` |

Note on Quartz and Shootout: both tried to REPLACE base sheets (`gfx`,
`cards`, `title`, `tutorial`) for the whole game. Their `gfx` is an older
256×384 copy of the base sheet (v1.623b's is 256×464, with newer sprites at
the bottom), so a global override would break base sprites. Both now
register unique names; Quartz's own cards and pieces draw from its own
sheets. The trade-off: their title-screen and tutorial reskins aren't
applied. Nightmare and Quartz Throne still swap `weapons` while their mode
runs, which is the same thing the base Throne mode does
(`newsrf("weapons", …)` on initialize).

## Load order (written by `tools/build-dist.ps1` into `mods/modlist.lua`)

The game loads mods top to bottom. Glac Terminal gathers hook functions only
from mods ABOVE it, and The Art of War needs Glacies' Collection above it.
The build writes this order: sk-rework, glacies collection, extra features,
the art of war, disgraced_justice, retry, royal card lab, grenade predictor,
show exclude, nightmare, some_fairy_pieces, the_magnificient_quartz_army,
Shootout, **glac terminal (always last)**. Run 6's alphabetical order put the
Terminal 4th, which caused the red "must be loaded above Glac Terminal"
warnings.

NOT included: `King's Court` (2022 pre-info.lua legacy format — won't load on
v1.623b without a port; kept in `uploads/mods/extracted/` in the workspace).
Our own mod lives in `modded/sk-rework/` (source of truth), also injected by
the build script.

If an author objects to being mirrored here, we remove it on request — this
repo is a private personal-use build system.
