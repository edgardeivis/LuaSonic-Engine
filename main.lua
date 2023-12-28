love.graphics.setDefaultFilter('nearest', 'nearest')
initial_width, initial_height = love.graphics.getDimensions( ) --idk if this is the best way to do this
imgui = require "cimgui"
ffi = require "ffi"
require "source.grids"
require "source.imguistuff"
statelibrary = require 'source.gamestate'

function loadgame()
	for i, v in pairs(states) do
		print('state'..i..': '..v)
	end
    gamestate_switch('level_editor')
end

loadgame()

function love.draw()
	gamestate_draw()
end

