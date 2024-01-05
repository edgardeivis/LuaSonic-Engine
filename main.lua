love.graphics.setDefaultFilter('nearest', 'nearest')
initial_width, initial_height = love.graphics.getDimensions( ) --idk if this is the best way to do this
ffi = require "ffi"
statelibrary = require 'source.gamestate'

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

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

	love.graphics.print('FPS: '.. love.timer.getFPS() , 10, 10)
	gamestate_draw()

end

