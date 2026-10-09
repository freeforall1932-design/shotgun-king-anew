name="sk-rework" -- must match this mod's folder name

title="SK Rework"
by="freeforall1932"
description=[[
SK Rework — Build 7 (live-test helpers + diagnostics). The Build 6 input
probe fix was confirmed live in Run 5; only engine-published button IDs are
used, avoiding the fatal unknown-button path.

DEV PANEL: native in-game controls for +3 reserve ammo, reload, +1 temporary
chamber capacity, a random eligible card, ally summon, and best-effort God
Mode (unreliable; DO NOT TEST YET).
TEST SOUL/WAND directly grants Majestic Censer and Wand of Souls so the owner
can exercise soul/scepter paths without waiting for a rare offer. Damage
multipliers and Mist-style lethal-hit escape are not implemented yet.

MOD MENU: the owner confirmed the Back button works in Run 5. Please also
check the WHITE=ON / BLACK=OFF legend and the save-and-reboot flow when a mod
is toggled. Existing load-order arrows are unchanged.

DIAGNOSTICS: full card fields and EXCLUDE pairs (SKCF|), offer flow (SKOF|),
souls/scepters/pieces (SKS|), damage/bullet route (SKD|), input/`but` fields/menu IDs
(SKI|), and UI/config state (SKUI|). Probe blocks run after READY and each
one logs an SKA2|probe|<name>=done checkpoint.
]]

cover="cover.png"

priority_hint=0

mode_description = {
}
