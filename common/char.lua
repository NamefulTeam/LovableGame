class = require 'class'

Character = class()

-- Constants
Character.max_vy = 3000
Character.max_vx = 1000
Character.wall_fall_g_friction = 0.95 -- Relative to char.g
Character.max_grab_fall_speed = 1000
Character.x_friction_threshold = 10
Character.x_friction = 0.99
Character.walk_acceleration = 30
Character.jump_speed = 330
Character.wall_jump_xspeed = 800
Character.wall_jump_yspeed = 400
Character.g = 1100
Character.default_invulnerability_time = 3

-- Graphics setup
Character.quad = love.graphics.newQuad(3, 2, 26, 42, 32, 48)

function Character:init()
	self.textures = {}

	-- Variables
	self.magics = { 'fireball' }
	self.crystals = 0
	self.maximum_lives = 3
	self.current_lives = 3
	self.is_vulnerable = true

	self.x = 32*4
	self.y = 170
	self.width = 24
	self.height = 42
	self.px = x
	self.py = y
	self.vx = 0
	self.vy = 0
	self.jump_key_active_last_frame = false
	self.flipped = false
	self.state = 'normal'
	self.active_magic = self.magics[1]
	self.can_cast = true
	self.can_move = true
	self.move_cooldown_state = 0

	-- Textures
	self.textures.cast_front = love.graphics.newImage('common/char-cast-front.png')
	self.textures.cast_general = love.graphics.newImage('common/char-cast-general.png')
	self.textures.dead = love.graphics.newImage('common/char-dead.png')
	self.textures.normal = love.graphics.newImage('common/char-normal.png')
	self.textures.grab_wall = love.graphics.newImage('common/char-grab-wall.png')
end

function Character:draw()
	local xscale = self.flipped and -1 or 1
	local ox = self.flipped and self.width or 0

	if not self.is_vulnerable then
		love.graphics.setColor(255, 255, 255, 128)
	end

	love.graphics.draw(self.textures[self.state], Character.quad, self.x, self.y, 0, xscale, 1, ox, 0)

	love.graphics.setColor(255, 255, 255)
end

function Character:update(map, dt)
	if not self.is_vulnerable then
		if self.invulnerability_time == nil then
			self.invulnerability_time = self.default_invulnerability_time
		elseif self.invulnerability_time < dt then
			self.invulnerability_time = nil
			self.is_vulnerable = true
		else
			self.invulnerability_time = self.invulnerability_time - dt
		end
	end

	self.px = self.x
	self.py = self.y

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	if self.vx > self.x_friction_threshold or self.vx < -self.x_friction_threshold then
		self.vx = self.vx * math.pow(1 - self.x_friction, dt)
	else
		self.vx = 0
	end
	self.vy = self.vy + self.g * dt

	if self.vy > self.max_vy then
		self.vy = self.max_vy
	elseif self.vy < -self.max_vy then
		self.vy = -self.max_vy
	end
	if self.vx > self.max_vx then
		self.vx = self.max_vx
	elseif self.vx < -self.max_vx then
		self.vx = -self.max_vx
	end

	local direction = 0
	if love.keyboard.isDown(KeyConfig.left) and self.can_move then
		direction = direction - 1
	end
	if love.keyboard.isDown(KeyConfig.right) and self.can_move then
		direction = direction + 1
	end

	Physics.check_collisions_with_ground(map, self)

	local can_jump = self:can_jump_up(map, self)
	local can_wall_jump_left = not can_jump and self:can_wall_jump_left(map, self)
	local can_wall_jump_right = not can_jump and self:can_wall_jump_right(map, self)

	local jump_key_active = love.keyboard.isDown(KeyConfig.jump)

	if direction < 0 then
		if not can_wall_jump_right then
			self.flipped = true
		end
		self.vx = self.vx - self.walk_acceleration
	elseif direction > 0 then
		if not can_wall_jump_left then
			self.flipped = false
		end
		self.vx = self.vx + self.walk_acceleration
	end

	if self.can_cast and love.keyboard.isDown(KeyConfig.cast_spell) then
		local magic = magics[self.active_magic]
		magic:cast(map, self)
	end

	if self.state == 'normal' then
		if not char.jump_key_active_last_frame then
			if can_wall_jump_left then
				self.state = 'grab_wall'
				self.flipped = true
			elseif can_wall_jump_right then
				self.state = 'grab_wall'
				self.flipped = false
			elseif can_jump and jump_key_active then
				self.vy = -Character.jump_speed
			end
		end
	elseif self.state == 'grab_wall' then
		if self.vy > 0 then
			self.vy = self.vy - self.g * self.wall_fall_g_friction * dt -- Counter G
		end
		if self.vy > self.max_grab_fall_speed then
			self.vy = self.max_grab_fall_speed
		end

		if jump_key_active then
			if self.flipped then
				-- Jump to the left
				self.vx = -self.wall_jump_xspeed
				self.vy = -self.wall_jump_yspeed
				self.state = 'normal'
			else
				-- Jump to the right
				self.vx = self.wall_jump_xspeed
				self.vy = -self.wall_jump_yspeed
				self.state = 'normal'
			end
		elseif not can_wall_jump_left and not can_wall_jump_right then
			self.state = 'normal'
		end
	elseif self.state == 'cast_general' or self.state == 'cast_front' then
		if self.cast_time <= dt then
			self.cast_time = 0
			self.prepared_magic.magic:finalize_cast(map, self, self.prepared_magic)
		else
			self.cast_time = self.cast_time - dt
		end
	end

	self.jump_key_active_last_frame = jump_key_active
end

function Character:can_jump_up(map)
	return Physics.has_collisions_at_position(map, self.x, self.y + 1, self)
end

-- For whenever we add reverse gravity
function Character:can_jump_down(map)
	return Physics.has_collisions_at_position(map, self.x, self.y - 1, self)
end

function Character:can_wall_jump_left(map)
	return Physics.has_collisions_at_position(map, self.x + 1, self.y, self)
end

function Character:can_wall_jump_right()
	return Physics.has_collisions_at_position(map, self.x - 1, self.y, self)
end

function Character:get_center()
	return self.x + self.width / 2, self.y + self.height / 2
end

return Character
