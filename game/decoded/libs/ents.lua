
-- CREATE
function mke(fr,x,y)
 local e={
  fr=fr or -1,
  x=x or 0,
  y=y or 0,
  t=0,vx=0,vy=0,we=0,frict=1,
  ww=16,hh=16,
  dp=1,
  flx=false,fly=false,
 } 
 add(ents,e)
 return e
end



-- CHILD SYSTEM
function add_child(par,e,keep_pos)

	par=par or _G

	if keep_pos then
		local ax,ay=get_global_pos(par)
		local bx,by=get_global_pos(e)
		e.x=bx-ax
		e.y=by-ay
	end



	if e.par then
		del(e.par.ents,e)
	else
		del(ents,e)
	end
	
	e.par=par	
	if not par.ents then par.ents={} end
	add(par.ents,e)
	
	if e.par==_G then e.par=nil end
	
end
function pop_child(e,lp)
	if not e.par then return end
	e.x=e.x+e.par.x
	e.y=e.y+e.par.y
	del(e.par.ents,e)
	e.par=e.par.par
	add(e.par and e.par.ents or ents,e)
	
	if lp then pop_child(e,lp) end
	
end




-- MANAGE
function dre(e,ddx,ddy)
	
	local x=(ddx or 0)+e.x
	local y=(ddy or 0)+e.y

	if e.fr>0 then
		spr(e.fr,flr(x),flr(y),e.ww/16,e.hh/16,e.flx,e.fly)
	end	
	if e.dr then e.dr(e,x,y) end
 
 -- draw childs 	
	if e.ents then 
		tcamera(-x,-y)
		foreach(e.ents,dre)
		tcamera(x,y)
	end
	

end
function upe(e)

	e.t=e.t+1

	-- physics
	e.vx=e.vx*e.frict
	e.vy=e.vy*e.frict
	e.vy=e.vy+e.we
	e.x=e.x+e.vx
	e.y=e.y+e.vy

	-- update
	if e.upd then e.upd(e) end

 --  tweens
	if e.twc then
		local c=min(e.twc+1/e.tws,1)
		cc=e.twcv and e.twcv(c) or c
		e.x=e.sx+(e.ex-e.sx)*cc
		e.y=e.sy+(e.ey-e.sy)*cc
		if e.jmp then
			local k=sin(c/2)*e.jmp
			local a=e.jma or -.25
			e.x=e.x+cos(a)*k
			e.y=e.y+sin(a)*k
		end  
		if e.spiral then
			local ray=sin(c/2)*80
			local an=.5+cc*3
			e.x=e.x+cos(an)*ray
			e.y=e.y+sin(an)*ray
		end
		e.twc=c  
		if c==1 then
			e.twc=nil
			e.jmp=nil
			e.twcv=nil
			local f=e.twf
			if f then
				e.twf=nil
				f()
			end
		end
	end  
 
 
 -- update childs
	if e.ents then
		for e in all(e.ents) do upe(e) end
	end
 
 
  -- counters
	for v,n in pairs(e) do  if sub(v,1,2)=="c_" then
		n=n-1
		e[v]= n>0 and n or nil
	end end

 -- life
	if e.life then
		e.life=e.life-1
		if e.life<=0 then
			kl(e)
		end
	end 

 
end



-- KILL
function reg_add(a,e)
	add(a,e)
	e.reg_tables=e.reg_tables or {}
	add(e.reg_tables,a)	
end
function kl(e)
	e.dead=true
	if not e then return end
	del(e.par,e)
	
	if e.reg_tables then for a in all(e.reg_tables) do
		del(a,e)
	end end		
	if e.nxt then
		local f=e.nxt
		e.nxt=nil
		f()
	end 
end

-- TWEEN
function mv(e,dx,dy,n,f)
 mvt(e,e.x+dx,e.y+dy,n,f)
end
function mvt(e,tx,ty,n,f)
 e.sx=e.x
 e.sy=e.y
 e.sz=e.z
 e.ex=tx
 e.ey=ty
 e.ez=e.sz
 e.twc=0
 e.tws=n
 e.twf=f  
 if n<0 then mv_speed(e,-n) end

end
function mv_speed(e,n)

  local dx=e.ex-e.sx
  local dy=e.ey-e.sy
	local d=sqrt(dx^2+dy^2)
	if e.jmp then d=d+e.jmp*2 end	
  e.tws=d/n
end


-- MOUSE TRACKING
function track_mouse()
	
	
	
	if not mouse_tracker_init then
		mouse_tracker_init=true
		defbtn("mouse_tracker_x",0,"m:x")
		defbtn("mouse_tracker_y",0,"m:y")
		defbtn("mouse_tracker_lb",0,"m:lb")
		defbtn("mouse_tracker_rb",0,"m:rb")
		defbtn("mouse_tracker_mb",0,"m:mb")
	end


	local trg,mx,my=get_mouse_target(ents,btnv("mouse_tracker_x"),btnv("mouse_tracker_y"))	
	
	
	local run=function(e,k) if e and e[k] then e[k](mx,my) end end
	
	
	if trg~=mouse_tracker_trg then
		run(mouse_tracker_trg,"on_out")
		if mouse_tracker_trg then	mouse_tracker_trg.mouse_over=false end
		mouse_tracker_trg=trg
		if mouse_tracker_trg then	mouse_tracker_trg.mouse_over=true end	
		run(mouse_tracker_trg,"on_over")
	end
	
	--local lb=btnv("mouse_tracker_lb")

	if not mouse_tracker_trg then return end

	if btnp("mouse_tracker_lb") then
		run(mouse_tracker_trg,"on_click")
	end
	if btn("mouse_tracker_lb") then		
		run(mouse_tracker_trg,"on_press")
	end	
	if btnr("mouse_tracker_lb") then		
		run(mouse_tracker_trg,"on_release")
	end	
	
	if btnp("mouse_tracker_rb") then
		run(mouse_tracker_trg,"on_right_click")
	end
	if btn("mouse_tracker_rb") then		
		run(mouse_tracker_trg,"on_right_press")
	end
	if btnr("mouse_tracker_rb") then
		run(mouse_tracker_trg,"on_right_release")
	end
	

	
	
end
function get_mouse_target(a,mx,my)

	for i=#a,1,-1 do
		local e=a[i]
		if e.ents then
			local trg,x,y=get_mouse_target(e.ents,mx-e.x,my-e.y)
			if trg then	return trg,x,y	end			
		end	
		if not e.mouse_disable and e.vis and mx>=e.x and mx<e.x+e.ww and my>=e.y and my<e.y+e.hh then
			return e,mx-e.x,my-e.y
		end
	end
	
end

-- ANIM
function play(e,tempo,mfr)
	local bfr=e.fr
	e.life=tempo*mfr
	e.upd=function(e)
		e.fr=bfr+flr(e.t/tempo)
	end


end

-- GET
function get_global_pos(e)
	local x,y,p=e.x or 0,e.y or 0,e.par
	while p do
		x=x+p.x
		y=y+p.y
		p=p.par
	end
	return x,y
end

-- TOOLS
function impulse(e,an,spd)
 an = an or rnd()
 spd = spd or 1
 e.vx=e.vx+cos(an)*spd
 e.vy=e.vy+sin(an)*spd
end
function wait(t,f,a,b,c,d,g,h,i,j,k)
	if not f then return end
	if t<=0 then 
		f(a,b,c,d,g,h,i,j,k)
		return
	end
 local e=mke(-1)
 e.life=t
 e.nxt=function() f(a,b,c,d,g,h,i,j,k) end
 return e
end
function loop(f,t,nxt)
 local e=mke(-1)
 e.upd=f
 e.life=t
 e.nxt=nxt
 return e
end




--
function ospr(fr,x,y,sheet,gw,gh)
	local a,b,c=my_spritesheet,my_grid_w,my_grid_h
	spritesheet(sheet)
	sprgrid(gw,gh)
	spr(fr,x,y)
	spritesheet(a)
	sprgrid(b,c)
end





