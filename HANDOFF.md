# HANDOFF — Session 2026-10-06 (session 10, branch `arena/6424942a-shotgun-king-anew`)

> **Purpose:** a fresh agent (or the owner after a break) can resume from this
> file alone. Read `PLANNING.md` for the full history; this is *current state*.
> Update this file at the end of every working session.

---

## 1. Project in one paragraph

Private, personal-use mod project for **Shotgun King: The Final Checkmate
v1.623b** (PUNKCAKE Délicieux). The game runs on **SUGAR** — the studio's
custom Pico-8-style Lua engine (LuaJIT 2.1 / Lua 5.1, SDL3) — **not Godot**.
Deliverable = a normal SGK mod (`modded/sk-rework/`) plus a toolchain that
builds a ready-to-play modded **copy** of the game. Goal list: in-game
dev-cheat panel, ammo rework (A→B→C), free-choice card picker, enemy
picker, right-click ability cap removal + button remapping, Yu-Gi-Oh soul
deck + board-cap summons, bullet damage/crit system, balance knobs,
100%-unlock save (full specs: `PLANNING.md` §0.7). The play path never
patches game files; "injection" = adding folders under `mods/` (the
game's own mod system).

## 2. Where things are

| Thing | Location |
|---|---|
| Working branch | `arena/6424942a-shotgun-king-anew` (session 10, session-fixed; branched from `main` @ `aedfc71`, fast-forwarded to the owner's zip upload `a9e5dd2`). Session 9 = PR #8 (`2975dba`); earlier sessions = PRs #1–#7 |
| **Owner's game copy (unpacked)** | **`game/`** in this branch — exe, dlls, `data.sgr`, `lang/`, `mods/` (workshop originals), `save/`, `log.txt`, `settings.txt`. **Read §2b before touching it** |
| **Decoded game source** | **`game/decoded/`**: `code.lua` (main, ~15.4k lines), `code/*.lua` (menu, mods sandbox, gamepad, save, codex…), `code/modes/*.lua`, `libs/*.lua`, `lang/`, `assets/gfx/*.png`, shaders. Produced by `tools/sgr_extract.py`; the engine facts are summarised in **`notes/game-internals.md`** |
| Our mod | `modded/sk-rework/` (**Build 9** = Build 8 panel + the reworked mod menu: live ON/OFF text, Back restored after undoing a change, far-left legend with E1–E4 load-order codes + AUTO-FIX (§5 of script.lua, `notes/red-warnings.md`). **Build 8**: an overlay dev panel that owns no engine buttons (one dp-15 draw entity + an `append("gamepad_ctrl")` click-consume hook, bottom-left `SK DEV` tab, modal box, live labels, hidden during card choice/pause/menus, re-created on every new run). Unchanged from Build 7: damage/crit/pierce at `mk_bullet`, RELOAD + CLIP+, card AUTO/LIST pages, spawn picker, Mist-style dodge, `SKE\|call\|` intent logging + SAFE, bank restore, menu legend on the real ids — replaced in Build 9) |
| Log parser + smoke test | `tools/parse_log.py` (**49/49**: red mod text → error codes §1b, `!!` prefixes, multi-boot dedup, probe checkpoints, crash detection, **`SKE\|call` dangling-call forensics** + a Build-7 trace section), `tools/mode_guns_check.py` (**29/29**, Throne-like mode gun lists), `tools/mod_smoketest.py` (**64/64** × both `all()` semantics × default Lua/LuaJIT 2.1; the mod now runs inside a copy of the engine's **real sandbox write rules** (only replaceable keys reach the engine). The fake engine chains appends, models `gamepad_ctrl`'s mouse read, `mke`/`kl`, `remove_buts`, `reset()`, the draw calls and board clicks, re-raises the fatal unknown-id `btn()` error, and runs a verbatim port of the engine's mod-menu `open_menu`/`act_menu`/`close_menu`) |
| Live-test evidence | `live testing result/SUMMARY.md` — consolidated runs 1–6; raw packs `run 5 i believe or latest run/` and **`run 6 wow/`** (critique, powershell output, log, modlist, save, 4 crash logs) |
| Parsed live map | `notes/game-map-draft.md` (**regenerated from the run-4 log**; it now reports the boot crash and the full load-time harvest) |
| Owner feature specs (from critiques) | `PLANNING.md` §0.7 — implemented queue in `WORKLIST.md` |
| 13 workshop mods, vendored, name-verified | `dist-overlay/mods/`. **7 are locally patched** (asset-loader argument order). The list, the Quartz/Shootout note and the load order are in `dist-overlay/README.md` |
| Tools | `tools/` (build-dist.ps1 (writes the dependency-ordered `modlist.lua`), install-mods.ps1, apply.ps1, save_codec.py, make_100pct_save.py, **sgr_extract.py** (data.sgr decoder), mod-dev.md, recover.md) |
| Knowledge | `notes/` (**game-internals.md = engine facts from the decoded source, with line numbers**, map.md = live-derived code map, mods.md = mod inventory + API, review-2026-10-03.md, changelog.md, data-sgr-filelist.txt) |
| Owner archives + modding guide | `uploads/` (**gitignored**) — not in the sandbox; lives on the owner's machine. The game itself is now in `game/` (above) |

## 2b. Game-files policy (owner's instruction, session 10) — READ FIRST

- The owner's game copy is stored **unpacked in this branch under `game/`**
  (it arrived on `main` as a 4-part split zip, was extracted with all CRCs
  OK, and the zips were removed so the owner never has to upload again).
  `.gitignore` has an explicit exception (`!game/`, `!game/**`) for it.
- **To inspect the game, future sessions check out / fetch branch
  `arena/6424942a-shotgun-king-anew` and open `game/`** (or `game/decoded/`
  for readable source). Don't ask the owner to put the game on `main` again.
- **Never delete `game/`, before or after merging.** The owner removes it
  manually after testing, or a later debug session does so when the owner
  asks. Don't "clean it up" on your own initiative.
- Decoding: `python3 tools/sgr_extract.py game/data.sgr game/decoded` (pure
  Python, ~24 s; `--all` adds fonts/sfx/music, ~92 MB; `--list` prints the
  entry table). Format: `notes/game-internals.md` §0.
- Assets for modding (symbols, sprites) can be taken from
  `game/decoded/assets/gfx/*.png`. Personal use only (§8).

## 3. Hard-won facts (do not re-derive)

> Session 10: the facts below came from live runs. Where the decoded source
> (`notes/game-internals.md`) refines them, that file is the more reliable
> one; the corrections are inline.


1. **Mod folder name MUST equal `name=` in info.lua.** Mismatch = silent
   no-load. Mods must be unpacked folders — zips/rars in `mods/` are ignored.
2. **Mod API**: `append`/`prepend` any global game function (id-registered),
   `on_*` event callbacks, custom cards via `concat(CARDS, {...})` (fields
   incl. `pwe` = offer weight, `knockback`, `pierce`), custom modes in
   `modes/`, `gimme("global"|"replaceable"|"forbidden"|"autocall")`
   introspection, `_log()` → log.txt. Patterns confirmed in the vendored
   mods: `for k in all(gimme("global"))` yields global names;
   `for i,v in ipairs(MODLIST) do if v.title == "…"` finds your own mod.
2b. **🛑 `btn()` is fatal on unknown ids — live-proven by crashing build 5
   (run 4, `ERR Button left for player 0 doesn't exist.`, game quits).** It is
   an engine-side fatal, so it cannot be caught. *(Session 10: `pcall` is not
   on the sandbox's forbidden list; Build 8 uses it only around its panel,
   behind a `type(pcall)` check, and logs `pcall=` so run 7 confirms it.)* Only call
   `btn/btnp/btnr/defbtn` with ids the running game published: the
   `INPUT_ASSIGNEMENT` actions (`validate/cancel/shoot/special/reload/unsafe`),
   `ctrl`, and the bound mouse codes `m:lb/m:rb/m:mb`. Everything else —
   `left`, `right`, `middle`, `mouse4`, `wheel`… — is a one-way ticket.
   **General rule: engine calls take only confirmed arguments.**
2c. **Engine UI (corrected in session 10 from the source):** `mk_text_but`
   returns a visual entity whose CHILD is the button. Remove the group with
   **`kl(group)`** (the old `del(ents, child)` removed nothing, because the
   child lives in `group.ents`). **Never call `remove_buts()` from a mod:**
   the game calls it ~40× per turn, and it also ends the player's turn state
   (`selecting/playing/aiming=false`, squares unselectable). That is what
   broke Build 7. Overlapping buttons **all** fire on one click. `reset()`
   empties `ents` at every `init_game`. A mod writes engine globals only for
   the sandbox's *replaceable* keys (incl. `mcl/mlb/mcr/mx/my`, not
   `cancel_but`). Full detail: `notes/game-internals.md` §1–2.
2d. **Mod-menu button ids are plain strings**: `play options codex credits quit
   mods throne endless chase charnier tutorial back save_back`, the mod-list
   rows `" ON "` / `"OFF "` and the arrows `é`/`è` (a later pass repeats them
   with a numeric prefix). Nothing compares against MODLIST titles — that's
   why the Build-6 legend never attached.
2e. **Bank file format** (`save/mods/<mod>.bnk`): ASCII `<w>:<h>:<cell>:<hex>`
   — run 5: `128:64:4:` + 65536 hex chars = 32768 bytes, little-endian i32 per
   4-byte cell; cells `(0,0)=505` (magic) and `(1,0)=1` (God Mode). Read with
   `bget(x,y)`, write with `bset(x,y,v)`, flush with `savbnk()`; the game
   keeps a byte-identical `_bak`.
2f. **Damage/bullet route (live)**: `fire` → `mk_bullet(x, y, angle, life)` →
   bullet carries `dmg`/`pierce`/`shot`/`life` → `hit(p, dmg, tags)` →
   `fx_dmg(p, dmg)` (a2 = final damage) → `bleed_dmg`. **`ev_hit` never fires.**
   The shot is 4 bullets sharing one origin. `stack.chamber_max` is the live
   chamber field (1); there is no `stack.ammo_max`/`stack.chamber`.
3. **Save format** (`save/*.sav`): `[u32 BE plaintext length][zlib stream]`,
   payload `PUNKCAKE\nt{...}\nFOREVER`, no indentation, string values carry
   a trailing 0x1F. `tools/save_codec.py` parses/serializes **byte-identical**
   on all 6 real v1.623b saves (prior session). `make_100pct_save.py` =
   unlock-all (128 achievements, weapons 1–9, rank 20 + badges, endless
   floor 15 ⇒ chase unlocked, 164-card codex). Backups + `--restore`.
4. **Mods are OFF by default (black text; white = ON); enable state lives in
   `mods/modlist.lua`** — format (byte-verified run 2):
   `return {` CRLF `\t{ '<mod name>', <bool> },` … `}` (tab indent, trailing
   comma on every entry, no trailing newline). The game writes it at boot;
   `build-dist.ps1` now writes it too → built copies boot with `sk-rework`
   already ON (`-AllModsOn` for everything). Mod menu = click **Play**, top
   entry; click = on/off, up/down = load priority only.
   Title bar with mods: `MODDED: ON - ACHIEVEMENTS: OFF` = Steam tracking
   paused, save-side achievements fine (run 2: all 128 stayed True).
4d. **Per-mod saves**: an active mod gets `save/mods/<name>.sav`
   automatically (raw PUNKCAKE plaintext — NO zlib container) +
   `save/mods/reg.sav` registry (`s"name"\x1f: f"save/mods/name.sav"`).
   `MODSAV`/`save` globals exist = candidate API for sk-rework config
   persistence. The game also keeps one-generation `.sav.bak` snapshots.
   `loadfile` does NOT exist in the mod env.
4b. **Game log wraps every line in `  . ` / ` !! `** — any new parser/grep
   must strip it (session-4 parser bug). Lua errors still at log END.
4c. **`append()` is the only proven hook.** `on_*`/`upd` globals never fire
   for plain mods (live-proven); `append/prepend/gimme` are mod-env functions
   (absent from `gimme("global")` but working). Never define global `on_*`
   names (can shadow Glac Terminal's dispatch).
5. **data.sgr** = 79 MB package with all 278 game files. **Cracked in session
   10** (XOR/xorwow cipher + zlib + a simple container) →
   `tools/sgr_extract.py`, output committed in `game/decoded/`.
5b. **Mod asset loaders take `(name, "file.ext")`** — the reversed order
   silently loads nothing (run 6: 21 × `didn't match any files`, Fairy fatal
   `inexistent surface`). **Mods load top-to-bottom from `modlist.lua`**, and
   Glac Terminal must be last. Both are fixed in the build
   (`dist-overlay/README.md`).
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

## 5. Current state & immediate next step (session 10)

**Run 6 (owner, 2026-10-05, Build 7)** proved the bank read-back
(`SKUI|bank|ready=true|magic=505`) and the mod-menu widgets. It also
exposed the panel bug: SK DEV → CLIP+ moved the king, and the panel never
came back. With all mods ON there were 4 crash logs (`fairy_cards`) and red
load-order warnings. Analysis: `live testing result/SUMMARY.md` Run 6.

**Session 10 did:**
1. Stored the owner's game in `game/` (§2b), cracked `data.sgr`, and
   committed the decoded source plus `tools/sgr_extract.py`; findings in
   `notes/game-internals.md`.
2. **Build 8 item 1 — the panel**, rebuilt from the source facts: one plain
   draw entity at dp 15, plus an `append("gamepad_ctrl")` hook that
   hit-tests the tab/box and consumes the click (`mcl/mcr/mlb=false`)
   before any `mk_but` updates. Modal while open (outside click / CLOSE
   closes it); hidden while `leveling`/`pause`/`menu`/`any_card_menu`;
   re-created when `ents` is replaced; pico-font 9 px buttons; live labels;
   a fast-forward click lock. Never calls `remove_buts()`.
3. **Item 2:** 7 workshop mods patched to `newsrf(name, "file")`.
   Quartz/Shootout no longer override base sheets.
4. **Item 3:** `build-dist.ps1` writes the dependency order, Glac Terminal
   last.
5. Verified without the game: smoke **59/59** ×4 (real sandbox write rules;
   mutation-checked), parser 44/44, codec 2/2, all 37 mod Lua files compile
   under LuaJIT 2.1. `build-dist.ps1` couldn't be executed (no `pwsh`); its
   ordering logic was checked against the folder list in Python.

6. **Build 9: owner's Build 8 items 4–6** (approved in session 10):
   - **Item 4, Throne-like gun lists:** Quartz Throne, Fairy Endless,
     Nightmare and Card Lab carry the base 9-gun Throne list.
     - **Quartz never called `savbnk()`**, so its unlocks lived only in RAM.
       It now flushes after every `save()`.
     - Quartz and Fairy unlock all guns in-game (`SK_ALL_GUNS`).
     - Stale `weapons` sheet overrides are commented out.
     - **Decision:** the 100% tool does **not** write mod banks. Mods can't
       read the base unlocks (`DEN` is forbidden; `bget` is per-mod), and
       an offline write would have been lost on Quartz's next boot anyway.
       The in-mode unlock is more robust. Checked by
       `tools/mode_guns_check.py` (29 checks). Details:
       `dist-overlay/README.md`.
   - **Item 5, mod menu** (`script.lua` §5): appends to `open_menu` /
     `act_menu` / `gamepad_ctrl`, and never adds entities to `menu`.
     - Row text is re-synced live (`e.name = e.id`).
     - Back and Reset are restored when the list matches the state at
       opening.
     - The legend is one plain dp-4 entity at x=4, vertically centred, with
       pico-font short lines and no hover.
     - `modcheck` gives E1–E4 at boot and in the menu; AUTO-FIX
       stable-sorts to the canonical order and enables needed mods.
     - The owner rule "red text = error code" is implemented in
       `notes/red-warnings.md` (T/A/D/C/S/L/B) and `parse_log.py` §1b.
     - Mock render: `notes/img/build9-modmenu-mock.png`.
   - **Item 6:** INSTALL Step 5 is rewritten as the Build 9 test list
     (A mod menu, B modes, C panel), listing only the tests.
   - Verified: smoke **64/64** ×4 (with a verbatim port of the engine's
     `open_menu`/`act_menu`/`close_menu`; mutation-checked: 3 injected bugs
     each caught), `mode_guns_check` 29/29, parser 49/49, codec 2/2, and
     all mod Lua compiles under LuaJIT 2.1.

**Next: owner live run of Build 9.** Rebuild with `build-dist.ps1`
(INSTALL Step 4), then do INSTALL Step 5:
- A1–A6: mod-menu legend, live toggle, Back after on→off, the AUTO-FIX
  flow, no red text with all mods ON;
- B1–B4: 9 guns in Quartz, Fairy, Nightmare and Card Lab; Quartz and Fairy
  unlocks survive a relaunch;
- C1–C8: the Build 8 panel, never run live (CLIP+ must not move the king).

Collect with `apply.ps1 -GetInsights`.
Any red text from an ON mod is an error: read `parse_log.py --print` §1b.

**Approved items still open:** none. **Owner asks still open:** the
features in `live testing result/SUMMARY.md` "Still open".

## 6. Owner (human) intervention points

- ~~Harvest + verification runs 1–3~~ **DONE and consolidated**
- ~~Build 6 playtest~~ **done (run 5)**
- ~~Build 7 playtest~~ **done (run 6)**
- Rebuild with Build 9 and playtest it: INSTALL Step 4 (rebuild), then the
  Step 5 test list (A1–A6, B1–B4, C1–C8).
- Delete `game/` from the branch yourself once testing no longer needs it
  (agents never do that unprompted, §2b).
  Collect `log.txt` with `apply.ps1 -GetInsights`; if it crashes, also send the
  newest `crash_log_*.txt` — the parser names the last engine call that started
  and never finished, so the failing control is identifiable from the log.
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
  works and is ephemeral. System `pip install lupa` fails (PEP 668,
  externally-managed): create a venv first —
  `python3 -m venv /tmp/skvenv && /tmp/skvenv/bin/pip install lupa`, then run
  the smoke test with `/tmp/skvenv/bin/python tools/mod_smoketest.py`
  (plain `python3 tools/mod_smoketest.py` fails on `import lupa`).
- `uploads/` is gitignored and **absent in this session** — docs referencing
  it describe the owner's machine.
- No unrar/7z/bsdtar/xxd preinstalled. A *multi-volume* zip can't be joined
  with `zip -s 0`/`zipfile`; session 10 used a small custom extractor
  (ephemeral `/tmp/gz/extract.py`). The game is already unpacked in `game/`.
- Exe analysis venv (ephemeral): `python3 -m venv /tmp/skvenv &&
  /tmp/skvenv/bin/pip install lupa pefile capstone` (capstone needs
  `skipdata=True`; don't name a script `dis.py`).

## 8. Rules that still stand

- Never commit game assets or archives (`.gitignore` guards: *.rar *.zip
  *.exe *.dll *.sgr, uploads/, dist/, save_backup_/, __pycache__/).
  **Sole exception: `game/`** (owner's explicit instruction, §2b), which is
  never deleted by an agent.
- Workshop mods in `dist-overlay/` are mirrored for the owner's personal
  build (owner confirmed freely distributed); remove on author request.
- Mod code: additive hooks only, `-- SK-REWORK:` markers, stable hook ids,
  discoveries logged to `notes/map.md` immediately.
- Personal use only — nothing public.
