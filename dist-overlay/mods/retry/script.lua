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

range = {"throne","endless",}
range_mods = {"royal card lab"}

append("set_mode",function()
	if tbl_has(range,mode.id) or tbl_has(range_mods,MOD) then
		local death = mode.on_hero_death
		function mode.on_hero_death()
			if mode.resign then
				death()
				return
			end
			add(upgrades,{deaths=1})
			wait(60,end_level,new_level)
		end
	end
end,"retry")

function edit_disp_stats(stats)
	if stack.deaths then
		add(stats,{id="deaths",name=get_lang("deaths",{stack.deaths}),value=tostr(stack.deaths),cl=blue})
	end
end

chinese = {
	retry_terminal_not_loaded = "死亡重试mod：冰凌中枢未启动",
	retry_terminal_not_after = "死亡重试mod须在冰凌中枢上方",

	deaths = "死亡次数",
	stat_deaths = "在本局中死亡了$0次"
}

english = {
	retry_terminal_not_loaded = "Retry after Death: Glac Terminal is not active",
	retry_terminal_not_after = "Retry after Death must be loaded above Glac Terminal",

	deaths = "Death(s)",
	stat_deaths = "You have died $0 time(s)"
}

function add_lang(s)
	tbl_import(lang,s=="simplified_chinese" and chinese or english)
end

add_lang(current_lang)
append("load_lang",add_lang,"retry")

function warn(text)
	log(text)
	wlog(text)
	append("init_menu",bind(sfx,"wrong"),"glacies warning")
end

function scan()
	for mod in all(MODLIST) do
		if mod.title == "Glacies Module Terminal" and mod.active then
			for title,mod in pairs(MODS) do
				if mod.title == "Glacies Module Terminal" then warn(lang.retry_terminal_not_after) end
			end
			return
		end
	end
	warn(lang.retry_terminal_not_loaded)
end

scan()
