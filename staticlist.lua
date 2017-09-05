--[[
	静态列表，包含一个list表，一个head和一个tail一个length表示长度
--]]
local class = require 'lib.simpleclass'

local StaticList = class('StaticList')

function StaticList:init()
	self.list = {}
	self.head = 0
	self.tail = 0
	self.length = 0
end
--[[
	在头部插入数据
--]]
function StaticList:push(data)
	self.head = self.head + 1
	self.list[self.head] = data
	self.length = self.length + 1
end
--[[
	弹出头部数据，如果列表为空，返回nil
--]]
function StaticList:pop()
	if (self.head <= self.tail) then 
		return nil
	end
	local h = self.list[self.head]
	self.list[self.head] = nil
	self.head = self.head - 1
	self.length = self.length - 1
	return h
end
--[[
	从尾部插入数据
--]]
function StaticList:append(data)
	self.list[self.tail] = data
	self.tail = self.tail - 1
	self.length = self.length + 1
end

return StaticList