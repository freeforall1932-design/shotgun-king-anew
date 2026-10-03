id = "3342310033"

name="some_fairy_pieces" -- Make this match your mod's folder

title="Fairy Pieces for SGK"
by="sub122"
description=[[
Fairy chess piecess for Shotgun King. Contains a few basic fairy pieces.

Centaur > Moves as a King or Knight. Is not royal, and therefore will not end a floor if defeated.

Archbishop > Moves as a Bishop or Knight.

Chancellor > Moves as a Rook or Knight.

Amazon > Moves as a Queen or Knight.

Commoner > Moves as a King, is not royal.

Gryphon > Moves 1 square diagonally, and then outwards as a Rook.

Prince > Moves as a King, will replace the King if the King is defeated.

Banner > Cannot move. Nearby pieces can move as a Queen. 
]]

cover="cover_sfps.png" -- This is the mod preview that will appear on the steam workshop

--default_lang="frank" -- This lets you set a default language for when your mod is active

priority_hint=1 -- A higher number means your mod will automatically be placed higher in people's mod loading order
mode_description = {
	["Fairy Endless"] = "Fairy Endless|A variant of endless that can also add fairy pieces per floor after floor 10"
}
mode_record = { -- This lets you display a highscore for each of your game modes.
	-- ["skirmish"] = { name="best score: ", bx=0, by=1 } -- bx and by are coordinates in the mod's save bank.
}