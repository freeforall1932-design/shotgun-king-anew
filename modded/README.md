# modded/ — OUR mod, the project deliverable

Everything we build lives in `modded/sk-rework/` as a normal Shotgun King mod
(SUGAR engine, Lua). `tools/apply.ps1` deploys it into a game folder's
`mods/` dir; `tools/build-dist.ps1` bakes it into a full ready-to-play copy.

```
sk-rework/
├── info.lua     mod identity (name MUST match the folder name)
├── script.lua   hooks: append/prepend + on_* events; debug keys land here
├── modes/…      custom game modes (later phases)
├── lang/…       strings (later phases)
└── cover.png    16:9 workshop cover (placeholder art for now)
```

## Working rules (from PLANNING.md §3.4, adapted 2026-10-03)

1. **Additive over invasive** — `append`/`prepend` with stable ids; never
   overwrite a game global unless `gimme("replaceable")` says it's allowed.
2. **Native feel** — UI reuses the game's own button/menu constructors
   (`mk_menu_but`, menu init hooks) so panels look vanilla.
3. Every hook gets a `-- SK-REWORK:` comment.
4. Discoveries go into `notes/map.md` immediately.
5. The game is the spec — read how PUNKCAKE did it before redesigning it
   (reference: `uploads/modding-guide/`, the 13 workshop mods).

The 13 workshop mods we ship alongside live in `dist-overlay/mods/` — do not
edit those (they're third-party); we only fixed folder names to match their
`info.lua`.
