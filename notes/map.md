# notes/map.md — code map of Shotgun King (recovered source)

> Phase 1 deliverable. Fill this in by searching `game-dump/` — the game is the
> spec. Log every identifier the moment you find it. File paths are `res://`
> paths (relative to `game-dump/`).

**Game version recovered:** _(fill in after Phase 0)_
**Godot version:** _(from project.godot header)_
**Recovered on:** _(date)_

---

## Autoloads & scene tree (start here)

_(List every autoload from project.godot [autoload] section — these are the
global singletons: likely something like a game/board/pieces manager. Note what
scene each loads first.)_

| Autoload name | Script | What it owns |
|---|---|---|
| | | |

---

## Ammo / shells / shooting  (search: `ammo`, `shell`, `shot`, `reload`, `magazine`)

| Symbol | File | Function/line | What it does | Notes |
|---|---|---|---|---|
| | | | | |

Questions to answer:
- Where is the shell count stored (which node/script)?
- What function spends a shell? What refills it (per-move? per-kill? card)?
- Is there a magazine/reload concept at all, or one shared pool?
- Which numbers are hardcoded vs. set by cards?

## Cards / perks / drafting  (search: `card`, `perk`, `offer`, `choice`, `draft`, `pwe`)

| Symbol | File | Function/line | What it does | Notes |
|---|---|---|---|---|
| | | | | |

Questions to answer:
- Card data format (the `pwe` power-weight field = offer rarity, base 4)?
- Where is the "offer N cards after a floor" roll? How many are offered?
- Where do card effects get applied (stat block? signal? direct call)?
- Full roster location — needed for the "pick ANY card" picker.

## Enemies / spawning / floors  (search: `spawn`, `piece`, `enemy`, `floor`, `wave`, `board`)

| Symbol | File | Function/line | What it does | Notes |
|---|---|---|---|---|
| | | | | |

Questions to answer:
- Who decides which pieces spawn on a floor (roster + roll)?
- Piece base stats table(s) — hp, damage, movement?
- Floor/stage progression flow — where is "next floor" chosen?

## Damage / health / death  (search: `damage`, `hp`, `health`, `hit`, `die`)

| Symbol | File | Function/line | What it does | Notes |
|---|---|---|---|---|
| | | | | |

Questions to answer:
- One damage entry-point or several (pellet hit vs. enemy attack)?
- Where the king's HP lives → hook point for `damage_taken_mult`.
- Pellet/hit code location → hook point for knockback/pierce/bleed (Phase 5).

## Debug toolchain (Phase 2)

| Binding | What it does | Implemented in |
|---|---|---|
| F1 +ammo | | |
| F2 card list | | |
| F3 next-enemy cycle | | |
| F4 damage multipliers | | |

---

## Open questions / surprises

_(Anything weird found while reading. Date entries.)_
