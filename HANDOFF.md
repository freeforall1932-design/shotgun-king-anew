# HANDOFF — Session 2026-10-03 (arena/01a10145-shotgun-king-anew)

> **Purpose:** a fresh agent (or the owner after a break) can resume from this
> file alone. Read `PLANNING.md` for the full history; this is *current state*.
> Update this file at the end of every working session.

---

## 1. Project in one paragraph

Private, personal-use mod project for **Shotgun King: The Final Checkmate
v1.623b** (PUNKCAKE Délicieux). The game runs on **SUGAR** — the studio's
custom Pico-8-style Lua engine (LuaJIT 2.1 / Lua 5.1, SDL3) — **not Godot**
(that was the original wrong assumption, corrected in PLANNING.md §0.5).
Deliverable = a normal SGK mod (`modded/sk-rework/`) plus a toolchain that
builds a ready-to-play modded copy of the game. Goal list: ammo rework
(A→B→C), card picker, enemy picker, extra shot mechanics, balance knobs,
in-game dev-cheat panel, 100%-unlock save.

## 2. Where things are

| Thing | Location |
|---|---|
| Working branch | `arena/01a10145-shotgun-king-anew` (pushed; PR #1 → main) |
| Our mod | `modded/sk-rework/` (info.lua + script.lua stub + cover.png) |
| 13 workshop mods, vendored, name-verified | `dist-overlay/mods/` |
| Tools | `tools/` (build-dist.ps1, install-mods.ps1, apply.ps1, save_codec.py, make_100pct_save.py, mod-dev.md, recover.md) |
| Knowledge | `notes/` (map.md = code map, mods.md = mod inventory + API, changelog.md, data-sgr-filelist.txt) |
| Owner archives + extracted game + modding guide + unrar binary | `uploads/` (**gitignored**, workspace-only, ~25 MB) |
| Full extracted game (incl. 79 MB data.sgr) | `/tmp/skgame/…` (**ephemeral** — gone on sandbox reset; re-extract from owner's rars or git history if needed) |

## 3. Hard-won facts (do not re-derive)

1. **Mod folder name MUST equal `name=` in info.lua.** Mismatch = silent
   no-load. `disgraced_justice` needed a rename. Mods must be unpacked
   folders — zips/rars in `mods/` are ignored.
2. **Mod API**: `append`/`prepend` any global game function (id-registered),
   `on_*` event callbacks (on_fire, on_bad_hurt, on_bad_spawn, …), custom
   cards via `concat(CARDS, {...})` (fields incl. `pwe` = offer weight,
   `knockback`, `pierce`), custom modes in `modes/`, `gimme("global"|
   "replaceable"|"forbidden"|"autocall")` introspection, `_log()` → log.txt.
   Full docs: `uploads/modding-guide/` (SUGAR_manual.txt + README by the dev
   + **vanilla CARDS table** in vanilla_stuff/).
3. **Save format** (`save/*.sav`): `[u32 BE plaintext length][zlib stream]`,
   payload `PUNKCAKE\nt{...}\nFOREVER`, no indentation, string values carry
   a trailing 0x1F. `tools/save_codec.py` parses/serializes **byte-identical**
   on all 6 saves (`--selftest`). `make_100pct_save.py` = unlock-all
   (128 achievements, weapons 1–9, rank 20 + badges, endless floor 15 ⇒
   chase unlocked, 164-card codex). Saves auto-backup; `--restore` undoes.
4. **No mod-enable state in saves** → mods in `mods/` are likely enabled by
   default; the in-game mod menu toggles them. *(Unconfirmed — live test.)*
5. **data.sgr** = 79 MB compressed package with all 278 game files (incl.
   `code/gameplay.lua`, `code/mods.lua`, …). Format undocumented (SUGAR is
   closed-source). **Decision: don't crack it** — runtime `gimme()` dump via
   our stub mod gives the same intel legally & cheaply.
6. The analyzed game copy is a Goldberg-emu repack (owner's); Workshop UPLOAD
   won't work there, modding works fine.
7. `King's Court` (in owner's mods/) is a 2022 pre-info.lua legacy mod —
   won't load on v1.623b without a port. Kept in `uploads/mods/extracted/`.

## 4. Current state & immediate next step

Phases 0–2a **done** (game analyzed, toolchain shipped, PR #1 ready/merged).
**The critical path blocker is ONE live test by the owner:**

```
pwsh tools/apply.ps1 -GameDir "<game folder>"        # or build-dist.ps1
→ launch game → mod menu → enable "SK Rework" → quit
→ upload the game's log.txt to the repo (any branch/commit, like the rars)
```

The stub mod writes `SKG|<name>` / `SKR|…` / `SKF|…` lines for every global
in the game. With that log: finish `notes/map.md` (exact ammo/damage/spawn
functions), then build the **dev-cheat panel** (Phase 2c) using native
`mk_menu_but` UI, then ammo rework A→B→C.

## 5. Owner (human) intervention points

- Run the live test above and upload log.txt ← **only blocker**
- Playtest each phase build; report crashes (error text = END of log.txt)
- At deployment: flip repo private (Settings → Danger Zone), optional git
  history scrub (old commits still contain the rars), or archive repo if
  abandoning
- Repo `main` cleanup = merge PR #1 (if not already merged)

## 6. Environment quirks (this sandbox / Arena agent mode)

- **The platform may reset the local branch to the base commit between
  turns** (happened 2026-10-03). Working files survive; commits survive on
  the remote. Recovery: `git fetch origin && git reset --soft origin/arena/…`
  then `git reset` to unstage (working tree already correct).
- Network: `api.github.com` + `git` + `pypi` reachable. **Blocked:**
  `raw.githubusercontent.com`, GitHub release assets, Debian apt mirrors.
- No unrar/7z preinstalled; **we compiled unrar 7.20 from source**
  (`uploads/tools/unrar`) — apt/pywheel routes fail.
- No `pwsh` in sandbox — PowerShell scripts are reviewed but only testable
  on the owner's machine.
- `/tmp` is NOT persisted across sessions; `uploads/` (≤ ~25 MB) is.

## 7. Rules that still stand

- Never commit game assets or archives (`.gitignore` guards: *.rar *.zip
  *.exe *.dll *.sgr, uploads/, dist/, save_backup_/, __pycache__/).
- Workshop mods in `dist-overlay/` are mirrored for the owner's personal
  build (owner confirmed freely distributed); remove on author request.
- Mod code: additive hooks only, `-- SK-REWORK:` markers, stable hook ids,
  discoveries logged to `notes/map.md` immediately.
- Personal use only — nothing public.
