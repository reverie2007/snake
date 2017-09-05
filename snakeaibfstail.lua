--[[ ai to find way
	需要使用snake的list，head，tail，food数据
	写入了snake的list.headDirection
--]]

local  class = require 'lib.simpleclass'


local StaticList = require 'StaticList'

local SnakeAIBFSTail = class('SnakeAIBFSTail')

function SnakeAIBFSTail:init()
	self.dirlist = StaticList()	-- 策略列表，如果不为空，说明已经选定了一系列点，跟着走就行了
end

--[[
	获取下一步策略
--]]
function SnakeAIBFSTail:getNextPoint(snake)
	--  如果策略表中有数据，直接根据该数据前进
	local dir = self.dirlist:pop()
	if dir then return dir end

	local list = snake.list
	local h = {x = list[list.head].x,y = list[list.head].y}
	local t = {x = list[list.tail].x,y = list[list.tail].y}
	local food = snake.food
	if food.x == nil then
		return nil
	end
	-- 首先，找出蛇头部到食物的最短路径
	local headtofood = self:getShortestPath(h,food,snake)

	-- 构建一个虚拟蛇，按照路径吃到食物，然后查找是否有食物到尾部的路线，
	-- 如果有，就可以按照该路径前进，否则查找到尾部的最长路径
	if headtofood.length > 0 then
		if (self:canReachTail(food,t,headtofood,snake)) then
			for i = 1,headtofood.length do
				local p = headtofood:pop()
				self.dirlist:append(p)
			end
			return self:getNextPoint(snake)
			-- 此处如果没有return，每次开始新路径都会跳过第一个点，为啥？？
		end
	end

	local headtotail = self:getShortestPath(h,t,snake)
	local expanddir = self:expand(headtotail,snake)
	local exp = expanddir:pop()
	return exp
end

--[[
	根据headtofood构建虚拟蛇，看是否有食物到尾部的路线
--]]
function SnakeAIBFSTail:canReachTail(origin,target,headtofood,snake)
	-- 起点和终点相同，返回nil
	if origin.x == target.x and origin.y == target.y then
		return nil
	end

	-- 构建一个虚拟蛇的表，用来测试点的状态
	local vitualsnake = {}
	local dirlength = headtofood.length
	local snakelength = snake.list.length

	if snakelength >= dirlength - 1 then
		--  头部向前运动
		for i = 1 ,dirlength do
			local point = headtofood.list[headtofood.tail + i]
			vitualsnake[point.x * snake.sizey + point.y] = 1 -- 等于1表示被占用
		end
		--  尾部向前运动length-1
		local snaketail = snake.list.tail
		for i= 1,dirlength - 1 do
			local x = snake.list[snaketail + i -1].x
			local y = snake.list[snaketail + i -1].y
			vitualsnake[x * snake.sizey + y] = -1  -- 等于-1表示是空的，不用去snake中查找
		end
	else
		-- 路径前方蛇身长度+1的地方会被占据
		for i = 1 , snakelength + 1 do
			local point = headtofood.list[headtofood.head - i + 1]
			vitualsnake[point.x * snake.sizey + point.y] = 1 -- 等于1表示被占用
		end
		-- 整个蛇身全部空出来。
		--  尾部向前运动length-1
		local snaketail = snake.list.tail
		for i= 1,snakelength do
			local x = snake.list[snaketail + i -1].x
			local y = snake.list[snaketail + i -1].y
			vitualsnake[x * snake.sizey + y] = -1  -- 等于-1表示是空的，不用去snake中查找
		end

	end
	--  返回虚拟蛇中某一点的状态
	local function getState(x,y)
		if vitualsnake[x * snake.sizey + y] == 1 then
			return 'stone'
		elseif vitualsnake[x * snake.sizey + y] == -1 then
			return 'blank'
		else 
			return snake:getPS(x,y)
		end
	end
	local fs = {}
	local huise = StaticList()	-- 灰色顶点表
	huise:append(origin)	-- 顶点是先进先出，所以使用append添加，pop弹出
	fs[origin.x * snake.sizey + origin.y] = true 	--开始节点在状态表中标记为true
	local np
	local d = {{1,0},{-1,0},{0,1},{0,-1}}
	local x = 0
	local y = 0
	while(huise.length > 0) do
		np = huise:pop()
		for i,v in ipairs(d) do -- 找到4个方向的点
			x = np.x + v[1]
			y = np.y + v[2]
			-- 如果点与目标点相同，搜索结束
			if (x == target.x and y == target.y) then
				return true
			elseif getState(x,y) ~= 'stone' and fs[x * snake.sizey + y] == nil then
				--  如果一个点没有被占用并且还没有标记
				fs[x * snake.sizey + y] = {x = np.x,y = np.y} --  将该点的父节点坐标存储在fs中
				huise:append({x = x , y = y})
			end
		end
	end
	-- 没有找到
	return false
end


--[[
	取得从起点到终点的最短路径，参数为origin(x,y),target(x,y)
	snake为存储蛇身与表的对象，需要用到它的list，pointState，sizey等数据
	返回一个StaticList,包含从起点到终点的一系列点
--]]
function SnakeAIBFSTail:getShortestPath(origin,target,snake)
	-- 起点和终点相同，返回nil
	if origin.x == target.x and origin.y == target.y then
		return nil
	end



	local fs = {}
	local huise = StaticList()	-- 灰色顶点表
	local headtotail = StaticList() 	-- 要返回的静态列表
	local function addUP(np)
		-- 如果np就是起点了
		if fs[np.x * snake.sizey + np.y] == true then
			return
		else
			-- 还没有到起点，先将np加上
			headtotail:push(np)
			-- 接着添加np的父节点
			return addUP(fs[np.x * snake.sizey + np.y])
		end
	end

	huise:append(origin)	-- 顶点是先进先出，所以使用append添加，pop弹出
	fs[origin.x * snake.sizey + origin.y] = true 	--开始节点在状态表中标记为true
	local np
	local d = {{1,0},{-1,0},{0,1},{0,-1}}
	local x = 0
	local y = 0
	while(huise.length > 0) do
		np = huise:pop()
		for i,v in ipairs(d) do -- 找到4个方向的点
			x = np.x + v[1]
			y = np.y + v[2]
			-- 如果点与目标点相同，搜索结束
			if (x == target.x and y == target.y) then
				-- 先将(x,y)添加到路径中
				headtotail:push({x = x , y = y})-- 这里是从终点反推回去，所以使用push，pop的时候就是从起点开始了
				  --  根据np坐标与fs中记录的父节点坐标将从np到起点全部添加到路径表中
				addUP(np)
				return headtotail
			elseif snake:getPS(x,y) ~= 'stone' and fs[x * snake.sizey + y] == nil then
				--  如果一个点没有被占用并且还没有标记
				fs[x * snake.sizey + y] = {x = np.x,y = np.y} --  将该点的父节点坐标存储在fs中
				huise:append({x = x , y = y})
			end
		end
	end
	-- 找到以后
	return headtotail
end

function SnakeAIBFSTail:expand(headtotail,snake)
	-- 如果不在，扩展该路径直到碰到食物或者扩展到最大
	local expanddir = StaticList()
	local food = snake.food

	local fs = {}	-- 记录扩展过程中点的状态，如果fs[x * snake.sizey + y] == true,该点不能用
	-- 先将路径上的点标记为已使用。
	for i = headtotail.head,headtotail.tail + 1,-1 do
		fs[headtotail.list[i].x * snake.sizey + headtotail.list[i].y] = true
	end

	local function isEmpty(p)
		if fs[p.x * snake.sizey + p.y] == nil and snake:getPS(p.x,p.y) ~= 'stone' then
			return true
		else
			return false
		end
	end
	local findfood = false
	-- local p1 = headtotail:pop()  -- p1不能从路径第一个点开始，而应该从head开始
	local p1 = {x = snake.list[snake.list.head].x , y = snake.list[snake.list.head].y}
	while (headtotail.length > 0) do
		local p2 = headtotail:pop()

		if (p2.x == food.x and p2.y == food.y) then
			-- 如果p2是食物
			expanddir:append(p1)
			expanddir:append(p2)
			findfood = true
			break
		end
		local expand = true
		while(expand) do
			if p1.x == p2.x then -- 如果是竖的
				-- 左边能扩展么
				local np1 = {x = p1.x - 1 , y = p1.y}
				local np2 = {x = p2.x - 1 , y = p2.y}
				local np3 = {x = p1.x + 1 , y = p1.y}
				local np4 = {x = p2.x + 1 , y = p2.y}
				if isEmpty(np1) and isEmpty(np2) then
					-- 左边两个点都是空的
					fs[np1.x * snake.sizey + np1.y] = true
					fs[np2.x * snake.sizey + np2.y] = true
					headtotail:push(p2)
					headtotail:push(np2)
					p2 = np1
				elseif isEmpty(np3) and isEmpty(np4) then
					-- 右边两个点是空的
					fs[np3.x * snake.sizey + np3.y] = true
					fs[np4.x * snake.sizey + np4.y] = true
					headtotail:push(p2)
					headtotail:push(np4)
					p2 = np3
				else
					expand = false
				end
			elseif p1.y == p2.y then -- 如果是横的
				local np1 = {x = p1.x , y = p1.y - 1}
				local np2 = {x = p2.x , y = p2.y - 1}
				local np3 = {x = p1.x , y = p1.y + 1}
				local np4 = {x = p2.x , y = p2.y + 1}
				if isEmpty(np1) and isEmpty(np2) then
					-- 上边两个点都是空的
					fs[np1.x * snake.sizey + np1.y] = true
					fs[np2.x * snake.sizey + np2.y] = true
					headtotail:push(p2)
					headtotail:push(np2)
					p2 = np1
				elseif isEmpty(np3) and isEmpty(np4) then
					-- 下边两个点是空的
					fs[np3.x * snake.sizey + np3.y] = true
					fs[np4.x * snake.sizey + np4.y] = true
					headtotail:push(p2)
					headtotail:push(np4)
					p2 = np3
				else
					expand = false
				end
			end
		end
		-- 将第一个点都扩展完毕后
		expanddir:append(p1)	-- 将p1添加到扩展后的路径中
		p1 = p2
		-- 这里p1是扩展的点，没有添加到headtotail中，没有机会与food比较
		if (p1.x == food.x and p1.y == food.y) then
			-- 如果p2是食物
			expanddir:append(p1)
			findfood = true
			break
		end
	end
	while (headtotail.length > 0) do
		p1 = headtotail:pop()
		expanddir:append(p1)
	end
	-- 将head弹出
	expanddir:pop()
	return expanddir
end

return SnakeAIBFSTail
