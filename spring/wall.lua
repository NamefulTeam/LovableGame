local Wall = {}

Wall.texture1 = love.graphics.newImage("spring/lamp-wall.png")
Wall.texture2 = love.graphics.newImage("spring/lamp-canister.png")
Wall.fire_textures = {
	love.graphics.newImage("spring/lamp-fire1.png"),
	love.graphics.newImage("spring/lamp-fire2.png")
}
Wall.quad1 = love.graphics.newQuad(0, 0, 64, 64, 64, 64)
Wall.quad2 = love.graphics.newQuad(0, 0, 12, 10, 12, 10)
Wall.fire_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)

local frame_time = 0.3

function Wall.init(decoration)
	decoration.total_time = 0
	decoration.lit = false

	decoration.sensitive_width = 12
	decoration.sensitive_height = 10
	decoration.sensitive_x = (64 - decoration.sensitive_width) / 2
	decoration.sensitive_y = (64 - decoration.sensitive_height) / 2
end

function Wall.handle_magic(decoration, magic, map)
	if magic.is_preparing then return end
	
	if magic.element == 'fire' then
		decoration.lit = true
	end
end

function Wall.update(decoration, map, dt)
	if decoration.lit then
		decoration.total_time = decoration.total_time + dt
	end
end

function Wall.draw(decoration)
	local fire_offsety = decoration.sensitive_y - 8

	love.graphics.draw(Wall.texture1, Wall.quad1, decoration.x, decoration.y)
	love.graphics.draw(Wall.texture2, Wall.quad2, decoration.x + decoration.sensitive_x, decoration.y + decoration.sensitive_y)

	if decoration.lit then
		love.graphics.draw(Wall.fire_textures[math.floor(decoration.total_time / frame_time) % #Wall.fire_textures + 1],
			Wall.fire_quad,
			decoration.x + decoration.sensitive_x, decoration.y + fire_offsety)
	end
end

return Wall
