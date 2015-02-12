local Test = {}

function Test.load()
	love.graphics.setBackgroundColor(255, 255, 255)

	char = {}
	char.textures = {}

	-- Graphics setup
	char.quad = love.graphics.newQuad(3, 2, 26, 42, 32, 48)

	-- Variables
	char.x = 32*4
	char.y = 170
	char.px = x
	char.py = y
	char.vx = 0
	char.vy = 0
	char.jump_key_active_last_frame = false
	char.flipped = false
	char.state = 'normal'
	char.in_ground = false
	char.in_ceiling = false

	-- Constants
	char.max_vy = 2000
	char.max_vx = 1000
	char.wall_fall_g_friction = 0.8 -- Relative to char.g
	char.max_grab_fall_speed = 1000
	char.x_friction_threshold = 10
	char.x_friction = 0.1
	char.walk_acceleration = 30
	char.jump_speed = 300
	char.wall_jump_xspeed = 900
	char.wall_jump_yspeed = 200
	char.g = 500
	char.width = 24
	char.height = 42

	-- Textures
	char.textures.cast_front = love.graphics.newImage('common/char-cast-front.png')
	char.textures.cast_general = love.graphics.newImage('common/char-cast-general.png')
	char.textures.dead = love.graphics.newImage('common/char-dead.png')
	char.textures.normal = love.graphics.newImage('common/char-normal.png')
	char.textures.grab_wall = love.graphics.newImage('common/char-grab-wall.png')

	ground = {}
	ground.width = 32
	ground.height = 32
	ground.quad = love.graphics.newQuad(0, 0, 32, 32, 32, 32)
	ground.textures = {}
	ground.yoffsets = {}

	ground.textures.spring_grass = love.graphics.newImage('spring/ground-grass.png')
	ground.yoffsets.spring_grass = 3
	ground.textures.spring_deep = love.graphics.newImage('spring/ground-deep.png')
	ground.yoffsets.spring_deep = 0

	map = {}
	map.ground = {}
	table.insert(map.ground, make_ground(32 * 0, 110, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 0, 110 + 32, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 0, 110 + 32 * 2, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 0, 110 + 32 * 3, 'spring_deep'))

	table.insert(map.ground, make_ground(32 * 1, 200, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 2, 200, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 3, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 4, 254, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 5, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 6, 245, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 7, 240, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 8, 240, 'spring_grass'))

	table.insert(map.ground, make_ground(32 * 4, 100, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 5, 100, 'spring_grass'))

	table.insert(map.ground, make_ground(32 * 8, 240, 'spring_grass'))

	table.insert(map.ground, make_ground(32 * 6, 60, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 6, 60 + 32, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 6, 60 + 32 * 2, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 6, 60 + 32 * 3, 'spring_deep'))

	table.insert(map.ground, make_ground(32 * 9, 32 * 1, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 2, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 3, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 4, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 5, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 6, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 7, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 9, 32 * 8, 'spring_deep'))
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

	love.graphics.draw(sprite.textures[sprite.state], sprite.quad, sprite.x, sprite.y, 0, xscale, 1, ox, 0)
end

function update_sprite(sprite, dt)
	sprite.px = sprite.x
	sprite.py = sprite.y

	sprite.x = sprite.x + sprite.vx * dt
	sprite.y = sprite.y + sprite.vy * dt

	if sprite.vx > sprite.x_friction_threshold or sprite.vx < -sprite.x_friction_threshold then
		sprite.vx = sprite.vx * (1 - sprite.x_friction)
	else
		sprite.vx = 0
	end
	sprite.vy = sprite.vy + sprite.g * dt

	if sprite.vy > sprite.max_vy then
		sprite.vy = sprite.max_vy
	elseif sprite.vy < -sprite.max_vy then
		sprite.vy = -sprite.max_vy
	end
	if sprite.vx > sprite.max_vx then
		sprite.vx = sprite.max_vx
	elseif sprite.vx < -sprite.max_vx then
		sprite.vx = -sprite.max_vx
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
		sprite.vx = sprite.vx - sprite.walk_acceleration
	elseif direction > 0 then
		sprite.flipped = false
		sprite.vx = sprite.vx + sprite.walk_acceleration
	end

	check_collisions_with_ground(sprite)

	local can_jump = can_jump_up(sprite)
	local can_wall_jump_left = not can_jump and can_wall_jump_left(sprite)
	local can_wall_jump_right = not can_jump and can_wall_jump_right(sprite)

	local jump_key_active = love.keyboard.isDown(KeyConfig.jump)

	if sprite.state == 'normal' then
		if not char.jump_key_active_last_frame and jump_key_active then
			if can_wall_jump_left then
				sprite.state = 'grab_wall'
				sprite.flipped = true
			elseif can_wall_jump_right then
				sprite.state = 'grab_wall'
				sprite.flipped = false
			elseif can_jump then
				sprite.vy = -sprite.jump_speed
				sprite.y = sprite.y
				sprite.jump_cooldown_state = sprite.jump_cooldown
			end
		end
	elseif sprite.state == 'grab_wall' then
		if sprite.vy > 0 then
			sprite.vy = sprite.vy - sprite.g * sprite.wall_fall_g_friction * dt -- Counter G
		end
		if sprite.vy > sprite.max_grab_fall_speed then
			sprite.vy = sprite.max_grab_fall_speed
		end

		if not jump_key_active then
			if sprite.flipped then
				-- Jump to the left
				sprite.vx = -sprite.wall_jump_xspeed
				sprite.vy = -sprite.wall_jump_yspeed
				sprite.jump_cooldown_state = sprite.jump_cooldown
				sprite.state = 'normal'
			else
				-- Jump to the right
				sprite.vx = sprite.wall_jump_xspeed
				sprite.vy = -sprite.wall_jump_yspeed
				sprite.jump_cooldown_state = sprite.jump_cooldown
				sprite.state = 'normal'
			end
		else
			local disable_grab = false

			if can_jump then
				-- On ground
				disable_grab = true
			elseif sprite.flipped then
				if not can_wall_jump_left then
					disable_grab = true
				end
			else
				if not can_wall_jump_right then
					disable_grab = true
				end
			end

			if disable_grab then
				sprite.state = 'normal'
			end
		end
	end

	char.jump_key_active_last_frame = jump_key_active
end

function can_jump_up(sprite)
	return has_collisions_at_position(sprite.x, sprite.y + 1, sprite)
end

-- For whenever we add reverse gravity
function can_jump_down(sprite)
	return has_collisions_at_position(sprite.x, sprite.y - 1, sprite)
end

function can_wall_jump_left(sprite)
	return has_collisions_at_position(sprite.x + 1, sprite.y, sprite)
end

function can_wall_jump_right(sprite)
	return has_collisions_at_position(sprite.x - 1, sprite.y, sprite)
end

function check_collisions_with_ground(sprite)
	-- Calculate constraints
	for key, value in pairs(map.ground) do
		if check_collision_with_ground(sprite.x, sprite.y, sprite, value) then
			-- Fix character position and speed
			perform_ground_collision(sprite, value)
		end
	end

	-- TODO: Check if character is being smashed
end

function has_collisions_at_position(tentative_x, tentative_y, sprite)
	for key, value in pairs(map.ground) do
		if check_collision_with_ground(tentative_x, tentative_y, sprite, value) then
			return true
		end
	end

	return false
end

function perform_ground_collision(sprite, tile)
	local ground_yoffset = ground.yoffsets[tile.tile]

	local sprite_centerx = sprite.x + sprite.width / 2
	local sprite_centery = sprite.y + sprite.height / 2
	local tile_centerx = tile.x + ground.width / 2
	local tile_centery = tile.y + (ground.height + ground_yoffset) / 2
	local diffx = sprite_centerx - tile_centerx
	local diffy = sprite_centery - tile_centery

	local proposed_x = sprite.x
	local proposed_y = sprite.y

	if diffy < 0 then
		-- Collision from upwards (usually hero is going down)
		proposed_y = tile.y + ground_yoffset - sprite.height
	elseif diffy > 0 then
		-- Collision from downwards (usually hero is going up)
		proposed_y = tile.y + ground.height
	end

	if diffx < 0 then
		-- Collision from the left side of the tile (character is probably going right)
		proposed_x = tile.x - sprite.width
	elseif diffx > 0 then
		-- Collision from the right side of the tile (character is probably going left)
		proposed_x = tile.x + ground.width
	end

	local can_move_x = not has_collisions_at_position(proposed_x, sprite.py, sprite)
	local can_move_y = not has_collisions_at_position(sprite.px, proposed_y, sprite)

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

		local can_move_both = not has_collisions_at_position(proposed_x, proposed_y, sprite)
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

function check_collision_with_ground(sprite_x, sprite_y, sprite, tile)
	return sprite_x < tile.x + ground.width and
		sprite_x + sprite.width > tile.x and
		sprite_y < tile.y + ground.height and
		sprite_y + sprite.height > tile.y + ground.yoffsets[tile.tile]
end

return Test
