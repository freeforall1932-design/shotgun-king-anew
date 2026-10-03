# WORKLIST — pending tasks, audit results & live-test tracker

> Living document. Check things off in commits. Companion: `HANDOFF.md`
> (state), `notes/review-2026-10-03.md` (readiness review),
> `notes/changelog.md` (what changed file-by-file).

## 🔴 Critical path (blocks all features)

**Live-test ladder** — risk-ordered, each step reversible.
**Canonical instructions: `INSTALL.md`** (owner layout `E:\testing\{game, repo,
ShotgunKing-Modded}`) · rationale: `notes/review-2026-10-03.md` §5.

- [x] **Step 1 — dry run**: ✅ ran, printed the dry-run copy list.
- [x] **Step 2 — build the copy**: ✅ ran twice (with and without
      `-NoInheritMods -Clean`); 14 mod folders injected; inherited zips
      unpacked & renamed; `King's Court.rar` removed as designed.
- [x] **Step 3 — launch the copy**: ✅ 14 mods listed, **ON by default**;
      menu lives under Play (top entry); click = on/off (bright text = ON);
      up/down = load priority (cosmetic renumbering).
- [x] **Step 4 — harvest the log**: ✅ run-1 log uploaded
      (`live testing result/game-insights/log.txt`) and parsed →
      `notes/game-map-draft.md` (920 globals / 41 replaceable / 26 forbidden,
      47 events, object model). **🐛 found on the way:** the parser rejected
      the good log (game wraps lines in `  . `) — fixed, selftest 23/23.
      Remaining TBDs (ammo spend/refill entry, offer roll) now have candidate
      lists in the draft; modlist.lua format awaited (build 4 SKML probe).
- [x] **Step 5 — 100% save on the copy**: ✅ game ACCEPTED it —
      Achievements 100%, chase unlocked; codex was 96% (6 special cards
      missing) → tool now writes 170 cards. `ACHIEVEMENTS: OFF` title label
      explained (Steam tracking paused while modded).

## 🟠 Next features (after log.txt)

- [ ] Phase 2c — in-game **dev-cheat panel** (native `mk_menu_but` UI):
      give ammo/cards, god mode, spawn pieces, damage multipliers
- [ ] Phase 3 — ammo rework **A** (simple scale) → playtest → **B**
      (shell economy) → **C** (shell types)  [owner decision §0.6]
- [ ] Phase 4 — card picker (reuse Royal Card Lab pattern) + enemy picker
- [ ] Phase 5 — expose vanilla `knockback`/`pierce`/bleed as player tools
- [ ] Phase 6 — balance knobs config + final packaging
- [ ] **Pre-enable mods from the toolchain** (owner critique #2): once the
      harvested `modlist.lua` format is known, `build-dist.ps1` writes it so
      no in-game toggling is ever needed (today: ON by default anyway)

## 🟢 Ready now, not blocked (agent can do without the game)

- [x] ~~**log.txt parser** (`tools/parse_log.py`)~~ — shipped session 2b,
      live-fixed session 4: strips the game's `  . `/` !! ` line prefix;
      parses `SKG|/SKR|/SKF|/SKA|/SKH|/SKE|/SKE2|/SKO|/SKW|/SKM|/SKC|/SKML|`
      into `notes/game-map-draft.md`; `--selftest` 23/23 incl. a
      game-prefixed regression case
- [x] ~~**no-game smoke test** (`tools/mod_smoketest.py`)~~ — shipped: runs
      `script.lua` against a fake SUGAR env under BOTH `all()` semantics,
      fires hooks, feeds the output to the parser; 29/29 checks (build 4)
- [x] ~~**diagnostics build 3** of sk-rework~~ — LIVE-PROVEN twice on the real
      game (load proof, 920 globals, hooks, 47 events, object dumps)
- [x] ~~**diagnostics build 4** of sk-rework~~ — shipped session 4: MODLIST
      dump (`SKM|`), card id map (`SKC|`), `mods/modlist.lua` probe (`SKML|`);
      dead `on_*`/`upd` probes removed; awaits one live run
- [x] ~~`-NoInheritMods` switch for `build-dist.ps1`~~ (review F7) — shipped
      2026-10-03 session 2b: copies get exactly the 14 known-good mods
- [ ] Real cover art for sk-rework (currently placeholder 320×180 gray)
- [ ] **Waitlist (after core features work first):** zero-argument auto-file
      discovery across all tools (auto-find `game`, `repo`, and
      `ShotgunKing-Modded` anywhere on disk without predetermined `-GameDir` /
      `-OutDir` flags; requested by owner 2026-10-03 session 3)
- [ ] `install-mods.ps1`: no .rar support (prints manual-extract hint now);
      rar mods are already vendored so low priority
- [ ] King's Court (2022 legacy mod) port to modern format — optional
- [ ] Friendly save-editor UI (beyond codec + 100% script) — optional
- [ ] Mine reference repos: modderongithub/shotgun-king-mods,
      Shotgun-King-Puzzle-Developers/Shotgun-King-Puzzle-Mod
- [ ] sk-rework `priority_hint` tuning once features stack up

## ❓ Open questions — live-test answers (2026-10-03)

1. ~~Do plain mods receive `on_*` callbacks?~~ **No.** `on_*`/`upd` never
   fired during real gameplay; `append()` is the only proven hook. (Build 4
   removed the probes; defining those globals can shadow the Terminal.)
2. ~~Are mods enabled by default?~~ **Yes, ON by default**; enable state lives
   in `mods/modlist.lua`, written by the game at boot. On-disk format still
   unknown → build 4 `SKML|` probe + `apply.ps1 -GetInsights` will capture it.
3. ~~Real field names for ammo/hp?~~ Partially: `hero.hp`, `hero.ammo`
   confirmed live; the displayed-stats table (nested ammo/health names) is a
   Terminal callback, not a global — cheat panel should read `hero.ammo`
   directly or dump `get_disp_stats()` (it IS a global).

## 🧹 Audit sweep log (latest first)

**2026-10-03 (session 4 — live test #1 absorbed; see changelog for detail):**
- ✅ live ladder steps 1–5 all ran (twice); run-1 log parsed into
      `notes/game-map-draft.md`; `notes/map.md` gained a Live-verified section
- 🐛 FIXED `parse_log.py` false "mod did not run" (game `  . ` line prefix)
- ✅ `sk-rework` build 4 shipped (SKM/SKC/SKML harvest; dead probes removed);
      smoke test 29/29 both `all()` semantics
- ✅ `make_100pct_save.py` codex 96%→100% (6 special cards) + achievements-off
      explanation; `apply.ps1 -GetInsights`; `build-dist.ps1` PLAY-THIS.txt,
      `INSTALL.md`, `README.md` corrected from the owner's critique
- ⏳ NEW (owner, ~5 min): run build 4 once + `-GetInsights`, upload the pack →
      modlist.lua format + exact special-card ids → then build-dist can
      pre-enable mods (critique #2 fully closed)

**2026-10-03 (session 3 — placement-aware INSTALL.md + `mod`/`mods` normalization):**
- ✅ **`INSTALL.md` rewritten for manual setup + `E:\testing\repo\tools` copy-paste**:
      Steps 1 & 2 are now strictly **manual (File Explorer)** (removed the broken
      `mkdir E:\testing` + Steam `Copy-Item` block that errored when `E:\testing`
      already existed and the game wasn't in `C:\Program Files (x86)\Steam`);
      Steps 3, 4, 6, 7 all `cd E:\testing\repo\tools` (where `apply.ps1`,
      `build-dist.ps1`, `parse_log.py`, and `make_100pct_save.py` live) and pass
      `"E:\testing\repo\tools\..."`
- ✅ **`build-dist.ps1` & `install-mods.ps1` handle existing `game\mod` or `game\mods`**:
      if the owner already put mods in `E:\testing\game\mod` or
      `E:\testing\game\mods` (either as compressed `.zip`/`.rar` files or
      already unpacked under their own folder names), `build-dist.ps1` now
      merges `mod\` into `mods\`, unpacks `.zip`s, renames already-unpacked mod
      folders to match `info.lua`'s `name=` (preventing duplicates or silent
      load failures), removes `.rar` and legacy non-`info.lua` folders from the
      copy, and overlays the 13 workshop mods + `sk-rework`
- ✅ **Waitlist item recorded**: zero-argument auto-discovery of files/folders
      queued for after core features are implemented and working first

**2026-10-03 (session 2b — self-logging diagnostics + parser):**
- ✅ `modded/sk-rework/script.lua` rewritten as diagnostics build 3:
      load proof, MODLIST self-check, API availability check, globals dump,
      5 `append()` hooks (new_turn/new_level/setup_piece/add_card/init_game),
      `on_*` callback probes, per-turn world state, object dumps, frame
      heartbeat; all values nil/boolean-safe; volume-capped
- ✅ `tools/parse_log.py`: log → `notes/game-map-draft.md`; 16/16 selftest;
      explains "mod didn't load" with the log tail when our lines are absent
- ✅ `tools/mod_smoketest.py`: runs the mod against a fake SUGAR env (lupa)
      under both `all()` semantics, 27/27 checks, feeds output to the parser
- 🐛 CAUGHT by the smoke test before the live run: concatenating a boolean
      (`mod.active`) crashes Lua 5.1 — sv() now handles booleans, nil, tables
- 🐛 CAUGHT: `dump_fields` skipped nested tables — the displayed-stats table
      *is* nested (`{id=,name=,value=}`), i.e. exactly where the ammo stat
      lives; now expands one level (`SKO|disp_stats|ammo.value=…`)
- ⚠️ engine nuance found in the workshop mods: `all()` yields VALUES, not
      indices (mods call the yielded elements); our code now survives both

**2026-10-03 (session 2b — single canonical install path):**
- ✅ **`INSTALL.md` added** — the one click-by-click guide: whole-repo
      download answer, `E:\testing\{game, repo, ShotgunKing-Modded}` layout,
      steps 1–7 with per-step checks, success checklist, live-testing vs
      roadmap boundary, undo table, troubleshooting, clearly-marked
      variations
- ✅ README points to INSTALL.md; its own step list reduced to a summary so
      there are no competing/contradicting instructions
- ✅ `build-dist.ps1`: header documents the canonical `-OutDir` usage;
      `PLAY-THIS.txt` now names the source folder + exact unlock command;
      end of run prints the playable exe path and the -GetLog command
      (exe auto-detect prefers a name matching shotgun/king)
- ✅ 3/3 `.ps1` re-parsed clean after the edits

**2026-10-03 (session 2 — review + README + fixes):**
- ✅ README rewritten: clone-vs-install answered up front, honest
      ✅/🟡/⛔ status table, roadmap demoted; review doc added
- ✅ `make_100pct_save.py`: `throne` setdefault fix; friendly errors for
      missing save dir/files; `--restore` works with `save/` deleted
- ✅ `save_codec.py --help` prints usage (was treated as a filename)
- ✅ `build-dist.ps1`: unambiguous stray-archive filter; PLAY-THIS.txt
      explains copy semantics + how to unlock the copy
- ✅ Verified this session: py_compile; 100% tool E2E on disposable saves
      (incl. F2 regression test); 3/3 `.ps1` tree-sitter parse clean;
      14/14 mod folders `name=`-correct; sk-rework Lua compiles
- ⚠️ KNOWN: PowerShell never executed in sandbox — first run on owner
      machine may surface behaviour quirks; report back
- ⚠️ KNOWN: save acceptance by game + mods-auto-enable remain unproven

**2026-10-03 (sweep #2):**
- ✅ git tree clean; python tools py_compile OK; save codec selftest 6/6
- ✅ 13 vendored mods name-verified; sk-rework name-verified
- 🐛 FIXED: apply.ps1 auto-locate paths missed owner's Goldberg folder name
- 🐛 FIXED: apply.ps1 `-GetLog` error handling; install-mods.ps1 .rar gap

**2026-10-03 (sweep #1):**
- ✅ Purged Godot-era leftovers; .gitignore rebuilt; dropped `__pycache__`
- 🐛 FIXED in save_codec.py (caught by selftest): empty-table parse,
      string-value 0x1F suffix, indentation assumption

## 🚩 Risks / watch list

| Risk | Mitigation |
|---|---|
| Save edits rejected by game (semantic mismatch) | auto-backup + `--restore`; test on the copy first |
| PowerShell behaviour quirks on first real run | dry run first (`-List`), copy-only build, isolated `dist/` |
| Built copy inherits a broken extracted mod from the original install | `-NoInheritMods` switch (todo) or temporarily rename `<game>\mods` before building |
| Game update changes internals | mods are additive; re-run stub-mod dump, refresh map.md |
| Old rar blobs still in git history | acceptable until deployment → private flip / history scrub / repo delete |
| Repo public during dev | owner decision (§0.6); no game assets in tracked files |

## 👑 Owner to-do

1. Live-test ladder Steps 1–5 above (Step 4 is the only true blocker)
2. At deployment: flip private; optionally scrub history; or archive repo
