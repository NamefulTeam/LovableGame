class = require 'class'
FieldObject = require 'field_object'

Flower1 = class(FieldObject)

local texture = love.graphics.newImage("spring/flower1.png")
local quad = love.graphics.newQuad(0, 0, 8, 16, 8, 16)

function Flower1:init()
	FieldObject.init(self)
end

function Flower1:draw(instance)
	love.graphics.draw(texture, quad, instance.x, instance.y)
end

return Flower1
