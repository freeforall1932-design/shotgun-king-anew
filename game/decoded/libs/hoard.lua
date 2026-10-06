
--  require("hoard.lua")({
--  	HOARD = {
--  		encode = true,
--  		folder = "save",
--  		rootfile = "reg",
--  		ext = ".sav",
--  		backup = ".bak",
--  		wait = 3, -- if `wait` is set, wait for that many seconds after the last modification before saving, otherwise saves at the end of the frame
--			--loadonly = {"save1", "save2} -- for specific usecases where you only want to load a set of savefiles rather than all of them
--  	},
--  	SETTINGS = {
--  		folder = ".",
--  		rootfile = "settings"
--  		rootonly = true,
--  		ext = ".txt"
--  	}
--  })



local _time,_log,_print = time,log,print


local _metas,_subs,_upds

local read_formats
local function read_v(str,pos)
	pos=find(str,"%a",pos)
	local chr=sub(str,pos,pos)
	
	if not chr then return nil,pos end
	local read=read_formats[chr]
	
	if read then
		return read(str,pos)
	else
		return nil,pos+1
	end
end

read_formats={
	t=function(str,pos) -- table
		local tbl={}
		local i=1
		pos=pos+2
		local len,chr=#str
		while pos and pos<len do
			pos=find(str,"[%a}]",pos)
			
			local chr = sub(str,pos,pos)
			if chr=="}" then
				pos=pos+1
				break
			end
			
			local read = read_formats[chr]
			if read then
				local k,v
				k,pos = read(str, pos+1)
				
				local coma = find(str, ",", pos, true)
				pos = find(str,"[%a]",pos)
				if pos and coma and pos<coma then
					chr = sub(str,pos,pos)
					read = read_formats[chr]
					v,pos = read(str, pos+1)
					
					tbl[k]=v
				else
					wlog("Could not read value for key '"..k.."'.")
					pos=coma
				end
			else
				pos=pos+1
			end
		end
	
		return tbl,pos
	end,
	
	n=function(str,pos) -- number
		local endpos=find(str,"[^0-9%.%-x]",pos) or #str+1
		local v=tonum(sub(str,pos,endpos-1))
		return v,endpos
	end,
	
	s=function(str,pos) -- string
		local endpos=find(str,'"\x1f',pos+1) or #str+1
		local v=sub(str,pos+1,endpos-1)
		
		return v,endpos+2
	end,
	
	b=function(str,pos) -- bool
		local v=sub(str,pos,pos+3)
		if v=="True" or v=="true" then
			return true, find(str,"%A",pos+4)
		else
			return false, find(str,"%A",pos)
		end
	end,
	
	f=function(str,pos) -- file
		local endpos=find(str,'"',pos+1) or #str+1
		local fil=sub(str,pos+1,endpos-1)
		
		local function v()
			return fil
		end
		
		return v,endpos+1
	end
}




local function mkstr(chr,str)
	return chr..str
end

local formats = {
	table = function(v)
		local dat = _metas[v]
		if not dat then
			_print("Attempt to save a table as key.")
			wlog("Attempt to save a table as key.")
			return ""
		end
		dat = dat.dat
	
		local str="{\n"
		for _,d in pairs(dat) do
			str=str..d[1]..": "..d[2]..",\n"
		end
		return mkstr("t", str.."}")
	end,
	number = function(v)
		return mkstr("n", tostr(v))
	end,
	string = function(v)
		return mkstr("s", '"'..v..'"\x1f')
	end,
	boolean = function(v)
		return mkstr("b", v and "True" or "False")
	end,
	["function"] = function(v)
		_print("Attempt to save function.")
		wlog("Attempt to save function.")
		return ""
	end
}



local function data(meta, k, v)
	if v==nil then
		meta.dat[k] = nil
	else
		local typ=type(v)
		local dat = meta.dat[k]
		
		if dat then
			dat[2] = formats[typ](v)
		else
			meta.dat[k] = { formats[type(k)](k), formats[typ](v) }
		end
	end
end

local function newfile(meta, k, v)
	local dat = meta.dat[k]
	if dat then
		dat[2] = 'f"'..v..'"'
	else
		meta.dat[k] = { formats[type(k)](k), 'f"'..v..'"' }
	end
end


local function resolve(modifs)
	local levels = {}
	
	local add_m
	add_m = function(met,key)
		local dp=met.dp
		
		local lvl=levels[dp]
		if lvl then
			local m=lvl[met]
			if m then
				if m[key] then return end
				m[key]=true
			else
				lvl[met]={[key]=true}
			end
		else
			levels[dp]={[met]={[key]=true}}
		end
		
		if met.par then
			add_m(met.par, met.key)
		end
	end
	
	local k=#modifs
	for i=k,1,-1 do
		local m=modifs[i]
		add_m(m[1],m[2])
		modifs[i] = nil
	end
	
	if not levels[0] then return end -- nothing to be done
	
	local maxdp = #levels
	for dp=maxdp,0,-1 do
		for met,keys in pairs(levels[dp]) do
			if met.files then
				for key,_ in pairs(keys) do
					if met.files[key] then
						newfile(met, key, met.files[key])
					else
						data(met, key, met.real[key])
					end
				end
			else
				for key,_ in pairs(keys) do
					data(met, key, met.real[key])
				end
			end
		end
	end
end

local forget_subtable
function forget_subtable(tbl)
	setmetatable(tbl, nil)
	local data = _subs[tbl]
	for k,v in pairs(data) do
		if type(v)=="table" then
			forget_subtable(v)
		end
		tbl[k]=v
	end
	
	_subs[tbl] = nil
	_metas[tbl] = nil
end

local default
default = function(tbl, k, v, deep)
	local tv=tbl[k]
	if tv==nil then
		tbl[k] = v
	elseif deep and type(v)=="table" and type(tv)=="table" then
		for kk,vv in pairs(v) do
			default(tv, kk, vv, true)
		end
	end
	return tbl[k]
end

local function make_subtable(tbl, par, key, modifs)

	local real = {}
	local meta = {}
	local via = {}
	
	for k,v in pairs(tbl) do
		--real[k] = v
		via[k] = v
		tbl[k] = nil
	end
	
	meta.dat = {}
	meta.real = real
	meta.dp = par.dp+1
	meta.par = par
	meta.key = key
	
	local methods = {
		add = function(v)
			tbl[#real+1]=v
		end,
		default = function(k, v, deep)
			return default(tbl, k, v, deep)
		end
	}
	
	setmetatable(tbl, {
		__index = function(t,k)
			return methods[k] or real[k]
		end,
		
		__newindex = function(t,k,v)
			if v==real[k] then return end -- nothing new
			
			if type(v)=="table" then
				if getmetatable(v) then
					rlog("Attempting to save a metatable in hoard.")
					return
				end
				
				make_subtable(v, meta, k, modifs)
			end
		
			real[k] = v
			add(modifs, {meta, k, _time()})
		end,
		
		__len = function()
			return #real
		end,
		
		__pairs = function()
			return pairs(real)
		end,
		__ipairs = function()
			return ipairs(real)
		end,
	})
	
	_metas[tbl] = meta
	_subs[tbl] = real
	
	for k,v in pairs(via) do
		tbl[k] = v
	end
	via=nil
end

local function make_base(name, tbl, is_root, params, init)
	if params.onlyload then
		local list = params.onlyload
		if is_root then
			for _,k in ipairs(list) do
				list[k]=true
			end
		else
			if not list[name] then
				return
			end
		end
	end

	local enc = params.encode

	local filepath = params.folder.."/"..name..params.ext
	local writing = nil
	
	local root = {}
	local meta = {}
	local modifs = {}
	
	local via = {}
	
	for k,v in pairs(tbl) do
		--root[k] = v
		via[k] = v
		tbl[k] = nil
	end
	
	if is_root then
		meta.files = {}
	end
	
	meta.dat = {}
	meta.real = root
	meta.dp = 0
	
	local bakt
	local methods = {
		add = function(v)
			tbl[#root+1]=v
		end,
		save = function()
			resolve(modifs)
			local str = "PUNKCAKE\n"..formats["table"](tbl).."\nFOREVER"
			writing = afile(filepath, str, enc)
			bakt=_time()+5
		end,
		readable = function()
			resolve(modifs)
			local str = formats["table"](tbl)
			writing = afile(filepath..".txt", str, false)
		end,
		default = function(k, v, deep)
			return default(tbl, k, v, deep)
		end
	}
	
	local wait,bak = params.wait, params.backup
	local function update(ti)
		if modifs[1] then
			if not wait or ti-modifs[#modifs][3]>=wait then
				methods.save()
			end
		end
		
		-- writing() is broken in Sugar v0.0.7b
		--if bak and writing and not writing() then -- time to write a backup
		if bak and bakt and ti>=bakt then -- time to write a backup
			local str = "PUNKCAKE\n"..formats["table"](tbl).."\nFOREVER"
			afile(filepath..bak, str, enc)
			writing = nil
			bakt = nil
		end
	end
	
	local function remove_file(k)
		local old = root[k]
		
		setmetatable(old, nil)
		local data = _subs[old]
		for k,v in pairs(data) do
			if type(v)=="table" then
				forget_subtable(v)
			end
			old[k]=v
		end
		
		_upds[old] = nil
		_subs[old] = nil
		_metas[old] = nil
		
		rm(meta.files[k])
		meta.files[k] = nil
	end
	
	local _init=init
	
	setmetatable(tbl, {
		__index = function(t,k)
			return methods[k] or root[k]
		end,
		
		__newindex = function(t,k,v)
			if v==root[k] then return end -- nothing new
			--_log(name..": "..k)
		
			if type(v)=="table" then
				if getmetatable(v) then
						rlog("Attempting to save a metatable in hoard.")
					return
				end
			
				if is_root then
					if meta.files[k] then
						remove_file(k)
					end
					
					local fil = make_base(k, v, false, params, _init)
					meta.files[k] = fil
				else
					make_subtable(v, meta, k, modifs)
				end
			else
				if is_root and meta.files[k] then
					remove_file(k)
				end
			end
			
			root[k] = v
			add(modifs, {meta, k, _time()})
		end,
		
		__len = function()
			return #root
		end,
		
		__pairs = function()
			return pairs(root)
		end,
		__ipairs = function()
			return ipairs(root)
		end,
	})
	
	_metas[tbl] = meta
	_subs[tbl] = root
	_upds[tbl] = update
	
	for k,v in pairs(via) do -- force subtable creation etc
		tbl[k] = v
	end
	via=nil
	
	if init then -- load file
		local function get_root(path)
			if not isfile(path) then return end
			local str
			
			if params.encode then
				str = encfile(path)
			else
				str = file(path)
			end
			
			if not str then return end
			
			if find(str, "PUNKCAKE\n")~=1 or not find(str, "\nFOREVER", -8) then
				return
			end
			str=sub(str,10,-9)
			
			return read_v(str,nil)
		end
		
		local save = get_root(filepath)
		if not save then
			_log("Could not read save at: "..filepath.." resorting to backup.")
			if params.backup then
				save = get_root(filepath..params.backup)
				if save then
					_log("Backup saved the day.")
				else
					_log("Could not read backup either.")
				end
			end
		end
		
		if save then
			for k,v in pairs(save) do
				if type(v)=="function" then
					tbl[k] = {}
				else
					tbl[k] = v
				end
			end
			
			resolve(modifs)
			_log("Successfully loaded save at: "..filepath)
		end
	else
		methods.save()
	end
	
	_init = false
	
	return filepath
end


function _lib_update.hoard()
	local ti=_time()
	for _,upd in pairs(_upds) do
		upd(ti)
	end
end


-- return this function at end of file
function init_hoard(params)
	_metas,_subs,_upds = {},{},{}

	for k,d in pairs(params) do
		d.folder = d.folder or "."
		d.rootfile = d.rootfile or "root"
		d.ext = d.ext or ""
		
		if not isfolder(d.folder) then
			mkdir(d.folder)
		end
		
		local root = {}
		make_base(d.rootfile, root, not d.rootonly, d, true)
		_G[k] = root
	end

end





-- root["hello"] = {} --> create file "hello.sav" + register it in root file and save
-- 
-- 
-- root = {
-- 	"hello" = tbl,
-- 	
-- 	___d = {
-- 		["hello"]={0,12,'f"hello.sav"'},
-- 	}
-- }
-- 
-- 
-- modifs={
-- 	{tbl,key,time}
-- }
-- 
-- tbl[234] = {} --> save
-- tbl[234][56] = 3245 --> save
-- 
-- 
-- tbl = {
-- 	[234] = {
-- 		3245,
-- 		true
-- 	},
-- 	"hi",
-- 	
-- 	___par = root,
-- 	___key = "hello",
-- 	___d = { -- key = {pos, len, str, modified}
-- 		[234]={0,14,"t{n3245,bTrue}"},
-- 		[1]={6,5,'s"hi"'}
-- 	}
-- }


--remysys_set_glob("hoard", "_update", update_hoard, true)




return init_hoard

