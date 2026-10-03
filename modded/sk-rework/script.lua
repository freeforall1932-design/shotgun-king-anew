-- SK-REWORK: Phase 2 stub — prove the mod loads + dump the runtime map.
-- All output goes to log.txt next to the game exe. No gameplay changes.
-- Line prefixes for grepping: SKG=global names, SKR=replaceable, SKF=forbidden.

-- find ourselves in the mod list (canonical pattern from community mods)
for i,v in ipairs(MODLIST) do
	if v.title == "SK Rework" then
		mod_index, mod = i, v
		break
	end
end

_log("SK-REWORK: loaded (mod_index="..tostring(mod_index)..")")

-- SK-REWORK: one-shot introspection dump -------------------------------
local function dump(tag, tbl)
	local n = 0
	for k in all(tbl) do
		_log(tag.."|"..tostring(k))
		n = n + 1
	end
	_log("SK-REWORK: "..tag.." count="..n)
end

dump("SKG", gimme("global"))
dump("SKR", gimme("replaceable"))
dump("SKF", gimme("forbidden"))

-- SK-REWORK: TODO (next iterations, once the dump is verified):
--   F-key debug keys (needs input API study: Glac Terminal mod)
--   +ammo, card list, enemy cycle, damage multipliers
