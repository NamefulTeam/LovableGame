local Canister = {}

Canister.enable_magic_collisions = true

local canister_texture = love.graphics.newImage("spring/lamp-canister.png")
local fire_textures = {
	love.graphics.newImage("spring/lamp-fire1.png"),
	love.graphics.newImage("spring/lamp-fire2.png")
}
local canister_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)
local fire_quad = love.graphics.newQuad(0, 0, 12, 10, 12, 10)

local fire_offsety = 0
local canister_offsety = 8

local frame_time = 0.3

function Canister.init(decoration)
	decoration.total_time = 0
	decoration.lit = false

	decoration.sensitive_width = 12
	decoration.sensitive_height = 10
	decoration.sensitive_x = 0
	decoration.sensitive_y = canister_offsety
end

function Canister.handle_magic(decoration, magic_instance, map)
	if magic_instance.is_preparing then return end

	if magic_instance.magic.element == 'fire' then
		decoration.lit = true
	end
end

function Canister.update(decoration, map, dt)
	if decoration.lit then
		decoration.total_time = decoration.total_time + dt
	end
end

function Canister.draw(decoration, map)
	love.graphics.draw(canister_texture, canister_quad, decoration.x, decoration.y + canister_offsety)

	if decoration.lit then
		love.graphics.draw(fire_textures[math.floor(decoration.total_time / frame_time) % #fire_textures + 1],
			fire_quad,
			decoration.x, decoration.y + fire_offsety)
	end
end

return Canister
