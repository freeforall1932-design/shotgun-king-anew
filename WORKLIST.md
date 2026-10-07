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

## 🔴 Verified audit follow-ups (2026-10-07; current `main` @ `a0b09e4`)

Source of verdicts and reviewed patch proposals: `audit/VERIFICATION_RESULTS.md`.
The audit fixes below were applied selectively after owner approval. The owner
has now also approved removing `game/` from the current tree; history rewriting
is not included. Rejected audit proposals remain unapplied.

### Protect data and build outputs

- [x] **A-02 — guard `GameDir`/output overlap before `-Clean`.**
      `build-dist.ps1` normalizes both paths and rejects equality or nesting in
      either direction before deleting/creating the destination. The check is
      lexical (`GetFullPath`), not junction/reparse-point aware.
  - [ ] Run disposable Windows cases for equal, ancestor, descendant, and
        sibling-prefix paths before relying on the guard for a real build.
- [x] **A-03 / SEC-01 — interpret Robocopy status explicitly.** The script
      captures `$LASTEXITCODE` immediately, temporarily disables
      `PSNativeCommandUseErrorActionPreference` when available, accepts 0–7,
      and aborts on 8+.
  - [ ] Run Robocopy success/failure statuses with the native-command
        preference both enabled and disabled on Windows.
- [x] **A-05 — honor `--dry-run` during `--restore`.** Restore now prints a
      preview and returns before deleting/copying. Temporary fixture test
      verifies byte-identical current and backup save trees.
- [x] **A-06 — validate and refresh `-GetInsights` as one snapshot.** Requires
      an existing game folder and `log.txt`; optional modlist/save files are
      staged in a fresh sibling directory, then swapped in after collection.
      Swap failure attempts to restore the prior snapshot (and retains it at
      the unique backup path if rollback itself fails); removed source files
      cannot linger in the new pack.
  - [ ] Run Windows tests for missing paths/log, stale-file removal, copy
        failure before swap, and rollback after swap failure.

### Make checks, saves, and instructions trustworthy

- [x] **A-04 — report a missing Lupa smoke test as skipped, not passed.** The
      script runs the independent parser selftest, reports `SKIPPED`, and exits
      2. `tools/mod-dev.md` documents status 2 as skip, not pass. Regression
      tests exercise both `lupa` present and absent.
- [x] **SEC-03 — harden King dodge relocation.** Uses only the verified
      `goto_sq(hero, square)` contract and confirms the resulting square and
      `.p` occupant. Removed both the bad-argument guess and direct square
      coordinate fallback. The smoke fake models pointer/occupancy changes and
      confirms SAFE-blocked dodges leave all tile coordinates/occupants intact.
- [x] **SEC-06 — validate `--pack` input before writing.** `parse()` now rejects
      missing root tables, entries outside the root, and unmatched braces;
      `--pack` validates before opening its output. Parser selftests and a
      sentinel-output regression test pass.
- [x] **SEC-07 — handle unsupported `endless` schemas explicitly.** The tool
      supports the verified numeric scalar (and the existing missing-key
      default), but rejects table/invalid shapes before creating a backup or
      changing any save. Temporary fixtures test both the rejected shape and
      supported scalar dry-run.
- [x] **A-07 — refresh generated `PLAY-THIS.txt` copy** to describe Build 9's
      game-state controls and state that sandbox testing is complete while
      live-game validation remains pending.

### A-01 — current-tree cleanup approved; history decision separate

- [x] Owner explicitly approved removing `game/` from the current branch tree
      (2026-10-07); the game payload is removed and `/game/` is ignored. The
      owner says another copy remains available outside this branch.
- [x] Keep the tooling runnable without the payload: `mode_guns_check.py` uses a
      checked-in Throne gun-list snapshot (verified against the removed file's
      `HEAD` revision; re-parses `game/decoded/` automatically when present) and
      still passes **37/37**; `save_codec.py --selftest` passes 6/6 with no save
      directory.
- [ ] Merge [PR #11](https://github.com/freeforall1932-design/shotgun-king-anew/pull/11) so `main`'s current tree no longer contains `game/`.
- [ ] Decide separately whether Git history should be rewritten. This change
      preserves prior commits, so the game blobs remain reachable and a normal
      clone may retain the old repository-size cost. Do not force-update history
      without a separate explicit approval and coordination.

**Triage:** SEC-02 is rejected (the engine sets `mod.loaded`); SEC-04 is not
substantiated (no source-level ZIP self-move/lock found); SEC-05 is already
handled by `card_page = 1` in the current source. SEC-08 is a documented queued
feature already listed below, so it is not duplicated here. Do not apply the
unified audit bundle or its rejected hunks.

## 🟠 Next features (Build 9 live validation first)

- [x] **Build 5 implementation** — Phase 2c native-button panel + §0.7 probes
      are in `modded/sk-rework/script.lua`; `parse_log.py` and the fake-game
      harness were updated. Panel controls currently cover +ammo,
      random eligible card, a dynamically selected ally summon, and a
      best-effort God Mode toggle. Damage-multiplier action is explicitly
      gated until the live hit path is confirmed. Mod-menu Back/legend attach
      when a native menu-button ID matches a live MODLIST entry.
- [x] ~~**Owner live-run Build 5**~~ — **RAN 2026-10-04 (run 4) and CRASHED
      AT BOOT**: the input probe called `btn("left")`; unknown SUGAR input
      names fall through to the id parser and a malformed id is FATAL (game
      quits, no pcall available). Root cause + evidence: `live testing
      result/SUMMARY.md` run 4, `notes/map.md` input section.
- [x] **Build 6 crash fix** — `btn*()` is now only called with ids the live
      game published (`INPUT_ASSIGNEMENT` actions + bound mouse codes), the
      probe chain is reordered (safe blocks first: cards → exclude → souls →
      bank → input) with `SKA2|probe|<name>=done` checkpoints, and the fake
      engine in `mod_smoketest.py` now **raises** on unconfirmed ids exactly
      like the game (the old fake returned `false`, which is why 33/33 passed
      while the game died). Verified by re-injecting the run-4 bug: the
      harness fails with the live error. Parser 37/37 (crash detection included), smoke 36/36.
- [x] ~~**Owner live-run Build 6**~~ — **RAN 2026-10-04 (run 5, ~22 min in
      play, clean shutdown)**: `READY build=6 hooks=30 globals=920`, all five
      probe blocks completed, panel + every cheat fired, bank written, souls/
      scepters/offers/damage traced. Findings absorbed into `notes/map.md`,
      `SUMMARY.md`, `PLANNING.md` §0.7b. The run also produced 8 new owner
      asks (panel close/state, spawn placement + ally bugs, reload/cartridge,
      cardless card, damage, dodge, spawn lag).
- [x] **Build 7 — run-5 fixes + features (this session)** — panel v2 with the
      engine's own `remove_buts()` and a page rebuild after every action;
      damage/crit/pierce system applied at `mk_bullet`; RELOAD + CLIP+;
      card AUTO/LIST pages with the cardless fallback and summon-on-card;
      spawn piece picker with diagonal-first squares; Mist-style dodge;
      engine-call intent logging (`SKE|call|…=start/=ok`) + SAFE mode; bank
      read-back/config restore; menu legend/Back armed on the real run-5 ids.
      Sandbox: smoke **47/47** ×4 variants (incl. the panel's offer-screen guard,
      which stops a stray click from wiping the engine's own level-up buttons),
      parser **44/44**, codec 2/2.
- [x] ~~**Owner live-run Build 7**~~ — **RAN 2026-10-05 (run 6)**: bank
      read-back ✅ and menu widgets ✅, but clicking SK DEV → CLIP+ moved the
      king and the panel never came back; 4 crash logs (`fairy_cards`
      surface) and red load-order warnings with all mods ON. Analysis:
      `live testing result/SUMMARY.md` Run 6.
- [x] **Game files stored + decoded (session 10)** — the prior-session import
      decoded `data.sgr` (`tools/sgr_extract.py` → `game/decoded/`); its engine
      facts are in `notes/game-internals.md`. The owner later approved removing
      this copy from the current tree (2026-10-07); another copy is reported to
      remain outside this branch, and earlier Git commits still retain the files.
- [x] **Build 8 item 1 — panel rebuilt as an overlay** — one plain draw
      entity (dp 15, no `button` flag) and an `append("gamepad_ctrl")` hook
      that hit-tests and consumes clicks (`mcl/mcr/mlb=false`) before any
      board button updates. Never calls `remove_buts()`; re-created when
      `reset()` replaces `ents`; hidden while leveling/pause/menu; smaller
      pico-font buttons; modal box over the board; bottom-left `SK DEV` tab;
      live labels. `destroy_group` now uses `kl()`.
- [x] **Build 8 item 2 — 7 workshop mods patched** to the sandbox's
      `newsrf(name, "file")` order (Quartz/Shootout re-registered under unique
      names instead of overriding the base `gfx`/`cards`/`title`/`tutorial`).
      List: `dist-overlay/README.md`.
- [x] **Build 8 item 3 — dependency load order** in `build-dist.ps1`:
      Collection → … → art of war → disgraced_justice → retry/card lab/grenade
      predictor → … → **Glac Terminal last**.
- [x] **Smoke test now runs the mod inside the engine's real sandbox rules**
      (writes reach the engine only for replaceable keys) and drives the
      panel through a fake `gamepad_ctrl`; **59/59** ×4. Mutation-checked:
      removing the click consume, the new-run rebuild, or adding a
      non-replaceable write each fails exactly its check.
- [x] **Build 8 item 4 → Build 9** — Quartz Throne / Fairy Endless /
      Nightmare / Card Lab carry the 9 base Throne guns; Quartz + Fairy
      unlock all guns in-game and save their bank. **Quartz never called
      `savbnk()`, so its unlocks were lost on every boot; that's fixed.**
      The 100% tool deliberately does NOT write mod banks (mods can't read
      the base unlocks, and an offline write would have been lost on the
      next Quartz boot). `tools/mode_guns_check.py` 29/29.
- [x] **Build 8 item 5 → Build 9** — mod menu: live ON/OFF row text, Back
      restored after undoing changes, far-left centred legend (no hover),
      E1–E4 load-order codes + AUTO-FIX; red text = error codes
      (`notes/red-warnings.md`, `parse_log.py` §1b). Smoke 64/64 ×4 with a
      verbatim port of the engine's mod-menu code; mutation-checked.
- [x] **Build 8 item 6 → Build 9** — INSTALL Step 5 rewritten as the test
      list only (A1–A6 mod menu, B1–B4 modes, C1–C8 panel).
- [ ] **Owner live-run Build 9** — INSTALL Step 4 (rebuild), then the Step 5
      test list.
- [ ] **Remaining API guesses, independent of SEC-03 dodge fix** —
      `get_nearest_free_square(px,py)` (only called when it exists, result
      validated) and `stack.chamber_max` / `stack.ammo_max` field writes.
      Validate those against the decoded/live contract before treating them as
      stable; `SAFE:on` still limits gameplay-mutating calls during a probe.
- [x] ~~**Finish Phase 2c after probes**~~ — run 5 proved the route
      (`mk_bullet` → `bullet.dmg` → `hit` → `fx_dmg`; `ev_hit` never fires), so
      Build 7 ships configurable damage + crit + pierce auto-crit, and the
      legend/Back now arm on the real menu ids (the Build-6 predicate could
      never match). Live validation of both is the Build-7 run.
- [ ] **Extra-mouse-button binding — isolated experiment (run-4 finding).**
      The only mouse ids the engine publishes are `m:lb`, `m:rb`, `m:mb`
      (+ `m:x`/`m:y` axes); mouse4/mouse5/wheel appear nowhere, and a wrong
      `defbtn`/`btn` id may be fatal. Do NOT blind-probe. Design: a separate
      opt-in build that tries ONE candidate binding per boot (config-bank
      switched), documented as crash-tolerant, so a failure costs one run
      instead of a whole feature cycle.
- [x] **Mod-menu Back + white/black legend** (owner ask run 3) — Build 6
      attached nothing because it compared MODLIST titles to button ids; run 5
      harvested the real ids (`mods`/`save_back`/`" ON "`/`"OFF "`/arrows) and
      Build 7 arms on those.
- [ ] **Right-click ability cap removal** (owner asks run 3 + 2026-10-04
      refinements — see PLANNING.md §0.7.6): vanilla caps right-click
      abilities at 1 (Better Codex documents it: "1 right-click ability,
      5 soul slots, 3 scepters") — owning one removes all others from
      offers. Goal: own multiple + pick which one each button triggers.
      **Soft-coded by design (owner): discover ALL active-ability cards at
      runtime (`special=` — owner reports 10 in v1.623b, including Unjust
      Decree; SKCF probe will verify; also scepters and mod-added cards); no
      hardcoded list, no fixed count.** Expected bindings: RMB + two side
      buttons + optional middle click, remap menu, cycle if abilities exceed
      buttons. **Scepter cap relaxed too.** Probe results precede behavior.
      SEC-08 was verified absent in the 2026-10-07 audit; it remains a planned
      feature, not a fix to apply from the unverified `prepend` proposal.
- [ ] Phase 3 — ammo rework **A** (simple scale) → playtest → **B**
      (shell economy) → **C** (shell types)  [owner decision §0.6]
- [ ] Phase 4 — card picker (reuse Royal Card Lab pattern) + enemy picker
- [ ] **Soul-system rework — "Yu-Gi-Oh deck"** (owner, 2026-10-04 —
      PLANNING.md §0.7.8): 2–3 soul slots, ONE slot holds MANY souls,
      freely use/exchange any stored soul mid-stage — **any soul allowed,
      NO hardcoded pawn exception (owner correction: pawn-as-power comes
      from cards — pawn souls = bullets at 1 damage each — behavior stays
      card-driven)**; summon the held soul's piece as a per-floor
      temporary ally — no summon cap beyond board capacity. Vanilla
      summon-family: Right-hand, Warhorse, Onboarding Party, Rapunzel,
      Small Key; holograms: Holoking, Soul Projection. API mapped
      (add_soul/activate_soul/stack.replace_soul/hero.free_souls/
      soul_slot fields/dj_summon pattern) — needs a live probe of soul
      activation flow + slot internals
- [~] 🟡 **Implemented since Build 7, not yet live-tested** (pre-PR audit:
      run 6 logged `SKUI|cfg|on=0`, so it was never switched on; INSTALL
      Step 5 test C6 covers it). **Bullet damage & crit
      system** (owner, 2026-10-04 — PLANNING.md §0.7.11): configurable per-bullet damage (vanilla 1; `firepower` =
      the damage stat), configurable crit chance + crit damage (crits may
      exceed 2), **pierce auto-crits by default** (`pierce` is a % status,
      `stack.pierce`, A Piercing Truth = 30). All knobs in the cheat
      panel / balance config, persisted in the mod save — nothing
      hardcoded. Pipeline partly mapped (shot-modifier priority
      jump>fearsome>blade>pierce>knock>f_arc); build-5 probe pins the
      damage application point (`ev_hit`/`damage`/`damages`/`fx_dmg`)
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

- [x] ~~**log.txt parser** (`tools/parse_log.py`)~~ — strips the game's
      `  . `/` !! ` prefix; parses legacy build-4 and Build-6 prefixes
      (`SKCF|/SKOF|/SKS|/SKD|/SKI|/SKUI|`) into the draft, plus crashed logs
      and `SKA2|probe|<name>=done` checkpoints (`probe blocks completed` +
      a crash-location warning); selftest 37/37, including a `!! `
      warning-prefix regression and a crashed-chain case.
- [x] ~~**no-game smoke test** (`tools/mod_smoketest.py`)~~ — runs Build 7
      in a fake SUGAR env under BOTH `all()` semantics, fires hooks and native
      button callbacks, then checks parser output; **47/47** per mode on default
      Lua and LuaJIT 2.1. The fake engine chains multiple appends per target
      like the real one, models `remove_buts`/`goto_sq`/`flr`/`mk_bullet`, and
      its `btn()` reproduces the fatal unknown-id path (with a self-check).
- [x] ~~**diagnostics build 3** of sk-rework~~ — LIVE-PROVEN twice on the real
      game (load proof, 920 globals, hooks, 47 events, object dumps)
- [x] ~~**diagnostics build 4** of sk-rework~~ — shipped session 4, **live-proven
      run 2**: MODLIST dump (`SKM|` 14 entries), card id map (`SKC|` 186 cards);
      the `SKML|` in-log probe never fired (`loadfile` absent from the mod env)
      but `-GetInsights` harvested the real `mods/modlist.lua` instead
- [x] **Build 5/6 script + tool support** — native-button dev controls, menu
      helper hook, post-READY `SKCF/SKOF/SKS/SKD/SKI/SKUI` probes; build 5
      ran live and crashed (run 4), build 6 is the evidence-gated fix.
- [x] **Promoted code map** — `notes/map.md` now folds in live runs 1–4 and
      vendored mod patterns, with unknown/owner-reported facts labeled, the
      `btn()` fatal contract documented, and the remaining runtime gaps called
      out.
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

## ❓ Live-test answers (runs 1–4) + Build-6 questions (2026-10-04)

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
5. ~~What is the input/button space?~~ **Mostly answered run 4, with a
   landmine attached.** Valid named actions come from `INPUT_ASSIGNEMENT`
   (validate/cancel/shoot/special/reload/unsafe) and `unsafe`/`cancel`/`ctrl`
   are callable; mouse ids are only `m:lb`, `m:rb`, `m:mb` (+`m:x`/`m:y`
   axes). **Any other `btn()` string is fatal** — that is what killed build 5.
   Still open: whether `defbtn` accepts mouse4/mouse5-style codes at all
   (needs the isolated one-candidate-per-boot experiment, see the queued item
   above).
6. ~~**Build 6 must answer (needs gameplay, not just boot)**~~ — **ANSWERED
   by run 5 (2026-10-04, ~22 min in play):** the panel renders and every action
   fires; the real menu ids are `play/mods/save_back/" ON "/"OFF "` (the build-6
   title compare could never match); the bank write path is proven and its file
   format decoded (`128:64:4:` + hex, `(0,0)=505`, `(1,0)=1`); the damage route
   is `mk_bullet` → `bullet.dmg` → `hit(p,dmg,tags)` → `fx_dmg(p,dmg)`, with
   `ev_hit` never firing. Build 7 ships the fixes + features; **Build 7 must
   answer** (next run): the bank read-back across a boot
   (`SKUI|bank|ready=true|magic=505`), real CLOSE (`SKUI|panel|clear=remove_buts`),
   damage rolls on shots (`SKD|dmg|`), reload/clip effects, the spawn picker's
   `route=`, a dodge that moved the king (`SKUI|dodge|…|moved=true`), and the
   legend attaching (`SKUI|menu|widgets_added=true`).

## 🧹 Audit sweep log (latest first)

**2026-10-07 (owner-approved current-tree game removal):**
- ✅ Owner superseded the earlier retain-`game/` instruction. Removed the 368
  tracked files (about 115 MB) from the current worktree and added `/game/` to
  `.gitignore`; updated README/HANDOFF/A-01 wording.
- ℹ️ This removes the payload from the branch tip, not from earlier Git commits.
  `main` will remain unchanged until the cleanup PR is merged; history/clone-size
  cleanup would require a separate, coordinated history rewrite.
- ⏭ Prepare/push the change only on the session-fixed Arena branch and open a PR
  from that branch; do not switch or force-update `main`.

**2026-10-07 (external audit verification + selective fixes; current main @ `a0b09e4`):**
- ✅ Read both audit pages and checked all distinct findings against the
  current source. Verdicts, patch review, applied changes, and limits are in
  `audit/VERIFICATION_RESULTS.md`.
- ✅ Reviewed the patch guides before editing; rejected the bundle wholesale.
  SEC-02 is false, SEC-05 is already handled, SEC-03's `.piece` field is wrong
  (`.p` is the engine field), SEC-04's `-LiteralPath` wildcard will not expand,
  and SEC-08's `prepend` return is ignored. The proposed `endless` nested
  schema is unverified; the implementation fails closed instead.
- ✅ Applied A-02/A-03/A-04/A-05/A-06/A-07 and SEC-03/SEC-06/SEC-07 fixes;
  no game payload, save, or Git history was removed/rewritten. Added temporary
  fixture regressions and updated the Build 9 play instructions.
- ✅ Smoke **68/68 ×4** (default/LuaJIT 2.1, value/pair `all()` semantics),
  regression suite **7/7**, parser **49/49**, codec/game-save selftest **12/12**.
  Forced missing-Lupa branch returns the documented skip status 2.
- ⏭ PowerShell/Robocopy and live-game validation remain pending because those
  runtimes are unavailable here. A-01 was initially left open; the owner
  subsequently approved current-tree removal (see the newer entry above).

**2026-10-06 (session 10 — run 6 absorbed; game decoded; Build 8 items 1–3):**
- ✅ Run 6 analysed (panel click-through, `remove_buts` turn break, stale
  flag after `reset()`; reversed `newsrf` args in 7 mods; alphabetical
  `modlist.lua`).
- ✅ `game/` stored from the owner's split zips (315 files, CRCs OK), zips
  removed; `data.sgr` format solved → `tools/sgr_extract.py`,
  `game/decoded/` (54 files).
- ✅ Build 8 items 1–3 shipped and sandbox-verified (smoke 59/59 ×4, parser
  44/44, codec 2/2, all 37 mod Lua files compile under LuaJIT 2.1).
- ✅ Items 4–6 approved and shipped as **Build 9**: Throne-like gun lists +
  Quartz bank save, mod-menu rework (live text, Back, legend, E1–E4,
  AUTO-FIX), red-text error codes, a new Step 5 test list. Smoke 64/64 ×4,
  `mode_guns_check` 29/29, parser 49/49, codec 2/2.
- ✅ **Pre-PR audit of Build 9** (session 10): Extra Features + Quartz added
  to the Terminal rule (E1), Quartz all-ranks unlock (`SK_ALL_RANKS`),
  Collection's dormant `hook.lua` gun list patched + a sweep check, INSTALL
  A4/A5/B corrected, damage/crit status corrected to "implemented, untested
  live". Smoke 66/66 ×4, `mode_guns_check` 37/37. Details: HANDOFF §5 item 7.
- ⏭ Next: owner live-run Build 9 (INSTALL Step 4, then Step 5).

**2026-10-05 (session 9 — run 5 absorbed; Build 7 shipped):**
- ✅ **Run 5 (build 6) parsed and absorbed**: 22 min in play, clean shutdown,
  1 boot, all probe blocks done; every "Build 6 must answer" question resolved
  (panel renders + actions fire, menu ids harvested, bank write proven,
  damage route traced, souls/scepters/offers live).
- 🔴 **Three run-5 bugs root-caused**: (1) the panel never really closed —
  the engine ignores `del(ents, e)` on `mk_text_but` groups, so state and
  visuals diverged; (2) the mod-menu legend could never attach — the predicate
  compared MODLIST titles to ids; (3) spawn-ally only ever made a pawn and
  could block the king's step.
- ✅ **Build 7 shipped** (`modded/sk-rework/`, BUILD=7 + info.lua): panel v2
  (real `remove_buts()` CLOSE, page rebuild per action, live labels, card
  pages, spawn picker, damage knobs, SAFE toggle), damage/crit system at
  `mk_bullet`, RELOAD + CLIP+, cardless fallback + summon-on-card, Mist-style
  dodge, engine-call intent logging for crash forensics, bank restore/rewrite.
- ✅ **Bank format decoded** from the run-5 save pack: `128:64:4:` + hex,
  one ASCII hex pair per byte, LE i32 per cell → `(0,0)=505`, `(1,0)=1`.
- ✅ **Tooling**: smoke test now chains multiple appends per target like the
  real engine (the old single-slot dict silently dropped the damage hook) and
  models `remove_buts`/`goto_sq`/`flr`/`mk_bullet`; parser gained
  `SKE|call|` crash forensics (a dangling `=start` names the failing control)
  and a Build-7 section. **47/47 smoke ×4 variants; 44/44 parser selftest;
  codec 2/2.**
- 🧹 **Evidence consolidated**: `uploads/` (run-4 pack) and the run-5
  `notes/` snapshot deleted after absorption; `notes/game-map-draft.md`
  regenerated from the run-5 log with the new parser sections.
- ⏭ Next: owner live-run Build 7 (control-by-control), then the cap
  removal + picker/soul-deck work on top of the validated panel.

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
- ⏭ Next: ~~owner live-run Build 6 in play~~ **done — run 5 (22 min,
      clean, all blocks answered)**; the follow-up is the Build-7 run.

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
| Older public Git commits still contain the former `game/` payload and saves | Current-tree removal is approved; merge the cleanup PR. History scrub is separate; no legal conclusion or force-update without explicit approval |

## 👑 Owner to-do

1. ~~Harvest + verification runs 1–3~~ **DONE and consolidated into
      `live testing result/SUMMARY.md`.**
2. ~~Apply Build 5 / playtest~~ **done (run 4/5)**; Build 6 is retired.
3. ~~Apply Build 7~~ **done (run 6)**.
3b. **Apply Build 9 and playtest it**: rebuild with `build-dist.ps1`
      (INSTALL Step 4), then the INSTALL Step 5 tests:
      - A1–A6 mod menu: legend at the far left, live ON/OFF, Back after
        on→off, AUTO-FIX, no red text with all mods ON;
      - B1–B4: 9 guns in Quartz/Fairy/Nightmare/Card Lab, with Quartz and
        Fairy unlocks surviving a relaunch;
      - C1–C8: the panel.

      Then run `apply.ps1 -GetInsights`.
4. **A-01 current-tree removal is owner-approved** and is being prepared on
      this fixed Arena branch. After merge, `main`'s current tree will omit
      `game/`; earlier commits still retain it unless a separate history scrub
      is explicitly approved. At deployment, flip private, optionally scrub
      history, or archive the repo.
