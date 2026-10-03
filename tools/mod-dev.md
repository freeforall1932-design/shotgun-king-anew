# mod-dev.md — the build/test loop for our mod

> Replaces the old repack pipeline (no .pck, no Godot — PLANNING.md §0.5).
> Our deliverable is a normal SGK mod folder: `modded/sk-rework/`.

## 1. The mod skeleton (created 2026-10-03)

```
modded/sk-rework/
├── info.lua        # name="sk-rework", title="SK Rework", cover.png
├── script.lua      # Phase 2 stub: _log + gimme() dumps (SKG=/SKR=/SKF= lines)
├── modes/…         # (later) custom modes for the pickers, if needed
├── lang/…          # (later) strings
└── cover.png       # 16:9 png, required for workshop upload
```

`name=` must match the folder name (`sk-rework`). Copy patterns from
`uploads/modding-guide/sample_mod/` and the 13 mods (`notes/mods.md`).

## 2. Deploy + test loop

```bash
# from repo root (Windows pwsh):
pwsh tools/apply.ps1 -GameDir "D:\...\Steamapps\common\Shotgun King"
```

That copies `modded/sk-rework/` → `<game>/mods/sk-rework/` (idempotent).
Then:

1. Launch the game (Steam).
2. Mod menu → enable **sk-rework**.
3. Play / trigger the feature.
4. On crash or weirdness: read `<game folder>/log.txt` and the crashlog
   (SUGAR writes crashlogs; the error is at the END of the log).

In-mod debugging:

```lua
_log("hello")                        -- writes to log.txt
_log(ser(gimme("global")))           -- dump every global name
_log(ser(gimme("replaceable")))      -- what we may replace outright
append("new_turn", function(...) _log("turn!") end, "dbg")  -- trace calls
```

## 3. Dev etiquette (survives game updates)

- Only use documented mod APIs (`SUGAR_manual.txt`, guide README) and
  patterns proven by the workshop mods.
- `append`/`prepend` always with a stable id string; unregister cleanly.
- Every hook we add gets a `-- SK-REWORK:` comment in `script.lua`.
- Log discoveries into `notes/map.md` as you find them.

## 4. Sharing (optional, later)

In-game mod menu → type **UPLOAD** on the keyboard → button next to our mod
uploads it to Steam Workshop (needs the cover.png, 16:9). See guide README
"Uploading to the Steam Workshop".
