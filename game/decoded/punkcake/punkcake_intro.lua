
local clip = clip
local camera = camera
local sspr=sspr
local spr=spr
local circfill=circfill
local line=line
local pal=pal
local sugar_step=sugar_step
local palette=palette
local rnd=rnd
local sfx = sfx
local lines
local oplt

local function chance(a) return rnd(100)<a end
local function got(a) return rnd(2*a)-a end

local frame_recs={}
local function is_frame(ti, nt)
  if ti > nt and not frame_recs[nt] then
    frame_recs[nt] = true
    return true
  end
  return false
end

local movy = 0
local shkx,shky = 0,0
local boom = 0
local function add_shake(p)
  local a = rnd(1)
  shkx = shkx + p * cos(a)
  shky = shky + p * sin(a)
end

local function pcd_init()
  oplt = palette()
  palette({0x0, 0x666666, 0xaaaaaa, 0xffffff})
  spritesheet(newsrf("pcd_sheet", "../../punkcake/punkcake_sheet.png"))
  
  newsfx("pcd_slap", "../../punkcake/slap.wav", 0.6)
  newsfx("pcd_chomp", "../../punkcake/chomp.wav", 0.4)
  newsfx("pcd_punkcake", "../../punkcake/punkcake.wav")
  newsfx("pcd_delicieux", "../../punkcake/delicieux.wav", 0.9)
  
  palette({0, 0xff30a0, 0xffffff})
  sprgrid(8,8)
  
	frame_recs = {}
  lines = {}
--  rsd = rnd()
end

local function pcd_upd(ti)
  if abs(shkx)+abs(shky) < 0.75 then
    shkx, shky = 0,0
  elseif ti%0.033 < dt() then
    shkx = shkx * (-0.5-rnd(0.2))
    shky = shky * (-0.5-rnd(0.2))
  end
  
  if is_frame(ti, 0.125) then movy = 8 sfx("pcd_slap") end
  if is_frame(ti, 0.275) then movy = 8 sfx("pcd_slap") end
  if is_frame(ti, 0.425) then movy = 8 sfx("pcd_slap") end
  
  if is_frame(ti, 0.55) then sfx("pcd_punkcake") end
  if is_frame(ti, 1.1) then add_shake(4) boom = 1 sfx("pcd_chomp") end
  if is_frame(ti, 1.5) then sfx("pcd_delicieux") end
  
  --movy = max(movy-dt()*30, 0)
  movy = lerp(movy, 0, dt()*5)
  
  boom = lerp(boom, 0, dt()*3)

  do -- create rays
    if ti > 0.425 and ti%0.05 < dt() then
      local k = flr(2 + irnd(3))
      local a = rnd(1)
      
      for i = 1, k do
        add(lines, {
          l = -rnd(0.1),
          d = 28 + irnd(3)*8 + rnd(48),
          a = a + i/k + rnd(0.2)-0.1,
          va = rnd(0.1)
        })
      end
    end
  end
  
  do -- update and kill rays
    for i,l in pairs(lines) do
      l.l = l.l + dt()*.25
      if l.l > 0.5 then
        deli(lines, i)
      end
    end
  end
end

local function pcd_drw(ti, c0, c1, c2)
  if ti < 0.1 then
    pal({c0, c1}, 1)
  elseif ti < 3.5 then
    pal({c1, c2}, 1)
  end

  local scrw, scrh = srfsize()
  local cx = scrw/2
  local cy = scrh/2
  
  camera(shkx, shky-movy)
  
  do -- bg
    cls(0)
  end
  
  do -- logo bubble
    circfill(cx, cy, 120, 1)
    circfill(cx, cy, 122*(1-boom), 0)
  end
  
  pal(3,2)
  
  local py = cy - 28 -- pancake position
  local clpx, clpy
  
  do -- logo clip rectangle
    clpx = cx - 64
    clpy = py - 56
  
    clip(clpx+2, clpy+movy+2, 128-4, 168-4)
  end
  
  rectfill(clpx, clpy, clpx+127, clpy+167, 0)
  
  do -- pancakes!
    pal(1,0)
    if ti < 1.1 then
      local vt = mid(ti*8, 0, 1)*0.25
      local x = cx - round(48*(1-sin(vt)))
      local y = py + 8 - 76*cos(vt)
      local sp = (vt >= 0.25) and 166 or 208
      spr(sp, x-24, y-4, 6, 3)
      
      local vt = mid((ti-0.15)*8, 0, 1)*0.25
      local x = cx + round(48*(1-sin(vt)))
      local y = py - 76*cos(vt)
      local sp = (vt >= 0.25) and 166 or 208
      pal(3,0) spr(sp, x-24, y-1, 6, 3)
      pal(3,2) spr(sp, x-24, y-4, 6, 3)
      
      local vt = mid((ti-0.3)*8, 0, 1)*0.25
      local x = cx - round(48*(1-sin(vt)))
      local y = py - 8 - 76*cos(vt)
      local sp = (vt >= 0.25) and 160 or 208
      pal(3,0) spr(sp, x-24, y-1, 6, 3)
      pal(3,2) spr(sp, x-24, y-4, 6, 3)
    else
      spr(6, cx-24, py+4, 6, 3)
      spr(6, cx-24, py-4, 6, 3)
      spr(0, cx-24, py-12, 6, 3)
    end
    pal(1,1)
  end

  do -- rays
    for _,l in pairs(lines) do
      if l.l > 0 then
        local ia = 1 + min(l.l/0.1, 1)
        local ib = 1 + l.l/0.5
        
        local a = l.a + l.l*l.va
        local co, si = cos(a), sin(a)
        
        local xa = cx + ia * co * l.d
        local ya = py+4 + ia * si * l.d
        local xb = cx + ib * co * l.d
        local yb = py+4 + ib * si * l.d
        
        line(xa, ya, xb, yb, 3)
        line(xa-1, ya, xb-1, yb, 3)
        line(xa, ya-1, xb, yb-1, 3)
        line(xa-1, ya-1, xb-1, yb-1, 3)
      end
    end
  end
  
  
  do -- PUNKCAKE délicieux
    ny = py+48
    
    ti = ti - 0.5
    
    if ti >= 0 then
      local vt = 1-sin(min(ti*4, 1)*0.25)
      -- PUNKCAKE shadows
      local x = cx-4*15
      for i=0,7 do
        local dy = -2*(i%2-0.5)*16*vt
        circfill(x+i*15+7, ny+5+6+(i%2)*7+dy, 12, 0)
      end
      
      -- PUNKCAKE letters
      pal(2,1)
      for i=0,7 do
        local dy = -2*(i%2-0.5)*16*vt
        local dx = 0
        if chance(10) then
        --  dx = got(1)
        --  dy = dy+got(1)
        end
        
        if ti<0.1 then
          pal(2,0)
          pal(3,1)
        end
        
        spr(64+i*2, x+i*15+dx, ny+5+dy, 2, 3)
      end
    end
    
    -- délicieux
    ti = ti - 1.5
    pal(1,0)
    if ti > 0 then
      local x = cx-11*4
      local y = ny + 32 - 4 * (1-min(ti*2, 1))
      
      if ti<0.1 then
        pal(2,0)
        pal(3,1)
      end
      
      spr(112, x, y, 11, 3)
    end
    pal(2,1)
    pal(3,2)
  end
  
  clip()
  
  do -- logo frame
    spr(14, clpx-4, clpy-4, 2, 2)
    spr(14, clpx+116, clpy-4, 2, 2, true, false)
    spr(14, clpx-4, clpy+156, 2, 2, false, true)
    spr(14, clpx+116, clpy+156, 2, 2, true, true)
    
    sspr(122, 0, 6, 6, clpx+12, clpy-4, 104, 6)
    sspr(122, 0, 6, 6, clpx+12, clpy+164+7, 104, -6)
    sspr(112, 10, 6, 6, clpx-4, clpy+12, 6, 144)
    sspr(112, 10, 6, 6, clpx+124+7, clpy+12, -6, 144)
  end

  pal(1,1)
  pal(2,2)
  pal(3,3)
  
  ti = ti - 1.3
  if ti >= 0 then
    if ti < 0.1 then
      pal({c0, c1}, 1)
    elseif ti < 0.2 then
      pal({c0, c0}, 1)
    end
  end
end

local function pcd_shut()
--  delsrf("pcd_sheet")
--  
--  delsfx("pcd_slap")
--  delsfx("pcd_chomp")
--  delsfx("pcd_punkcake")
--  delsfx("pcd_delicieux")
  
  palette(oplt)
end

function punkcake_intro()
  local __upd, __drw = _update, _draw
  _update,_draw = nil, function() end
  sugar_step()
  
  pcd_init()
  
  local startt = t()
  
  while t() < startt + 3.5 do
    local ti = t() - startt
    
    pcd_upd(ti)
    pcd_drw(ti, 0, 1, 2)
    
  --  if btnp"gifkey_snap" then
  --    local name = namefind(GIF_FOLDER.."\\"..GIF_NAME.."_snap_", ".png", 3)
  --    name = sub(name, 1, #name-4)
  --    srfshot(name, GIF_SNAP_SCALE, true)--SNAP_SCALE or GIF_SCALE)
  --    _log("Saved screenshot "..name..".png")
  --  end
  
    sugar_step()
  end
  
  pcd_shut()
  
  pal()
  _update,_draw = __upd, __drw
end



function punkcake_gif()
  pcd_init()
  camera()
  clip()
  palette({0, 0xff30a0, 0xffffff})
  
  local w,h = 400,400
  local dur = 200--30*30
  local rays = 100

  newsrf(w, h, "ok")
  target("ok")
  cls()
  spritesheet("ok")
  spritesheet("pcd_sheet")
  
  newgif(w, h, dur, 0.03)
  pal()
  
  for t=0,dur+2 do
    pal()
    pal(3,2)
    
    cls(0)
    --rect(0,0,w-1,h-1,2)
    
    local cx,cy = w/2, h/2
    local py = cy-28 -- pancakes position
    
    
    do -- logo clip rectangle
      clpx = cx - 64
      clpy = py - 56
    
      --clip(clpx+2, clpy+movy+2, 128-4, 168-4)
    end
    
    --rectfill(clpx, clpy, clpx+127, clpy+167, 0)
    
    do -- rays
      srand(69)
      for i=1,rays do
        local l = rnd(dur)
        local a = rnd(1)
        local d = 28 + irnd(4)*8 + rnd(48)
        local va = rnd(0.025)
        
        local ti = ((t-l)%dur)*0.01
        if ti >= 0 and ti <= 1 then
          local ia = 1+min(ti*5, 1)
          local ib = 1+ti
          
          local a = a+ti*va
          local co = cos(a)
          local si = sin(a)
          
          local xa = cx   + ia*co*d
          local ya = py+4 + ia*si*d
          local xb = cx   + ib*co*d
          local yb = py+4 + ib*si*d
          
          color(1)
          line(xa, ya, xb, yb)
          line(xa-1, ya, xb-1, yb)
          line(xa, ya-1, xb, yb-1)
          line(xa-1, ya-1, xb-1, yb-1)
        end
        
      end

    end
    
    do -- logo frame
      pal(1,0)
      spr(14, clpx-4, clpy-4, 2, 2)
      spr(14, clpx+116, clpy-4, 2, 2, true, false)
      spr(14, clpx-4, clpy+156, 2, 2, false, true)
      spr(14, clpx+116, clpy+156, 2, 2, true, true)
      
      sspr(122, 0, 6, 6, clpx+12, clpy-4, 104, 6)
      sspr(122, 0, 6, 6, clpx+12, clpy+164+7, 104, -6)
      sspr(112, 10, 6, 6, clpx-4, clpy+12, 6, 144)
      sspr(112, 10, 6, 6, clpx+124+7, clpy+12, -6, 144)
      pal(1,1)
    end
    
    clip(clpx+2, clpy+2, 128-4, 168-4)
    
    do -- rays
      srand(69)
      for i=1,rays do
        local l = rnd(dur)
        local a = rnd(1)
        local d = 28 + irnd(4)*8 + rnd(48)
        local va = rnd(0.025)
        
        local ti = ((t-l)%dur)*0.01
        if ti >= 0 and ti <= 1 then
          local ia = 1+min(ti*5, 1)
          local ib = 1+ti
          
          local a = a+ti*va
          local co = cos(a)
          local si = sin(a)
          
          local xa = cx   + ia*co*d
          local ya = py+4 + ia*si*d
          local xb = cx   + ib*co*d
          local yb = py+4 + ib*si*d
          
          color(2)
          line(xa, ya, xb, yb)
          line(xa-1, ya, xb-1, yb)
          line(xa, ya-1, xb, yb-1)
          line(xa-1, ya-1, xb-1, yb-1)
        end
        
      end

    end
    
    do -- pancakes
      spr(6, cx-24, py+4, 6, 3)
      spr(6, cx-24, py-4, 6, 3)
      spr(0, cx-24, py-12, 6, 3)
    end
    
    do -- PUNKCAKE délicieux
      ny = py+48
      
      ti = 5
      
      if ti >= 0 then
        local vt = 1-sin(min(ti*4, 1)*0.25)
        -- PUNKCAKE shadows
        local x = cx-4*15
        for i=0,7 do
          local dy = -2*(i%2-0.5)*16*vt
          circfill(x+i*15+7, ny+5+6+(i%2)*7+dy, 12, 0)
        end
        
        -- PUNKCAKE letters
        pal(2,1)
        for i=0,7 do
          local dy = -2*(i%2-0.5)*16*vt
          local dx = 0
          if chance(10) then
          --  dx = got(1)
          --  dy = dy+got(1)
          end
          
          if ti<0.1 then
            pal(2,0)
            pal(3,1)
          end
          
          spr(64+i*2, x+i*15+dx, ny+5+dy, 2, 3)
        end
      end
      
      -- délicieux
      ti = ti - 1.5
      pal(1,0)
      if ti > 0 then
        local x = cx-11*4
        local y = ny + 32 - 4 * (1-min(ti*2, 1))
        
        if ti<0.1 then
          pal(2,0)
          pal(3,1)
        end
        
        spr(112, x, y, 11, 3)
      end
      pal(2,1)
      pal(3,2)
    end
    
    clip()
    
    gifframe()
  end
  
  endgif(desktop_path().."/punkcake.gif", 1)

  delsrf("ok")
  pcd_shut()
end


local _stt
local _upd_sav, _drw_sav
local _plt_sav, _spr_sav
local _back

local function _wait_upd()
	local ti = time()-_stt

	if btnp("punkcake_go") then
		_update = _upd_sav
		_draw = _drw_sav
		palette(_plt_sav)
		spritesheet(_spr_sav)
		sprgrid(16,16)
		_back()
	end
	
	
	if abs(shkx)+abs(shky) < 0.75 then
    shkx, shky = 0,0
  elseif ti%0.033 < dt() then
    shkx = shkx * (-0.5-rnd(0.2))
    shky = shky * (-0.5-rnd(0.2))
  end
  
  if is_frame(ti, 0.125) then movy = 8 sfx("pcd_slap") end
  if is_frame(ti, 0.275) then movy = 8 sfx("pcd_slap") end
  if is_frame(ti, 0.425) then movy = 8 sfx("pcd_slap") end
  
  if is_frame(ti, 0.55) then sfx("pcd_punkcake") end
  if is_frame(ti, 1.1) then add_shake(4) boom = 1 sfx("pcd_chomp") end
  if is_frame(ti, 1.5) then sfx("pcd_delicieux") end
  
  --movy = max(movy-dt()*30, 0)
  movy = lerp(movy, 0, dt()*5)
  
  boom = lerp(boom, 0, dt()*3)

  do -- create rays
    if ti > 0.425 and ti%0.05 < dt() then
      local k = flr(2 + irnd(3))
      local a = rnd(1)
      
      for i = 1, k do
        add(lines, {
          l = -rnd(0.1),
          d = 28 + irnd(3)*8 + rnd(48),
          a = a + i/k + rnd(0.2)-0.1,
          va = rnd(0.1)
        })
      end
    end
  end
  
  do -- update and kill rays
    for i,l in pairs(lines) do
      l.l = l.l + dt()*.25
      if l.l > 0.5 then
        deli(lines, i)
      end
    end
  end
end

local function _wait_drw()
	local ti = time()-_stt
	
	c0,c1,c2 = 0,1,2

  if ti < 0.1 then
    pal({c0, c1}, 1)
  elseif ti < 3.5 then
    pal({c1, c2}, 1)
  end

  local scrw, scrh = srfsize()
  local cx = scrw/2
  local cy = scrh/2+16
  local py = cy - 28 -- pancake position
  
  camera(shkx, shky-movy)
  
  do -- bg
    cls(0)
  end
	
  do -- rays
		color(1)
    for _,l in pairs(lines) do
      if l.l > 0 then
        local ia = 1 + min(l.l/0.1, 1)
        local ib = 1 + l.l/0.5
        
        local a = l.a + l.l*l.va
        local co, si = cos(a), sin(a)
        
        local xa = cx + ia * co * l.d
        local ya = py+4 + ia * si * l.d
        local xb = cx + ib * co * l.d
        local yb = py+4 + ib * si * l.d
        
        line(xa, ya, xb, yb)
        line(xa-1, ya, xb-1, yb)
        line(xa, ya-1, xb, yb-1)
        line(xa-1, ya-1, xb-1, yb-1)
      end
    end
  end
  
  do -- logo bubble
  --  circfill(cx, cy, 120, 1)
  --  circfill(cx, cy, 122*(1-boom), 0)
  end
  
  pal(3,2)
  
  local clpx, clpy
  
  do -- logo clip rectangle
    clpx = cx - 64
    clpy = py - 56
  
    clip(clpx+2, clpy+movy+2, 128-4, 168-4)
  end
  
  rectfill(clpx, clpy, clpx+127, clpy+167, 0)
  
  do -- pancakes!
    pal(1,0)
    if ti < 1.1 then
      local vt = mid(ti*8, 0, 1)*0.25
      local x = cx - round(48*(1-sin(vt)))
      local y = py + 8 - 76*cos(vt)
      local sp = (vt >= 0.25) and 166 or 208
      spr(sp, x-24, y-4, 6, 3)
      
      local vt = mid((ti-0.15)*8, 0, 1)*0.25
      local x = cx + round(48*(1-sin(vt)))
      local y = py - 76*cos(vt)
      local sp = (vt >= 0.25) and 166 or 208
      pal(3,0) spr(sp, x-24, y-1, 6, 3)
      pal(3,2) spr(sp, x-24, y-4, 6, 3)
      
      local vt = mid((ti-0.3)*8, 0, 1)*0.25
      local x = cx - round(48*(1-sin(vt)))
      local y = py - 8 - 76*cos(vt)
      local sp = (vt >= 0.25) and 160 or 208
      pal(3,0) spr(sp, x-24, y-1, 6, 3)
      pal(3,2) spr(sp, x-24, y-4, 6, 3)
    else
      spr(6, cx-24, py+4, 6, 3)
      spr(6, cx-24, py-4, 6, 3)
      spr(0, cx-24, py-12, 6, 3)
    end
    pal(1,1)
  end

  do -- rays
    for _,l in pairs(lines) do
      if l.l > 0 then
        local ia = 1 + min(l.l/0.1, 1)
        local ib = 1 + l.l/0.5
        
        local a = l.a + l.l*l.va
        local co, si = cos(a), sin(a)
        
        local xa = cx + ia * co * l.d
        local ya = py+4 + ia * si * l.d
        local xb = cx + ib * co * l.d
        local yb = py+4 + ib * si * l.d
        
        line(xa, ya, xb, yb, 3)
        line(xa-1, ya, xb-1, yb, 3)
        line(xa, ya-1, xb, yb-1, 3)
        line(xa-1, ya-1, xb-1, yb-1, 3)
      end
    end
  end
  
  
  do -- PUNKCAKE délicieux
    ny = py+48
    
    ti = ti - 0.5
    
    if ti >= 0 then
      local vt = 1-sin(min(ti*4, 1)*0.25)
      -- PUNKCAKE shadows
      local x = cx-4*15
      for i=0,7 do
        local dy = -2*(i%2-0.5)*16*vt
        circfill(x+i*15+7, ny+5+6+(i%2)*7+dy, 12, 0)
      end
      
      -- PUNKCAKE letters
      pal(2,1)
      for i=0,7 do
        local dy = -2*(i%2-0.5)*16*vt
        local dx = 0
        if chance(10) then
        --  dx = got(1)
        --  dy = dy+got(1)
        end
        
        if ti<0.1 then
          pal(2,0)
          pal(3,1)
        end
        
        spr(64+i*2, x+i*15+dx, ny+5+dy, 2, 3)
      end
    end
    
    -- délicieux
    ti = ti - 1.5
    pal(1,0)
    if ti > 0 then
      local x = cx-11*4
      local y = ny + 32 - 4 * (1-min(ti*2, 1))
      
      if ti<0.1 then
        pal(2,0)
        pal(3,1)
      end
      
      spr(112, x, y, 11, 3)
    end
    pal(2,1)
    pal(3,2)
  end
  
  clip()
  
  do -- logo frame
    spr(14, clpx-4, clpy-4, 2, 2)
    spr(14, clpx+116, clpy-4, 2, 2, true, false)
    spr(14, clpx-4, clpy+156, 2, 2, false, true)
    spr(14, clpx+116, clpy+156, 2, 2, true, true)
    
    sspr(122, 0, 6, 6, clpx+12, clpy-4, 104, 6)
    sspr(122, 0, 6, 6, clpx+12, clpy+164+7, 104, -6)
    sspr(112, 10, 6, 6, clpx-4, clpy+12, 6, 144)
    sspr(112, 10, 6, 6, clpx+124+7, clpy+12, -6, 144)
  end

  pal(1,1)
  pal(2,2)
  pal(3,3)
	
		
	font("averia")
	fntspec("dy",16)
	
	
	local str = "Un nouveau jeu tous les mois"
	local x = cx-strwidth(str)*0.5
	local y = 4
	print(str, x-1, y, 0)
	print(str, x+1, y, 0)
	print(str, x+1, y+1, 0)
	print(str, x-1, y+1, 0)
	print(str, x, y+2, 0)
	print(str, x, y-1, 0)
	print(str, x, y+1, 1)
	print(str, x, y, 2)
	local str = "https://punkcake.club"
	local x = cx-strwidth(str)*0.5
	local y = y+28
	print(str, x-1, y, 0)
	print(str, x+1, y, 0)
	print(str, x+1, y+1, 0)
	print(str, x-1, y+1, 0)
	print(str, x, y+2, 0)
	print(str, x, y-1, 0)
	print(str, x, y+1, 1)
	print(str, x, y, 2)
  
	if ti>1 and ti%1.5>=0.75 then
		local str = "pressez (A) pour lancer Stray Shot"
		local x = cx-strwidth(str)*0.5
		local y = MCH-24
		print(str, x-1, y, 0)
		print(str, x+1, y, 0)
		print(str, x+1, y+1, 0)
		print(str, x-1, y+1, 0)
		print(str, x, y+2, 0)
		print(str, x, y-1, 0)
		print(str, x, y+1, 1)
		print(str, x, y, 2)
	end
	
  --ti = ti - 1.3
  --if ti >= 0 then
  --  if ti < 0.1 then
  --    pal({c0, c1}, 1)
  --  elseif ti < 0.2 then
  --    pal({c0, c0}, 1)
  --  end
  --end
end

function punkcake_wait(back)
	_back = back
	_upd_sav = _update
	_drw_sav = _draw
	_plt_sav = palette()
	_spr_sav = spritesheet()
	
	music()
	
	newfnt("../../punkcake/averia.ttf", 24, "averia")
	
	defbtn("punkcake_go", 0, "m:lb, m:rb, m:mb")

	pcd_init()
	
	_stt = time()

	_update = _wait_upd
	_draw = _wait_drw
end