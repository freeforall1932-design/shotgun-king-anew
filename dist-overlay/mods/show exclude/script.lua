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

local card
local xmax=8
local cdw=xmax*24	
local pw=MCW-(cdw+16)

local function dr_ext_pan(bpy,card)

	local ma,py=16,bpy+4
	if card.spsheet then ma = 12 end

	if not card then
		log("OMG this actually can happen? Pls report to Glacies")
		return pprint(lang.codex_select,pw/2,py,pw,2,1)
	end			
	
	-- FUNCS
	local function disp_list(key, tags)
		local a=card[key] or {}
		if #a>0 then
			py=py+2
			lprint(lang["codex_"..key]..":",pw/2,py,4,1,1)
			py=py+6
			for id in all(a) do
				local s=tags and ("tag_"..id) or id 
				lprint(get_lang(s),pw/2,py,3,1,1)
				py=py+6
			end
		end
	end

	--local function f()
	py=bpy+4

	-- PLAYED
	if card.spsheet then
		py = py - 2
	else
		lprint(lang.codex_played..":"..card.played,pw/2,py,2,1,1)
		py=py+8
	end

	-- CARD
	if card.spsheet == "the art of war: cards" then
		local y = pprint(get_lang(card.id),pw/2,py,pw-2*ma,4,1,nil,1)
		py = y-6
	else
		lprint(get_lang(card.id),pw/2,py,4,1,1)
	end
	dr_flip_card(pw/2-12,py+8,card,0,false)		
	py=py+40

	-- DESC
	local desc=get_desc(card)
	desc = sbs(desc, "|", "\n")
	desc = sbs(desc, "%$", lang.degree_symbol)
	local hy=pprint(desc,pw/2,py,pw-2*ma,3,1,nil,1)
	py=hy+2

	-- LOVE
	if not card.spsheet then
		local prc=flr(card.played*100/(card.played+card.ignored))
		lprint(lang.codex_love.." "..prc.."%",pw/2,py,5,1,1)
		py=py+6
	end

	-- py = py + 4

	-- FAMILY
	disp_list("tags", true)

	-- NEED
	disp_list("need_card")
	
	-- NEED TAG
	disp_list("need_tag", true)

	-- (NEW) NEED PIECES
	local title
	local army = {}
	for n in all(card.need) do
		army[n] = (army[n] or 0) + 1
	end
	for type,n in pairs(army) do
		if not title then
			title = true
			py = py + 2
			lprint(lang.codex_others..":",pw/2,py,blue-1,1,1)
			py=py+6
		end
		lprint(get_lang("other_needs_piece",{n,sbs(get_lang("piece_"..type),"%$leader",lang.tag_leader)}),pw/2,py,3,1,1)
		py=py+6
	end
	for k,v in pairs(card) do
		local k,targets=parse_effect(k)
		if targets.need and type(v) == "number" then
			if not title then
				title = true
				py = py + 2
				lprint(lang.codex_others..":",pw/2,py,blue-1,1,1)
				py=py+6
			end
			lprint(get_lang("other_needs",{v,get_lang(k)}),pw/2,py,3,1,1)
			py=py+6
		end
	end
	-- if title then py = py + 2 end

	-- EXCLUDE TAG
	disp_list("exclude_tag", true)

	-- (NEW) NON-TAG EXCLUDE
	local exclude = card.exclude or {}
	local title
	for id in all(exclude) do
		local excluded
		for tag in all(card.exclude_tag) do
			if tbl_has(get_card(id).tags,tag) then
				excluded = true
				break
			end
		end
		if not excluded then
			if not title then
				title = true
				py = py + 2
				lprint(lang.codex_exclude..":",pw/2,py,blue-1,1,1)
				py=py+6
			end
			lprint(get_lang(id),pw/2,py,3,1,1)
			py=py+6
		end
	end
	-- if title then py = py + 2 end
	py=py+10
	
	return py	
end

local function enrich_pan(ca)
	local bg_ents = pan_bg.ents
	local pan = bg_ents[#bg_ents]
	pan.dr=function(e,cx,cy)
		local ma=12
		-- if ca.spsheet then ma = 10 end
		local mh=4
		local dr_pan = btn("unsafe") and dr_pan or dr_ext_pan
		if not btn("unsafe") and ca.spsheet then ma = 10 end

		target("playground")
		--clip(0,0,2,2)
		local h=dr_pan(-666,ca)+666
		target()
		
		clip(pan_bg.x,0,pw+16,MCH)
		--rect(pan_bg.x,0,pan_bg.x+pw-1,MCH,5)
		
		tcamera(-cx,-cy)
		
		local y=(MCH-h)/2-8
		rectshade(ma,y-mh,pw-2*ma,h+2*mh,-2)
		rect(ma,y-mh,pw-ma,y+h+mh,3)

		dr_pan(y,ca)
		
		tcamera(cx,cy)
		clip()
	end
end

local function display_cards()

	local ents = codex.ents
   for i,e in ipairs(ents) do
      if e.iscodexcard then
         if i%2 == 1 then return end
         local ca = ents[i-1]
         if not ca.locked then
            local select = e.left_clic
            function e.left_clic()
               select()
               -- card = ca
               enrich_pan(ca)
            end
         end
      end
   end

end

append("init_codex",function()

	if codex_mode == "codex" then display_cards() end

	pan_bg = ents[4]

	local bg = ents[2]
	local codexb = bg.ents[1]
	local switch_to_codex = codexb.left_clic
	function codexb.left_clic()
		if codex_mode == "achievement" then
			switch_to_codex()
			display_cards()
		end
	end

end,"better codex")

chinese = {
	codex_others = "其他要求",
	other_needs = "$0 $1",
	other_needs_piece = "$0 $1s",
	codex_exclude = "互斥卡牌",
}

english = {
	codex_others = "Other requirements",
	other_needs = "$0 $1",
	other_needs_piece = "$0 $1s",
	codex_exclude = "Excludes card",

}

function add_lang(s)
	tbl_import(lang,s=="simplified_chinese" and chinese or english)
end

add_lang(current_lang)
append("load_lang",add_lang,function() end,"better codex")