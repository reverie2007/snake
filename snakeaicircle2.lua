--[[ ai to find way
	需要使用snake的list，head，tail，food数据
	写入了snake的list.headDirection
--]]

local  class = require 'lib.simpleclass'


local StaticList = require 'StaticList'

local SnakeAICircle2 = class('SnakeAICircle2')

function SnakeAICircle2:init(x,y)
	self.dirlist = StaticList()	-- 策略列表，如果不为空，说明已经选定了一系列点，跟着走就行了
	self.pointnum = {}  -- 创建一个初始路径表，pointnum[x][y] = num,表明该点的初始顺序
	self.numpoint = {}  -- 反向查询某一数字num是哪一个点
	if x % 2 ~= 0 then
		error('Cloums can not be single num')
	end
	self.sizex = x
	self.sizey = y
	self.couple = {}
	for i = 1 , self.sizex/2 - 1 do
		self.couple[i] = self.sizey -1
	end
	-- 根据size和couple创建初始路径
	self.pointnum,self.numpoint = self:createPath(self.couple)
end


--[[
	获取下一步策略
--]]
function SnakeAICircle2:getNextPoint(snake)
	--  如果策略表中有数据，直接根据该数据前进
	--local dir = self.dirlist:pop()
	--if dir then return dir end
	-- 能否调整预定路线？
	self:adjustDir(snake)

	local list = snake.list
	local h = {x = list[list.head].x,y = list[list.head].y}
	local t = {x = list[list.tail].x,y = list[list.tail].y}
	local food = snake.food
	if food.x ~= nil then
		-- 查找到食物的最短路径，找不到就按照最开始的顺序前进
		local headtofood = self:getShortestPath(h,food,snake)
		-- 如果有，就可以按照该路径前进，否则按照既定路线前进
		if headtofood.length > 0 and list.length < self.sizex * self.sizey * 0.6 then
			-- 如果不是每次找一条路径，而是只找一个点，下次重新寻找最短路径，如何呢？
			local p = headtofood:pop()
			return p
			-- 下面是把整个路径添加到表中，该路径走完前不再重新寻找
			--[[
			--if (self:canReachTail(food,t,headtofood,snake)) then
				for i = 1,headtofood.length do
					local p = headtofood:pop()
					self.dirlist:append(p)
				end
				return self:getNextPoint(snake)
				-- 此处如果没有return，每次开始新路径都会跳过第一个点，为啥？？
			--end
			--]]
		end
	end

	local num = self.pointnum[h.x][h.y]
	num = num + 1
	if num > self.sizex*self.sizey then
		num = num - self.sizex*self.sizey
	end
	return self.numpoint[num]
end
--[[
	能否调整路径
--]]
function SnakeAICircle2:adjustDir(snake)
	
	local list = snake.list
	local h = {x = list[list.head].x,y = list[list.head].y}
	local t = {x = list[list.tail].x,y = list[list.tail].y}
	local food = snake.food
	-- 第一种情况，能否上下调整分隔线，使head到food的距离缩短
	if food ~= nil  and food.x ~= 1 and food.x ~= self.sizex then
		local cnum = 0
		-- 看food属于哪两列组成的对
		if (food.x % 2) == 0 then 
			cnum = food.x / 2
		else
			cnum = (food.x - 1) / 2
		end
		--local snum = self.pointnum[food.x][self.couple[cnum]] 
		local headnum = self.pointnum[h.x][h.y]
		local foodnum = self.pointnum[food.x][food.y]
		local distance = foodnum - headnum
		if distance < 0 then
			distance = distance + self.sizex * self.sizey
		end
		local c = {}
		for i,v in ipairs(self.couple) do 
			c[i] = v
		end
		if self.couple[cnum] < food.y then -- 如果分割线在食物上方
			-- 分割线在食物上方时看分割线能否挪到食物那条线
			-- 如果可以挪到，再看挪过去是否有好处来决定是否调整
			if self:canReachLine(cnum,self.couple[cnum] + 1,food.y,snake) then
				c[cnum] = food.y
				local pn = self:createPath(c)
				local newdist = pn[food.x][food.y] - pn[h.x][h.y]
				if newdist < 0 then
					newdist = newdist + self.sizex * self.sizey
				end
				-- 如果变过去有好处
				if newdist < distance then
					self.couple[cnum] = food.y
					self.pointnum,self.numpoint = self:createPath(self.couple)
				else
					-- 看变到food上方那条线是否有好处
					c[cnum] = food.y - 1
					pn = self:createPath(c)
					newdist = pn[food.x][food.y] - pn[h.x][h.y]
					if newdist < 0 then
						newdist = newdist + self.sizex * self.sizey
					end
					-- 如果变过去有好处
					if newdist < distance then
						self.couple[cnum] = food.y - 1
						self.pointnum,self.numpoint = self:createPath(self.couple)
					end
				end

				
			end
		else 
			-- 分割线在食物下方时看分割线能否挪到食物上方那条线
			-- 如果可以挪到，再看挪过去是否有好处来决定是否调整
			if self:canReachLine(cnum,food.y - 1,self.couple[cnum],snake) then
				c[cnum] = food.y - 1
				local pn = self:createPath(c)
				local newdist = pn[food.x][food.y] - pn[h.x][h.y]
				if newdist < 0 then
					newdist = newdist + self.sizex * self.sizey
				end
				-- 如果变过去有好处
				if newdist < distance then
					self.couple[cnum] = food.y - 1
					self.pointnum,self.numpoint = self:createPath(self.couple)
				else
					-- 看变到food那条线是否有好处
					c[cnum] = food.y
					pn = self:createPath(c)
					newdist = pn[food.x][food.y] - pn[h.x][h.y]
					if newdist < 0 then
						newdist = newdist + self.sizex * self.sizey
					end
					-- 如果变过去有好处
					if newdist < distance then
						self.couple[cnum] = food.y - 1
						self.pointnum,self.numpoint = self:createPath(self.couple)
					end
				end
			end
		end
	end
	-- 

end
--[[
	第cnum对中从y1能否到达y2中间没有障碍，设定y1<y2
--]]
function SnakeAICircle2:canReachLine(cnum,y1,y2,snake)
	if y1 < 1 or y2 >= self.sizey then
		return false
	end
	-- 根据第几对求出列数
	local c1 = cnum * 2
	local c2 = c1 + 1
	for i = y1,y2 do
		if snake:getPS(c1,i) == 'stone' or snake:getPS(c2,i) == 'stone' then
			return false
		end
	end
	return true
end
-- 点(x1,y1)能否走到(x2,y2)
function SnakeAICircle2:canReach(x1,y1,x2,y2,snake)
	if x2 > self.sizex or x2 < 1 or y2 < 1 or y2 > self.sizey then
		return false
	end
	local snaketail = snake.list.tail
	local tailnum = self.pointnum[snake.list[snaketail].x][snake.list[snaketail].y]
	--tailnum = tailnum or 0
	local num2 = 0
	local num1 = 0
	if self.pointnum[x2][y2] > tailnum then
		num2 = self.pointnum[x2][y2]
	else
		num2 = self.pointnum[x2][y2] + self.sizex * self.sizey
	end
	if self.pointnum[x1][y1] > tailnum then
		num1 = self.pointnum[x1][y1]
	else
		num1 = self.pointnum[x1][y1] + self.sizex * self.sizey
	end
	if num2 > num1 then 
		return true
	else
		return false
	end 

end

function SnakeAICircle2:createPath(couple)
	if couple == nil then
		error('缺少分隔信息无法创建路径')
	end

	local pairstart = 1
	local pairend = self.sizex * self.sizey

	-- 第一列
	local pn = {}
	local np = {}
	pn[1] = {}
	for j = 1,self.sizey do
		pn[1][j] = pairend
		np[pairend] = {x = 1,y = j}
		pairend = pairend - 1
	end

	for i,v in ipairs(couple) do
		local cloums = 2 * i
		pn[cloums] = {}
		for j = 1,v do
			pn[cloums][j] = pairstart
			np[pairstart] = {x = cloums,y = j}
			pairstart = pairstart + 1
		end
		for j = self.sizey,v+1,-1 do
			pn[cloums][j] = pairend
			np[pairend] = {x = cloums,y = j}
			pairend = pairend - 1
		end
		cloums = cloums + 1
		pn[cloums] = {}
		for j = v,1,-1 do
			pn[cloums][j] = pairstart
			np[pairstart] = {x = cloums,y = j}
			pairstart = pairstart + 1
		end
		for j = v+1,self.sizey do
			pn[cloums][j] = pairend
			np[pairend] = {x = cloums,y = j}
			pairend = pairend - 1
		end
	end

	-- 最后一列
	pn[self.sizex] = {}
	for j = 1,self.sizey do
		pn[self.sizex][j] = pairstart
		np[pairstart] = {x = self.sizex,y = j}
		pairstart = pairstart + 1
	end
	return pn,np
end
--[[
	根据headtofood构建虚拟蛇，看是否有食物到尾部的路线
--]]
function SnakeAICircle2:canReachTail(origin,target,headtofood,snake)
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
			if self:canReach(np.x,np.y,x,y,snake) then
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
	end
	-- 没有找到
	return false
end


--[[
	取得从起点到终点的最短路径，参数为origin(x,y),target(x,y)
	snake为存储蛇身与表的对象，需要用到它的list，pointState，sizey等数据
	返回一个StaticList,包含从起点到终点的一系列点
	有一个初始路径，在这个路径中按照顺序寻找，不允许破坏顺序
--]]
function SnakeAICircle2:getShortestPath(origin,target,snake)
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
			-- 定向图，先看np点能否走到新的x，y点
			if self:canReach(np.x,np.y,x,y,snake) then
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
	end
	-- 找到以后
	return headtotail
end

return SnakeAICircle2
