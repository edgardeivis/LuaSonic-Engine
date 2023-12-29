require "source.grids"
local appdata_location = love.filesystem.getAppdataDirectory()

local folder = love.filesystem.createDirectory("exported_levels")

local camera = {
x = 0,
y = 0,
scale = 1
}

local iterations_slider
local curvature_slider
local line_xy = {x1=90,y1=360,x2=360,y2=-180}
local placed = {}
local to_render = {}
local selected_line

local level_info = {
name = ffi.new("char[32]"),
act = ffi.new("int[0]"),
size_width = ffi.new("int[0]"),
size_height = ffi.new("int[0]")
}

local function save_level()
	lvl_name = ffi.string(level_info.name)
	local file = love.filesystem.newFile('exported_levels/'.. lvl_name ..'.lslv')
	local text_to_save = ''
	for i,v in pairs(placed) do
		if placed[i].curvature ~= nil then
			text_to_save = text_to_save .. tostring(placed[i].id .. '/' .. placed[i].x1 .. '/' .. placed[i].y1 .. '/' .. placed[i].x2 .. '/' .. placed[i].y2 .. '/' .. placed[i].iterations .. '/' .. placed[i].curvature .. '\n')			
		else
			text_to_save = text_to_save .. tostring(placed[i].id .. '/' .. placed[i].x1 .. '/' .. placed[i].y1 .. '/' .. placed[i].x2 .. '/' .. placed[i].y2 .. '\n')
		end
	end
	love.filesystem.write('exported_levels/'..lvl_name..'.lslv',text_to_save)
end


function love.keypressed( key, scancode, isrepeat )
    imgui.love.KeyPressed(key)
    if not imgui.love.GetWantCaptureKeyboard() then
		if selected_line ~= nil then
			if key == 'delete' then
				table.remove(placed, selected_line.id)
				selected_line = nil
			elseif key == 'escape' then
				selected_line = nil
			end
		end
    end
end

function love.load()
    imgui.love.Init()
    iterations_slider = ffi.new("int[0]")
    curvature_slider = ffi.new("float[0]")
	line_xy.x1 = ffi.new("int[0]")
	line_xy.y1 = ffi.new("int[0]")
	line_xy.x2 = ffi.new("int[0]")
	line_xy.y2 = ffi.new("int[0]")	
    iterations_slider[0] = 8
    curvature_slider[0] = 1
	line_xy.x2[0] = 64
	line_xy.y2[0] = -64
	level_info.name[0] = 0
	level_info.act[0] = 1
	level_info.size_width[0] = 1280
	level_info.size_height[0] = 1280
	imgui.GetIO().ConfigFlags = 64
end

function love.update(dt)
    imgui.love.Update(dt)
    imgui.NewFrame()
end

function create_line_editor_window()
    -- line editor window
	imgui.SetNextWindowSize({350, 130}, imgui.ImGuiCond_FirstUseEver)
	imgui.SetNextWindowPos({436, 32}, imgui.ImGuiCond_FirstUseEver)
	imgui.Begin("line #".. selected_line.id,nil,256)
	if selected_line.curvature ~= nil then
		imgui.PushItemWidth(236)
		imgui.SliderInt("##iterations", iterations_slider, 1, 64); imgui.SameLine()
		imgui.Text("Iterations")	
		imgui.SliderFloat("##curvature", curvature_slider, 0, 64); imgui.SameLine()
		imgui.Text("Curvature")
	end
	imgui.PushItemWidth(114)
	imgui.InputInt("##X1", line_xy.x1,1, 8); imgui.SameLine()
	imgui.InputInt("##Y1", line_xy.y1,1, 8); imgui.SameLine()
	imgui.Text("Initial Pos")
	imgui.InputInt("##X2", line_xy.x2,1, 8); imgui.SameLine()
	imgui.InputInt("##Y2", line_xy.y2,1, 8); imgui.SameLine()
	imgui.Text("End Pos")
	if curvature_slider[0] < 0 then
		imgui.TextColored({1, 0, 0, 1}, "I wouldn't recommend using negative numbers")
	end
	imgui.End() 
end

function imgui_stuff()
	--object browser
	imgui.SetNextWindowSize({160, 400},imgui.ImGuiCond_FirstUseEver)
	imgui.SetNextWindowPos({620, 180},imgui.ImGuiCond_FirstUseEver)
	imgui.Begin("object list")
		for i,v in pairs(placed) do
			local is_selected
			if selected_line == placed[i] then
				is_selected = true
			else
				is_selected = false
			end
			if imgui.Selectable_Bool("line #".. placed[i].id,is_selected) then
				if placed[i].curvature ~= nil then
					iterations_slider[0] = placed[i].iterations
					curvature_slider[0] = placed[i].curvature
				end
				line_xy.x1[0] = placed[i].x1
				line_xy.y1[0] = placed[i].y1
				line_xy.x2[0] = placed[i].x2
				line_xy.y2[0] = placed[i].y2
				selected_line = placed[i]
			end
		end
	imgui.End() 
	--------------------------
	-- level settings
	imgui.Begin('Settings')
		imgui.SetNextWindowSize({350, 130}, imgui.ImGuiCond_FirstUseEver)
		imgui.SetNextWindowPos({32, 32}, imgui.ImGuiCond_FirstUseEver)
		imgui.PushItemWidth(236)
		imgui.InputText("##Name", level_info.name,32); imgui.SameLine()
		imgui.Text("Level Name")
		imgui.PushItemWidth(114)
		if imgui.InputInt("##lvl_width", level_info.size_width,32,128) then
			grids_load(level_info.size_width[0],level_info.size_height[0])
		end
			imgui.SameLine()
		if imgui.InputInt("##lvl_height", level_info.size_height,32,128) then
			grids_load(level_info.size_width[0],level_info.size_height[0])
		end
		imgui.SameLine()

		imgui.Text("Level Borders")
		if level_info.size_width[0] < 0 or level_info.size_height[0] < 0 then
			imgui.TextColored({1, 0, 0, 1}, "I wouldn't recommend using negative numbers")
		end
	imgui.End()
	--------------------------
	-- menu bar
	imgui.BeginMainMenuBar()
	if imgui.BeginMenu('File') then

		if imgui.MenuItem_Bool('New') then
			--maybe will remove
		end
		if imgui.MenuItem_Bool('Open') then
			--will replace by just draggin file
		end
		if imgui.MenuItem_Bool('Save') then
			if ffi.string(level_info.name) ~= '' then
				save_level()			
			end

		end
		if imgui.MenuItem_Bool('Exit Editor') then
		end
	imgui.EndMenu()
	end
	
	if imgui.BeginMenu('Editor') then

		if imgui.MenuItem_Bool('add line') then
			local edge_table = {id = #placed+1,x1 = 32,y1 = 32,x2 = 64,y2 = -64}
			table.insert(placed, edge_table)
			selected_line = placed[#placed]		
		end
		
		if imgui.MenuItem_Bool('add curved line') then
			local curve_table = {id = #placed+1,x1 = 32,y1 = 32,x2 = 64,y2 = -64,iterations = 8,curvature = 1}
			table.insert(placed, curve_table)
			selected_line = placed[#placed]
		end
		
		imgui.MenuItem_Bool('object browser')
		
		if imgui.MenuItem_Bool('reset camera') then
			camera.x = 0
			camera.y = 0
			camera.scale = 1	
		end
	imgui.EndMenu()
	end
	
	imgui.EndMainMenuBar()
	--------------------------

	--------------------------
	if selected_line ~= nil then
		create_line_editor_window()
	end
    -- code to render imgui
    imgui.Render()
    imgui.love.RenderDrawLists()
end



function drawcurve(x1, y1, x2, y2, iterations, curvature)
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

function drawedge(x1, y1, x2, y2)
	local edge = love.physics.newEdgeShape(x1, y1, x2 + x1, y2 + y1)
	table.insert(to_render, edge)
end

local right 
local left 
local up 
local down 
local ctrl

local x, y
local x_editor
local y_editor
	
function state_draw()
	x, y = love.mouse.getPosition()
	x_editor = (x+camera.x)/camera.scale
	y_editor = (y+camera.y)/camera.scale
	
	
	right = love.keyboard.isDown('right')
	left = love.keyboard.isDown('left')
	up = love.keyboard.isDown('up')
	down = love.keyboard.isDown('down')
	ctrl = love.keyboard.isDown('lctrl')
	
	if right then
		camera.x = camera.x + 5 
	elseif left then
		camera.x = camera.x - 5 		
	end
	
	
	to_render = {}
	if selected_line ~= nil then
		selected_line.x1 = line_xy.x1[0]
		selected_line.y1 = line_xy.y1[0]
		selected_line.x2 = line_xy.x2[0]
		selected_line.y2 = line_xy.y2[0]		
		if selected_line.curvature ~= nil then
			selected_line.curvature = curvature_slider[0]
			selected_line.iterations = iterations_slider[0]
		end
	end
	for i,v in pairs(placed) do
		if v.curvature ~= nil then
			drawcurve(placed[i].x1, placed[i].y1, placed[i].x2, placed[i].y2, placed[i].iterations, placed[i].curvature)
		else
			drawedge(placed[i].x1, placed[i].y1, placed[i].x2, placed[i].y2)
		end
	end
	

	
	if not ctrl then
		if up then
			camera.y = camera.y - 5 
		elseif down then
			camera.y = camera.y + 5 		
		end
	else
		if up then
			camera.scale = camera.scale - 0.01 
			camera.x = camera.x - 4 
			camera.y = camera.y - 3 
		elseif down then
			camera.scale = camera.scale + 0.01 		
			camera.x = camera.x + 4 
			camera.y = camera.y + 3 
		end
	end
	
    love.graphics.push()
	width, height = love.graphics.getDimensions( )
	
    love.graphics.translate(-camera.x, -camera.y)
	love.graphics.scale( camera.scale + width/initial_width - 1, camera.scale + width/initial_width - 1)
	grids_draw()

    love.graphics.setColor(1, 1, 1)
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
	imgui_stuff()

	love.graphics.print( math.floor(x_editor + 0.5) .. ',' .. math.floor(y_editor +0.5) .. ' | ' .. camera.scale,7,580)
end

return state_draw