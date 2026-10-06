## 2026-10-06 — session 10 (cont.): Build 9 = owner's Build 8 items 4–6

- **Item 4, Throne-like gun lists** (`dist-overlay/mods/`): Quartz Throne,
  Fairy Endless, Nightmare and Card Lab now carry the base 9-gun Throne list
  (absolute `firerange`).
  - **Quartz:** never called `savbnk()`, so its unlocks were RAM-only and
    lost at every boot. It now flushes after every `save()`, unlocks all
    guns on `initialize` (`SK_ALL_GUNS`), adds the Montezuma `unlock(9)`
    rule, and drops its stale 5-gun `weapons` override.
  - **Fairy:** unlocks all guns, adds the rules for guns 6/7/9, and flushes
    with `save_preferences`.
  - **Nightmare:** its stale 7-gun `weapons` override is commented out.
  - **Decision:** the 100% tool does not write mod banks; the in-mode unlock
    is more robust (README "Local patches (Build 9…)").
  - New **`tools/mode_guns_check.py`** (29 checks; 12 fail against the old
    files).
- **Item 5, mod menu**, `modded/sk-rework/script.lua` **BUILD=9**, new §5:
  - appends to `open_menu` / `act_menu` / `gamepad_ctrl`, and never adds
    entities to the engine `menu` table;
  - `mm_sync` re-syncs the frozen row names (`e.name = e.id`) so ON/OFF
    flips live;
  - restores Back (`back`) and locks Reset when the list matches the state
    at opening (the engine set `reboot` permanently);
  - the legend is one plain dp-4 entity at x=4, vertically centred, in short
    pico-font lines, with no hover state;
  - `modcheck` gives E1–E4 (Terminal off or not last; Collection off or
    below Art of War) at boot and live;
  - **AUTO-FIX** stable-sorts to the canonical order and enables the needed
    mods;
  - the old `native_button` / `destroy_group` / global `add` probe were
    removed;
  - mock render: `notes/img/build9-modmenu-mock.png`.
- **Red text = error codes** (owner rule): new **`notes/red-warnings.md`**
  (T1–T3, A1–A3, D1, C1–C2, S1, L1, B1 + E1–E4 + dependency rules).
  `tools/parse_log.py` adds section **1b**: every ` !! ` mod red line,
  classified, attributed to the loading mod (L1 to the folder in its path),
  with engine noise ignored. It also collects `SKUI|modmenu` /
  `SKUI|modcheck`. Selftest **49/49**; mutation-checked.
- `tools/mod_smoketest.py`:
  - `FAKE_MODMENU_LUA`, a verbatim port of the engine's
    `open_menu` / `act_menu` / `close_menu` mod-list branches;
  - 8 item-5 checks (live toggle text, Back after on→off, reorder and
    restore, legend position and removal, AUTO-FIX result, boot modcheck);
  - the build number is read from `script.lua`.
  - **64/64 ×4.** Mutation-checked: no name re-sync, Back never restored, and
    Terminal mis-ranked are each caught.
- **Item 6:** INSTALL Step 5 is rewritten as the Build 9 test list (A1–A6,
  B1–B4, C1–C8, tests only). The success checklist, HANDOFF §5/§6, WORKLIST,
  README, SUMMARY, `notes/mods.md` pitfalls 8–9 and `tools/mod-dev.md` are
  updated.

## 2026-10-06 — session 10: run 6 absorbed, game decoded, Build 8 items 1–3

- **`game/`** (commit d4cb2f5): the owner's game copy, extracted from the
  4-part split zip on `main` (315 files, all CRCs OK). The zips were removed
  from `live testing result/`, and `.gitignore` has a `!game/` exception.
  Policy (never delete; future sessions read it from this branch):
  HANDOFF §2b.
- **`tools/sgr_extract.py`** (new): pure-Python `data.sgr` decoder (xorwow XOR
  cipher + zlib + container; `--all`, `--list`). Its output, committed as
  **`game/decoded/`** (54 files: all Lua source, gfx, lang, shaders).
- **`notes/game-internals.md`** (new): engine facts with line numbers: the
  main loop / `gamepad_ctrl` order, `mk_but` / `mk_text_but` / `remove_buts`
  / `reset` / `kl`, draw depths, the screen geometry, the mod sandbox's
  replaceable / forbidden keys and asset-loader wrapper, `append`
  semantics, the mod load order, and the weapons list.
- `modded/sk-rework/script.lua` — **BUILD=8**. §4 panel rewritten as a
  self-drawn overlay:
  - one entity (dp 15, no `button` flag), with
    `panel_frame` appended to `gamepad_ctrl` (hit test, click consume via
    `mcl/mcr/mlb=false`, pointer parked at -1,-1 while the modal box is
    open, fast-forward click lock);
  - `build_items` lays out pages 1/2/3 (cards 15 per page, spawn 16 per
    page, both paged) in a 204-px box over the board; `panel_draw` uses
    pico-font 9-px buttons; the `SK DEV` tab is in the bottom-left corner;
  - re-created when `ents` changes; hidden while
    `leveling/pause/menu/any_card_menu/codex`; `pcall` wraps only when it
    exists;
  - removed: `clear_native_buttons`, `ensure_dev_panel`, `make_*_page`,
    `offer_active` and the `remove_buts` CLOSE; `destroy_group` now uses
    `kl()`;
  - the `new_turn` hook no longer touches the panel; `init_game` calls
    `panel_reset`.
- `modded/sk-rework/info.lua` — Build-8 description.
- `dist-overlay/mods/` — 7 workshop mods patched to the sandbox's
  `newsrf/newsfx(name, "file.ext")` order. Quartz Army and Shootout
  register `tmqa_*` / `shootout_gfx` instead of overriding the base
  `gfx/cards/title/tutorial`, and Quartz's cards and pieces point at its own
  sheets. Documented in `dist-overlay/README.md`.
- `tools/build-dist.ps1` — `modlist.lua` is written in an explicit
  dependency order (Collection above Art of War / Disgraced Justice; every
  Terminal client above it; **Glac Terminal last**; unknown folders
  alphabetical just above the Terminal) instead of alphabetical order.
- `tools/mod_smoketest.py` — the mod now loads through a copy of the
  engine's sandbox (`ENGINE_REPLACEABLE` from `code/mods.lua`). A refused
  write fails the run.
  - The fake engine models `gamepad_ctrl` (mouse → hooks → what the board
    sees), `mke`/`kl`, the real `remove_buts` button filter, `font` /
    `lprint` / `rectfill` / `rect` / `sfx`.
  - The panel is driven by the coordinates it draws.
  - 14 new checks, including CLIP+ over the board never reaching a square,
    the new-run rebuild, survival of `remove_buts`, the fast-forward
    double-lp guard, modal swallow, hidden-while-leveling, live labels,
    and no refused global writes.
  - **59/59 × value/pair × default/LuaJIT.** Mutation-checked (3 injected
    bugs, each caught by its check).
- Docs: HANDOFF (session 10, §2b policy, corrected facts 2b/2c/5),
  `live testing result/SUMMARY.md` Run 6, WORKLIST, INSTALL Step 5 (Build-8
  test list), README status rows, `notes/mods.md` pitfalls 6–7.

## 2026-10-05 — session 9: run 5 absorbed, Build 7 shipped

- `modded/sk-rework/script.lua` — **BUILD=7**. New §1b runtime layer (config
  table, SAFE budget + `SKE|call|` intent logging, seeded PRNG, damage/crit
  roll, `ifloor`, bank helpers `bank_set`/`bank_flush`/`persist_cfg`, diagonal-
  first `choose_spawn_square`, `spawn_ally`, `dodge_king`). §4 rewritten as the
  panel v2 (13 buttons on page 1, REAL pages via `remove_buts()` +
  `reopen_page()` after every action so labels show live state; card LIST page
  6/page with `is_card_available` filtering and summon-on-card; spawn piece
  picker). §5 menu widgets now arm on the run-5 ids and clear via `del` (never
  `remove_buts`, which would wipe the engine's own menu). §6 hooks: `new_turn`
  also flushes the bank; `hit` prepend adds the dodge; a new `mk_bullet` append
  applies the damage/crit roll. Post-READY: bank restore/rewrite (magic 505 +
  config cells), a Build-7 API capability line, and the existing probe blocks.
  An offer/level-up screen sets `offer_active`, and the panel refuses to clear
  or build the button layer while it is set — otherwise a stray click on our
  panel would delete the engine's own card buttons. Dead helpers from the
  build-6 panel (`is_live_entity`, `group_alive`, `cheat_spawn_ally`) removed.
- `modded/sk-rework/info.lua` — Build-7 description (panel controls, damage
  knobs, persistence, menu legend, diagnostics + SAFE/intent logging).
- `tools/mod_smoketest.py` — fake engine now keeps **ordered hook lists + a
  `fire()` dispatcher** (the real engine chains appends; the old single-slot
  dict silently dropped Build 7's damage hook), models `remove_buts`, `goto_sq`
  (only the `(hero, sq)` order works, so the mod's guess-validation is
  exercised), `flr`, `t`, `mk_bullet`, `refill_ammo`/`can_reload`, and
  `stack.chamber_max=1` (faithful to run 5). Scenario rewritten for the new
  panel (per-control clicks, offer-screen guard, DMG on → bullet roll, lethal hit → dodge, card
  list take, spawn picker, SAFE double-click, CLOSE) with 45 checks incl. the
  close-state regression and the offer-screen guard). **47/47 × value/pair ×
  default/LuaJIT.**
- `tools/parse_log.py` — parses `SKE|call|` (name/status + a dangling `=start`
  becomes `crash.pending_call`, rendered as "that control is the crash
  suspect"), stores `SKD|dmg|` rolls and `SKUI|{panel,card,spawn,dodge,cfg,api,
  menu}` lines, and renders a new "12h. Build 7" section. Selftest extended to
  **44/44** (build-7 calls, SAFE-blocked call, damage roll, panel lines,
  section render, dangling-call forensics, plus a mutation-command
  non-execution check).
- `notes/map.md` — new "Live-verified facts — run 5" section: the ghost-panel
  root cause + `remove_buts`, the real menu ids, the decoded bank format, the
  bullet/damage route + `stack` fields, summon-family card fields, live soul/
  scepter/offer traces, and the availability of the Build-7 helpers.
- `notes/game-map-draft.md` — regenerated from the run-5 log (new parser
  sections included).
- `live testing result/SUMMARY.md` — Run 5 section (findings + the 8 owner
  asks) and the refreshed follow-up status.
- `PLANNING.md` — §0.7 routing note updated; new **§0.7b** with asks 12–19
  (panel close/state, spawn placement/variety, ally bugs, reload/cartridge,
  cardless card, damage, dodge, spawn lag).
- `WORKLIST.md` — Build-6 live run ticked, Build 7 recorded, guessed-signature
  item rewritten, Phase-2c finished, menu item closed, session-9 audit entry,
  owner to-do refreshed for the control-by-control Build-7 run.
- `HANDOFF.md` — session 9: branch/docs/mod pointers, new hard-won facts
  (2c–2f), §5 rewritten around the run-5 outcome and the Build-7 next step.
- Evidence cleanup: `live testing result/uploads/` (run 4) and the run-5
  `notes/` snapshot deleted after absorption.

# notes/changelog.md — what we changed and why

Every kept change gets an entry. Newest first. `res://` paths only (the same
file lives in `modded/` at that path).

## Format

```
## YYYY-MM-DD — Phase N: <short title>
- `modded/sk-rework/<file>` — what changed (with `-- SK-REWORK:` markers inside)
- why: <reason / which design option from PLANNING.md §5>
- status: <shipped / playtest-pending / reverted>
```

---

## 2026-10-04 (session 8) — Run 4 crash fixed as Build 6; run-4 harvest promoted

- `modded/sk-rework/script.lua` — BUILD 5 → 6. **Crash fix:** the input probe
  no longer blind-calls `btn()`; it only probes ids the live game published
  (`validate/cancel/shoot/special/reload/unsafe`, `ctrl`, `m:lb/m:rb/m:mb`),
  with the fatal path documented in a comment block. Probe blocks reordered
  safe-first (cards → exclude → souls → bank → input) and each ends with an
  `SKA2|probe|<name>=done` checkpoint; the persistence block (which run 4 never
  reached) now runs before the input probe. why: run 4 crashed the game at
  boot with `ERR Button left for player 0 doesn't exist.` (script.lua:817) —
  unknown `btn()` ids fall through to the engine's input parser and a malformed
  id is fatal, with no `pcall` available to catch it. status: shipped;
  playtest-pending (owner live run of build 6).
- `modded/sk-rework/info.lua` — description updated to Build 6 with the crash
  note and the checkpoint contract.
- `tools/mod_smoketest.py` — the fake engine is now faithful where it mattered:
  `INPUT_ASSIGNEMENT` is a formatted string, `MOUSE` is a boolean, `scepters`
  is not a global, and `btn()/btnp()/btnr()` **raise** on unconfirmed ids with
  the engine's own `!!` warning lines. Added a model self-check (`btn("left")`
  must raise) and new expectations (`SKI|btn|validate=false`,
  `SKI|btncode|m:lb=false`, `SKI|input|probed=10…`, no unsafe names, all five
  checkpoints, `SKS|scepters|available=false`). 36/36 per mode on default Lua
  and LuaJIT 2.1; re-injecting the run-4 bug now fails the harness with the
  exact live error string. why: the old fake returned `false` for every
  `btn()` call, which is why 33/33 passed while the real game died.
- `tools/parse_log.py` — new `SKA2|probe|<name>=done` checkpoint capture and
  rendering (with a warning when the chain stopped before the input block),
  plus **crash detection**: `ERR` message, tab-indented `Stack traceback`
  frames, `Quitting required`, and a "crash inside a mod" highlight. Selftest
  31/31 → 37/37 (crashed-chain + crash-render cases). why: a draft generated
  from a crashed run previously looked like a clean harvest.
- `notes/game-map-draft.md` — regenerated from the run-4 log; its verdict
  section now reports the boot crash and the failing frame.
- `notes/map.md` — new run-4 section (63-name live API surface incl. the soul/
  scepter family, 186 cards fully fielded, the 10 `special=` cards, 14 piece
  schemas, 25 offer candidates, `savbnk`/`scepters` absent); input section
  rewritten around the 🛑 `btn()` contract, the live `INPUT_ASSIGNEMENT` text,
  and the fact that mouse ids stop at `m:lb/m:rb/m:mb`.
- `live testing result/SUMMARY.md` — run 4 section (crash + root cause + what
  was harvested before it) and session-8 follow-up status.
- `WORKLIST.md` — build 5 live run marked crashed; build 6 fix item added;
  "extra-mouse-button binding" queued as an isolated, crash-tolerant
  experiment; run-4 answers and build-6 questions added; audit log entry.
- `HANDOFF.md` — session 8 state; fact 2b (the `btn()` landmine + "engine
  calls take only confirmed arguments"); intervention point updated to build 6
  in-play testing.
- `IMPROVEMENTS.md` — session-8 arc (items 29–34).
- `README.md`, `INSTALL.md`, `tools/mod-dev.md`, `notes/map.md`, `HANDOFF.md`
  — Build 5 → 6 references, test counts, and the owner's wording fix: the
  mod-menu location now reads "click **Play** (top entry)" everywhere, with no
  title-screen/main-menu contrast.

## 2026-10-04 (session 7) — Build 5 code + map/tooling refresh (live test pending)

- `modded/sk-rework/script.lua` — Build 5: native `mk_text_but` Dev panel
  (+ammo, random eligible card, dynamically chosen ally summon, God Mode),
  MODLIST-ID-gated mod-menu Back/legend, plus post-READY `SKCF/SKOF/SKS/SKD/
  SKI/SKUI` probes. The damage-multiplier button is intentionally gated until
  the live damage route is confirmed. Build 5 has **not** been run in-game yet.
- `tools/parse_log.py` — added parsers and markdown sections for full card
  fields/EXCLUDE, offer flow, souls/scepters, damage, input, and UI/config.
  Selftest now 31/31, including a `!!` warning-prefix regression check.
- `tools/mod_smoketest.py` — models Lua-function wrappers, no `loadfile`, both
  `all()` semantics, additive hooks, fake native buttons, Dev actions, and
  parser handoff. Result: 33/33 checks per mode on default Lua and LuaJIT 2.1.
- `notes/map.md` — promoted static, source-grounded engine patterns and
  labeled owner-reported/unknown details; Build-5 probes remain unverified
  until the live log.
- `tools/save_codec.py` — fixed the no-directory `--selftest` `IndexError`;
  built-in synthetic parse/container roundtrips pass 2/2, optional `[savedir]`
  checks real `.sav` files. Earlier six-save verification remains in history.
- `modded/sk-rework/info.lua`, `cover.png`, `README.md`, `WORKLIST.md`,
  `HANDOFF.md`, `IMPROVEMENTS.md`, `tools/mod-dev.md` — Build-5 status/docs
  synced; new custom cover is 320×180 pixel art.
- why: owner said proceed with schedule steps 1 & 2 (Build 5 + code-map/tool
  reliability/doc promotion).
- status: sandbox-tested; **owner Build-5 live run still required**.

---

## 2026-10-04 (session 6) — live-testing evidence consolidated; docs finalized; full audit before PR

All raw run-1/2/3 evidence (8 screenshots, 3 critique notes, 3 log packs
with save folders and modlist copies) is deleted — every finding was
already recorded in `notes/map.md`, `notes/game-map-draft.md`,
`PLANNING.md` §0.7 and the changelog entries below. New:
- `live testing result/SUMMARY.md` — the single consolidated live-testing
  log: per-run findings tables (fixed vs open), pointers to where each
  result lives now, and the open feature-ask list
- `HANDOFF.md` — session 6 state: toolchain complete + live-proven, five
  owner feature specs locked (PLANNING §0.7.6–.11), next = sk-rework
  build 5 (Phase 2c panel + legend/Back button + probes)
- `IMPROVEMENTS.md` — sessions 5–6 arc (items 17–22)
- `PLANNING.md` §0.7 — routing note: specs → WORKLIST queue, build 5 first
- `WORKLIST.md` — consolidation sweep entry, stale path references fixed,
  owner to-do refreshed
- older changelog entries keep their original `live testing result/…`
  paths as history — those files no longer exist (see SUMMARY.md)
- audit findings folded in (no functional bugs): `save_codec.py` docstring
  now tells the truth about containers — the game's own deflate writer
  isn't python-zlib-reproducible (FLEVEL 0, sizes between L0/L1), so the
  byte-exact guarantee is the TEXT layer while our level-9 containers are
  live-proven readable; `notes/map.md` stale "mods ARE enabled by default"
  line reworded (mods start OFF; run 2's correction now stated everywhere)
- why: owner asked to consolidate the evidence, update all four log docs,
  audit the entire branch diff, then open the PR
- status: shipped; full test suite re-run green (parser 23/23 + both log
  parses; smoke 29/29; codec roundtrips; unlock E2E; 3/3 .ps1 parse)

---

## 2026-10-03 (session 5b) — run 3 absorbed: unlock unified into the build, multi-boot log handling

Owner rebuilt with the updated repo (`-Clean -NoInheritMods`), played without
opening the mod menu (as instructed), then toggled one workshop mod on/off and
used save-and-reboot, and uploaded the run-3 `-GetInsights` pack plus their
full console log.

- **Pre-enable verified live:** console showed `3b/3 wrote mods/modlist.lua`,
  the copy booted with sk-rework ON and all 13 workshop mods OFF with zero
  menu visits, and the harvested `modlist.lua` matches the build's written
  order exactly. The legend text also shipped (visible in the SKM desc dump).
- **`tools/build-dist.ps1` — 100% unlock unified (owner run-3 request).** New
  step 4/4 runs `make_100pct_save.py` on the copy automatically: python/py
  auto-detected, `-NoUnlockAll` skips, friendly messages when the copy has no
  `save\` yet or python is missing (manual command printed). Run 3's saves
  proved the need: 27 achievements / 163 cards / rank 6 — the owner's real
  progress, because the separate tool step was never run. PLAY-THIS.txt,
  INSTALL.md (Step 7 now "automatic"), README updated to match.
- **`tools/parse_log.py` — multi-boot log support.** The mod menu's
  save-and-reboot soft-reboots the game inside the same log.txt: every mod
  script runs twice (dumps duplicated) and the reboot truncated boot 1's SKC
  dump mid-line at card 177 (its tail — 9 cards, count, READY, probe — lost;
  line order non-chronological at the transition). Parser now dedupes cards
  by id and hooks by target+id (last occurrence wins): run-3 parse reports
  `hooks: 5 · cards: 186`. A missing READY line in a rebooted session is the
  collision, not a mod failure — documented in `notes/map.md`.
- **New feature asks logged in WORKLIST:** mod-menu Back button (Phase 2c,
  same UI-hook route as the always-visible legend line) and the exclude-rule
  rework (remove auto-ban of un-chosen offered cards after a pick + make the
  exclude action rebindable to extra mouse buttons; needs offer-roll
  internals + a mouse4/5 probe).
- why: owner's run-3 critique ("how about unify it since we inject it to
  modded app already anyway") + the reboot-path log anomaly their run exposed
- status: shipped — verified: parser selftest 23/23, run-3 + run-2 parses,
  3/3 `.ps1` tree-sitter clean. Owner's next rebuilt copy should show 4/4
  and boot fully unlocked (pending that one glance).

---

## 2026-10-03 (session 5) — live test run 2 absorbed: modlist format, pre-enable, 195-card set

Owner ran build 4 with `apply.ps1 -GetInsights` and uploaded the pack into
`live testing result/run 2/` (log + the game's own `mods/modlist.lua` + the
whole `save\` folder) plus a critique of the mod-menu documentation. Both
remaining harvest goals landed; feature work is unblocked.

- **`notes/game-map-draft.md` regenerated from the run-2 log** — build 4
  confirmed clean (`READY build=4 hooks=5 globals=920`); new sections live:
  §10 MODLIST dump (all 14 entries with author/save/priority_hint/active…),
  §11 card id map (186 cards, gid 0–192, ext 0–3, pwe, `special=` flags on
  10 cards). The `SKML|` in-log probe never fired because `loadfile` does
  not exist in the mod environment (`SKA2|loadfile=no`) — the harvested file
  itself supplied the format instead.
- **`tools/build-dist.ps1` — mods pre-enabled (owner critique #2 closed).**
  New step 3b writes `mods/modlist.lua` in the game's byte-exact format
  (CRLF, tab indent, trailing comma every entry, no trailing newline —
  generator verified byte-identical to the game's own file): `sk-rework`
  starts ON, workshop mods start OFF, new `-AllModsOn` switch. PLAY-THIS.txt
  and console output updated to match.
- **`tools/make_100pct_save.py` — card set corrected 170 → 195.** The run-2
  SKC dump showed the old list missed 25 real cards (Anarchy, Stoning,
  Vendetta, Warhorse, Shovel, Sprint, …); the game itself writes exactly 186
  CARDS names + 9 special keys (bleed, cloak, grenade, jump, leader, line,
  mission, orb, Unfaithful Steed) to stats.sav — the tool now writes that
  exact set (E2E-verified on a disposable copy of the run-2 save).
- **Docs corrected from the run-2 critique:** mods are **OFF by default**
  (run 1's "ON by default" was wrong — black text = OFF, white = ON; the
  owner's paradox observation was right). `INSTALL.md` Step 5 rewritten in
  neutral tone with the correct color facts and the new no-toggling-needed
  flow; README + PLAY-THIS.txt + success checklist + troubleshooting rows
  all updated.
- **`modded/sk-rework/info.lua`** — description now leads with the mod-menu
  legend the owner asked for ("white text = ON, black text = OFF; up/down =
  load priority"), visible in the mod menu. (An always-on legend line inside
  the menu itself needs a draw hook — queued with Phase 2c.)
- **`tools/parse_log.py`** — summary line now also prints `mods:` and
  `cards:` counts when SKM/SKC sections are present.
- **`notes/map.md`** — live-verified section updated: OFF-by-default +
  modlist.lua byte format, per-mod save system (`save/mods/<name>.sav`
  plaintext, no zlib wrapper; `reg.sav` registry; `MODSAV`/`save` globals),
  game-made `.sav.bak` snapshots, `loadfile` absent, full MODLIST entry
  fields, 195-key codex set with the 10 `special=` mechanics cards, and a
  footnote about the caught-in-analysis bool-vs-string bug (briefly
  suggested "modded sessions wipe achievements" — false; run-2 post-session
  file has all 128 True).
- why: owner's run-2 critique (mod-menu default state paradox, doc tone,
  in-game legend request) + the two harvested unknowns (modlist format,
  card ids) that gated pre-enable and the codex fix
- status: shipped — verified: parser selftest 23/23; smoke test 29/29 (both
  `all()` semantics); codec roundtrip byte-identical on run-2's 6 saves;
  100% tool E2E (128 achievements True, 195/195 cards); 3/3 `.ps1`
  tree-sitter parse clean. Playtest of the pre-enable behavior pending
  (owner's next launch of a rebuilt copy).

---

## 2026-10-03 (session 4) — live test #1 absorbed: parser fix, build 4, codex 100%, docs corrected

Owner ran the whole ladder twice (inherited mods + `-NoInheritMods`) and the
optional python step, uploaded `live testing result/` (critique + screenshots)
and `live testing result/game-insights/log.txt` (run 1). Everything below is a
response to observed reality.

- **`tools/parse_log.py` — 🐛 fixed the false "mod did not run".** The game
  wraps every log line in `  . ` / ` !! ` markers; the parser matched raw
  prefixes only, so a perfectly good live log was rejected. Now strips the
  marker; selftest grew to 23/23 including a game-prefixed regression case.
  New prefixes understood: `SKM|` (MODLIST dump), `SKC|` (CARDS id map),
  `SKML|` (modlist.lua probe), rendered as draft §10–12.
- **`notes/game-map-draft.md` generated from the real log** — 920 globals,
  41 replaceable, 26 forbidden, 47 gameplay events, 4 object tables; verdict:
  append() hooks fire, on_* probes never do.
- **`modded/sk-rework/` build 4** — drops the proven-dead `on_*`/`upd` probes
  (they never fire for plain mods and shadowing those globals can break the
  Glac Terminal dispatcher); adds SKM MODLIST dump, SKC card id map, and a
  post-READY `loadfile("mods/modlist.lua")` probe so the next run reveals the
  enable-state file format. Smoke test 29/29 under both `all()` semantics.
- **`tools/make_100pct_save.py` — codex 96% → 100%.** Live run left 6 special
  cards locked (Right-hand, Gatehouse, Catacombs, Onboarding Party, Faithful
  Steed, Redemption); they are now written too (170 cards). Output explains
  the harmless `MODDED: ON - ACHIEVEMENTS: OFF` title label.
- **`tools/apply.ps1` — new `-GetInsights`**: harvests log.txt +
  `mods/modlist.lua` + the whole `save\` folder into
  `uploads/game-insights/` (backup route to learn the modlist format and the
  exact codex keys).
- **`tools/build-dist.ps1` PLAY-THIS.txt corrected**: mod menu is Play→top
  entry (not main menu), mods ON by default, up/down = priority, and the
  achievements-off label explained.
- **`INSTALL.md` corrected from the critique**: real mod-menu location,
  default-ON, bright text = ON, priority sorting is cosmetic; Step 5 log table
  now shows build-4 lines (heartbeat line removed — it never fired); Step 6
  offers `-GetInsights`; Step 7 documents the two "looks wrong but is not"
  symptoms; troubleshooting rows for 96% codex / achievements-off / scrambled
  numbering / stale parser.
- **`notes/map.md`** — new "Live-verified facts" section (log wrapping,
  default-ON + modlist.lua, append-only hooks, live object model, 170-card
  codex); the "probably enabled by default" guess marked resolved.
- **README.md** — status table flipped to live-proven; the three pre-live
  unknowns listed as resolved.
- why: owner's live-test critique (mod menu location, terminal-vs-patch mod
  management, toggle colour confusion, codex thumbnails, achievements-off
  label) — each item answered or tool-fixed here; modlist pre-enable waits
  for the format (build 4 SKML / -GetInsights will deliver it).
- status: shipped; build 4 + -GetInsights await the owner's next 5-minute run.

---

## 2026-10-03 (session 3) — Placement-aware INSTALL.md + `mod`/`mods` normalization

- **`INSTALL.md` fixed for manual folder setup & `E:\testing\repo\tools` commands.**
  - Steps 1 & 2 are now **Manual (File Explorer) only** — removed the broken
    `mkdir E:\testing` and Steam `Copy-Item` block (owner already created
    `E:\testing\game` 1:1 with the game `.exe` + `data.sgr` and `E:\testing\repo`
    1:1 with the root of `main`).
  - Every PowerShell step (Steps 3, 4, 6, 7) now points directly to
    `E:\testing\repo\tools` (`cd E:\testing\repo\tools` +
    `"E:\testing\repo\tools\..."`), where `apply.ps1`, `build-dist.ps1`,
    `parse_log.py`, and `make_100pct_save.py` are located.
- **`tools/build-dist.ps1` & `tools/install-mods.ps1` — handles pre-existing
  `game\mod` or `game\mods` (compressed `.zip`/`.rar` or unpacked folders):**
  - Merges `mod\` (singular) into `mods\` (plural) in the built copy;
  - Unpacks any `.zip` archives in `game\mod` or `game\mods` and names the
    folder after `name=` in `info.lua`;
  - Normalizes already-unpacked mod folders (even if named after the zip or
    double-nested) to match `name=` in `info.lua` so nothing duplicates;
  - Removes `.rar` archives and legacy folders without `info.lua` from the
    copy's `mods\`;
  - Added `Resolve-RepoRoot` and `Resolve-GameDir`.
- **Waitlist (`WORKLIST.md`):** queued zero-argument auto-file discovery for
  after core features are implemented and working first.
- why: `INSTALL.md` pointed to `repo` instead of `repo\tools`, had a failing
  Steam `Copy-Item`/`mkdir` snippet in Step 1, and needed to account for mods
  already placed inside `game\mod` or `game\mods`.
- status: shipped

- **`modded/sk-rework/script.lua` → diagnostics build 3.** Owner asked that
  the mod "log itself, or the game state during live testing, if the patch was
  successful". It now:
  - proves itself: load banner with build id, `MODLIST` self-check,
    `SK-REWORK: READY build=3 hooks=5 globals=N` marker;
  - self-checks the API: `SKA|<name>|YES/no` for 38 globals the project
    plans to use (so we stop coding against names that don't exist);
  - dumps the function map: `SKG|`/`SKR|`/`SKF|` (as before) + counts;
  - hooks 5 proven game globals via `append()` (`new_turn`, `new_level`,
    `setup_piece`, `add_card`, `init_game`) and logs each registration
    (`SKH|`) — hooks are the proven mechanism for *script.lua*; `on_*`
    callbacks are only probed (`SKE2|`) because independent workshop mods
    never rely on them (the "Glacies Module Terminal" mod supplies that
    dispatch). Comparing `SKE|` vs `SKE2|` counts in the log settles it.
  - logs live state: `SKW|turn=…|bads=…|bullets=…|hero_px=…|hero_py=…` each
    turn, `SKO|hero|…` / `SKO|piece|…` / `SKO|card|…` object field dumps,
    `SKO|disp_stats|…` from `edit_disp_stats` (the fastest route to the real
    ammo/health field names), plus a 900-frame heartbeat.
  - safety: no `pcall` exists in this engine (no shipped mod uses it), so
    every value goes through a nil/boolean/table-safe `sv()`, all loops are
    capped (first 30 hits then every 25th) and no gameplay logic is touched.
- **`tools/parse_log.py` (NEW)** — parses those lines into
  `notes/game-map-draft.md`: mod-load verdict, API availability, hook list,
  **event-dispatch verdict** (append vs on_*), live state samples, discovered
  object model, and keyword-grouped candidate names for each `map.md` TBD
  (ammo/damage/spawn/cards/turn/UI/save/shots). `--print`, `--json`,
  `--selftest` (16/16). If the log has no SK-REWORK lines it says so and
  prints the log tail, where the game writes the Lua error.
- **`tools/mod_smoketest.py` (NEW)** — runs `script.lua` against a **fake
  SUGAR environment** (lupa), fires the hooks, and feeds the captured lines
  to the parser: 27/27 checks, run twice (once per possible `all()` semantics,
  since the engine's iterator is only known from usage in the workshop mods).
  Caught two real defects before the owner's live test — see below.
- 🐛 **Fixed (found by the smoke test):** `sv()` would concatenate a boolean
  (`mod.active`) — a runtime error in Lua 5.1; now booleans/ nil/ tables are
  handled explicitly. Also `dump_fields` skipped nested tables, which would
  have hidden the `{id=,name=,value=}` shape of the displayed-stats table —
  i.e. exactly where the ammo stat name lives; it now expands one level.
- **Docs**: `tools/mod-dev.md` gained the log-line reference + parser/smoke
  test usage; `INSTALL.md` step 5 shows what "it worked" looks like (READY
  line etc.) and step 6 mentions the parser; README tool table + status rows
  updated.
- why: owner wanted the patch to prove itself during live testing and log
  game state, rather than only dumping a name list.
- status: shipped (fully tested without the game; live run still pending)

## 2026-10-03 (session 2b) — One canonical install path (INSTALL.md)

- **`INSTALL.md` (NEW)** — the owner asked for an unambiguous, step-by-step
  install and a clear division between live testing and the dev roadmap.
  Contains: the "whole repo, not one file" answer (mods are folders; nothing
  patches the exe); the canonical layout `E:\testing\{game, repo,
  ShotgunKing-Modded}`; Steps 1–7 with a check after each; a success/report
  checklist; an explicit "your part ends at Step 7 / development is mine"
  boundary with the phase table; undo table; troubleshooting; and a
  clearly-marked Variations section (paths, unlocks-only, real-install mods,
  dev loop) so alternatives can't be mistaken for the main flow.
- **`README.md`** — top callout points to INSTALL.md; the "First run" section
  became a 7-row summary + link (two competing checklists was itself a
  contradiction risk); fixed stale step references; layout section includes
  INSTALL.md.
- **`tools/build-dist.ps1`** — usage header documents the canonical
  `-OutDir "E:\testing"` invocation; `PLAY-THIS.txt` is now generated with
  the real source path and the exact unlock command for that copy; the end of
  the run prints the playable exe path, the next action, and the `-GetLog`
  command; exe auto-detect prefers names matching shotgun/king.
  **NEW `-NoInheritMods` switch** (closes review F7): drops the source
  game's `mods\` from the copy so a build contains exactly the 14 known-good
  mods — the owner's base game demonstrably contains stray mods
  (King's Court.rar etc.), which would otherwise be inherited silently.
- why: owner found the README ambiguous about what to download, where to put
  things, and which steps were theirs.
- status: shipped (docs + script output; 3/3 ps1 re-parsed clean)

## 2026-10-03 (session 2) — Readiness review + README rewrite + tool fixes

- **`notes/review-2026-10-03.md` (NEW)** — pre-live-test review: per-tool
  target/undo table, per-artifact verification status, findings F1–F9, risks,
  risk-ordered test ladder. Written because the owner found the README
  ambiguous about whether tools patch the install or build a clone.
- **`README.md` rewritten** — "Does this touch my real game install?" is now
  the first section (answer: the play path builds a copy; "injection" only
  ever = adding folders under `mods/`); status table uses honest
  ✅ verified / 🟡 ready-but-unproven / ⛔ blocked states instead of
  "shipped"; dev roadmap reduced to a short pointer; safe first-run checklist
  added (dry run → build copy → launch → -GetLog → optional 100% save).
- **`tools/make_100pct_save.py`** — F2: `throne` table was dropped when the
  save lacked the key (`prog.get` → `prog.setdefault`); F3: friendly
  instructions instead of tracebacks when `save/` or its three `.sav` files
  don't exist yet; `--restore` now works even if `save/` was deleted;
  backup path made explicit (`game_dir`, not `dirname(save_dir)`).
  Regression-tested end-to-end on disposable synthetic saves.
- **`tools/save_codec.py`** — F4: `--help`/no args prints usage (previously
  tried to decode a file named "--help").
- **`tools/build-dist.ps1`** — F5: stray-archive cleanup rewritten with
  `Where-Object { $_.Extension -in ... }` (the old `-LiteralPath` + `-Include`
  combination is a PowerShell grey zone and the unquoted wildcard list was the
  one construct flagged by a tree-sitter parse); `PLAY-THIS.txt` now states
  the copy semantics and includes the unlock-the-copy recipe; typo `game''s`
  fixed.
- **`HANDOFF.md` / `WORKLIST.md`** — branch name corrected to the current
  session branch; live tests re-cast as the risk-ordered ladder (Step 4 =
  the only blocker); new "ready now, not blocked" list (log parser first).
- why: owner asked for a review before live testing, and to have the README
  reworded so it distinguishes "clone with injected mods" from "modifying my
  base install".
- status: shipped (docs + tool fixes verified in sandbox; live run pending)

## 2026-10-03 — Audit + 100% save generator + main-disposal merge + pro README

- **Audit pass**: purged Godot-era leftovers (tools/repack.md, game-dump/,
  stale modded/README.md, .gitignore rebuilt), dropped accidentally
  committed tools/__pycache__, verified tracked-file consistency.
- **save_codec.py upgraded to full parser/serializer** — PUNKCAKE text
  <-> Python dicts, byte-identical roundtrip on all 6 saves (`--selftest`).
  Bugs found & fixed by the selftest: empty tables, string-value 0x1F
  suffix, no indentation in the real format.
- **NEW tools/make_100pct_save.py** ("casual Sunday player" unlock-all):
  128 achievements bTrue, weapons 2-9 unlocked, throne rank 20 + rank-20
  badge per weapon, endless floor 15 (chase unlocked), 164 vanilla cards
  marked played (codex 100%). Preserves best times/runs/reg/misc.
  Auto-backup + --dry-run + --restore. Verified on real save copies.
- **Mod menu on/off documented** (owner request): injected mods are NOT
  forced — PLAY-THIS.txt + README explain per-mod toggling in-game.
- **Merge commit disposes main's archives**: merged origin/main (unrelated
  histories) into the branch, then removed part4.rar + 13 mod zips + stale
  plan doc. A PR branch->main now carries the cleanup (merging it cleans
  main without 14 manual web-UI deletions).
- **README rewritten** professional-style: feature table, three quick-start
  paths, layout map, troubleshooting, credits.
- why: owner asked for 100% unlock save, PR-based main cleanup, full patch
  audit, and a polished README.
- status: shipped (live playtest still pending)

## 2026-10-03 — Save format cracked + dist injector + mods vendored

- **Save codec**: `save/*.sav` = [4-byte BE length][zlib] + PUNKCAKE
  serializer text. Verified on all 6 saves (decode/encode/decode roundtrip).
  `tools/save_codec.py` (CLI decode/pack/scan). Key cheat targets identified:
  prog.sav (weapons/badges/throne), stats.sav (card offer memory).
  No mod-enable state in saves → mods likely default-enabled (live test
  will confirm).
- **dist-overlay/mods/**: all 13 workshop mods vendored into the branch
  (owner confirmed: freely distributed via official Discord/Workshop;
  wants them "injected into the game's genes"). Folder names verified
  against info.lua name= (disgraced_justice needed a rename — would have
  been another silent load failure).
- **tools/build-dist.ps1**: builds dist/ShotgunKing-Modded/ = full game copy
  + all mods injected + sk-rework + PLAY-THIS.txt. Original folder untouched.
- **Workspace slimmed**: uploads/game/ (part4 rar copy) deleted — full game
  still recoverable from branch history + user's PC rars. uploads now ~24MB.
- why: owner wants zero-hassle play (mods pre-injected) + save modification
  capability; repo carries small payloads only.
- status: shipped (live test pending)

## 2026-10-03 — Owner decisions locked + repo slim-down

- **Decisions recorded in PLANNING.md §0.6**: ammo = A→B→C progressive;
  native-feel UI principle (reuse game's own button code); built-in
  dev/cheat mode + save-modification tools (Phase 2 scope expanded);
  repo public during dev, private at deployment.
- **Removed the 3 game rar parts from the branch** (git rm) — extracted
  keep-list instead into `uploads/game-extracted-lite/` (exe, lang/ 18
  string tables, save/ samples for the save tools, mods/, settings, bats —
  no dlls/steam_settings/data.sgr). `main` still holds part4 + mod zips
  (owner to delete via web UI or covered by private flip). Rars remain in
  git history until a deployment-time scrub.
- **NEW tools/install-mods.ps1**: unzips workshop-mod zips into
  `<game>/mods/`, auto-renames each folder to its `name=` field (the #1
  "mod won't load" cause), skips old-format mods without info.lua.
- why: owner confirmed strategy; repo slimming requested ("remove the rar
  and zip if its already unpacked"); mod-loading failures were killing
  motivation to play.
- status: shipped

## 2026-10-03 — Phase 0 complete: game obtained + ENGINE CORRECTION + strategy pivot

**Findings (owner uploaded the game in 4 rar parts + 13 workshop mods to
GitHub; all parts recovered, extracted, analyzed):**

- **Engine is SUGAR, not Godot** (custom Pico-8-style Lua engine by Rémy
  Devaux; runtime v0.0.8f, LuaJIT 2.1/Lua 5.1, SDL3). No .pck, no gdre_tools,
  no repacking — ever. PLANNING.md §0.5 correction added; §2/§8 updated.
- **Strategy pivot: build the rework AS A MOD.** The game has a first-class
  mod system (official guide by the dev, `append`/`prepend` any function,
  `on_*` events, custom cards/pieces/modes, save banks, `gimme()` runtime
  introspection). `tools/repack.md` deleted → `tools/mod-dev.md` created;
  `tools/apply.ps1` rewritten to deploy `modded/sk-rework/` → `<game>/mods/`.
- **13 workshop mods inventoried** (`notes/mods.md`) incl. Royal Card Lab
  (≈ our card picker) and Glac Terminal (modder debug tool). Dev's modding
  guide cloned to `uploads/modding-guide/` (has SUGAR_manual.txt +
  vanilla `CARDS` table in vanilla_stuff/).
- **Game copy analyzed**: v1.623b, Goldberg-emu repack. `data.sgr` = 79 MB
  compressed package holding all 278 game files (full list:
  `notes/data-sgr-filelist.txt`); contents not plaintext — decision: don't
  crack it, introspect at runtime via debug mod instead. Loose `lang/*.txt`
  = readable string tables (saved to uploads/game-insights/).
- **"Mod won't load" mystery SOLVED**: owner's `King's Court.rar` sat
  unextracted in mods/, AND it's a pre-info.lua 2022 mod (see notes/mods.md).
- Sandbox tooling: compiled unrar 7.20 from source (kept at
  `uploads/tools/unrar`); GitHub raw/release URLs blocked but git+api work.
- why: the entire Phase 0/1 premise changed once real files were examined.
- status: shipped (docs + tooling; no game files modified)

## 2026-10-03 — Phase 0 prep: embedded-pack handling

- `tools/recover.md`, `tools/repack.md`, `PLANNING.md` §8 updated: the game
  ships with its pack **embedded in the exe** (owner confirmed: no loose .pck
  in the install folder). Recovery points `--recover` at the exe; repack uses
  an export preset with "Embed Pck" ticked (or gdre_tools `--pck-patch
  --embed`) and installs by replacing the exe under its original filename.
- why: `--recover` accepts pck/apk/embedded-exe natively (gdsdecomp docs);
  an exe-embedded game ignores a dropped-in .pck, so install must swap the exe.
- status: shipped (docs only, no game files touched)

## 2026-10-03 — Phase -1: repo scaffold

- No game files touched. Created the PLANNING.md §2 structure:
  `.gitignore`, `README.md`, `tools/` (recover.md, apply.ps1, repack.md),
  `modded/`, `notes/` (map.md, changelog.md), `game-dump/` (ignored).
- Renamed the handoff file `2026-10-02-shotgun-king-plan.md` → `PLANNING.md`
  as the plan itself prescribes (§2).
- why: working structure must exist before Phase 0 so nothing we keep ever
  lands outside `modded/`.
- status: shipped
