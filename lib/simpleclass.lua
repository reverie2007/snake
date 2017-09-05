--[[ SimpleClass
	简单的单一继承类,single inheritance,
--]]

local SimpleClass = {
	_VERSION = 0.1;
	_DESCREPTION = [===[
		Wang Hongwei, email: 525269029@qq.com
	]===];
}

local function isValidClassName(name)
	-- 什么是合法的类名呢，有没有必要检测类名称
	if type(name) == 'string' then
		local s = string.match(name,"[_%a][_%w]*")
		if (s == name) then
			return true
		end
	end
	return false
end

local function isClass(c)
	if type(c) == 'table' and c._TYPE =='SimpleClass' then
		return true
	else
		return false
	end
end

local function creatclass(classname,baseclass)

	if not isValidClassName(classname) then error("invalid class name") end

	if baseclass and (not isClass(baseclass)) then error(tostring(baseclass)..'is not a valid class') end

	local cls = {}
	cls._TYPE = 'SimpleClass'	-- 使用SimpleClass创建的类都添加标识，有这个标识就可以用作基类
	cls._VERSION = SimpleClass._VERSION
	cls._CLASSNAME = classname	--类名起什么作用呢，怎样区分不同包里相同的类名,尤其在is_a中
	cls.is_a = {}
	cls.is_a[cls] = true
	--cls.is_a[cls._CLASSNAME] = true

	local mt = {__call = function(c,...)
		local ins = {}
		setmetatable(ins,{__index = c})
		-- 构造函数
		local init = c.init
		if init and type(init) == "function" then
			init(ins,...)
		end
		return ins
	end}

	if baseclass then
		mt.__index = baseclass	--
		cls.base = baseclass
		-- 将基类的is_a复制到新类中
		for k,v in pairs(baseclass.is_a) do
			cls.is_a[k] = true
		end
	end

	setmetatable(cls,mt)
	return cls
end

setmetatable(SimpleClass,{__call = function(c,...) return creatclass(...) end})

return SimpleClass
