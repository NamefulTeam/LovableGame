function love.load()
	KeyConfig = {}
	KeyConfig.left = 'left'
	KeyConfig.right = 'right'

	screen = love.filesystem.load('test.lua')()
	screen.load()
end
function love.draw()
	screen.draw()
end
function love.update(dt)
	screen.update(dt)
end
