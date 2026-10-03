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
- [x] **Step 3 — launch the copy**: ✅ 14 mods listed; menu lives under Play
      (top entry); click = on/off; up/down = load priority (cosmetic
      renumbering). *(Run 1 recorded "ON by default" — run 2 disproved it:
      mods start OFF/black; the belief came from misread text colours.
      Build now pre-enables sk-rework via `mods/modlist.lua`.)*
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
      (+ owner ask from run 2: an always-visible "white = ON / black = OFF"
      legend line in the mod menu itself — needs a draw hook on the mods
      menu; the legend currently lives in sk-rework's description text).
      Build 5 should carry the intel probes for §0.7 asks: offer roll
      (right-click-slot filtering), soul system (`add_soul`/`activate_soul`/
      `TEST_SOULS`), input (`MOUSE` global, `but` fields, `btn()` args —
      remap-menu feasibility), mods-menu draw hook (legend + Back button)
- [ ] **Mod-menu Back button** (owner ask run 3, **confirmed 2026-10-04**):
      the game's mod menu only offers reset / save+reboot — no way out
      without rebooting. Add a Back button via the same UI-hook route as
      the legend (Phase 2c work)
- [ ] Phase 3 — ammo rework **A** (simple scale) → playtest → **B**
      (shell economy) → **C** (shell types)  [owner decision §0.6]
- [ ] Phase 4 — card picker (reuse Royal Card Lab pattern) + enemy picker
- [ ] **Right-click ability cap removal** (owner asks run 3 + 2026-10-04
      refinement — see PLANNING.md §0.7.6): vanilla caps right-click
      abilities at 1 (Better Codex documents it: "1 right-click ability,
      5 soul slots, 3 scepters") — owning one removes all others from
      offers. Goal: own multiple + pick which one right-click triggers
      (swap key / remap-menu binding / SPECIAL_BUTTON interception).
      Affected: the 10 `special=` cards (scope, grenade×5, strafe, orb,
      dig, decree). Blocked on the offer roll (TBD in map.md) → next
      build probes it. Scepter cap (3) could be relaxed the same way if
      wanted
- [ ] **Soul-system rework — "Yu-Gi-Oh deck"** (owner, 2026-10-04 —
      PLANNING.md §0.7.8): 2–3 soul slots, ONE slot holds MANY souls,
      freely use/exchange any stored soul mid-stage (pawn excluded —
      pawn = power/ammo); optionally summon the held soul's piece as a
      per-floor temporary ally (vanilla summon-family: Right-hand,
      Warhorse, Onboarding Party, Rapunzel, Small Key; holograms:
      Holoking, Soul Projection). API mapped (add_soul/activate_soul/
      stack.replace_soul/hero.free_souls/soul_slot fields/dj_summon
      pattern) — needs a live probe of soul activation flow + slot
      internals
- [ ] **Full button-remap menu** (owner decision 2026-10-04): in-game
      settings panel to assign any action to any extra mouse button
      (owner mouse: 2 side buttons + middle click; right-click exclude
      stays default). Gated on a probe: does SUGAR expose mouse4/mouse5
      to mods at all? (mods only use `but.left_clic`/`but.right_clic` +
      `btn("unsafe")` so far; dump `MOUSE` global + `but` fields + `btn()`
      args in the next sk-rework build)
- [ ] Phase 5 — expose vanilla `knockback`/`pierce`/bleed as player tools
- [ ] Phase 6 — balance knobs config + final packaging
      (persist knobs via the mod's own `save/mods/sk-rework.sav` slot —
      run-2-verified per-mod save system)
- [x] ~~**Pre-enable mods from the toolchain** (owner critique #2)~~ —
      shipped session 5, **verified live run 3**
- [x] ~~**Unify the 100% unlock into the build** (owner run-3 request)~~ —
      shipped session 5b: `build-dist.ps1` step 4/4 applies it
      automatically (`-NoUnlockAll` to skip)

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
- [x] ~~**diagnostics build 4** of sk-rework~~ — shipped session 4, **live-proven
      run 2**: MODLIST dump (`SKM|` 14 entries), card id map (`SKC|` 186 cards);
      the `SKML|` in-log probe never fired (`loadfile` absent from the mod env)
      but `-GetInsights` harvested the real `mods/modlist.lua` instead
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
2. ~~Are mods enabled by default? What is modlist.lua's format?~~ **Mods
   start OFF by default** (run 2 corrected run 1's wrong "ON by default" —
   black text = OFF until clicked). Format (byte-verified):
   `return {` CRLF `\t{ '<mod name>', <bool> },` … `}` — tab indent,
   trailing comma on every entry, no trailing newline. The game writes it
   at boot; `build-dist.ps1` now writes it too (pre-enable).
3. ~~Real field names for ammo/hp?~~ Partially: `hero.hp`, `hero.ammo`
   confirmed live; the displayed-stats table (nested ammo/health names) is a
   Terminal callback, not a global — cheat panel should read `hero.ammo`
   directly or dump `get_disp_stats()` (it IS a global).
4. ~~Exact special-card ids for the codex?~~ **Answered run 2 (build-4
   `SKC|` dump):** the game's CARDS table = 186 cards; stats.sav codex =
   those 186 + 9 special keys (bleed, cloak, grenade, jump, leader, line,
   mission, orb, Unfaithful Steed) = 195. `make_100pct_save.py` now writes
   exactly that set. 10 cards carry a `special=` mechanic field (strafe,
   scope, decree, grenade, orb, dig).

## 🧹 Audit sweep log (latest first)

**2026-10-03 (session 5b — run 3 absorbed; unlock unified into the build):**
- ✅ **Pre-enable verified live (run 3, owner-confirmed):** build console
      showed `3b/3 wrote mods/modlist.lua`; the copy booted with sk-rework
      ON and all 13 workshop mods OFF with zero menu visits; harvested
      modlist.lua matches the build's written order exactly
- ✅ **Unlock-all unified into `build-dist.ps1` (owner run-3 request):**
      new step 4/4 runs `make_100pct_save.py` on the copy automatically
      (python/py auto-detected; `-NoUnlockAll` skips; friendly fallback if
      no `save\` yet or no python). Run-3's saves showed why: owner never
      ran the separate tool (27 achievements / 163 cards / rank 6 = real
      progress), so "i didnt see the all unlock" — now it can't be missed
- ✅ **Legend text live:** the mod-menu legend (white=ON/black=OFF) shipped
      in sk-rework's description — visible in the run-3 log's SKM desc dump
- 🐛 FOUND + FIXED: **multi-boot logs** — the mod menu's "save and reboot"
      soft-reboots inside the same log.txt, all mod dumps appear twice, and
      the reboot can truncate in-flight `_log()` lines (boot 1's SKC dump
      cut at card 177; READY line lost — NOT a mod failure).
      `parse_log.py` now dedupes (cards by id, hooks by target+id);
      documented in map.md so a missing READY is never misread again
- ⚠️ Owner also toggled one workshop mod ON then OFF before save-and-reboot
      (their note) — final modlist state stayed sk-rework-only, as expected
- 📋 NEW asks logged (run-3 critique): exclude-rule rework + rebindable
      exclude button (Phase 4), mod-menu back button (Phase 2c, the menu
      only offers reset / save+reboot)
- ✅ Verified this session: parser selftest 23/23 + run-3 parse
      (`hooks: 5 · cards: 186` after dedup); 3/3 `.ps1` tree-sitter clean;
      run-2 regression parse unchanged

**2026-10-03 (session 5 — live test run 2 absorbed; feature work unblocked):**
- ✅ run-2 `-GetInsights` pack parsed: build 4 all-probes-good
      (`READY build=4 hooks=5 globals=920`; SKM 14 entries, SKC 186 cards);
      draft regenerated (`notes/game-map-draft.md`), parser summary now also
      prints `mods:` / `cards:` counts
- 🐛 CORRECTED (run 2 evidence): mods are **OFF by default** (black text) —
      run 1's "ON by default" was wrong; all docs fixed (INSTALL, README,
      PLAY-THIS.txt); `modlist.lua` byte-format documented in `notes/map.md`
- ✅ **Pre-enable shipped:** `build-dist.ps1` writes `mods/modlist.lua`
      (verified byte-identical to the game's own file for the same states);
      `sk-rework` ON, workshop mods OFF, new `-AllModsOn` switch
- ✅ **100% tool card set corrected:** old list missed 25 real cards
      (Anarchy, Stoning, Vendetta, …) — now writes the live-verified 195
      (186 CARDS + 9 special keys), exactly matching the game's own
      stats.sav key set
- ✅ New intel logged in `notes/map.md`: per-mod saves
      (`save/mods/<name>.sav` plaintext, no zlib wrapper + `reg.sav`
      registry; `MODSAV`/`save` globals = candidate config-persistence API),
      game-made `.sav.bak` snapshots, `loadfile` absent from mod env,
      full MODLIST entry field list
- ⚠️ CAUGHT IN ANALYSIS (fixed before shipping): a bool-vs-string comparison
      bug in an ad-hoc script briefly suggested "modded sessions wipe
      achievements" — false; post-run achievements.sav = all 128 True
      (save-side achievements survive modded play, as run 1 showed)
- ✅ owner's run-2 asks: mod-menu doc rewritten (neutral tone, correct
      black=OFF/white=ON facts); legend text added to sk-rework's
      description (visible in the mod menu); in-menu always-visible legend
      queued for Phase 2c
- ✅ Verified this session: parser selftest 23/23; smoke test 29/29 (both
      `all()` semantics); codec roundtrip byte-identical on run-2's 6 saves;
      100% tool E2E on the run-2 save copy (128 True + 195 cards); 3/3
      `.ps1` tree-sitter parse clean
- ✅ Owner's full PowerShell console log (sent for verification) confirms
      the run-2 timeline end-to-end: `-Clean -NoInheritMods` build →
      unlock-all 22:49:38 (old tool: "170/170 cards") → modded session →
      `-GetInsights` fetch → parse. It also proves achievements survive a
      modded session (tool ran BEFORE, fetch AFTER, all 128 True), and that
      run 2 used the pre-session-5 tools — expected; the updated repo's
      outputs will differ next run (195/195 cards, new `3b/3` modlist
      pre-enable line, pre-enabled sk-rework, `mods:`/`cards:` in the
      parser summary)

**2026-10-03 (session 4 — live test #1 absorbed; see changelog for detail):**
- ✅ live ladder steps 1–5 all ran (twice); run-1 log parsed into
      `notes/game-map-draft.md`; `notes/map.md` gained a Live-verified section
- 🐛 FIXED `parse_log.py` false "mod did not run" (game `  . ` line prefix)
- ✅ `sk-rework` build 4 shipped (SKM/SKC/SKML harvest; dead probes removed);
      smoke test 29/29 both `all()` semantics
- ✅ `make_100pct_save.py` codex 96%→100% (6 special cards) + achievements-off
      explanation; `apply.ps1 -GetInsights`; `build-dist.ps1` PLAY-THIS.txt,
      `INSTALL.md`, `README.md` corrected from the owner's critique
- ⏳ ~~NEW (owner, ~5 min): run build 4 once + `-GetInsights`, upload the pack~~
      → **done in run 2** (see session-5 entry above): modlist.lua format +
      full card set delivered; build-dist pre-enable shipped (critique #2
      fully closed)

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

1. ~~Build-4 run + `-GetInsights` upload~~ **DONE (runs 2 & 3)** — all
      harvest + verification goals met. Nothing left to collect.
2. Next launch of a rebuilt copy (with the updated repo): build console
      should show `4/4 applying the 100% unlock...` and the copy should
      boot with **everything unlocked from the start** (128 achievements,
      all shotguns, codex 100%) plus sk-rework already ON. That single
      check closes run 3 completely.
3. At deployment: flip private; optionally scrub history; or archive repo
