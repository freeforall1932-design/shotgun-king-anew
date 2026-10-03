function get_blue()
	local plt = palette()
	for k,v in pairs(plt) do if v == 0xdfff then
		blue = k
		return
	end end
	add(plt,0xdfff)
	palette(plt)
	blue = #plt
end

get_blue()

for i,v in ipairs(MODLIST) do if v.title == "Royal Card Lab" then
	mod_index,mod = i,v
	break
end end

newsrf("cards.png", "wild_card")
newbnk(128,64,4)

local new_cards = {
	{ gid=0, spsheet="wild_card", team=0, n=1, pwe=0, id="Black Wild Card",		wild=1	},
	{ gid=1, spsheet="wild_card", team=1, n=1, pwe=0, id="White Wild Card",		wild=1	},
}

concat(CARDS, new_cards)

function on_card_but_init(but,ca)
	if ca.wild then
		local left_clic = but.left_clic
		function but.left_clic()
			if btn("unsafe") then exe(left_clic)
			elseif mode.unlimited then
				remove_buts()
				local slot_cards = {}
				local real_slot_cards = get_slot_cards(true)
				for i = 1,#real_slot_cards do
					add(slot_cards,real_slot_cards[i])
					if real_slot_cards[i] == ca then
						wild_card = i
					else
						real_slot_cards[i].turn_count = 0
					end
				end
				init_codex()
				del(ents,ents[5])
				local ent = ents[3]
				local upd = ent.upd
				ent.upd = function(...)
					if not btn("cancel") then
						return upd(...)
					end
				end
				local selected = nil
				for i = 2,#codex.ents,2 do
					local but = codex.ents[i]
					if but.iscodexcard then
						local codex_card = codex.ents[i-1]
						codex_card.locked = nil
						codex_card.played = 1
						if ca.team == codex_card.team then
							local id = codex_card.id
							local f = but.left_clic
							but.left_clic = function(...) if codex_mode == "codex" then
								if selected ~= id then
									selected = id
									f(...)
									return
								end
								init_game()
								-- new_level()
								mode.lvl = mode.lvl - 1
								mode.next_floor()
								mode.turns = 0
								exe(mode.enable_jump)
								for sq in all(squares) do
									sq.c_deep = nil
								end
								local ca = new_card(id)  -- code by Glacies
								ca.wild = 1
								slot_cards[wild_card] = ca
								for ca in all(slot_cards) do
									if ca ~= slot_cards[wild_card] then add(ents,ca) end
									add_card(ca)
								end end
							end
						end
					end
				end
			else
				remove_buts()
				mode.add_wild = true
				tear_apart(ca,bind(add_any_card,{team=ca.team},play))
				for oca in all(cards.pool) do
					if oca.id == ca.id then
						ca.n = ca.n + 1
						return
					end
				end
				local oca = clone(get_card(ca.id),true)
				oca.n = 1
				add(cards.pool,oca)
			end
		end
	end
end

append("add_card",function(ca) if mode.add_wild then
	mode.add_wild = false
	ca.wild = 1
end end,"card lab")


local lab,endless = 0,1
local v1513b = 1
function on_menu_but_init(but,id)
	if (id == mod_index..". card lab" and (bget(0,lab) or 0)<v1513b) or 
	(id == mod_index..". endless lab" and (bget(0,endless) or 0)<v1513b) then
		local dr = but.dr
		function but.dr(e,x,y)
			dr(e,x,y)
			lprint(lang.new_content, x+66, y+3+cyc(2,12), 5 )
		end		
	end
end

chinese = {
	["Black Wild Card"] = "黑色百变卡",
	["White Wild Card"] = "白色百变卡",

	[mod_index..". card lab"] = "卡牌实验室",
	[mod_index..". card lab_desc"] = "卡牌实验室|百变卡可变为任意其他同色卡牌|用百变卡来测试不同卡组吧！",
	[mod_index..". endless lab"] = "无尽实验室",
	[mod_index..". endless lab_desc"] = "无尽实验室|在无尽模式中测试卡组",
	-- [mod_index..". beta lab"] = "Beta实验室",
	-- [mod_index..". beta lab_desc"] = "Beta实验室|在Beta王座中测试卡组",
	
	effect_wild = "此卡为百变卡，点击可切换卡片效果",

	jump_to_boss = "跳转到第12层",
	unlimited_desc = "无限制模式|回到旧版实验室，你可以无限获取同一张卡牌并无视互斥|这可能导致游戏崩溃|你无法退出无限制模式",

	signature = "作者：冰凌",
	new_content = "有更新！"
}

english = {
	["Black Wild Card"] = "Black Wild Card",
	["White Wild Card"] = "White Wild Card",

	[mod_index..". card lab"] = "Card Lab",
	[mod_index..". card lab_desc"] = "Card Lab|Play with wild cards that can be used as any card|Use them to try different builds!",
	[mod_index..". endless lab"] = "Endless Lab",
	[mod_index..". endless lab_desc"] = "Endless Lab|Test cards in endless mode",
	-- [mod_index..". beta lab"] = "Beta Lab",
	-- [mod_index..". beta lab_desc"] = "Beta Lab|Test cards in Beta throne",	

	effect_wild = "This card is a wild card - click to change effect",

	jump_to_boss = "Jump to F12",
	unlimited_desc = "Unlimited Mode|Return to the old card lab where you can have any number of copies of the same card and ignore card exclusions|Might cause crash|You can't turn it off",

	signature = "Modder:Glacies",
	new_content = "NEW!!"
}

function add_lang(s)
	tbl_import(lang,s=="simplified_chinese" and chinese or english)
end

add_lang(current_lang)
append("load_lang",add_lang,"card lab")

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
