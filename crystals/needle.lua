class = require 'class'
Crystal = require 'crystals.crystal'

Needle = class(Crystal)

function Needle:init()
	Crystal.init(self, 4, 8, 45, 9, 5, love.graphics.newImage("crystals/needle.png"))
end

return Needle
