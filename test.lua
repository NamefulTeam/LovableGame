local Test = {}

function Test.load()
	love.graphics.setBackgroundColor(255, 255, 255)

	char = {}
	char.textures = {}

	char.quad = love.graphics.newQuad(3, 2, 26, 42, 32, 48)
	char.x = 32*4
	char.y = 170
	char.px = x
	char.py = y
	char.vx = 0
	char.vy = 0
	char.max_vy = 2000
	char.walk_speed = 400
	char.jump_speed = 300
	char.g = 300
	char.width = 24
	char.height = 42
	char.flipped = false
	char.draw_state = 'normal'
	char.in_ground = false
	char.in_ceiling = false
	char.textures.cast_front = love.graphics.newImage('common/char-cast-front.png')
	char.textures.cast_general = love.graphics.newImage('common/char-cast-general.png')
	char.textures.dead = love.graphics.newImage('common/char-dead.png')
	char.textures.normal = love.graphics.newImage('common/char-normal.png')

	ground = {}
	ground.width = 32
	ground.height = 32
	ground.quad = love.graphics.newQuad(0, 0, 32, 32, 32, 32)
	ground.textures = {}
	ground.yoffsets = {}

	ground.textures.spring_grass = love.graphics.newImage('spring/ground-grass.png')
	ground.yoffsets.spring_grass = 3

	map = {}
	map.ground = {}
	table.insert(map.ground, make_ground(32 * 0, 170, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 0, 150, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 0, 130, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 0, 110, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 1, 200, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 2, 200, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 3, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 4, 254, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 5, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 6, 245, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 7, 240, 'spring_grass'))

	table.insert(map.ground, make_ground(32 * 4, 100, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 5, 100, 'spring_grass'))

	table.insert(map.ground, make_ground(32 * 6, 100, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 6, 80, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 6, 60, 'spring_grass'))

end

function Test.draw()
	love.graphics.clear()

	draw_sprite(char)
	draw_map(map)
end

function Test.update(dt)
	update_sprite(char, dt)
end

function make_ground(x, y, tile)
	return {
		x = x,
		y = y,
		tile = tile
	}
end

function draw_map(map)
	for key, value in pairs(map.ground) do
		love.graphics.draw(ground.textures[value.tile], ground.quad, value.x, value.y)
	end
end

function draw_sprite(sprite)
	local xscale = char.flipped and -1 or 1
	local ox = char.flipped and sprite.width or 0

	love.graphics.draw(sprite.textures[sprite.draw_state], sprite.quad, sprite.x, sprite.y, 0, xscale, 1, ox, 0)
end

function update_sprite(sprite, dt)
	sprite.px = sprite.x
	sprite.py = sprite.y

	sprite.x = sprite.x + sprite.vx * dt
	sprite.y = sprite.y + sprite.vy * dt

	sprite.vy = sprite.vy + sprite.g * dt

	if sprite.vy > sprite.max_vy then
		sprite.vy = sprite.max_vy
	end
	if sprite.vy < -sprite.max_vy then
		sprite.vy = -sprite.max_vy
	end

	local direction = 0
	if love.keyboard.isDown(KeyConfig.left) then
		direction = direction - 1
	end
	if love.keyboard.isDown(KeyConfig.right) then
		direction = direction + 1
	end

	if direction < 0 then
		sprite.flipped = true
		sprite.x = sprite.x - sprite.walk_speed * dt
	elseif direction > 0 then
		sprite.flipped = false
		sprite.x = sprite.x + sprite.walk_speed * dt
	end

	-- Fix can_jump so mid-air jumps aren't possible.
	local can_jump = true
	if love.keyboard.isDown(KeyConfig.jump) then
		sprite.vy = -sprite.jump_speed
	end

	check_collisions_with_ground(sprite)
end

function check_collisions_with_ground(sprite)
	local solution = {
		min_x = -math.huge,
		max_x = math.huge,
		min_y = -math.huge,
		max_y = math.huge
	}

	-- Calculate constraints
	for key, value in pairs(map.ground) do
		if check_collision_with_ground(sprite.x, sprite.y, sprite, value) then
			-- Fix character position and speed
			perform_ground_collision(sprite, value, solution)
		end
	end

	if --min_x == -math.huge and max_x == math.huge and
		solution.min_y == -math.huge and solution.max_y == math.huge then

		-- No collisions
		return

	end

	-- Actually decide where to place sprite
	local valid_solutions = {}

	-- There are 8 possible adjustments (north, south, west, east and the corners)
	-- Let's try them all
	for x_adjustment = -1,1 do
		for y_adjustment = -1,1 do
			if not (x_adjustment == 0 and y_adjustment == 0) then
				if (not (x_adjustment < 0) or solution.min_x > -math.huge) and
					(not (x_adjustment > 0) or solution.max_x < math.huge) and
					(not (y_adjustment < 0) or solution.min_y > -math.huge) and
					(not (y_adjustment > 0) or solution.max_y < math.huge) then

					-- So far, so good. This adjustment "makes sense".
					-- If it is also valid (doesn't lead to a filled position), then we'll add it to the list

					local actual_x = sprite.x
					if x_adjustment < 0 then actual_x = solution.min_x end
					if x_adjustment > 0 then actual_x = solution.max_x end

					local actual_y = sprite.y
					if y_adjustment < 0 then actual_y = solution.min_y end
					if y_adjustment > 0 then actual_y = solution.max_y end

					assert(actual_x < math.huge)
					assert(actual_x > -math.huge)
					assert(actual_y < math.huge)
					assert(actual_y > -math.huge)
					table.insert(valid_solutions, {actual_x, actual_y, y_adjustment < 0, y_adjustment > 0})
				end
			end
		end
	end

	if #valid_solutions == 0 then
		-- Being smashed. Oops.
		-- Die or something
	else
		local min_squared_adjustment = math.huge
		local min_adjustment_index

		for key, value in pairs(valid_solutions) do
			local xdiff = value[1] - sprite.x
			local ydiff = value[2] - sprite.y

			local squared_adjustment = xdiff * xdiff + ydiff * ydiff
			if squared_adjustment < min_squared_adjustment then
				min_squared_adjustment = squared_adjustment
				min_adjustment_index = key
			end
		end

		assert(min_adjustment_index ~= nil)

		-- Fix position
		local chosen_position = valid_solutions[min_adjustment_index]
		sprite.x = chosen_position[1]
		sprite.y = chosen_position[2]
		if chosen_position[3] and sprite.vy < 0 then
			sprite.vy = 0
		elseif chosen_position[4] and sprite.vy > 0 then
			sprite.vy = 0
		end
	end
end

function try_collisions_at_position(tentative_x, tentative_y, sprite)
	for key, value in pairs(map.ground) do
		if check_collision_with_ground(tentative_x, tentative_y, sprite, value) then
			return true
		end
	end

	return false
end

function perform_ground_collision(sprite, tile, solution)
	local ground_yoffset = ground.yoffsets[tile.tile]

	if sprite.y + sprite.height < tile.y + ground_yoffset + ground.height then
		-- Collision from upwards (usually hero is going down)
		local proposed_y = tile.y + ground_yoffset - sprite.height + 1
		solution.max_y = math.min(solution.max_y, proposed_y)
	elseif sprite.y > tile.y then
		-- Collision from downwards (usually hero is going up)
		local proposed_y = tile.y + ground.height
		solution.min_y = math.max(solution.min_y, proposed_y)
	end

	if sprite.x < tile.x then
		-- Collision from the left side of the tile (character is probably going right)
		local proposed_x = tile.x - sprite.width + 1
		solution.max_x = math.min(solution.max_x, proposed_x)
	elseif sprite.x + sprite.width > tile.x then
		-- Collision from the right side of the tile (character is probably going left)
		local proposed_x = tile.x + ground.width
		solution.min_x = math.max(solution.min_x, proposed_x)
	end
end

function check_collision_with_ground(sprite_x, sprite_y, sprite, tile)
	return sprite_x <= tile.x + ground.width and
		sprite_x + sprite.width > tile.x and
		sprite_y <= tile.y + ground.height and
		sprite_y + sprite.height > tile.y + ground.yoffsets[tile.tile]
end

return Test
