local Camera = require "camera"
local pipes = {}

local pipeDelta = 300

-- print (love.graphics.getHeight(), 6 * love.graphics.getHeight / 8)

for i = 1, 100 do
	local width = 64
	local gap = love.graphics.getHeight() / 4
	local height = love.math.random(1, 6) * love.graphics.getHeight() / 8
	
	local temp1 = {
		x = i * pipeDelta + width,
		y = 0,
		width = width,
		height = height
	}

	local temp2 = {
		x = i * pipeDelta + width,
		y = height + gap,
		width = width,
		height = love.graphics.getHeight() - height + gap 
	}

	table.insert(pipes, temp1)
	table.insert(pipes, temp2)
end

function drawPipes()
	love.graphics.setColor(0,255,0)

	for i = 1, #pipes do
		local pipe = pipes[i]
		love.graphics.rectangle("fill", pipe.x, pipe.y, pipe.width, pipe.height)
	end
end

local bird = {
	x = 0,
	y = 0,
	vx = 100,
	vy = 0,
	width = 32,
	height = 32,
	jumpVel = -335,
	gravity = 600,
	score = 0
}

function bird:jump(key)
	if key == "space" then
		self.vy = self.jumpVel
	end
end

function bird:update(dt)
	self.x = self.x + self.vx * dt

	if self.vy < self.gravity then
		self.vy = self.vy + self.gravity * dt
	else
		self.vy = self.gravity
	end

	self.y = self.y + self.vy * dt

	if self.y < 0 or self.y + self.height > love.graphics.getHeight() then
		love.event.quit("restart")
	end

	self:updateScore()
end

function bird:updateScore()
	for i = 1, #pipes do
		if self.x > pipes[i].x + pipes[i].width / 2 then
			self.score = math.floor(i / 2)
		else
			break
		end
	end
end

function bird:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

cam = Camera(bird.x, bird.y)

function love.update(dt)
	bird:update(dt)
	cam:lookAt(bird.x, love.graphics.getHeight()/2)
end

function love.draw()
	cam:attach()
	bird:draw()
	drawPipes()
	cam:detach()

	love.graphics.setColor(100,100,100)
	love.graphics.rectangle("fill", 0, 0, 200, 75)
	love.graphics.setColor(255,255,255)
	love.graphics.print("Score: " .. tostring(bird.score), 20, 20, 0, 2, 2)
end

function love.keypressed(key)
	bird:jump(key)

	if key == "escape" then
		love.event.quit()
	end
end