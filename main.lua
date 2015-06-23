function show_field(field) 

	if field == nil then
		print("field is empty")
		return;
	end

	local counter = 1
	for i = 1,3 do
		local str = ""
		for j = 1, 3 do
			if nil == field[i][j] then
				str = str .. '|' .. counter .. '|'
			else
				str = str .. '|' .. tostring(field[i][j]) .. '|'
			end
			counter = counter + 1
		end
		print(str)
	end
end

function count_field(field, player_sign, enemy_sign)
	local output_field = {}
	local get_count = get_count_factory(player_sign, enemy_sign)

	--setup

	for i = 1,3 do
		output_field[i] = {}
		for j = 1,3 do
			output_field[i][j] = 0
		end
	end

	--horizontals

	local index = {1,2,3}

	for i = 1,3 do
		for j = 1,3 do
			if field[i][index[1]] == nil then
				output_field[i][index[1]] = get_count(field[i][index[2]]) + get_count(field[i][index[3]]) 
			end
			local first = table.remove(index,1)
			index[3] = first
		end
	end

	--verticals

	index = {1,2,3}

	for i = 1,3 do
		for j = 1,3 do
			local new_c = get_count(field[index[2]][i]) + get_count(field[index[3]][i])
			if field[index[1]][i] == nil and math.abs(output_field[index[1]][i]) < math.abs(new_c)  then
				output_field[index[1]][i] = new_c
			end
			local first = table.remove(index,1)
			index[3] = first
		end
	end

	--diagonal 1

	index = {1,2,3}

	for i = 1,3 do
		local new_c = get_count(field[index[2]][index[2]]) + get_count(field[index[3]][index[3]])
		if field[index[1]][index[1]] == nil and math.abs(output_field[index[1]][index[1]]) < math.abs(new_c)  then
			output_field[index[1]][index[1]] = new_c
		end
		local first = table.remove(index,1)
		index[3] = first
	end

	--diagonal 2

	local new_c = get_count(field[2][2]) + get_count(field[3][1])
	if field[1][3] == nil and math.abs(output_field[1][3]) < math.abs(new_c)  then
		output_field[1][3] = new_c
	end
	new_c = get_count(field[2][2]) + get_count(field[1][3])
	if field[3][1] == nil and math.abs(output_field[3][1]) < math.abs(new_c)  then
		output_field[3][1] = new_c
	end

	return output_field;
end

function get_count_factory(psign, esign)
	return function(sign)
		if sign == nil then
			return 0
		elseif sign == psign then
			return 1
		elseif sign == esign then
			return -1
		end
	end
end

function check_win(field)
	local winner = nil

	for i=1,3 do
		--horizontal
		if field[1][i] == field[2][i] and field[1][i] == field[3][i] and field[1][i] ~= nil then
			winner = field[1][i]
			return winner
		end
		--vertical
		if field[i][1] == field[i][2] and field[i][1] == field[i][3] and field[i][1] ~= nil then
			winner = field[i][1]
			return winner
		end
	end

	--diag1
	if field[1][1] == field[2][2] and field[1][1] == field[3][3] and field[1][1] ~= nil then
		winner = field[1][1]
		return winner
	end

	--diag2
	if field[1][3] == field[2][2] and field[1][3] == field[3][1] and field[1][3] ~= nil then
		winner = field[1][3]
		return winner
	end

	local is_empty = false
	for i = 1,3 do
		for j = 1,3 do
			if field[i][j] == nil then
				is_empty = true;
				break;
			end
		end
	end

	if not is_empty then
		winner = "nothing"
	end
	return winner
end

function get_comp_step(main_field, player_sign, enemy_sign, is_hard)

	local output_field = count_field(main_field, player_sign, enemy_sign);

	local current_step = {-1, -1}
	local max = 0
	for i = 1, 3 do
		for j = 1,3 do
			if math.abs(output_field[i][j]) > math.abs(max) then
				max = output_field[i][j]
				current_step = {i,j}
			end
		end
	end

	if is_hard then
		if (math.abs(output_field[2][2]) == math.abs(max)) then
			current_step = {2,2}
		end
	end

	if current_step[1] == -1 and current_step[2] == -1 then
		local empty_cell = {}
		for i = 1, 3 do
			for j = 1,3 do
				if main_field[i][j] == nil then
					table.insert(empty_cell, {i,j})
				end
			end
		end
		local random_cell 
		for i = 1, 3 do
			random_cell = math.random(#empty_cell)
		end
		current_step = empty_cell[random_cell]
	end

	return current_step
end

function tocellcoordinate(number)
	if number == nil or  number <= 0 or number > 9 then
		return nil
	end
	local coord = { {1,1}, {1,2}, {1,3}, {2,1}, {2,2}, {2,3}, {3,1}, {3,2}, {3,3} }
	return coord[number]
end

function start_game(player_interaction, enemy_interaction) 

	local main_field = {}
	main_field[1] = { nil, nil, nil }
	main_field[2] = { nil, nil, nil }
	main_field[3] = { nil, nil, nil }


	local player_sign = 'X'
	local enemy_sign = 'O'

	local player_stack = { 
		{ sign = player_sign, interaction = player_interaction }, 
		{ sign = enemy_sign, interaction = enemy_interaction } 
	}

	local winner = nil
	repeat
		local player_turn
		repeat
			os.execute('cls')
			print('Current player:' .. player_stack[1].sign .. " Enter number of cell.")
			show_field(main_field)
			player_turn = player_stack[1].interaction(main_field, player_stack[1].sign, player_stack[2].sign)
		until player_turn ~= nil and main_field[player_turn[1]][player_turn[2]] == nil
		main_field[player_turn[1]][player_turn[2]] = player_stack[1].sign 

		local temp = table.remove(player_stack, 1)
		player_stack[2] = temp
		winner = check_win(main_field)
	until (winner)

	os.execute('cls')
	show_field(main_field)

	if "nothing" == winner then
		print("Congratulation! Friendship wins!")
	else
		print("Congratulation! Win : " .. winner)
	end

	print("Press any key...")
	io.flush()
	io.read(2)
end

math.randomseed( os.time() )
local human = function() return tocellcoordinate(tonumber(io.read(1))) end 
local hard_computer = function(x,y,z) return get_comp_step(x,y,z,true) end
local easy_computer = function(x,y,z) return get_comp_step(x,y,z,false) end

repeat 

	os.execute('cls')
	print("Select mode. Enter the number:")
	print("1. Hot Seat")
	print("2. Man X VS Easy Computer")
	print("3. Man O VS Easy Computer")
	print("4. Man X VS Hard Computer")
	print("5. Man O VS Hard Computer")
	print("6. Hard Computer VS Hard Computer")
	print("-------------------------")
	print("0. Exit")

	local input = tonumber(io.read(1))

	if input == 1 then
		start_game(human, human)
	elseif input == 2 then
		start_game(human, easy_computer)
	elseif input == 3 then
		start_game(easy_computer, human)
	elseif input == 4 then
		start_game(human, hard_computer)
	elseif input == 5 then
		start_game(hard_computer, human)
	elseif input == 6 then
		start_game(hard_computer, hard_computer)
	end

until input == 0


