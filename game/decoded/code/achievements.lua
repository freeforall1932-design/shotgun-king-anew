require("code/achievements_data.lua")

-- SAVE
function init_achievements()

	
	local sel=SET.achsel or 0
	
	
	-- REMOVE CRT
	SET.crt = 0
	apply_options()

	-- BG
	local bg=mke()
	bg.dr=function()
		rectfill(0,0,MCW-1,MCH-1,1)
	end
	
	-- ICON
	local sz=64
	icon=mke(0,(MCW-sz)/2,(MCH-sz)/2)
	icon.dr=function(e,x,y)
		draw_icon(sel,x,y)
		local name=ACHIEVEMENTS[sel+1].id
		print(name, MCW/2-#name*2, y+70,3)

	end
	
	-- ARROW
	for i=0,1 do
		local e=mke(0,MCW/2+(i*2-1)*40, MCH/2)
		e.dr=function(e,x,y)
			spr(34-i*2,x-8,y-8)
		end
		local function f(n)
			--log("coucou")
			sel=(sel+n)%#ACHIEVEMENTS
			SET.achsel = sel
			save()
		end		
		b=mk_but(e.x-8,e.y-8,16,16,bind(f,i*2-1))
		
		--[[
		e.upd=function() 
			if btnp("leftStickX-") and i == 0 then
				f(i*2-1)
			end
			if btnp("leftStickX+") and i == 1 then
				f(i*2-1)
			end
		end
		--]]
		
	end
	
	---[[ EXPORT
	local bw,bh=32,9
	local mb=mke(0,(MCW-bw)/2,MCH-bh-8)
	local ov=false
	mb.dr=function(e,x,y)
		rectfill(x,y,x+bw-1,y+bh-1,ov and 5 or 3)
		local s="export"
		print(s,x+bw/2-#s*2,y+2,4)
	end
	local b=mk_but(mb.x,mb.y,bw,bh,export_icon_png)
	b.over=function() ov=true end
	b.out=function() ov=false end
	
	if not PC then
		mb.upd=function()
			if btnp("validate") then
				export_icon_png()
			end
			if btnp("reload") then
				export_trophy_desc_file()
			end
		end	
	end

	--]]
	
	
	mdr=function()
		foreach(ents,dre)
	end

end
function export_icon_png()

	local srf=newsrf("icon", 64,64)
	target(srf)
	for i=1,#ACHIEVEMENTS do
		cls()
		local col=ACHIEVEMENTS[i]
		draw_icon(i-1,0,0)	
		local name=col.id
		name=rep(name,"?","")
		srfshot("achievements/"..name,4,true)
		pal({0,1,2,3,3}, true)
		flip()
		srfshot("achievements/"..name.."_UNL",4,true)
		pal({1,2,3,4,5}, true)
		flip()
	end	
	delsrf("icon")
	target()
	
	export_steam_loc()
end


-- DRAW
function draw_icon(sel,x,y)
	spritesheet("achievements")
	sspr(0,0,64,64,x,y)
	
	--rectfill(x,y,x+sz-1,y+sz-1,2)
	local col=ACHIEVEMENTS[sel+1]
	
	if col.spr then
		sprgrid(64,64)
		spr(col.spr, x, y)
		sprgrid(16,16)
		spritesheet("gfx")
	elseif col.gun then
		sspr(192,0,64,64,x,y)
		spritesheet("weapons")
		--sspr(0,col.gun*24,96,24, x,y)
		local sc=.7
		local function f()
			asspr(0,col.gun*24,96,24,x+32,y+32,-.125,sc,sc)
		end
		brd(f,4)
		
	elseif col.rank then

		local n=col.rank-1		
		pal(5,1)		
		sspr(448,0,64,64,x,y)
		pal()
		local function f()			
			local dx=(n%10)*48
			local dy=flr(n/10)*32
			sspr(dx,192+dy,48,32,x+8,y+16)
		end
		brd(f,1)
		
	elseif col.sm then
		local px=(col.sm%32)*32
		local py=128+flr(col.sm/32)*32

		apal(1)
		sspr(px,py,32,32,x+2,y+2,64,64)
		pal()
		sspr(px,py,32,32,x,y,64,64)
		
	elseif col.cards then
		spritesheet("gfx")
		for i=1,3 do
			local ca=get_card(col.cards[i]) or {gid=59}
			local cx=x+7
			local cy=y+8
			if i==2 then
				cx=cx+24
			end
			if i==3 then
				cx=cx+12
				cy=cy+32-12
			end		
			dr_flip_card(cx,cy,ca,0,true)
		end
		
	end
	
	spritesheet("gfx")
	
end
function ach_desc(ach)
	if ach.cards then
		return get_lang("ach_cards_desc", {get_lang(ach.cards[1]), get_lang(ach.cards[2]), get_lang(ach.cards[3])})
	elseif ach.gun then
		return get_lang("ach_gun_desc")
	elseif ach.rank then
		return get_lang("ach_rank_desc", ach.rank)
	else
		return get_lang("ach_"..ach.id.."_desc")
	end
end

-- UNLOCKS
function check_collections()
	if MODDED then return false end

	local tbl={}
	for col in all(ACHIEVEMENTS) do 
		if col.cards then
			tbl[col.id]=clone(col.cards)	
		end
	end
	for ca in all(get_all_cards(true)) do
		for k,v in pairs(tbl) do
			del(v,ca.id)
		end
	end
	for k,v in pairs(tbl) do
		if #v==0 then
			trig_achievement(k)
		end
	end
end
function ach_event(id,trg)
	for col in all(ACHIEVEMENTS) do
		if col.chk==id and chk_achievement(col.id,trg) then
			trig_achievement(col.id)
		end
	end		
end
function chk_achievement(id,trg)
	if mode.id == "tutorial" or MODDED then return false end


	local function get_army()
		local a={}
		for i=0,20 do a[i]=0 end
		for b in all(bads) do a[b.type]=a[b.type]+1 end		
		return a
	end

	-- ON CARD
	if id=="FULL_SET" then
		local sum=0
		for sl in all(card_slots) do
			if sl.ca and sl.ca.team==0 then sum=sum+1 end
		end
		return sum>=10
	end
	if id=="WIZARD" then
		local sum=0
		for ca in all(get_all_cards()) do
			if ca.wand then sum=sum+1 end
		end
		return sum>=3
	end
	
	-- END_FLOOR
	if id=="MERCIFUL_RULER" then
		local a=get_index_table(hero.frags)
		return not a[0]
	end
	if id=="A_VELVET_GLOVE" then
		for n in all(hero.frags) do
			if n~=leader then return false end
		end
		return true
	end
	if id=="DELETED" then
		return mode.turns<=6
	end
	if id=="SQUARE_ALLEGIANCE" then
		return not hero.whited
	end
	if id=="INCARNATION" then
		return not hero.walked
	end	
	if id=="FINAL_ESCAPE" then
		return hero.deathcount_start and not hero.fail_final_escape
	end

	-- PIECE DEATH
	if id=="LIKE_FATHER_LIKE_SON" then
		return trg.type==5 and trg.mark.heir_impact	
	end
	if id=="HUMILIATION" then
		return trg.type==5 and trg.hop_death	
	end	
	if id=="HASTA_LA_VISTA_BABY" then
		return trg.type==4 and trg.iron
	end
	if id=="WORKPLACE_ACCIDENT" then
		return trg.falling and trg.type>0
	end	
	if id=="BULLFIGHTING" then
		return trg.suicide and trg.charge and trg.type==1
	end	
	if id=="BURIED_ALIVE" then
		return trg.type==leader and trg.bad and not trg.non_bond_dmg and trg.hp<=0
	end
	if id=="COLD_REGICIDE" then
		return trg.type==leader and trg.bad and hero.cloaked
	end
	
	-- PLAY
	if id=="HOW_IT_SHOULD_BE" then
		local a=get_army()
		return a[0]==8 and a[1]==2 and a[2]==2 and a[3]==2 and a[4]==1 and a[5]==1
	end
	if id=="SHE_IS_EVERYWHERE" then
		local a=get_army()		
		return a[4]>=5
	end	
	if id=="MORTAL_PERIL" then
		return #hero.sq.danger>=4
	end	
	if id=="PROJECTILE_DYSFUNCTION" then
		return chamber>stack.ammo_max
	end
	if id=="HOPE_THIS_HITS" then
		return get_spread()>=120
	end
	if id=="NINE_LIVES" then
		return mode.mist_rescue==9
	end
	if id=="YOUR_WIFE_MY_WIFE" then
		return hero.sq==start_sq and hero.lift and hero.lift.type==4
	end
	if id=="A_MIGHTY_FORTRESS" then
		local a=get_army()
		return a[3]>=6
	end
	if id=="UNDERPRESSURE_AMMO" then
		return get_firepower()==1
	end
	if id=="GLUTTONY" then
		return ammo+chamber>=20
	end
	if id=="BLOODBATH" then
		local sum=0
		for b in all(bads) do
			if b.bleed then sum=sum+1 end
		end
		return sum>=12
	end
	if id=="ANARCHY" then		
		local a=get_army()	
		return a[5]>=4		
	end
	if id=="HIPPOCRACY" then
		return perm["Commoner's Reign"]
	end
	if id=="WARDEN" then
		local sum=0
		for b in all(bads) do
			if b.jail then sum=sum+1 end
		end
		return sum>=8
	end

	if id=="KING_WARBAND" then
		local a={}
		for p in all_pieces() do
			if not p.bad then a[p.type]=1 end
		end
		return a[1] and a[2] and a[3]
	end
	if id=="OVERPOPULATION" then
		return get_ach_count("spawn")>=12
	end
	if id=="OBSCURANTISM" then
		local sum=0
		for sl in all(card_slots) do
			if sl.ca and sl.ca.team==0 and sl.ca.flipped then
				sum=sum+1
			end
		end
		return sum>=6
	end
	if id=="EXPULSION" then
		return get_ach_count("retire")>=4
	end
	if id=="UNITED_HANDS" then
		local a,sum={},0
		for b in all(bads) do
			local t=b.type
			if t==6 then t=5 end
			if not a[t] then
				a[t]=1			
				sum=sum+1
			end
		end
		return sum>=8		
	end


	-- WIN
	if id=="IRON_KING" then
		return not mode.fool
	end
	if id=="WIDOW" then
		local a=get_index_table(mode.frags)
		return not a[4]
	end	
	if id=="YOU_SHALL_NOT_PASS" then
		return not mode.pawn_promoted
	end	
	if id=="BLITZ" then
		return chrono_time<5*3600
	end	
	if id=="BULLET" then
		return chrono_time<2*3600
	end
	
end

ents_ach={}
ach_popup_list={}
no_popup=true

function ach_unlock(s)
	add(ach_popup_list,s,1)
	if no_popup then
		spawn_popup()
	end
end
function spawn_popup()
	no_popup=false
	local ma=4
	local s=get_lang("unlocked", get_lang(ach_popup_list[#ach_popup_list]))
	deli(ach_popup_list, #ach_popup_list)
	local pw=txtwidth(s)+ma*2
	local ph=5+2*ma
	local e=mke(0,(MCW-pw)/2,-ph)
	del(ents,e)
	add(ents_ach,e)
	
	e.dr=function(e,x,y)
		camera()
		local sz=2
		rectshade(x+sz,y+sz,pw,ph)
	
		rectfill(x,y,x+pw-1,y+ph-1,FORCE_DARK)
		rect(x,y,x+pw-1,y+ph-1,FORCE_MEDIUM)
		hdclear(x,y,x+pw-1,y+ph-1)	
		lprint(s,x+pw/2,y+ma,FORCE_BRIGHT,1)
	end
	
	-- SCROLL
	mv(e,0,ph+4,16)
	e.twcv=ease_out	
	local function back()
		local function kill_popup()
			del(ents_ach,e.wait)
			del(ents_ach,e)
			no_popup=true
			if #ach_popup_list > 0 then spawn_popup() end
		end

		mv(e,0,-ph-6,16,kill_popup)
		e.twcv=ease_in
	end
	e.wait=wait(180,back)
	del(ents,e.wait)
	add(ents_ach,e.wait)
end
function trig_achievement(id)
	if mode and mode.id == "tutorial" then return end
	if DEMO or MODDED or VISION then return end
	
	local found=ACHIEVEMENTS[id]
	if not found then return end

	if SHOW_ACH then log(id.." unlocked! ("..found..")") end

	if PSN then
		psn("unlock_trophy", found)
		DEN.achievements[id]=true
		--bset("achievements",found-1,0,1)
	elseif LIVE then
		live("set_achievement", found)
		DEN.achievements[id]=true
		--bset("achievements",found-1,0,1)
	else
		--local unlocked = bget("achievements",found-1,0)
		local unlocked = not DEN.achievements[id]
		
		local ach = ACHIEVEMENTS[found]
		if STEAM then
			steam("set_achievement", ach.steam)
		end
		
		if unlocked then
			if ach.rank then
				ach_unlock(get_lang("ach_rank", ach.rank))
			else
				ach_unlock(get_lang("ach_"..id))
			end
			
			--bset("achievements",found-1,0,1)
			DEN.achievements[id]=true
			--save_achievements() -- we have auto-save now
		end
	end
end

-- Ingame Counters
function ach_count(id,n)
	if id=="reset" then
		ach_c={}	
		return
	end	
	ach_c[id]=(ach_c[id] or 0)+(n or 1)
end
function get_ach_count(id)
	return ach_c[id] or 0
end

-- Steam
function export_steam_loc()

	local order={
		"SWARM",
		"LEGION",
		"SNIPER",
		"ASSASSIN",
		"STEROID",
		"TRIGGER_HAPPY",
		"SCAVENGER",
		"HAREM",
		"SOCIAL_DISTANCING",
		"RELIGION",
		"SECRET",
		"SECURITY_SERVICE",
		"INQUISITION",
		"MOBILITY",
		"BOUNDARIES",
		"MACHINE_GUN",
		"SURVIVOR",
		"DEMOLITION",
		"FULL_SET",
		"WIZARD",
		"COMPLETE",
		"AVENGED",
		"EXORCISED",
		"HORSEMEN OF THE APOCALYPSE",
		"ROYAL RETAINER",
		"THE FLOOR IS LAVA",
		"EMPEROR",
		"LATE TO THE PARTY",
		"UNEXPECTED ENTRANCE",
		"SWORDMAN",
		"CLIFFHANGER",
		"NINJA",
		"SLAUGHTER",
		"BENEVOLENCE",
		"BUILDER",
		"SOLOMON",
		"VICTORIA",
		"RAMESSES II",
		"RICHARD III",
		"MAKEDA",
		"MERCIFUL RULER",
		"A VELVET GLOVE",
		"DELETED",
		"SQUARE ALLEGIANCE",
		"INCARNATION",
		"LIKE FATHER LIKE SON",
		"HUMILIATION",
		"HASTA LA VISTA BABY",
		"HOW IT SHOULD BE",
		"SHE IS EVERYWHERE",
		"MORTAL PERIL",
		"PROJECTILE DYSFUNCTION",
		"HOPE THIS HITS",
		"NINE LIVES",
		"YOUR WIFE MY WIFE",
		"A MIGHTY FORTRESS",
		"UNDERPRESSURE AMMO",
		"GLUTTONY",
		"IRON KING",
		"WIDOW",
		"YOU SHALL NOT PASS",
		"BLITZ",
		"BULLET",
		"SUICIDE PACT",
		"OH NO !",
		"MR PRESIDENT !",
		"LIFEGUARD",
		"MMMMH DELICIEUX !",
		"RANK 1",
		"RANK 2",
		"RANK 3",
		"RANK 4",
		"RANK 5",
		"RANK 6",
		"RANK 7",
		"RANK 8",
		"RANK 9",
		"RANK 10",
		"RANK 11",
		"RANK 12",
		"RANK 13",
		"RANK 14",
		"RANK 15",
		"DANGEROUS LIFE",
		"NIGHTMARE ERA",
		"DRAUGHTS",
		"PUPPET MASTER",
		"HIDDEN CONSPIRATOR",
		"DECEIVER",
		"STARBURST",
		"DETENTION",
		"OUT OF TIME",
		"JEALOUSY",
		"DISCREET HOST",
		"FIRST AID",
		"ALEXANDER",
		"YVAN IV",
		"MARITAL PEACE",
		"END OF THE WORLD",
		"WORKPLACE ACCIDENT",
		"BULLFIGHTING",
		"BURIED ALIVE",
		"COLD REGICIDE",
		"FINAL ESCAPE",
		"HIPPOCRACY",
		"BLOODBATH",
		"ANARCHY",
		"WARDEN",
		"MIDNIGHT DANCE",
		"NEW JOB",
		
		"RANK 16",
		"RANK 17",
		"RANK 18",
		"RANK 19",
		"RANK 20",
		"ATTILA",
		"MONTEZUMA",
		"KING WARBAND",
		"OVERPOPULATION",
		"OBSCURANTISM",
		"EXPULSION",
		"UNITED HANDS",
		"DEATH SENTENCE",
		"KINDLED ATROCITY",
		"ARCHITECT OF RUIN",
		"SOVEREIGN OF THE MASS GRAVE",
		"CINDERLORD",
	}
	
	local achs={}
	for i,k in ipairs(order) do
		for j,ach in ipairs(ACHIEVEMENTS) do
			if ach.steam == k then
				achs[i]=ach
				break
			end
		end
	end

	local dont = {["catalan"]=true, ["galician"]=true, ["traditional_chinese"]=true, ["safe_english"]=true}
	local langs = {
		["simplified_chinese"] = "schinese",
		["portuguese"] = "brazilian"
	}

	local str = '"lang"\n{\n'
	for l in all(LANGUAGES) do
		if not dont[l] then
			str=str..'\t"'..(langs[l] or l)..'"\n\t{\n\t\t"Tokens"\n\t\t{\n'
			load_lang("english")
			load_lang(l)
			for i,ach in ipairs(achs) do
				local n=i-1
				if n>=2*32+2 then n=n+1 end
				local k="NEW_ACHIEVEMENT_"..(flr(n/32)+1).."_"..(n%32).."_"
				local nam=ach.rank and get_lang("ach_rank",ach.rank) or get_lang("ach_"..ach.id)
				str=str..'\t\t\t"'..k..'NAME"\t"'..nam..'"\n\t\t\t"'..k..'DESC"\t"'..ach_desc(ach)..'"\n'
			end
			str=str..'\t\t}\n\t}\n'
		end
	end
	str=str..'}\n'

	file("achievements/steam_loc_all.vdf", str)
end

-- Consoles
locale_ps = {
	{ lang="english", 				id = ""},
	{ lang="japanese", 				id = "_00"},
	{ lang="english", 				id = "_01"},
	{ lang="french", 				id = "_02"},
	{ lang="spanish", 				id = "_03"},
	{ lang="german", 				id = "_04"},
	{ lang="russian", 				id = "_08"},
	{ lang="korean", 				id = "_09"},
	{ lang="traditional_chinese",	id = "_10"},
	{ lang="simplified_chinese",	id = "_11"},
	{ lang="polish", 				id = "_16"},
	{ lang="ukrainian", 			id = "_30"},
}
locale = {
	{ lang="english", 				locale = "en-US"},
	{ lang="french", 				locale = "fr-FR"},
	{ lang="spanish", 				locale = "es-ES"},
	{ lang="german", 				locale = "de-DE"},
	{ lang="polish", 				locale = "pl-PL"},
	{ lang="russian", 				locale = "ru-RU"},
	{ lang="ukrainian", 			locale = "uk-UA"},
	{ lang="simplified_chinese",	locale = "zh-CN"},
	{ lang="korean", 				locale = "ko-KR"},
	{ lang="japanese", 				locale = "ja-JP"}
}
function export_localized_strings()
	local str=""
	str = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
	str = str .. "<Localization xmlns=\"http://config.mgt.xboxlive.com/schema/localization/1\">\n"
	str = str .. "    <DevDisplayLocale locale=\"en-US\" />\n"
	str = str .. "\n"
	for i=1,#ACHIEVEMENTS do
		local ach=ACHIEVEMENTS[i]
		local ach_desc = ""
		
		str = str .. "    <LocalizedString id=\"AchievementNameId_"..ach.id.."\">\n"
		for i=1,#locale do
			load_lang_nofont(locale[i].lang)
			local ach_name = ""
			if ach.rank then
				ach_name = get_lang("ach_rank", ach.rank)
			else
				ach_name = get_lang("ach_"..ach.id)
			end
			str = str .. "        <Value locale=\""..locale[i].locale.."\">"..ach_name.."</Value>\n"
		end
		str = str .. "    </LocalizedString>\n"





		local descs = ""
		for i=1,#locale do
			load_lang_nofont(locale[i].lang)
			local ach_desc = ""
			if ach.cards then
				ach_desc = get_lang("ach_cards_desc", {get_lang(ach.cards[1]), get_lang(ach.cards[2]), get_lang(ach.cards[3])})
			elseif ach.gun then
				ach_desc = get_lang("ach_gun_desc")
			elseif ach.rank then
				ach_desc = get_lang("ach_rank_desc", ach.rank)
			else
				ach_desc = get_lang("ach_"..ach.id.."_desc")
			end
			descs = descs .. "        <Value locale=\""..locale[i].locale.."\">"..ach_desc.."</Value>\n"
		end
		
		str = str .. "    <LocalizedString id=\"UnlockedDescriptionId_"..ach.id.."\">\n"
		str = str .. descs
		str = str .. "    </LocalizedString>\n"
		str = str .. "    <LocalizedString id=\"LockedDescriptionId_"..ach.id.."\">\n"
		str = str .. descs
		str = str .. "    </LocalizedString>\n"

		_log(i .. "/" .. #ACHIEVEMENTS)
	end


	str = str .. "    <!--Featured Stats-->\n"
	str = str .. "    <LocalizedString id=\"HERO_BestEndless\">\n"
	str = str .. "        <Value locale=\"en-US\">Best floor in endless mode</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "    <LocalizedString id=\"HERO_HighscoreChase\">\n"
	str = str .. "        <Value locale=\"en-US\">Highscore in chase mode</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "\n"
	str = str .. "    <!--Rich Presence-->\n"
	str = str .. "    <LocalizedString id=\"Presence_RP_menu\">\n"
	str = str .. "        <Value locale=\"en-US\">In the menu</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "    <LocalizedString id=\"Presence_RP_tutorial\">\n"
	str = str .. "        <Value locale=\"en-US\">In the tutorial</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "    <LocalizedString id=\"Presence_RP_throne\">\n"
	str = str .. "        <Value locale=\"en-US\">In throne mode - Rank {0}</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "    <LocalizedString id=\"Presence_RP_endless\">\n"
	str = str .. "        <Value locale=\"en-US\">In endless mode - At floor {0}</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "    <LocalizedString id=\"Presence_RP_chase\">\n"
	str = str .. "        <Value locale=\"en-US\">In chase mode</Value>\n"
	str = str .. "    </LocalizedString>\n"
	str = str .. "</Localization>"

	
	file("out.txt", str)
end
function export_trophy_desc_file()
	local str = ""
	local indent_str = ""
	local function append(line)
		str = str .. indent_str .. line .. "\n"
	end
	local function indent()
		indent_str = indent_str .. " "
	end
	local function unindent()
		indent_str = sub(indent_str, 2)
	end
	local function get_id(id)
		return format("%03d", id)
	end

	append('<?xml version="1.0" encoding="utf-8"?>')
	append('<trophytrp fmt_ver="3" attribute="2" service_label="0">')
	indent()
		append('<file name="TROPCONF.SFM" path="">')
		indent()
			append('<trophyconf version="1.1" platform="ps4" policy="large">')
				indent()
				append('<npcommid>AAAA00000_00</npcommid>')
				append('<trophyset-version>01.00</trophyset-version>')

				append('<trophy id="000" hidden="no" ttype="P" pid="000"/>')
				for i=1,#ACHIEVEMENTS do
					append('<trophy id="'.. get_id(i) ..'" hidden="no" ttype="'.. ACHIEVEMENTS[i].type ..'" pid="000"/>')
				end
				unindent()
			append('</trophyconf>')
		unindent()
		append('</file>')


		for i=1,#locale_ps do
			load_lang_nofont(locale_ps[i].lang)
			
			append('<file name="TROP'.. locale_ps[i].id ..'.SFM" path="">')
			indent()
				append('<trophyconf version="1.1" platform="ps4" policy="large">')
					indent()
						append('<title-name>Shotgun King: The Final Checkmate</title-name>')
						append('<title-detail>Achievements for Shotgun King: The Final Checkmate</title-detail>')
	
						append('<trophy id="000">')
						indent()
							append('<name>'.. get_lang("ach_PLATINIUM") ..'</name>')
							append('<detail>'.. get_lang("ach_PLATINIUM_desc") ..'</detail>')
						unindent()
						append('</trophy>')

						for i=1,#ACHIEVEMENTS do
							local ach=ACHIEVEMENTS[i]
							local ach_name = ""
							local ach_desc = ""

							if ach.rank then
								ach_name = get_lang("ach_rank", ach.rank)
								ach_desc = get_lang("ach_rank_desc", ach.rank)
							elseif ach.gun then
								ach_name = get_lang("ach_"..ach.id)
								ach_desc = get_lang("ach_gun_desc")
							else
								ach_name = get_lang("ach_"..ach.id)
								ach_desc = get_lang("ach_"..ach.id.."_desc")
							end


							append('<trophy id="'..get_id(i)..'">')
							indent()
								append('<name>'.. ach_name ..'</name>')
								append('<detail>'.. ach_desc ..'</detail>')
							unindent()
							append('</trophy>')
						end
					unindent()
				append('</trophyconf>')
			unindent()
			append('</file>')
		end

		append('<file name="ICON0.PNG" path="..\\..\\..\\SUGAR\\platform-assets\\orbis\\trophies_images\\ICON0.png" />')
		for i=0,#ACHIEVEMENTS do
			append('<file name="TROP'..get_id(i)..'.PNG" path="..\\..\\..\\SUGAR\\platform-assets\\orbis\\trophies_images\\TROP'..get_id(i)..'.png" />')
		end

	unindent()
	append('</trophytrp>')

	file("trophy_desc.trx", str)
end
