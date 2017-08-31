
local  class = require 'lib.simpleclass'
local COLOR = require 'lib.predefinedcolor'
local  MainScene = require 'mainscene'

local lg = love.graphics


local StartScene = class('StartScene')

function StartScene:init()
	img = lg.newImage('res/start.jpg')
end

function StartScene:draw()
    local text = {{255,0,0,100},"Press Space to start!"}
	lg.draw(img)
	lg.print(text, 100, 200, 0, 4, 4)
	
    --drawBlock(blockx,blocky)
    
end

function StartScene:keypressed(key)
    if key == 'escape' then
    	love.event.quit()
    elseif key == 'space' then
    	SceneManager.mainscene = SceneManager.mainscene or MainScene()
    	SceneManager.scene = SceneManager.mainscene
    end
end

function StartScene:update(dt)
	
end

return StartScene
