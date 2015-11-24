

local map = require "map"
local actor = require "actor"
local map1
local act1
map1 = map.new(800, 600)
act1 = actor.new()
act1.id = 1

act1:to(100, 100)
map1:actor_add(act1)
local function draw(node)
	print(tostring(node.x)..':'..tostring(node.y).."|"..tostring(node.targetx)..":"..tostring(node.targety),  200, 20)
	node:tick()
	if not node:isrunning() then
		node:to(math.random(700), math.random(500))

	end
	map1:actor_move(node)
	--print("line", node.rect.left, node.rect.top, node.rect.right - node.rect.left, node.rect.bottom - node.rect.top)  	
	print("line1", 
		node.map.node.rect.left, node.map.node.rect.top, 
		node.map.node.rect.right - node.map.node.rect.left, node.map.node.rect.bottom - node.map.node.rect.top)  	

end
function draw1()
	map1:allactors_do(draw)	
end
while true do
	draw1()
end
-- love.load()
-- love.draw()