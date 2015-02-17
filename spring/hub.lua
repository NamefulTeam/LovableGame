class = require('class')

SpringHubIcon = class()

SpringHubIcon.y_oscillation = 4
SpringHubIcon.background_min_magnification = 1.4
SpringHubIcon.background_magnification = 0.1
SpringHubIcon.oscillation_period = 3

function SpringHubIcon:init(center_x, center_y)
	self.center_x = center_x
	self.center_y = center_y
	self.total_time = 0
end

function SpringHubIcon:load()
	self.background_texture = love.graphics.newImage('spring/hub-background.png')
	self.ground_texture = love.graphics.newImage('spring/hub-ground.png')
	self.cloud_texture = love.graphics.newImage('spring/hub-cloud.png')

	self.quad = love.graphics.newQuad(0, 0, 128, 128, 128, 128)
end

function SpringHubIcon:unload()

end

function SpringHubIcon:update(dt)
	self.total_time = self.total_time + dt
end

function SpringHubIcon:draw()
	local period_point = math.sin(self.total_time * 2 * math.pi / self.oscillation_period)

	local current_background_magnification = self.background_min_magnification +
		period_point * self.background_magnification
	local background_half_size = 64 * current_background_magnification

	love.graphics.draw(self.background_texture, self.quad, self.center_x - background_half_size, self.center_y - background_half_size, 0, current_background_magnification, current_background_magnification)

	love.graphics.draw(self.cloud_texture, self.quad, self.center_x - 64, self.center_y - 64)

	local actual_y = math.floor(self.center_y - 64 + period_point * self.y_oscillation)

	love.graphics.draw(self.ground_texture, self.quad, self.center_x - 64, actual_y)
end

function SpringHubIcon:enter_map(hub)
	return 'spring/main.map'
end

return SpringHubIcon
