class = require 'class'
FieldObject = require 'field_object'

Wall = class(FieldObject)

local texture = love.graphics.newImage("spring/lamp-wall.png")
local quad = love.graphics.newQuad(0, 0, 64, 64, 64, 64)

function Wall:init()
	FieldObject.init(self)
end

function Wall:draw(instance)
	love.graphics.draw(texture, quad, instance.x, instance.y)
end

return Wall
