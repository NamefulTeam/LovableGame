class = require 'class'

FieldObject = class()

function FieldObject:init()
end

function FieldObject:make_instance(x, y)
	return { x = x, y = y }
end

function FieldObject:update(instance, map, dt)
end

return FieldObject