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

Next step: **sk-rework build 5** — Phase 2c cheat panel + legend + Back
button + the probes that pin every remaining unknown (offer roll, full
card fields, scepters, soul flow, damage application, mouse buttons).
