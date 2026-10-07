# Comprehensive Audit Review: Shotgun King: Reworked
**Repository:** https://github.com/freeforall1932-design/shotgun-king-anew  
**Audit Target:** Mod Build 9, Toolchain, Save System, and Decoded SUGAR Engine Integration  
**Date:** 2026-10-06  
**Auditor:** Automated Engine & Code Verification Suite  

---

## 1. Executive Summary

This audit examined the entirety of `shotgun-king-anew` (v1.623b target), including:
- `modded/sk-rework/script.lua` (Build 9 overlay dev panel, mod menu, and probes)
- `tools/build-dist.ps1`, `tools/apply.ps1`, `tools/install-mods.ps1` (PowerShell mod & copy pipeline)
- `tools/save_codec.py` & `tools/make_100pct_save.py` (PUNKCAKE serializer & 100% unlocker)
- `tools/parse_log.py` & `tools/mod_smoketest.py` (Forensics parser & testbench)
- 13 vendored workshop mods in `dist-overlay/mods/`
- Decoded SUGAR game engine source (`game/decoded/code.lua`, `code/mods.lua`, `code/menu.lua`)

While the project has achieved remarkable milestones (reverse-engineering the PUNKCAKE save format, decoding `data.sgr`, creating dependency-ordered mod lists), this audit identified **8 critical/high-severity defects**, **missing logic implementations**, and **misaligned contracts** that cause runtime failures or desynchronization.

---

## 2. Defect & Misalignment Matrix

| Issue ID | Severity | File | Affected System | Summary |
|---|---|---|---|---|
| **SEC-01** | **CRITICAL** | `tools/build-dist.ps1` | PowerShell Builder | Robocopy bitmask return codes (1..7) trigger fatal script exit under `$ErrorActionPreference="Stop"` / PS7 |
| **SEC-02** | **HIGH** | `modded/sk-rework/script.lua` | Mod Menu Sync | `modlist_changed()` checks undefined `mod.loaded` field, locking Back button to "Save and Reboot" on clean boot |
| **SEC-03** | **CRITICAL** | `modded/sk-rework/script.lua` | God Mode Dodge | Fallback directly mutates `hero.sq.px`, corrupting the shared 8x8 spatial grid and desyncing piece tables |
| **SEC-04** | **HIGH** | `tools/build-dist.ps1` / `install-mods.ps1` | Zip Extractor | Flat workshop zips cause `$info.Directory == $stage`, resulting in directory self-move lockouts |
| **SEC-05** | **MEDIUM** | `modded/sk-rework/script.lua` | Dev Panel Card List | Toggling `FILT:PIECE` on page > 2 does not reset `card_page`, rendering a blank screen |
| **SEC-06** | **MEDIUM** | `tools/save_codec.py` | Save Codec | `--pack` compresses raw text without PUNKCAKE syntax validation, allowing corrupted saves |
| **SEC-07** | **MEDIUM** | `tools/make_100pct_save.py` | Unlock Tool | Inactive check for dictionary-formatted `prog["endless"]` throws `KeyError: 1` on active saves |
| **SEC-08** | **HIGH** | `modded/sk-rework/script.lua` | Ability System | Right-click ability cap removal (§0.7.6) is missing active override logic; `is_card_available` remains probe-only |

---

## 3. Detailed Technical Analysis

### 3.1 PowerShell Execution Engine (SEC-01 & SEC-04)
- **Robocopy Return Code Trapping:** Robocopy returns a bitmask where values 1 through 7 represent copy successes (e.g. 1 = files copied, 2 = extra files detected). PowerShell terminates execution when external binaries return non-zero under modern error preferences. Furthermore, $LASTEXITCODE retains 1 across functions, causing step 4/4 to falsely report failure.
- **Flat Zip Archive Expansion:** In `build-dist.ps1` lines 145-165, `Expand-Archive` extracts into `$stage`. When a mod zip does not nest files in a folder, `$info.Directory.FullName` resolves to `$stage`. The subsequent `Move-Item -LiteralPath $info.Directory.FullName` attempts to move the root staging directory, colliding with the cleanup hook.

### 3.2 SUGAR Engine Integration (SEC-02 & SEC-03)
- **Engine Mod Object Schema:** In `game/decoded/code/mods.lua`, the engine populates `MODLIST` with `{ title, num, folder, active, desc }`. It does NOT populate `loaded`. The expression `(mod.loaded and true or false)` evaluates to `false` in Lua for all active mods, breaking `modlist_changed()`.
- **Spatial Grid Pointer Architecture:** The SUGAR engine maintains board tiles as shared singleton tables in `board[y][x]`. Moving a piece requires clearing `old_sq.piece = nil`, setting `hero.sq = new_sq`, and `new_sq.piece = hero`. Mutating `hero.sq.px = sq.px` modifies the coordinates of the old square object directly, corrupting `gsq(x, y)` lookups.

### 3.3 Missing Feature Logic (SEC-08)
- In `PLANNING.md` §0.7.6, the owner specified: *"Right-click ability cap removal — own multiple abilities, soft-coded discovery of all active-ability cards"*. In Build 9, `is_card_available` was only hooked as a telemetry probe. An active `prepend("is_card_available")` hook is required to uncap active ability offers.

---

## 4. Verification & Testing

Every defect in this review was proven through:
1. Static contract verification against the decoded game engine source (`game/decoded/`).
2. Execution of test harnesses (`tools/mod_smoketest.py`, `save_codec.py --selftest`).
3. Empirical script runs simulating PowerShell 7 and Lua 5.1 / LuaJIT 2.1 environments.

Refer to `PROOF_AND_VERIFICATION.md` for exact reproduction traces and formal proofs.
