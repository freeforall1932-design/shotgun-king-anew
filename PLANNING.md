# Shotgun King — Ammo & Gameplay Rework: Planning + Agent Handoff

> **This file is a take-away.** It was written during the SkyCraft-fork port session
> (2026-10-02) and does NOT belong in the SkyCraft repo. Copy it to the new
> Shotgun King mod repo, then delete it from the fork. It is written to be fully
> self-contained: a fresh agent with zero prior context should be able to work
> from it.

---

## 0.6 Owner decisions (2026-10-03, Q&A)

1. **Ammo rework: ALL designs, progressive** — ship **A** (simple scale)
   first as the safe quick win, layer **B** (shell economy) on top once A is
   playtested, experiment with **C** (shell types) + future content after.
2. **UI principle: native-feel.** Any mod UI (buttons, pickers, cheat panel)
   must reuse the game's own button/menu code (`mk_menu_but`, `on_menu_but_init`,
   `init_menu` patterns from the reference mods) so it feels like part of the
   game, not an overlay.
3. **Built-in dev/cheat mode** (owner request): in-game cheats "as if the dev
   was playing" — give ammo/cards, god mode, spawn pieces — plus **save
   modification** tooling (save/*.sav are PUNKCAKE-serializer text; samples
   kept in uploads/game-extracted-lite/save/). Phase 2 scope now includes a
   dev panel; save tools may be a python script (tools/) and/or in-game.
4. **Motivation context:** stock game feels boring without working mods — so
   the 13 workshop mods must load reliably (`tools/install-mods.ps1`) and the
   dev-cheat panel is high priority, not a luxury.
5. **Visibility:** repo stays public while in development; flips to private
   at deployment (or gets archived if abandoned). Game rars were removed from
   the branch 2026-10-03 (they remain in git *history* until scrubbed — do a
   history rewrite or delete the repo at deployment if concerned; `main`
   still holds part4 + the 13 mod zips until the owner deletes them via web
   UI or the private flip happens).

## 0.7 Owner decisions (2026-10-04, run-3 follow-up)

> **Where this work happens:** these specs are implemented via the queue in
> `WORKLIST.md` → "🟠 Next features". Build 6's safe input-probe fix and
> runtime diagnostics were confirmed live in Run 5. The current working tree is
> Build 7 (not yet live-tested): focused test controls, direct soul/Wand card
> grants, and panel cleanup. Follow `INSTALL.md` Step 5 before treating any
> Build-7 behavior as game-verified. Remaining feature work follows the live
> evidence in `notes/map.md`; overall live-test status is in
> `live testing result/SUMMARY.md`.

6. **Right-click ability cap — REMOVE it** (owner's refined description,
   2026-10-04): right-click is ONE button, so vanilla lets you hold only
   ONE right-click ability — take the scope/snipe card and Seer's Orb (and
   every other right-click card) is never offered again, "like dev
   preventing the player from making a dumb decision… or maybe they were
   too lazy to implement button assignment, or for balance". Better Codex
   (vendored `show exclude` mod) documents the vanilla caps verbatim:
   *"You can't have more than: 1 right-click ability, or 5 soul slots, or
   3 scepters"* (plus other offer rules: no 0 max ammo, no grabbing+blade
   together, …). **Owner clarification #2 (2026-10-04): the right-click
   skill cards are NOT just snipe + orb — e.g. Unjust Decree fires the
   whole magazine in 1 turn as a right-click skill. Owner confirms the 10
   `special=` cards probably cover ALL right-click abilities in v1.623b
   (the dynamic scan stays the design anyway — future versions, modded
   cards). The system must be DYNAMIC and SOFT-CODED: discover every
   active-ability card at runtime (incl. cards other mods add via
   `concat(CARDS, …)`), no hardcoded list, no fixed count — "universal
   soft coded adaptable as I play".**
   Owner's expected bindings (NOT caps): right-click + 2 side mouse
   buttons + optional middle/wheel click ≈ 3–4 simultaneously bound,
   reassignable via the remap menu; more abilities than buttons →
   swap/cycle UI. **Scepter cap (3): owner said relax it too** — scepters
   unify into the same dynamic active-ability pool. Run 4 showed `scepters`
   is not a global (only replaceable) and that the scepter API is
   `add_scepter`/`activate_scepter`/`recal_scepters`/`get_scepter`; Run 5
   observed soul-slot/soul additions and `get_scepter`, but not either
   activation. Build 7 grants Wand of Souls directly for a deterministic test;
   its live behavior is still unverified. Goal: own MULTIPLE right-click
   abilities + pick which one each button triggers (remap-menu binding /
   SPECIAL_BUTTON interception).
8. **Soul-system rework** (owner, 2026-10-04): souls turn the king into a
   piece and let him move like it for 1 turn. Vanilla slots: max 5, grown
   via `soul_slot=N` cards (Majestic Censer +1, Possessed +2 w/
   `need_card`, Succubus +1); `hero.free_souls` = empty slots (live-seen).
   Separate summon-family cards bring temporary ALLY pieces for the
   current floor only (reset on floor change / run restart — the ext=3
   block: Right-hand, Warhorse, Onboarding Party, Rapunzel, Small Key;
   hologram cards: Holoking, Soul Projection). **Owner's modded vision
   ("like a Yu-Gi-Oh deck"): 2–3 soul slots where ONE slot holds MANY
   souls — freely use or exchange any stored soul at any time during the
   stage. NO hardcoded pawn exclusion (owner correction 2026-10-04:
   pawn-as-power comes from skill cards — pawn souls become bullets that
   each deal 1 damage — so the behavior must stay CARD-DRIVEN, not a
   baked-in exception; any soul is allowed in the deck).** Owner's open
   question (2026-10-04): does a stored pawn soul feed POWER or turn the
   king into a pawn? Answer plan: the power route is card-driven
   (`pawn_shell=1` Small Fry Harvest, `pawnreap=1` Cannon Fodder); whether
   the movement route also accepts pawn still needs a targeted soul activation
   test — and the deck UI will expose whichever routes the game actually
   supports (choice if both), never a hardcoded pick. Run 5 did not activate a
   soul. Build 7 adds
   a direct Majestic Censer grant so soul-slot and activation checks do not
   depend on a rare card offer; the owner still needs to collect a soul in-play.
   API:
   `add_soul(type, p, sanctity, replace)`, `activate_soul`,
   `stack.replace_soul`, `PIECES_NAMES[x].type`; summon blueprint =
   disgraced_justice's `dj_summon` (`new_piece(typ, false, sq)` +
   `fx_spawn(p)` + a hero cost field). **Summon cap (owner, 2026-10-04):
   none beyond board capacity — "as much as the board game can hold, like
   a normal game of chess"** (free squares are the limit; still per-floor
   temporary).
11. **Bullet damage & crit system** (owner, 2026-10-04): per-bullet damage
   configurable (vanilla = 1 per bullet; `firepower` is the damage stat on
   cards); **crits** — a crit probability and a crit damage value, both
   configurable (crit may exceed 2 damage); **pierce auto-crits by
   default** — `pierce` is a percentage status (`stack.pierce`, e.g.
   A Piercing Truth `pierce=30`), and piercing shots crit unless the
   player changes the rule. All knobs live in the cheat panel / balance
   config (persisted via the mod's own save slot) — nothing hardcoded.
   Known pipeline: shot modifiers are `stack.pierce` / `stack.blade` /
   `stack.knockback` / `stack.fearsome` with display priority
   `jump > fearsome > blade > pierce > knock > f_arc` (glac terminal's
   `get_disp_stats` interception); Run 5 captured 12 `fire` calls, 48 bullet
   samples, and 30 `hit` samples (`dmg=1`, `pierce=0`). That establishes an
   observable ordinary shot/hit route, but does not yet prove a safe multiplier
   insertion point or all damage sources. Damage/crit controls remain unimplemented.
7. **Card picker — free choice instead of the 2-card offer** (already
   Phase 4; owner re-confirmed). Reference implementation exists in the
   vendored **Royal Card Lab** ("unlimited mode"): it wraps each offer
   button's handler via the `on_card_but_init(but, ca)` callback and
   rebuilds the offer list from `get_slot_cards(true)`. Run 5 exercised the
   existing random-card debug action; the free-choice picker itself remains
   unimplemented.
8. **Infinite soul card** (new): a card that, once owned, lets the player
   switch souls freely and infinitely during the current stage — like a
   skill card but reusable — **any soul, including pawn, is allowed**. Pawn
   behavior stays card-driven (pawn-as-power is defined by skill cards, not
   a hardcoded soul-deck exception). Souls = piece types; API seen in mods:
   `add_soul(type, …)`, `activate_soul` (global), `stack.replace_soul`
   (glacies collection `effects.soul`). The Run-5 probe ran, but the owner did
   not use a soul card or activate a soul. Build 7 directly grants Majestic Censer and
   Wand of Souls to enable a deterministic live test; multi-soul behavior and
   activation/cooldown are still open.
9. **Full button-remap menu** (owner chose this over a fixed binding):
   in-game settings panel assigning any action to any extra mouse button
   (owner mouse: 2 side buttons + middle click). Mods can read/wrap
   `but.left_clic` / `but.right_clic` and query `btn("unsafe")`. Run 5
   published `m:lb`, `m:rb`, `m:mb` plus axes; it did not publish mouse4/5 or
   wheel IDs. Full remapping remains unimplemented; never probe guessed names
   because an unknown `btn()` ID is fatal.
10. **Mod-menu Back button + legend**: the owner confirms Back worked in
    Run 5; the missing `SKUI|menu|widgets_added` marker is not evidence that it
    failed. The legend's visibility still needs confirmation. Run 5 did not test
    toggling a mod and using Save & Reboot; Build 7's checklist covers that
    flow explicitly. Keep the native Back control in place.

## 0. What this project is

**Game:** Shotgun King: The Final Checkmate (PUNKCAKE Délicieux) — a 2D roguelike
where you are a shotgun-wielding chess king fighting chess-piece enemies across
floors, drafting perk **cards** after each floor. Ammo (shells) is a core resource.

**Goal of this mod (owner's side project):**
1. Rework the ammo system (how ammo is gained, spent, capped, reloaded)
2. Card picker: manually pick any card (or let the game pick at random from ALL cards)
3. Enemy picker: manually pick or randomize the enemies that spawn
4. Stretch: add new shot mechanics — knockback, pierce, bleed, and similar
5. Balance knobs: incoming/outgoing damage multipliers (difficulty scaling)

**Not a port project.** Nothing here bridges to Minecraft/other games — that's the
SkyCraft fork's business (see §7). This is a standalone single-player game mod.

## 1. Engine and packaging reality (correction to the initial research)

The original 2026-10-02 notes below this section were written before the game
archive was inspected and incorrectly assumed Godot, GDScript, a recoverable
`.pck`, and a repack pipeline. **Those assumptions are obsolete.** Live
inspection identifies Shotgun King v1.623b as a custom **SUGAR** Lua engine
(LuaJIT 2.1 / Lua 5.1), with the game's supported `info.lua` mod-folder
loader. This project adds an ordinary mod under `mods/` and builds a separate
game copy; it does not decompile, patch, or repack the executable or `data.sgr`.

Current, evidence-based development instructions live in `README.md`,
`INSTALL.md`, `HANDOFF.md`, and `tools/mod-dev.md`; the live API map is
`notes/map.md`. Do not follow any old Godot/pck/repack instructions retained
below for historical context.

## 2. Original repo scaffold plan (implemented; current tree is in README.md)

```
shotgun-king-rework/          (private; never publish game assets)
├── .gitignore                # uploads/, game-dump/, repacks/, *.pck, *.rar
├── PLANNING.md               # this file
├── README.md                 # how to build/install (written in Phase 0)
├── tools/
│   ├── recover.md            # get the game running + (optional) source extraction
│   ├── mod-dev.md            # the mod build/test loop (NEW — replaces repack)
│   └── apply.ps1             # copy modded/sk-rework/ into <game>/mods/
├── uploads/                  # IGNORED BY GIT — owner's game+mods archives, modding-guide clone
├── modded/sk-rework/         # OUR MOD — info.lua, script.lua, modes/ (the deliverable)
└── notes/
    ├── map.md                # code map: which globals/functions own ammo/cards/spawns
    ├── mods.md               # the 13 workshop mods inventory + API knowledge
    └── changelog.md          # what we changed and why
```

Rules: **game files and other people's mods never get committed** (creator's
IP + updates invalidate them). Everything we build lives in `modded/sk-rework/`
as a normal SGK mod, so installing = copying one folder.

## 3. Agent instructions

### 3.1 What the agent needs from the human (intervention points)

| # | Need | When | Example |
|---|---|---|---|
| 1 | **The game's installed files** (Steam → right-click game → Manage → Browse local files), or at least the game's `.pck` / exe path | Phase 0, before anything runs | `D:\SteamLibrary\steamapps\common\Shotgun King\` |
| 2 | **A backup of the original `.pck`** (or the agent makes one and reports where) | Phase 0 | `ShotgunKing.pck.orig` |
| 3 | **The creator's sample mod / the downloaded mod that fails to load** | Optional, Phase 1 — diffing it against recovered files may reveal loader expectations | the mod zip/folder the owner already has |
| 4 | **Design decisions** when a phase offers options (e.g., which ammo design from §5) | Before implementing that phase | "pick design B" |
| 5 | **Playtesting** the repacked build and reporting back (agent cannot play) | End of each phase | "repack crashed after intro" / "feels right" |

If items 1–3 are missing, **stop and ask**. Everything else is autonomous.

### 3.2 What the agent can do fully autonomously

- Run recovery, open the project, read and search all scripts
- Produce `notes/map.md` (the code map) without any human input
- Implement features once their design is chosen (or choose sensible defaults
  and flag them as reversible)
- Add debug tooling (an autoload with F-keys) — always additive
- Repack, and run the game headless just far enough to catch script errors
  (`godot --headless --check-only` style validation where possible)
- Update `notes/changelog.md` and this file's phase checkboxes

### 3.3 Hard blockers (stop, report, wait for human)

- Recovery fails (encrypted pck, unknown Godot version, stripped scripts)
- The game updates and file structure shifts → re-run recovery, re-apply,
  report what broke
- A wanted feature turns out to need asset (art/audio) work the agent can't do
- Any temptation to redistribute game assets — never; personal use only

### 3.4 Working rules

1. **Additive over invasive**: prefer a debug autoload that calls existing
   functions over rewriting their code. Survives updates.
2. Never delete original logic — comment it out with a `# SK-REWORK:` marker.
3. Every change lands in `modded/` with the same `res://` path.
4. Note every discovered identifier in `notes/map.md` as you find it.
5. The game is the spec: read how PUNKCAKE did it before redesigning it.

## 4. Phase plan

- [ ] **Phase 0 — Setup & recovery.** Get game files (human), back up `.pck`,
      run `gdre_tools --headless --recover=...`, open in Godot editor, run from
      source with F5 to prove the loop works. Write README + tools/*. Deliverable:
      a running-from-source game.
- [ ] **Phase 1 — Recon (no code changes).** Find and document in `notes/map.md`:
      - ammo: search `ammo`, `shell`, `shot`, `reload`, `magazine`
      - cards: search `card`, `perk`, `offer`, `choice`, `draft`, `pwe`
      - enemies/spawns: search `spawn`, `piece`, `enemy`, `floor`, `wave`, `board`
      - damage: search `damage`, `hp`, `health`, `hit`, `die`
      Deliverable: the code map, including exact file + function names.
- [ ] **Phase 2 — Debug toolchain.** Autoload singleton with F-keys:
      F1 +ammo, F2 open card list, F3 next-enemy cycle, F4 damage multipliers.
      This is also the delivery vehicle for the pickers.
- [ ] **Phase 3 — Ammo rework.** Implement the chosen design (§5 options).
- [ ] **Phase 4 — Pickers.** Card picker (manual list + pick_random from all +
      ban list) and enemy picker (choose next floor / random from full roster).
- [ ] **Phase 5 — New mechanics** (each: locate pellet/hit code → extend):
      knockback (impulse on hit piece), pierce (pellet continues through),
      bleed (DoT status on pieces), then the rest of §5's menu as desired.
- [ ] **Phase 6 — Balance & packaging.** Damage in/out multipliers as config;
      final repack; install instructions; warning about Steam verify.

## 5. Design menu (owner picks, agent can default)

**Ammo rework options:**
- A. Simple scale: more starting shells / bigger magazine / cheaper reload
- B. Economy: shells as floor resource — earn per kill, spend per shot, pickups
- C. Shell types: buckshot default + special shells (pierce, explosive...) on
  cooldown or found — pairs naturally with Phase 5 mechanics

**New mechanics menu (each is a pellet/hit-code extension):**
knockback, pierce, bleed (DoT), ricochet (walls), leech (heal on hit),
explosive rounds, tighter/wider spread cards, chain hits, freeze/slow,
execution threshold (bonus dmg below X% hp).

**Balance knobs:** `damage_taken_mult`, `damage_dealt_mult` as exported vars or
a config file — the "lore-accurate power balancing" idea from the session,
applied here.

## 6. Optional Cheat Engine recon (only if source is confusing)

Run the STOCK game, attach CE, scan for the shell count: shoot → "decreased
value" → repeat until 1 address. That tells you the variable's runtime name/
role; then find the same variable in recovered source. Discard CE after —
it is not part of the mod.

## 7. Session handoff — SkyCraft-fork port session, 2026-10-02

Origin of this file: a SkyCraft (Skyrim↔Minecraft bridge) fork session that
spawned several side-questions. Its initial Godot/source-recovery assumption
was incorrect for Shotgun King; the correction is recorded in §1 above. The
remaining cross-project scope notes are retained as history:

- **Volatile memory is a host-process property** (ASLR); editing files at rest
  has none of those problems.
- The other threads of that session (PS2 bridge route, IW4L/MW3, FPS-to-FPS
  loadouts, game↔game bridging) live in the SkyCraft fork under
  `port/notes/` and are NOT part of this repo's scope.

SkyCraft session state at handoff: branch `arena/01a0fb2f-skycraft-fork`,
fork point `bfcaf17` (SkyCraft 0.1.2, level with upstream at that date),
`port/` folder with README (sync rules), PLAN.md (target-game selection
pending) and notes: repo-map, integration-menu, ps2-route, side-projects
(this file's sibling). Reference notes by filename, not commit hash.

## 8. Command cheat sheet

```bash
# 2026-10-03: gdre/godot commands below are OBSOLETE (engine is SUGAR, not
# Godot — see §1). Kept for history only.

# OLD (void): gdre_tools --headless --recover=... ; godot --export-pack ...

# NEW pipeline:
#   1. install game, put owner mods in <game>/mods/<folder>   (tools/recover.md)
#   2. develop: edit modded/sk-rework/* → pwsh tools/apply.ps1 → run game
#      (tools/mod-dev.md)
#   3. debug: read <game>/log.txt + crashlog; use _log() and gimme() in-mod
#   4. share (optional): in-game mod menu → type UPLOAD → Steam Workshop
```

*Written 2026-10-02. Delete from the SkyCraft fork once copied to its own repo.*
