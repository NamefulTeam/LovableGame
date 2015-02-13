function love.load()
	KeyConfig = {}
	KeyConfig.left = 'left'
	KeyConfig.right = 'right'
	KeyConfig.jump = 'z'
	KeyConfig.cast_spell = 'c'

	screen = love.filesystem.load('test.lua')()
	screen.load()
end
function love.draw()
	screen.draw()
end
function love.update(dt)
	screen.update(dt)
end
