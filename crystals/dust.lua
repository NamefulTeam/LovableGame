class = require 'class'
Crystal = require 'crystals.crystal'

Dust = class(Crystal)

function Dust:init()
	Crystal.init(self, 4, 4, 40, 7, 2, love.graphics.newImage("crystals/dust.png"))
end

return Dust
