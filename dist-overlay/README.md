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

NOT included: `King's Court` (2022 pre-info.lua legacy format — won't load on
v1.623b without a port; kept in `uploads/mods/extracted/` in the workspace).
Our own mod lives in `modded/sk-rework/` (source of truth), also injected by
the build script.

If an author objects to being mirrored here, we remove it on request — this
repo is a private personal-use build system.
