DO_SNAPS    = not IN_EXPORT
SNAP_FOLDER = "autosnaps"
SNAP_FREQ   = 15
SNAP_SCALE  = 4
SNAP_W      = 1920 --| ignored unless    |
SNAP_H      = 1080 --| SNAP_SCALE is nil |
SNAP_SHADER = true

local _tim = rnd(SNAP_FREQ)

local _print,_log = print,log
local _srfshot = srfshot
local _winspec = winspec

function _lib_init.autosnaps()
  if not DO_SNAPS then return end
  
  mkdir(SNAP_FOLDER)
end

function _lib_update.autosnaps()
  if not DO_SNAPS then return end
  
  _tim = _tim - dt()
  if _tim < 0 then
    if winspec("focus") then
      local nam = namefind(SNAP_FOLDER.."\\snap_", ".png", 4)
      nam = sub(nam, 1, #nam-4)
      
      if SNAP_SCALE then
        srfshot(nam, SNAP_SCALE, SNAP_SHADER)
      else
        srfshot(nam, SNAP_W, SNAP_H, SNAP_SHADER)
      end
    end
    
    _tim = (0.75+rnd(0.5))*SNAP_FREQ
  end
end

--remysys_set_glob("autosnaps", "_init", init)
--remysys_set_glob("autosnaps", "_draw", update, true)

--remysys_set_init("autosnaps", init)
--remysys_set_update("autosnaps", update)

