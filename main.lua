-- global imports
oo = require "oo"
flux = require "flux"
Anim = require "anim"
EntityList = require "entitylist"
signal = require "signal"

PlayScene = require "scenes.playscene"
MenuScene = require"scenes.menuscene"

CAT_GOAL = 1
CAT_WALL = 2
CAT_BALL = 3
CAT_PADDLE = 4

-- misc imports
local limitFrameRate = require "limitframerate"
local baton = require "baton"

local scene = {}
local nextScene = nil

function setScene(newScene)
	nextScene = newScene
end

function love.load()
	math.randomseed(os.time())
	lf = love.filesystem
	ls = love.sound
	la = love.audio
	lp = love.physics
	lt = love.thread
	li = love.image
	lg = love.graphics
	lm = love.mouse
	lj = love.joystick
	lw = love.window
	
	sounds = require "sounds"
	
	local p1controls = {
		-- primary movement controls
		left = {'axis:leftx-', 'button:dpleft', 'key:left'},
		right = {'axis:leftx+', 'button:dpright', 'key:right'},
		up = {'axis:lefty-', 'button:dpup', 'key:up'},
		down = {'axis:lefty+', 'button:dpdown', 'key:down'},
		-- secondary movement controls (rotation etc.)
		rotl = {'axis:rightx-', 'key:a'},
		rotr = {'axis:rightx+', 'key:d'},
		rotu = {'axis:righty-', 'key:w'},
		rotd = {'axis:righty+', 'key:s'},
		special = {'button:a', 'key:space'},
		cancel = {'button:b', 'key:2'}
	}
	
	local p2controls = {
		-- primary movement controls
		left = {'axis:leftx-', 'button:dpleft', 'key:j'},
		right = {'axis:leftx+', 'button:dpright', 'key:l'},
		up = {'axis:lefty-', 'button:dpup', 'key:i'},
		down = {'axis:lefty+', 'button:dpdown', 'key:k'},
		-- secondary movement controls (rotation etc.)
		rotl = {'axis:rightx-', 'key: o'},
		rotr = {'axis:rightx+', 'key: p'},
		rotu = {'axis:righty-'},
		rotd = {'axis:righty+'},
		special = {'button:a', 'key: 3'},
		cancel = {'button:b', 'key:4'}
	}
	
	p1input = baton.newPlayer(p1controls, lj.getJoysticks()[1])
	p2input = baton.newPlayer(p2controls, lj.getJoysticks()[2])
	
	setScene(MenuScene.new())
end

function love.update(dt)
	flux.update(dt)
	p1input:update()
	p2input:update()
	signal.emit("update", scene, dt)
	limitFrameRate(60)
	
	-- switch scene
	if nextScene then
		if scene.leave then scene:leave(nextScene) end
		if nextScene.enter then nextScene:enter(scene) end
		scene = nextScene
		nextScene = nil
	end
end

function love.draw()
	signal.emit("draw", scene)
end

function love.keypressed(key, scancode, isrepeat)
	signal.emit("keypressed", scene, key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function love.keyreleased(key, scancode)
	signal.emit("keyreleased", scene, key, scancode)
end

