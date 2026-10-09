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
      (since consolidated into `live testing result/SUMMARY.md`) and
      parsed → `notes/game-map-draft.md` (920 globals / 41 replaceable /
      26 forbidden, 47 events, object model). **🐛 found on the way:** the
      parser rejected the good log (game wraps lines in `  . `) — fixed,
      selftest 23/23. Remaining TBDs (ammo spend/refill entry, offer roll)
      now have candidate lists in the draft; modlist.lua format awaited
      (build 4 SKML probe).
- [x] **Step 5 — 100% save on the copy**: ✅ game ACCEPTED it —
      Achievements 100%, chase unlocked; the harvested game set is 186 CARDS
      + 9 special codex keys = 195 stats entries. `ACHIEVEMENTS: OFF` title
      label explained (Steam tracking paused while modded).

## 🟠 Next features (Build 7 live validation)

- [x] **Build 5 boot crash fixed by Build 6** — Run 4 exposed fatal
      `btn("left")`; Build 6 restricted probes to confirmed engine IDs and
      added per-block checkpoints. The fake engine now raises on unknown IDs.
- [x] **Owner live-run Build 6 (Run 5)** — clean boot, full probe checkpoints,
      30 hooks / 920 globals / 186 cards, runtime bullet/hit and UI traces.
      Evidence and limitations: `live testing result/SUMMARY.md` Run 5 and
      `notes/map.md`.
- [x] **Run-5 owner feedback recorded** — Back worked; do not infer otherwise
      from the absent `SKUI|menu|widgets_added` marker. Mod toggle → Save &
      Reboot was not tested. The owner did not use/activate a soul or scepter.
- [x] **Build 7 testability update implemented** — reload and chamber controls,
      direct Majestic Censer + Wand of Souls grants, and panel-entity cleanup.
      Sandbox smoke test: 37/37 in both `all()` modes on default Lua and LuaJIT
      2.1. This is not live evidence; `uplift({chamber_max=1})` is experimental.
- [ ] **Owner live-run Build 7** — follow `INSTALL.md` Step 5: test mod ON →
      Save & Reboot → verify-after-reboot, then (if convenient) OFF → check for
      a second Save & Reboot → verify OFF after reboot. Test safe panel controls
      one at a time, including direct soul/Wand grants and close/reopen cleanup.
      Collect the log + insight pack. No Build 7 live test has happened yet.
- [ ] **Confirm chamber capacity in the actual game** — the panel uses
      `uplift({chamber_max=1})`; the API exists and temporary stat changes are
      used by reference mods, but this specific capacity change is unverified.
- [ ] **Soul/scepter live test** — use Build 7's direct card grant (no rare
      offer RNG), collect a soul from a white piece, and try normal soul and
      Wand activation. Run 5 did not test either activation.
- [ ] **Verify mod-toggle persistence and config readback** — Build 6 Run 5
      captured menu IDs and bank writes, but not the requested toggle/reboot
      interaction or a separate-launch bank readback.
- [ ] **Damage/crit implementation** — Run 5 captured `fire`, bullet, and `hit`
      traces. Review the trace to establish a safe insertion point; no damage
      or crit control is implemented in Build 7. Do not test such a control yet.
- [ ] **Extra-mouse-button binding — isolated experiment (Run-4 finding).**
      Run 5 reconfirmed only `m:lb`, `m:rb`, `m:mb` and axes; mouse4/mouse5 /
      wheel IDs remain unconfirmed. Do not blind-probe: an unknown `btn()` ID
      can be fatal. Any experiment must try one explicit candidate per boot.
- [x] **Mod-menu Back** — owner confirmed it worked in Run 5. Keep it; absence
      of `SKUI|menu|widgets_added` is not failure evidence. Legend visibility
      still needs the next-run check.
- [ ] **Right-click ability cap removal** (owner asks run 3 + 2026-10-04
      refinements — see PLANNING.md §0.7.6): vanilla caps right-click
      abilities at 1 (Better Codex documents it: "1 right-click ability,
      5 soul slots, 3 scepters") — owning one removes all others from
      offers. Goal: own multiple + pick which one each button triggers.
      **Soft-coded by design (owner): discover ALL active-ability cards at
      runtime (`special=` — Run 4 confirmed 10 vanilla cards, including Unjust
      Decree; continue supporting mod-added cards); no hardcoded list or fixed
      count.** Expected bindings: RMB + two side
      buttons + optional middle click, remap menu, cycle if abilities exceed
      buttons. **Scepter cap relaxed too.** Probe results precede behavior.
- [ ] Phase 3 — ammo rework **A** (simple scale) → playtest → **B**
      (shell economy) → **C** (shell types)  [owner decision §0.6]. A can be
      started from the mapped ammo APIs, but keep it out of the Build-7 live
      test until reload/chamber behavior is verified, so that run stays a clean
      baseline.
- [ ] **SK DEV icon polish (owner suggestion, afterthought)** — replace the
      plain `SK DEV` text launcher with a compact wand/tool icon, placed below
      the board by the `Turn 1: MODDED` status. Use a native clickable hitbox
      plus a mod-owned sprite (or a documented engine icon); check placement,
      tooltip/recognizability, and hover state in-game. Keep this separate from
      the pending Build-7 live validation; no icon change is implemented yet.
- [ ] Phase 4 — card picker (reuse Royal Card Lab pattern) + enemy picker
- [ ] **Soul-system rework — "Yu-Gi-Oh deck"** (owner, 2026-10-04 —
      PLANNING.md §0.7.8): 2–3 soul slots, ONE slot holds MANY souls,
      freely use/exchange any stored soul mid-stage — **any soul allowed,
      NO hardcoded pawn exception (owner correction: pawn-as-power comes
      from cards — pawn souls = bullets at 1 damage each — behavior stays
      card-driven)**; summon the held soul's piece as a per-floor
      temporary ally — no summon cap beyond board capacity. Vanilla
      summon-family: Right-hand, Warhorse, Onboarding Party, Rapunzel,
      Small Key; holograms: Holoking, Soul Projection. API/schema mapped
      (`add_soul`/`activate_soul`/`stack.replace_soul`/`hero.free_souls`/
      `soul_slot`/`dj_summon`); Run 5 had no soul activation. Build 7's direct
      card grant enables the next deterministic activation test.
- [ ] **Bullet damage & crit system** (owner, 2026-10-04 — PLANNING.md
      §0.7.11): configurable per-bullet damage (vanilla 1; `firepower` =
      the damage stat), configurable crit chance + crit damage (crits may
      exceed 2), **pierce auto-crits by default** (`pierce` is a % status,
      `stack.pierce`, A Piercing Truth = 30). All knobs in the cheat
      panel / balance config, persisted in the mod save — nothing
      hardcoded. Pipeline partly mapped (shot-modifier priority
      jump>fearsome>blade>pierce>knock>f_arc); Run 5 captured 12 `fire`, 48
      bullets, and 30 `hit` samples, but a safe multiplier insertion point and
      all damage routes still need review. Not implemented in Build 7.
- [ ] **Full button-remap menu** (owner decision 2026-10-04): in-game
      settings panel to assign any action to any extra mouse button
      (owner mouse: 2 side buttons + middle click; right-click exclude
      stays default). Run 5 published `m:lb`/`m:rb`/`m:mb` and axes, but no
      mouse4/mouse5/wheel IDs. Do not guess unconfirmed `btn()` names.
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

- [x] ~~**log.txt parser** (`tools/parse_log.py`)~~ — strips the game's
      `  . `/` !! ` prefix; parses runs 1–5 / Build-7-compatible probe prefixes
      (`SKCF|/SKOF|/SKS|/SKD|/SKI|/SKUI|`) into the draft, plus crashed logs
      and `SKA2|probe|<name>=done` checkpoints (`probe blocks completed` +
      a crash-location warning); selftest 37/37, including a `!! `
      warning-prefix regression and a crashed-chain case.
- [x] ~~**no-game smoke test** (`tools/mod_smoketest.py`)~~ — runs Build 7
      in a fake SUGAR env under BOTH `all()` semantics, fires hooks and native
      button callbacks, then checks parser output; 37/37 per mode on default
      Lua and LuaJIT 2.1. The fake `btn()` now models the engine's fatal
      unknown-id path (and self-checks that it does).
- [x] ~~**diagnostics build 3** of sk-rework~~ — LIVE-PROVEN twice on the real
      game (load proof, 920 globals, hooks, 47 events, object dumps)
- [x] ~~**diagnostics build 4** of sk-rework~~ — shipped session 4, **live-proven
      run 2**: MODLIST dump (`SKM|` 14 entries), card id map (`SKC|` 186 cards);
      the `SKML|` in-log probe never fired (`loadfile` absent from the mod env)
      but `-GetInsights` harvested the real `mods/modlist.lua` instead
- [x] **Build 5/6/7 script + tool support** — Build 5 crashed (Run 4), Build 6
      fixed the unknown-button path and completed Run 5, and Build 7 adds focused
      test aids. The Build-7 changes are sandbox-tested, not live-verified.
- [x] **Promoted code map** — `notes/map.md` folds in live runs 1–5 and
      vendored mod patterns, with unknown/owner-reported facts labeled, the
      `btn()` fatal contract documented, and remaining Build-7 checks called
      out. `notes/game-map-draft.md` is regenerated from the Run-5 log.
- [x] **Save codec no-argument selftest** — `python tools/save_codec.py
      --selftest` now runs two built-in parser+container roundtrips; optional
      `[savedir]` adds real `.sav` text roundtrips; current result 2/2.
- [x] **sk-rework cover art** — replaced the gray placeholder with custom
      320×180 pixel-art crown/shells "DEV PANEL + INTEL" title.
- [x] ~~`-NoInheritMods` switch for `build-dist.ps1`~~ (review F7) — shipped
      2026-10-03 session 2b: copies get exactly the 14 known-good mods
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

## ❓ Live-test answers (runs 1–5) + Build-7 checks (2026-10-04)

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
   exactly that set. The owner reports 10 `special=` ability cards (including
   Unjust Decree); **run 4 confirmed exactly 10 `special=` cards** and dumped
   every field of all 186 cards (see `notes/map.md` run-4 section).
5. ~~What is the input/button space?~~ **Mostly answered in Run 4/5, with a
   landmine attached.** Valid named actions come from `INPUT_ASSIGNEMENT`
   (validate/cancel/shoot/special/reload/unsafe) and `unsafe`/`cancel`/`ctrl`
   are callable; mouse ids are only `m:lb`, `m:rb`, `m:mb` (+`m:x`/`m:y`
   axes). **Any other `btn()` string is fatal** — that is what killed build 5.
   Still open: whether `defbtn` accepts mouse4/mouse5-style codes at all
   (needs the isolated one-candidate-per-boot experiment, see the queued item
   above).
6. **Build 7 must answer:** does `RELOAD` work, does `CHAMBER +1` change real
   capacity, do both directly granted cards appear and allow normal soul/Wand
   activation, and does panel cleanup remove stale visuals? Run 5 already
   supplied runtime damage/bullet traces and confirmed Back works. Separately
   test mod-toggle → Save & Reboot → verify-after-reboot; the owner did not
   exercise that flow in Run 5.

## 🧹 Audit sweep log (latest first)

**2026-10-04 (Run 5 follow-up — Build 7 testability update):**
- ✅ Run 5 completed Build 6's live probe chain without a crash; the parser
      reports 30 hooks, 920 globals, 186 cards, 30 sampled turns, and the
      bullet/hit traces. Full details are in `live testing result/SUMMARY.md`.
- ✅ Owner correction recorded: the Back button worked. The absent
      `SKUI|menu|widgets_added` line is not evidence to the contrary.
- ✅ Uncompleted Run-5 checks are explicit: no mod-toggle → Save & Reboot,
      no soul card used, and no soul/scepter activated.
- ✅ Build 7 adds RELOAD / experimental CHAMBER +1, direct Majestic Censer +
      Wand of Souls grants, and cleanup for panel buttons. Smoke test 37/37 in
      both iterator modes on Lua + LuaJIT; chamber uplift still needs the game.
- ⏭ Next: owner Build-7 live run via `INSTALL.md` Step 5; collect the log and
      verify menu persistence, direct soul/Wand path, chamber capacity, and UI cleanup.

**2026-10-04 (session 8 — run 4 absorbed; boot crash fixed as Build 6):**
- 🔴 **Run 4 (build 5) crashed the game at boot** — `ERR Button left for player
      0 doesn't exist.` at `script.lua:817`: the input probe called `btn()`
      with unconfirmed names, and SUGAR makes a malformed input id fatal (no
      pcall exists in the mod sandbox). Both crash logs share the exact trace;
      the intro/no-intro difference was just timing.
- ✅ **Harvest before the crash absorbed**: 186 cards fully fielded (3353
      `SKCF|` lines), EXCLUDE pairs, 14 piece definitions, 25 offer candidates,
      the 63-name live API surface (incl. the whole soul/scepter family), and
      the input dump. Promoted into `notes/map.md` + regenerated
      `notes/game-map-draft.md`.
- ✅ **Build 6 = evidence-gated input probe**: `btn*()` only with ids the live
      game published (`validate/cancel/shoot/special/reload/unsafe`, `ctrl`,
      `m:lb/m:rb/m:mb`); probe chain reordered (cards → exclude → souls → bank
      → input) with `SKA2|probe|<name>=done` checkpoints; crash-fix documented
      in the script header and info.lua.
- ✅ **Regression proof**: re-injecting the run-4 bug into `script.lua` now
      fails the smoke test with the live error message ("Button left for
      player 0 doesn't exist"), because the fake `btn()` raises like the real
      engine instead of returning `false`. Parser 37/37 (incl. crashed-chain
      warning); smoke 36/36 × both `all()` semantics × default Lua + LuaJIT.
- ✅ Owner doc note applied: mod-menu location now simply says "click Play"
      (no title-screen/main-menu contrast) in README/INSTALL/HANDOFF/map/
      mod-dev.
- ✅ Later completed by Run 5: Build 6 boots and reaches gameplay; see the
      newer Build-7 entry above for current follow-up.

**2026-10-04 (session 7 — Build 5 code + map/tooling refresh):**
- ✅ Build 5 Phase-2c panel and §0.7 `SKCF/SKOF/SKS/SKD/SKI/SKUI` probes
      implemented; parser handles all new prefixes; fake-game smoke test
      exercises hooks, native buttons, panel actions and parser output.
- ✅ Sandbox results: parser selftest 31/31; smoke test 33/33 under both
      `all()` semantics; save-codec no-argument selftest 2/2; Python compile.
- ✅ `notes/map.md` promoted with cautious source-grounded API facts and
      explicit Build-5 unknowns; `save_codec.py --selftest` no longer needs a
      directory and optionally accepts one for real saves.
- ✅ Added a 320×180 Build-5-themed cover and synced README / mod-dev / info.
- ⏳ Build 5 remains **not live-tested**: owner run needed to validate actual
      menu-button IDs, navigation, God Mode, bank persistence, and the runtime
      probe data. Damage multipliers remain gated until `SKD|` is verified.

**2026-10-04 (session 6 — consolidation + full-diff audit + PR):**
- ✅ **Live-testing evidence consolidated**: all raw material from runs 1–3
      (8 screenshots, 3 critique notes, 3 log packs incl. save folders and
      modlist copies) deleted; every finding had already been recorded in
      `notes/map.md`, `notes/game-map-draft.md`, `PLANNING.md` §0.7 and the
      changelog. `live testing result/SUMMARY.md` = the single consolidated
      log (fixed-vs-open tables + pointers)
- ✅ Docs updated for the consolidated state: HANDOFF (session 6),
      IMPROVEMENTS (sessions 5–6 arc, items 17–22), PLANNING §0.7 routing
      note (specs → this worklist, build 5 first), WORKLIST/README
      references to deleted paths fixed
- ✅ Owner's five feature asks fully specified across Q&A rounds
      (right-click cap removal, card picker, soul deck, bullet crit
      system, remap menu + Back button) — see PLANNING §0.7.6–.11;
      standing design rule: nothing hardcoded that can't be confirmed
- ✅ Full-branch audit before PR: parser selftest 23/23 + run-3/run-2 log
      parses; smoke test 29/29 both `all()` semantics; codec roundtrip on
      all real saves; unlock tool E2E; 3/3 `.ps1` tree-sitter clean;
      modlist generator byte-identical to the game's own file; diff
      reviewed file-by-file

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

1. ~~Runs 1–5~~ **Recorded in `live testing result/SUMMARY.md`; Run 5 was Build 6.**
2. Apply Build 7 / rebuild the copy and follow `INSTALL.md` Step 5.
3. Test one OFF workshop-mod toggle → **Save & Reboot** → verify the setting
   after the soft reboot; report whether the legend is visible (Back is already
   confirmed working).
4. In a run, test `RELOAD`, experimental `CHAMBER +1`, direct soul/Wand grants,
   and panel cleanup one at a time. Do not test God Mode, damage/crit, or other
   unimplemented items yet. Send `-GetInsights` output.
5. At deployment: flip private; optionally scrub history; or archive repo
