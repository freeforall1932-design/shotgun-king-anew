
if __REMY_SYSTEMS__ then return end
__REMY_SYSTEMS__ = true -- I don't want this file to get ran twice

local _print = print

do -- SYSTEM AUTOMATION
--  local __upds = {}
--  local __inis = {}
  
  local _globs = {}
  local _glob_rec = {}
  
  local function _gen_foo(glob, foo)
    local data = _globs[glob]
    if not data or not foo or type(foo)~="function" then
      return foo
    end
    
    local bef,aft = data.bef, data.aft
    return function(...)
      local gr = _glob_rec[glob]
      if gr > 0 then
        return foo(...)
      end
      
      _glob_rec[glob] = gr+1
      
      for _,f in pairs(bef) do f(...) end
      local rslt = {foo(...)}
      for _,f in pairs(aft) do f(...) end
      
      _glob_rec[glob] = gr
      
      return unpack(rslt)
    end
  end
  
  
  function remysys_set_glob(id, glob, foo, after)
    if not _globs[glob] then
      _globs[glob] = {bef={},aft={}}
    end
    
    if after then
      _globs[glob].aft[id] = foo
    else
      _globs[glob].bef[id] = foo
    end
    
    _glob_rec[glob] = 0
    
    rawset(_G, glob, _gen_foo(glob, _G[glob]))
  end
  
  
  
  
--  function remysys_set_update(name, foo)
--    __upds[name] = foo
--  end
--  
--  function remysys_set_init(name, foo)
--    __inis[name] = foo
--  end
--  
--  
--  local __user_upd
--  local function __remysys_upd()
--    for n,f in pairs(__upds) do
--      f()
--    end
--    
--    __user_upd()
--  end
--  
--  local __user_ini
--  local function __remysys_ini()
--    for _,f in pairs(__inis) do
--      f()
--    end
--    
--    __user_ini()
--  end
  
  setmetatable(_G, {
    __newindex = function(t, k, v)
      --rawset(t, k, v)
      rawset(t, k, _gen_foo(k, v))
    --  if k == "_init" then
    --    if v == __remysys_ini then
    --      rawset(t, k, __remysys_ini)
    --    elseif v == nil then
    --      rawset(t, k, nil)
    --    else
    --      __user_ini = v
    --      rawset(t, k, __remysys_ini)
    --    end
    --    
    --  elseif k == "_update" then
    --    if v == __remysys_upd then
    --      rawset(t, k, __remysys_upd)
    --    elseif v == nil then
    --      rawset(t, k, nil)
    --    else
    --      __user_upd = v
    --      rawset(t, k, __remysys_upd)
    --    end
    --    
    --  else
    --    rawset(t, k, v)
    --  end
    end
  })

end


do -- SYSTEM UTILITIES

  local _ltime,_t,_flr = ltime,t,flr
  function remysys_timestamp()
    local s,m,h,d,mo,y = _ltime()
    return y..mo.."_"..d.."_"..h.."_"..m..s.."__".._flr((_t()%1)*1000)
  end

end

