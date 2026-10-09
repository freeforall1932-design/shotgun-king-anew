# Live testing — consolidated log (runs 1–5, 2026-10-03–04)

> Runs 1–3 were consolidated here after their raw packs were deleted. Run 4's
> crash evidence remains in `live testing result/uploads/`; Run 5's raw log,
> insights, notes, and critique remain in `live testing result/run 5 i believe
> or latest run/`. Preserve those live artifacts as evidence.
> Where the accumulated knowledge lives now:
> - **`notes/map.md`** — live-verified engine facts + mod-API patterns
> - **`notes/game-map-draft.md`** — the full parsed dump (globals, cards,
>   MODLIST, object model) regenerated from Run 5 (Build 6)
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
| `SKD|`/`SKUI|bank`/menu-ID probes never ran (crash + no gameplay) | ✅ Build 6 reached gameplay in Run 5; see the next section |
| Owner doc note: where the mod menu is should just say **"click Play"** — no mention of the title screen or a contrast ("not on the main menu") | ✅ all docs reworded in this session |

## Run 5 — Build 6 live follow-up (2026-10-04)

**Tested:** Build 6 in the modded copy, in a roughly 22-minute gameplay run.
The game shut down normally, and all five probe checkpoints completed. Raw
artifacts: `live testing result/run 5 i believe or latest run/`.

| Finding | Status |
|---|---|
| Build 6 boot + probe chain | ✅ completed in the game; parser reports 30 hooks, 920 globals, 14 mods, 186 cards, 30 sampled turns; no crash |
| Bullet / hit path | ✅ Run 5 captured 12 `fire` calls, 48 bullet samples (`dmg=1`, `pierce=0`), and 30 `hit` samples. This is runtime evidence, not proof of every damage route or a safe multiplier insertion point |
| `+3 AMMO`, random card, ally spawn | ✅ run-time calls observed (9 ammo calls, 2 card additions, 39 spawn attempts). Owner confirms +3 behaves like reserve regeneration, not a chamber reload; the card was not always visually apparent; only type-0 pawns spawned |
| Dev-panel close/hover visuals | ⚠️ owner reports labels remained visible/frozen after closing; panel buttons became unusable. Build 7 strengthens cleanup, but only sandbox-tested so far |
| Pawn placement/reset | ⚠️ owner reports pawn can block king movement and a pawn/occupancy ghost after resigning and starting a new run. Build 7 still spawns one pawn beside the king; click once only and report the reset behavior |
| God Mode | ❌ owner reports it did not protect the king. Mist-style escape from lethal threat is not implemented; mark **DO NOT TEST YET** |
| **Mod-menu Back** | ✅ owner confirms Back worked. The absence of `SKUI|menu|widgets_added` is **not** evidence of failure; do not repeat that inference |
| Mod toggle → Save & Reboot → verify-after-reboot | ⏭ **Not tested in Run 5.** Test ON → Save & Reboot → verify ON; if convenient, toggle back OFF, check for a second Save & Reboot, and verify OFF after reboot. Record whether each reboot control appears |
| Soul / scepter | ⏭ Owner did not use a soul card or activate a soul or Wand/scepter skill. Build 7 adds a direct grant for Majestic Censer + Wand of Souls so testing does not depend on a rare random offer |
| Bank persistence | ⚠️ Run 5 read `magic=0` at initial probe and wrote bank values; no separate-launch readback was tested |

### Build 7 follow-up (working tree; not live-tested)

Build 7 adds `RELOAD`, experimental `CHAMBER +1` (`uplift({chamber_max=1})`),
direct **Majestic Censer + Wand of Souls** grants, and panel-entity cleanup; it
removes the confusing `DMG GATED` placeholder. The capacity change, grants,
visual cleanup, and all other Build-7 behavior must still be confirmed in the
game. See the exact owner checklist in `INSTALL.md` Step 5. Damage/crit,
Mist-style God Mode, the multi-soul deck, ability-cap removal, pickers, and full
button remapping are **not implemented — do not test yet**.

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
5. **Full button-remap menu** (§0.7.9); mod-menu Back is owner-confirmed
   working in Run 5, while the legend visibility still needs confirmation.

## Current follow-up status (2026-10-04, Build 7)

Build 6 fixed Run 4's fatal `btn("left")` crash and was confirmed live in Run 5.
Build 7 is now in `modded/sk-rework/`; it has not been applied or tested in the
game. The owner checklist in `INSTALL.md` Step 5 covers the untested toggle →
Save & Reboot flow, reload/chamber checks, direct soul/Wand grants, pawn-spawn
safety, and panel close/reopen behavior. It clearly marks unreliable or
unimplemented features **DO NOT TEST YET**.

Sandbox results after the Build-7 edits: parser 37/37; smoke test 37/37 for
both `all()` semantics under default Lua and LuaJIT 2.1. These checks are not
game evidence. `uplift({chamber_max=1})` and native-entity cleanup remain
especially dependent on the next live run.
