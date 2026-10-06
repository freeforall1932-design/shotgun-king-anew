

-- MODABLE GRAPHICS and VARIABLES -- only used for reading gameplay.lua at this point
MOD_GRAPHICS_KEYS={
	"cards",
	"gfx",
	"title",
	"intro",
	"weapons",
}
MOD_GAMEPLAY_KEYS={	
	"CARDS",
	"EXCLUDE",
	"AUTO_REPLACE",
	"TAGS",
	"DIFFICULTY",
	"FIRST_ARMY",
	"PIECES",
	"HERO_INIT",	
}
MOD_HERO_INIT_KEYS={
	"ammo_max",
	"chamber_max",
	"firepower",
	"firerange",
	"ammo_regen",
	"knockback",
	"pierce",
	"special",
	"ai_lvl",
}


do -- safe_require and quarantine_req functions

	function quarantine_req(filename) -- get what the lua file returns
		local env = getfenv()
		local ctrl = {error = error, traceback = traceback}
		setfenv(0, ctrl)
		local wa=watch(false)
		local res = require("mods/modlist.lua")
		watch(wa)
		setfenv(0, env)
		return res
	end
	
	function quarantine_req_env(filename) -- get the lua file's environment as a table
		local env = getfenv()
		local ctrl = {error = error, traceback = traceback}
		setfenv(0, ctrl)
		local wa=watch(false)
		require(filename)
		watch(wa)
		setfenv(0, env)
		if ctrl.error == error then ctrl.error = nil end
		if ctrl.traceback == traceback then ctrl.traceback = nil end
		return ctrl
	end

	
	local _forbid = { "safe_require", "rm", "cd", "delsfx", "delmus", "delsrf", "logdupe", "setfenv", "getfenv", "steam", "steamws", "discord", "load", "stop", "execute", "export", "help", "man", "changelog", "mantxt", "url", "progress", "_G", "_S", "DEN", "MODSAV" }
	
  local _forbidden = {}
  for _,k in pairs(_forbid) do
    _forbidden[k] = true
  end
	
	local _safe_path -- function defined in safe_require
	local _path_access = {
		"require", "file", "mkdir", "srfshot", "endgif", "dirload", "quarantine_req_env", "quarantine_req", "shader", "rm", "isfile", "isfolder", "afile", "encfile", "namefind", "watch"
	}
	local _path_access2 = {
		"newsrf", "newsfx", "newmus", "newfnt"
	}
	local _access = {}
	for _,k in pairs(_path_access2) do
		_access[k] = function(name, path, ...)
			if k=="newsrf" and type(path)=="number" then
				return _G.newsrf(name, path, ...)
			elseif path and sub(path,-4,-4)=='.' then
				return _G[k](name, _safe_path(path), ...)
			elseif name then
				return _G[k](_safe_path(path), ...)
			else
				return _G[k]()
			end
		end
	end
	for _,k in pairs(_path_access) do
		_access[k] = function(path, ...)
			if not path then return _G[k]() end
			if type(path)=="boolean" then return _G[k](path, ...) end
			return _G[k](_safe_path(path), ...)
		end
	end
	
	-- append & prepend modding functions
	local append, prepend
	do
		local _chain_app = {}
		function append(foo_name, after, id)
			local chain = _chain_app[foo_name]
			if chain then
				for i,v in ipairs(chain) do
					if v[1]==id then
						if after then
							v[2] = after
						else
							deli(chain, i)
							if #chain==0 then
								_G[foo_name] = chain[0]
								_chain_app[foo_name] = nil
							end
						end
						return
					end
				end
				
				add(chain, {id, after})
			else
				chain = {[0] = _G[foo_name], {id, after}}
				_chain_app[foo_name] = chain
				
				local foo = _G[foo_name]
				_G[foo_name] = function(...)
					local a,b,c,d,e,f = foo(...)
					local chain = _chain_app[foo_name]
					for _,v in ipairs(chain) do
						v[2](...)
					end
					return a,b,c,d,e,f
				end
			end
		end
		
		local _chain_prep = {}
		function prepend(foo_name, before, id)
			local chain = _chain_prep[foo_name]
			if chain then
				for i,v in ipairs(chain) do
					if v[1]==id then
						if before then
							v[2] = before
						else
							deli(chain, i)
							if #chain==0 then
								_G[foo_name] = chain[0]
								_chain_prep[foo_name] = nil
							end
						end
						return
					end
				end
				
				add(chain, {id, before})
			else
				chain = {[0] = _G[foo_name], {id, before}}
				_chain_prep[foo_name] = chain
				
				local foo = _G[foo_name]
				_G[foo_name] = function(...)
					local chain = _chain_prep[foo_name]
					for i=#chain,1,-1 do
						chain[i][2](...)
					end
					return foo(...)
				end
			end
		end
	end


  function safe_require(folder, filename, replaceable, allow)
		local id
		if folder == "" then
			--rlog("folder cannot be the project's root path.")
			--return
			_safe_path = function(path) return path end
		else
			_safe_path = function(path)
				if find(path, "%.%.") then
					rlog("'..' is not allowed in filepaths.")
				end
				return folder.."/"..path
			end
			
			local i=#folder-1
			while sub(folder,i,i)~='\\' and sub(folder,i,i)~='/' do
				i=i-1
			end
			id = sub(folder, i+1)
		end
	
    local env = getfenv()
		
		local function gimme(what)
			local tbl={}
			if what=="global" then
				for k,v in pairs(env) do
					add(tbl, k)
				end
				return tbl
			elseif what=="replaceable" then
				for k,v in pairs(replaceable) do
					add(tbl, v)
				end
				return tbl
			elseif what=="forbidden" then
				for k,v in pairs(_forbid) do
					add(tbl, v)
				end
				return tbl
			elseif what=="autocall" then
				return {"on_fire", "on_hero_death", "on_piece_move(e)", "on_[piece_name]_move", "on_bad_hurt(e)", "on_leader_death", "on_[piece_name]_death", "on_bad_death(e)", "on_boss_death", "on_new_turn", "on_empty"}
			elseif what=="SUGAR" then
				url("https://youtu.be/dQw4w9WgXcQ")
			end
		end

		local _allow={}
		if allow then
			for i,k in ipairs(allow) do
				_allow[k]=true
			end
		end

		-- bank stuff
		local _newbnk, _delbnk, _expbnk, _bank, _bset, _bget
		if folder=="" then
			_newbnk, _delbnk, _expbnk, _bank, _bset, _bget = newbnk, delbnk, expbnk, bank, bset, bget
		else
			function _newbnk(w,h,depth)
				local data = check_corrupt(file("save/mods/"..id..".bnk"))
				if not data then
					data = check_corrupt(file("save/mods/"..id..".bnk_bak"))
				end
				
				local tbl
				if data then
					newbnk(id, data)
					bank(id)
					local ww,hh,dep = bnksize()
					if ww~=w or hh~=h or dep~=depth then
						_log("Mod save for id '"..id.."' is the wrong size, attempting transfer to new size.")
						tbl={}
						for y=0,hh-1 do
							tbl[y]={}
							for x=0,ww-1 do
								tbl[y][x] = bget(x,y)
							end
						end
						delbnk(id)
					else
						_log("Mod save for id '"..id.."' loaded.")
						return
					end
				end
			
				if depth then
					newbnk(id, w, h, depth)
				else
					newbnk(id, w, h)
				end
				bank(id)
				
				if tbl then
					for y,lin in pairs(tbl) do
						for x,v in pairs(lin) do
							bset(x,y,v)
						end
					end
				end
			end
			
			function _delbnk()
				delbnk(id)
			end
			
			function _expbnk()
				return expbnk(id)
			end
			
			function _bank()
				bank(id)
				return id
			end
			
			function _bset(x,y,v,byte)
				if byte then
					bset(id, x, y, v, byte)
				else
					bset(id, x, y, v)
				end
			end
			
			function _bget(x,y,byte)
				if byte then
					return bget(id, x, y, byte)
				else
					return bget(id, x, y)
				end
			end
		
			function _savbnk()
				local data = expbnk(id)
				file("save/mods/"..id..".bnk", data)
				file("save/mods/"..id..".bnk_bak", data)
			end
		end

    local can_replace = {}
    for _,k in pairs(replaceable or {}) do
      can_replace[k] = true
    end
		
		local ctrl
		local function _require(a)
			local env=getfenv()
			setfenv(0, ctrl)
			local wa=watch(false)
			local res = {_access.require(a)}
			watch(wa)
			setfenv(0, env)
			return unpack(res)
		end
    
		local sav
		if id then
			if MODSAV[id] then
				sav = MODSAV[id]
			else
				sav = {}
				MODSAV[id] = sav
			end
		end
		
		local nS={}
		setmetatable(nS, {
			__newindex = function(t, k, v)
        rawset(t, k, v)
      end,
      
      __index = function(t, k)
        local v = rawget(t,k)
        if v then
          return v
				elseif _access[k] then
					return _access[k]
        elseif _forbidden[k] and not _allow[k] then
          rlog("Attempt to use forbidden SUGAR function '"..k.."'")
        else
          return env[k]
        end
      end
		})
		
    ctrl = {
			error = error, traceback = traceback,
			append = append, prepend = prepend,
			gimme = gimme,
			newbnk = _newbnk, delbnk = _delbnk, expbnk = _expbnk, bset = _bset, bget = _bget, savbnk = _savbnk,
			require = _require,
			progress = function()end,
			SAVE = sav,
			_S = nS
		}
		
    setmetatable(ctrl, {
      __newindex = function(t, k, v)
        if can_replace[k] then
					env[k] = v
				elseif not env[k] then
          rawset(t, k, v)
        else
          rlog("Not allowed to change value for index '"..k.."'")
        end
      end,
      
      __index = function(t, k)
        local v = rawget(t,k)
        if v then
          return v
				elseif _access[k] then
					return _access[k]
        elseif _forbidden[k] and not _allow[k] then
          rlog("Attempt to use forbidden index '"..k.."'")
        else
          return env[k]
        end
      end
    })
    
    setfenv(0, ctrl)
		local path = (folder)
    require((folder == "") and filename or folder.."/"..filename)
    setfenv(0, env)
    
    local rslt = {}
    for nam,v in pairs(ctrl) do
      rslt[nam]=v
    end

    return rslt
  end

end

local first_mod_load
function load_mods()
	if IGNORE_MODS or not PC then return end
	--if true then return end

	local function get_mod_list()
		if not isfile("mods/modlist.lua") then return {},{} end
		
		list = quarantine_req("mods/modlist.lua")
		
		if not list or type(list)~="table" then return {},{} end
		
		local nlist,known = {},{}
		local n = #list
		for i = 1,n do
			local entry = list[i]
			if type(entry)=="table" and type(entry[1])=="string" and type(entry[2]) then
				add(nlist, {
					name = entry[1],
					active = entry[2]
				})
				known[entry[1]] = #nlist
			end
		end
		
		return nlist, known
	end
	
	function write_mod_list(list)
		local str="return {\n"
		for i,v in ipairs(list) do
			str = str.."\t{ \'"..v.name.."\', "..(v.active and "true" or "false").." },\n"
		end
		
		file("mods/modlist.lua", str.."}")
	end
	
	if not isfolder("mods") then
		_log("Creating mod folder")
		mkdir("mods")
	end
	
	local mods = ls("mods/", true)
	local prio,known = get_mod_list()
	local loaded = {}
	local new = {}
	
	local change
	for i,s in ipairs(mods) do
		if isfolder("mods/"..s) and isfile("mods/"..s.."/info.lua") then
			local mod
			if known[s] then
				mod = prio[known[s]]
			else
				mod = {
					name = s,
					active = not isfile("mods/"..s.."/script.lua")
				}
				add(new, mod)
			end
			
			loaded[s] = true
			
			if isfolder("mods/"..s.."/modes") then
				local modes = ls("mods/"..s.."/modes", true)
				for i=#modes,1,-1 do
					local mode = modes[i]
					if sub(mode, -4,-1)==".lua" then
						modes[i] = sub(mode, 1, -5)
					else
						deli(modes, i)
					end
				end
				
				mod.modes = modes
			end
			
			if isfolder("mods/"..s.."/lang") then
				local langs = ls("mods/"..s.."/lang", true)
				for i = #langs,1,-1 do
					local l=langs[i]
					if sub(l, -4, -1)==".txt" then
						langs[i] = sub(l, 1, -5)
					else
						deli(langs, i)
					end
				end
				
				if #langs>0 then
					mod.langs = langs
				end
			end
			
			local script = "mods/"..s.."/script.lua"
			mod.script = isfile(script) and script
			
			mod.exists = true
			
			if not mod.lang and not mod.modes and not mod.script then
				if s.active then change = true end
				_log("Mod '"..s.."' has no content, setting it as deactivated.")
				s.empty = true
				s.active = false
			end
			
			local info = quarantine_req_env("mods/"..s.."/info.lua")
			mod.save = s
			mod.title = info.title or s
			mod.author = info.by or ""
			mod.desc = info.description or ""
			mod.default_lang = info.default_lang
			mod.priority_hint = info.priority_hint or 0
			mod.mode_description = info.mode_description
			mod.mode_record = info.mode_record
			mod.id = info.id
			mod.folder = "mods/"..s
			mod.cover = info.cover and (mod.folder.."/"..info.cover)
			mod.here = true
		end
	end
	
	-- Steam Workshop mods
	if STEAM then
		local ws_mods = steamws("subbed")
		for i,s in ipairs(ws_mods) do
			if isfile(s.."/info.lua") then
				local info = quarantine_req_env(s.."/info.lua")
				
				local i=#s-1
				while sub(s,i,i)~='\\' and sub(s,i,i)~='/' do
					i=i-1
				end
				local id = sub(s, i+1)
				
				local name = id--info.name or info.title
				local mod
				
				--if loaded[name] then
				--	name = name.." (WS)"
				--end
				
				if known[name] then
					mod = prio[known[name]]
				else
					mod = {
						name = name,
						active = not isfile(s.."/script.lua")
					}
					add(new, mod)
				end

				if isfolder(s.."/modes") then
					local modes = ls(s.."/modes", true)
					for i=#modes,1,-1 do
						local mode = modes[i]
						if sub(mode, -4,-1)==".lua" then
							modes[i] = sub(mode, 1, -5)
						else
							deli(modes, i)
						end
					end
					
					mod.modes = modes
				end
				
				if isfolder(s.."/lang") then
					local langs = ls(s.."/lang", true)
					for i = #langs,1,-1 do
						local l=langs[i]
						if sub(l, -4, -1)==".txt" then
							langs[i] = sub(l, 1, -5)
						else
							deli(langs, i)
						end
					end
					
					if #langs>0 then
						mod.langs = langs
					end
				end
				
				local script = s.."/script.lua"
				mod.script = isfile(script) and script
				
				mod.exists = true
				mod.save = id
				mod.title = info.title or info.name
				mod.author = info.by or ""
				mod.desc = info.description or ""
				mod.default_lang = info.default_lang
				mod.priority_hint = info.priority_hint or 0
				mod.mode_description = info.mode_description
				mod.mode_record = info.mode_record
				mod.id = info.id
				mod.folder = s
			end
		end
		
		
		if not first_mod_load then
			steamws("on_install", function()
				load_mods()
				
				if inmods then -- user is in mods menu
					close_menu(bind(open_menu, {}, "mods"))
				end
			end)
		end
	end
	
	for i=#prio, 1, -1 do
		if not prio[i].exists then
			_log("Removing '"..prio[i].name.."' from mod list: couldn't be found in mods folder.")
			deli(prio, i)
			change = true
		end
	end
	
	for i,mod in ipairs(new) do
		local added
		for i,b in ipairs(prio) do
			if (mod.priority_hint or 0) > (b.priority_hint or 0) then
				add(prio, mod, i)
				added = true
				break
			end
		end
		if not added then
			add(prio, mod)
		end
		change = true
	end
	
	if change then
		write_mod_list(prio)
	end
	
	if #prio == 0 then
		return
	end
	
	MODLIST = prio
	MODS = {}
	
	first_mod_load = true
end

function run_mods()
	if not PC or not MODLIST then return end
	
	if not isfolder("save/mods") then
		mkdir("save/mods")
	end

	for i,mod in ipairs(MODLIST) do
		mod.num = i
		if mod.active then
			_log("Loading '"..mod.name.."' mod.")

			-- MOD LANG
			if mod.langs then
				MODDED_LANG = MODDED_LANG or {}
				
				for _,l in pairs(mod.langs) do
					local name = i..". "..l
					add(LANGUAGES, name)
					MODDED_LANG[name] = mod.folder.."/lang/"..l..".txt"
				end
			end
			
			local option = OPTIONS[OPTIONS.lang+1]
			option.opt = #LANGUAGES
			option.labels = LANGUAGES
			
			if mod.default_lang then
				local name = i..". "..mod.default_lang
				load_lang(name)
				SET.lang = name
			end
			
			-- MOD MODES
			if mod.modes then
				for _,mode in ipairs(mod.modes) do
					local name = i..". "..mode
					add(GAME_MODES, name)
					
					if mod.mode_description then
						lang[name.."_desc"] = mod.mode_description[mode]
					end
				end
			end
			
			-- MOD SAVE
			if mod.save then
				local data = check_corrupt(file("save/mods/"..mod.save..".bnk"))
				if data then
					newbnk(mod.save, data)
				else
					newbnk(mod.save, 1, 1)
				end
			end
			
			
			-- MOD SCRIPT
			if mod.script then
				mod.env = safe_require(mod.folder, "script.lua", {
					"DEV", "START_LVL", "FORCE_WHITE_ARMY", "DUMMY", "FRAGILE", "SHOW_BUTS", "TEST_CARDS", "TEST_SOULS", "OVERWEIGHT", "BOOT", "game_mode", "CARDS", "PIECES", "EXCLUDE", "AUTO_REPLACE", "FIRST_ARMY", "HERO_INIT", "TAGS",
					"hero", "heir", "leader", "pentasquares", "waypoint", "ammo", "chamber", "grenades", "stack", "scepters", "menu", "bg", "white_army", "perm", "mode", "cards",
					"mx", "my", "mcl", "mlb", "mcr", "mMenu", "VISION",
				})
				mod.ran = true
				
				MODDED = true
			end
			
			mod.loaded = true
			
			MODS[mod.name] = mod
		end
	end

	for ca in all(CARDS) do
		ca.exclude = nil
	end
	format_gameplay_datas()
end


--
function read_gameplay_file(path)
	
	local keys={
		"coucou",
	}
	local reps={}
	for k in all(MOD_GAMEPLAY_KEYS) do
		add(keys,k)
		add(reps,k)
	end
	

	local tbl=quarantine_req_env(path)--table_from_file(path,keys,reps)
	for k in all(MOD_GAMEPLAY_KEYS) do if tbl[k] then
		_G[k]=tbl[k]
	end end
	format_gameplay_datas(true)

	-- BUILD MODES
	GAME_MODES={"throne","endless","chase","charnier","tutorial"}
	
	if NO_TUTORIAL then
		del(GAME_MODES, "tutorial")
	end
end

function format_gameplay_datas(first_time)
	
	-- ADJUST CARD LIST
	for ca in all(NEW_CARDS) do
		add(CARDS,ca)
	end
	
	-- OVERWEIGHT + ADJUST WEIGHTS + FORMATING
	local gid=0
	local team=0
	for ca in all(CARDS) do
		
		-- TEAM & GID
		if first_time then
			if ca.team then	
				team=ca.team 
				gid=HALF_POOL
			end
			ca.team=team
			ca.gid=gid
			gid=gid+1
		end
		
		-- DEFAULT N
		ca.n=ca.n or 1
		
		--[[
		if ca.gid and not ca.team then
			ca.team=ca.gid<80 and 0 or 1
		end
		--]]
		
		
		local a={"gain","sac","need","need_card","need_tag","exclude_tag"}
		for k in all(a) do
			if type(ca[k])~="table" then ca[k]={ca[k]} end	
		end	
		ca.pwe=ca.pwe and ca.pwe or ( ca.wand and 1 or 4 )	
		
		-- OVERWEIGHT
		for ovid in all(OVERWEIGHT) do
			if ovid==ca.id then ca.pwe=10000 end
		end
		
		--if ca.ext==2 then ca.pwe=ca.pwe+4 end
		
	end
	
	-- APPLY TAGS 
	for ca in all(CARDS) do
		ca.tags={}
		for tag in all(TAGS or {}) do
			if not (tag.exclude and tbl_has(tag.exclude, ca.id)) then
				--local tagged
				for id in all(tag.attributes or {}) do
					for k,v in pairs(ca) do
						if k==id or sub(k,1,#id)==id then						
							uadd(ca.tags,tag.id)
							--tagged=true
							--break
						end
					end		
					if ca.id==id then uadd(ca.tags,tag.id) end	
					--if tagged then break end
				end
				
				if ca.special then --and not tagged
					for id in all(tag.special or {}) do
						if ca.special==id then
							uadd(ca.tags,tag.id)
							--tagged=true
						end
						--if tagged then break end
					end
				end
				
			end
		end
	end
	
	-- EXCLUDE
	for ex in all(EXCLUDE) do
		for i=1,#ex do
			local ca=get_card(ex[i])
			ca.exclude=ca.exclude or {}	
			for j=1,#ex do
				if i~=j then
					add(ca.exclude,ex[j])
				end
			end
		end		
	end
	for ca in all(CARDS) do		
		for id in all(ca.exclude_tag or {}) do			
			for oca in all(CARDS) do
				if tbl_has(oca.tags,id) then
					ca.exclude=ca.exclude or {}
					oca.exclude=oca.exclude or {}
					add(ca.exclude,oca.id)
					add(oca.exclude,ca.id)
				end
			end			
		end	
	end
	
	-- OPTIONS
	for i=1,#OPTIONS do
		local opt=OPTIONS[i]
		OPTIONS[opt.id]=i-1
	end
	
	-- PIECES
	PIECES_NAMES={}
	PIECES_TYPES={}
	for p in all(PIECES) do
		PIECES_TYPES[p.type]=p
		PIECES_NAMES[p.name]=p
		for bh in all(p.behavior or {}) do
			bh.native=1
		end		
	end

	add_indexes(PIECES)
	add_indexes(CARDS)
	add_indexes(OPTIONS)
end
