# WORKLIST — pending tasks, audit results & live-test tracker

> Living document. Check things off in commits. Companion: `HANDOFF.md`
> (state), `IMPROVEMENTS.md` (what got better), `notes/changelog.md` (what
> changed file-by-file).

## 🔴 Critical path (blocks all features)

- [ ] **LIVE TEST A — stub mod run** (owner, ~5 min): `pwsh tools/apply.ps1
      -GameDir "<game>"` → launch → enable SK Rework → quit → upload game's
      `log.txt` to repo. **Result: ⏳ not run yet.**
  - [ ] Parse `SKG|/SKR|/SKF|` lines → complete `notes/map.md`
        (ammo spend/refill, damage entry point, spawn decision, offer roll)
- [ ] **LIVE TEST B — mods auto-enable?** Does a fresh mods/ folder appear
      ON in the mod menu, or need one toggle? (No enable-flag exists in any
      save → expected: auto-on. **Result: ⏳ unknown.**)
- [ ] **LIVE TEST C — 100% save** `python tools/make_100pct_save.py
      --game-dir "<game>"` → verify in-game: all shotguns, chase mode,
      codex, achievements. **Result: ⏳ not run.** (Codec is byte-lossless;
      semantic acceptance by the game unproven until played.)
- [ ] **LIVE TEST D — dist build** `pwsh tools/build-dist.ps1 …` → play the
      built copy, confirm all 13 mods + sk-rework listed & loadable.
      **Result: ⏳ not run.**

## 🟠 Next features (after live tests)

- [ ] Phase 2c — in-game **dev-cheat panel** (native `mk_menu_but` UI):
      give ammo/cards, god mode, spawn pieces, damage multipliers
- [ ] Phase 3 — ammo rework **A** (simple scale) → playtest → **B**
      (shell economy) → **C** (shell types)  [owner decision §0.6]
- [ ] Phase 4 — card picker (reuse Royal Card Lab pattern) + enemy picker
- [ ] Phase 5 — expose vanilla `knockback`/`pierce`/bleed as player tools
- [ ] Phase 6 — balance knobs config + final packaging

## 🟡 Known gaps / improvements wanted

- [ ] Real cover art for sk-rework (currently placeholder 320×180 gray)
- [ ] `install-mods.ps1`: no .rar support (prints manual-extract hint now);
      rar mods are already vendored in dist-overlay so low priority
- [ ] King's Court (2022 legacy mod) port to modern format — optional
- [ ] Friendly save-editor UI (beyond codec + 100% script) — optional
- [ ] Mine reference repos: modderongithub/shotgun-king-mods,
      Shotgun-King-Puzzle-Developers/Shotgun-King-Puzzle-Mod
- [ ] sk-rework `priority_hint` tuning once multiple features stack up

## 🧹 Audit sweep log (latest first)

**2026-10-03 (session-end sweep #2):**
- ✅ git tree clean, no uncommitted work; tracked inventory matches intent
- ✅ python tools: `py_compile` OK; save codec selftest 6/6 byte-identical
- ✅ 13 vendored mods: every folder == `name=` in its info.lua
- ✅ sk-rework: folder == `name=`, script.lua title lookup matches info.lua
- 🐛 FIXED: apply.ps1 auto-locate paths missed owner's Goldberg folder name
      (`Shotgun.King.The.Final.Checkmate.v1.623b`) — added
- 🐛 FIXED: apply.ps1 `-GetLog` error handling could continue after errors
      ($ErrorActionPreference moved to top)
- 🐛 FIXED: install-mods.ps1 silently ignored .rar mods — now prints
      manual-extract instructions
- ⚠️ KNOWN: PowerShell scripts untestable in sandbox (no pwsh) — first run
      on owner machine may surface syntax quirks; report back

**2026-10-03 (sweep #1):**
- ✅ Purged Godot-era leftovers (tools/repack.md, game-dump/, stale
      modded/README.md); .gitignore rebuilt; dropped committed __pycache__
- 🐛 FIXED in save_codec.py (caught by selftest): empty-table parse,
      string-value 0x1F suffix, indentation assumption (game writes flush-left)

## 🚩 Risks / watch list

| Risk | Mitigation |
|---|---|
| Save edits rejected by game (semantic mismatch) | auto-backup + `--restore`; test on disposable run first |
| Game update changes internals | mods are additive; re-run stub-mod dump, refresh map.md |
| Old rar blobs still in git history | acceptable until deployment → private flip / history scrub / repo delete |
| Repo public during dev | owner decision (§0.6); no game assets in tracked files anymore |
| Multiple mods hooking same function | community `append` is id-registered & cumulative (v1.62 changelog says fixed for multi-mod use) |

## 👑 Owner to-do

1. Live tests A–D above (A is the only true blocker)
2. Merge PR #1 (cleans main of the 14 archives) — if not merged yet
3. At deployment: flip private; optionally scrub history; or archive repo
