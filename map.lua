Test = {}
Character = require 'common.char'
Physics = require 'physics'

function Test.load()
	love.graphics.setBackgroundColor(255, 255, 255)

	char = Character()

	local ground = {}
	ground.width = 32
	ground.height = 32
	ground.quad = love.graphics.newQuad(0, 0, 32, 32, 32, 32)
	ground.textures = {}
	ground.yoffsets = {}

	ground.textures.spring_grass = love.graphics.newImage('spring/ground-grass.png')
	ground.yoffsets.spring_grass = 3
	ground.textures.spring_deep = love.graphics.newImage('spring/ground-deep.png')
	ground.yoffsets.spring_deep = 0

	local decorator_types = {}
	decorator_types.wall = love.filesystem.load('spring/wall.lua')()
	decorator_types.lamp = love.filesystem.load('spring/lamp.lua')()

	magics = {}
	magics.fireball = (require ('magics/fireball'))()

	map = {}
	map.ground_info = ground
	map.decorator_types = decorator_types
	map.magics = {}
	map.ground = {}
	map.decorations_back = {}
	map.decorations_front = {}
	table.insert(map.ground, make_ground(32 * 0, 110, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 0, 110 + 32, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 0, 110 + 32 * 2, 'spring_deep'))
	table.insert(map.ground, make_ground(32 * 0, 110 + 32 * 3, 'spring_deep'))

	table.insert(map.ground, make_ground(32 * 1, 200, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 2, 200, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 3, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 4, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 5, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 6, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 7, 250, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 8, 250, 'spring_deep'))

	table.insert(map.ground, make_ground(32 * 4, 100, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 5, 100, 'spring_grass'))

	table.insert(map.ground, make_ground(32 * 8, 218, 'spring_grass'))

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

	table.insert(map.ground, make_ground(32 * 10, 32 * 8, 'spring_grass'))
	table.insert(map.ground, make_ground(32 * 11, 32 * 8, 'spring_grass'))

	table.insert(map.decorations_back, make_decoration(0, 0, 'wall'))
	table.insert(map.decorations_back, make_decoration(20, 20, 'lamp'))
	table.insert(map.decorations_back, make_decoration(64, 0, 'wall'))
	table.insert(map.decorations_back, make_decoration(94, 20, 'lamp'))
	table.insert(map.decorations_back, make_decoration(128, 128, 'wall'))
	table.insert(map.decorations_back, make_decoration(128, 192, 'wall'))
end

function make_ground(x, y, tile)
	return {
		x = x,
		y = y,
		tile = tile
	}
end

function make_decoration(x, y, decorator_name, ...)
	local decorator = map.decorator_types[decorator_name]
	local instance = decorator:make_instance(x, y, ...)
	instance.decorator_name = decorator_name

	return instance
end

function Test.draw()
	love.graphics.clear()

	draw_decorations(map.decorations_back)

	char:draw()
	draw_map(map)

	draw_magics(map)

	draw_decorations(map.decorations_front)
end

function Test.update(dt)
	char:update(map, dt)

	update_decorations(map.decorations_back, dt)
	update_decorations(map.decorations_front, dt)

	update_magics(map, dt)
end

function draw_decorations(decoration_list)
	for key, value in pairs(decoration_list) do
		local decorator = map.decorator_types[value.decorator_name]

		decorator:draw(value)
	end
end

function draw_map(map)
	for key, value in pairs(map.ground) do
		love.graphics.draw(map.ground_info.textures[value.tile], map.ground_info.quad, value.x, value.y)
	end
end

function draw_magics(map)
	for key, value in pairs(map.magics) do
		value.magic:draw(map, value)
	end
end

function update_decorations(instance_list, dt)
	for key, value in pairs(instance_list) do
		local field_object = map.decorator_types[value.decorator_name]

		if field_object.enable_magic_collisions then
			for mkey, mvalue in pairs(map.magics) do
				if Physics.check_collision_rect(value.x + value.sensitive_x, value.y + value.sensitive_y, value.sensitive_width, value.sensitive_height,
					mvalue.x, mvalue.y, mvalue.width, mvalue.height) then

					field_object:handle_magic(value, mvalue, map)

				end
			end
		end

		field_object:update(value, map, dt)
	end
end

function update_magics(map, dt)
	for key, value in pairs(map.magics) do
		value.magic:update(map, value, dt)
	end
end

return Test
