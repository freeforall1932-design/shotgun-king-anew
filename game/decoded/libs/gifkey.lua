require "../../libs/remy_systems.lua"

DO_GIFKEY  = not IN_EXPORT
GIF_FOLDER = desktop_path()
GIF_NAME   = nil
GIF_SCALE  = 3
GIF_LENGTH = 8 -- in seconds
GIF_SNAP_SCALE = 7

GIF_WIDTH  = nil
GIF_HEIGHT = nil

GIF_X = nil
GIF_Y = nil

GIF_START = "k:f3"
GIF_END   = "k:f4"
SNAP_KEY  = "k:f1"


local _gifw,_gifh
local _gifx,_gify

local function _start_gif(w,h)
  _gifw = GIF_WIDTH or w
  _gifh = GIF_HEIGHT or h
  
  _gifx = GIF_X or ((w-_gifw)*0.5)
  _gify = GIF_Y or ((h-_gifh)*0.5)
  
  newgif(_gifw, _gifh, GIF_LENGTH * 33)
end

local function nnewwin(name, w, h)
  if not DO_GIFKEY then return end
  
  GIF_NAME = GIF_NAME or name
  
  _start_gif(w,h)
end
remysys_set_glob("gifkey", "newwin", nnewwin, true)


--local _winspec = winspec
function nwinspec(_a, _b, _c)
  if not DO_GIFKEY then return end

  if _a == "screen" and _b then
    _start_gif(_b,_c)
  end
end
remysys_set_glob("gifkey", "winspec", nwinspec, true)

local _log = log

function _lib_init.gifkey()
  if not DO_GIFKEY then return end
	_log("Adding gifkey controls.")
  defbtn("gifkey_start", -41, GIF_START)
  defbtn("gifkey_end", -41, GIF_END)
  defbtn("gifkey_snap", -41, SNAP_KEY)
	allinputs(-41,true)
end

local _lft = 0
local _time = t
local _log = print
function _lib_update.gifkey()
  if not DO_GIFKEY then return end

  if btnp("gifkey_start", -41) then
    newgif(_gifw, _gifh, GIF_LENGTH * 33)
    _log("Gif starting point set!")
  end
  
  if btnp("gifkey_end", -41) then
		local name = namefind(GIF_FOLDER.."\\"..GIF_NAME.."_", ".gif", 3)
		name = sub(name, 1, #name-4)
    endgif(name, GIF_SCALE)
    _log("Saved gif "..name..".gif")
  end
  
  if btnp("gifkey_snap", -41) then
    local name = namefind(GIF_FOLDER.."\\"..GIF_NAME.."_snap_", ".png", 3)
		name = sub(name, 1, #name-4)
    if GIF_SNAP_W and GIF_SNAP_H then
      srfshot(name, GIF_SNAP_W, GIF_SNAP_H, true)--SNAP_SCALE or GIF_SCALE)
    else
      srfshot(name, GIF_SNAP_SCALE, true)--SNAP_SCALE or GIF_SCALE)
    end
    
    _log("Saved screenshot "..name..".png")
  end
  
  local ti = _time()
  if ti >= _lft+0.03 then
    gifframe(_gifx, _gify)
    _lft = ti
  end
end

--remysys_set_glob("gifkey", "_draw", update, true)
