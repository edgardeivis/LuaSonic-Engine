local sonic_vars = {
	cur_action = 'stand',
	cur_frame = 1,
	cur_direction = 0,
	invert = 1,
	frame_delay = 0,
	x = 60,
	y = 0,
	x_speed = 0,
	y_speed = 0,
	ground_speed = 0,
	ground_angle = 0,
	on_ground = false
}
	
local constants = {
	acceleration_speed = 0.046875,
	deceleration_speed = 0.5,
	friction_speed = 0.046875,
	air_acceleration_speed = 0.09375,
	gravity_force = 0.21875,
	top_speed = 6,
	jump_force = 6.5
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
	-- World:update(dt)
end

local function drawcurve(x1, y1, x2, y2, iterations, curvature)
    local tablex = {}
    local tabley = {}
    local curves = {}

    for i = 1, iterations+1 do
        local t = (i + curvature) / (curvature + (iterations + 1))
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
	if (key == 'a' or key == 's') and sonic_vars.on_ground == true then
		sonic_vars.x_speed = sonic_vars.x_speed - constants.jump_force * math.sin(sonic_vars.ground_angle)	
		sonic_vars.y_speed = sonic_vars.y_speed - constants.jump_force * math.cos(sonic_vars.ground_angle)
		love.audio.newSource("assets/sounds/jump.mp3", "static"):play()
		sonic_vars.y = sonic_vars.y - 3
	end
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

local function state_load()
	love.physics.setMeter(1)
	
	World = love.physics.newWorld()
	Terrain = {}
	Terrain.Body = love.physics.newBody( World, 0, 0, 'static' )
	
	
	load_level('test_level')
end

state_load()

local right 
local left 
local up 
local down 
	
local function draw_sonic()

	right = love.keyboard.isDown('right')
	left = love.keyboard.isDown('left')
	up = love.keyboard.isDown('up')
	down = love.keyboard.isDown('down')
		
	if right then
		if sonic_vars.ground_speed < 0 then
			sonic_vars.ground_speed = sonic_vars.ground_speed + constants.deceleration_speed		
			if sonic_vars.ground_speed >= 0 then
				sonic_vars.ground_speed = 0.5
			end
		elseif sonic_vars.ground_speed < constants.top_speed then
			sonic_vars.ground_speed = sonic_vars.ground_speed + constants.acceleration_speed	
			sonic_vars.invert = 1
			if sonic_vars.ground_speed >= constants.top_speed then
				sonic_vars.ground_speed = constants.top_speed
			end
		end
	elseif left then
		if sonic_vars.ground_speed > 0 then
			sonic_vars.ground_speed = sonic_vars.ground_speed - constants.deceleration_speed		
			if sonic_vars.ground_speed <= 0 then
				sonic_vars.ground_speed = -0.5
			end
		elseif sonic_vars.ground_speed > -constants.top_speed then
			sonic_vars.ground_speed = sonic_vars.ground_speed - constants.acceleration_speed	
			sonic_vars.invert = -1
			if sonic_vars.ground_speed <= -constants.top_speed then
				sonic_vars.ground_speed = -constants.top_speed
			end
		end
	else
		sonic_vars.ground_speed = sonic_vars.ground_speed - math.min(math.abs(sonic_vars.ground_speed),constants.friction_speed) * sign(sonic_vars.ground_speed)
	end
	
	if sonic_vars.ground_speed ~= 0 then
		if sonic_vars.invert == -1 then
			if sonic_vars.ground_speed <= -constants.top_speed then
				sonic_vars.cur_action = 'run'
			else
				sonic_vars.cur_action = 'jog'
			end
		else
			if sonic_vars.ground_speed >= constants.top_speed then
				sonic_vars.cur_action = 'run'
			else
				sonic_vars.cur_action = 'jog'
			end
		end
	end
	--raycasting & collision stuff
	if sonic_vars.cur_direction == 0 then
		cast1 = World:rayCast(sonic_vars.x, sonic_vars.y+19, sonic_vars.x, sonic_vars.y+40, worldRayCastCallback)
		cast2 = World:rayCast(sonic_vars.x+17, sonic_vars.y+19, sonic_vars.x+17, sonic_vars.y+40, worldRayCastCallback)
		
		love.graphics.setLineWidth(2)
		love.graphics.setColor(1, 1, 1, .4)
		
		love.graphics.line(sonic_vars.x, sonic_vars.y+19, sonic_vars.x, sonic_vars.y+40)
		love.graphics.line(sonic_vars.x+17, sonic_vars.y+19, sonic_vars.x+17, sonic_vars.y+40)	
	elseif sonic_vars.cur_direction == 1 then
		cast1 = World:rayCast(sonic_vars.x+8, sonic_vars.y, sonic_vars.x+32, sonic_vars.y, worldRayCastCallback)
		cast2 = World:rayCast(sonic_vars.x+8, sonic_vars.y+17, sonic_vars.x+32, sonic_vars.y+17, worldRayCastCallback)
		
		love.graphics.setLineWidth(2)
		love.graphics.setColor(1, 1, 1, .4)
		
		love.graphics.line(sonic_vars.x+8, sonic_vars.y, sonic_vars.x+32, sonic_vars.y)
		love.graphics.line(sonic_vars.x+8, sonic_vars.y+17, sonic_vars.x+32, sonic_vars.y+17)	
	end
	love.graphics.setLineWidth(1)
	for i, hit in ipairs(ray_hitLists) do
		table.sort(ray_hitLists, function(a,b) return a.y < b.y end)
		if sonic_vars.cur_direction == 0 then
			sonic_vars.y = ray_hitLists[1].y-38
		elseif sonic_vars.cur_direction == 1 then
			sonic_vars.x = ray_hitLists[1].x-30
		end
		local angle_rad = math.atan2(ray_hitLists[1].xn ,ray_hitLists[1].yn)
		sonic_vars.ground_angle = math.floor( -(math.deg(angle_rad) - 180))
		love.graphics.setColor(1, 0, 0)
		love.graphics.circle("line", hit.x, hit.y, 3)
		love.graphics.setColor(0, 1, 0)
		love.graphics.line(hit.x, hit.y, hit.x + hit.xn * 25, hit.y + hit.yn * 25)
	end	
	print(sonic_vars.ground_angle)
	if (sonic_vars.ground_angle > 226 and sonic_vars.ground_angle < 314) then
		sonic_vars.cur_direction = 1
	else
		sonic_vars.cur_direction = 0
	end
	love.graphics.setColor(1, 1, 1)
	
	camera.x = sonic_vars.x*camera.scale - 400
	camera.y = sonic_vars.y*camera.scale - 250
	love.graphics.setColor(1, 0.25, 0.5,0.25)
	love.graphics.rectangle('fill',sonic_vars.x,sonic_vars.y+2,17,33)
	love.graphics.setColor(1, 1,1)
	local sonic_sprite = love.graphics.newImage('assets/sprites/sonic/'..sonic_vars.cur_action .. '.png')
	love.graphics.draw(sonic_sprite,love.graphics.newQuad(59*(sonic_vars.cur_frame-1),0,59,59, sonic_sprite),sonic_vars.x+7,sonic_vars.y+16, math.rad(sonic_vars.ground_angle) ,sonic_vars.invert,1,30,30,0,0)	--sorry for the mess
	if sonic_sprite:getWidth()/59 ~= 1 then
		if sonic_vars.frame_delay > 10/ math.abs(sonic_vars.ground_speed) then
			sonic_vars.frame_delay = 0
			sonic_vars.cur_frame = sonic_vars.cur_frame + 1
			if sonic_vars.cur_frame > sonic_sprite:getWidth()/59 then
				sonic_vars.cur_frame = 1
			end
		else
			sonic_vars.frame_delay = sonic_vars.frame_delay + 1
		end
	end
	if sonic_vars.x_speed ~= 0 then
		sonic_vars.x_speed = sonic_vars.x_speed - math.min(math.abs(sonic_vars.x_speed),constants.friction_speed) * sign(sonic_vars.x_speed)
	end
	
	if sonic_vars.y_speed > 16 then
		sonic_vars.y_speed = 16
	end
	
	if sonic_vars.cur_direction == 1 then
		sonic_vars.y = sonic_vars.y + -sonic_vars.ground_speed + sonic_vars.y_speed
		sonic_vars.x = sonic_vars.x + sonic_vars.x_speed	
	else
		sonic_vars.x = sonic_vars.x + sonic_vars.ground_speed + sonic_vars.x_speed
		sonic_vars.y = sonic_vars.y + sonic_vars.y_speed
	end
	
	if #ray_hitLists == 0 then
		sonic_vars.on_ground = false
	else
		sonic_vars.on_ground = true
	end
	
	if sonic_vars.on_ground == false then
		sonic_vars.y_speed = (sonic_vars.y_speed + constants.gravity_force)
	elseif sonic_vars.on_ground == true then
		sonic_vars.y_speed = 0
		if sonic_vars.ground_speed == 0 and sonic_vars.cur_action ~= 'stand' then
			sonic_vars.cur_frame = 1
			sonic_vars.cur_action = 'stand'
		end
	end
	ray_hitLists = {}


end
local createdFixtures = {}
function state_draw()

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
			 local fixture = createdFixtures[i] or love.physics.newFixture(Terrain.Body, v)
			 createdFixtures[i] = fixture
        else
            love.graphics.circle("line", v.x, v.y, v:getRadius())
        end
    end
	draw_sonic()
	love.graphics.pop()
end

return state_draw