# HANDOFF — Session 2026-10-03 (session 3, branch `arena/01a101f3-shotgun-king-anew`)

> **Purpose:** a fresh agent (or the owner after a break) can resume from this
> file alone. Read `PLANNING.md` for the full history; this is *current state*.
> Update this file at the end of every working session.

---

## 1. Project in one paragraph

Private, personal-use mod project for **Shotgun King: The Final Checkmate
v1.623b** (PUNKCAKE Délicieux). The game runs on **SUGAR** — the studio's
custom Pico-8-style Lua engine (LuaJIT 2.1 / Lua 5.1, SDL3) — **not Godot**.
Deliverable = a normal SGK mod (`modded/sk-rework/`) plus a toolchain that
builds a ready-to-play modded **copy** of the game. Goal list: ammo rework
(A→B→C), card picker, enemy picker, extra shot mechanics, balance knobs,
in-game dev-cheat panel, 100%-unlock save. The play path never patches game
files; "injection" = adding folders under `mods/` (the game's own mod system).

## 2. Where things are

| Thing | Location |
|---|---|
| Working branch | `arena/01a101f3-shotgun-king-anew` (push here; PRs #1 and #2 already merged to `main`) |
| Our mod | `modded/sk-rework/` (info.lua + script.lua = diagnostics build 3 + cover.png) |
| Log parser + smoke test | `tools/parse_log.py`, `tools/mod_smoketest.py` (both tested, see §5) |
| 13 workshop mods, vendored, name-verified | `dist-overlay/mods/` |
| Tools | `tools/` (build-dist.ps1, install-mods.ps1, apply.ps1, save_codec.py, make_100pct_save.py, mod-dev.md, recover.md) |
| Knowledge | `notes/` (map.md = code map, mods.md = mod inventory + API, review-2026-10-03.md = pre-live-test review, changelog.md, data-sgr-filelist.txt) |
| Owner archives + extracted game + modding guide | `uploads/` (**gitignored**) — **NOT present in this session's sandbox**; lives on the owner's machine |
| Full extracted game | was `/tmp/skgame/…` — **gone** (ephemeral). Re-extract from owner's rars if needed |

## 3. Hard-won facts (do not re-derive)

1. **Mod folder name MUST equal `name=` in info.lua.** Mismatch = silent
   no-load. Mods must be unpacked folders — zips/rars in `mods/` are ignored.
2. **Mod API**: `append`/`prepend` any global game function (id-registered),
   `on_*` event callbacks, custom cards via `concat(CARDS, {...})` (fields
   incl. `pwe` = offer weight, `knockback`, `pierce`), custom modes in
   `modes/`, `gimme("global"|"replaceable"|"forbidden"|"autocall")`
   introspection, `_log()` → log.txt. Patterns confirmed in the vendored
   mods: `for k in all(gimme("global"))` yields global names;
   `for i,v in ipairs(MODLIST) do if v.title == "…"` finds your own mod.
3. **Save format** (`save/*.sav`): `[u32 BE plaintext length][zlib stream]`,
   payload `PUNKCAKE\nt{...}\nFOREVER`, no indentation, string values carry
   a trailing 0x1F. `tools/save_codec.py` parses/serializes **byte-identical**
   on all 6 real v1.623b saves (prior session). `make_100pct_save.py` =
   unlock-all (128 achievements, weapons 1–9, rank 20 + badges, endless
   floor 15 ⇒ chase unlocked, 164-card codex). Backups + `--restore`.
4. **No mod-enable state in saves** → mods in `mods/` are likely enabled by
   default; the in-game mod menu toggles them. *(Unconfirmed — live test.)*
5. **data.sgr** = 79 MB package with all 278 game files. Format undocumented;
   **decision: don't crack it** — runtime `gimme()` dump gives the same intel.
6. The analyzed game copy is a Goldberg-emu repack (owner's); Steam Workshop
   upload won't work there, modding works fine.
7. `King's Court` (owner's mods/) is a 2022 pre-info.lua legacy mod — won't
   load on v1.623b without a port.

## 4. Session 2 & 3 outcome (review → docs → placement-aware fixes)

Owner asked in session 3: fix `INSTALL.md` because previous commands didn't
account for how file placement affects copy-paste commands (`apply.ps1` lives
inside `tools\`, while relative commands like `-File tools\apply.ps1` only work
when PowerShell is at the root of the `main` branch `repo\`, breaking if run
from `tools\`, `E:\testing\`, `C:\Users\...`, or when GitHub's ZIP creates a
nested `shotgun-king-anew-main` folder). Done:

- **`INSTALL.md` fixed for manual Steps 1–2 & `E:\testing\repo\tools` commands:**
  - Steps 1 & 2 are now **Manual (File Explorer) only** — removed the broken
    `mkdir E:\testing` + Steam `Copy-Item` PowerShell block.
  - Steps 3, 4, 6, 7 all `cd E:\testing\repo\tools` (where `apply.ps1`,
    `build-dist.ps1`, `parse_log.py`, and `make_100pct_save.py` live) and use
    explicit `"E:\testing\repo\tools\..."` paths.
- **`tools/build-dist.ps1` & `tools/install-mods.ps1` handle existing `game\mod` or `game\mods`:**
  - If `E:\testing\game` already has a `mod\` or `mods\` folder containing
    compressed `.zip`/`.rar` files or already-unpacked folders with their own
    folder names, `build-dist.ps1` merges `mod\` → `mods\`, unpacks `.zip`s,
    renames unpacked folders to match `info.lua`'s `name=` (so nothing
    duplicates or fails to load), removes `.rar` and legacy non-`info.lua`
    folders in the copy, and overlays the 13 workshop mods + `sk-rework`.
  - Zero-argument auto-file discovery placed on the waitlist in `WORKLIST.md`
    until after core features work first.

- **`notes/review-2026-10-03.md`** — full readiness review: what each tool
  writes and how to undo it, verification status per artifact, risks, and the
  risk-ordered live-test ladder (now also the README quick-start).
- **README rewritten** — answers "does it patch my game or build a clone?"
  in the first screen, honest ✅/🟡/⛔ status table, dev roadmap demoted to
  a short pointer. Removed the "✅ shipped" overclaims.
- **Code fixes** (all covered by tests in the sandbox):
  - `make_100pct_save.py`: `throne` table could be dropped when absent
    (`setdefault` fix); friendly errors when `save/` or its files don't exist;
    `--restore` now works even if `save/` was deleted; backup path explicit.
  - `save_codec.py`: `--help` no longer treated as a filename.
  - `build-dist.ps1`: robust stray-archive filter (`-Include` + `-LiteralPath`
    grey zone removed); `PLAY-THIS.txt` now explains copy semantics + how to
    unlock the copy.
- **Verification run this session:** Python `py_compile`; 100% tool end-to-end
  on disposable synthetic saves (dry-run → write → value inspection →
  restore); regression test for the `throne` fix; all 3 `.ps1` parse clean
  under tree-sitter-powershell; all 14 mod folders re-checked
  `folder == name=`; `sk-rework/script.lua` compiles under Lua.

## 5. Current state & immediate next step

**The stub is now a self-reporting diagnostics build (build 3)** and the
parser exists, so the live run harvests everything in one pass:

1. owner runs `INSTALL.md` steps 1–7 (Step 5 = launch, enter a run, play a
   couple of turns, quit; Step 6 = `apply.ps1 -GetLog`);
2. upload `log.txt`;
3. `python tools/parse_log.py uploads/game-insights/log.txt` →
   `notes/game-map-draft.md` (auto: load verdict, API check, hook list,
   **append-vs-on_* dispatch verdict**, live object model, candidate lists
   per TBD area);
4. promote confirmed names into `notes/map.md`, then build Phase 2c
   (dev-cheat panel via `mk_menu_but`), then ammo rework A→B→C.

What the diagnostics build logs: see the table in `tools/mod-dev.md` §3.
Safety: no `pcall` in this engine (no shipped mod uses it) → everything is
nil/boolean-safe (`sv()`), loops capped, no gameplay code touched.

Verified without the game: `python tools/parse_log.py --selftest` (16/16) and
`python tools/mod_smoketest.py` (needs `lupa`; 27/27 under both `all()`
semantics; it caught two real bugs — boolean concatenation and nested-table
dumps — before the live run).

Next unblocked candidates: pre-build the cheat-panel skeleton against
candidate names, real cover art, or the `install-mods.ps1` .rar path.

## 6. Owner (human) intervention points

- Run the live-test ladder and upload log.txt ← **only blocker**
- Playtest each phase build; report crashes (error text = END of log.txt)
- At deployment: flip repo private, optional git history scrub (old commits
  still contain the rars), or archive repo if abandoning

## 7. Environment quirks (this sandbox / Arena agent mode)

- **The platform may reset the local branch to the base commit between
  turns.** Working files survive; commits survive on the remote. Recovery:
  `git fetch origin && git reset --soft origin/arena/…` then `git reset`.
- Network: `git`/`api.github.com`/`pypi` reachable. **Blocked:** raw
  GitHub, GitHub release assets, Debian apt mirrors (apt install fails).
- **No `pwsh`** → PowerShell scripts are static-parsed (tree-sitter) but never
  executed here. Python 3.11 is available; `/tmp/skvenv` (lupa + tree-sitter)
  works and is ephemeral.
- `uploads/` is gitignored and **absent in this session** — docs referencing
  it describe the owner's machine.
- No unrar/7z preinstalled; unrar was compiled last session (that binary is
  in `uploads/tools/`, not in git).

## 8. Rules that still stand

- Never commit game assets or archives (`.gitignore` guards: *.rar *.zip
  *.exe *.dll *.sgr, uploads/, dist/, save_backup_/, __pycache__/).
- Workshop mods in `dist-overlay/` are mirrored for the owner's personal
  build (owner confirmed freely distributed); remove on author request.
- Mod code: additive hooks only, `-- SK-REWORK:` markers, stable hook ids,
  discoveries logged to `notes/map.md` immediately.
- Personal use only — nothing public.
