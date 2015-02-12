local Wall = {}

Wall.texture1 = love.graphics.newImage("spring/lamp-wall.png")
Wall.texture2 = love.graphics.newImage("spring/lamp-canister.png")
Wall.quad1 = love.graphics.newQuad(0, 0, 64, 64, 64, 64)
Wall.quad2 = love.graphics.newQuad(0, 0, 12, 10, 12, 10)

function Wall.init(decorator)

end

function Wall.update(decorator, map, dt)
end

function Wall.draw(decorator)
	local offsetx = (64 - 6) / 2
	local offsety = (64 - 6) / 2

	love.graphics.draw(Wall.texture1, Wall.quad1, decorator.x, decorator.y)
	love.graphics.draw(Wall.texture2, Wall.quad2, decorator.x + offsetx, decorator.y + offsety)
end

return Wall
