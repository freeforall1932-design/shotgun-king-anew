# HANDOFF — Session 2026-10-04 (Run 5 follow-up / Build 7, branch `arena/01a1062a-shotgun-king-anew`)

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
| Working branch | `arena/01a1062a-shotgun-king-anew` (session-fixed branch) |
| Our mod | `modded/sk-rework/` (**Build 7**, sandbox-tested but not live-tested; Build 6 completed Run 5 without a crash) |
| Log parser + smoke test | `tools/parse_log.py` (37/37, including warning prefixes, multi-boot dedup, checkpoints, and crash location); `tools/mod_smoketest.py` (37/37 in both `all()` modes on default Lua + LuaJIT 2.1) |
| Live-test evidence | `live testing result/SUMMARY.md` — consolidated runs 1–5; Run 5's raw pack is in `live testing result/run 5 i believe or latest run/` |
| Parsed live map | `notes/game-map-draft.md` (**regenerated from the Run-5 Build-6 log**) |
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

## 5. Current state & immediate next step (Run 5 follow-up / Build 7)

**Run 5 tested Build 6 in the real game.** It ran for about 22 minutes, shut
down normally, and completed all five diagnostic checkpoints. The live parser
reports 30 hooks, 920 globals, 14 mods, 186 cards, 30 sampled turns, 12 `fire`
calls, 48 bullet samples, and 30 `hit` samples. The raw log/critique/insights
are retained at `live testing result/run 5 i believe or latest run/`; the
root `notes/game-map-draft.md` has been regenerated from that log.

**Run-5 corrections / open checks (keep these exact):**
- The owner confirms the mod-menu **Back button worked**. The absence of
  `SKUI|menu|widgets_added` is not evidence it failed; do not repeat that
  inference.
- The owner did **not** test toggling a mod ON and checking/using **Save &
  Reboot**. The next run must explicitly perform toggle → Save & Reboot →
  verify the mod remains ON after reboot.
- No soul card was used and no soul was activated; no Wand/scepter skill was
  activated. Build 7's **TEST SOUL/WAND** button directly grants Majestic
  Censer + Wand of Souls so these tests do not depend on rare card offers.
- Build 6's Run-5 damage probes are now present, but the owner reports God Mode
  did not protect the king. Mist-style escape, damage/crit controls, pickers,
  soul-deck overhaul, and input remapping are not implemented; mark them
  **DO NOT TEST YET**.
- Run 5 owner feedback: closing the panel left frozen/visible labels; ally
  spawns can obstruct the king and a pawn/occupancy ghost was reported after
  resigning and starting a new run. Build 7 changes cleanup, but this is only
  sandbox-tested so far.

**Build 7 is in the working tree and has not been live-tested.** Changes:
`RELOAD`, experimental `CHAMBER +1` (`uplift({chamber_max=1})`, not yet
confirmed in the game), direct test-card grants, and stronger panel entity
cleanup. It also removes the confusing no-op `DMG GATED` control. Follow
`INSTALL.md` Step 5; don't treat smoke-test results as game facts.

**Sandbox verification completed after these edits:**
- `python tools/parse_log.py --selftest` — 37/37.
- `PYTHONPATH=/tmp/sk-rework-deps python tools/mod_smoketest.py` — 37/37 for
  value/pair `all()` semantics on default Lua and LuaJIT 2.1.
- `python -m py_compile` — parser, smoke harness, save codec, and unlock tool
  compile; `python tools/save_codec.py --selftest` — 2/2; `git diff --check` —
  clean.
- The smoke test checks direct card-grant calls, temporary chamber-capacity math in
  its fake engine, and action-entity cleanup. The chamber behavior and visual
  cleanup still need confirmation in the actual game.

**Immediate next step:** the owner should apply/rebuild Build 7 and follow
`INSTALL.md` Step 5. Collect `log.txt`, `modlist.lua`, and the `save/` folder
with `apply.ps1 -GetInsights`; attach the entire insights pack. No Build 7 live
run has occurred.

## 6. Owner (human) intervention points

- ~~Runs 1–5~~ **Recorded in `live testing result/SUMMARY.md`** (Run 5 was Build 6).
- Apply/rebuild Build 7 and follow `INSTALL.md` Step 5. Test mod ON → Save &
  Reboot → verify-after-reboot; if convenient, test OFF → a second Save &
  Reboot → verify it stays OFF. Confirm legend visibility (Back is already
  confirmed), then test safe panel controls one at a time. Use the direct soul /
  Wand grant instead of waiting for random offers. Do not test God Mode,
  damage/crit, remapping, pickers, or other unimplemented features yet.
- Collect the full insights pack with `apply.ps1 -GetInsights`; if it crashes,
  include the newest `crash_log_*.txt`.
- At deployment: flip repo private, optional git history scrub (old commits
  still contain the rars), or archive repo if abandoning.

## 7. Environment quirks (this sandbox / Arena agent mode)

- **The platform may reset the local branch to the base commit between
  turns.** Working files survive; commits survive on the remote. Recovery:
  `git fetch origin && git reset --soft origin/arena/…` then `git reset`.
- Network: `git`/`api.github.com`/`pypi` reachable. **Blocked:** raw
  GitHub, GitHub release assets, Debian apt mirrors (apt install fails).
- **No `pwsh` or system `lua`** → PowerShell scripts are static-parsed but not
  executed here. Python 3.11 is available. Build-7 smoke tests used a temporary
  Lupa install at `/tmp/sk-rework-deps` (`python -m pip install --target
  /tmp/sk-rework-deps lupa`); that path is ephemeral and not part of the repo.
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
