local quadtree = { }
local rt, lt, lb, rb = 1, 2, 3, 4
local id = 1
function quadtree.split(node, r, level)
	node.level = level 
	node.id = id
	id = id + 1
	if  level - 1 > 0 then
		node.quadnode = {}
		
		local t
		t = {left = r.left + (r.right - r.left) / 2, top = r.top}
		t.right = t.left + (r.right - r.left) / 2
		t.bottom = t.top + (r.bottom - r.top) / 2
		node.quadnode[rt] = {}
		node.quadnode[rt].rect = t
	
		t = {left = r.left, top = r.top}
		t.right = t.left + (r.right - r.left) / 2
		t.bottom = t.top + (r.bottom - r.top) / 2
		node.quadnode[lt] = {}
		node.quadnode[lt].rect = t

		t = {left = r.left, top = r.top + (r.bottom - r.top) / 2}
		t.right = t.left + (r.right - r.left) / 2
		t.bottom = t.top + (r.bottom - r.top) / 2
		node.quadnode[lb] = {}
		node.quadnode[lb].rect = t

		t = {left = r.left + (r.right - r.left) / 2, top = r.top + (r.bottom - r.top) / 2}
		t.right = t.left + (r.right - r.left) / 2
		t.bottom = t.top + (r.bottom - r.top) / 2
		node.quadnode[rb] = {}
		node.quadnode[rb].rect = t
	
		quadtree.split(node.quadnode[rt], node.quadnode[rt].rect, level - 1)
		quadtree.split(node.quadnode[lt], node.quadnode[lt].rect, level - 1)
		quadtree.split(node.quadnode[lb], node.quadnode[lb].rect, level - 1)
		quadtree.split(node.quadnode[rb], node.quadnode[rb].rect, level - 1)
	else
		node.rect = r
	end
end

function quadtree.pointinrect(point, outrect)
	if point.x >= outrect.left and point.x < outrect.right and
		point.y >= outrect.top and point.y < outrect.bottom then
		return true
	else
		return false
	end
end

function quadtree.put_point(node, parent, point)
	if (node.level > 1) and quadtree.pointinrect(point, node.rect) then
		if point.x >= node.rect.left + (node.rect.right - node.rect.left) / 2 then
			if point.y >= node.rect.top + (node.rect.bottom - node.rect.top) / 2 then
				return quadtree.put_point(node.quadnode[rb], node, point)
			else
				return quadtree.put_point(node.quadnode[rt], node, point)
			end
		else
			if point.y >= node.rect.top + (node.rect.bottom - node.rect.top) / 2 then
				return quadtree.put_point(node.quadnode[lb], node, point)
			else
				return quadtree.put_point(node.quadnode[lt], node, point)
			end
		end
	end
	assert(node.level == 1)
	assert(quadtree.pointinrect(point, node.rect))
	return node, parent
end

function quadtree.get_node(root, point)
	return quadtree.put_point(root, root, point)
end

function quadtree.innode(node, p)
	return quadtree.pointinrect(p, node.rect)
end

function quadtree.rectinrect(inrect, outrect)
	if (outrect.left <= inrect.left) and (outrect.top <= inrect.top) 
		and (outrect.right >= inrect.right) and (outrect.bottom >= inrect.bottom) then
		return true
	else
		return false
	end
end

function quadtree.find_node(node, rect, parent)
	if (node.level > 1) and quadtree.rectinrect(rect, node.rect) then
		if rect.left >= node.rect.left + (node.rect.right - node.rect.left) / 2 then
			if rect.top >= node.rect.top + (node.rect.bottom - node.rect.top) / 2 then
				return quadtree.find_node(node.quadnode[rb], rect, node)
			else
				return quadtree.find_node(node.quadnode[rt], rect, node)
			end
		else
			if rect.top >= node.rect.top + (node.rect.bottom - node.rect.top) / 2 then
				return quadtree.find_node(node.quadnode[lb], rect, node)
			else
				return quadtree.find_node(node.quadnode[lt], rect, node)
			end
		end
	end
	-- 
	if quadtree.rectinrect(rect, node.rect) then
		return node, parent
	elseif quadtree.rectinrect(rect, parent.rect) then
		return parent
	else
		return nil
	end
end

local function splitrect(rect, point)
	if quadtree.pointinrect(point, rect) then--split 4
		return 
		{left = point.x, right = rect.right, top = rect.top, bottom = point.y},
		{left = rect.left, right = point.x, top = rect.top, bottom = point.y},
		{left = rect.left, right = point.x, top = point.y, bottom = rect.bottom},
		{left = point.x, right = rect.right, top = point.y, bottom = rect.bottom}
	elseif point.y > rect.top and point.y < rect.bottom then
		local r1, r2 = {left = rect.left, right = rect.right, top = rect.top, bottom = point.y},
			{left = rect.left, right = rect.right, top = point.y, bottom = rect.bottom}
		if point.x <= rect.left then 
			return r1, nil, nil, r2
		else
			return nil, r1, r2, nil
		end
	else
		local r1, r2 = {left = rect.left, right = point.x, top = rect.top, bottom = rect.bottom},
			{left = point.x, right = rect.right, top = rect.top, bottom = rect.bottom}
		if point.y <= rect.top then
			return nil, nil, r1, r2
		else
			return r1, r2, nil, nil
		end
	end
end

local function wget(node, rect, r)
	if node.level > 1 then
		local r1, r2, r3, r4 = splitrect(rect, 
			{x = node.rect.left + (node.rect.right - node.rect.left) / 2,
			y = node.rect.top + (node.rect.bottom - node.rect.top) / 2})
		if r1 then 
			local n = quadtree.find_node(node, r1, node)
			wget(n, r1, r) 
		end
		if r2 then 
			local n = quadtree.find_node(node, r2, node)
			wget(n, r2, r) 
		end
		if r3 then 
			local n = quadtree.find_node(node, r3, node)
			wget(n, r3, r) 
		end
		if r4 then 
			local n = quadtree.find_node(node, r4, node)
			wget(n, r4, r) 
		end
	else
		table.insert(r, node)	
	end
end

function quadtree.get(node, rect)
	local r = {}
	local n = quadtree.find_node(node, rect, node)
	if n then wget(n, rect, r) end
	return r
end

function quadtree.dotree(node, callback)
	if node.rect then 
		callback(node)
	else
		return
	end
	if not node.quadnode then return end
	quadtree.dotree(node.quadnode[lt], callback)
	quadtree.dotree(node.quadnode[lb], callback)
	quadtree.dotree(node.quadnode[rt], callback)
	quadtree.dotree(node.quadnode[rb], callback)
end

return quadtree
