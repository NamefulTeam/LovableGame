class = require 'class'
FieldObject = require 'field_object'

BaseTrap = class(FieldObject)
BaseTrap.expulsion_speed = 400

BaseTrap.init = FieldObject.init
BaseTrap.enable_char_collisions = true

function BaseTrap:handle_hero_collision(instance, char, map)
	if char.is_vulnerable then
		self:damage(instance, char)
	end
end

function BaseTrap:damage(instance, char)
	local center_x = instance.sensitive_x + instance.sensitive_width / 2
	local center_y = instance.sensitive_y + instance.sensitive_height / 2
	local char_center_x = char.x + char.width / 2
	local char_center_y = char.y + char.height / 2

	local angle = math.atan2(center_y - char_center_y, center_x - char_center_x)

	local ycomp = math.sin(angle) * self.expulsion_speed
	local xcomp = math.cos(angle) * self.expulsion_speed

	char.is_vulnerable = false
	char.current_lives = char.current_lives - 1
	char.vx = xcomp
	char.vy = ycomp
end

return BaseTrap
