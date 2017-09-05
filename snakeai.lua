--[[ ai to find way
	需要使用snake的list，head，tail，food数据
	写入了snake的list.headDirection
--]] 

local  class = require 'lib.simpleclass'
local SnakeAI = class('SnakeAI')

function SnakeAI:init()
	-- body
end


-- 让ai查找下一个点
function SnakeAI:getNextPoint(snake)
	-- 最简单的ai，先横再纵往目标点走，不能走在旁边先挑一个可以走的地方走
	local list = snake.list
	local pos = {x = list[list.head].x,y = list[list.head].y}
	local turns = {}
	local food = snake.food
	if food.x == nil then
		return nil
	end

	if food.x > pos.x and food.y > pos.y then
		turns = {'right','down','left','up'}
	elseif food.x == pos.x and food.y > pos.y then
		turns = {'down','right','left','up'}
	elseif food.x > pos.x and food.y < pos.y then
		turns = {'right','up','left','down'}
	elseif food.x == pos.x and food.y < pos.y then
		turns = {'up','right','left','down'}
	elseif food.x > pos.x and food.y == pos.y then
		turns = {'right','down','up','left'}
	elseif food.x < pos.x and food.y > pos.y then
		turns = {'left','down','right','up'}
	elseif food.x < pos.x and food.y < pos.y then
		turns = {'left','up','right','down'}
	elseif food.x < pos.x and food.y == pos.y then
		turns = {'left','up','down','right'}
	end
	
	for i,v in ipairs(turns) do 
		SceneManager.info(v)
		if v == 'right' then 
			if snake:getPS(pos.x+1,pos.y) == 'blank' or snake:getPS(pos.x+1,pos.y) == 'food' then
				list.headDirection = v
				pos.x = pos.x + 1
				return pos
			end
		elseif v == 'left' then 
			if snake:getPS(pos.x-1,pos.y) == 'blank' or snake:getPS(pos.x-1,pos.y) == 'food' then
				list.headDirection = v
				pos.x = pos.x - 1
				return pos
			end
		elseif v == 'down' then 
			if snake:getPS(pos.x,pos.y+1) == 'blank' or snake:getPS(pos.x,pos.y+1) == 'food' then
				list.headDirection = v
				pos.y = pos.y + 1
				return pos
			end
		elseif v == 'up' then
			if snake:getPS(pos.x,pos.y-1) == 'blank' or snake:getPS(pos.x,pos.y-1) == 'food' then
				list.headDirection = v
				pos.y = pos.y - 1
				return pos
			end
		end
	end

end

return SnakeAI
