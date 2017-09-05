--[[ ai to find way
	需要使用snake的list，head，tail，food数据
	写入了snake的list.headDirection
--]] 

local  class = require 'lib.simpleclass'
local SnakeAIBFS = class('SnakeAIBFS')

function SnakeAIBFS:init()
	self.dirlist = {}
end

--[[
	宽度优先搜索寻找下一个点。每前进一步重新搜索。
	如果搜索一次就确定一个路径，该次走完前不重新搜索效果如何？
--]]
function SnakeAIBFS:getNextPoint(snake)
	--
	local list = snake.list
	local h = {x = list[list.head].x,y = list[list.head].y}
	local t = {x = list[list.tail].x,y = list[list.tail].y}
	local food = snake.food
	if food.x == nil then
		return nil
	end

	-- 起点h(x,y)，终点food(x,y)
	local fs = {} 	-- 状态表，一个点(x,y)如果没有访问到，fs[x * sizey + y]为nil，发现后为他的上一层点的坐标(x1,y1)
	local queen = {} -- 灰色顶点表
	local function push(pos)
		table.insert(queen,pos)
	end
	local function pop()
		return table.remove(queen,1)
	end

	local function getSecondNode(np)
		local p = fs[np.x * snake.sizey + np.y]
		if fs[p.x * snake.sizey + p.y] == true then
			if np.x == h.x then
				if np.y > h.y then
					list.headDirection = 'down'
				else 
					list.headDirection = 'up'
				end
			elseif np.x > h.x then
				list.headDirection = 'right'
			else
				list.headDirection = 'left'
			end
			return np
		else
			return getSecondNode(p)
		end
	end

	push(h)
	fs[h.x * snake.sizey + h.y] = true 	--开始节点在状态表中标记为true
	local np
	local d = {{1,0},{-1,0},{0,1},{0,-1}}
	local x = 0
	local y = 0
	while(#queen > 0) do
		np = pop()
		for i,v in ipairs(d) do -- 找到4个方向的点
			x = np.x + v[1]
			y = np.y + v[2]
			if snake:getPS(x,y) == 'food' then
				if fs[np.x * snake.sizey + np.y] == true then
					if x == h.x then
						if y > h.y then
							list.headDirection = 'down'
						else 
							list.headDirection = 'up'
						end
					elseif x > h.x then
						list.headDirection = 'right'
					else
						list.headDirection = 'left'
					end
					return {x = x , y = y} 	--  处理np就是开始节点的情况
				else
				--  如果xy是目标点,np是他的父节点
					return getSecondNode(np)  --  根据np坐标与fs中记录的父节点坐标反向找到第二个点
				end
			elseif snake:getPS(x,y) == 'blank' and fs[x * snake.sizey + y] == nil then
				--  如果一个点是空值并且还没有标记
				fs[x * snake.sizey + y] = {x = np.x,y = np.y} --  将一个点的父节点坐标存储在fs中
				push({x = x , y = y})

			end
		end
	end
	--  如果执行到这里，说明没有找到目标点，那么np不是目标点
	--  但是np也是最远的点，就往这走吧
	if fs[np.x * snake.sizey + np.y] == true then
		return np
	else
		return getSecondNode(np)
	end

end

--[[
	宽度优先搜索寻找下一个点。每前进一步重新搜索。
	如果搜索一次就确定一个路径，该次走完前不重新搜索效果如何？
--]]
function SnakeAIBFS:getNextPoint2(snake)
	--
	local list = snake.list
	local h = {x = list[list.head].x,y = list[list.head].y}
	local t = {x = list[list.tail].x,y = list[list.tail].y}
	local food = snake.food
	if food.x == nil then
		return nil
	end

	-- 起点h(x,y)，终点food(x,y)
	local fs = {} 	-- 状态表，一个点(x,y)如果没有访问到，fs[x * sizey + y]为nil，发现后为他的上一层点的坐标(x1,y1)
	local queen = {} -- 灰色顶点表
	local function push(pos)
		table.insert(queen,pos)
	end
	local function pop()
		return table.remove(queen,1)
	end

	local function getSecondNode(np)
		local p = fs[np.x * snake.sizey + np.y]
		if fs[p.x * snake.sizey + p.y] == true then
			if np.x == h.x then
				if np.y > h.y then
					list.headDirection = 'down'
				else 
					list.headDirection = 'up'
				end
			elseif np.x > h.x then
				list.headDirection = 'right'
			else
				list.headDirection = 'left'
			end
			return np
		else
			return getSecondNode(p)
		end
	end

	push(h)
	fs[h.x * snake.sizey + h.y] = true 	--开始节点在状态表中标记为true
	local np
	local d = {{1,0},{-1,0},{0,1},{0,-1}}
	local x = 0
	local y = 0
	while(#queen > 0) do
		np = pop()
		for i,v in ipairs(d) do -- 找到4个方向的点
			x = np.x + v[1]
			y = np.y + v[2]
			if snake:getPS(x,y) == 'food' then
				if fs[np.x * snake.sizey + np.y] == true then
					if x == h.x then
						if y > h.y then
							list.headDirection = 'down'
						else 
							list.headDirection = 'up'
						end
					elseif x > h.x then
						list.headDirection = 'right'
					else
						list.headDirection = 'left'
					end
					return {x = x , y = y} 	--  处理np就是开始节点的情况
				else
				--  如果xy是目标点,np是他的父节点
					return getSecondNode(np)  --  根据np坐标与fs中记录的父节点坐标反向找到第二个点
				end
			elseif snake:getPS(x,y) == 'blank' and fs[x * snake.sizey + y] == nil then
				--  如果一个点是空值并且还没有标记
				fs[x * snake.sizey + y] = {x = np.x,y = np.y} --  将一个点的父节点坐标存储在fs中
				push({x = x , y = y})

			end
		end
	end
	--  如果执行到这里，说明没有找到目标点，那么np不是目标点
	--  但是np也是最远的点，就往这走吧
	if fs[np.x * snake.sizey + np.y] == true then
		return np
	else
		return getSecondNode(np)
	end

end

return SnakeAIBFS
