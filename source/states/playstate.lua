local sonic_vars = {
	x = 60,
	y = 0,
	x_speed = 0,
	y_speed = 0,
	on_ground = false
}
	
local constants = {
	air_acceleration_speed = 0.09375,
	gravity_force = 0.21875,
	top_speed = 6
}	

local ray_hitLists = {}

function worldRayCastCallback(fixture, x, y, xn, yn, fraction)

	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x, y
	hit.xn, hit.yn = xn, yn
	hit.fraction = fraction

	table.insert(ray_hitLists, hit)

	return 1 -- Continues with ray cast through all shapes.
end


local camera = {
	x = 0,
	y = 0,
	scale = 1.8
}

local placed = {}
local to_render = {}

local level_info = {
	name = 'test',
	act = 1,
	size_width = 1280,
	size_height = 1280
}

function love.update(dt)
	World:update(dt)
	sonic_vars.x = sonic_vars.x + sonic_vars.x_speed
	sonic_vars.y = sonic_vars.y + sonic_vars.y_speed
end

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
	love.physics.setMeter(1)
	
	World = love.physics.newWorld()
	Terrain = {}
	Terrain.Body = love.physics.newBody( World, 0, 0, 'static' )
	
	
	load_level('test_level')
end



	
local function draw_sonic()

	if #ray_hitLists == 0 then
		sonic_vars.on_ground = false
	else
		sonic_vars.on_ground = true
	end
	
	love.graphics.rectangle('line',sonic_vars.x,sonic_vars.y+2,17,33)
	
	camera.x = sonic_vars.x
	camera.y = sonic_vars.y
	
	if sonic_vars.y_speed > 16 then
		sonic_vars.y_speed = 16
	end
	
	
	if sonic_vars.on_ground == false then
		sonic_vars.y_speed = (sonic_vars.y_speed + constants.gravity_force)
	elseif sonic_vars.on_ground == true then
		sonic_vars.y_speed = 0
	end

	

	

	--raycasting & collision stuff
	ray_hitLists = {}
	
	cast1 = World:rayCast(sonic_vars.x, sonic_vars.y+19, sonic_vars.x, sonic_vars.y+38, worldRayCastCallback)
	cast2 = World:rayCast(sonic_vars.x+17, sonic_vars.y+19, sonic_vars.x+17, sonic_vars.y+38, worldRayCastCallback)
	
	love.graphics.setLineWidth(2)
	love.graphics.setColor(1, 1, 1, .4)
	love.graphics.line(sonic_vars.x, sonic_vars.y+19, sonic_vars.x, sonic_vars.y+38)
	love.graphics.line(sonic_vars.x+17, sonic_vars.y+19, sonic_vars.x+17, sonic_vars.y+38)	
	love.graphics.setLineWidth(1)

	for i, hit in ipairs(ray_hitLists) do
		love.graphics.setColor(1, 0, 0)
		love.graphics.circle("line", hit.x, hit.y, 3)
		love.graphics.setColor(0, 1, 0)
		love.graphics.line(hit.x, hit.y, hit.x + hit.xn * 25, hit.y + hit.yn * 25)
	end	
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
	love.graphics.setColor(1, 1, 1)
	for i,v in pairs(placed) do
		if v.curvature ~= nil then
			drawcurve(placed[i].x1, placed[i].y1, placed[i].x2, placed[i].y2, placed[i].iterations, placed[i].curvature)
		else
			drawedge(placed[i].x1, placed[i].y1, placed[i].x2, placed[i].y2)
		end
	end
	


	width, height = love.graphics.getDimensions( )
	
    love.graphics.translate(-camera.x, -camera.y)
	love.graphics.scale( camera.scale + width/initial_width - 1, camera.scale + width/initial_width - 1)

	love.graphics.push()
    for i, v in ipairs(to_render) do
        if v:getType() == "polygon" then
            love.graphics.polygon("line", v:getPoints())
		
        elseif v:getType() == "edge" then
            love.graphics.line(v:getPoints())
			love.physics.newFixture(Terrain.Body , v)
			-- i have to create a fixture somehow
        else
            love.graphics.circle("line", v.x, v.y, v:getRadius())
        end
    end
	draw_sonic()
	love.graphics.pop()
end

return state_draw