current_state = nil

	
states = love.filesystem.getDirectoryItems('source/states')

function gamestate_switch(state)
	state_draw = require('source.states.'.. state)
	print('source.states.'.. state)
	current_state = state
end

function gamestate_draw()
	if current_state ~= nil then
		state_draw()
	end
end
