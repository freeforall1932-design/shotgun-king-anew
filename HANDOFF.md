# HANDOFF — Session 2026-10-04 (session 8, branch `arena/01a105e5-shotgun-king-anew`)

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
| Working branch | `arena/01a105e5-shotgun-king-anew` (session-fixed branch; PRs #1 and #2 already merged to `main`) |
| Our mod | `modded/sk-rework/` (**Build 6** — Build 5 crashed at boot in run 4; build 6 has the evidence-gated input probe, safe-first probe chain with checkpoints, plus the Phase-2c panel and legend/Back helper) |
| Log parser + smoke test | `tools/parse_log.py` (37/37: `!!` warning prefixes, multi-boot dedup, probe checkpoints, **crash detection with the failing frame**), `tools/mod_smoketest.py` (36/36 under each `all()` semantics; default + LuaJIT 2.1; fake `btn()` re-raises the fatal unknown-id error) |
| Live-test evidence | `live testing result/SUMMARY.md` — consolidated runs 1–4; **run 4's raw pack is still in `live testing result/uploads/`** (log + 2 crash logs + saves + critique) and can be deleted once the run-5 pack arrives |
| Parsed live map | `notes/game-map-draft.md` (**regenerated from the run-4 log**; it now reports the boot crash and the full load-time harvest) |
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
2b. **🛑 `btn()` is fatal on unknown ids — live-proven by crashing build 5
   (run 4, `ERR Button left for player 0 doesn't exist.`, game quits).** There
   is no `pcall` in the mod sandbox, so it cannot be caught. Only call
   `btn/btnp/btnr/defbtn` with ids the running game published: the
   `INPUT_ASSIGNEMENT` actions (`validate/cancel/shoot/special/reload/unsafe`),
   `ctrl`, and the bound mouse codes `m:lb/m:rb/m:mb`. Everything else —
   `left`, `right`, `middle`, `mouse4`, `wheel`… — is a one-way ticket.
   **General rule: engine calls take only confirmed arguments.**
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

## 5. Current state & immediate next step (session 8)

**Run 4 happened (owner, 2026-10-04) and Build 5 crashed the game at boot.**
Both launches died with the same fatal — `ERR Button left for player 0
doesn't exist.` at `mods/sk-rework/script.lua:817`, inside the mod's own load.
Cause: the input probe blind-called `btn()` on names the engine does not know;
in SUGAR an unknown `btn()` id falls through to the input-id parser and a
malformed id is **fatal**, and the mod sandbox has no `pcall`. The "no intro"
vs "intro then crash" difference the owner saw was just timing — the crash is
deterministic and identical in both logs.

**But the run still paid off.** The whole load-time harvest completed before
the crash and is now promoted into `notes/map.md` (run-4 section):
- the live `gimme("global")` API surface (63 planned names present, incl. the
  full soul/scepter family `add_soul`/`activate_soul`/`add_soul_slot`/
  `remove_soul_slot`/`exhaust_soul`/`add_scepter`/`activate_scepter`/
  `recal_scepters`/`get_scepter`, plus `fire`/`mk_bullet`/`hit`/`ev_hit`/
  `pick`/`add_any_card`/`level_up`/`is_card_available`/`newbnk`/`bget`/`bset`);
  `savbnk` and `scepters` do **not** exist as globals (the engine writes the
  per-mod save itself, and `scepters` is only *replaceable*);
- all 186 cards field-by-field (3353 `SKCF|` lines) — the ten `special=`
  right-click cards are exactly the owner's list (strafe, scope, decree,
  grenade ×5, orb, dig);
- 14 piece definitions with the real schema (`type/name/hp/tempo/danger/seek/
  behavior/sided/hdy/reap`), the 25 offer-eligible candidates, and the input
  dump (`INPUT_ASSIGNEMENT` is a formatted string; mouse ids stop at
  `m:lb`/`m:rb`/`m:mb` — no mouse4/mouse5 anywhere).

**Build 6 (this session) fixes the crash**: `btn*()` is only called with ids
the live game published; the probe chain is reordered safe-first (cards →
exclude → souls → bank → input) with `SKA2|probe|<name>=done` checkpoints so a
partial run is diagnosable; the parser now detects crashes and prints the
failing frame. The smoke test's fake engine now **raises** on unconfirmed ids
exactly like the real engine — re-injecting the run-4 bug into the script
makes the harness fail with the live error message. Sandbox: parser 37/37,
smoke 36/36 × both `all()` semantics × default Lua and LuaJIT 2.1.

**Next: owner live run of Build 6, in play (not just boot).** Run 4 proved the
load-time chain works; everything runtime-only is still unobserved: Dev-panel
actions (`SKUI|panel|`), mod-menu Back/legend ID detection (`SKI|menu_button|`,
`SKI|menu_but|`), bank persistence (`SKUI|bank|magic=505`), and the damage
trace (`SKD|`) during real shots. Collect with `apply.ps1 -GetInsights`; if the
game dies, send `log.txt` **and** the newest `crash_log_*.txt`.

**The owner's feature requests are fully specified** (five asks, refined
over several Q&A rounds into `PLANNING.md` §0.7 items 6–11): right-click
ability cap removal (soft-coded discovery, any number of ability cards,
bindings RMB + side buttons + optional middle click, scepter cap relaxed
too), free-choice card picker, the Yu-Gi-Oh soul deck (any soul allowed —
pawn behavior stays card-driven; summons capped by board capacity only),
the bullet damage & crit system (configurable damage/crit-chance/crit-damage,
pierce auto-crits), the button-remap menu, and the mod-menu Back button.
Design rule throughout: **nothing hardcoded that can't be confirmed —
universal, soft-coded, adaptable as the owner plays.** Run 4 sharpened this
into a hard safety rule: **engine calls take only confirmed arguments.**

Verified without the game this session: parser selftest 37/37 (incl. the
crashed-chain and crash-render cases); smoke test 36/36 under both `all()`
semantics on default Lua and LuaJIT 2.1, including the meta-check that the
fake engine still rejects `btn("left")` and an end-to-end run of the real
`script.lua`; Python compilation. Safety rules unchanged: no
`pcall`/`loadfile`, nil/boolean-safe `sv()`, capped loops, additive hooks only,
all static probe dumps after READY, and no unconfirmed arguments to engine
functions.

## 6. Owner (human) intervention points

- ~~Harvest + verification runs 1–3~~ **DONE and consolidated**
- Apply Build 6 to the modded copy (rebuild keeps the pre-enable + unlock) and
  playtest **in play**: native panel actions, Back/legend in the mod menu,
  bank persistence across a boot, and a few shots so the damage trace fires.
  Collect `log.txt` with `apply.ps1 -GetInsights`; if it crashes, also send the
  newest `crash_log_*.txt` (the parser now names the failing frame).
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
