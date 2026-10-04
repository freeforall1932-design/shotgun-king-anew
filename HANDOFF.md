# HANDOFF — Session 2026-10-04 (session 7, branch `arena/01a10404-shotgun-king-anew`)

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
| Working branch | `arena/01a10404-shotgun-king-anew` (session-fixed branch; PRs #1 and #2 already merged to `main`) |
| Our mod | `modded/sk-rework/` (Build 5 Phase-2c native-button Dev panel + legend/Back helper + §0.7 probes; live run pending) |
| Log parser + smoke test | `tools/parse_log.py` (31/31 incl. Build-5 + `!!` warning prefixes; multi-boot dedup), `tools/mod_smoketest.py` (33/33 under each `all()` semantics; default + LuaJIT 2.1) |
| Live-test evidence | `live testing result/SUMMARY.md` — **consolidated** (raw logs/screenshots/saves deleted after absorption; findings live in the docs below) |
| Parsed live map | `notes/game-map-draft.md` (from run-3 log: SKM/SKC sections live) |
| Owner feature specs (from critiques) | `PLANNING.md` §0.7 — implemented queue in `WORKLIST.md` |
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
4. **Mods are OFF by default (black text; white = ON); enable state lives in
   `mods/modlist.lua`** — format (byte-verified run 2):
   `return {` CRLF `\t{ '<mod name>', <bool> },` … `}` (tab indent, trailing
   comma on every entry, no trailing newline). The game writes it at boot;
   `build-dist.ps1` now writes it too → built copies boot with `sk-rework`
   already ON (`-AllModsOn` for everything). Mod menu = Play screen's top
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

## 5. Current state & immediate next step (session 7)

**All live runs 1–3 are absorbed and consolidated** in
`live testing result/SUMMARY.md`; the toolchain remains live-proven:
`build-dist.ps1` pre-enables sk-rework, auto-applies the unlock-all, and the
parser handles multi-boot logs. Build 5 is now in the repo but **has not been
run in the game**.

Build 5 contains: native `mk_text_but` controls for +ammo, random eligible
card, dynamic ally spawn, and best-effort God Mode; mod-menu Back/legend
widgets attached by an additive `mk_menu_but` hook when IDs match MODLIST;
post-READY `SKCF/SKOF/SKS/SKD/SKI/SKUI` probes. Damage multipliers are gated
until the live hit route is confirmed. New UI/menu behavior and runtime data
remain provisional until the owner runs it.

Also done this session: promoted static code-map findings into `notes/map.md`,
fixed `save_codec.py --selftest` to work without arguments (built-in checks),
created Build-5 cover art, and synced README / WORKLIST / mod-dev docs.

**The owner's feature requests are fully specified** (five asks, refined
over several Q&A rounds into `PLANNING.md` §0.7 items 6–11): right-click
ability cap removal (soft-coded discovery, any number of ability cards,
bindings RMB + side buttons + optional middle click, scepter cap relaxed
too), free-choice card picker, the Yu-Gi-Oh soul deck (any soul allowed —
pawn behavior stays card-driven; summons capped by board capacity only),
the bullet damage & crit system (configurable damage/crit-chance/crit-damage,
pierce auto-crits), the button-remap menu, and the mod-menu Back button.
Design rule throughout: **nothing hardcoded that can't be confirmed —
universal, soft-coded, adaptable as the owner plays.**

**Next: owner live run of Build 5** using `INSTALL.md`/`apply.ps1 -GetInsights`:
verify the panel actions, Back/legend detection, config-bank save, and capture
`SKCF/SKOF/SKS/SKD/SKI/SKUI` output. Then promote confirmed values to
`notes/map.md`; only afterward implement the queued ability cap, ammo/crit,
card-picker, soul-deck, and input-remap systems.

Verified without the game this session: parser selftest 31/31; smoke test
33/33 under both `all()` semantics on default Lua and LuaJIT 2.1 (includes
Lua load, hook registration, button callbacks, cheats, parser handoff);
save-codec selftest 2/2 built-in
parser+container checks; Python compilation. The six real saves had been
roundtrip-verified in an earlier session; they are not present here. Safety
rules unchanged: no `pcall`/`loadfile`, nil/boolean-safe `sv()`, capped loops,
additive hooks only, and all static probe dumps after READY.

## 6. Owner (human) intervention points

- ~~Harvest + verification runs 1–3~~ **DONE and consolidated**
- Apply Build 5 to the modded copy (or use the updated build) and playtest
  the native panel, Back/legend, and probes. Collect `log.txt` with
  `apply.ps1 -GetInsights`; report crashes (error at log END; missing READY
  after save-and-reboot can be the known log collision, not a failure).
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
