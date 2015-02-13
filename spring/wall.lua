local Wall = {}

local texture = love.graphics.newImage("spring/lamp-wall.png")
local quad = love.graphics.newQuad(0, 0, 64, 64, 64, 64)

function Wall.draw(decoration)
	love.graphics.draw(texture, quad, decoration.x, decoration.y)
end

return Wall
