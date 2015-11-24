local map = require "map"
local actor = require "actor"
local map1
local act1, act2
-- local love = {}
function love.load()
	love.window.setMode(800, 600)
	map1 = map.new(800, 600)
	for x= 0, 15 do
		for y= 0, 15 do
			act1 = actor.new()
			act1.id = x * 16 + y
			act1:to(x * (800 / 16) + 10 , y * (600 / 16) + 10)
			map1:actor_init(act1)
		end
	end
end
local function draw(actor)
	-- if not actor:isrunning() then actor:to(math.random(700), math.random(500)) end
	actor:tick()
	map1:actor_move(actor)	
	love.graphics.setColor(255, 255, 0)
	function drawrect(node)
	-- 	love.graphics.rectangle("fill", 
	-- 	node.rect.left, node.rect.top, 
	-- 	node.rect.right - node.rect.left, node.rect.bottom - node.rect.top)
	end
	if actor.map.topleftpoint.node then
		drawrect(actor.map.topleftpoint.node)	
	end
	if actor.map.toprightpoint.node then
		drawrect(actor.map.toprightpoint.node)
	end
	if actor.map.bottomleftpoint.node then
		drawrect(actor.map.bottomleftpoint.node)
	end
	if actor.map.bottomrightpoint.node then
		drawrect(actor.map.bottomrightpoint.node)
	end
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", actor.rect.left, actor.rect.top, actor.rect.right - actor.rect.left, actor.rect.bottom - actor.rect.top)  
	love.graphics.setColor(actor.color.r, actor.color.g, actor.color.b)	
	love.graphics.print(tostring(actor.id), actor.x, actor.y)
	actor.color.r = 255
	actor.color.g = 255
	actor.color.b = 255	
end

local function drawtree(node)
	love.graphics.rectangle("line", node.rect.left, node.rect.top, node.rect.right - node.rect.left, node.rect.bottom - node.rect.top)  	
end

local function drawarea(actor)
	actor.color.r = 0
	actor.color.g = 0
	actor.color.b = 0
end

function love.draw()
	local x = love.mouse.getX()
	local y = love.mouse.getY()
	if x > 0 and x < 800 and y > 0 and y < 600 then
	 	local w = 100
		local r = {left = x, right = x + w, top = y, bottom = y + w}
		love.graphics.setColor(0, 255, 0)
		love.graphics.rectangle("fill", r.left, r.top, r.right - r.left, r.bottom - r.top)  	
		map1:areaactors_do(r, drawarea)
	end
	map1:allactors_do(draw)
	love.graphics.setColor(255, 0, 255)
	map1:quadtree_do(drawtree)
	love.graphics.print(tostring(love.timer.getFPS()), 0, 0)

end
