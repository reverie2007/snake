-- 主游戏场景,负责绘制和响应输入

local  class = require 'lib.simpleclass'
local COLOR = require 'lib.predefinedcolor'
local Snake = require 'Snake'

local g = love.graphics


local MainSence = class('MainSence')

function MainSence:init()
	self.pos = {x = 80,y = 80}		-- 偏移位置
	self.unitsize = 40				-- 每个格子大小
	self.size = {x = 20,y = 16}		-- 有多少格子
	self.snake = Snake(self.size.x,self.size.y)

end

local function drawBox(x,y,size,color)
	local r, g, b, a = g.getColor()
	g.setColor(color.red, color.green, color.blue, color.alpha)
	g.rectangle('fill', x, y, size, size)
	g.setColor(135, 206, 235, 100)
	g.rectangle('line', x, y, size, size)
	g.rectangle('line', x+1, y+1, size-2, size-2)
	g.rectangle('line', x+2, y+2, size-4, size-4)
	g.rectangle('line', x+3, y+3, size-6, size-6)
	
	g.setColor(r, g, b, a)
end
MainSence.drawBox = drawBox

function MainSence:drawBlock(x,y)
	local x = self.pos.x + (x-1) * self.unitsize
	local y = self.pos.y + (y-1) * self.unitsize
	drawBox(x,y,self.unitsize,COLOR.red)

end

function MainSence:drawBorder()
	local x = 0
	
	local size = self.unitsize

	local y1 = self.pos.y - size
	local y2 = self.pos.y + self.size.y * size

	for i = 0 ,self.size.x do
		x = (i-1) * size + self.pos.x
		drawBox(x,y1,size,COLOR.blue)
		drawBox(x,y1,size,COLOR.blue)
	end
	y1 = self.pos.x -size
	y2 = self.pos.y + self.size.x * size
	for j = 0 ,self.size.y do
		x = self.pos.y + (j-1) * size
		drawBox(y1,x,size,COLOR.blue)
		drawBox(y2,x,size,COLOR.blue)
	end

	-- 画内部线方便对准
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(190, 190, 190, 30)
	for i = 2,(self.size.x - 1) do
		g.line(self.pos.x + i * size, self.pos.y, self.pos.x + i * size, self.pos.y + self.size.y * size)
	end
	for i = 2,(self.size.y - 1) do
		g.line(self.pos.x , self.pos.y+ i * size, self.pos.x + self.size.x * size, self.pos.y + i * size)
	end
	love.graphics.setColor(r, g, b, a)
end

function MainSence:drawSnake()
	local snake = self.snake
	for i = snake.tail,snake.head do
		self:drawBlock(snake[i].x,snake[i].y)
	end
	local food = s.food
	if food.state == true then
    	self:drawBlock(food.x,food.y)
    end

end
function MainSence:draw()
    self:drawBorder()
    self:drawSnake()
    
    self:drawState()
    --drawBlock(blockx,blocky)
    
end

function MainSence:keypressed(key)
    self.snake:keypressed(key)
end

function MainSence:update(dt)
	self.snake:update(dt)
end

function MainSence:drawState()
	local pausetext = {{0,255,0,100}," Pause "}
	local failtext = {{255,0,0,100},"You lose!!!!!"}
	local goaltext = {{255,0,0,100},"Wonderful!!You win!"}
	local snake = self.snake
	if snake.state == 'pause' then
		g.print(pausetext, 280, 300, 0, 5, 5)
	elseif snake.state == 'fail' then
		g.print(failtext, 220, 300, 0, 5, 5)
	elseif snake.state == 'goal' then
		g.print(goaltext, 100, 300, 0, 5, 5)
	end
end

return MainSence
