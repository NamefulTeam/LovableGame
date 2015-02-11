function love.load()
	screen = love.filesystem.load('test.lua')()
	screen.load()
end
function love.draw()
	screen.draw()
end
function love.update(dt)
	screen.update(dt)
end
