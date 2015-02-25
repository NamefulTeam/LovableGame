class = require 'class'

LinkedList = class()

function LinkedList:init()
end

function LinkedList:insert_at_beginning(value)
	assert(value ~= nil)
	assert(value.list == nil)

	value.list = self

	value.next = self.first
	if self.first ~= nil then
		self.first.previous = value
	end

	self.first = value
	if self.last == nil then
		self.last = value
	end
end

function LinkedList:insert_at_end(value)
	assert(value ~= nil)
	assert(value.list == nil)

	value.list = self

	value.previous = self.last
	if self.last ~= nil then
		self.last.next = value
	end

	self.last = value
	if self.first == nil then
		self.first = value
	end
end

function LinkedList:delete(value)
	if value.previous ~= nil then
		value.previous.next = value.next
	end
	if value.next ~= nil then
		value.next.previous = value.previous
	end
	if self.first == value then
		self.first = value.next
	end
	if self.last == value then
		self.last = value.previous
	end
end

function LinkedList:iterate()
	local current_item = self.first
	local f = function(item)
		local prev = current_item
		if current_item ~= nil then
			current_item = current_item.next
		end
		return prev
	end
	return f
end

return LinkedList
