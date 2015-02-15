class = require 'class'
BaseTrap = require 'traps.base_trap'

Spikes = class(BaseTrap)

Spikes.texture = love.graphics.newImage('traps/spikes.png')
Spikes.quad = love.graphics.newQuad(0, 0, 64, 64, 64, 64)

function Spikes:init()
	BaseTrap.init(self)
end

function Spikes:make_instance(x, y)
	local instance = BaseTrap.make_instance(self, x, y)

	instance.sensitive_width = 54
	instance.sensitive_height = 54
	instance.sensitive_x = 5
	instance.sensitive_y = 5

	return instance
end

function Spikes:draw(instance, map)
	love.graphics.draw(self.texture, self.quad, instance.x, instance.y)
end

return Spikes
