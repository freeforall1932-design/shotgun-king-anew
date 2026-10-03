for i,v in ipairs(MODLIST) do if v.title == "Nightmare Mode" then
	mod_index,mod = i,v
	break
end end

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

if not SAVE.nightmare then SAVE.nightmare = {} end
-- It acts as a grid where you can set and retrieve values with bset and bget respectively.
-- 128 and 64 are the dimensions of that bank, 4 is the depth which defines how big numbers can be in this bank. A depth of 1 means numbers above 255 cannot be stored in this bank. In doubt, set it to 4, it's the maximum value and it allows numbers up to 4,294,967,295. Banks cannot store negative values however.
-- You can save your bank to a file in the player's save folder by calling savbnk(). Each mod gets one bank and a corresponding save file.

newsrf("cards.png","nightmare")

add(CARDS,{gid=0, spsheet="nightmare", team=0, n=1, pwe=0, id="Nightmare Blank", played=1, ignored=0})

local english = {
	discard = "Shift-click a black card to discard it",
	[mod_index..". nightmare"] = "Nightmare",
	[mod_index..". nightmare_desc"] = "Nightmare|Complete your build to combat stronger enemies!",

	["Nightmare Blank"] = "Blank",

	signature = "Modder: Glacies",
}

local chinese = {
	discard = "Shift+左键弃置黑牌",
	[mod_index..". nightmare"] = "梦魇",
	[mod_index..". nightmare_desc"] = "梦魇|在你的敌人变强之前凑齐你的卡组！",

	["Nightmare Blank"] = "空白",

	signature = "作者：冰凌",
}

function add_lang(s)
	tbl_import(lang,s=="simplified_chinese" and chinese or english)
end

add_lang(current_lang)
append("load_lang",add_lang,"nightmare")