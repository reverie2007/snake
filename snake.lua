-- snake 类，负责所有的逻辑操作,所有操作基于每段占据的格，与实际坐标脱离
-- 使用一个数组链表list表示贪食蛇，两个整数表示头尾，

local  class = require 'lib.simpleclass'
local SnakeAI = require 'snakeai'
local SnakeAIBFS = require 'snakeaibfs'
local SnakeAIBFSTail = require 'SnakeAIBFSTail'

local Snake = class('Snake')

--[[
	初始化函数，创建新实例时自动调用
--]]
function Snake:init(x,y)
	-- 定义一个x*y大小的矩阵来表示活动范围
	self.sizex = x
	self.sizey = y
	self.speed = 0.05
	self.operator = 'ai' -- 规定操作者是ai还是human
	self.ai = SnakeAI()
	self.ai2 = SnakeAIBFS()
	self.ai3 = SnakeAIBFSTail()
	self.eatsound = love.audio.newSource('res/eat.wav', 'static')
	self.failsound = love.audio.newSource('res/gameover.wav', 'static')
	self:start()
end

--[[
	开始函数，启动一局新游戏
--]]
function Snake:start()
	self.list = {}		--贪食蛇链表
	self.pointState = {}  	-- 标志一个点是否被占用的表，如果pointState[x*self.siezy + y] == true,表示该点是蛇身体，不能占用
	self.food = {}
	-- 初始化定时器
	self.time = 0
	self.totaltime = 0		-- 总时间

	local list = self.list
	local pointState = self.pointState
	local food = self.food
	local time = self.time

	math.randomseed(os.time())
	self.state = 'start'
	food.state = false

	-- 初始化贪食蛇的位置大小方向
	local x = self.sizex
	x= (x/2)-(x/2)%1
	local y = self.sizey
	y = (y/2)-(y/2)%1

	list.headDirection = 'right'
	list.bodyDirection = 'right'
	list[3] = {x = x,y = y,flag = 'right'}
	pointState[list[3].x*self.sizey + list[3].y] = true
	list[2] = {x = x - 1,y = y,flag = 'right-right'}
	pointState[list[2].x*self.sizey + list[2].y] = true
	list[1] = {x = x-2,y = y,flag = 'right-right'}
	pointState[list[1].x*self.sizey + list[1].y] = true
	list.length = 3

	list.head = 3
	list.tail = 1
end

--[[
	更新函数，每帧被MainScene自动调用
--]]
function Snake:update(dt)
	local list = self.list
	local pointState = self.pointState
	local food = self.food

	if self.state == 'start' then
		self.totaltime = self.totaltime + dt
		self.time = self.time + dt
		if self.time > self.speed then
			self.time = self.time - self.speed
			self:updateSnake()
			self:updateFood()
		end
	elseif self.state == 'pause' then

	elseif self.state == 'fail' then

	elseif self.state == 'goal' then

	end
end

--[[
 	接受转向指令
--]]
function Snake:turn(d)
	if self.state ~= 'start' then
		return
	end

	local list = self.list

	if d == 'right' then
		-- 向右走，如果现在正在向左，命令无效
    	if list.bodyDirection == 'left' then
    		return
    	else
    		list.headDirection = 'right'
        end
    elseif d == 'left' then
    	-- 向左走，如果现在正在向右，命令无效
        if list.bodyDirection == 'right' then
    		return
    	else
    		list.headDirection = 'left'
        end
    elseif d == 'down' then
    	-- 向下走，如果现在正在向上，命令无效
        if list.bodyDirection == 'up' then
    		return
    	else
    		list.headDirection = 'down'
        end
    elseif d == 'up' then
    	-- 向上走，如果现在正在向下，命令无效
        if list.bodyDirection == 'down' then
    		return
    	else
    		list.headDirection = 'up'
        end
    elseif d == 'rotateright' then
    	-- 向右旋转
        if list.bodyDirection == 'down' then
    		list.headDirection = 'left'
    	elseif list.bodyDirection == 'left' then
    		list.headDirection = 'up'
    	elseif list.bodyDirection == 'up' then
    		list.headDirection = 'right'
    	elseif list.bodyDirection == 'right' then
    		list.headDirection = 'down'
        end
    elseif d == 'rotateleft' then
    	-- 向左旋转
        if list.bodyDirection == 'down' then
    		list.headDirection = 'right'
    	elseif list.bodyDirection == 'left' then
    		list.headDirection = 'down'
    	elseif list.bodyDirection == 'up' then
    		list.headDirection = 'left'
    	elseif list.bodyDirection == 'right' then
    		list.headDirection = 'up'
        end
    end
end

--[[获取下一个点，人工模式根据输入的方向获取下一个点
	ai模式直接获取下一个点，并标注方向，下一步是否有必要
	将ai介入地点从该函数移走，和人工一样通过turn函数操作

--]]

function Snake:getNextPoint()
	if self.operator == 'ai' then
		local pos = self.ai3:getNextPoint(self)
		if pos then
			return pos 
		else 
			return nil
		end

	end


	local list = self.list
	if list.headDirection == 'right' then
		return {x= list[list.head].x + 1,y = list[list.head].y}
	elseif list.headDirection == 'left' then
		return {x = list[list.head].x - 1,y = list[list.head].y}
	elseif list.headDirection == 'up' then
		return {x = list[list.head].x,y = list[list.head].y - 1}
	elseif list.headDirection == 'down' then
		return {x = list[list.head].x ,y = list[list.head].y + 1}
	end
end
--[[ 获得指定点（x,y）的状态，返回'out','blank','stone','food'
 	分别表示该点：超出范围，空的，被占用，是食物，
 	超出范围也改成'stone',效果是一致的，使用时少判断一个状态

--]]
function Snake:getPS(x,y)
	-- 判断边界，可以通过在pointState外面包一个圈，这样不用单独处理边界
	-- 只要
	if x < 1 or x > self.sizex or y < 1 or y > self.sizey then
		return 'stone'
	end
	local pointState = self.pointState
	if pointState[x * self.sizey + y] == true then
		return 'stone'
	elseif pointState[x * self.sizey + y] == nil then
		return 'blank'

	elseif pointState[x * self.sizey + y] == 'food' then
		return 'food'
	end
end

--[[ 更新snake状态

--]]
function Snake:updateSnake()
	local pos = self:getNextPoint()
	if pos == nil then return end

	local list = self.list
	local pointState = self.pointState
	local food = self.food
	-- 根据pos和head判定方向
	---[[
	local headx = list[list.head].x 
	local heady = list[list.head].y
	if pos.x == headx then
		if pos.y > heady then
			list.headDirection = 'down'
		else 
			list.headDirection = 'up'
		end
	elseif pos.x > headx then
		list.headDirection = 'right'
	else
		list.headDirection = 'left'
	end
	--]]
	if self:getPS(pos.x,pos.y) == 'stone' then
		-- 撞到自己或边界
		self.failsound:play()
		self.state = 'fail'

    	--self:start()
	elseif self:getPS(pos.x,pos.y) == 'blank' then
		-- 点是空的，前进一位
		list[list.head].flag = list.bodyDirection .. '-' .. list.headDirection
		pos.flag = list.headDirection
		list[list.head + 1] = pos
		pointState[pos.x * self.sizey + pos.y] = true
		pointState[list[list.tail].x * self.sizey + list[list.tail].y] = nil
		list[list.tail] = nil
		list.head = list.head + 1
		list.tail = list.tail + 1

		list.bodyDirection = list.headDirection

	elseif self:getPS(pos.x,pos.y) == 'food' then
		-- 撞到食物
		self.eatsound:play()
		list[list.head].flag = list.bodyDirection .. '-' .. list.headDirection
		list.head = list.head + 1
		list.length = list.length + 1
		pos.flag = list.headDirection
		list[list.head] = pos
		pointState[pos.x * self.sizey + pos.y] = true
		list.bodyDirection = list.headDirection
		food.state = false -- 食物被吃掉了，没有食物了，应该生成新的食物了
		if list.length > 300 then
			self.state = 'goal'
		end
	end
end

--[[
	生成新的食物
--]]
function Snake:updateFood()
	local food = self.food
	if food.state == true then
		return
	end

	local list = self.list
	local pointState = self.pointState
	local find = true
	local x = 1
	local y = 1
	-- 找出一个可用的放食物的地方
	-- 现在是随机生成位置，如果已经被占了就重新生成位置，直到找到一个空的地方
	-- 这样可能在后期需要比较多的次数，以后可以改为随机生成在第i个空的地方
	while find == true do
		x = math.random(self.sizex)
		y = math.random(self.sizey)
		if pointState[x * self.sizey + y] == nil then
			food.state = true
			food.x = x
			food.y = y
			pointState[x * self.sizey + y] = 'food'
			find = false
		end
	end
end


return Snake
