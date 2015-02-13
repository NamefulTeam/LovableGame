local Fireball = {}

local texture = love.graphics.newImage('magics/fireball.png')
local quad = love.graphics.newQuad(0, 0, 24, 24, 24, 24)

local collision_width = 16
local collision_height = 16
local draw_width = 24
local draw_height = 24

local total_cast_time = 2
local speed = 200

local rotation_time = 0.5

function finalize_cast(map, caster, magic_instance)
	-- TODO
	caster.state = 'normal'

	caster.prepared_magic = nil
	caster.can_cast = true

	magic_instance.is_preparing = false
	magic_instance.vx = magic_instance.direction * speed
end

function update(map, magic_instance, dt)
	magic_instance.total_time = magic_instance.total_time + dt

	if magic_instance.is_preparing then
		magic_instance.cast_time = magic_instance.cast_time + dt
		if magic_instance.cast_time >= total_cast_time then
			magic_instance.cast_time = total_cast_time
		end
	else
		magic_instance.x = magic_instance.x + magic_instance.vx * dt
	end
end

function draw(map, magic_instance)
	local scale = magic_instance.cast_time / total_cast_time

	local scaled_draw_width = draw_width * scale
	local scaled_draw_height = draw_height * scale

	local offsetx = (collision_width - scaled_draw_width) / 2
	local offsety = (collision_height - scaled_draw_height) / 2

	local rotation_angle = (magic_instance.total_time / rotation_time) % 1 * math.pi * 2

	love.graphics.draw(texture, quad,
		magic_instance.x + offsetx + scaled_draw_width / 2, magic_instance.y + offsety + scaled_draw_height / 2,
		rotation_angle, scale, scale, draw_width / 2, draw_height / 2)
end

function Fireball.cast(map, caster)
	local magic_instance = {}

	local offsety = (caster.height - collision_height) / 2

	if caster.flipped then
		magic_instance.x = caster.x - collision_width - 4
		magic_instance.direction = -1
	else
		magic_instance.x = caster.x + caster.width + 4
		magic_instance.direction = 1
	end

	magic_instance.y = caster.y + offsety
	magic_instance.width = collision_width
	magic_instance.height = collision_height

	magic_instance.caster = caster

	magic_instance.finalize_cast = finalize_cast
	magic_instance.update = update
	magic_instance.draw = draw

	magic_instance.cast_time = 0
	magic_instance.total_time = 0
	magic_instance.is_preparing = true

	caster.state = 'cast_front'
	caster.cast_time = total_cast_time
	caster.can_cast = false
	caster.prepared_magic = magic_instance

	table.insert(map.magics, magic_instance)
end

return Fireball
