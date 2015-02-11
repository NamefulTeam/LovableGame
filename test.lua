local Test = {}

function Test.load()
	love.graphics.setBackgroundColor(255, 255, 255)

	char = {}
	char.textures = {}

	char.quad = love.graphics.newQuad(4, 2, 25, 42, 32, 48)
	char.x = 100
	char.y = 48
	char.vx = 0
	char.vy = 0
	char.g = 50
	char.width = 24
	char.height = 42
	char.flipped = false
	char.draw_state = 'normal'
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
	table.insert(map.ground, make_ground(0, 300, 'spring_grass'))
	table.insert(map.ground, make_ground(32, 300, 'spring_grass'))
	table.insert(map.ground, make_ground(64, 300, 'spring_grass'))
	table.insert(map.ground, make_ground(96, 300, 'spring_grass'))
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

	love.graphics.draw(sprite.textures[sprite.draw_state], sprite.quad, sprite.x, sprite.y, 0, xscale, 1, 0, 0)
end

function update_sprite(sprite, dt)
	sprite.x = sprite.x + sprite.vx * dt
	sprite.y = sprite.y + sprite.vy * dt

	sprite.vy = sprite.vy + sprite.g * dt

	check_collisions_with_ground(sprite)
end

function check_collisions_with_ground(sprite)
	for key, value in pairs(map.ground) do
		if check_collision_with_ground(sprite, value) then
			sprite.vx = 0
			sprite.vy = 0
			-- TODO: Correct position
		end
	end
end

function check_collision_with_ground(sprite, tile)
	if sprite.x < tile.x + ground.width and
		sprite.x + sprite.width >= tile.x and
		sprite.y < tile.y + ground.height and
		sprite.y + sprite.height >= tile.y + ground.yoffsets[tile.tile] then

		return true

	end
end

return Test
