local showing_prob

function upd()
	if btnp("lstickb") and get_square_at(mx,my) then showing_prob = not showing_prob end
end

function init_squares()
	local sqs = {}
	for sq in all(squares) do
		sqs[sq] = 0
	end
	return sqs
end

function is_solidsquare(sq,sco)
	return sq and not sq.moat
end

function jump(probs)
	new_probs = init_squares()

	for sq,prob in pairs(probs) do
		if prob > 0 then
			local prob = prob/9

			new_probs[sq] = new_probs[sq] + prob

			for di=0,7 do
				local tsq = dsq(sq,di)
				if is_solidsquare(tsq) then new_probs[tsq] = new_probs[tsq] + prob end
			end
		end
	end

	return new_probs
end

function draw_4()
	if stack.special == "grenade" and playing and t%60 >= 9 and hero.grenade_ready
	and btn("lstickb") and not stack.grenade_sticky then
		local sq = get_square_at(mx,my)
		if is_solidsquare(sq) and sq.p ~= hero then
			
			local dd = dist(sq,hero.sq)
			local jz = dd/2+8
			if stack.grenade_throwpower then jz = jz * stack.grenade_throwpower/100 end
			local probs = init_squares()
			probs[sq] = 1
			local frict = stack.trampoline and 0.75 or 0.5

			while jz > 20 do
				probs = jump(probs)
				jz = jz * frict
			end

			if not showing_prob then
				for p in all(bads) do
					local sq = p.sq
					local dmg = probs[sq]
					for di=0,7 do
						local tsq = dsq(sq,di)
						if tsq then dmg = dmg + probs[tsq] end
					end
					dmg = dmg * stack.grenade_dmg
					if stack.grenade_center_dmg then
						dmg = dmg + probs[sq]*stack.grenade_center_dmg
					end

					if dmg ~= 0 then
						lprint((round(dmg*10)/10),p.x+8,p.y+2,5,1)
						palt(4,true)
						sspr(87,56,9,8,p.x+3,p.y+7)
						palt(4)
						pset(p.x+5,p.y+9,4)
						pset(p.x+8,p.y+9,4)
					end

				end

				return
			end

			for sq,prob in pairs(probs) do
				if prob > 0 then
					lprint(round(prob*100).."%",sq.x+8,sq.y+5,5,1)
				end
			end

		end
	end
end

chinese = {
	terminal_warning = "冰凌中枢运转异常！请确认是否正确安装",
}

english = {
	terminal_warning = "Glac Terminal is not loaded correctly!",
}

function add_lang(s)
	tbl_import(lang,s=="simplified_chinese" and chinese or english)
end

add_lang(current_lang)
append("load_lang",add_lang,"grenade indicator")

function warn()
	log(lang.terminal_warning)
	wlog(lang.terminal_warning)
	append("init_menu",bind(sfx,"wrong"),"glacies warning")
end

function scan()
	for mod in all(MODLIST) do
		if mod.title == "Glacies Module Terminal" then
			if not mod.active then
				warn()
			else
				for title,mod in pairs(MODS) do
					if mod.title == "Glacies Module Terminal" then warn() end
				end
			end
			return
		end
	end
	warn()
end

scan()
