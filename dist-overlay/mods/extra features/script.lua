prepend("init_game",function()
	if not mode.ban then mode.ban = {} end
	local ban = mode.ban
	if mode.weapons then
		local wep = mode.weapons[mode.weapons_index+1]
		local wep_ban = wep.ban
		if type(wep_ban) == "table" then
			for id in all(wep_ban) do add(ban,id) end
		elseif type(wep_ban) then add(ban,wep_ban) end
	end
	if mode.ranks then
		local rank = mode.ranks[mode.ranks_index+1]
		local rank_ban = rank.ban
		if type(rank_ban) == "table" then
			for id in all(rank_ban) do add(ban,id) end
		elseif type(rank_ban) then add(ban,rank_ban) end
	end
end,"add banned cards")

local making_card
local ca
prepend("new_card",function() making_card = true end,"animated cards")
append("tbl_import",function(tbl) if making_card then ca = tbl end end,"animated cards")
append("new_card",function()
	local dr = ca.dr
	local gid = ca.gid
	function ca:dr(x,y)
		local cx,cy = x,y
		if self.par then cx,cy = x+self.par.x,y+self.par.y end
		if (mx>=cx and mx<cx+24 and my>=cy and my<cy+32) or not self.ov_play then
			self.ovt = (self.ovt or 0) + 1
		else
			self.ovt = 0
		end
		if self.animated then self.gid = gid + cyc(self.animated,self.ani_spd,self.ovt) end
		dr(self,x,y)
	end
	making_card = nil
	ca = nil
end,"animated cards")


prepend("dr_flip_card",function(cx,cy,ca,ct)
	if ct == 0 and ca.animated and ca.par and cx==ca.x then
		if not ca.o_gid then
			ca.o_gid = ca.gid
			ca.ovt = 0
		end
		local x,y = ca.x+ca.par.x,ca.y+ca.par.y
		if (mx>=x and mx<x+24 and my>=y and my<y+32) or not ca.ov_play then
			ca.ovt = ca.ovt + 1
		else
			ca.ovt = 0
		end
		ca.gid = ca.o_gid + cyc(ca.animated,ca.ani_spd,ca.ovt)
	end
end,"animated cards")
