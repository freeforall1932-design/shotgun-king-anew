name="sk-rework" -- must match this mod's folder name

title="SK Rework"
by="freeforall1932"
description=[[
SK Rework — Build 6 (Phase 2c + diagnostics). Build 5 crashed at boot in
the input probe; build 6 only probes engine inputs the game itself has
published, so it cannot hit the fatal unknown-button path.

DEV PANEL: native in-game buttons for +ammo, a random eligible card, an
ally summon, and a God Mode toggle. The damage-multiplier control is
intentionally gated until the live damage probe confirms the right hook.
Settings use this mod's own bank save.

MOD MENU: adds a Back button and the WHITE=ON / BLACK=OFF legend when the
menu button ID matches a live MODLIST entry. Existing load-order arrows are
unchanged.

DIAGNOSTICS: full card fields and EXCLUDE pairs (SKCF|), offer flow (SKOF|),
souls/scepters/pieces (SKS|), damage/bullet route (SKD|), input/`but` fields/menu IDs
(SKI|), and UI/config state (SKUI|). Probe blocks run after READY and each
one logs an SKA2|probe|<name>=done checkpoint.
]]

cover="cover.png"

priority_hint=0

mode_description = {
}
