maps = require 'hub.maps'
class = require 'class'
map = require 'map'

Hub = class()

function Hub:init(key_config)
	self.key_config = key_config
end

local musics = { 'hub/saywhatyouwill.ogg' }

local font_size = 18
local line_spacing = font_size + 2

function Hub:load()
	self.music = love.audio.newSource(musics[1])
	self.music:setLooping(true)
	love.audio.play(self.music)

	font = love.graphics.newFont('Righteous-Regular.ttf', font_size)

	self.selected_map = 'spring'
end

function Hub:unload()
	self.music:stop()
end

function Hub:update(dt)
	local pressing_accept = love.keyboard.isDown(self.key_config.accept)

	if self.last_frame_pressing_accept == false and pressing_accept then
		self:unload()

		self:enter_map()
	end

	self.last_frame_pressing_accept = pressing_accept
end

function Hub:enter_map()
	local current_map = maps[self.selected_map]

	screen = map(self.key_config, current_map.path)
	screen:load()
end

function Hub:draw()
	love.graphics.setFont(font)

	local current_map = maps[self.selected_map]

	local current_y = 30

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(current_map.name, 10, current_y)
	current_y = current_y + line_spacing

	love.graphics.setColor(25, 255, 255)
	love.graphics.print(current_map.description, 10, current_y)
	local _, description_line_breaks = string.gsub(current_map.description, "\n", "")
	current_y = current_y + line_spacing * (description_line_breaks + 2)

	love.graphics.setColor(255, 100, 0)
	love.graphics.print("Missions:", 10, current_y)
	current_y = current_y + line_spacing

	love.graphics.setColor(255, 255, 255)
	for key, mission in pairs(current_map.missions) do
		love.graphics.print(mission.name, 30, current_y)
		current_y = current_y + line_spacing

		love.graphics.print(mission.description, 50, current_y)
		_, description_line_breaks = string.gsub(mission.description, "\n", "")
		current_y = current_y + line_spacing * (description_line_breaks + 2)
	end
end

return Hub
