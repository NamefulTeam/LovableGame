class = require 'class'
FieldObject = require 'field_object'

Lamp = class(FieldObject)

Lamp.enable_magic_collisions = true

local Lamp_texture = love.graphics.newImage("spring/lamp-base.png")
local fire_textures = {
	love.graphics.newImage("spring/lamp-fire1.png"),
	love.graphics.newImage("spring/lamp-fire2.png")
}
local Lamp_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)
local fire_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)

local fire_offsety = 0
local Lamp_offsety = 8

local frame_time = 0.3

function Lamp:init()
	FieldObject.init(self)
end

function Lamp:make_instance(x, y)
	local instance = FieldObject.make_instance(self, x, y)

	instance.total_time = 0
	instance.lit = false

	instance.sensitive_width = 12
	instance.sensitive_height = 10
	instance.sensitive_x = 0
	instance.sensitive_y = Lamp_offsety

	return instance
end

function Lamp:handle_magic(instance, magic_instance, map)
	if magic_instance.is_preparing then return end

	if magic_instance.magic.element == 'fire' then
		instance.lit = true
	end
end

function Lamp:update(instance, map, dt)
	if instance.lit then
		instance.total_time = instance.total_time + dt
	end
end

function Lamp:draw(instance, map)
	love.graphics.draw(Lamp_texture, Lamp_quad, instance.x, instance.y + Lamp_offsety)

	if instance.lit then
		love.graphics.draw(fire_textures[math.floor(instance.total_time / frame_time) % #fire_textures + 1],
			fire_quad,
			instance.x, instance.y + fire_offsety)
	end
end

return Lamp
