-- DEFAULT SETTINGS

--[[
	If you want to have your custom settings,
	copy this file to your mod folder and rename as <mode>_settings.lua
	
	You can delete entries that you don't want to change,
	so that you know whatever left in your setting file is the changes you made.

	Remember that adding -- to the start of a line COMMENTS OUT that line,
	which does the same thing as deleting.
--]]

-------------------------------------------------------------------
return
{
hook = {
   -- gameplay settings

   -- default damage of the hook
   damage = 1,
	
	-- default stun duration of the hook
	stun = 1,

	-- pieces that don't get pulled or stunned
   immune = {
		-- pawn = false,
		-- knight = false,
		-- bishop = false,
		-- rook = false,
		-- queen = false,
		king = true,
		boss = true,
		-- canonball = false,
		leader = true
	},

	-- display settings

   -- animation speed of the hook (unit: pixels per frame, or 3.75 squares per second)
	-- changing this affects the range
	speed = 9,
   
   -- colour of the rope
	rope_color = 5,

   -- number of frames it takes for the piece to get pulled back
	pull_tempo = 12,

	-- enables the icon to the left of the board | the surface and position to draw the icon from
	enable_icon = true,
	surface = "collection_gfx",
	index = 0,

   -- enables sfx for throwing the hook
	enable_sfx = true,

   -- enables folly shield warning when using the hook
	danger_warning = true

},

aura = {
	-- gameplay settings

	-- default damage of the aura
	def_dmg = 1,

	-- display settings

	-- number of frames it takes for the aura to expand to maximum
	aura_tempo = 12,

	-- colour of the aura
	aura_colour = 5,

	-- enables sfx for the aura
	enable_sfx = true,
},

frag = {

	-- minimum range of fragments (unit: half square)
	min_range = 4,

	-- difference between minimum and maximum range (unit: half square)
	variance = 2,

	-- damage of each fragment
	dmg = 1,

	-- if used, sets the pierce of each fragment to this value
	-- by default, uses the pierce stat
	--pierce = 100,
},

poison = {
	stackable = true
	-- true: add duration of poison effects
	-- false: take the maximum duration
},

restart = {

	-- enables restart by pressing `/~
	enable_restart_key = true,

	-- plays error sfx if not enough cost can be payed
	-- enable_error_sfx = false,
	
	-- enables the red warning (overrides error sfx setting)
	-- enable_fail_warning = false,

	-- [Optional] the error message displayed below the board
	-- error_msg = "",

	-- settings for special="restart"
	enable_icon = true,
	surface = "collection_gfx",
	index = 1,
},

}