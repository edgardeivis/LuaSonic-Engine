love.graphics.setDefaultFilter('nearest', 'nearest')
initial_width, initial_height = love.graphics.getDimensions( ) --idk if this is the best way to do this
imgui = require "cimgui"
ffi = require "ffi"
require "source.imguistuff"
statelibrary = require 'source.gamestate'

--thanks stackoverflow
function string:split( inSplitPattern, outResults )
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end


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

