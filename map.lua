Test = {}
LinkedList = require 'linked_list'
Character = require 'common.char'
Physics = require 'physics'
Wall = require 'spring.wall'
Flower1 = require 'spring.flower1'
Lamp = require 'spring.lamp'
Dust = require 'crystals.dust'
Needle = require 'crystals.needle'
Fireball = require 'magics.fireball'
Spikes = require 'traps.spikes'
background = love.graphics.newImage("background.png")
mainmap = love.filesystem.read("main.map")
CharHud = require 'hud.main'

function Test.load()
	love.graphics.setBackgroundColor(255, 255, 255)

	char = Character()

	magics = {}
	magics.fireball = Fireball()

	parse_mapfile(mainmap)

	local music = love.audio.newSource(map.musics[1])
	music:setLooping(true)
	love.audio.play(music)

	hud_elements = { CharHud(magics, char, 790, 10) }
end

function make_ground(x, y, tile)
	assert(tile ~= nil)

	return {
		x = x,
		y = y,
		tile = tile
	}
end

function make_decoration(x, y, decorator_name, ...)
	local decorator = map.field_object_types[decorator_name]

	assert(decorator ~= nil)

	local instance = decorator:make_instance(x, y, ...)
	instance.decorator_name = decorator_name

	return instance
end

function Test.draw()
	love.graphics.clear()

	--back layer
	camera:set()
	camera.x = camera.x*camera.parallax
	camera.y = camera.y*camera.parallax
	love.graphics.draw(background,math.floor(camera.x/1600)*1600,-400)
	love.graphics.draw(background,(math.floor(camera.x/1600)+1)*1600,-400)
	camera:unset()
	
	--front layer
	camera:set()
	draw_decorations(map.decorations_back)
	draw_magics(map)
	char:draw()
	draw_map(map)
	draw_decorations(map.decorations_front)
	camera:unset()

	for key, value in pairs(hud_elements) do
		value:draw()
	end
end

function Test.update(dt)
	char:update(map, dt)

	camera:follow(char.x, char.y)

	update_decorations(map.decorations_back, dt)
	update_decorations(map.decorations_front, dt)

	update_magics(map, dt)

	for key, value in pairs(hud_elements) do
		value:update(dt)
	end
end

function draw_decorations(instance_list)
	local instance = instance_list.first
	while instance ~= nil do
		local decorator = map.field_object_types[instance.decorator_name]

		decorator:draw(instance)

		instance = instance.next
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
	local instance = instance_list.first
	while instance ~= nil do
		local field_object = map.field_object_types[instance.decorator_name]

		if field_object.enable_magic_collisions then
			local collision_x = instance.x + instance.sensitive_x
			local collision_y = instance.y + instance.sensitive_y

			for mkey, mvalue in pairs(map.magics) do
				if Physics.check_collision_rect(collision_x, collision_y, instance.sensitive_width, instance.sensitive_height,
					mvalue.x, mvalue.y, mvalue.width, mvalue.height) then

					field_object:handle_magic(instance, mvalue, map)

				end
			end
		end

		if field_object.enable_char_collisions then
			local collision_x = instance.x + instance.sensitive_x
			local collision_y = instance.y + instance.sensitive_y
			
			for mkey, mvalue in pairs(map.chars) do
				if Physics.check_collision_rect(collision_x, collision_y, instance.sensitive_width, instance.sensitive_height,
					mvalue.x, mvalue.y, mvalue.width, mvalue.height) then

					field_object:handle_hero_collision(instance, mvalue, map)

				end
			end
		end

		field_object:update(instance, map, dt)

		instance = instance.next
	end
end

function update_magics(map, dt)
	for key, value in pairs(map.magics) do
		value.magic:update(map, value, dt)
	end
end

--https://love2d.org/wiki/String_exploding
function string.explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end

function parse_mapfile(mapfile)
	local maplist = string.explode(mapfile, "\n")

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

	local field_object_types = {}
	field_object_types.wall = Wall()
	field_object_types.lamp = Lamp()
	field_object_types.flower1 = Flower1()
	field_object_types.dust = Dust()
	field_object_types.needle = Needle()
	field_object_types.spikes = Spikes()

	map = {}
	map.chars = { char }
	map.ground_info = ground
	map.field_object_types = field_object_types
	map.magics = {}
	map.ground = {}
	map.decorations_back = LinkedList()
	map.decorations_front = LinkedList()
	map.musics = {}

	local index = 1
	while maplist[index] do
		elementlist = string.explode(maplist[index], ",")

		if elementlist[1] == "--" then
			-- Ignore
		elseif elementlist[1] == "music" then
			local music_path = elementlist[2]

			table.insert(map.musics, music_path)
		elseif elementlist[1] == "tile" then
			local tile_type = elementlist[2]
			local x = tonumber(elementlist[3]) * 32
			local y = tonumber(elementlist[4]) * 32

			table.insert(map.ground, make_ground(x, y, tile_type))
		elseif elementlist[1] == "tile-range-x" then
			local tile_type = elementlist[2]
			local start_x = tonumber(elementlist[3]) * 32
			local end_x = tonumber(elementlist[4]) * 32
			local interval_x = tonumber(elementlist[5]) * 32
			local y = tonumber(elementlist[6]) * 32

			for x = start_x, end_x, interval_x do
				table.insert(map.ground, make_ground(x, y, tile_type))
			end
		elseif elementlist[1] == "tile-range-y" then
			local tile_type = elementlist[2]
			local x = tonumber(elementlist[3]) * 32
			local start_y = tonumber(elementlist[4]) * 32
			local end_y = tonumber(elementlist[5]) * 32
			local interval_y = tonumber(elementlist[6]) * 32

			for y = start_y, end_y, interval_y do
				table.insert(map.ground, make_ground(x, y, tile_type))
			end
		elseif elementlist[1] == "field" then
			local pos = elementlist[2]
			local obj_type = elementlist[3]

			local x = tonumber(elementlist[4]) * 32
			local y = tonumber(elementlist[5]) * 32
			map['decorations_' .. pos]:insert_at_end(make_decoration(x, y, obj_type))
		elseif elementlist[1] == "field-range-x" then
			local pos = elementlist[2]
			local obj_type = elementlist[3]

			local start_x = tonumber(elementlist[4]) * 32
			local end_x = tonumber(elementlist[5]) * 32
			local interval_x = tonumber(elementlist[6]) * 32
			local y = tonumber(elementlist[7]) * 32
			
			for x = start_x, end_x, interval_x do
				map['decorations_' .. pos]:insert_at_end(make_decoration(x, y, obj_type))
			end
		elseif elementlist[1] == "field-range-y" then
			local pos = elementlist[2]
			local obj_type = elementlist[3]

			local x = tonumber(elementlist[4]) * 32
			local start_y = tonumber(elementlist[5]) * 32
			local end_y = tonumber(elementlist[6]) * 32
			local interval_y = tonumber(elementlist[7]) * 32
			
			for y = start_y, end_y, interval_y do
				map['decorations_' .. pos]:insert_at_end(make_decoration(x, y, obj_type))
			end
		elseif elementlist[1] == "field-range-arc" then
			local pos = elementlist[2]
			local obj_type = elementlist[3]

			local center_x = tonumber(elementlist[4]) * 32
			local center_y = tonumber(elementlist[5]) * 32
			local radius = tonumber(elementlist[6]) * 32
			local count = tonumber(elementlist[7])
			
			for i = 1, count do
				local angle = math.pi * 2 * i / count
				local relative_x = math.cos(angle) * radius
				local relative_y = math.sin(angle) * radius

				local x = center_x + relative_x
				local y = center_y + relative_y

				map['decorations_' .. pos]:insert_at_end(make_decoration(x, y, obj_type))
			end
		end

		index = index + 1
	end
end

return Test
