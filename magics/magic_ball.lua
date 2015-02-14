class = require ('class')

MagicBallSpell = class()

MagicBallSpell.quad = love.graphics.newQuad(0, 0, 24, 24, 24, 24)

MagicBallSpell.collision_width = 16
MagicBallSpell.collision_height = 16
MagicBallSpell.draw_width = 24
MagicBallSpell.draw_height = 24

MagicBallSpell.total_cast_time = 1
MagicBallSpell.speed = 200

MagicBallSpell.rotation_time = 0.5

function MagicBallSpell:finalize_cast(map, caster, magic_instance)
	-- TODO
	caster.state = 'normal'

	caster.prepared_magic = nil
	caster.can_cast = true
	caster.can_move = true

	magic_instance.is_preparing = false
	magic_instance.vx = magic_instance.direction * self.speed
end

function MagicBallSpell:update(map, magic_instance, dt)
	magic_instance.total_time = magic_instance.total_time + dt

	if magic_instance.is_preparing then
		magic_instance.y = magic_instance.caster.y + self:get_offsety(magic_instance.caster)

		magic_instance.cast_time = magic_instance.cast_time + dt
		if magic_instance.cast_time >= self.total_cast_time then
			magic_instance.cast_time = self.total_cast_time
		end
	else
		magic_instance.x = magic_instance.x + magic_instance.vx * dt
	end
end

function MagicBallSpell:draw(map, magic_instance)
	local scale = magic_instance.cast_time / self.total_cast_time

	local scaled_draw_width = self.draw_width * scale
	local scaled_draw_height = self.draw_height * scale

	local draw_offsetx = (self.collision_width - scaled_draw_width) / 2
	local draw_offsety = (self.collision_height - scaled_draw_height) / 2

	local rotation_angle = (magic_instance.total_time / self.rotation_time) % 1 * math.pi * 2

	love.graphics.draw(self.texture, self.quad,
		magic_instance.x + draw_offsetx + scaled_draw_width / 2, magic_instance.y + draw_offsety + scaled_draw_height / 2,
		rotation_angle, scale, scale, self.draw_width / 2, self.draw_height / 2)
end

function MagicBallSpell:get_offsety(caster)
	local offsety = (caster.height - self.collision_height) / 2

	return offsety
end

function MagicBallSpell:cast(map, caster)
	local magic_instance = {}

	local offsety = self:get_offsety(caster)

	if caster.flipped then
		magic_instance.x = caster.x - self.collision_width - 4
		magic_instance.direction = -1
	else
		magic_instance.x = caster.x + caster.width + 4
		magic_instance.direction = 1
	end

	magic_instance.y = caster.y + offsety
	magic_instance.width = self.collision_width
	magic_instance.height = self.collision_height

	magic_instance.caster = caster
	magic_instance.magic = self

	magic_instance.cast_time = 0
	magic_instance.total_time = 0
	magic_instance.is_preparing = true

	caster.state = 'cast_front'
	caster.cast_time = self.total_cast_time
	caster.can_cast = false
	caster.can_move = false
	caster.prepared_magic = magic_instance

	table.insert(map.magics, magic_instance)
end

function MagicBallSpell:init(texture, element)
	print('MagicBallSpell:init')

	self.texture = texture
	self.element = element
end

return MagicBallSpell
