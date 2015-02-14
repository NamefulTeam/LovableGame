local MagicBallSpell = require 'magics/magic_ball'
local class = require 'class'

local FireballSpell = class(MagicBallSpell)

local texture = love.graphics.newImage('magics/fireball.png')

function FireballSpell:init()
	MagicBallSpell.init(self, texture, 'fire')
end

return FireballSpell
