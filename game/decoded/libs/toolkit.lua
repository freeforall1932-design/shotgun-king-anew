PI=3.141592653589793
DIR={1,0,0,1,-1,0,0,-1, 1,1,-1,1,-1,-1,1,-1 }


-- RAND
function arand(a)
 return a[1+irnd(#a)]
end
function hrnd(n)
	n = n or 1
	return rnd(n*2)-n
end
function steal(a)
 local n=rnd(a)
 del(a,n)
 return n
end

-- EASE
function ease_in(c,p)
 return pow(c,p or 2)
end
function ease_out(c)
 return sqrt(c)
end
function ease_in_out(c)
 return mid(0,.5-cos(c/2)*0.5,1,1)
end
function ease_in_back(x,c1)
	c1 = c1 or 1.7015401988668
	local c3 = c1 + 1
	return c3 * x * x * x - c1 * x * x
end
function ease_out_back(c,c1)
	c1=c1 or 1.70158
	local c3=c1+1
	return 1 + c3*(c-1)^3 + c1*(c-1)^2
end
function ease_out_in(c,p)
	p=p or 1
	return c<.5 and ease_out((c*2)^(1/p))/2 or ease_in(((c-.5)*2)^p)/2+.5
	--return c<.5 and 2*c*c or -1+2*(2-c)*c
end
function ease_bounce_out(c)
	local n=7.5625
	local d=2.75

	--if true then return rnd(1) end



	if c<1/d then
		return n*c*c
	elseif c<2/d then
		c=c-1.5/d
		return n*c*c + 0.75
	elseif c<2.5/d then
		c=c-2.25/d
		return n*c*c + 0.9375
	else
		c=c-2.625/d
		return n*c*c + 0.984375
	end


	--[[
	if c<1/d then
		return n*c*c
	elseif c<2/d then
		--c=c-1.5
		return n * ((c-1.5)/d) * c + 0.75
	elseif c<2.5/d then
		--c=c-2.25
		return n * ((c-2.25)/d) * c + 0.9375
	else
		--c=c-2.625
		return n * ((c-2.625)/d) * c + 0.984375
	end	
	--]]

	--[[
	if c<1/d then
		return n*c*c
	elseif c<2/d then
		c=c-1.5
		return n * (c/d) * c + 0.75
	elseif c<2.5/d then
		c=c-2.25
		return n * (c/d) * c + 0.9375
	else
		c=c-2.625
		return n * (c/d) * c + 0.984375
	end
	--]]
	
	--[[
	if c<1/d then
		return n*c*c
	elseif c<2/d then
		--c=c-1.5
		return n * (c/d) * (c-1.5) + 0.75
	elseif c<2.5/d then
		--c=c-2.25
		return n * (c/d) * (c-2.25) + 0.9375
	else
		--c=c-2.625
		return n * (c/d) * (c-2.625) + 0.984375
	end	
	
	--]]
	
	
	
end
function ease_uturn(c)
	return sin(c/2)
end
function ease_atk(c)
	if c<.5 then 
		return pow(c*2,2) 
	else 
		return 1-pow((c-.5)*2,.5) 
	end
end
function ease_flat(c,tresh)
	tresh=tresh or .1
	if c<tresh then
		return sqrt(c/tresh)
	elseif c>1-tresh then
		--return --sqrt(1+(c-1)/tresh)
		return sqrt((1-c)/tresh)
	else
		return 1
	end

end


-- MATH
function acos(x)
 return atan2(x,-sqrt(1-x*x))
end
function asin(y)
 return atan2(sqrt(1-y*y),-y)
end
function dist(a,b)
	local dx=a.x-b.x
	local dy=a.y-b.y
	return sqrt(dx*dx+dy*dy)
end

-- %
function hmod(n,k)
 return (n+k)%(k*2)-k
 --[[
 while n>=k do n=n-k*2 end
 while n<-k do n=n+k*2 end
 return n
 --]]
end

-- T
function cyc(k,n,pt)
	pt=pt or t
	return flr(pt/(n or 1))%k
end
function gco(n,pt)
	pt=pt or t
	return (pt%n)/n
end


-- COORD
function rotate(x,y,a)
	return cos(a)*x-sin(a)*y,cos(a)*y+sin(a)*x
end

-- COLLECTION - TABLE
function uadd(a,b) 
 for c in all(a) do 
  if c==b then return end
 end
 add(a,b)
end
function sum_el(a,b)
 local sum=0
 for c in all(a) do 
  if c==b then sum=sum+1 end
 end
 return sum
end
function shuffle_old(a) -- BUG keep for compatibilty
 local b={}
 for n in all(a) do add(b,n) del(a,n) end 
 while #b>0 do add(a,steal(b)) end
end
function shuffle(a) -- FIXED SHUFFLE
 local b=clone(a)
 for i=1,#a do a[i]=nil end 
 while #b>0 do add(a,steal(b)) end
end

function shuffle_copy(a)
 local b,c={},{}
 for n in all(a)do add(c,n) end 
 while #c>0 do add(b,steal(c)) end
 return b
end
function clone(a,recursive)
 local b={}
 for k,v in pairs(a) do
  b[k]=v
	if recursive and type(v)=="table" then
		b[k]=clone(v,true)
	end	
 end
 return b
end
function tbl_import(a,b)
	for k,v in pairs(b) do a[k]=v end
end
function tbl_index(a,n)
	for i=1,#a do if a[i]==n then return i end end
	return -1
end
function concat(a,b)
	for c in all(b) do add(a,c) end
end
function reverse(a)
	local b={}
	for i=1,#a do b[i]=a[#a+1-i] end
	return b
end
function tbz(n)
	if n then
		return type(n)=="table" and n or {n}
	else
		return {}
	end
end
function map_tbl(a,k)
	k=k or "id"
	for o in all(a) do
		if o[k] then a[o[k]]=o end
	end
end
function tbl_has(a,n)
	for id in all(a) do if id==n then return true end end
	return false
end
function join_tbl(a)
	local res={}
	for tbl in all(a) do concat(res,tbl) end
	return res
end
function tbl_inv(a)
	local b={}
	for k,v in pairs(a) do
		b[v]=k
	end
	return b
end
function tbl_key(a)
	local b={}
	for n in all(a) do b[n]=1 end	
	return b
end

-- PAL
function apal(n)
 for i=0,#palette() do pal(i,n) end
end
function transp(n)
	palt(0,false)
	palt(n,true)
end
function mpal(x,y,xm,dy)
	xm=xm or 8
	dy=dy or 0
	for x=x,x+xm-1 do
		pal(sget(x,y),sget(x,y+dy))	
	end
	
end


-- BRES
function bres(x0,y0,x1,y1) -- 234
 local a={}
 local yi=1 
 local dx=x1-x0
 local dy=y1-y0
 
 if dx < dy then  
  x0,y0,x1,y1=x1,y1,x0,y0
 end
 
 if dx<0 then
  dx=-dx
  yi=-yi
 end
 if dy<0 then
  dy=-dy
  yi=-yi
 end
 
 if dy>=dx and y1<=y0 then
  local error=-flr(dy/2)
  while y1<y0 do
   add(a,{x=x1,y=y1})   
   error=error+dx
   if error > 0 then
    x1=x1+yi
    error=error-dy
   end
   y1=y1+1
  end
 else
  error=-flr(dx/2)
  while x0<x1 do
   add(a,{x=x0,y=y0})
   error=error+dy
   if error > 0 then
    y0=y0+yi
    error=error-dx
   end
   x0=x0+1
  end  
 end 
 return a 
end
function bres_2(x0,y0,x1,y1)
 local a={}
 local dx=x1-x0
 local dy=y1-y0
 local ystep,xstep,error,errorprev=nil
 local x,y=x0,y0
 add(a,{x=x0,y=y0})

 if dy<0 then
  ystep=-1
  dy=-dy
 else
  ystep=1
 end
 if dx<0 then
  xstep=-1
  dx=-dx
 else
  xstep=1
 end
 
 local ddx,ddy=2*dx,2*dy

 if ddx>= ddy then
  errorprev,error=dx,dx
  for i=0,dx-1 do
   x=x+xstep
   error=error+ddy
   if error>ddx then
    y=y+ystep
    error=error-ddx
    if error + errorprev <= ddx then add(a,{x=x,y=y-ystep}) end
    if error + errorprev >= ddx then add(a,{x=x-xstep,y=y}) end
   end
   add(a,{x=x,y=y})
   errorprev=error   
  end
 else
  errorprev,error=dy,dy
  for i=0,dy-1 do
   y=y+ystep
   error=error+ddx
   if error>ddy then
    x=x+xstep
    error=error-ddy
    if error + errorprev <= ddy then add(a,{x=x-xstep,y=y}) end
    if error + errorprev >= ddy then add(a,{x=x,y=y-ystep}) end
   end
   add(a,{x=x,y=y})
   errorprev=error   
  end
 end
 return a
end

-- STRING
function split(str,sep)
	local a={}
	while #str>0 do
		for i=1,#str do
			if #sep==0 or sub(str,i,i+#sep-1)==sep then
				add(a,sub(str,1,#sep==0 and i or i-1))
				str=sub(str,i+max(#sep,1),#str)
				if #str==0 then add(a,"") end
				break
			elseif i==#str then
				add(a,str)
				str=""
				break
			end		
		end
	end
	return a
end
function join(a,sep)
	local r=""
	local s=""
	for n in all(a) do
		r=r..s..n
		s=sep
	end
	return r
end
function rep(str,a,b)
	return join(split(str,a),b)
end
function min_digits(s,n,rep)
	rep=rep or "0"
	local s=s..""
	while #s<n do s=rep..s end
	return s
end
function decilim(n,lim)
	local k=pow(10,lim)
	return flr(n*k)/k
end

-- SRF
function crop_to(to,cx,cy,from)
	if from then target(from) else target() end

	from_adr,from_len=srfmem()
	aw,ah=srfsize()
	
	target(to)
	to_adr,to_len=srfmem()	
	bw,bh=srfsize()	
	for y=0,bh-1 do
		memcpy(to_adr+y*bw,from_adr+(flr(cy)+y)*aw+cx,bw)
	end
	target()
end

-- SORT
function ysort(a)
	for i=1,#a do
		local j = i
		while j > 1 and a[j-1].y > a[j].y do
			a[j],a[j-1] = a[j-1],a[j]
			j = j - 1
		end
	end
end
function custom_sort(a,f)
 for i=1,#a do
  local j = i
  while j > 1 and f(a[j-1]) > f(a[j]) do
   a[j],a[j-1] = a[j-1],a[j]
   j = j - 1
  end
 end
end

-- FUNCS
function bind(f,a,b,c,d,e,g)
	return function() return f(a,b,c,d,e,g) end
end
function merge_funcs(a,b)
 return function()
  if a then a() end
  if b then b() end
 end
end
function exe(foo,a,b,c,d,e,f)
	if foo then foo(a,b,c,d,e,f) end
end

-- COLLISION
function rect_col(ax,ay,aw,ah,bx,by,bw,bh,ma)
	ma=ma or 0
	return ax<bx+bw+ma and ax+aw+ma>bx and ay<by+bh+ma and ay+ah+ma>by
end
function bump_all(tbl,ray)
	for i=1,#tbl do for j=i+1,#tbl do
		local a,b=tbl[i],tbl[j]
		local dx=a.x-b.x
		local dy=a.y-b.y
		local dd=ray-sqrt(dx*dx+dy*dy)
		if dd>0 then
			local an=atan2(dx,dy)
			local dx=cos(an)*dd/2
			local dy=sin(an)*dd/2
			a.x=a.x+dx
			a.y=a.y+dy
			b.x=b.x-dx
			b.y=b.y-dy
		end
	end end
end
function rect_round_col(ax,ay,aw,ah,cx,cy,cr)
	local dx=cx-mid(ax,cx,ax+aw)
	local dy=cy-mid(ay,cy,ay+ah)
	return dx*dx+dy*dy<cr*cr
end
function rect_dist(ax,ay,aw,ah,bx,by,bw,bh)
	local ax2,ay2=ax+aw,ay+ah
	local bx2,by2=bx+bw,by+bh
	local dx,dy=0,0
	
	if ax2<bx then
		dx=bx-ax2
	elseif bx2<ax then
		dx=ax-bx2
	end
	
	if ay2<by then
		dy=by-ay2
	elseif by2<ay then
		dy=ay-by2
	end
	
	if dx>0 and dy>0  then
		return sqrt(dx * dx + dy * dy)
	else
		local px=min(ax2,bx2)-max(ax,bx)
		local py=min(ay2,by2)-max(ay,by)
		return -min(px,py)
	end
end


-- GRAPHIC GEN
function grid_rect(x,y,w,h,px,py,k,fill)

	-- CORNERS
	sspr(px,py,k,k,x,y)
	sspr(px+k*2,py,k,k,x+w-k,y)
	sspr(px+k*2,py+k*2,k,k,x+w-k,y+h-k)
	sspr(px,py+k*2,k,k,x,y+h-k)
	
	-- SIDES
	sspr(px+k,py,			k,k,	x+k,y,			w-k*2,k	)
	sspr(px+k,py+2*k,	k,k,	x+k,y+h-k,	w-k*2,k	)	
	sspr(px,py+k,			k,k, 	x,y+k, 			k,h-k*2	)
	sspr(px+k*2,py+k,	k,k, 	x+w-k,y+k,	k,h-k*2	)
	
	if fill then
		sspr(px+k,py+k,k,k,x+k,y+k,w-k*2,h-k*2)
	end
	

end
function grid_line(x,y,w,px,py,k)
	sspr(px,py,k,k,x,y)
	sspr(px+k*2,py,k,k,x+w-k,y)
	sspr(px+k,py,k,k,x+k,y,w-k*2,k)
end

-- SERIALIZE & LOAD
function serialize(tbl,code)
	local s=""
	if not code then s=s.."{" end
	
	for k,v in pairs(tbl) do
		if type(k)=="string" then				s=s..k.."="	end		
		if type(v)=="table" then  			s=s..serialize(v)
		elseif type(v)=="boolean" then	s=s..( v and "true" or "false")
		elseif type(v)=="string" then 	s=s..'"'..v..'"'
		else														s=s..v	end
		s=s..( code and " " or "," )	
	end
	if not code then s=s.."}" end
	
	return s
end

-- PARAMS & LOAD
_load=load
function load(s,params)
	if params then
		clipboard(":exe:"..serialize(params,true))
	end
	_load(s)
end
function load_params()

	local s=file("map_edit.ini")
	cb=clipboard()
	if sub(cb,1,5)==":exe:" then	s=sub(cb,6,#cb) end	

	--local s=clipboard()
	--if sub(s,1,5)==":exe:" then	execute(sub(s,6,#s)) end	
		execute(s) 
	if s then
	end
	
	
end

-- OVERRIDE
_flr=flr
function flr(n,k)
	return k and _flr(n/k)*k or _flr(n)
end

-- ADDITIONAL
function ssspr(x,y,w,h,dx,dy,sx,sy)
	sx=sx or 1
	sy=sy or 1
	sspr(x,y,w,h,dx+(1-sx)*w/2,dy+(1-sy)*h/2,sx*w,sy*h)
end


-- ARITHMETIC
function get_square_pos(c)
	c=(c*4)%4
	if c<1 then return c,0
	elseif c<2 then return 1,c-1
	elseif c<3 then return 3-c,1
	else return 0,4-c end	
end
function get_square_coef(dx,dy)
	local q=(atan2(.5-dx,.5-dy)*4-.5)%4	
	-- local c=0
	if q<1 then
		c=dx
	elseif q<2 then		
		c=1+dy	
	elseif q<3 then
		c=3-dx
	elseif q<4 then 
		c=4-dy
	end
	return c/4
end

-- INVERSE KIN
function tri_angle(a,b,c)
	return acos( mid(-1,(b^2+c^2-a^2)/(2*b*c),1) )
end
function inv_kin(ax,ay,bx,by,sb,sc,s)	
	s=s or 1
	local dx,dy=ax-bx,ay-by
	local sa=sqrt(dx*dx+dy*dy)	
	sa,sb,sc=sc,sa,sb	
	local an=atan2(dx,dy)+tri_angle(sa,sb,sc)*s+.5
	local x=ax+cos(an)*sc
	local y=ay+sin(an)*sc	
	return x,y	
end

-- VARIOUS TOOLS
do -- cheatcodes
	local cheats,lt={},0
	
	function cheatcode(code,func,limit)
		cheats[code]={foo=func,lim=limit,i=1}
		
		if not _lib_update.cheatcode then
			_lib_update.cheatcode=function()
				local n=catchtxt()
				if n then
					local ti=time()
					local dt=ti-lt
					lt=ti
					
					local function clear()
						for cheat,dat in pairs(cheats) do
							dat.i=1
						end
					end
					
					for cheat,dat in pairs(cheats) do
						if n==sub(cheat,dat.i,dat.i) and (not dat.lim or dt<dat.lim) then
							dat.i=dat.i+1
							if dat.i>#cheat then
								dat.foo()
								clear()
							end
						else
							dat.i=1
						end
					end
				end
			end
		end
	end
	
end