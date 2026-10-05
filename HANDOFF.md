# HANDOFF — Session 2026-10-05 (session 9, branch `arena/01a10d48-shotgun-king-anew`)

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
| Working branch | `arena/01a10d48-shotgun-king-anew` (session-fixed). **Session 9's work is merged to `main` as PR #8** (merge commit `2975dba`), so `main` is current and a fresh session can branch from it; earlier sessions = PRs #1–#7 |
| Our mod | `modded/sk-rework/` (**Build 7** — run-5 fixes + features: panel v2 with the engine's own `remove_buts()` CLOSE and per-action page rebuild, damage/crit/pierce at `mk_bullet`, RELOAD + CLIP+, card AUTO/LIST pages + cardless fallback + summon-on-card, spawn piece picker with diagonal-first squares, Mist-style dodge, `SKE|call|` intent logging + SAFE mode, bank restore, menu legend on the real run-5 ids) |
| Log parser + smoke test | `tools/parse_log.py` (**44/44**: `!!` prefixes, multi-boot dedup, probe checkpoints, crash detection, **`SKE\|call` dangling-call forensics** + a Build-7 trace section), `tools/mod_smoketest.py` (**47/47** × both `all()` semantics × default Lua/LuaJIT 2.1; the fake engine chains multiple appends per target like the real one, models `remove_buts`/`goto_sq`/`flr`/`mk_bullet`, and re-raises the fatal unknown-id `btn()` error) |
| Live-test evidence | `live testing result/SUMMARY.md` — consolidated runs 1–5; run 5's raw pack (`run 5 i believe or latest run/`: log, save/bank files, critique) is absorbed and kept as the newest evidence; the run-4 pack was deleted |
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
2c. **Engine UI: `del(ents, e)` does NOT remove `mk_text_but` groups** — run 5
   showed the panel's state flipping to closed while its buttons stayed on
   screen. The engine's own **`remove_buts()`** is the proven primitive
   (disgraced_justice ×7, glac terminal); it clears the button layer, so a mod
   panel must be rebuilt afterwards (sk-rework does this on the next turn /
   next click).
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

## 5. Current state & immediate next step (session 9)

**Run 5 happened (owner, 2026-10-04) and it was a full success for Build 6**:
one clean boot, ~22 minutes of real play (`READY build=6 hooks=30 globals=920`,
`Application ran for 1311.772 s`), every probe block completed, and all four
open Build-6 questions answered — panel renders + actions fire, the real menu
ids are captured, the bank write path is proven, and the damage route is
traced (`mk_bullet` → `bullet.dmg` → `hit(p,dmg,tags)` → `fx_dmg(p,dmg)`;
`ev_hit` never fires). Full absorption: `notes/map.md` run-5 section,
`SUMMARY.md` Run 5, `PLANNING.md` §0.7b.

**Run 5 also exposed three real bugs and produced 8 owner asks**, all of which
Build 7 addresses:
1. **The panel never really closed** — the engine ignores `del(ents, e)` on
   `mk_text_but` groups, so the mod's state and the on-screen buttons diverged
   (owner: "close it doesnt close the ui", "button is frozen to brown").
   Build 7 clears through the engine's own `remove_buts()` and rebuilds the
   page after every action so the labels always show live state.
2. **The mod-menu legend could never attach** — the predicate compared MODLIST
   titles to ids; the real ids are `play/mods/save_back/" ON "/"OFF "` etc.
   Build 7 arms on the harvested ids.
3. **Spawn-ally only ever made a pawn and could block the king's 1-tile move**
   — Build 7 adds a piece picker page and a square picker that prefers a
   DIAGONAL neighbour, plus summon-on-card for the ext=3 `allies` cards.

**Build 7 also ships the feature work the run-5 answers unblocked**: the
damage/crit/pierce system (applied at `mk_bullet`, persisted), RELOAD +
CLIP+ (`reload`, `stack.chamber_max`), card AUTO/LIST pages with the cardless
fallback, Mist-style dodge on lethal hits, `SKE|call|<name>=start/=ok`
intent logging (so a crash names the failing control) and a `SAFE` toggle that
limits a boot to one gameplay-mutating engine call.

**Next: owner live run of Build 7, control by control.** Rebuild the copy
(`build-dist.ps1`, or `apply.ps1` over it), then in play click each SK DEV
control once — `+3 AMMO`, `RELOAD`, `CLIP+`, `CARD:AUTO`, `CARD NOW`, `CARDS>`
(take a card), `SPAWN...` (pick a knight), `GOD:on` then take a lethal hit,
`DMG:on` + `DMG+` + `CRIT+` then fire a few shots, `SAFE`, `CLOSE` — and open
the mod menu once for the legend. Collect with `apply.ps1 -GetInsights`; if
the game dies, send `log.txt` **and** the newest `crash_log_*.txt` (the parser
now names the last engine call that started but never finished).

Verified without the game this session: smoke test **47/47** under both
`all()` semantics on default Lua and LuaJIT 2.1 (including the panel
close-state regression, the offer-screen guard that keeps a stray click from
wiping the engine's level-up buttons, damage rolls, dodge route validation,
SAFE blocking, card list pages and the fake engine's multi-append chaining);
parser
**44/44** (incl. the dangling-call crash-forensics case and a Build-7 render
check); save codec 2/2; Python compilation.

## 6. Owner (human) intervention points

- ~~Harvest + verification runs 1–3~~ **DONE and consolidated**
- ~~Build 6 playtest~~ **done (run 5)**
- Apply Build 7 to the modded copy (rebuild keeps the pre-enable + unlock) and
  playtest it control-by-control (list in §5 / `WORKLIST.md` owner to-do).
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
