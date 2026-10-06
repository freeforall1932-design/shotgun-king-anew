function get_blue()
	local plt = palette()
	for k,v in pairs(plt) do if v == 0xdfff then
		blue = k-1
		return
	end end
	add(plt,0xdfff)
	palette(plt)
	blue = #plt-1
end

get_blue()
signature = "the art of war"

-- for i,v in ipairs(MODLIST) do
-- 	if v.title == "The Art of War" then
-- 	mod_index,mod = i,v
-- 	break
-- end end

newsrf("the art of war: cards","cards.png")
newsrf("the art of war: gfx","gfx.png")

newsfx("shout","sfx/shout.wav")
newsfx("drum1","sfx/drum1.wav")
newsfx("drum2","sfx/drum2.wav")

local bundles = {
	art_of_war = 1,

	bundle_lastResort = {"flip","boost_firepower","boost_firerange","ifHero_burn","sfx_shout","refresh","pfcz"},
	bundle_drumbeat = {"flip","not_ifFullChamber_reload","morale","refresh"},
	bundle_await1 = {"reload","halt"},
	bundle_await = {"skipturn","boost_firepower","boost_spread","ifHero_burn","not_ifFullChamber_ifAmmo_await1",
	"not_ifFullAmmo_if_stack_ammoUNDERregen_setValue_ammoUNDERregen_ammo"},
}
tbl_import(TEST_STACK,bundles)

local new_cards = {
	-- BLACK
	{ gid=0, team=0, n=1, pwe=4, id="Break Your Cauldrons and Sink Your Boats", firepower=1, spread=12,
	click_not_if_ca_flipped_lastResort={1,5,1,30,1,10}, },

	{ gid=1, team=0, n=1, pwe=4, id="So in Warfare There Are No Constant Conditions", bwcs=1,
	firepower=-1, spread=-45, firerange=1, click_not_if_ca_flipped_replace="Just as Water Retains No Constant Shape" },
	{ gid=2, team=0, n=1, pwe=0, id="Just as Water Retains No Constant Shape", swcx=1, 
	played=get_stats("So in Warfare There Are No Constant Conditions","played"),
	ignored=get_stats("So in Warfare There Are No Constant Conditions","ignored"),
	firepower=2, spread=35, firerange=-1, click_not_if_ca_flipped_replace="So in Warfare There Are No Constant Conditions" },
	
	{ gid=3, team=0, n=1, pwe=4, id="The First Drumbeat Excites Morale", 
	click_not_if_ca_flipped_drumbeat=1 },

	{ gid=4, team=0, n=1, pwe=4, id="Await the Exhausted Enemy at Your Ease", 
	click_not_if_ca_flipped_ifPass_await={1,1,-7,20,1,1} },

	{ gid=5, team=0, n=1, pwe=4, id="Know Your Enemy and Know Yourself",
	click_not_if_ca_flipped_predict=1, predict=2, rclick_not_if_ca_flipped_cancelPredict=1 },

	{ gid=6, team=0, n=1, pwe=4, id="Rapidity Is The Essence of War", steed=1, --nflip_resetRapid=1, 
	period_1_rapidity=4, black_king_fitness=1 },

	{ gid=7, team=0, n=1, pwe=4, id="Lure the Tiger Out of the Mountains", 
	click_not_if_ca_flipped_ifPass_exile=7, },	
	
	-- { gid=8, team=0, n=1, pwe=0, id="Make a Feint to the East While Attacking in the West",  },

	-- WHITE
	{ gid=10, team=1, n=1, pwe=6, id="Remove the Firewood from Under the Cauldron", floor_min=2, ammo_max=-1, 
	turn_5_removeFirewood=2, },

	{ gid=11, team=1, n=1, pwe=6, id="Appear Where You Are Not Expected", period_1_rnd_18_cqby=1, cqby=1, },
	
	{ gid=12, team=1, n=1, pwe=6, id="Besiege Wei to Rescue Zhao", floor_min=3,
	wwjz=1, click_not_if_ca_flipped_ifPass_antisubotage=1, cycle=1, delay=4, delayed={wwjz_desc=1}, },
	
	{ gid=13, team=1, n=1, pwe=6, id="Hearing Chu's Songs from All Four Sides", 
	flip_on="not_besieged", firepower=-2 },
	
	-- { gid=12, team=1, n=1, pwe=0, id="Never Load Your Supply Wagons More Than Twice", 
	-- all_shell=2, turn_1_ammocut=3, noregen=1 },
}

for ca in all(new_cards) do
	ca.spsheet = "the art of war: cards"
	-- ca.tactic_card = 1

	if ca.pwe ~= 0 then
		-- ca.pwe = ca.team==0 and 16 or 28
	end

	ca.pwe = ca.pwe * 1.5
end

concat(CARDS, new_cards)

-- local lab,endless = 0,1
-- local v1513b = 1
-- function on_menu_but_init(but,id)
-- 	if (id == mod_index..". card lab" and (bget(0,lab) or 0)<v1513b) or 
-- 	(id == mod_index..". endless lab" and (bget(0,endless) or 0)<v1513b) then
-- 		local dr = but.dr
-- 		function but.dr(e,x,y)
-- 			dr(e,x,y)
-- 			lprint(lang.new_content, x+66, y+3+cyc(2,12), 5 )
-- 		end		
-- 	end
-- end

chinese = {
	["Break Your Cauldrons and Sink Your Boats"] = "破釜沉舟",
	["So in Warfare There Are No Constant Conditions"] = "兵无常势",
	["Just as Water Retains No Constant Shape"] = "水无常形",
	["The First Drumbeat Excites Morale"] = "一鼓作气",
	["Await the Exhausted Enemy at Your Ease"] = "以逸待劳",
	["Know Your Enemy and Know Yourself"] = "知己知彼",
	["Rapidity Is The Essence of War"] = "兵贵神速",
	["Lure the Tiger Out of the Mountains"] = "调虎离山",

	["Remove the Firewood from Under the Cauldron"] = "釜底抽薪",
	["Appear Where You Are Not Expected"] = "出其不意",
	["Besiege Wei to Rescue Zhao"] = "围魏救赵",
	["Hearing Chu's Songs from All Four Sides"] = "四面楚歌",
	-- [""] = "",

	effect_click_not_if_ca_flipped_lastResort = "点击此卡：翻面，下次开火+$1火力、+$2射程",
	effect_bwcs = "点击此卡切换为水无常形",
	effect_swcx = "点击此卡切换为兵无常势",
	effect_click_not_if_ca_flipped_drumbeat = "点击此卡：翻面，立即装弹并获得<鼓舞>状态|鼓舞：持续一回合，火力+2，击杀敌人后的下一回合开始时装填一发子弹并获得<鼓舞>",
	effect_click_not_if_ca_flipped_ifPass_await = "点击此卡：结束此回合（仍会装弹或获得弹药），下次开火+$1火力、$2$散射",
	effect_click_not_if_ca_flipped_predict = "点击此卡选择一个白棋猜测其下回合位置（不能为其当前格），同时最多存在两个猜测且不能猜测同一种棋子"..
	"|回合开始时依次验证，被猜中的棋子受到1点伤害|此外，两个猜测全对时晕眩两个棋子一回合，两个猜测全错时本层-1火力|右键此卡取消所有猜测",
	effect_period_1_rapidity = "回合开始时，令黑王回合结束时额外行动一次|$0回合后翻面",
	effect_click_not_if_ca_flipped_ifPass_exile = "点击此卡：翻面，结束回合并选择一个白棋移除|"..
	"$0回合后该棋子选择一个格子回归棋盘但清空行动条，同时此卡翻回",

	effect_turn_5_removeFirewood = "第5回合开始时，随机翻面两张黑卡，然后选择一张被翻面的卡翻回",
	effect_period_1_rnd_18_cqby = "某回合开始时，一个马登场",
	effect_wwjz_desc = "随机翻面一张黑卡|点击此卡：结束回合，翻回所有被此卡翻面的卡并重置此卡倒计时",

	refresh_when_come_back = "被调虎离山的棋子于第$0回合返回棋盘时",
	cond_not_besieged = "黑王移动范围内有安全格",
	cond_subotaged = "受到敌方干扰",

	too_many_predictions = "已达猜测上限",
	predict_where = "选择一个格子",
	unflip_a_card = "翻回一张卡",

	-- terminal_warning = "冰凌中枢未正确安装！",
	-- collection_warning = "冰凌扩展包未正确安装！",
	the_art_of_war_collection_warning = "冰凌扩展包须在孙子兵法下方",
	the_art_of_war_terminal_not_loaded = "孙子兵法mod：冰凌中枢未启动",
	the_art_of_war_terminal_not_after = "孙子兵法mod须在冰凌中枢上方",
}

english = {
	["Break Your Cauldrons and Sink Your Boats"] = "Break Your Cauldrons and Sink Your Boats",
	["So in Warfare There Are No Constant Conditions"] = "So in Warfare There Are No Constant Conditions",
	["Just as Water Retains No Constant Shape"] = "Just as Water Retains No Constant Shape",
	["The First Drumbeat Excites Morale"] = "The First Drumbeat Excites Morale",
	["Await the Exhausted Enemy at Your Ease"] = "Await the Exhausted Enemy at Your Ease",
	["Know Your Enemy and Know Yourself"] = "Know Your Enemy and Know Yourself",
	["Rapidity Is The Essence of War"] = "Rapidity Is The Essence of War",
	["Lure the Tiger Out of the Mountains"] = "Lure the Tiger Out of the Mountains",

	["Remove the Firewood from Under the Cauldron"] = "Remove the Firewood from Under the Cauldron",
	["Appear Where You Are Not Expected"] = "Appear Where You Are Not Expected",
	["Besiege Wei to Rescue Zhao"] = "Besiege Wei to Rescue Zhao",
	["Hearing Chu's Songs from All Four Sides"] = "Hearing Chu's Songs from All Four Sides",

	effect_click_not_if_ca_flipped_lastResort = "Click this card: flip, +$1 firepower and +$2 firerange on your next shot",
	effect_bwcs = "Click this card to switch to the other form",
	effect_swcx = "Click this card to switch to the other form",
	effect_click_not_if_ca_flipped_drumbeat = "Click this card: flip, reload and gain <morale> effect|"..
	"Morale: lasts for 1 turn, +2 firepower, and if you kill any enemy, load 1 shell and regain <morale> at the start of the next turn",
	effect_click_not_if_ca_flipped_ifPass_await = "Click this card: end your turn (you will still reload or gain ammo), "..
	"+$1 firepower and $2$ spread on your next shot",
	effect_click_not_if_ca_flipped_predict = "Click to predict where an enemy is on the next turn"
	.."|At most 2 predictions at same time, and not on pieces of same type"..
	"|Verified in order, each correct one deals 1 dmg to the piece"..
	"|Stun both pieces for 1 turn if both correct, and -1 firepower for this floor if both wrong"..
	"|Right click to cancel all predictions",
	effect_period_1_rapidity = "At the start of each turn, makes you gain an extra turn at the end of the turn|Flip card after $0 turn(s)",
	effect_click_not_if_ca_flipped_ifPass_exile = "Click this card: flip, end your turn and remove a white piece|"..
	"after $0 turn(s) the removed piece will choose a square to return (with full move cooldown), and unflip this card",

	effect_turn_5_removeFirewood = "At the start of turn 5, flips two random black cards, then you unflip a flipped black card",
	effect_period_1_rnd_18_cqby = "At the start of a random turn, a knight spawns on the board",
	effect_wwjz_desc = "Flips a random black card|Click this card: reset its countdown, unflip all cards flipped by this card and end your turn",

	refresh_when_come_back =  "when the removed piece returns on Turn $0",
	cond_not_besieged = "there is a safe square within your move range",
	cond_subotaged = "it is subotaged by the enemy",
	
	too_many_predictions = "Maximum predictions reached",
	predict_where = "Select a square",
	unflip_a_card = "Unflip a card",

	-- effect_tactic_card = "Tactic",
	terminal_warning = "Glac Terminal is not loaded correctly!",
	-- collection_warning = "Glacies' Collection is not loaded correctly!",
	the_art_of_war_collection_warning = "Glacies' Collection needs to be loaded above The Art of War!",
	the_art_of_war_terminal_not_loaded = "The Art of War: Glac Terminal is not active",
	the_art_of_war_terminal_not_after = "The Art of War must be loaded above Glac Terminal",
}

literal = {

}

alternative = {

}

local n = 1
for k,v in pairs(chinese) do
	if sub(k,1,7) == "effect_" then
		effect_order[sub(k,8)] = lang_sum + n
		n = n + 1
	end
end
-- effect_order["wwjz_desc"] = lang_sum
-- effect_order["tactic_card"] = -1

function add_lang(s)
	tbl_import(lang,s=="simplified_chinese" and chinese or english)
end

add_lang(current_lang)
append("load_lang",add_lang,signature)

function warn(txt)
	log(txt)
	wlog(txt)
	append("init_menu",bind(sfx,"wrong"),"glacies warning")
end

function get_collection()
	for title,mod in pairs(MODS) do
		if mod.title == "Glacies' Collection" then
			collection = mod.env
			effects = collection.effects
			return
		end
	end
	warn(lang.the_art_of_war_collection_warning)
	collection = {effects={}}
	effects = {}
end

function scan()
	for mod in all(MODLIST) do
		if mod.title == "Glacies Module Terminal" and mod.active then
			for title,mod in pairs(MODS) do
				if mod.title == "Glacies Module Terminal" then warn(lang.the_art_of_war_terminal_not_after) end
			end
			return
		end
	end
	warn(lang.the_art_of_war_terminal_not_loaded)
end

-- function scan_collection()
-- 	for mod in all(MODLIST) do
-- 		if mod.title == "Glacies' Collection" then
-- 			if not mod.active then
-- 				warn(lang.collection_warning)
-- 			end
-- 			return
-- 		end
-- 	end
-- 	warn(lang.collection_warning)
-- end

scan()
get_collection()
-- scan_collection()

function effects.pfcz(args)
	hero.pfcz = true
end

function effects.morale(args)
	hero.morale = 1
	hero.morale_kept = nil
	hero.c_burning = 30
	sfx(rnd{"drum1","drum1"})
	build_stack()
end

function effects.predict(args)
	if hero.predictions and #hero.predictions >= stack.predict then
		fx_wrong(lang.too_many_predictions)
		return
	end
	sfx("wand")
	remove_buts()

	local function chk(p)
		return not hero.predictions or not hero.predictions[tostr(p.type)]
	end
	local function select(p)
		local e = mke()
		e.dp = DP_SHADES
		function e.dr()
			local sq = get_square_at(mx,my)
			if sq and sq ~= p.sq then
				spritesheet("the art of war: gfx")
				spr(0,sq.x,sq.y)
				spritesheet("gfx")
			end
		end

		local function clean()
			kl(e)
			set_instructions()
		end
	
		for sq in all(squares) do
			local function click()
				if sq ~= p.sq then
					if not hero.predictions then
						hero.predictions = {}
					end
					hero.predictions[tostr(p.type)] = true
					add(hero.predictions,{p=p,sq=sq})
					sfx("disguise")
					remove_buts()
					wait(10,play)
					
					clean()
				end
			end
			but = mk_sq_but(sq,click)
		end
		scan_cancel(clean)
		set_instructions(lang.predict_where)
	end
	local function no_trg()
		fx_wrong(lang.no_valid_target)
		wait(10,play)
	end
	ask_piece(chk,function(p) wait(2,select,p) end,no_trg)
end

function effects.cancelPredict(args)
	hero.predictions = {}
	sfx("cancel")
end

function effects.rapidity(args)
	if hero.rapid_count and hero.rapid_count >= args.v then
		local ca = get_card_with("period_1_rapidity")
		flip_card(ca)
		sfx("unsoul")
		hero.rapid_count = nil
		return
	end
	hero.rapid_count = (hero.rapid_count or 0) + 1
	hero.second_move = 1
	-- add_soul(1)
end

function effects.resetRapid(args)
	-- hero.rapid_count = nil
end

function effects.exile(args)
	remove_buts()
	sfx("wand")
	local function chk(p)
		return not p.big
	end
	local function select(p)
		flip_card(args.ca)
		args.ca.dhls = 1
		p.cd = 0
		p.ready = false
		fx_ascend(p,opp_turn)
		sfx("retire")
		if not hero.exile then hero.exile = {} end
		add(hero.exile,{p=p, ca=args.ca, turn=mode.turns+args.v})

		-- ACHIEVEMENTS
		if MOD then return end
		if #hero.exile >= 2 then trig_achievement("BBYZ") end
		if p.type == 0 and p.promote then trig_achievement("NQCZ") end
	end
	local function no_trg()
		fx_wrong(lang.no_valid_target)
		wait(10,play)
	end
	ask_piece(chk,select,no_trg)
end

function effects.removeFirewood(args)
	local function flip()
		local cards = {}
		for sl in all(card_slots) do
			local ca = sl.ca
			if ca and ca.team==0 and not ca.disrupted and (not ca.flipped or ca.flip_on) then
				add(cards,ca)
			end
		end
		for i=1,args.v do
			local ca = steal(cards)
			if ca then
				flip_card(ca)
				ca.disrupted = true
				ca.removed_firewood = 1
			else
				break
			end
		end
		local function chk(ca)
			return ca.flipped and (ca.disrupted or not ca.flip_on) and ca.team==0
		end
		local e = mke()
		e.dp = DP_INTER
		e.dr = function()
			if t%60<30 and MOUSE then
				for sl in all(card_slots) do
					local ca = sl.ca
					if ca and ca.selectable and ca.flip_co==1 then
						rect(ca.x+1,ca.y,ca.x+21,ca.y+28,5)
					end
				end
			end
		end
		set_instructions(lang.unflip_a_card)
		local function unflip(ca)
			-- ACHIEVEMENTS
			if not ca.removed_firewood and not MOD then
				trig_achievement("JJJJ")
			end

			kl(e)
			set_instructions()
			ca.disrupted = nil
			ca.removed_firewood = nil
			unflip_card(ca)
			wait(30,event_nxt)
		end
		wait(30,ask_card,chk,unflip)
	end
	add_event(show_card,"Remove the Firewood from Under the Cauldron",flip,60)
end

function effects.cqby(args)
	if mode.turns >= 4 then
		local sqs = {}
		for i=1,#KNIGHT_MOVES,2 do
			local x,y = KNIGHT_MOVES[i], KNIGHT_MOVES[i+1]
			local sq = gsq(hero.sq.px+x,hero.sq.py+y)
			if is_free(sq) then
				add(sqs,sq)
			end
		end
		local sq = steal(sqs)
		if sq then
			local function spawn()
				fx_spawn(new_piece(1,true,sq))
				flip_card(get_card_with("cqby"))
				wait(30,event_nxt)
			end
			add_event(show_card,"cqby",spawn,60)
		end
	end
end

function effects.ammocut(args)
	sfx("disrupt")
	ammo = args.v
end

function effects.subotage(args)
	local cards = {}
	for sl in all(card_slots) do
		local ca = sl.ca
		if ca and ca.team==0 and not ca.disrupted and (not ca.flipped or ca.flip_on) and not ca.wand then
			add(cards,ca)
		end
	end
	if #cards == 0 then
		-- wait(5,event_nxt)
		return
	end
	local ca = rnd(cards)
	flip_card(ca)
	ca.disrupted = true
	ca.subotaged = 1
end

function effects.antisubotage(args)
	remove_buts()
	sfx("wand")
	args.ca.turn_count = 0
	for sl in all(card_slots) do
		local ca = sl.ca
		if ca and ca.subotaged then
			ca.disrupted = nil
			ca.subotaged = nil
			unflip_card(ca)
			break
		end
	end
	wait(30,opp_turn)
end

-- ACHIEVEMENTS
-- function effects.smcg(args)
	-- if MOD or not hero or not hero.sq or not ingame then return end
	-- if not hero.besieged then hero.besieged = {} end
	-- local turn = (mode.turns or 0) + args.v
	-- if not tbl_has(hero.besieged,turn) then
	-- 	add(hero.besieged,turn)
	-- 	log(turn)
	-- end
-- end

append("build_stack",function()
	if hero and hero.morale then
		-- stack.firepower = stack.firepower+2
		for sq in all(squares) do
			sq.stack.firepower = (sq.stack.firepower or 0) + 2
		end
	end
end,signature)

prepend("opp_turn",function()
	-- Rapidity
	if hero.second_move then
		hero.second_move = nil
		earn_extra_turn()
	end
end,signature)

append("ach_event",function(id)
	-- ACHIEVEMENTS
	if MOD or id ~= "play" then return end
	local ca = get_card_with("Hearing Chu's Songs from All Four Sides")
	if ca and not ca.flipped and hero then
		if not hero.besieged then hero.besieged = {} end
		if tbl_has(hero.besieged,mode.turns) then return end
		add(hero.besieged,mode.turns)
		-- log(mode.turns)
	end
end,signature)
append("set_mode",function()
	-- ACHIEVEMENTS
	if MOD then return end
	local f = mode.on_hero_death
	function mode.on_hero_death(...)
		if hero.besieged and #hero.besieged >= 5 then
			trig_achievement("BWBJ")
		end
		f(...)
	end
end,signature)

append("new_turn",function()
	if hero.second_move then
		local remove_shields = {shields=-shields}
		uplift(remove_shields)
		del(temporary,remove_shields)
	end
end,signature)

-- Stop ammo regen
append("wait",function(t,f)
	if f == inc_ammo and stack.noregen then
		local e = ents[#ents]
		-- e.nxt = nil
		del(ents,e)
	end
end,signature)

-- 围魏救赵翻面
append("ev_backup",function(ca)
	if ca.wwjz then
		collection.trigger("subotage")
	end
end,signature)

-- 兵无常势/水无常形 双重显示
append("mk_hint_but",function(x,y,w,h,str,c)
	if leveling and w==24 and h==32 and c and #c==2 then
		local but = ents[#ents]
		if but.x == x and but.y == y then
			local ch
			for e in all(ents) do
				if e.cards and e.y+e.cards[1].y == y then
					ch = e
					break
				end
			end
			if not ch then return end
			local xx = x-ch.x
			local ca
			for tca in all(ch.cards) do
				if tca.x == xx then
					ca = tca
					break
				end
			end
			if not ca then return end

			if ca.bwcs then
				local over = but.over
				function but.over()
					local ca = get_card("Just as Water Retains No Constant Shape")
					show_hint(get_lang(ca.id).."|"..get_desc(ca),{4,3})
					local odr = hint_box.dr
					hide_hint()

					over()

					local dr = hint_box.dr
					function hint_box.dr(e,x,y)
						dr(e,x,y)
						odr(e,x+100,y)
					end
				end
			end
		else
			-- Failsafe
			log("HINT BUTTON ERROR")
		end
	end
end,signature)

--[[
-- Blue Tactic tag
prepend("show_hint",function(str,c)
	if c and #c==2 and c[1]==4 and c[2]==3 then
		local str = (type(str)=="function" and str() or str)
		local descs = split(str,"|")
		-- record(descs)
		if descs[2] == get_lang("effect_tactic_card") then
			add(c,blue,2)
		end
	end
end,signature)
]]

prepend("get_desc",function(ca)
	if ca.subotaged then
		ca.flip_on_ = ca.flip_on
		ca.flip_on = "subotaged"
	elseif ca.dhls and hero.exile then
		lang.refresh_when_ = lang.refresh_when
		lang.refresh_when = get_lang("refresh_when_come_back",hero.exile[1].turn)
	end
end,signature)

append("get_desc",function(ca)
	if ca.flip_on_ then
		ca.flip_on = ca.flip_on_
		ca.flip_on_ = nil
	elseif ca.dhls then
		lang.refresh_when, lang.refresh_when_ = lang.refresh_when_
	end
end,signature)

append("new_level",function()
	for ca in all(get_slot_cards(true)) do
		ca.subotaged = nil
		ca.dhls = nil
	end
end,signature)

-- ACHIEVEMENTS
append("add_card",function()
	if MOD then return end
	local tactic = 0
	for ca in all(get_slot_cards(true)) do
		if ca.spsheet == "the art of war: cards" then
			tactic = tactic + 1
		end
		if tactic >= 4 then
			trig_achievement("SBFM")
		end
	end
end,"art of war achievements")

prepend("end_level",function()
	if MOD then return end
	if hero.pfcz then
		trig_achievement("SEHS")
	end
	if (mode.turns or 0) <= 5 then
		trig_achievement("QJRF")
	end
end,"art of war achievements")

append("check_collections",function()
	if MOD then return end
	local achievements = {
		RAMPAGE = {"The First Drumbeat Excites Morale","Wand of Execution"},
		TAKE_A_BREAK = {"The First Drumbeat Excites Morale","Sacred Crown"},
		FORESEEN = {"Know Your Enemy and Know Yourself","Seer's Orb"},
		WARM_UP_EXERCISE = {"Rapidity Is The Essence of War","Unholy Call"},
	}

	for id,cards in pairs(achievements) do
		if perm[cards[1]] and perm[cards[2]] then
			trig_achievement(id)
		end
	end
end,signature)

function on_bad_death(e)
	if hero.morale then
		hero.morale_kept = 1
	end
end

function on_new_turn()

	-- 破釜沉舟 成就
	if not hero.win then
		hero.pfcz = nil
	end

	-- Regain morale or lose morale
	if hero.morale_kept then
		effects.load()
		effects.morale()

		hero.morale_extended = (hero.morale_extended or 0) + 1
		if hero.morale_extended >= 5 and not MOD then
			trig_achievement("SRPZ")
		end 
	elseif hero.morale then
		hero.morale = nil
		build_stack()
		
		hero.morale_extended = nil
	end

	-- Verify predictions
	if hero.predictions and not hero.win then
		local fail = 0
		for pred in all(hero.predictions) do
			if pred.p.sq == pred.sq then
				hit(pred.p,1,{direct=1,predict=1})
				
				if not hero.prediction_failed then
					hero.correct_prediction = (hero.correct_prediction or 0) + 1
					if hero.correct_prediction >= 10 and not MOD then
						trig_achievement("BZBD")
					end
				end
			else
				fail = fail + 1
			end
		end
		if fail > 1 then
			uplift({firepower=-1})
			hero.c_plague = 60
			sfx("water_poison")

			hero.prediction_failed = 1
		elseif fail == 0 and #hero.predictions >= 2 then
			for pred in all(hero.predictions) do
				pred.p.stun = max(2,(pred.p.stun or 0))
			end
		end
		hero.predictions = {}
	end

	-- Tigers come back
	if hero.exile then
		for ex in all(hero.exile) do
			if ex.turn <= mode.turns+1 then
				add_event(ev_coming_back,ex.p,ex.ca,ex)
			end
		end
	end
end

function ev_coming_back(p,ca,ex)
	unflip_card(ca)
	ca.dhls = nil
	p.dead = nil
	add(ents,p)
	add(bads,p)
	setup_piece(p)

	local grids = {}
	for sq in all(squares) do
		if is_free(sq) then
			local grid = mk_grid()
			grid.mov(p,sq)
			grid.sq = sq
			score_grid(grid,p)
			add(grids,grid)
		end
	end
	if #grids == 0 then
		wait(5,event_nxt)
		return
	end
	local function score(grid) return -grid.score end
	custom_sort(grids,score)
	goto_sq(p,grids[mid(1,irnd(6*(3-stack.ai_lvl))+1,#grids)].sq,0)

	fx_spawn(p)
	del(hero.exile,ex)
	wait(30,event_nxt)

end

function check_custom_flip(ca)
	if ca.flip_on == "not_besieged" then
		for sq in all(get_range(hero)) do
			if #sq.danger == 0 then
				return true
			end
		end
		if stack.flagstones then
			for sq in all(squares) do
				if sq.flagstone and is_free(sq) and #sq.danger == 0 then
					return true
				end
			end
		end
	end
end

function draw_4()
	-- Prediction Line
	if hero and hero.predictions and ingame then
		for pred in all(hero.predictions) do
			if pred.p.sq then
				dr_dot_line(pred.p,pred.sq)
			end
		end
	end
end

function draw_2()
	-- Prediction Square
	if hero and hero.predictions and ingame then
		for pred in all(hero.predictions) do
			if pred.p.sq then
				local sq = pred.sq
				spritesheet("the art of war: gfx")
				pal(5,3+sq.cl)
				spr(0,sq.x,sq.y)
				pal()
				spritesheet("gfx")
			end
		end
	end
end