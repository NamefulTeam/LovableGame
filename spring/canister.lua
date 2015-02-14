class = require 'class'
FieldObject = require 'field_object'

Canister = class(FieldObject)

Canister.enable_magic_collisions = true

local canister_texture = love.graphics.newImage("spring/lamp-canister.png")
local fire_textures = {
	love.graphics.newImage("spring/lamp-fire1.png"),
	love.graphics.newImage("spring/lamp-fire2.png")
}
local canister_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)
local fire_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)

local fire_offsety = 0
local canister_offsety = 8

local frame_time = 0.3

function Canister:make_instance(x, y)
	local instance = FieldObject.make_instance(self, x, y)

	instance.total_time = 0
	instance.lit = false

	instance.sensitive_width = 12
	instance.sensitive_height = 10
	instance.sensitive_x = 0
	instance.sensitive_y = canister_offsety

	return instance
end

function Canister:handle_magic(instance, magic_instance, map)
	if magic_instance.is_preparing then return end

	if magic_instance.magic.element == 'fire' then
		instance.lit = true
	end
end

function Canister:update(instance, map, dt)
	if instance.lit then
		instance.total_time = instance.total_time + dt
	end
end

function Canister:draw(instance, map)
	love.graphics.draw(canister_texture, canister_quad, instance.x, instance.y + canister_offsety)

	if instance.lit then
		love.graphics.draw(fire_textures[math.floor(instance.total_time / frame_time) % #fire_textures + 1],
			fire_quad,
			instance.x, instance.y + fire_offsety)
	end
end

return Canister
