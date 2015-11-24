local quadtree = require "quadtree"
local map = {}
map.__index = map
local logger = io.open("log.txt", "a")
io.output(logger)
function map.new(w, h)
	local t = setmetatable({}, map)
	t.h = h
	t.w = w
	local r = {left = 0, top = 0, right = w, bottom = h}
	t.root = {}
	t.root.rect = r
	quadtree.split(t.root, r, 5)
	t.actors = {}
	return t
end

function map:actor_init(actor)
	self:actor_add(actor, actor.map.topleftpoint, actor.topleftpoint)
	self:actor_add(actor, actor.map.toprightpoint, actor.toprightpoint)
	self:actor_add(actor, actor.map.bottomleftpoint, actor.bottomleftpoint)
	self:actor_add(actor, actor.map.bottomrightpoint, actor.bottomrightpoint)
end

function map:actor_add(actor, actormap, point, root)
	self:actor_delete(actor)
	actormap.node, actormap.parent = quadtree.get_node(root or self.root, point)
	if not self.actors[actormap.node.id] then self.actors[actormap.node.id] = {} end
	self.actors[actormap.node.id][actor.id] = actor
end

function map:actor_delete(actor)
	if actor.map then
		if actor.map.topleftpoint.node then
			self.actors[actor.map.topleftpoint.node.id][actor.id] = nil
		end
		if actor.map.toprightpoint.node then
			self.actors[actor.map.toprightpoint.node.id][actor.id] = nil
		end
		if actor.map.bottomleftpoint.node then
			self.actors[actor.map.bottomleftpoint.node.id][actor.id] = nil
		end
		if actor.map.bottomrightpoint.node then
			self.actors[actor.map.bottomrightpoint.node.id][actor.id] = nil
		end
	end
end

function map:actor_move(actor)	
	local function move(node, point)
		assert(node)
		assert(point)
		if node.level == 1 and quadtree.innode(node.node, point) then
			return
		elseif node.parent and quadtree.innode(node.parent, point) then
			self:actor_add(actor, node, point, node.parent)
		else
			self:actor_add(actor, node, point)
		end
	end
	assert(actor)
	move(actor.map.topleftpoint, actor.topleftpoint)
	move(actor.map.toprightpoint, actor.toprightpoint)
	move(actor.map.bottomleftpoint, actor.bottomleftpoint)
	move(actor.map.bottomrightpoint, actor.bottomrightpoint)
end

function map:areaactors_do(rect, callback)
	assert(callback)
	local objs = quadtree.get(self.root, rect)
	for	k, v in ipairs(objs) do
		if self.actors[v.id] then
			for	_, actor in pairs(self.actors[v.id]) do
				callback(actor)
			end
		end
	end
end

function map:allactors_do(callback)
	assert(callback)
	for _,v in pairs(self.actors) do
		for _, actor in pairs(v) do
			callback(actor)
		end
	end
end

function map:quadtree_do(callback)
	quadtree.dotree(self.root, callback)
end
return map



