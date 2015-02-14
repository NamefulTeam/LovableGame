Physics = {}

function Physics.check_collisions_with_ground(map, sprite)
	-- Calculate constraints
	for key, value in pairs(map.ground) do
		if Physics.check_collision_with_ground(map, sprite.x, sprite.y, sprite, value) then
			-- Fix character position and speed
			Physics.perform_ground_collision(map, sprite, value)
		end
	end

	-- TODO: Check if character is being smashed (?)
end

function Physics.has_collisions_at_position(map, tentative_x, tentative_y, sprite)
	for key, value in pairs(map.ground) do
		if Physics.check_collision_with_ground(map, tentative_x, tentative_y, sprite, value) then
			return true
		end
	end

	return false
end

function Physics.perform_ground_collision(map, sprite, tile)
	local ground_yoffset = map.ground_info.yoffsets[tile.tile]

	local sprite_centerx = sprite.x + sprite.width / 2
	local sprite_centery = sprite.y + sprite.height / 2
	local tile_centerx = tile.x + map.ground_info.width / 2
	local tile_centery = tile.y + (map.ground_info.height + ground_yoffset) / 2
	local diffx = sprite_centerx - tile_centerx
	local diffy = sprite_centery - tile_centery

	local proposed_x = sprite.x
	local proposed_y = sprite.y

	if diffy < 0 then
		-- Collision from upwards (usually hero is going down)
		proposed_y = tile.y + ground_yoffset - sprite.height
	elseif diffy > 0 then
		-- Collision from downwards (usually hero is going up)
		proposed_y = tile.y + map.ground_info.height
	end

	if diffx < 0 then
		-- Collision from the left side of the tile (character is probably going right)
		proposed_x = tile.x - sprite.width
	elseif diffx > 0 then
		-- Collision from the right side of the tile (character is probably going left)
		proposed_x = tile.x + map.ground_info.width
	end

	local can_move_x = not Physics.has_collisions_at_position(map, proposed_x, sprite.py, sprite)
	local can_move_y = not Physics.has_collisions_at_position(map, sprite.px, proposed_y, sprite)

	local distance_x = proposed_x - sprite.x
	local distance_y = proposed_y - sprite.y

	local prefer_y =  distance_x * distance_x > distance_y * distance_y

	local fix_x = false
	local fix_y = false

	if can_move_y then
		if prefer_y or not can_move_x then
			fix_y = true
		else
			fix_x = true
		end
	elseif can_move_x then
		fix_x = true
	else
		-- Can't move in either way
		-- Try moving in both ways simultaneously
		-- TODO: Is this even supposed to happen?

		print('move both')

		local can_move_both = not Physics.has_collisions_at_position(map, proposed_x, proposed_y, sprite)
		if can_move_both then
			fix_x = true
			fix_y = true
		else
			-- TODO: Handle this
			assert(false, 'Collision panic')
		end
	end

	if fix_x then
		if sprite.vx > 0 and sprite.x > proposed_x then
			sprite.vx = 0
		elseif sprite.vx < 0 and sprite.x < proposed_x then
			sprite.vx = 0
		end

		sprite.x = proposed_x
	end

	if fix_y then
		if sprite.vy > 0 and sprite.y > proposed_y then
			sprite.vy = 0
		elseif sprite.vy < 0 and sprite.y < proposed_y then
			sprite.vy = 0
		end

		sprite.y = proposed_y
	end
end

function Physics.check_collision_with_ground(map, sprite_x, sprite_y, sprite, tile)
	local yoffset = map.ground_info.yoffsets[tile.tile]

	return Physics.check_collision_rect(sprite_x, sprite_y, sprite.width, sprite.height,
		tile.x, tile.y + yoffset, map.ground_info.width, map.ground_info.height - yoffset)
end

function Physics.check_collision_rect(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and
		x1 + w1 > x2 and
		y1 < y2 + h2 and
		y1 + h1 > y2
end

return Physics
