Hub = require 'hub.main'

frame = 0
frame_reset_count = 10
total_time = 0
last_fps = 0

function love.load()
	math.randomseed(os.time())
	
	local KeyConfig = {}
	KeyConfig.left = 'left'
	KeyConfig.right = 'right'
	KeyConfig.jump = 'z'
	KeyConfig.cast_spell = 'c'
	KeyConfig.accept = KeyConfig.jump

	screen = Hub(KeyConfig)
	screen:load()
end
function love.draw()
	screen:draw()
	love.graphics.print(tostring(last_fps))
end
function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	if dt > 1/30 then
		print('Slow frame: ' .. dt)
	end

	screen:update(dt)

	total_time = total_time + dt

	if frame + 1 >= frame_reset_count then
		frame = 0
		last_fps = frame_reset_count / total_time
		total_time = 0
	else
		frame = frame + 1
	end
	
end
