#!/usr/bin/env python3
"""SK-REWORK 100% save generator — the "casual Sunday player" unlock-all.

For players who don't want to grind: writes a completionist save over your
current one (after backing it up). Unlocks:

  * every achievement (game keys + platinum + all 20 ranks)
  * every shotgun (weapons 2-9; weapon 1 is the default)
  * every mode unlocked (chase needs endless floor 15+)
  * throne rank 20, rank-20 badge for every shotgun
  * every card marked "played" in the codex — the complete live-verified set:
    186 cards from the game's own CARDS table (dumped by the diagnostics mod,
    live test run 2) PLUS the 9 special codex keys the game tracks outside
    CARDS (bleed, cloak, grenade, jump, leader, line, mission, orb,
    Unfaithful Steed) = 195 entries, exactly matching what the game itself
    writes to stats.sav

Note on the title screen showing "MODDED: ON - ACHIEVEMENTS: OFF": that is the
game's own label shown while any mod is ACTIVE - it pauses *Steam*
achievement tracking. The save-side achievements are unaffected: run 2's
harvested pack (fetched after a full modded session) still shows all 128
achievements True in the copy's save, and the game keeps its own one-generation
.sav.bak snapshots next to the saves it rewrites.

What it does NOT touch: your best times, run history, reg.sav (file
registry), misc.sav (codex layout). Your old save is backed up to
save_backup_<timestamp>/ next to the save folder.

Usage (works with stock python.org Python 3, no dependencies):
    python tools/make_100pct_save.py --game-dir "E:\\...\\Shotgun.King.The.Final.Checkmate.v1.623b"
    python tools/make_100pct_save.py --game-dir ... --dry-run   # show, don't write
    python tools/make_100pct_save.py --game-dir ... --restore   # restore newest backup
    python tools/make_100pct_save.py --game-dir ... --restore --dry-run  # preview restore

--game-dir points at the game folder whose save/ you want to change. To unlock
a modded copy built by tools/build-dist.ps1, pass that copy's folder:
    python tools/make_100pct_save.py --game-dir "dist\\ShotgunKing-Modded"

The game must have been launched (and closed) at least once so its save files
exist; the tool refuses with instructions otherwise. Game must NOT be running
while you write.
Format docs: tools/save_codec.py (parse/serialize verified lossless on all
six v1.623b saves). Live-tested 2026-10-03: the game accepted the save
(achievements/unlocks/codex showed up, and stayed unlocked after a full
modded session). Keep the backup habit anyway.
"""
import sys, os, shutil, datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from save_codec import load_save, save_save, b, n

ACHIEVEMENTS = ['ALEXANDER', 'ANARCHY', 'ARCHITECT_OF_RUIN', 'ASSASSIN', 'ATTILA', 'AVENGED', 'A_MIGHTY_FORTRESS', 'A_VELVET_GLOVE', 'BENEVOLENCE', 'BLITZ', 'BLOODBATH', 'BOUNDARIES', 'BUILDER', 'BULLET', 'BULLFIGHTING', 'BURIED_ALIVE', 'CINDERLORD', 'CLIFFHANGER', 'COLD_REGICIDE', 'COMPLETE', 'DANGEROUS_LIFE', 'DEATH_SENTENCE', 'DECEIVER', 'DELETED', 'DEMOLITION', 'DETENTION', 'DISCREET_HOST', 'DRAUGHTS', 'EMPEROR', 'END_OF_THE_WORLD', 'EXORCISED', 'EXPULSION', 'FINAL_ESCAPE', 'FIRST_AID', 'FULL_SET', 'GLUTTONY', 'HAREM', 'HASTA_LA_VISTA_BABY', 'HIDDEN_CONSPIRATOR', 'HIPPOCRACY', 'HOPE_THIS_HITS', 'HORSEMEN_OF_THE_APOCALYPSE', 'HOW_IT_SHOULD_BE', 'HUMILIATION', 'INCARNATION', 'INQUISITION', 'IRON_KING', 'JEALOUSY', 'KINDLED_ATROCITY', 'KING_WARBAND', 'LATE_TO_THE_PARTY', 'LEGION', 'LIFEGUARD', 'LIKE_FATHER_LIKE_SON', 'MACHINE_GUN', 'MAKEDA', 'MARITAL_PEACE', 'MERCIFUL_RULER', 'MIDNIGHT_DANCE', 'MMMMH_DELICIEUX', 'MOBILITY', 'MONTEZUMA', 'MORTAL_PERIL', 'MR_PRESIDENT', 'NEW_JOB', 'NIGHTMARE_ERA', 'NINE_LIVES', 'NINJA', 'OBSCURANTISM', 'OH_NO', 'OUT_OF_TIME', 'OVERPOPULATION', 'PLATINIUM', 'PROJECTILE_DYSFUNCTION', 'PUPPET_MASTER', 'RAMESSES_II', 'RELIGION', 'RICHARD_III', 'ROYAL_RETAINER', 'SCAVENGER', 'SECRET', 'SECURITY_SERVICE', 'SHE_IS_EVERYWHERE', 'SLAUGHTER', 'SNIPER', 'SOCIAL_DISTANCING', 'SOLOMON', 'SOVEREIGN_OF_THE_MASS_GRAVE', 'SQUARE_ALLEGIANCE', 'STARBURST', 'STEROID', 'SUICIDE_PACT', 'SURVIVOR', 'SWARM', 'SWORDMAN', 'THE_FLOOR_IS_LAVA', 'TRIGGER_HAPPY', 'UNDERPRESSURE_AMMO', 'UNEXPECTED_ENTRANCE', 'UNITED_HANDS', 'VICTORIA', 'WARDEN', 'WIDOW', 'WIZARD', 'WORKPLACE_ACCIDENT', 'YOUR_WIFE_MY_WIFE', 'YOU_SHALL_NOT_PASS', 'YVAN_IV', 'RANK_1', 'RANK_2', 'RANK_3', 'RANK_4', 'RANK_5', 'RANK_6', 'RANK_7', 'RANK_8', 'RANK_9', 'RANK_10', 'RANK_11', 'RANK_12', 'RANK_13', 'RANK_14', 'RANK_15', 'RANK_16', 'RANK_17', 'RANK_18', 'RANK_19', 'RANK_20', 'PLATINIUM']
CARDS = ['A Piercing Truth', 'Ambush', 'Ammunition Depot', 'Analysis Paralysis', 'Anarchy', 'Ancient Flagstone', 'Ascension', 'Assault', 'August Presence', 'Auto-da-fe', 'Backups', 'Bastion', 'Black Mist', 'Black Plague', 'Bloodless Coups', 'Blunderbuss', 'Bodyguard', 'Bold Plan', 'Bouncy Castle', 'Buckler of Limos', 'Bunker', 'Bushido', 'Caltrops', 'Cannon Fodder', 'Cardinal', 'Castle', 'Catacombs', 'Cathedral', 'Cavalry', 'Church Organ', 'Cloaking Device', "Commoner's Reign", 'Conclave', 'Conscription', 'Cornered Despot', 'Court of the King', 'Courteous Jousting', "Crow's Blessing", 'Crusades', 'Death Mark', 'Deep Water', 'Divine Healing', 'Egotic Maelstrom', 'Elite Gem', 'Elusive', 'Emergency Call', 'Engraved Scope', 'Entitle', 'Ermine Belt', 'Excommunication', 'Extra Barrel', 'Faithful Steed', 'Fallen Dynasty', 'Fearsome', 'Final Countdown', 'Flesh Wall', 'Fool Companion', 'Force-feeding', 'Full Plate Armor', 'Gatehouse', 'Genderqueer', 'Golden Aging', 'Governess', 'Gradual Absolution', 'Grindstone', 'Guerilla Tactics', 'Guillotine', 'High Focus', 'Highest Dungeon', 'Hired Blade', 'Holoking', 'Holy Gunpowder', 'Homecoming', 'Human Shield', 'Imperial Shot Put', 'Indelible Memories', 'Inquisition', 'Iron Maiden', 'Karma', "King's Look-alike", "King's Mistress", "King's Shoulders", 'Kingdom Wealth', 'Kingly Alms', 'Kite Shield', 'Knightmare', 'Lady in the Tower', 'Last Guardian', 'Late for dinner', 'Lightfoot', 'Lookout Tower', 'Low-Cost Disguise', 'Loyalist March', 'Majestic Censer', 'Mangonel', 'Mausoleum', 'Military Academy', 'Militia', "Monarch's Confidence", 'Mystic Shackles', 'Nightbane', 'Nomad Life', 'Oathkeeper', 'Onboarding Party', 'Patience', 'Peace', 'Philanthropy', 'Pikemen', 'Pillage', 'Plumed Knight', 'Possessed', 'Presbyopia', 'Prison', 'Pyre of Lust', 'Rapunzel', 'Ravenous Rats', 'Redemption', 'Reign of Terror', 'Remparts', 'Reverend Mother', 'Revolution', 'Right-hand', 'Rightful Curtsy', 'Ritual Dagger', 'Royal Loafers', 'Ruins', 'Saboteur', 'Sacred Crown', 'Sacred Light', 'Saddle', 'Sanctity', 'Sawed-off Justice', 'Scouting', 'Secret Move', "Seer's Orb", 'Selective Listening', 'Self-Defense', 'Shortage', 'Shovel', 'Shrapnel', 'Silencer', 'Small Fry Harvest', 'Small Key', 'Sokoban', 'Soul Projection', 'Sprint', 'Stoning', 'Subtle Poison', 'Succubus', 'Tag Team', 'Taunting Hop', 'Tearing Bullets', 'The Bridge', 'The Jester', 'The Moat', 'The Mole', 'The Red Book', 'The Royal Hunt', 'The Secret Heir', 'Theocracy', 'Throne Room', 'Tragic Homecoming', 'Trench War', 'Trowel', 'Undead Armies', 'Undercover Mission', 'Unholy Call', 'Unicorn', 'Unjust Decree', 'Unsettled Throne', 'Vampirism', 'Vendetta', 'Wand of Downpour', 'Wand of Execution', 'Wand of Frenzy', 'Wand of Gust', 'Wand of Hypnosis', 'Wand of Souls', 'Wand of Treachery', 'Wand of Wings', 'Wand of Wrath', 'Warhorse', 'Welcome Gift', "Witch's Curse", 'Workshop', 'Zealots']

# Special codex keys: tracked in stats.sav but NOT part of the game's CARDS
# offer table. Live test run 2 (2026-10-03, build 4 SKC| dump) proved the game
# itself writes exactly CARDS(186) + these 9 keys = 195 entries to stats.sav.
# The 8 lowercase ones are codex mechanic entries; 'Unfaithful Steed' is a
# variant of the regular card 'Faithful Steed'. Save keys are display names.
SPECIAL_CARDS = ['Unfaithful Steed', 'bleed', 'cloak', 'grenade', 'jump',
                 'leader', 'line', 'mission', 'orb']

WEAPONS = list(range(2, 10))       # 9 shotguns; 1 = default (no unlock key)
RANKS = 20                         # highest rank shown in game
ENDLESS_FLOOR = 15                 # chase mode unlocks at floor 15 in endless
REQUIRED_SAVES = ("achievements.sav", "prog.sav", "stats.sav")


def save_dir_for(game_dir: str) -> str:
    return os.path.join(game_dir, "save")


def require_saves(game_dir: str) -> str:
    """The save dir + the 3 files this tool edits must already exist."""
    save_dir = save_dir_for(game_dir)
    if not os.path.isdir(save_dir):
        raise SystemExit(
            f"no save/ folder inside {game_dir}\n"
            "  -> launch the game once and quit normally so it creates its "
            "saves, then re-run this tool.")
    missing = [f for f in REQUIRED_SAVES
               if not os.path.isfile(os.path.join(save_dir, f))]
    if missing:
        raise SystemExit(
            f"missing save file(s) in {save_dir}: {', '.join(missing)}\n"
            "  -> launch the game once and quit normally so it creates its "
            "saves, then re-run this tool.")
    return save_dir


def current_endless_floor(prog: dict) -> int:
    """Read only the numeric scalar shape verified in the game's prog.sav."""
    value = prog.get("endless", ("n", "0"))
    if not (isinstance(value, tuple) and len(value) == 2 and value[0] == "n"):
        raise SystemExit(
            "unsupported prog.sav schema: 'endless' is not a numeric scalar; "
            "no save files were changed. Keep a backup and verify this game "
            "version's save format before editing it.")
    try:
        return int(value[1] or 0)
    except (TypeError, ValueError):
        raise SystemExit(
            "unsupported prog.sav schema: 'endless' has an invalid numeric "
            "value; no save files were changed.")


def main(argv):
    if "--game-dir" not in argv:
        print(__doc__)
        return 1
    game_dir = argv[argv.index("--game-dir") + 1]
    if not os.path.isdir(game_dir):
        raise SystemExit(f"game folder not found: {game_dir}")
    dry = "--dry-run" in argv

    if "--restore" in argv:
        backups = sorted(d for d in os.listdir(game_dir)
                         if d.startswith("save_backup_"))
        if not backups:
            raise SystemExit(f"no save_backup_* folder found in {game_dir}")
        src = os.path.join(game_dir, backups[-1])
        dst = save_dir_for(game_dir)
        print(f"restoring {src} -> {dst}")
        if dry:
            print("(dry run - restore preview only; no files changed)")
            return 0
        if os.path.isdir(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        return 0

    save_dir = require_saves(game_dir)

    # Validate the one version-sensitive value before creating a backup or
    # writing any save, so unknown schema shapes fail closed without a partial
    # unlock operation.
    prog_path = os.path.join(save_dir, "prog.sav")
    prog = load_save(prog_path)
    cur_endless = current_endless_floor(prog)

    # ---- backup ----
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    bak = os.path.join(game_dir, f"save_backup_{stamp}")
    if not dry:
        shutil.copytree(save_dir, bak)
        print(f"backup  -> {bak}")

    # ---- achievements.sav: all bTrue ----
    p = os.path.join(save_dir, "achievements.sav")
    ach = load_save(p)
    for a in ACHIEVEMENTS:
        ach[a] = b(True)
    trues = sum(1 for v in ach.values() if v == ("b", True))
    print(f"achievements: {trues} set True")
    if not dry:
        save_save(p, ach)

    # ---- prog.sav: weapons, ranks, badges, endless floor ----
    p = prog_path
    throne = prog.setdefault("throne", {})   # F2: must exist in prog, not a copy
    unl = throne.setdefault("weapon_unl", {})
    for w in WEAPONS:
        unl[w] = b(True)
    badges = throne.setdefault("badges", {})
    for w in range(1, 10):
        badges.setdefault(w, {})["rank"] = n(RANKS)
    throne["rank"] = n(RANKS)
    prog["endless"] = n(max(ENDLESS_FLOOR, cur_endless))
    print(f"prog: weapons 1-9 unlocked, throne rank {RANKS}, all badges rank "
          f"{RANKS}, endless floor {prog['endless'][1]} (chase unlocked)")
    if not dry:
        save_save(p, prog)

    # ---- stats.sav: every card seen & played (codex 100%) ----
    p = os.path.join(save_dir, "stats.sav")
    stats = load_save(p)
    all_cards = CARDS + SPECIAL_CARDS
    for c in all_cards:
        e = stats.get(c)
        if e is None:
            stats[c] = {"ignored": n(0), "played": n(1)}
        elif e.get("played", ("n", "0"))[1] == "0":
            e["played"] = n(1)
    print(f"stats: {sum(1 for c in all_cards if c in stats)}/{len(all_cards)} "
          f"cards in codex (incl. {len(SPECIAL_CARDS)} special cards)")
    if not dry:
        save_save(p, stats)

    if dry:
        print("(dry run - nothing written)")
    else:
        print("done. Start the game - everything should be unlocked.")
        if os.path.isdir(os.path.join(game_dir, "mods")):
            print("note: while a mod is ACTIVE the title bar says 'MODDED: ON -")
            print("      ACHIEVEMENTS: OFF'. That pauses Steam achievement tracking")
            print("      only - the achievements in this copy's save stay unlocked")
            print("      (live-verified run 2: all 128 still True after a modded session).")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
