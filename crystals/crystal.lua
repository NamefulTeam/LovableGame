class = require 'class'
FieldObject = require 'field_object'

Crystal = class(FieldObject)

function Crystal:init(width, height, magnet_distance, absorption_distance, value, texture)
	self.quad = love.graphics.newQuad(0, 0, width, height, width, height)
	self.width = width
	self.height = height
	self.magnet_squared_distance = magnet_distance * magnet_distance
	self.absorption_squared_distance = absorption_distance * absorption_distance
	self.value = value
	self.texture = texture
	self.max_rotation_speed = 1
	self.rotation_acceleration = 0.1
	self.friction = 10
	self.accel = 2500
end

function Crystal:make_instance(x, y)
	local instance = FieldObject.make_instance(self, x, y)

	instance.is_awake = false
	instance.angle = 0
	instance.rotation_speed = 0
	instance.vx = 0
	instance.vy = 0

	return instance
end

function Crystal:copy(instance, offset_x, offset_y)
	return self:make_instance(instance.x + offset_x, instance.y + offset_y)
end

function Crystal:update(instance, map, dt)
	assert(instance ~= nil)
	assert(map ~= nil)

	local instance_center_x = instance.x + self.width / 2
	local instance_center_y = instance.y + self.height / 2

	local min_distance_char = nil
	local min_distance_squared_value = math.huge
	local min_distance_center_x = nil
	local min_distance_center_y = nil

	for index, char in pairs(map.chars) do
		local char_center_x, char_center_y = char:get_center()

		local diffx = char_center_x - instance_center_x
		local diffy = char_center_y - instance_center_y

		local squared_distance = diffx * diffx + diffy * diffy

		if squared_distance < self.magnet_squared_distance and
			squared_distance < min_distance_squared_value then

			min_distance_char = index
			min_distance_squared_value = squared_distance
			min_distance_center_x = char_center_x
			min_distance_center_y = char_center_y
		end
	end

	if instance.is_awake then
		local char_instance = map.chars[instance.magnet_char]

		if min_distance_squared_value < self.absorption_squared_distance then
			char_instance = map.chars[min_distance_char]
			char_instance.crystals = char_instance.crystals + self.value

			instance.list:delete(instance)
		elseif min_distance_squared_value < self.magnet_squared_distance then
			instance.magnet_char = min_distance_char
			char_instance = map.chars[instance.magnet_char]
		end

		local char_center_x, char_center_y = char_instance:get_center()
		local diffx = char_center_x - instance_center_x
		local diffy = char_center_y - instance_center_y
		local squared_distance = diffx * diffx + diffy * diffy

		local angle = math.atan2(diffy, diffx)

		instance.vx = instance.vx*(1-self.friction*dt) + math.cos(angle) * self.accel * dt
		instance.vy = instance.vy*(1-self.friction*dt) + math.sin(angle) * self.accel * dt

		instance.angle = instance.angle + instance.rotation_speed
		if instance.rotation_speed + self.rotation_acceleration > self.max_rotation_speed then
			instance.rotation_speed = self.max_rotation_speed
		else
			instance.rotation_speed = instance.rotation_speed + self.rotation_acceleration * dt
		end

		instance.x = instance.x + instance.vx * dt
		instance.y = instance.y + instance.vy * dt

	elseif min_distance_char ~= nil then
		instance.is_awake = true
		instance.magnet_char = min_distance_char
	end
end

function Crystal:draw(instance)
	love.graphics.draw(self.texture, self.quad, instance.x, instance.y, instance.angle, 1, 1, self.width / 2, self.height / 2)
end

return Crystal
