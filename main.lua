frame = 0
frame_reset_count = 10
total_time = 0
last_fps = 0

function love.load()
	KeyConfig = {}
	KeyConfig.left = 'left'
	KeyConfig.right = 'right'
	KeyConfig.jump = 'z'
	KeyConfig.cast_spell = 'c'

	screen = love.filesystem.load('map.lua')()
	love.filesystem.load('camera.lua')()
	screen.load()
end
function love.draw()
	--camera:set()
	screen.draw()
	--camera:unset()
	love.graphics.print(tostring(last_fps))
end
function love.update(dt)
	screen.update(dt)

	total_time = total_time + dt

	if frame + 1 >= frame_reset_count then
		frame = 0
		last_fps = frame_reset_count / total_time
		total_time = 0
	else
		frame = frame + 1
	end
	
end
