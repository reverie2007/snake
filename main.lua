
local  MainScene = require 'mainscene'
local StartScene = require 'startscene'

SceneManager = {}
SceneManager.text = 'test'
function SceneManager.info(text)
	SceneManager.text = text
end


function SceneManager.draw()	
	if SceneManager.scene then
		SceneManager.scene:draw()
	end
	local str = {{255,0,0,100},SceneManager.text}
	love.graphics.print(str,100,10,0,2,2)
end
function SceneManager.update(dt)	
	if SceneManager.scene then
		SceneManager.scene:update(dt)
	end
end

function SceneManager.keypressed(key)	
	if SceneManager.scene then
		SceneManager.scene:keypressed(key)
	end
end

function love.load()
	s = StartScene()
	SceneManager.startscene = s

	--mains = MainScene()
	SceneManager.scene = s
end
love.draw = SceneManager.draw
love.update = SceneManager.update
love.keypressed = SceneManager.keypressed

