Hud = class()

Hud.background = love.graphics.newImage('hud/hud_background.png')
Hud.background_quad = love.graphics.newQuad(0, 0, 256, 128, 256, 128)
Hud.font = love.graphics.newFont('Righteous-Regular.ttf', 26)

Hud.crystals_number_top = 4
Hud.crystals_diff_top = 37
Hud.number_right = 148

Hud.update_freeze_time = 2
Hud.update_crystal_count_speed = 20

function Hud:init(char, x, y)
	self.char = char
	self.current_crystals = char.crystals
	self.target_crystals = char.crystals
	self.countdown = 0
	self.x = x - 256
	self.y = y
end

function Hud:draw()
	love.graphics.draw(self.background, self.background_quad, self.x, self.y)

	local current_crystals_number = math.floor(self.current_crystals)

	local crystals_number_text = tostring(current_crystals_number)
	local crystals_diff_text = tostring(self.char.crystals - current_crystals_number)
	if crystals_diff_text[0] ~= '-' then
		crystals_diff_text = '+' .. crystals_diff_text
	end
	local crystals_number_width = self.font:getWidth(crystals_number_text)
	local crystals_diff_width = self.font:getWidth(crystals_diff_text)

	love.graphics.setFont(self.font)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(crystals_number_text,
		self.x + self.number_right - crystals_number_width, self.y + self.crystals_number_top)
	love.graphics.print(crystals_diff_text,
		self.x + self.number_right - crystals_diff_width, self.y + self.crystals_diff_top)

	love.graphics.setColor(117, 197, 255)
	love.graphics.print(crystals_number_text,
		self.x + self.number_right - crystals_number_width - 2, self.y + self.crystals_number_top - 2)
	love.graphics.print(crystals_diff_text,
		self.x + self.number_right - crystals_diff_width - 2, self.y + self.crystals_diff_top - 2)
	love.graphics.setColor(255, 255, 255)
end

function Hud:update(dt)
	local correct_crystals = self.char.crystals

	if correct_crystals ~= self.target_crystals then
		self.countdown = self.update_freeze_time
		self.target_crystals = correct_crystals
	elseif self.countdown >= dt then
		self.countdown = self.countdown - dt
	else
		self.countdown = 0

		local adjustment = Hud.update_crystal_count_speed * dt
		if math.abs(self.current_crystals - self.target_crystals) <= adjustment then
			self.current_crystals = self.target_crystals
		elseif self.current_crystals < self.target_crystals then
			self.current_crystals = self.current_crystals + adjustment
		else
			self.current_crystals = self.current_crystals - adjustment
		end
	end
end

return Hud
