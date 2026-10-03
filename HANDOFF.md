# HANDOFF — Session 2026-10-03 (session 2, branch `arena/01a101d6-shotgun-king-anew`)

> **Purpose:** a fresh agent (or the owner after a break) can resume from this
> file alone. Read `PLANNING.md` for the full history; this is *current state*.
> Update this file at the end of every working session.

---

## 1. Project in one paragraph

Private, personal-use mod project for **Shotgun King: The Final Checkmate
v1.623b** (PUNKCAKE Délicieux). The game runs on **SUGAR** — the studio's
custom Pico-8-style Lua engine (LuaJIT 2.1 / Lua 5.1, SDL3) — **not Godot**.
Deliverable = a normal SGK mod (`modded/sk-rework/`) plus a toolchain that
builds a ready-to-play modded **copy** of the game. Goal list: ammo rework
(A→B→C), card picker, enemy picker, extra shot mechanics, balance knobs,
in-game dev-cheat panel, 100%-unlock save. The play path never patches game
files; "injection" = adding folders under `mods/` (the game's own mod system).

## 2. Where things are

| Thing | Location |
|---|---|
| Working branch | `arena/01a101d6-shotgun-king-anew` (push here; PR #1 already merged) |
| Our mod | `modded/sk-rework/` (info.lua + script.lua stub + cover.png) |
| 13 workshop mods, vendored, name-verified | `dist-overlay/mods/` |
| Tools | `tools/` (build-dist.ps1, install-mods.ps1, apply.ps1, save_codec.py, make_100pct_save.py, mod-dev.md, recover.md) |
| Knowledge | `notes/` (map.md = code map, mods.md = mod inventory + API, review-2026-10-03.md = pre-live-test review, changelog.md, data-sgr-filelist.txt) |
| Owner archives + extracted game + modding guide | `uploads/` (**gitignored**) — **NOT present in this session's sandbox**; lives on the owner's machine |
| Full extracted game | was `/tmp/skgame/…` — **gone** (ephemeral). Re-extract from owner's rars if needed |

## 3. Hard-won facts (do not re-derive)

1. **Mod folder name MUST equal `name=` in info.lua.** Mismatch = silent
   no-load. Mods must be unpacked folders — zips/rars in `mods/` are ignored.
2. **Mod API**: `append`/`prepend` any global game function (id-registered),
   `on_*` event callbacks, custom cards via `concat(CARDS, {...})` (fields
   incl. `pwe` = offer weight, `knockback`, `pierce`), custom modes in
   `modes/`, `gimme("global"|"replaceable"|"forbidden"|"autocall")`
   introspection, `_log()` → log.txt. Patterns confirmed in the vendored
   mods: `for k in all(gimme("global"))` yields global names;
   `for i,v in ipairs(MODLIST) do if v.title == "…"` finds your own mod.
3. **Save format** (`save/*.sav`): `[u32 BE plaintext length][zlib stream]`,
   payload `PUNKCAKE\nt{...}\nFOREVER`, no indentation, string values carry
   a trailing 0x1F. `tools/save_codec.py` parses/serializes **byte-identical**
   on all 6 real v1.623b saves (prior session). `make_100pct_save.py` =
   unlock-all (128 achievements, weapons 1–9, rank 20 + badges, endless
   floor 15 ⇒ chase unlocked, 164-card codex). Backups + `--restore`.
4. **No mod-enable state in saves** → mods in `mods/` are likely enabled by
   default; the in-game mod menu toggles them. *(Unconfirmed — live test.)*
5. **data.sgr** = 79 MB package with all 278 game files. Format undocumented;
   **decision: don't crack it** — runtime `gimme()` dump gives the same intel.
6. The analyzed game copy is a Goldberg-emu repack (owner's); Steam Workshop
   upload won't work there, modding works fine.
7. `King's Court` (owner's mods/) is a 2022 pre-info.lua legacy mod — won't
   load on v1.623b without a port.

## 4. Session 2 outcome (review → docs → fixes)

Owner asked: review before live testing (clone-vs-install ambiguity, low
confidence). Done in this session:

- **`INSTALL.md` (NEW) — the single canonical setup + live-test guide** for
  the owner's layout `E:\testing\{game, repo, ShotgunKing-Modded}`: steps 1–7
  with per-step checks, whole-repo download answer (there is no single-file
  patch), success checklist, live-testing vs roadmap boundary, undo table,
  troubleshooting, clearly-marked variations. README's step list is now only
  a summary that points here (no competing instructions).

- **`notes/review-2026-10-03.md`** — full readiness review: what each tool
  writes and how to undo it, verification status per artifact, risks, and the
  risk-ordered live-test ladder (now also the README quick-start).
- **README rewritten** — answers "does it patch my game or build a clone?"
  in the first screen, honest ✅/🟡/⛔ status table, dev roadmap demoted to
  a short pointer. Removed the "✅ shipped" overclaims.
- **Code fixes** (all covered by tests in the sandbox):
  - `make_100pct_save.py`: `throne` table could be dropped when absent
    (`setdefault` fix); friendly errors when `save/` or its files don't exist;
    `--restore` now works even if `save/` was deleted; backup path explicit.
  - `save_codec.py`: `--help` no longer treated as a filename.
  - `build-dist.ps1`: robust stray-archive filter (`-Include` + `-LiteralPath`
    grey zone removed); `PLAY-THIS.txt` now explains copy semantics + how to
    unlock the copy.
- **Verification run this session:** Python `py_compile`; 100% tool end-to-end
  on disposable synthetic saves (dry-run → write → value inspection →
  restore); regression test for the `throne` fix; all 3 `.ps1` parse clean
  under tree-sitter-powershell; all 14 mod folders re-checked
  `folder == name=`; `sk-rework/script.lua` compiles under Lua.

## 5. Current state & immediate next step

Same blocker as before, just better documented: **one live run by the owner**
(README §"First run", steps 1–4). Then upload `log.txt` (via
`apply.ps1 -GetLog`, or attach it in chat).

With that log: finish `notes/map.md` (exact ammo/damage/spawn functions), then
build the **dev-cheat panel** (Phase 2c) using native `mk_menu_but` UI, then
ammo rework A→B→C.

Highest-value work that is NOT blocked and is fully testable in-sandbox:
a **log.txt parser** (Python) that turns the `SKG|/SKR|/SKF|` dump into the
function map automatically — proposed next.

## 6. Owner (human) intervention points

- Run the live-test ladder and upload log.txt ← **only blocker**
- Playtest each phase build; report crashes (error text = END of log.txt)
- At deployment: flip repo private, optional git history scrub (old commits
  still contain the rars), or archive repo if abandoning

## 7. Environment quirks (this sandbox / Arena agent mode)

- **The platform may reset the local branch to the base commit between
  turns.** Working files survive; commits survive on the remote. Recovery:
  `git fetch origin && git reset --soft origin/arena/…` then `git reset`.
- Network: `git`/`api.github.com`/`pypi` reachable. **Blocked:** raw
  GitHub, GitHub release assets, Debian apt mirrors (apt install fails).
- **No `pwsh`** → PowerShell scripts are static-parsed (tree-sitter) but never
  executed here. Python 3.11 is available; `/tmp/skvenv` (lupa + tree-sitter)
  works and is ephemeral.
- `uploads/` is gitignored and **absent in this session** — docs referencing
  it describe the owner's machine.
- No unrar/7z preinstalled; unrar was compiled last session (that binary is
  in `uploads/tools/`, not in git).

## 8. Rules that still stand

- Never commit game assets or archives (`.gitignore` guards: *.rar *.zip
  *.exe *.dll *.sgr, uploads/, dist/, save_backup_/, __pycache__/).
- Workshop mods in `dist-overlay/` are mirrored for the owner's personal
  build (owner confirmed freely distributed); remove on author request.
- Mod code: additive hooks only, `-- SK-REWORK:` markers, stable hook ids,
  discoveries logged to `notes/map.md` immediately.
- Personal use only — nothing public.
