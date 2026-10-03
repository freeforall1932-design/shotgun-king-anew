name="sk-rework" -- must match this mod's folder name

title="SK Rework"
by="freeforall1932"
description=[[
Ammo & gameplay rework (private personal-use project).

Diagnostics build 4: same load/hook proof and function-map dump as build 3
(lines prefixed SK-REWORK:, SKG|, SKA|, SKH|, SKE|, SKO|, SKW|), plus: dumps
every MODLIST entry (SKM|) and the full card id map (SKC|), and probes
mods/modlist.lua (SKML|). The on_*/upd probes of build 3 are gone — the first
live run proved they never fire for plain mods. Changes nothing in the game.
]]

cover="cover.png"

priority_hint=0

mode_description = {
}
