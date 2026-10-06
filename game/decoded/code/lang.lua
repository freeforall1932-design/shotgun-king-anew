
FONTS_DATA={
	pico={ dy=0, h=7 },
	
	indienovaBC={ dy=9, h=16, sz=12 },
	Galmuri11={ dy=9, h=16, sz=12 },
	Terminus={ dy=8, h=14, sz=12 },
	galvanic={ dy=8, h=12, sz=8 },
	LanaPixel={ dy=8, h=14, sz=11 },
	Determination={ dy=9, h=14, sz=13 },
}

lang={}
plural={}
numbered={}
force_HD=false
local safe={}
local cache_fnt
local lang_file

function load_all_fonts() -- used for console
	cache_fnt=cache_fnt or {}

	addfont("TerminusThai",true,"assets/fonts/TerminusThai.ttf",12)
	addfont("Terminus",true,"assets/fonts/Terminus.ttf",12)
	font("Terminus")
	fntspec("fallback", "TerminusThai")
	
	cache_fnt["Terminus"]=true

	if BUILD_TYPE ~= "NX_EU" then
		addfont("indienovaBC",true,"assets/fonts/indienovaBC.ttf",12)
		addfont("Galmuri11",true,"assets/fonts/Galmuri11.ttf",12)
		cache_fnt["indienovaBC"]=true
		cache_fnt["Galmuri11"]=true
	end
end

function load_lang_nofont(s) -- used for console
	local function read_file(filename)
		local fl=file(filename)
		if not fl then return end
	
		local a=split(fl,"\n")
		lang_sum=0
		
		-- READ ALL
		for s in all(a) do
		
			-- ENTRIES
			local o=split(s,"::")
			if #o>1 then
				local trad=o[2] or ""
				trad=sbs(trad,"|","\n")
				lang[o[1]]=trad
				lang_sum=lang_sum+1
			end
			
			-- PLURIAL
			local o=split(s,":s:")
			if #o>1 then
				plural[o[1]]=o[2]
				plural[lowercase(o[1])]=lowercase(o[2])
			end
			
			-- NUMBER SPECIFICS
			local k,n,p = match(s, "(.+):(%d+):(.+)")
			if k then
				if not numbered[k] then
					numbered[k] = {}
					numbered[lowercase(k)] = {}
				end
				numbered[k][tonum(n)] = p
				numbered[lowercase(k)][tonum(n)] = lowercase(p)
			end
		end
		current_lang=s
	end
	
	-- LOAD TEXT
	read_file("lang/"..s..".txt")
end

function load_hd_font() -- used on PC
	addfont("Terminus", true, "assets/fonts/Terminus.ttf", 12)
	newfnt("TerminusThai", "assets/fonts/TerminusThai.ttf", 12)
	font("TerminusThai")
	fntspec("h", 12)
	fntspec("dy", 8)
	font("Terminus")
	fntspec("h", 12)
	fntspec("dy", 8)
	fntspec("fallback", "TerminusThai")
end

function load_safe_lang()
	load_lang("safe_english")
	safe = lang
end

local first_load
function load_lang(s)

	local function parse(fl)
		fl = sbs(fl, "\r\n", "\n")
		local a=split(fl,"\n")
		lang_sum=0
		
		-- DEFAULT
		cache_fnt=cache_fnt or {pico=true, Terminus=true}
		fnt="pico" -- default pico-8 font
		fnt_size=5
		fnt_params={h=7,dy=0}
		
		plural={}
		numbered={}
		
		-- READ ALL
		if not first_load then
			effect_order={}
		end
		
		for s in all(a) do
		
			-- ENTRIES
			local o=split(s,"::")
			if #o>1 then
				local trad=o[2] or ""
				trad=sbs(trad,"|","\n")
				lang[o[1]]=trad
				lang_sum=lang_sum+1
				
				if not first_load and sub(o[1],1,7)=="effect_" then
					effect_order[sub(o[1],8)]=lang_sum
				end
			end
			
			-- PLURIAL
			local o=split(s,":s:")
			if #o>1 then
				plural[o[1]]=o[2]
				plural[lowercase(o[1])]=lowercase(o[2])
			end
			
			-- NUMBER SPECIFICS
			local k,n,p = match(s, "(.+):(%d+):(.+)")
			if k then
				if not numbered[k] then
					numbered[k] = {}
					numbered[lowercase(k)] = {}
				end
				numbered[k][tonum(n)] = p
				numbered[lowercase(k)][tonum(n)] = lowercase(p)
			end
			
			-- PARAMS
			local o=split(s,">>")
			if #o>1 then
				if o[1]=="font" then fnt=o[2] end
				if o[1]=="font_line_height" then fnt_params.h=o[2] end
				if o[1]=="font_offset_y" then fnt_params.dy=o[2] end
				if o[1]=="font_size" then fnt_size=o[2] end
			end
		end
		
		if sub(fnt,1,4)~="pico" and not cache_fnt[fnt] then
			cache_fnt[fnt]=true
			addfont(fnt,true,"assets/fonts/"..fnt..".ttf",fnt_size)
		end
		
		if fnt=="pico" and force_HD then
			font("Terminus")
			local params=FONTS_DATA["Terminus"]
			if params then for k,v in pairs(params) do
				fntspec(k,params[k])
			end end
		else
			font(fnt)
			for k,v in pairs(fnt_params) do
				fntspec(k,fnt_params[k])
			end
		end

		_log("Found "..lang_sum.." keys in "..lang_file)
		
		current_lang=s
	end
	
	local function read_file(filename)
		local fl=file(filename)
		if not fl then return end
		
		lang,plural,numbered={},{},{}
		for k,v in pairs(safe) do
			lang[k]=v
		end
		
		if filename~=lang_file then
			watch(true)
			if lang_file then
				unwatch(lang_file)
			end
			lang_file = filename
			watch(filename, function(path) parse(file(path)) end, 0)
			watch(false)
		end
		
		parse(fl)
	end
	
	-- LOAD TEXT
	if PC and MODDED_LANG and MODDED_LANG[s] then
		read_file(MODDED_LANG[s])
	else
		read_file("lang/"..s..".txt")
	end
	
	first_load=true
end

function get_lang(s,reps,num)

	if reps and type(reps)~="table" then
		reps={reps}
	end

	local _s=lang[s]
	if not _s then return s end
	s = _s
	
	local num=num or 999 -- force plural

	if reps then
		for k,v in pairs(reps) do
		
			-- $0 $1 $2 $3 etc
			if type(k)=="number" then
				local i,rs=k-1,v
				if type(rs)=="number" then num=rs end
				s=sbs(s,"%$"..i.."s",get_plural(rs,num))
				s=sbs(s,"%$"..i,rs)
				s=sbs(s,"%(s%)",num>1 and "s" or "", 1) -- french english spanish
				s=sbs(s,"%(es%)",num>1 and "es" or "", 1) -- for spanish
				s=sbs(s,"%(y%)",num>1 and "y" or "", 1) -- for polish
				s=sbs(s,"%(и%)",num>1 and "и" or "", 1) -- for ukrainian
				s=sbs(s,"%(e%)",num>1 and "e" or "", 1) -- for german & italian
				s=sbs(s,"%[([%z\1-\191\194-\244]+)%]", function(id)
					return get_plural(id, num)
				end)
				
				if current_lang == "german" then
					s=sbs(s,"%(n%)",num>1 and "n" or "", 1)
					s=sbs(s,"%(er%)",num>1 and "er" or "", 1)
				end
			else
				s=sbs(s,"%"..k,v)				
			end
		
		end
		
	end

	return s
end

function get_plural(s,n)
	if numbered[s] and numbered[s][n] then return numbered[s][n] end
	if abs(n)<=1 then return s end
	if plural[s] then return plural[s] end
	return s..plural["*"] or ""
end

function console_ver()
	return MOUSE and "" or "_console"
end

function console_alt(key)
	if MOUSE then return key end
	
	local cons = key.."_console"
	if lang[cons] then return cons end

	return key
end

function format_lang(lang_name, newfile)
	local en=file("lang/english.txt")
	local ol=file("lang/"..lang_name..".txt")
	
	local nl=""
	
	local i,nx=1
	repeat
		nx=find(ol,"\n",i)
	
		local def = find(ol, "%>%>", i)
		if def and nx and def>nx then def=nil end
		
		if def then
			nl=nl..sub(ol,i,nx)
		end
	
		i=nx and (nx+1)
	until not nx

	local i,nx=1
	repeat
		nx=find(en,"\n",i)
		
		local com = find(en, "%-%-", i)
		local col = find(en, "::", i)
		local def = find(ol, "%>%>", i)
		
		if com and nx and com>nx then com=nil end
		if col and nx and col>nx then col=nil end
		if def and nx and def>nx then def=nil end
		
		if def then
			-- do nothing
		elseif com or not col then
			nl=nl..sub(en,i,nx)
		else
			local k = sub(en, i, col+1)
			local va,vb = find(ol, k)
			if va then
				local eol = find(ol, "\n", vb)
				nl=nl..k..sub(ol, vb+1, eol)
			else
				nl=nl..k.."\n"
			end
		end
		
		i=nx and (nx+1)
	until not nx
	
	
	
	local i,nx=1
	repeat
		nx=find(ol,"\n",i)
		
		local plur = find(ol, ":s:", i)
		local spec = find(ol, ":%d+:", i)
		local com = find(ol, "%-%-", i)
	
		if plur and nx and plur>nx then plur=nil end
		if spec and nx and spec>nx then spec=nil end
		if com and nx and com>nx then com=nil end
		
		if (plur or spec) and not com then
			nl=nl..sub(ol,i,nx)
		end
	
		i=nx and (nx+1)
	until not nx
	
	file("lang/"..newfile..".txt", nl)
end