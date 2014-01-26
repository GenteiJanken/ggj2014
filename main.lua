--[[

	From Where I'm Standing...
	
	Josh Douglass-Molloy
	Jam: Global Game Jam 2014
	Theme: "We don't see things as they are, we see them as we are."

	Line to include: "My views are the same as yours!"
	
]]--


COLOURS = {
	DEFAULT = {255, 255, 255},
	PLAYER = {100, 154, 91}, --moss green
	ENTITY = {50, 80, 30},
	TEXTBOX = {50, 50, 50, 125}
}

WORLD_SIZE = {200, 200}
MAX_ENTITIES = 6
---[[
TEST_ENTITY_SPAWNS = {
	{35, 35},
	{-35, 35},
	{35, -35},
	{-35, -35},
	{50, 50},
	{-50, -50},
	
	
}
--]]--
ENTITY_SPAWNS = {
	{35, 35},

	{-35, 35},
	{35, -35},
	{-35, -35},
	{50, 50},
	{-50, -50},
	{50, 0},
	{0, 50},
	{-50, 0},
	{0, -50},
	{-50, 50},
	{50, -50}
}

PLAYER_IDENTITIES = {
	
--	{0, 0},
	{25, 0},
	{0, 25},
	{25, 25},
	{-25, 0},
	{0, -25},
	{-25, -25},
	{-25, 25},
	{25, -25}

}



GUESS_TOLERANCE = 15


player = {}


function player:init()
	self.pos = {0, 0}
	self.size = 10
	self.camera = 20
	self.identity = PLAYER_IDENTITIES[math.random(#PLAYER_IDENTITIES)]
	self.speed = 70
	self.lives = 3
end

--player always drawn at centre, entities drawn relative
function player:draw()
	sw, sh = love.graphics.getMode()
	love.graphics.setColor(unpack(COLOURS.PLAYER))	
	love.graphics.rectangle("fill", (0.5- self.size / WORLD_SIZE[1]) * sw, (0.5- self.size /WORLD_SIZE[1]) *sh, 2*self.size/WORLD_SIZE[1] *sw, 2*self.size/WORLD_SIZE[1] * sh)
end

function player:update(dt)
	
	if love.keyboard.isDown("up") then
		self.pos[2]	= self.pos[2] + self.speed * dt
	end
	
	if love.keyboard.isDown("left") then
		self.pos[1]	= self.pos[1] - self.speed * dt
	end
	
	if love.keyboard.isDown("down") then
		self.pos[2]	= self.pos[2] - self.speed * dt
	end

	if love.keyboard.isDown("right") then
		self.pos[1]	= self.pos[1] + self.speed * dt
	end
	
	
	for i = 1, 2 do
		if math.abs(self.pos[i]) > WORLD_SIZE[i] / 2 then
			self.pos[i] = self.pos[i] / math.abs(self.pos[i]) * WORLD_SIZE[i] / 2 
		end
	end

end

function player:worldtoscreen(pos)
	--get position relative to player then transform to screen coordinates
	relative = {pos[1] - self.pos[1], pos[2] - self.pos[2]}
	sw, sh = love.graphics.getMode()
	if math.abs(relative[1]) <= self.camera + self.size and math.abs(relative[2]) <= self.camera + self.size then
		return {(relative[1] + self.camera) / (self.camera * 2.0) * sw, 
				(1.0 - (relative[2] + self.camera) / (self.camera * 2.0)) * sh }
	else
		return false
	end
	
end


world = {}

function world:init()
	self.entities = {}
	self.collision = 0	
--[[	for i=1, MAX_ENTITIES do
		table.insert(self.entities, Entity:new(TEST_ENTITY_SPAWNS[i]))
	end
]]--
	ents = 0
	vals = {-50, -35, 0, 35, 50}
	
	while(ents < MAX_ENTITIES) do
		unique = true	
	
		trial = {vals[math.random(#vals)], vals[math.random(#vals)]}

		if distance(trial, player.pos) == 0 then
			unique = false	
		end

		for _, v in ipairs(self.entities) do
			if distance(trial, v.origin) == 0 then
				unique = false
			end
		end

		if unique then
			table.insert(self.entities, Entity:new(trial))
			ents = ents + 1
		end
	end 
end

function world:update(dt)
	self.collision = 0
	for i, e in ipairs(self.entities) do
		e:update(dt)
		if distance(e.pos, player.pos) < 5 then
			self.collision = i 
			
		end
	end
end

function world:draw()
	if self.collision == 0 then 
		r, b = self:getBackground(player.pos)
	else 
		r, b = self:getBackground(self.entities[self.collision].origin)
	end	
	love.graphics.setBackgroundColor(r, 0, b)
	
	for _, e in ipairs(self.entities) do
		e:draw()	
	end
	
end

function world:getBackground(pos)
	hue = {255*(pos[1] + WORLD_SIZE[1]/2)/WORLD_SIZE[1], 0, 255*(WORLD_SIZE[1]/2 - pos[1])/WORLD_SIZE[1] }
	sat = 0.5 + 0.3 * (-2*player.pos[2] / WORLD_SIZE[2])
	return hue[1] * sat, hue[3] * sat
end

Entity = {}

function Entity:new(spawn)

	local o = {
		origin = spawn,
		size = 10,
		active = true,
		jitter = 4
	}
	--o.pos = spawn
	
	o.pos = {spawn[1] + player.identity[1], spawn[2] + player.identity[2]}

	setmetatable(o, self)
	self.__index = self
	return o
end

function Entity:update(dt)

	if distance(self.pos, player.pos) < 10 then
		self:deactivate()
		
	end
end

function Entity:deactivate()
	self.active = false
	self.jitter = 0
end

function Entity:draw()
	drawpos = player:worldtoscreen(self.pos)
	love.graphics.setColor(unpack(COLOURS.ENTITY))
	
	if drawpos then
	
	love.graphics.rectangle("fill", drawpos[1] - self.size/WORLD_SIZE[1] * sw + math.random()*self.jitter, drawpos[2] - self.size/WORLD_SIZE[2] * sh + math.random() * self.jitter, 2*self.size/WORLD_SIZE[1] *sw, 2*self.size/WORLD_SIZE[1] * sh)
	end
end

function love.load()
	player:init()
	world:init()
	love.graphics.setBackgroundColor(255, 255,255)
	gameover = false
	text = ""
end

function love.update(dt)

	world:update(dt)
	player:update(dt)

end

function love.draw()
	world:draw()
	player:draw()

end

function love.keyreleased(key, unicode)
	if key == 'lshift' or key == 'rshift' then
		player.pos[1] = 0
		player.pos[2] = 0
	elseif key == ' ' or key == 'g' then --a guess!
		gameover = false
		text = ""
		sw, sh = love.graphics.getMode()
		love.graphics.setBackgroundColor(0, 0, 0)
		love.graphics.setColor(255, 255, 255)
	
		--if distance(player.pos, player.identity) <= GUESS_TOLERANCE then --Near enough
		
		if ((player.pos[1] == 0 and player.identity[1] == 0) or ( player.pos[1] / math.abs(player.pos[1]) == player.identity[1] / math.abs(player.identity[1])))
			and ((player.pos[2] == 0 and player.identity[2] == 0) or player.pos[2] / math.abs(player.pos[2]) == player.identity[2] / math.abs(player.identity[2])) then  
			print("You win! Please play again")
		else --Failure!
			print("You lose! Please play again.")
		end
		print("Guess: " .. player.pos[1] .. ", " .. player.pos[2])
		print("Truth: " .. player.identity[1] .. ", " .. player.identity[2])
		love.event.quit()				
	end
end


--Euclidean distance
function distance(p1, p2)
	return math.sqrt(math.pow(p1[1] - p2[1], 2.0) + math.pow(p1[2] - p2[2], 2.0))
end

function clamp(x, min, max)
	if x > max then
		return max
	elseif x < min then
		return min
	else
		return x 
	end
end
