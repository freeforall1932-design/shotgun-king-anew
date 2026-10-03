-- LOAD DEFAULT SETTINGS
local	def_settings = require("mode_settings.lua")
local settings

-- LOAD SETTINGS
append("set_mode",function()
	settings = clone(def_settings,true)
	if file(mode.id.."_settings.lua") then
		local custom_settings = require(mode.id.."_settings.lua")
		for feature,setting in pairs(custom_settings) do
			tbl_import(settings[feature],setting)
		end
	end
end,"get settings")

-- newbnk(128,64,4)
newsrf("gfx.png","collection_gfx")

for i,v in ipairs(MODLIST) do if v.title == "Glacies' Collection" then
	mod_index,mod = i,v
	break
end end

-- local chinese = {
-- 	signature = "作者：冰凌",
-- 	new_content = "有更新！"
-- }

-- local english = {
-- 	signature = "Modder:Glacies",
-- 	new_content = "NEW!!"
-- }

-- function add_lang(s)
-- 	tbl_import(lang,s=="simplified_chinese" and chinese or english)
-- end

-- add_lang(current_lang)
-- append("load_lang",add_lang,"collection")

prepend("build_stack",function()
	for ca in all(get_all_cards(true)) do for k,v in pairs(ca) do
		if sub(k,1,9) == "rankmore_" then
			local i = find(k,"_",10)
			if mode.ranks_index+1 > tonum(sub(k,10,i-1)) then
				if type(v) == "table" then
					ca[k] = nil
					local k = sub(k,i+1)
					ca[k] = ca[k] or {}
					for n in all(v) do
						add(ca[k],n)
					end
				else
					ca[k] = nil
					local k = sub(k,i+1)
					ca[k] = (ca[k] or 0)+v
				end
			end
		elseif sub(k,1,9) == "rankless_" then
			local i = find(k,"_",10)
			if mode.ranks_index+1 < tonum(sub(k,10,i-1)) then
				if type(v) == "table" then
					ca[k] = nil
					local k = sub(k,i+1)
					ca[k] = ca[k] or {}
					for n in all(v) do
						add(ca[k],n)
					end
				else
					ca[k] = nil
					local k = sub(k,i+1)
					ca[k] = (ca[k] or 0)+v
				end
			end
		end
	end end
end,"glacies collection")

function on_sq_but_init(b,sq)
	if b.left_clic and not b.right_clic and not b.on_drag then function b:right_clic()
		-- HOOK
		if stack.special == "hook" then
			local settings = settings.hook
			
			if settings.danger_warning and check_folly_shields(hero.sq) then
				show_danger(hero.sq)

			else
				local hook = mke()
				if settings.enable_sfx then sfx("grab_done") end
				hook.x = hero.x+8+8*cos(hero.current_an)
				hook.y = hero.y+8+8*sin(hero.current_an)
				impulse(hook,hero.current_an,settings.speed)
				hook.start_x = hero.x+8+8*cos(hero.current_an)
				hook.start_y = hero.y+8+8*sin(hero.current_an)
				hook.life = stack.hook_inf and 20 or (get_firerange()+(stack.hook_range or 0))*2+4
				hook.glacies = "hook"
				function hook:upd()
					local sq = get_square_at(hook.x,hook.y)
					if sq and not hook.stop then
						if sq.p then
							local p = sq.p
							if not p.airy or stack.hook_silver then
								hit(p,settings.damage+(stack.hook_dmg or 0),{hook=1})
								for k,v in pairs(stack) do if sub(k,1,7) == "hooked_" then
									trigger(sub(k,8),{v=v,p=p})
								end end
								if p.dead or settings.immune[p.name] or p.hkim or (p.type==leader and settings.immune.leader) then
									kl(hook)
								else
									stun_piece(p,settings.stun + (stack.hook_stun or 0))
									hook.vx = 0
									hook.vy = 0
									hook.stop = true
									hook.life = nil
									wait(15,function()
										if hook.sq then
											leave_sq(p)
											hook.sq.p = p
											p.sq = hook.sq
											mvt(p,hook.sq.x,hook.sq.y,settings.pull_tempo)
											if p.promote and hook.sq.py == 7 then
												add_event(ev_promote,p)
											end
											mvt(hook,hook.start_x,hook.start_y,settings.pull_tempo,bind(kl,hook))
										else
											kl(hook)
										end
									end)
								end
							end
						elseif hook.sq == nil then
							hook.sq = sq
						end
					end
				end
				function hook:dr(x,y)
					line(self.start_x,self.start_y,x,y,settings.rope_color)
				end
				function hook.nxt()
					wait(15,opp_turn)
				end
				remove_buts()
			end

		elseif stack.special == "restart" then
			effects.restart()
		end
	end end

	-- 
end

defbtn("restart",0,"k:grave")
function upd()
	if playing and btnr("restart") and settings.restart.enable_restart_key then
		effects.restart()
	end

	---[[ airburst (1/2)
	local function airburst()
		if not stack.airburst or stack.airburst <= 0 then
			if crosshair.old_dr then
				crosshair.dr = crosshair.old_dr
				crosshair.old_dr = nil
			end
			return
		end
		if (not crosshair) or (crosshair.old_dr) then return end
		crosshair.old_dr = crosshair.dr
		crosshair.dr = function(...)
			if not hero then return end
			if not hero.x then return end
			if not playing then return end
			if not (chamber > 0) then return end
			if mx < board_x or mx > board_x + (8 * 16) or my < board_y or my > board_y + (8 * 16) then
				crosshair.old_dr(...)
				return
			end
			local gun_x = hero.x + 8 + 8 * cos(hero.current_an)
			local gun_y = hero.y + 8 + 8 * sin(hero.current_an)
			local burst_x = hero.x + cos(hero.current_an) * 16 * stack.airburst
			local burst_y = hero.y + sin(hero.current_an) * 16 * stack.airburst
			if (sqrdist(mx, my, hero.x + 8, hero.y + 8) < (16 * stack.airburst + 8) ^ 2) and not aim then
				line(gun_x, gun_y, mx, my, 5)
				return
			end
			line(gun_x, gun_y, burst_x - hero.x + gun_x, burst_y - hero.y + gun_y, 5)
			local temp_hx = hero.x
			local temp_hy = hero.y
			hero.x = burst_x
			hero.y = burst_y
			stack.firerange = stack.firerange - stack.airburst
			crosshair.old_dr(...)
			stack.firerange = stack.firerange + stack.airburst
			hero.x = temp_hx
			hero.y = temp_hy
		end
	end
	airburst()
	--]]

end

append("draw_mode",function()
	local posX = board_x - 25
	local posY = board_y + 8 * SQ - 16 - 2
	local drawButton

	if stack.special == "hook" then
		if settings.hook.enable_icon then
			spritesheet(settings.hook.surface)
			spr(settings.hook.index,posX,posY)
			drawButton = true
		end
	elseif stack.special == "restart" then
		if settings.restart.enable_icon then
			if (stack.restart and stack.restart > 0) or (stack.temp_restart and stack.temp_restart > 0) then
				drawButton = true
			else
				pal_inc(-2)
			end
			spritesheet(settings.restart.surface)
			spr(settings.restart.index,posX,posY)
			pal()
			spritesheet("gfx")
		end
	end
	if drawButton then draw_button("special", posX + 3, posY + 18 - 1) end
end,"glacies collection")

function edit_disp_stats(stats)
	if stack.restart and stack.restart > 0 then
		add(stats,{id="restart",name=lang.restart,value=tostr(stack.restart)})
	end
	if stack.temp_restart and stack.temp_restart > 0 then
		add(stats,{id="temp_restart",name=lang.temp_restart,value=tostr(stack.temp_restart)})
	end
end

function on_card_but_init(but,ca)
	local function click()
		for k,v in pairs(ca) do if sub(k,1,6) == "click_" then
			trigger(sub(k,7),{v=v,ca=ca})
		end end
	end
	local function rclick()
		for k,v in pairs(ca) do if sub(k,1,7) == "rclick_" then
			trigger(sub(k,8),{v=v,ca=ca})
		end end
	end
	local left_clic = but.left_clic
	but.left_clic = function()
		exe(left_clic)
		click()
	end
	local right_clic = but.right_clic
	but.right_clic = function()
		exe(right_clic)
		rclick()
	end	
end

append("flip_card",function(ca)
	for k,v in pairs(ca) do
		if sub(k,1,6) == "oflip_" or sub(k,1,6) == "nflip_" then
			trigger(sub(k,7),{v=v,ca=ca})
		end
	end
	for k,v in pairs(stack) do
		if sub(k,1,8) == "flipped_" then trigger(sub(k,9),{v=v,ca=ca}) end
	end
end, "glacies collection")

append("unflip_card",function(ca)
	for k,v in pairs(ca) do
		local i
		if sub(k,1,7) == "unflip_" then
			i = 8
		elseif sub(k,1,6) == "nflip_" then
			i = 7
		end
		if i then
			trigger(sub(k,i),{v=v,ca=ca})
		end
	end
	for k,v in pairs(stack) do
		if sub(k,1,10) == "unflipped_" then trigger(sub(k,11),{v=v,ca=ca}) end
	end
end, "glacies collection")

append("ev_backup",function(ca)
	for k,v in pairs(ca) do
		if sub(k,1,8) == "delayed_" then trigger(sub(k,9),{v=v,ca=ca}) end
	end
end,"glacies collection")

append("uplift",function(delayed)
	for k,v in pairs(delayed) do
		if sub(k,1,8) == "delayed_" then trigger(sub(k,9),{v=v}) end
	end
end,"glacies collection")

append("new_level",function()
	for k,v in pairs(stack) do
		if sub(k,1,11) == "floorstart_" then
			trigger(sub(k,12),{v=v})
		elseif sub(k,1,6) == "floor_" then
			local i = find(k,"_",7)
			if i and mode.lvl == tonum(sub(k,7,i-1)) then
				trigger(sub(k,i+1),{v=v})
			end
		end
	end
end, "glacies collection")

local grenade
append("throw_grenade",function(sq,gre)
	-- if gre then
	-- 	grenade = gre
	-- else
	if not gre then
		for i = #ents,1,-1 do
			local e = ents[i]
			if e.jz and not e.sink and e.dp~=DP_BG then
				grenade = e

				if stack.grenade_throwpower then
					e.jz = e.jz * stack.grenade_throwpower/100
				end
				
				return
			end
		end

	end
end, "glacies collection")
append("sfx",function(sfx)
	if sfx == "grenade_xpl" then
		local sq = get_square_at(grenade.x,grenade.y)
		local targets = get_zone_targets(sq,1,function(p) return true end)
		for k,v in pairs(stack) do
			if sub(k,1,8) == "greneff_" then
				args = {v=v}
				for p in all(targets) do
					args.p = p
					trigger(sub(k,9),args)
				end
			end
		end
		function grenade.nxt()
			for k,v in pairs(stack) do
				if sub(k,1,8) == "grenxpl_" then
					trigger(sub(k,9),{v=v,sq=sq})
				end
			end
			grenade = nil
		end

	elseif sfx == "grenade_bounce" then
		if stack.grenade_sticky then
			grenade.jz = 0
		end
	end
end, "glacies collection")


function on_new_turn()
	local turn = (mode.turns or 0) + 1
	for k,v in pairs(stack) do
		if sub(k,1,7) == "period_" then
			local i = find(k,"_",8)
			if i then
				local effect = sub(k,i+1)
				local period = max(1,tonum(sub(k,8,i-1))-(stack["perioddown_"..effect] or 0)-(stack.perioddown or 0))
				if turn%period == 0 then
					trigger(effect,{v=v})
				end
			end
		elseif sub(k,1,5) == "turn_" then
			local i = find(k,"_",6)
			if i and turn == tonum(sub(k,6,i-1)) then
				trigger(sub(k,i+1),{v=v})
			end
		end
	end
end

function on_piece_move(p)
	for k,v in pairs(stack) do
		if sub(k,1,5) == "move_" then
			local i = find(k,"_",6)
			local name = sub(k,6,i-1)
			if name == p.name or name == "all" or (name == "leader" and p.type == leader) then
				trigger(sub(k,i+1),{v=v,p=p})
			end
		end
	end
end

function on_bad_death(p)
	-- if p.bad then
		
	for k,v in pairs(stack) do
		if sub(k,1,6) == "death_" then
			local i = find(k,"_",7)
			local name = sub(k,7,i-1)
			if name == p.name or name == "all" or (name == "leader" and p.type == leader) then
				trigger(sub(k,i+1),{v=v,p=p})
			end
		end
	end
	
	p.knockweak = -114514

	-- end
end

function on_bad_hurt(p)
	for k,v in pairs(stack) do
		if sub(k,1,5) == "hurt_" then
			local i = find(k,"_",6)
			local name = sub(k,6,i-1)
			if name == p.name or name == "all" or (name == "leader" and p.type == leader) then
				trigger(sub(k,i+1),{v=v,p=p})
			end
		end
	end
end

function on_bad_spawn(p)
	for k,v in pairs(stack) do
		if sub(k,1,6) == "spawn_" then
			local i = find(k,"_",7)
			local name = sub(k,7,i-1)
			if name == p.name or name == "all" or (name == "leader" and p.type == leader) then
				trigger(sub(k,i+1),{v=v,p=p})
			end
		end
	end
end

function on_fire()

	for k,v in pairs(stack) do
		if sub(k,1,5) == "fire_" then
			trigger(sub(k,6),{v=v})
		end
	end

	for i,b in ipairs(bullets) do if not b.terminal then
		b.terminal = true

		if not b.shot then return end

		if stack.b_dmg then b.dmg = b.dmg + stack.b_dmg end

		-- from JP
		if stack.long_gun then
			b.x = b.x + 4 * b.vx
   		b.y = b.y + 4 * b.vy
		end

		if stack.b_curve then
			-- b.curve = true
			b.angle = hero.current_an
			b.curve_angle = atan2(b.vx, b.vy) - b.angle
			if b.curve_angle > .5 then
				b.curve_angle = b.curve_angle - 1
			elseif b.curve_angle < -.5 then
				b.curve_angle = b.curve_angle + 1
			end
			local upd = b.upd
			function b.upd(...)
				b.angle = b.angle + (b.curve_angle * 0.3)
   			b.vx = cos(b.angle) * 8
   			b.vy = sin(b.angle) * 8
				upd(...)
			end
		end

		if stack.b_fixed_angle then
			for i, b in ipairs(bullets) do
				local arc = get_spread() / 360
				local b_offset = i * (arc / (#bullets + 1))
				local b_angle = (hero.current_an - arc / 2) + b_offset
				b.vx = cos(b_angle) * 8
				b.vy = sin(b_angle) * 8
			end
		end

		if stack.b_homing then
			local upd = b.upd
			function b.upd(...)
				if not b.target or b.target.hp < 1 then
					local closest = nil
					local closest_dist = 100000
					for e in all(get_real_bads()) do
						local dist = sqrdist(b.x, b.y, e.x + 64, e.y)
						if dist < closest_dist then
							closest = e
							closest_dist = dist
					  	end
					end
					b.target = closest
				end
				if b.target then
					local current_angle = atan2(b.vx, b.vy)
					local target_angle = atan2(b.target.x - b.x, b.target.y - b.y)
					if current_angle - target_angle > .5 then
					  	target_angle = target_angle + 1
					elseif target_angle - current_angle > .5 then
					  	target_angle = target_angle - 1
					end
					local angle = current_angle + (target_angle - current_angle) / 8
					b.vx = cos(angle) * 8
					b.vy = sin(angle) * 8
				end
				upd(...)
			end
		end

		if stack.b_strengthening then
			local upd = b.upd
			function b.upd(...)
				if b.t % 9 == 0 then
					b.dmg = b.dmg + 1
				end
				upd(...)
			end
		end

		if stack.b_weakening then
			local upd = b.upd
			function b.upd(...)
				if b.t % 9 == 0 then
					b.dmg = b.dmg - 1
				end
				upd(...)
			end
		end

		if stack.b_gamble then
			b.dmg = b.dmg + irnd(stack.b_gamble)
		end
		
		---[[ Also adapted by Scavenger
		-- airburst (2/2)
		if stack.airburst and stack.airburst>0 then
			b.airburst = stack.airburst
			b.old_vx = b.vx
			b.old_vy = b.vy
			b.vx = cos(hero.current_an) * 8
			b.vy = sin(hero.current_an) * 8

			local upd = b.upd
			function b.upd(...)
				if b.old_vx and b.old_vy then
					if b.t > (-1 + 2 * stack.airburst) then
						b.vx = b.old_vx
						b.old_vx = nil

						b.vy = b.old_vy
						b.old_vy = nil
					end
				end
			
				upd(...)
			end
		end

		if stack.b_bounce then
			local upd = b.upd
			function b.upd(...)
				-- X-axis bounce and reposition
				if b.x < board_x then
					b.vx = -b.vx
					b.x = board_x+SQ/2 -- Reposition to prevent getting stuck
				elseif b.x > board_x + xmax*SQ then
					b.vx = -b.vx
					b.x = board_x + xmax*SQ-SQ/2 -- Reposition to prevent getting stuck
				end
				
				-- Y-axis bounce and reposition
				if b.y < board_y then
					b.vy = -b.vy
					b.y = board_y + SQ/2 -- Reposition to prevent getting stuck
				elseif b.y > board_y + ymax*SQ then
					b.vy = -b.vy
					b.y = board_y + ymax*SQ-SQ/2 -- Reposition to prevent getting stuck
				end
				upd(...)
			end
		end		
		--]]

		--

	end end
end

effects = {}
builtins = {
	args = function(self) return self end, 
	stack = function() return stack end, 
	turn = function() return (mode.turns or 0) end, 
	floor = function() return mode.lvl end, 
	rank = function() return (mode.ranks_index and mode.ranks_index+1) end, 
	hero = function() return hero end,
	leader = function() return leader end,

	ammo = function() return ammo end,
	chamber = function() return chamber end,
	grenade = function() return grenades end,
	shield = function() return shields end,
	time = function() return chrono_time end,
}

function trigger(id,args)
	if not args then args = {} end
	if hero and (hero.win or hero.dead or hero.fail) or args.halt then return end

	-- log(id)
	
	if not getmetatable(args) then
		setmetatable(args,{__index=function(t,key)
			return builtins[key] and builtins[key](args)
		end})
	end

	if sub(id,1,9) == "setValue_" then
		local i = find(id,"_",10)
		local key = read_key(sub(id,10,i-1))
		local num = tonum(key)
		local v = args.v
		if num then
			args.v = num
		else
			is_absent(args,key)
			args.v = args[key]
		end
		trigger(sub(id,i+1),args)
		args.v = v
		return
	end
	
	local negate = false
	if sub(id,1,4) == "not_" then
		negate = true
		id = sub(id,5)
	end

	if sub(id,1,3) == "if_" then
		local i = find(id,"_",4)
		local j = find(id,"_",i+1)
		local s = sbs(sub(id,4,i-1),"UNDER","_")
		if is_absent(args,s) then return end
		local arg = args[s]
		local key = sbs(sub(id,i+1,j-1),"UNDER","_")
		if negate then
			if not arg[key] then trigger(sub(id,j+1),args) end
		elseif arg[key] then
			args[key] = arg[key]
			trigger(sub(id,j+1),args)
		end
		return

	elseif sub(id,1,12) == "ifTimeUnder_" then
		local i = find(id,"_",13)
		if (chrono_time >= tonum(sub(id,13,i-1))) ~= (not negate) then
			trigger(sub(id,i+1),args)
		end
		return
	elseif sub(id,1,11) == "ifTimeOver_" then
		local i = find(id,"_",12)
		if (chrono_time <= tonum(sub(id,12,i-1))) ~= (not negate) then
			trigger(sub(id,i+1),args)
		end
		return

	elseif sub(id,1,10) == "ifGreater_" then
		local i = find(id,"_",11)
		local j = find(id,"_",i+1)

		local key1 = read_key(sub(id,11,i-1))
		is_absent(args,key1)
		local key2 = read_key(sub(id,i+1,j-1))
		local num = tonum(key2)
		if not num then
			is_absent(args,key2)
			num = args[key2]
		end

		if negate ~= (args[key1] > num) then
			trigger(sub(id,j+1),args)
		end

		return

	elseif sub(id,1,8) == "ifLower_" then
		local i = find(id,"_",9)
		local j = find(id,"_",i+1)

		local key1 = read_key(sub(id,9,i-1))
		is_absent(args,key1)
		local key2 = read_key(sub(id,i+1,j-1))
		local num = tonum(key2)
		if not num then
			is_absent(args,key2)
			num = args[key2]
		end

		if negate ~= (args[key1] < num) then
			trigger(sub(id,j+1),args)
		end

		return

		elseif sub(id,1,8) == "ifEqual_" then
		local i = find(id,"_",9)
		local j = find(id,"_",i+1)

		local key1 = read_key(sub(id,9,i-1))
		is_absent(args,key1)
		local key2 = read_key(sub(id,i+1,j-1))
		local num = tonum(key2)
		if not num then
			is_absent(args,key2)
			num = args[key2]
		end

		if negate ~= (args[key1] == num) then
			trigger(sub(id,j+1),args)
		end

		return

	elseif sub(id,1,6) == "ifHas_" then
		local i = find(id,"_",7)
		if (not (stack[sbs(sub(id,7,i-1),"UNDER","_")])) ~= (not negate) then
			trigger(sub(id,i+1),args)
		end
		return

	elseif sub(id,1,7) == "ifAmmo_" then
		if negate == (ammo==0) then trigger(sub(id,8),args) end
		return

	elseif sub(id,1,11) == "ifFullAmmo_" then
		if negate == (ammo<stack.ammo_max) then trigger(sub(id,12),args) end
		return

	elseif sub(id,1,10) == "ifChamber_" then
		if negate == (chamber==0) then trigger(sub(id,11),args) end
		return

	elseif sub(id,1,14) == "ifFullChamber_" then
		if negate == (chamber<stack.chamber_max) then trigger(sub(id,15),args) end
		return

	elseif sub(id,1,8) == "ifExist_" then
		local i = find(id,"_",9)
		local targets = get_bads_named(sub(id,9,i-1))
		if negate then
			if #targets == 0 then trigger(sub(id,i+1),args) end
		elseif #targets > 0 then
			args.p = rnd(targets)
			trigger(sub(id,i+1),args)
		end
		return
	elseif sub(id,1,7) == "forAll_" then
		local i = find(id,"_",8)
		for p in all(get_bads_named(sub(id,8,i-1))) do
			args.p = p
			trigger(sub(id,i+1),args)
		end
		return

	elseif sub(id,1,10) == "ifHasCard_" then
		local i = find(id,"_",11)
		local name = sbs(sbs(sub(id,11,i-1),"SPACE"," "),"UNDER","_")
		local cards = {}
		for ca in all(get_slot_cards(true)) do
			if ca.id == name or ca[name] then
				if negate then
					return
				else
					add(cards,ca)
				end
			end
		end
		if #cards > 0 then
			args.ca = rnd(cards)
			trigger(sub(id,i+1),args)
		end
		return
	elseif sub(id,1,11) == "forAllCard_" then
		local i = find(id,"_",12)
		local name = sbs(sbs(sub(id,12,i-1),"SPACE"," "),"UNDER","_")
		for ca in all(get_slot_cards(true)) do
			if ca.id == name or ca[name] then
				args.ca = ca
				trigger(sub(id,i+1),args)
			end
		end
		return
	-- elseif sub(id,1,14) == "ifHasCardWith_" then
	-- 	local i = find(id,"_",15)
	-- 	local key = sbs(sub(id,15,i-1),"UNDER","_")
	-- 	local cards = {}
	-- 	for ca in all(get_slot_cards(true)) do
	-- 		if ca[key] then
	-- 			if negate then
	-- 				return
	-- 			else
	-- 				add(cards,ca)
	-- 			end
	-- 		end
	-- 	end
	-- 	if #cards > 0 then
	-- 		args.ca = rnd(cards)
	-- 		trigger(sub(id,i+1),args)
	-- 	end
	-- 	return
	-- elseif sub(id,1,15) == "forAllCardWith_" then
	-- 	local i = find(id,"_",16)
	-- 	local key = sbs(sub(id,16,i-1),"UNDER","_")
	-- 	for ca in all(get_slot_cards(true)) do
	-- 		if ca[key] then
	-- 			trigger(sub(id,i+1),args)
	-- 		end
	-- 	end
	-- 	return

	elseif sub(id,1,7) == "ifHero_" then
		if negate then
			if not hero then
				trigger(sub(id,8),args)
			end
		elseif hero then
			args.p = hero
			trigger(sub(id,8),args)
		end
		return

	elseif sub(id,1,11) == "getNearest_" then
		if is_absent(args,"sq") then return end
		local p = get_nearest_piece(args.sq)
		if p then
			args.p = p
			trigger(sub(id,12),args)
		end
		return

	elseif sub(id,1,13) == "ifLeftSquare_" then
		if is_absent(args,"p") then return end
		local p = args.p
		if negate then
			if not p.wsq then trigger(sub(id,14),args) end
		elseif p.wsq then 
			args.sq = p.wsq
			trigger(sub(id,14),args)
		end
		return

	elseif sub(id,1,8) == "ifBlack_" then
		if is_absent(args,"ca") then return end
		if negate ~= (args.ca.team == 0) then
			trigger(sub(id,9),args)
		end
		return

	elseif sub(id,1,4) == "rnd_" then
		local i = find(id,"_",5)
		local thres = tonum(sub(id,5,i-1))
		if (irnd(100)<thres) == not negate then
			trigger(sub(id,i+1),args)
		end
		return

	elseif sub(id,1,10) == "ifChecked_" then
		if negate == (#hero.sq.danger==0) then
			if not negate then args.p = rnd(hero.sq.danger) end
			trigger(sub(id,11),args)
		end
		return

	elseif sub(id,1,7) == "ifPass_" then
		if not check_folly_shields(hero.sq) then
			trigger(sub(id,8),args)
		end
		return

	elseif sub(id,1,12) == "selectPiece_" then
		remove_buts()
		local function select(p)
			args.p = p
			trigger(sub(id,13),args)
			wait(10,play)
		end
		wait(10,ask_piece,function() return true end,select)
		return
	elseif sub(id,1,11) == "selectCard_" then
		remove_buts()
		function select(ca)
			args.ca = ca
			trigger(sub(id,12),args)
			wait(10,play)
		end
		wait(10,ask_card,function() return true end,select) -- 避免立刻触发新生成的按钮
		return

	end

	-- COMMANDS

	if sub(id,1,8) == "promote_" then
		args.promote = get_bads_named(sub(id,9))
		id = "promote"
	elseif sub(id,1,5) == "soul_" then
		args.soul = PIECES_NAMES[sub(id,6)].type
		id = "soul"	
	elseif sub(id,1,9) == "disguise_" then
		args.disguise = PIECES_NAMES[sub(id,10)].type
		id = "disguise"

	---[[ DEPRECATED
	elseif sub(id,1,4) == "hit_" then
		args.p = rnd(get_bads_named(sub(id,5)))
		if not args.p then return end
		id = "hit"
	elseif sub(id,1,8) == "execute_" then
		args.p = rnd(get_bads_named(sub(id,9)))
		if not args.p then return end
		id = "execute"
	elseif sub(id,1,7) == "strike_" then
		args.p = rnd(get_bads_named(sub(id,8)))
		if not args.p then return end
		id = "strike"
	elseif sub(id,1,5) == "stun_" then
		args.p = rnd(get_bads_named(sub(id,6)))
		if not args.p then return end
		id = "stun"
	elseif sub(id,1,9) == "soulless_" then
		args.p = rnd(get_bads_named(sub(id,10)))
		if not args.p then return end
		id = "soulless"
	elseif sub(id,1,6) == "bleed_" then
		args.p = rnd(get_bads_named(sub(id,7)))
		if not args.p then return end
		id = "bleed"
	elseif sub(id,1,7) == "poison_" then
		args.p = rnd(get_bads_named(sub(id,8)))
		if not args.p then return end
		id = "poison"
	elseif sub(id,1,6) == "delay_" then
		args.p = rnd(get_bads_named(sub(id,7)))
		if not args.p then return end
		id = "delay"
	--]]

	elseif sub(id,1,4) == "inc_" then
		args.stat = sub(id,5)
		id = "inc"
	elseif sub(id,1,6) == "boost_" then
		args.stat = sub(id,7)
		id = "boost"
	elseif sub(id,1,5) == "gain_" then
		args.stat = sub(id,6)
		id = "gain"

	---[[ DEPRECATED
	elseif sub(id,1,5) == "heal_" then
		if sub(id,6,9) == "all_" then
			args.heal = get_bads_named(sub(id,10))
		else
			args.p = rnd(get_bads_named(sub(id,6)))
			if not args.p then return end
		end
		id = "heal"
	elseif sub(id,1,9) == "frighten_" then
		if sub(id,10,13) == "all_" then
			args.frighten = get_bads_named(sub(id,14))
		else
			args.p = rnd(get_bads_named(sub(id,10)))
			if not args.p then return end
		end
		id = "frighten"
	--]]

	elseif sub(id,1,4) == "sfx_" then
		args.sfx = sub(id,5)
		id = "sfx"
	elseif sub(id,1,6) == "emote_" then
		args.emote = sub(id,7)
		id = "emote"
	end

	-- log(id)
	-- _log(id)

	if effects[id] then
		effects[id](args)
	elseif stack["bundle_"..id] then
		local ids = stack["bundle_"..id]
		local values
		if type(args.v) == "table" then values = args.v end
		for i=1,#ids do
			local id = ids[i]
			if values then args.v = values[i] end
			trigger(id,args)
		end
		if values then args.v = values end
	else
		log("Command "..id.." not found")
		_log("Command "..id.." not found")
	end
end

function effects.aura(args)
	if is_absent(args,"sq") then return end

	local settings = settings.aura
	local rad = args.v
	local sq = args.sq
	for i=-rad,rad do
		for j=-rad,rad do
			local tsq = gsq(sq.px+i,sq.py+j)
			if tsq and tsq.p and tsq.p.bad then
				hit(tsq.p,settings.def_dmg+(stack.aura_dmg or 0),{aura=1})
			end
		end
	end
	if settings.enable_sfx then sfx("lift") end
	local marker1 = mke(-1,sq.x+7,sq.y+7)
	local marker2 = mke(-1,sq.x+8,sq.y+8)

	mv(marker1,-rad*16-7,-rad*16-7,settings.aura_tempo,bind(kl,marker1))
	marker1.glacies = "aura vertex 1"
	function marker1:dr()
		rect(marker1.x,marker1.y,marker2.x,marker2.y,settings.aura_colour)
	end

	mv(marker2,rad*16+7,rad*16+7,settings.aura_tempo,bind(kl,marker2))
	marker2.glacies = "aura vertex 2"
end

function effects.frag(args)
	if is_absent(args,"sq") then return end
	local sq = args.sq
	local x,y = sq.x+8,sq.y+8
	local settings = settings.frag

	local min_range = settings.min_range + (stack.frag_range or 0)*2
	local var = settings.variance + (stack.frag_interval or 0)*2
	local dmg = settings.dmg + (stack.frag_dmg or 0)
	
	for i=1,args.v do
		local b = mk_bullet(x,y,rnd(1),8)
		b.glacies = "fragment "..i
		b.life = irnd(var+1) + min_range
		b.dmg = dmg
		if settings.pierce then	b.pierce = settings.pierce end
		if stack.frag_pierce then b.pierce = (b.pierce or 0) + stack.frag_pierce end
	end
end

function effects.rats(args)
	if is_absent(args,"sq") then return end
	local sq = args.sq
	local rats = stack.rats
	local p = sq.p
	stack.rats = args.v
	xpl({x=sq.x,y=sq.y,name="rats",type=1000,sq=sq})
	stack.rats = rats
	sq.p = p
end

function effects.ammo(args)
	local n = args.v
	if n > 0 then
		local from = args.p or args.ca
		if from then give_ammo(from,n)
		else inc_ammo(n) end
	else ammo = ammo + n end
end

function effects.grenade(args)
	grenades = min(grenades+args.v,stack.grenades_max)
	if args.v > 0 then sfx("reload") end
end

function effects.load(args)
	if ammo == 0 then return end
	reload(true)
end

function effects.reload(args)
	if ammo == 0 then return end
	reload()
end

function effects.loaddelay(args)
	add_event(ev_reload,true)
end

function effects.reloaddelay(args)
	add_event(ev_reload)
end

function effects.grenready(args)
	if hero then hero.grenade_ready = grenades>0 end
end

function effects.scope(args)
	if hero then hero.scope = true end
end

function effects.xturn(args)
	earn_extra_turn()
end

function effects.skipturn(args)
	if playing then
		remove_buts()
		wait(10,opp_turn)
	else
		add_event(opp_turn)
	end
end

function effects.gainhop(args)
	hero.hop = (hero.hop or 0) + args.v
end

function effects.soul(args)
	local t = 30
	if stack.replace_soul then t = 60 end
	local function ev_soul(...)
		add_soul(...)
		wait(t,event_nxt)
	end
	local soul = args.soul
	if soul then
		for i=1,args.v do add_event(ev_soul,soul,nil,nil,stack.replace_soul) end
	else
		if is_absent(args,"p") then return end
		local p = args.p
		add_event(ev_soul,p.type,p,p.sanctity,stack.replace_soul)
	end
end

function effects.cloak(args)
	cloak_hero(args.v)
end

function effects.disguise(args)
	local type = args.disguise
	if not type then
		if is_absent(args,"p") then return end
		type = args.p.type
	end
	cloak_hero(args.v,type)
end

function effects.expose(args)
	expose()
end

function effects.holoking(args)
	if is_absent(args,"sq") then return end
	set_holoking(args.sq)
end

function effects.ammobox(args)
	add_event(ev_spawn_item,"ammo_box")
end

function effects.promote(args)
	if args.promote then
		for i=1,args.v do
			local p = steal(args.promote)
			if not p then return end
			add_event(ev_promote,p)
		end
	else
		if is_absent(args,"p") then return end
		local p = args.p
		add_event(ev_promote,p)
	end
end

function effects.transform(args)
	if is_absent(args,"p") then return end
	if not args.p.sq then return end
	args.p = morph_to(args.p,args.v,function() end)
end

function effects.inc(args)
	uplift({[args.stat] = args.v})
end

function effects.boost(args)
	boost(args.stat,args.v)
end

function effects.gain(args)
	add(upgrades,{[args.stat] = args.v})
	build_stack()
end

function effects.hit(args)
	if is_absent(args,"p") then return end
	hit(args.p,args.v)
end

function effects.execute(args)
	if is_absent(args,"p") then return end
	xpl(args.p)
	sfx("execute")
end

function effects.strike(args)
	if is_absent(args,"p") then return end
	mode.strike(args.p)
end

function effects.remove(args)
	if is_absent(args,"p") then return end
	fx_ascend(args.p)
end

function effects.stun(args)
	if is_absent(args,"p") then return end
	stun_piece(args.p,args.v)
end

function effects.soulless(args)
	if is_absent(args,"p") then return end
	args.p.soulless = 1
end

function effects.bleed(args)
	if is_absent(args,"p") then return end
	inflict(args.p,"bleed")
end

function effects.poison(args)
	if is_absent(args,"p") then return end
	local p = args.p
	local poison = p.poisoned or 0
	if settings.poison.stackable then
		p.poisoned = poison + args.v
	else
		p.poisoned = max(poison,args.v)
	end
end

function effects.delay(args)
	if is_absent(args,"p") then return end
	local p = args.p
	p.cd = p.cd - args.v
	p.ready = p.cd>=get_piece_tempo(p)
end

function effects.heal(args)
	if args.heal then
		for p in all(args.heal) do
			if not p.dead then mode.heal(p,args.v) end
		end
	else
		if is_absent(args,"p") then return end
		mode.heal(args.p,args.v)
	end
end

function effects.frighten(args)
	if args.frighten then
		for p in all(args.frighten) do
			p.fear = true
			setup_piece(p)
		end
	else
		if is_absent(args,"p") then return end
		args.p.fear = true
		setup_piece(args.p)
	end
end

function effects.disrupt(args)
	add_event(function() ask_disrupt(event_nxt) end)
end

function effects.restart()
	if stack.temp_restart and stack.temp_restart > 0 then
		uplift({temp_restart=-1})
	elseif stack.restart and stack.restart > 0 then
		add(upgrades,{restart=-1})
		build_stack()
	else
		if settings.restart.enable_fail_warning then
			fx_wrong(settings.restart.error_msg)
		elseif settings.restart.enable_error_sfx then
			sfx("wrong")
		end
		return
	end
	effects.reset()
end

function effects.reset()
	remove_buts()
	local temp_restart = 0
	for ca in all(temporary) do
		local restart = ca.temp_restart
		if restart then temp_restart = temp_restart + restart end
	end
	end_level(function()
		new_level()
		uplift({temp_restart=temp_restart})
		add_event(function()
			for k,v in pairs(stack) do
				if sub(k,1,8) == "restart_" then
					trigger(sub(k,9),{v=v})
				end
			end
			wait(1,event_nxt)
		end)
	end)
end

function effects.sfx(args)
	sfx(args.sfx,args.v)
end

function effects.emote(args)
	if is_absent(args,"p") then return end
	fx_emote(args.p,get_lang(args.emote),args.v)
end

function effects.burn(args)
	if is_absent(args,"p") then return end
	args.p.c_burning = (args.p.c_burning or 0) + args.v
end

function effects.win(args)
	add_event(ev_surrender)
end

function effects.fail(args)
	local from = args.p or args.ca or hero
	-- mode.hero_fail(120,from)
	fx_detect(120,from)
	hero.fail = true
	-- local function fail()
	-- 	remove_buts
	if playing then
		remove_buts()
		wait(120,xpl_king,hero)
		-- wait(120,gameover)
	else
		-- add_event(function() wait(from.c_detect,gameover) end)
		add_event(function() wait(from.c_detect or 0,xpl_king,hero) end)
	end
end


function effects.replace(args)
	if is_absent(args,"ca") then return end
	local oca = args.ca
	local sl = oca.sl
	local ca = new_card(args.v)
	oca.disrupted = true
	oca.life = 10
	function oca.nxt() ca.x,ca.y = sl.x,sl.y end
	if playing then
		remove_buts()
		wait(20,play)
	end
	sl.ca = ca
	ca.sl = sl
	ca.x,ca.y = MCW,MCH
	ca.flip_co = 1
	flip_card(oca)
	sfx("flip_back",0.5)
end

function effects.addcard(args)
	local v = args.v
	add_event(function() add_card(v,event_nxt) end)
end

function effects.flip(args)
	if is_absent(args,"ca") then return end
	args.ca.disrupted = true
	flip_card(args.ca)
end

function effects.unflip(args)
	if is_absent(args,"ca") then return end
	args.ca.disrupted = nil
	unflip_card(args.ca)
end

function effects.tear(args)
	if is_absent(args,"ca") then return end
	local ca = args.ca
	add_event(function() tear_apart(ca,event_nxt) end)
end

function effects.accel(args)
	if is_absent(args,"ca") then return end
	for i=1,args.v do increase_card_turns(args.ca) end
end

function effects.refresh(args)
	remove_buts()
	wait(args.v,play)
end

function effects.halt(args)
	args.halt = true
end

function effects.log(args)
	log(args.v)
	exe(record,args)
end

bundles = {
	bundle_targetfound = {"strike","halt"},
	bundle_retrostrike = {"if_p_wsq_if_wsq_p_targetfound","boost_firerange"},

	bundle_unflipCard = {"unflip","halt"},
	bundle_toggle = {"if_ca_flipped_unflipCard","flip"}
}
tbl_import(TEST_STACK,bundles)

append("format_gameplay_datas",function()
	setmetatable(PIECES_NAMES,{__index=function(t,k) if type(k)~="string" then return {index="ERROR"} end end})
end,"table valued fix")

function bypass_plural()
	setmetatable(plural,{__index=function(t,k) if type(k)~="string" then return "ERROR" end end})
end
bypass_plural()
append("load_lang",bypass_plural,"bypass_plural")

prepend("get_lang",function(s,reps)
	if sub(s,1,7) == "effect_" and reps and #reps == 2 and type(reps[1]) == "table" then
		local v = reps[1]
		local a = {}
		local function flatten(tbl)
			for val in all(tbl) do
				if #a > 100 then return end
				if type(val) == "table" then
					flatten(val)
				else
					add(a,val)
				end
			end
		end
		flatten(v)
		tbl_import(reps,a)
	end
end,"table valued support")

function is_absent(args,...)
	for arg in all({...}) do if not args[arg] then
		local warning = "Argument "..arg.." not found. Process terminated."
		log(warning)
		wlog(warning)
		args.halt = true
		return true
	end end
end

function read_key(key)
	return sbs(sbs(key,"SPACE"," "),"UNDER","_")
end

function get_bads_named(name,chk)
	local a = {}
	if name == "leader" then a = get_pieces(leader)
	elseif name == "all" then a = clone(bads)
	else
		for p in all(bads) do if p.name == name then add(a,p) end end
	end
	if chk then for p in all(a) do if not chk(p) then del(a,p) end end end
	return a
end
		

function warn()
	log("Glac Terminal is not loaded correctly!")
	wlog("Glac Terminal is not loaded correctly!")
	append("init_menu",bind(sfx,"wrong"),"glacies warning")
end

function scan()
	for mod in all(MODLIST) do
		if mod.title == "Glacies Module Terminal" then
			if not mod.active then
				warn()
			else
				for title,mod in pairs(MODS) do
					if mod.title == "Glacies Module Terminal" then warn() end
				end
			end
			return
		end
	end
	warn()
end

scan()