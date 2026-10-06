
OVERLAY_SCALE = 2
OVERLAY_SURF = "hdtext"
OVERLAY_TKEY = 255 -- transparent color

local _print,_bprint = _S.print, _S.bprint
local _newfnt = newfnt
local _font = font
local _strwidth = strwidth
local _strheight = strheight
local _pal = pal
local _newwin = newwin

local _font_on_ov = {default=true}
local _cur_font = "default"
local _on_ov = true
local _using_overlay

local _camera,_tcamera = camera,tcamera
local _camx, _camy = 0, 0
function camera(x,y)
  if x then
	  _camx, _camy = x, y
		_camera(x,y)
	else
	  _camx, _camy = 0, 0
		_camera()
	end
end

function tcamera(x, y)
  _camx = _camx + x
  _camy = _camy + y
	_tcamera(x, y)
end

function addfont(name, overlay, ...)
  local args = {...}
  args[3] = name
  
  _newfnt(args[3], args[1], args[2]);
  if overlay then
    _font_on_ov[name] = true
  end
end

function font(name)
  if not name then return _cur_font end
  _font(name)
  _on_ov = _font_on_ov[name]
  _cur_font = name
  if _on_ov then
    _using_overlay = true
  end
end

function lprint(str, x, y, c, align, outline) -- line print
  local res

  if _on_ov then
    target(OVERLAY_SURF)
		
		if align then
	    x = x - align*0.5*strwidth(str)/OVERLAY_SCALE
	  end

    local csc = (OVERLAY_SCALE-1)
		x = x*OVERLAY_SCALE-csc*_camx
		y = y*OVERLAY_SCALE-csc*_camy
		
		if outline then
			_print(str, x-2, y, outline)
			_print(str, x+2, y, outline)
			_print(str, x, y-2, outline)
			_print(str, x, y+2, outline)
			_print(str, x-1, y-1, outline)
			_print(str, x+1, y-1, outline)
			_print(str, x-1, y+1, outline)
			_print(str, x+1, y+1, outline)
			
			_print(str, x-1, y, outline)
			_print(str, x+1, y, outline)
			_print(str, x, y-1, outline)
			_print(str, x, y+1, outline)
		end
		
    if c then
      res = _print(str, x, y, c) + csc*_camx
    else
      res = _print(str, x, y) + csc*_camx
    end
  
    target()
    return res/OVERLAY_SCALE
  end
  
	if align then
	  x = x - align*0.5*strwidth(str)
	end
	
	local res
	
	if outline then
	  _print(str, x-1, y, outline)
	  _print(str, x+1, y, outline)
	  _print(str, x, y-1, outline)
	  _print(str, x, y+1, outline)
	end
	
  if c then
    res = _print(str, x, y, c)
  else
    res = _print(str, x, y)
  end
	
	return res
end

function pprint(str, x, y, w, c, align, lim, outline) -- paragraph print
  if align or lim then
		local lns={}
		local n,i,j,lsp=#str,1,1,1
		local lspx,xx=0,0
		
		while i and i<=n do
			local ii=find(str,"[%z\1-\127\194-\244]",i+1)
			local ch=sub(str,i,ii and (ii-1))
			
			if ch=='\n' then
				add(lns,sub(str,j,i-1))
				xx=0
				j=i+1
				i=j
			else
				local wch=txtwidth(ch)
				xx=xx+wch
				
				if ch==' ' or ch=='\t' then
					lsp=i
					lspx=xx
				end
				
				if xx > w then
					if lsp>j then
						add(lns,sub(str,j,lsp-1))
						xx=xx-lspx
						j=lsp+1
					else
						add(lns,sub(str,j,i-1))
						xx=wch
						j=i
					end
				end
			end
			
			i=ii
		end
		
		if j<n then
			add(lns,sub(str,j))
		end
		
    local addy = align and 0 or 1
		align = (align or 0)*0.5
    local fdy = strheight()
		if _on_ov then fdy=fdy*.5 end
		fdy=fdy+addy
		
		for s in all(lns) do
			local strw = txtwidth(s)
      local len = safesize(s)
			if lim and lim < len then
				local i,ch = 0,0
				while i<lim and ch and lim>0 do
				  ch = find(s,"[%z\1-\127\194-\244]", ch+1)
					i=i+1
				end

				ch = ch and max(ch-1,0)
				--y = pprint(sub(s, 1, ch), x-align*strw, y, w, c, nil, nil, outline)+addy
				pprint(sub(s, 1, ch), x-align*strw, y, w, c, nil, nil, outline)
				y = y+fdy
				
				break
			else
				--y = pprint(s, x-align*strw, y, w, c, nil, nil, outline)+addy
				pprint(sub(s, 1, ch), x-align*strw, y, w, c, nil, nil, outline)
				y = y+fdy
				
				if lim then
				  lim = lim-len
				end
			end
		end
		
		return y
	end
	
	--if lim then
	--  str = sub(str, 1, lim)..sbs(sub(str, lim+1), "%S", "\x06")
	--end

  local res
	
  if _on_ov then
    target(OVERLAY_SURF)

		local csc = (OVERLAY_SCALE-1)
    x = x*OVERLAY_SCALE-csc*_camx
		y = y*OVERLAY_SCALE-csc*_camy
    w = w*OVERLAY_SCALE
		
		if outline then
			_bprint(str, x-2, y, w, outline)
			_bprint(str, x+2, y, w, outline)
			_bprint(str, x, y-2, w, outline)
			_bprint(str, x, y+2, w, outline)
			_bprint(str, x-1, y-1, w, outline)
			_bprint(str, x+1, y-1, w, outline)
			_bprint(str, x-1, y+1, w, outline)
			_bprint(str, x+1, y+1, w, outline)
			
			_bprint(str, x-1, y, w, outline)
			_bprint(str, x+1, y, w, outline)
			_bprint(str, x, y-1, w, outline)
			_bprint(str, x, y+1, w, outline)
		end
    
    if c then
      res = _bprint(str, x, y, w, c) + csc*_camy
    else
      res = _bprint(str, x, y, w) + csc*_camy
    end
		
		--rect(x*OVERLAY_SCALE-csc*_camx, y*OVERLAY_SCALE-csc*_camy,x*OVERLAY_SCALE-csc*_camx+w*OVERLAY_SCALE, y*OVERLAY_SCALE-csc*_camy+32, 4)
  
    target()
    return res/OVERLAY_SCALE
  end
  
  if outline then
	  _bprint(str, x-1, y, w, outline)
	  _bprint(str, x+1, y, w, outline)
	  _bprint(str, x, y-1, w, outline)
	  _bprint(str, x, y+1, w, outline)
	end
  
  if c then
    res = _bprint(str, x, y, w, c)
  else
    res = _bprint(str, x, y, w)
  end
	
	return res
end

function safesub(str, a, b)

	if b<a then return "" end
	
	local cha,chb
	local ch,i = 0,0
  while ch do
	  ch = find(str,"[%z\1-\127\194-\244]", ch+1)
		i=i+1
		if cha then
		  if i==b+1 then
			  chb = ch and (ch-1)
			end
		else
		  if i==a then
			  cha = ch
			end
		end
	end
	
	return sub(str, cha, chb)
end

function safesize(str)
  local ch,i = 0,0
  while true do
	  ch = find(str,"[%z\1-\127\194-\244]", ch+1)
		if not ch then return i end
		i=i+1
	end
end

function hdclear(xa,ya,xb,yb)
  if not _using_overlay then return end
	
	target(OVERLAY_SURF)

	local csc = (OVERLAY_SCALE-1)
	
	rectfill(xa*OVERLAY_SCALE-csc*_camx, ya*OVERLAY_SCALE-csc*_camy, xb*OVERLAY_SCALE-csc*_camx, yb*OVERLAY_SCALE-csc*_camy, OVERLAY_TKEY)

	target()
end

function txtwidth(str)
  if _on_ov then
	  return _strwidth(str)/OVERLAY_SCALE
	else
	  return _strwidth(str)
	end
end

function txtheight(str,w)
  if _on_ov then
	  return _strheight(str, w*OVERLAY_SCALE)/OVERLAY_SCALE
	else
	  return _strheight(str, w)
	end
end

function _lib_init.hdtext()
  local scrw,scrh
  if MCW then
    scrw,scrh = MCW, MCH
  else
    scrw,scrh = SCRW, SCRH
  end
  
  newsrf(OVERLAY_SURF, scrw*OVERLAY_SCALE, scrh*OVERLAY_SCALE)
  target(OVERLAY_SURF)
  cls(OVERLAY_TKEY)
  target()
	
	wlog("Setting overlay...")
	winspec("overlay", OVERLAY_SURF, OVERLAY_TKEY)
end

function _lib_update.hdtext()
  if _using_overlay then
    target(OVERLAY_SURF)
    cls(OVERLAY_TKEY)
    target()
  end
  
  _using_overlay = _on_ov
end
