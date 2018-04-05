local Camera = require "camera"
local pipes = {}
local JumpSound = love.audio.newSource("jump.wav")
JumpSound:setVolume(.3)
local DiedSound = love.audio.newSource("died.wav")
DiedSound:setVolume(.3)
local GameState = "play"

local pipeDelta = 300

-- print (love.graphics.getHeight(), 6 * love.graphics.getHeight / 8)

function factorial(n)
	if n == 0 then n = 1 else
		for i=2, n-1 do
			n=n*i
		end
	end
	return n
end

for i = 1, 100 do
	local fac = factorial(i)
	local width = 64
	local xGap = 64 * fac / (1.2 * fac)
	local gap = love.graphics.getHeight() / 3.8
	local height = love.math.random(1, 6) * love.graphics.getHeight() / 12
	
	local temp1 = {
		x = i * pipeDelta + width + xGap,
		y = 0,
		width = width,
		height = height
	}

	local temp2 = {
		x = i * pipeDelta + width + xGap,
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
		if pipe.x <= cam.x + love.graphics.getWidth() / 2
		or pipe.x >= cam.x - love.graphics.getWidth() / 2 then
			love.graphics.rectangle("fill", pipe.x, pipe.y, pipe.width, pipe.height)
		end
	end
end

-- empirical constants
local birdSpeed = 145
local bird = {
	x = 0,
	y = 0,
	vx = birdSpeed,
	vy = 0,
	width = 24,
	height = 24,
	jumpVel = -420,
	gravity = 790,
	score = 0
}

function bird:playSound(source)
	if source:isPlaying() then
		source:stop()
		source:play()
	else
		source:play()
	end
end

function bird:jump(key)
	if key == "space" then
		self.vy = self.jumpVel
		self.vx = self.vx + -1 * self.jumpVel * love.timer.getDelta()
		self:playSound(JumpSound)
	end
end

function bird:update(dt)
	-- move to the right at a linear rate
	self.x = self.x + self.vx * dt

	-- apply gravity
	if self.vy < self.gravity then
		self.vy = self.vy + self.gravity * dt
	else
		self.vy = self.gravity
	end

	-- move upward or downward at a quadratic rate
	self.y = self.y + self.vy * dt

	-- limit upward movement to the top of the window
	if self.y < 0 then
		self.y = 0
		self.vy = 0
	end

	-- detect collision with any pipe
	local hitPipe, pipe, index
	index = self.score ~= 0 and self.score or 1
	for i = index, #pipes do
		hitPipe, pipe = false, pipes[i]
		if pipe.x < self.x + self.width
		and pipe.x + pipe.width > self.x
		and pipe.y < self.y + self.height
		and pipe.y + pipe.height > self.y then
			hitPipe = true
			break
		end
	end


	-- check for collisions or going below the screen
	if self.y + self.height > love.graphics.getHeight() or hitPipe then
		-- die
		GameState = "died"
		self:playSound(DiedSound)
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
	if GameState == "play" then
		bird:update(dt)
		cam:lockX(bird.x, Camera.smooth.damped(10))
		cam:lockY(love.graphics.getHeight() / 2)
	end
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
	if GameState == "play" then
		bird:jump(key)
	end

	if key == "escape" then
		love.event.quit()
	elseif key == "r" then
		love.event.quit("restart")
	end
end