name="sk-rework" -- must match this mod's folder name

title="SK Rework"
by="freeforall1932"
description=[[
SK Rework — Build 8 (run-6 absorbed; first build written against the
decoded game source). The dev panel is now an overlay that owns no engine
buttons, so a click on it can never move the king or end your turn.

DEV PANEL: click the small "SK DEV" tab in the bottom-left corner. A box
opens over the board, like the card-choice screen. While it is open every
click belongs to the panel; click outside the box or CLOSE to return to the
game. Page 1: +3 AMMO (reserve), RELOAD, CLIP+ (chamber_max), SAFE,
CARD:AUTO/LIST, CARD NOW, CARDS > (browse and take any card, FILT:PIECE for
piece/summon cards), SPAWN > (pick an ally piece; the square prefers a
DIAGONAL neighbour), GOD (HP refill + Mist-style dodge on a lethal hit), DMG
on/off, DMG+ and CRIT+ (the labels show the current values). Labels update
live after every click. The panel hides itself during card choices, the
pause menu and game over, and comes back on every new run.

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
