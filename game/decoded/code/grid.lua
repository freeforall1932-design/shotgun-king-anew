


function mk_grid()

	local grid={pos={}}
	for sq in all(squares) do
		if sq.p then
			grid.pos[sq.p]=sq
		end
	end
	
	grid.mov=function(p,tsq) 		
		grid.pos[p]=tsq		
	end
	grid.push=function(p,di)
		if not p or not grid.pos[p] then return 0 end
		local nsq=dsq(grid.pos[p],di)
		local np=grid.piece_at(nsq)		
		if np and np~=hero and (np.big or np.type==leader) then return -100 end
		local pushed=np and 1 or 0
		pushed=pushed+grid.push(np,di)
		grid.pos[p]=nsq	
		return pushed
	end
	
	grid.piece_at=function(sq)
		for k,v in pairs(grid.pos) do
			if v==sq then return k end
			if k.big then
				local a=get_piece_squares(k)
				for bsq in all(a) do 
					if bsq==sq then return k end
				end
			end
		end	
		return nil
	end
	return grid

end

--[[
function clone_grid(grid)
	local new_grid=mk_grid()
	for k,v in pairs(grid.pos) do
		new_grid.pos[k]=v
	end	
	return new_grid	
end
--]]

function paint_danger(grid)

	-- DANGER
	for sq in all(squares) do sq.dan=0 end

	--grid.danger={}

	for p,sq in pairs(grid.pos) do
		--PAINT DANGER
		if p.bad then		
			
			local osq=p.sq
			p.sq=sq
			local a=get_range(p,{atk=1,plan=1})--(p,"atk",nil,true)
			p.sq=osq			
			for sq in all(a) do sq.dan=sq.dan+1 end		
		end
	end


end

function score_grid(grid,from)

	grid.score=grid.bonus or 0
	local function sco(n)
		grid.score=grid.score+n
	end

	-- MODIFY SQUARES
	for sq in all(squares) do sq.op=sq.p end
	for p,sq in pairs(grid.pos) do sq.p=p end
	
	-- DANGER
	for sq in all(squares) do sq.dan=0 end

	-- PIECES
	local hsq=get_hero_sq()
	local hsd=pside(hsq)

	for p,sq in pairs(grid.pos) do
	
		local pdan=p.danger or 0
	
		-- BLACK PIECE
		if not p.bad and (stack.ai_lvl or 0)>=1 then	-- was ai_lvl
			if p.type~=5 then				
				local a=get_piece_targets(p,sq)
				for trg in all(a) do
					local n=trg.danger or 0
					if trg.type==leader then n=n*2 end
					sco(-n)
				end
			end
			goto continue
		end

		-- ARMY SUM		
		sco(pdan)
		
		-- PROMOTION EVAL
		if p.promote then			
			if sq.py==7 then 
				sco(3)
			else			
				sco(sq.py*(p.type==0 and 1 or 2)/8)
			end
		end		
	
		--PAINT DANGER
		if p.bad then		
			local osq=p.sq
			p.sq=sq
			local a=get_range(p,{atk=1,plan=1})
			p.sq=osq			
			for sq in all(a) do sq.dan=sq.dan+1 end		
		end	

		-- MOAT
		if stack.moat and not stack.bridge and not p.flying and p.type~=1 then			
			local psd=pside(sq)			
			if hsd~=0 and psd==-hsd or ( hsd==0 and stack.deepwater ) then --
				sco(-pdan)
			end
		end

		-- PPOV
		if from==p then		
			-- FEAR
			if p.fear then sco(sq.wdist*10)	end			
			-- GUARD
			if p.jester and stack.jester_guard then	sco(-(sq.gdist or 0)*2) end
			-- SEEK
			--if p.seek then sco( -sq[p.seek]/4-sq.wdist/8)	end
			
			
		end
		
		-- COVER
		if p.type==leader then
			local a=bres_2(hsq.px,hsq.py,sq.px,sq.py)			
			for i=2,#a do
				local p=a[i]
				local osq=gsq(p.x,p.y)
				if osq and osq.p and osq.p.type~=leader then
					sco(min(osq.p.hp,3)/80)
				end
			end
		end
		
		-- SEEK
		if p.dgr then			
			sco(-min(p.dgr[sq],6)/8)
		end
		
		-- DIAG NEAR TRG
		sco(1/(sq.ddist+20))		
		
		-- INQUISITION
		if sq.waypoint and p.investigate then
			sco(2)
		end
		
		-- DOUBT ( disguise )
		if p.type==leader and hero.cloaked and hero.disguised then
			--kok=kok and kok+1 or 1
			--log("!"..kok)
			sco(sq.doubt_dist or 0)
			--local n=get_sq_dist_from({type=hero.disguised})
		end
		
		-- WARD
		if p.ward then			
			for op,lsq in pairs(grid.pos) do
				if op.bad and op.type==get_leader_type() then
					local function ga(a,b)
						return atan2(a.px-b.px,a.py-b.py)
					end
					local da=hmod(ga(lsq,sq)-ga(hsq,sq),.5)
					sco(abs(da)*10)					
				end			
			end		
		end
		
		
		::continue::

	end

	local h=get_hero_trg()
	if not grid.pos[h] and not h.cloaked then sco(2000) end
	if not grid.pos[hero] and stack.elusive then sco(-4000) end
	
	-- SCAN ALL SQUARES ( DANGER )
	if not hero.cloaked or hero.holoking then
		local ai_lvl=stack.ai_lvl or 0
		for sq in all(squares) do		
			-- DANGER
			local trg=hero.holoking or hero
			if sq.dan>0 then
				if sq.p==trg then	-- ENDANGER KING
					sco(sq.dan>1 and 5 or 3)
				elseif sq.p and not sq.p.bad then
					sco(2)
				elseif sq.ddist<=1 and ai_lvl>=1 then -- ENDANGER KING'S MOVE ZONE ( ddist not update if king move )
					sco(1)
				elseif ai_lvl>=2 then -- ENDANGER ANY SQUARES 
					sco(1/20)
				end			
			end
		end		
	end
	
	
	-- LOG DANGERS
	grid.dangers={}
	for sq in all(squares) do
		grid.dangers[sq]=sq.dan
	end
	
	-- END
	for sq in all(squares) do sq.p=sq.op end

end

function pside(sq)
	if sq.py>4 then return 1 
	elseif sq.py<4 then return -1
	else return 0 end
end


--- DEV
function dev_log_grids_time(grids,e)
	local total_time=0
	for gr in all(grids) do
		total_time=total_time+(gr.gt or 0)		
	end
	log("("..#grids..") "..e.name..":"..flr(total_time*1000*1000)/1000)
end