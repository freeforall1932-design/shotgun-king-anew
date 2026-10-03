# WORKLIST — pending tasks, audit results & live-test tracker

> Living document. Check things off in commits. Companion: `HANDOFF.md`
> (state), `notes/review-2026-10-03.md` (readiness review),
> `notes/changelog.md` (what changed file-by-file).

## 🔴 Critical path (blocks all features)

**Live-test ladder** — risk-ordered, each step reversible.
**Canonical instructions: `INSTALL.md`** (owner layout `E:\testing\{game, repo,
ShotgunKing-Modded}`) · rationale: `notes/review-2026-10-03.md` §5.

- [ ] **Step 1 — dry run** (owner, 1 min): `pwsh tools/apply.ps1 -GameDir
      "<game>" -List`. Writes nothing; prints exactly what would be copied.
- [ ] **Step 2 — build the copy**: `pwsh tools/build-dist.ps1 -GameDir
      "<game>" -Clean` → confirm `dist\ShotgunKing-Modded\mods\` has 14
      folders and your install is unchanged. **Result: ⏳ not run.**
- [ ] **Step 3 — launch the copy** → mod menu shows/toggles the 14 mods
      (this also answers: do mods auto-enable?). **Result: ⏳ not run.**
- [ ] **Step 4 — harvest the log** (**the true blocker**):
      `pwsh tools/apply.ps1 -GameDir "dist\ShotgunKing-Modded" -GetLog` →
      send `uploads/game-insights/log.txt` (attach in chat / upload to repo).
      Then: parse `SKG|/SKR|/SKF|` lines → complete `notes/map.md`
      (ammo spend/refill, damage entry point, spawn decision, offer roll).
- [ ] **Step 5 — 100% save on the copy**: launch the copy once (creates
      `save\`) → `python tools/make_100pct_save.py --game-dir
      "dist\ShotgunKing-Modded"` → verify in-game: all shotguns, chase mode,
      codex, achievements. **Result: ⏳ not run.** (Codec byte-lossless;
      game acceptance unproven until played.)

## 🟠 Next features (after log.txt)

- [ ] Phase 2c — in-game **dev-cheat panel** (native `mk_menu_but` UI):
      give ammo/cards, god mode, spawn pieces, damage multipliers
- [ ] Phase 3 — ammo rework **A** (simple scale) → playtest → **B**
      (shell economy) → **C** (shell types)  [owner decision §0.6]
- [ ] Phase 4 — card picker (reuse Royal Card Lab pattern) + enemy picker
- [ ] Phase 5 — expose vanilla `knockback`/`pierce`/bleed as player tools
- [ ] Phase 6 — balance knobs config + final packaging

## 🟢 Ready now, not blocked (agent can do without the game)

- [ ] **log.txt parser** (Python): ingest `SKG|/SKR|/SKF|` lines + `SK-REWORK`
      markers, emit a draft function map for `notes/map.md`. Fully testable in
      sandbox with synthetic log input. ← proposed next task
- [x] ~~`-NoInheritMods` switch for `build-dist.ps1`~~ (review F7) — shipped
      2026-10-03 session 2b: copies get exactly the 14 known-good mods
- [ ] Real cover art for sk-rework (currently placeholder 320×180 gray)
- [ ] `install-mods.ps1`: no .rar support (prints manual-extract hint now);
      rar mods are already vendored so low priority
- [ ] King's Court (2022 legacy mod) port to modern format — optional
- [ ] Friendly save-editor UI (beyond codec + 100% script) — optional
- [ ] Mine reference repos: modderongithub/shotgun-king-mods,
      Shotgun-King-Puzzle-Developers/Shotgun-King-Puzzle-Mod
- [ ] sk-rework `priority_hint` tuning once features stack up

## 🧹 Audit sweep log (latest first)

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
