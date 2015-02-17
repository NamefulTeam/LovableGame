camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.followSpeed = 0.1-- at 0 the camera will be static, at 1 the camera will be locked on the target
camera.parallax = 0.9

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

function camera:follow(x, y)
  local vx = ((x - love.window.getWidth()/2) - self.x) * camera.followSpeed
  local vy = ((y - love.window.getHeight()/2) - self.y) * camera.followSpeed

  self.x = self.x + vx
  self.y = self.y + vy

  if(math.abs(self.x - x) < 5) then
    self.x = x
  end

  if(math.abs(self.y - y) < 5) then
    self.y = y
  end

  self.x = self.x / camera.parallax
  self.y = self.y / camera.parallax
end

return camera
