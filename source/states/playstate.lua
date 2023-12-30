local camera = {
x = 0,
y = 0,
scale = 0.8
}

local placed = {}
local to_render = {}

local level_info = {
name = 'test',
act = 1,
size_width = 1280,
size_height = 1280
}

local function drawcurve(x1, y1, x2, y2, iterations, curvature)
    local tablex = {}
    local tabley = {}
    local curves = {}

    for i = 1, iterations+1 do
        local t = (i + curvature) / (curvature + (iterations - 1))
        tabley[i] = y1 + (y2 / iterations * (i - 1))
        tablex[i] = x1 + ((x2 / iterations) * (i - 1)) / t
    end

    for i = 1, iterations  do
        curves[i] = love.physics.newEdgeShape(tablex[i], tabley[i], tablex[i + 1], tabley[i + 1])
        table.insert(to_render, curves[i])
    end
end

local function drawedge(x1, y1, x2, y2)
	local edge = love.physics.newEdgeShape(x1, y1, x2 + x1, y2 + y1)
	table.insert(to_render, edge)
end

function love.keypressed( key, scancode, isrepeat )

end

local function load_level(level_name)
		for i,v in pairs(love.filesystem.getDirectoryItems('levels')) do
			if string.sub(v,0,-6) == level_name then
				local inside_file = love.filesystem.read('levels/'..v)
				local file_line = inside_file:split("\n")
				local text = file_line[1]
				inside_file = text:split("/")
				level_info.size_width = tonumber(inside_file[1])
				level_info.size_height = tonumber(inside_file[2])
				level_info.act = tonumber(inside_file[3])
				for i=2,#file_line-1 do 
					local text = file_line[i]
					inside_file = text:split("/")
					local edge_table
					for i=1,#inside_file do
						inside_file[i] = tonumber(inside_file[i])
					end
					if inside_file[6] ~= nil then
						edge_table = {id = inside_file[1],x1 = inside_file[2],y1 = inside_file[3],x2 = inside_file[4],y2 = inside_file[5],iterations = inside_file[6],curvature = inside_file[7]}
					else
						edge_table = {id = inside_file[1],x1 = inside_file[2],y1 = inside_file[3],x2 = inside_file[4],y2 = inside_file[5]}
					end
					table.insert(placed,edge_table)
				end
			end
		end
end

function love.load()
	load_level('hello_world')
end

local right 
local left 
local up 
local down 

function state_draw()
		
	right = love.keyboard.isDown('right')
	left = love.keyboard.isDown('left')
	up = love.keyboard.isDown('up')
	down = love.keyboard.isDown('down')
		
	to_render = {}
	for i,v in pairs(placed) do
		if v.curvature ~= nil then
			drawcurve(placed[i].x1, placed[i].y1, placed[i].x2, placed[i].y2, placed[i].iterations, placed[i].curvature)
		else
			drawedge(placed[i].x1, placed[i].y1, placed[i].x2, placed[i].y2)
		end
	end
	

	love.graphics.push()
	width, height = love.graphics.getDimensions( )
	
    love.graphics.translate(-camera.x, -camera.y)
	love.graphics.scale( camera.scale + width/initial_width - 1, camera.scale + width/initial_width - 1)

    for i, v in ipairs(to_render) do
        if v:getType() == "polygon" then
            love.graphics.polygon("line", v:getPoints())
        elseif v:getType() == "edge" then
            love.graphics.line(v:getPoints())
        else
            love.graphics.circle("line", v.x, v.y, v:getRadius())
        end
    end
	
	love.graphics.pop()
end

return state_draw