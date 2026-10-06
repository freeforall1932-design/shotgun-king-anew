

local function regname(dir, ext)
  local reg = ""
  for i=1,#dir do
    local ch = sub(dir,i,i) 
    if ch ~= '/' and ch ~= '\\' then
      reg = reg..ch
    end
  end
  reg = reg..ext
  return reg
end


local _log = log
if IN_EXPORT then

  function dirload(dir, ext, foo)
    local reg = regname(dir, ext)
    
    local regf = reg..".bnk"
    local list = file(regf)
    
    if not list then
      wlog("Couldn't find reg for dirload")
    end
    
    local lp = 1
    for i=1,#list do
      if sub(list, i, i) == '\n' then
        local path = sub(list, lp, i-2)
        local lsl, dot
        for j=1,#path do
          local ch = sub(path, j, j)
          if ch == '/' or ch == '\\' then lsl = j end
          if ch == '.' and not dot then dot = j end
        end
        
        foo(path, sub(path, lsl+1, dot-1))
        
        lp = i+1
      end
    end
  end

else

  function dirload(dir, ext, foo)
    local reg = regname(dir, ext)
    
    local list = ""
    
    for filename in all(ls(dir)) do
	  	local n=split(filename,".")
	  	if n[2]==ext then
        local path = dir.."/"..filename
	  		--foo(n[1],path) -- new sugar
	  		foo(path,n[1])
        list = list..path.."\n"
	  	end
	  end
    
    local regf = reg..".bnk"
    file(regf, "1:1:1:00")
    newbnk("tmp", regf)
    delbnk("tmp")
    file(regf, list)
  end

end