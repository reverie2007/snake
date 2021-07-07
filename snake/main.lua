
local  MainScene = require 'mainscene'
local StartScene = require 'startscene'

SceneManager = {}

function SceneManager.draw()	
	if SceneManager.scene then
		SceneManager.scene:draw()
	end
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

