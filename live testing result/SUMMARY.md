# Live testing — consolidated log (runs 1–3, 2026-10-03)

> This file replaces the raw evidence (screenshots, logs, save packs,
> critique notes) that was absorbed into the project docs during sessions
> 4–6. Raw files were deleted after every finding in them was recorded.
> Where things live now:
> - **`notes/map.md`** — live-verified engine facts + mod-API patterns
> - **`notes/game-map-draft.md`** — the full parsed dump (globals, cards,
>   MODLIST, object model) from the latest run
> - **`PLANNING.md` §0.7** — the owner's feature specs from the critiques
> - **`WORKLIST.md`** — what is fixed vs what is queued (next phase)
> - **`notes/changelog.md`** — file-by-file change history

## Run 1 — the ladder (two builds: inherited mods + `-NoInheritMods`)

**Tested:** apply dry-run, dist build (mod normalization, 14 mods
injected), first launch, log harvest, 100%-save tool.

| Finding | Status |
|---|---|
| Game wraps every log line in `  . ` / ` !! ` — parser falsely said "mod did not run" | ✅ fixed (parser strips markers; selftest 23/23) |
| Mod menu is NOT on the title screen — it is Play → top entry | ✅ documented everywhere |
| Text-colour state confusion (run-1 note "ON by default" was wrong) | ✅ corrected in run 2: **black = OFF default, white = ON** |
| Codex showed 96% after the unlock-all (missing cards) | ✅ fixed (card set corrected twice: 170 → **195**, see run 2) |
| Screenshots (achievements screen, codex thumbnails, mod menu) | 🗑 deleted — issues all resolved |
| `MODDED: ON - ACHIEVEMENTS: OFF` title label | ✅ explained (Steam tracking paused; save-side achievements stay unlocked — proven in run 2) |

## Run 2 — build-4 harvest (`-GetInsights` pack: log + modlist.lua + save\)

**Tested:** diagnostics build 4 (SKM MODLIST dump, SKC card map, SKML
probe) + the insight pack collection.

| Finding | Status |
|---|---|
| `mods/modlist.lua` format captured (byte-exact: `return { {'name', bool}, … }`, CRLF, tabs, trailing commas) | ✅ → `build-dist.ps1` 3b pre-enable |
| **Mods are OFF by default** — run 1's claim corrected (owner was right about the black/white paradox) | ✅ all docs rewritten |
| Full card set: 186 CARDS + 9 special keys = 195 (old tool list missed 25 real cards) | ✅ `make_100pct_save.py` writes all 195 |
| Per-mod saves exist (`save/mods/<name>.sav` plaintext + `reg.sav` registry) | ✅ banked (config-persistence route for Phase 6) |
| `loadfile` absent from the mod environment (why the in-log SKML probe was silent) | ✅ banked |
| Achievements survive modded sessions (owner's full console log confirmed the tool→play→fetch timeline) | ✅ documented (an analysis bool-vs-string bug briefly claimed a "wipe" — caught and corrected) |
| Owner asks: white/black legend text in-game; doc tone fix | ✅ legend shipped in sk-rework's description; docs re-toned |

## Run 3 — pre-enable verification (no mod-menu visit)

**Tested:** the updated build end-to-end: 3b pre-enable, 195-card tool,
legend — played without opening the mod menu, then toggled one workshop
mod on/off and used save-and-reboot.

| Finding | Status |
|---|---|
| **Pre-enable works live**: console `3b/3` line, copy booted with sk-rework ON / 13 workshop mods OFF, zero toggling | ✅ verified (owner-confirmed) |
| Legend text visible in the mod-menu description | ✅ verified (present in the SKM desc dump) |
| Owner never saw the all-unlock — the separate tool step was missable | ✅ **unified**: `build-dist.ps1` step 4/4 applies the unlock automatically (`-NoUnlockAll` skips) |
| Mod-menu "save and reboot" = **soft reboot inside the same log**; mods re-run (double dumps) and the reboot truncated boot 1's card dump mid-line (missing READY ≠ mod failure) | ✅ parser dedupes multi-boot logs; documented |
| Owner feature asks (see PLANNING §0.7 for full specs) | 🔜 queued — WORKLIST next phase |

## Run 4 — Build 5 boot crash (2026-10-04, `-GetInsights` pack + 2 crash logs)

**Tested:** build 5 applied to a fresh copy (`-NoInheritMods`, pre-enabled
sk-rework) and launched twice. Owner note: *"the game fail to load once no
intro but second have intro but crash again."*

| Finding | Status |
|---|---|
| **Build 5 crashed the game at boot** — both runs, identical fatal: `ERR Button left for player 0 doesn't exist.` at `mods/sk-rework/script.lua:817` inside the mod's load (`safe_require` → `run_mods`). The game printed `!! Not recognizing button 'left'…` / `!! Malformed input id 'left'…` first. | 🔴 **root cause found** — the input probe called `btn()` on unconfirmed names (`left`, `right`, `middle`, `mouse4`…). In SUGAR an unknown `btn()` id falls through to the input-id parser, and a malformed id is **fatal** (no pcall exists in the mod sandbox, so nothing could catch it). Fixed in Build 6: `btn*()` is now only called with ids the live game itself published, and the smoke test's fake engine now *raises* on unconfirmed ids like the real one (the old fake returned `false`, which is why 33/33 passed while the game died). |
| "No intro" vs "intro then crash" difference | ✅ explained — same deterministic crash both times; whether the intro frame is visible is just timing. Nothing to fix. |
| Harvest before the crash (load chain) — full card fields (`SKCF|`, 3353 lines), all 186 cards (`SKC|`), EXCLUDE pairs, pieces (`SKS|piece_*`, 14 defs), offer candidates (`SKOF|`, 25), API surface (`SKA|` 63 YES / 5 no), input dump (`SKI|`) | ✅ absorbed → `notes/map.md` (run-4 section) + regenerated `notes/game-map-draft.md` |
| The 10 `special=` ability cards confirmed live (strafe, scope, decree, grenade ×5, orb, dig) — matches the owner's count and the cap-removal target | ✅ promoted to map.md |
| `savbnk` does not exist; the per-mod save is written by the engine itself (`save/mods/sk-rework.sav` was written on exit) | ✅ promoted (bank read/write still unverified — its probe block never ran) |
| `SKD|`/`SKUI|bank`/menu-ID probes never ran (crash + no gameplay) | 🔜 Build 6 re-run, this time through gameplay |
| Owner doc note: where the mod menu is should just say **"click Play"** — no mention of the title screen or a contrast ("not on the main menu") | ✅ all docs reworded in this session |

## Still open — the owner's feature asks (all specs in PLANNING §0.7)

1. **Right-click ability cap removal** (§0.7.6) — own multiple abilities,
   bind to RMB + side buttons + optional middle click, soft-coded
   discovery of any number of ability cards; scepter cap relaxed too
2. **Card picker** — free choice instead of the 2-card offer (§0.7.7;
   Royal Card Lab = the blueprint)
3. **Soul deck "Yu-Gi-Oh style"** (§0.7.8) — 2–3 slots, one slot holds
   many souls, free use/exchange, any soul allowed (pawn behavior stays
   card-driven), summons capped only by board capacity
4. **Bullet damage & crit system** (§0.7.11) — configurable normal/crit
   damage + crit chance, pierce auto-crits
5. **Full button-remap menu** (§0.7.9) + **mod-menu Back button** (§0.7.10)

## Current follow-up status (2026-10-04, session 8)

**Build 5 is retired** (it crashed at boot — see run 4 above). Build 6 is in
`modded/sk-rework/`: same Dev panel, Back/legend helper and probes, but the
input probe only uses ids the live game published, probe blocks are reordered
(safe blocks first) with `SKA2|probe|<name>=done` checkpoints, and the fake
engine now models the fatal `btn()` contract. Sandbox: parser 34/34 (incl. a
crashed-chain check), smoke test 36/36 under each `all()` semantics on default
Lua and LuaJIT 2.1 — including a deliberate re-injection of the run-4 bug,
which the harness now catches with the exact live error.

Next step: apply Build 6 (`apply.ps1` or a fresh `build-dist.ps1`), **play a
couple of turns** (the runtime probes need gameplay), collect the log with
`apply.ps1 -GetInsights`. Damage-multiplier controls remain gated until the
`SKD|` traces are observed in play.
