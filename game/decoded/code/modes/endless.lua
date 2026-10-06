id="endless"
setup={
	slots_max={10,10},
}
base={
	chamber_max=2, firepower=4, firerange=3, spread=55, ammo_max=5,
	pawn_global_promote=1, surrender=1,
	gain={3,0,0,0,1,5,2,0},
	ai_lvl=1,
}
function start()
	if LIVE then
		live("set_presence", "endless")
	end

	init_game()
	mode.lvl=0
	mode.turns=0
	
	restore_run()
	
	next_floor()
end
function next_floor()
	save_run()

	mode.lvl=mode.lvl+1
	new_level()	
	if LIVE then
		live("send_event", "BeginEndlessFloor", "{\"Floor\":"..mode.lvl.."}")
	end
end
function on_empty()
	end_level(grow)
end
function on_hero_death()
	if mode.lvl > (DEN.prog.endless or 0) then
		DEN.prog.endless = mode.lvl
	end
	DEN.prog.save()
	
	forget_run()
	
	gameover()
end


function grow()

	local data={
		id="level_up", 
		pan_xm=1,
		pan_ym=2, 
		pan_width=80,
		pan_height=96,
		choices={
			{{team=0},{team=1}},
			{{team=0},{team=1}},
		},
	}	

	if mode.lvl==3 then
		for i=1,2 do 
			data.choices[i][2].id="Homecoming"
		end
	end


	if mode.lvl<11 then
		level_up(data,next_floor)
	else			
		decay_up(next_floor)
	end	
end

--
function draw_inter()
	local s = lang.floor_.." "
	local x = lprint(s,MCW/2,board_y-19,3,1)
	lprint(mode.lvl,x,board_y-19,5)
end
