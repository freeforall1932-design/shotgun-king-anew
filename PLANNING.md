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
> `WORKLIST.md` → "🟠 Next features". Order: **sk-rework build 5 first**
> (Phase 2c cheat panel + mod-menu legend/Back button + the §0.7 intel
> probes — offer roll, full card fields, scepters, soul flow, damage point,
> input space), then the cap removal + bindings, card picker, soul deck,
> crit system, and remap menu on top of that panel. Live-test status of
> every ask: `live testing result/SUMMARY.md`.

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
   unify into the same dynamic active-ability pool. Build-5 probe still
   dumps all card fields + the `scepters` global (what scepters are and
   how they activate is still unknown). Goal: own MULTIPLE right-click
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
   the movement route also accepts pawn is a build-5 probe — and the deck
   UI will expose whichever routes the game actually supports (choice if
   both), never a hardcoded pick. API:
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
   `get_disp_stats` interception); damage globals to probe: `ev_hit`,
   `damage`, `damages`, `fx_dmg`, `bleed_dmg`, `hop_dmg` → build-5 probe
   pins the exact hit/damage application point.
7. **Card picker — free choice instead of the 2-card offer** (already
   Phase 4; owner re-confirmed). Reference implementation exists in the
   vendored **Royal Card Lab** ("unlimited mode"): it wraps each offer
   button's handler via the `on_card_but_init(but, ca)` callback and
   rebuilds the offer list from `get_slot_cards(true)`.
8. **Infinite soul card** (new): a card that, once owned, lets the player
   switch souls freely and infinitely during the current stage — like a
   skill card but reusable — **except the pawn soul** (pawn = power/ammo
   economy; cf. vanilla "Low-Cost Disguise" that disguises as a white pawn
   for 3 turns). Souls = piece types; API seen in vendored mods:
   `add_soul(type, …)`, `activate_soul` (global), `stack.replace_soul`
   (glacies collection `effects.soul`). Needs the soul system dumped
   (which souls exist, activation cooldown) → probe in the next build.
9. **Full button-remap menu** (owner chose this over a fixed binding):
   in-game settings panel assigning any action to any extra mouse button
   (owner mouse: 2 side buttons + middle click). Mods can read/wrap
   `but.left_clic` / `but.right_clic` and query `btn("unsafe")`; no mod
   touches mouse4/5 or middle click yet → feasibility probe needed (dump
   the `MOUSE` global, `but` table fields, `btn()` argument space).
10. **Mod-menu Back button** (confirmed): the vanilla mod menu only offers
    reset / save+reboot; add a Back button via the same UI-hook route as
    the white/black legend line (Phase 2c).

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

## 1. Verified findings (2026-10-02 research — do not re-research)

- The game is a **Godot engine** game (2D). Everything ships in a `.pck` package
  (or embedded in the exe).
- **Full source recovery is possible**: [gdsdecomp / Godot RE Tools](https://github.com/GDRETools/gdsdecomp)
  (4.3k★, supports Godot 2.x–4.x) performs *full project recovery*: decompiles all
  GDScript to readable source, restores resources, recovers the project file.
  One command: `gdre_tools --headless --recover=game.pck`
- **The game has an official-ish mod system** (Steam community guide id 2955710278,
  "SGK Modding"). Mods are folders loaded by the game's own loader; the guide
  documents a `load_mod("name")` call that must be registered in the right place
  for some mod types (throne mods), and card data files with a `pwe` field
  (power weight; base 4 if unspecified) controlling offer rarity.
- **Known failure modes of the stock mod loader** (why the owner's downloaded mod
  may not load): missing `load_mod()` registration, wrong folder name/structure,
  mod built for a different game version, resources loaded too late (Godot
  preloads), or Godot's `load_resource_pack` replace-flag behavior.
- **Decision made this session: bypass the mod loader entirely.** Edit the
  recovered game files directly and repack. This sidesteps every loader quirk
  above. Trade-off: Steam "verify integrity" and game updates revert changes —
  always keep the original `.pck` backed up, and keep OUR changes in a separate
  patch-repo structure so they can be re-applied after any update.
- **No runtime memory work needed.** The owner's original worry ("volatile
  memory") does not apply: we edit GDScript at rest, we never chase pointers.
  Cheat Engine is NOT part of the pipeline (optional 10-min recon on the stock
  game only, see §6).
- **Crash signature** (from the official guide): if the game crashes *after the
  Sugar intro but before the PUNKCAKE Délicieux intro*, the cause is almost
  always a **syntax error in a script file**. Check that first on any crash.

## 2. Repo structure to create (the new repo)

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
spawned several side-questions. Relevant outcomes for THIS project:

- **Godot games are among the easiest mod targets that exist** (full source
  recovery via gdsdecomp) — that's why this project is file-editing, not
  memory-patching.
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
# Godot — see §0.5). Kept for history only.

# OLD (void): gdre_tools --headless --recover=... ; godot --export-pack ...

# NEW pipeline:
#   1. install game, put owner mods in <game>/mods/<folder>   (tools/recover.md)
#   2. develop: edit modded/sk-rework/* → pwsh tools/apply.ps1 → run game
#      (tools/mod-dev.md)
#   3. debug: read <game>/log.txt + crashlog; use _log() and gimme() in-mod
#   4. share (optional): in-game mod menu → type UPLOAD → Steam Workshop
```

*Written 2026-10-02. Delete from the SkyCraft fork once copied to its own repo.*
