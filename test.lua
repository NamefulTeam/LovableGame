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
	-- Calculate constraints
	for key, value in pairs(map.ground) do
		if check_collision_with_ground(sprite.x, sprite.y, sprite, value) then
			-- Fix character position and speed
			perform_ground_collision(sprite, value)
		end
	end

	-- TODO: Check if character is being smashed
end

function try_collisions_at_position(tentative_x, tentative_y, sprite)
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

	local angle = math.atan2(diffy, diffx)

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

	local fix_x = false
	local fix_y = false

	if (angle > math.pi / 4 and angle < 3 * math.pi / 4) or
		(angle > -3 * math.pi / 4 and angle < -math.pi / 4) then
		fix_y = true
		print('fix_y')
	else
		fix_x = true
		print('fix_x')
	end

	if fix_x or fix_y and try_collisions_at_position(sprite.x, proposed_y, sprite) then
		sprite.x = proposed_x
		fix_x = true
	end
	if fix_y or fix_x and try_collisions_at_position(proposed_x, sprite.y, sprite) then
		sprite.y = proposed_y
		fix_y = true
	end

	if fix_x then
		sprite.x = proposed_x
	end

	if fix_y then
		sprite.y = proposed_y

		if sprite.vy > 0 and angle < 0 then
			sprite.vy = 0
		elseif sprite.vy < 0 and angle > 0 then
			sprite.vy = 0
		end
	end
end

function check_collision_with_ground(sprite_x, sprite_y, sprite, tile)
	return sprite_x < tile.x + ground.width and
		sprite_x + sprite.width > tile.x and
		sprite_y < tile.y + ground.height and
		sprite_y + sprite.height > tile.y + ground.yoffsets[tile.tile]
end

return Test
