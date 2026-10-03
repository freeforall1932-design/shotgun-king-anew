id="Shootout"
setup={
	slots_max={10,10},
}
base={
	chamber_max=2, firepower=2, firerange=2, spread=5, ammo_max=12,

	knight_bow=4,
	bishop_bow=4,
	king_bow=3,
	pawn_bow=3,
	pawn_shield=1,
	moat=4,
	force_promote=1,
	surrender=1,
	gain={5,0,0,1,0}
		-- PIECES
		-- These are used in card descriptions and other interface elements.
		-- piece_0::Pawn
		-- piece_1::Knight
		-- piece_2::Bishop
		-- piece_3::Rook
		-- piece_4::Queen
		-- piece_5::King
		-- piece_6::Boss
		-- piece_7::All pieces
}
function start()
	init_game()
	mode.lvl=0
	mode.turns=0
	next_floor()
end
function next_floor()
	mode.lvl=mode.lvl+1
	new_level()
end
function on_empty()
	end_level(grow)		
end

function on_hero_death()
	bank("save")
	if mode.lvl > bget(0,2) then
		bset(0,2,mode.lvl)
	end
	save()
	gameover()	
end

append("new_turn", function()
    for e in all(bads) do
        if (e.type >= 2 and e.type <= 4) then
            xpl(e)
        end
    end
end, "id:newtn")


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
