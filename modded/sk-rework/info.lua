name="sk-rework" -- must match this mod's folder name

title="SK Rework"
by="freeforall1932"
description=[[
SK Rework — Build 7 (run-5 absorbed: panel fix, damage/crit, ammo, dodge,
pickers). Build 6 ran live through gameplay on 2026-10-04 (run 5, ~22 min,
clean shutdown) and answered every open probe question.

DEV PANEL (SK DEV button, bottom-left of the board): +3 reserve ammo,
RELOAD the chamber (the global `reload`), CLIP+ (chamber_max, guessed field),
CARD:AUTO/LIST (auto = the game's own pick, LIST = browse every card and
take any of them; summon-family cards also bring their `allies` piece in),
SPAWN... (pick the piece; the square prefers a DIAGONAL neighbour so the
ally never blocks the king's 1-tile move), GOD (HP refill + Mist-style dodge
to a free square on a lethal hit), DMG on/off + DMG+ / CRIT+ (per-bullet
damage, crit chance, crit damage; pierce auto-crits while DMG is on), SAFE
(one engine-mutating action per boot) and CLOSE (uses the engine's own
remove_buts(); the panel rebuilds its header on the next turn).

Damage/crit values and the toggles persist in this mod's own bank save
(save/mods/sk-rework.bnk, format 128:64:4 hex; magic cell 505).

MOD MENU: adds a Back button and the WHITE=ON / BLACK=OFF legend on the
mod-list screen, using the real menu button ids harvested live in run 5
(mods / save_back / " ON " / "OFF ").

DIAGNOSTICS: full card fields and EXCLUDE pairs (SKCF|), offer flow (SKOF|),
souls/scepters/pieces (SKS|), damage/bullet/damage-roll route (SKD|),
input/`but` fields/menu IDs (SKI|), UI/config/bank state (SKUI|) and every
engine-mutating call (SKE|call|<name>=start before the call, =ok after).
Probe blocks run after READY and each one logs an SKA2|probe|<name>=done
checkpoint. GUESSED signatures are marked in the script and validated at
runtime, never called blind.
]]

cover="cover.png"

priority_hint=0

mode_description = {
}
