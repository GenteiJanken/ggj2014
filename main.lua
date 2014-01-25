--[[

	Standpoint
	
	Josh Douglass-Molloy
	Jam: Global Game Jam 2014
	Theme: "We don't see things as they are, we see them as we are."

	Line to include: "My views are the same as yours!"
	
]]--


COLOURS = {
	DEFAULT = {255, 255, 255},
	--PLAYER = {0, 255, 0}, --brightest green
	PLAYER = {100, 154, 91}, --moss green
	ENTITY = {50, 80, 30},
	TEXTBOX = {50, 50, 50, 125}
}

WORLD_SIZE = {100, 100}
MAX_ENTITIES = 6


player = {}


function player:init()
	self.pos = {0, 0}
	self.size = 5
	self.camera = 50
	self.identity = {0, 0}
	self.speed = 20
	self.lives = 3
end

--player always drawn at centre, entities drawn relative
function player:draw()
	sw, sh = love.graphics.getMode()
	love.graphics.setColor(unpack(COLOURS.PLAYER))
	--love.graphics.setColor(unpack(COLOURS.ENTITY))
	love.graphics.rectangle("fill", 0.5*sw - self.size / WORLD_SIZE[1] * sw, 0.5*sh - self.size /WORLD_SIZE[1] *sh, 2*self.size/WORLD_SIZE[1] *sw, 2*self.size/WORLD_SIZE[1] * sh)
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
	
	
	for i = 1,2 do
		if math.abs(self.pos[i]) > WORLD_SIZE[i] / 2 then
			self.pos[i] = self.pos[i] / math.abs(self.pos[i]) * WORLD_SIZE[1] / 2 
		end
	end

--[[	if math.abs(self.pos[2]) > WORLD_SIZE[2] / 2 then
		self.pos[2] = self.pos[2] / math.abs(self.pos[2]) * WORLD_SIZE[2] / 2 
	end
]]--
end


world = {}

function world:init()
	self.entities = {}
end

function world:draw()

	hue = {player.pos[1] + WORLD_SIZE[1]/2, 0, WORLD_SIZE[1]/2 - player.pos[1] }
	sat = (-player.pos[2] + 100) / WORLD_SIZE[2]
	love.graphics.setBackgroundColor(hue[1]*sat, 0, hue[3]*sat)
	
	for _, e in ipairs(self.entities) do
		e:draw()	
	end
end

function world:update(dt)

	for _, e in ipairs(self.entities) do
		e:update(dt)
	end
end

Entity = {}

function Entity:new(spawn)

	local o = {
		origin = spawn
	}
	o.pos = { clamp(spawn[1] + player[1], -WORLD_SIZE[1] / 2, WORLD_SIZE[1] / 2), 
				clamp(spawn[2] + player[2], -WORLD_SIZE[2] / 2, WORLD_SIZE[2] / 2)}

	setmetatable(o, self)
	self.__index = self
	return o
end



function love.load()
	world:init()
	player:init()
	love.graphics.setBackgroundColor(255, 255,255)
end

function love.update(dt)

	world:update(dt)
	player:update(dt)

end


function love.draw()
	world:draw()
	player:draw()
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

--Euclidean distance
function distance(p1, p2)
	return math.sqrt(math.pow(p1[1] - p2[2], 2), math.pow(p1[1], p2[2], 2))
end
