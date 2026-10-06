-- FROM benwiley4000/pico8-table-string

local token_sep = '\31'
local subtable_start = '\29'
local subtable_end = '\30'

function stringify_table(table)
  local str = ''
  for key, val in pairs(table) do
    str = str..key
    local t = type(val)
    if t == 'table' then
      str = str..subtable_start..stringify_table(val)..subtable_end
    else 
			
      str = str..token_sep..tostr(val)..token_sep
    end
  end
  return str
end
--[[
function serialize_table(table)
  local function escape(str)
    if type(str) ~= 'string' then
      return str
    end
    local new_str = ''
    for i = 1,#str do
      local char = sub(str, i, i)
      if char == '\'' then
        new_str = new_str..'\\\''
      else
        new_str = new_str..char
      end
    end
    return new_str
  end
  return '\''..escape(stringify_table(table))..'\''
end
--]]


function table_from_string(str)
  local tab, is_key = {}, true
  local key,val,is_on_key
  local function reset()
    key,val,is_on_key = '','',true
  end
  reset()
  local i, len = 1, #str
  while i <= len do
    local char = sub(str, i, i)
    -- token separator
    if char == '\31' then
      if is_on_key then
        is_on_key = false
      else
        tab[tonum(key) or key] = val
        reset()
      end
    -- subtable start
    elseif char == '\29' then
      local j,c = i,''
      -- checking for subtable end character
      while (c ~= '\30') do
        j = j + 1
        c = sub(str, j, j)
      end
      tab[tonum(key) or key] = table_from_string(sub(str,i+1,j-1))
      reset()
      i = j
    else
      if is_on_key then
        key = key..char
      else
        val = val..char
      end
    end
    i = i + 1
  end
  return tab
end
