return function (base)
	local builder_object = {}
	
	builder_object.init = function()
		-- Default init method
		if base ~= nil then
			base.init(self)
		end
	end

	local function builder(caller_class, ...)
		local object = {}
		setmetatable(object, { __index = builder_object })

		object:init(...)

		return object
	end

	local metatable = { __call = builder }

	if base ~= nil then
		metatable.__index = base
	end

	setmetatable(builder_object, metatable)

	return builder_object
end
