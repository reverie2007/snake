-- 主游戏场景,负责绘制和响应输入

local  class = require 'lib.simpleclass'
local COLOR = require 'lib.predefinedcolor'
local Snake = require 'Snake'

local lg = love.graphics


local MainScene = class('MainScene')

function MainScene:init()
	self.pos = {x = 32,y = 32}		-- 偏移位置
	self.unitsize = 32				-- 每个格子大小
	self.size = {x = 20,y = 20}		-- 有多少格子
	self.snake = Snake(self.size.x,self.size.y)
	self.img = lg.newImage('res/snake.png')
	self.quads = {}
	for i = 1,4 do
		for j = 1,4 do
			self.quads[(i-1)*4 + j] = lg.newQuad((j-1)*16,(i-1)*16,16,16,64,64)
		end
	end
	self.background = lg.newImage('res/background.jpg')

end

local function drawBox(x,y,size,color)
	local r, g, b, a = lg.getColor()
	lg.setColor(color.red, color.green, color.blue, color.alpha)
	lg.rectangle('fill', x, y, size, size)
	lg.setColor(135, 206, 235, 100)
	lg.rectangle('line', x, y, size, size)
	lg.rectangle('line', x+1, y+1, size-2, size-2)
	lg.rectangle('line', x+2, y+2, size-4, size-4)
	lg.rectangle('line', x+3, y+3, size-6, size-6)
	
	lg.setColor(r, g, b, a)
end
MainScene.drawBox = drawBox

-- 绘制一个格子
function MainScene:drawBlock(x,y,p,d)
	local x = self.pos.x + (x-1) * self.unitsize
	local y = self.pos.y + (y-1) * self.unitsize
	--drawBox(x,y,self.unitsize,COLOR.red)
	local id = self:getImgID(p,d)
	lg.draw(self.img,self.quads[id],x,y,0,2,2)
end
-- 得到对应的quadID，p为位置（头部，身体，尾巴），d为方向
function MainScene:getImgID(p,d)
	if p == 'head' then
		if d == 'up' then
			return 1
		elseif d == 'right' then
			return 2
		elseif d == 'down' then
			return 3
		elseif d == 'left' then
			return 4
		end
	elseif p == 'body' then
		if d == 'down-right' or d == 'left-up' then
			return 9
		elseif d == 'up-right' or d == 'left-down' then
			return 10
		elseif d == 'right-down' or d == 'up-left' then
			return 11
		elseif d == 'right-up' or d == 'down-left' then
			return 12
		elseif d == 'right-right' or d == 'left-left' then
			return 14
		elseif d == 'up-up' or d == 'down-down' then
			return 13
		end
	elseif p == 'tail' then
		if d == 'right-up' or d == 'left-up' or d == 'up-up' then
			return 5
		elseif d == 'up-right' or d == 'down-right' or d == 'right-right' then
			return 6
		elseif d == 'right-down' or d == 'left-down' or d == 'down-down'then
			return 7
		elseif d =='up-left'  or d == 'down-left' or d == 'left-left' then
			return 8
		end
	elseif p == 'food' then
		return 15
	end

end

-- 根据单元格大小，格子数绘制边框，以及内部对准线
function MainScene:drawBorder()
	local x = 0
	
	local size = self.unitsize

	local y1 = self.pos.y - size
	local y2 = self.pos.y + self.size.y * size

	for i = 0 ,self.size.x+1 do
		x = (i-1) * size + self.pos.x
		drawBox(x,y1,size,COLOR.blue)
		drawBox(x,y2,size,COLOR.blue)
	end
	y1 = self.pos.x -size
	y2 = self.pos.x + self.size.x * size
	for j = 1 ,self.size.y do
		x = self.pos.y + (j-1) * size
		drawBox(y1,x,size,COLOR.blue)
		drawBox(y2,x,size,COLOR.blue)
	end

	-- 画内部线方便对准
	local r, g, b, a = lg.getColor()
	lg.setColor(19, 19, 19, 30)
	for i = 1,(self.size.x - 1) do
		lg.line(self.pos.x + i * size, self.pos.y, self.pos.x + i * size, self.pos.y + self.size.y * size)
	end
	for i = 1,(self.size.y - 1) do
		lg.line(self.pos.x , self.pos.y+ i * size, self.pos.x + self.size.x * size, self.pos.y + i * size)
	end
	lg.setColor(r, g, b, a)
end

-- 绘制贪食蛇，用到了snake内的list，tail，head，food数据
function MainScene:drawSnake()
	local list = self.snake.list
	-- 是在创建列表的时候就把身体每个节存储到表中呢，还是在画身体时计算
	-- 创建列表每次移动执行，绘制次数要多，存储试试
	self:drawBlock(list[list.tail].x,list[list.tail].y,'tail',list[list.tail].flag)
	for i = list.tail+1,list.head -1 do
		self:drawBlock(list[i].x,list[i].y,'body',list[i].flag)
	end
	self:drawBlock(list[list.head].x,list[list.head].y,'head',list[list.head].flag)
	local food = self.snake.food

	if food.state == true then
    	self:drawBlock(food.x,food.y,'food','food')
    end

end
function MainScene:draw()
	lg.draw(self.background)
    self:drawBorder()
    self:drawSnake()
    
    self:drawState()
    --drawBlock(blockx,blocky)
    
end

function MainScene:keypressed(key)
    
    if key == 'right' then
    	self.snake:turn('right')
    elseif key == 'left' then
        self.snake:turn('left')
    elseif key == 'down' then
        self.snake:turn('down')
    elseif key == 'up' then
        self.snake:turn('up')
    elseif key == 'space' then
    	if self.snake.state == 'fail' or self.snake.state == 'goal' then
    		--self.snake.state = 'start'
    		self.snake:start()
    	elseif self.snake.state == 'start' then
    		self.snake.state = 'pause'
    	elseif self.snake.state == 'pause' then
    		self.snake.state = 'start'
    	end
    elseif key == 'escape' then
    	SceneManager.scene = SceneManager.startscene
    end
end

function MainScene:update(dt)
	self.snake:update(dt)
end
-- 绘制状态
function MainScene:drawState()
	local pausetext = {{0,255,0,100}," Pause "}
	local failtext = {{255,0,0,100},"You lose!!!!!"}
	local goaltext = {{255,0,0,100},"Wonderful!!You win!"}

	local snake = self.snake
	local str = 'Total time : '
	local t = snake.totaltime
	t = string.match(t,"[.][%d][%d]") -- 如果t==0，那么match返回nil
	if t == nil then t = '' end
	str = str .. t .. '    Listhead = '..snake.list.head

	lg.print(str,300,10,0,2,2)
	if snake.state == 'pause' then
		lg.print(pausetext, 100, 100, 0, 5, 5)
	elseif snake.state == 'fail' then
		lg.print(failtext, 100, 100, 0, 5, 5)
	elseif snake.state == 'goal' then
		lg.print(goaltext, 100, 100, 0, 5, 5)
	end
end

return MainScene
