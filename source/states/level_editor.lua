local debug_render = true -- renders lines in-engine, instead of hiding them

require 'source.grids' -- code for rendering the grids, might move this to here instead of having it as it own .lua file
imgui = require 'imgui' --imgui related stuff
require 'source.inputsimgui'
require 'source.objects' --where all the objects are stored, not for a specific level, in general

local keybinds = {
	right,
	left,
	up,
	down,
	ctrl
}

local camera = {
	x = 0,
	y = 0,
	to_x = 0,
	to_y = 0,
	scale = 1
}

local editor_view = love.graphics.newCanvas(540,320)
local editor_cursor = {x = 0, y = 0}

local open_windows = {
	editor_view = true,
	object_properties = true,
	object_list = true,
	object_browser = true,
	startup_popup = false --for first time users
}

local placed = {	--separated by categories
	--lines # these two actually show up as the same category but are different objects
	line = {},
	curved_line = {},
	--interactibles
	object = {},
	ring = {}, -- # separated from objects so it's easier to tell when all rings have been collected
	--misc interactibles # stuff that just don't fit into regular interactibles/objects
	flag = {} --interaction flags, stuff the player can't see but do stuff when touched or something
}

local cur_selected 
local cur_snap = 16 -- the grid snap, default is 16, snaps to 1 , 4 , 8 , 16 , 32 , 64 , 128 and 256

local function save_level()

end

local function load_level()

end

local function drawcurve(x1, y1, x2, y2, iterations, curvature, selected)
    local tablex = {}
    local tabley = {}
    local curve = {}

    for i = 1, iterations+1 do
        local t = (i + curvature) / (curvature + (iterations +1))
        tabley[i] = y1 + (y2 / iterations * (i - 1))
        tablex[i] = x1 + ((x2 / iterations) * (i - 1)) / t
    end

	if selected then
		love.graphics.setColor(0,1,1)
	end
	
    for i = 1, iterations  do
        curve[i] = love.physics.newEdgeShape(tablex[i], tabley[i], tablex[i + 1], tabley[i + 1])
		love.graphics.line(curve[i]:getPoints())
    end
	
	love.graphics.setColor(1,1,1)	
	return curve
end

local function drawedge(x1, y1, x2, y2,selected)
	local edge = love.physics.newEdgeShape(x1, y1, x2 + x1, y2 + y1)
	
	if selected then
		love.graphics.setColor(0,1,1)
	end
	
	love.graphics.line(edge:getPoints())
	
	love.graphics.setColor(1,1,1)
	return edge
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
	love.audio.newSource('assets/sounds/editor_click.wav', 'static'):play()
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
	love.audio.newSource('assets/sounds/editor_release.wav', 'static'):play()
end


function love.keypressed( key, scancode, isrepeat )
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then

    end
end

local default_font
local function state_load()
	default_font = imgui.AddFontFromFileTTF('assets/CascadiaMono.ttf',14)
	love.audio.newSource('assets/sounds/editor_popup.wav', 'static'):play()
	open_windows.startup_popup = true
end

state_load()

function love.update(dt)
	imgui.NewFrame()
end

function love.quit()
    imgui.ShutDown();
end

local function camera_stuff()
	keybinds.right = love.keyboard.isDown('right')
	keybinds.left = love.keyboard.isDown('left')
	keybinds.up = love.keyboard.isDown('up')
	keybinds.down = love.keyboard.isDown('down')
	keybinds.ctrl = love.keyboard.isDown('lctrl')
	
	if keybinds.right then
		camera.to_x = camera.to_x + 3
	elseif keybinds.left then
		camera.to_x = camera.to_x - 3	
	end

	if keybinds.up then
		camera.to_y = camera.to_y + 3
	elseif keybinds.down then
		camera.to_y = camera.to_y - 3
	end
	
	camera.x = lerp(camera.x,camera.to_x,0.15)
	camera.y = lerp(camera.y,camera.to_y,0.15)
end

function imgui_stuff() --prepare yourself because readability in here can be tough
	imgui.PushStyleVar('ImGuiStyleVar_WindowTitleAlign',0.50,0.50)
	imgui.PushStyleVar('ImGuiStyleVar_WindowRounding',3)
	imgui.PushStyleVar('ImGuiStyleVar_TabRounding',3)
	imgui.PushStyleVar('ImGuiStyleVar_WindowBorderSize',0)
	imgui.PushFont(default_font)
	--popups
	if open_windows.startup_popup then
		imgui.OpenPopup('Welcome!')
		imgui.BeginPopupModal('Welcome!',nil,'ImGuiWindowFlags_AlwaysAutoResize')
			imgui.SetItemDefaultFocus()
			imgui.Text("It looks like it's your first time using LuaSonicEngine")
			imgui.Text('Check out the wiki if confused')
			imgui.Separator()
			if imgui.Button('Ok') then
				imgui.CloseCurrentPopup()
				open_windows.startup_popup = false
			end
			imgui.SameLine()
			if imgui.Button('Open Wiki') then
				love.system.openURL('https://github.com/edgardeivis/LuaSonic-Engine/wiki')
				imgui.CloseCurrentPopup()
				open_windows.startup_popup = false
			end
		imgui.EndPopup()
	end
	--main menu bar
	imgui.BeginMainMenuBar()
		if imgui.BeginMenu('File') then
			imgui.MenuItem('New')
			imgui.MenuItem('Open')
			imgui.MenuItem('Save')
			imgui.Separator()
			imgui.MenuItem('Settings')
			imgui.Separator()
			if imgui.MenuItem('Exit') then
				love.event.quit()
			end			
			imgui.EndMenu()
		end
		
		if imgui.BeginMenu('Edit') then
			imgui.MenuItem('placeholder')
			imgui.EndMenu()
		end	
		
		if imgui.BeginMenu('View') then
			if imgui.MenuItem('Editor View',nil,open_windows.editor_view) then
				open_windows.editor_view = not open_windows.editor_view
			end
			if imgui.MenuItem('Object Properties',nil,open_windows.object_properties) then
				open_windows.object_properties = not open_windows.object_properties
			end
			if imgui.MenuItem('Object List',nil,open_windows.object_list) then
				open_windows.object_list = not open_windows.object_list
			end
			if imgui.MenuItem('Object Browser',nil,open_windows.object_browser) then	
				open_windows.object_browser = not open_windows.object_browser
			end
			imgui.EndMenu()
		end
		if imgui.BeginMenu('Help') then
			if imgui.MenuItem('Wiki') then
				love.system.openURL('https://github.com/edgardeivis/LuaSonic-Engine/wiki')
			end
			if imgui.MenuItem('Issues') then
				love.system.openURL('https://github.com/edgardeivis/LuaSonic-Engine/issues')
			end
			imgui.EndMenu()
		end	
		
		imgui.SetCursorPosX(initial_width/2 - imgui.CalcTextSize('LuaSonicEngine - Level Editor')/2)
		imgui.Text('LuaSonicEngine - Level Editor')
		
	imgui.EndMainMenuBar()
	--status bar
	imgui.SetNextWindowPos(0,initial_height - 30)
	imgui.SetNextWindowSize(initial_width,30)
	
	imgui.PushStyleVar('ImGuiStyleVar_WindowRounding', 0)
	
	imgui.Begin('##Status Bar', nil, {'ImGuiWindowFlags_NoTitleBar','ImGuiWindowFlags_NoResize','ImGuiWindowFlags_NoMove','ImGuiWindowFlags_NoScrollbar','ImGuiWindowFlags_NoSavedSettings'})
		imgui.Text('ver 0.1.0 - developed by edgardeivis')
		imgui.SameLine()
		imgui.Text('| FPS: '.. love.timer.getFPS())
	imgui.End()
	
	imgui.PopStyleVar()
	--object Browser
	if open_windows.object_browser then
		imgui.Begin('Object Browser',nil,'ImGuiWindowFlags_HorizontalScrollbar')
			for i,v in ipairs(objects) do			
				imgui.BeginGroup()
					if imgui.ImageButton(v.sprite ,64,64) then
						local new_object = {}
						for i2,v2 in pairs(v.values) do
							new_object[i2] = {}
							new_object[i2][1] = v2[1] --value
							new_object[i2][2] = v2[2] --type
							if i2 == 'name' then
								new_object[i2][1] = v2[1] .. #placed[v.category]
							end							
						end
						table.insert(placed[v.category],new_object)
					end
					if imgui.IsItemHovered() then
						imgui.SetTooltip(v.name..'\ncategory:'..v.category)
					end
					imgui.SetWindowFontScale(0.8)
					imgui.Text(v.name)
				imgui.EndGroup()
				imgui.SameLine()
				imgui.SetWindowFontScale(1)
			end
		imgui.End()
	end
	--editor view window
	if open_windows.editor_view then
		imgui.Begin('Editor View',nil,{'ImGuiWindowFlags_AlwaysAutoResize','ImGuiWindowFlags_NoDocking'})
			imgui.BeginChild('##inside_view',540,320,false,{'ImGuiWindowFlags_NoMove','ImGuiWindowFlags_NoScrollbar','ImGuiWindowFlags_NoScrollWithMouse'})
				imgui.Image(editor_view,540,320)
				--get cursor position relative to window
				local cursor_x,cursor_y = love.mouse.getPosition()
				local window_x,window_y = imgui.GetWindowPos()
				editor_cursor.x = cursor_x - window_x + camera.x
				editor_cursor.y = cursor_y - window_y - camera.y
			imgui.EndChild()
		imgui.End()
	end
	--object list
	if open_windows.object_list then
		imgui.SetNextWindowSize(200,380)
		imgui.Begin('Object List',nil)
			if imgui.TreeNodeEx('Collision') then --lines and curved lines
					for i,v in ipairs(placed.line) do
						if cur_selected == v then v.selected = true else v.selected = false end
						if imgui.Selectable(v.name[1],v.selected) then
							if cur_selected == v then cur_selected = nil else cur_selected = v end
						end
					end
					for i,v in ipairs(placed.curved_line) do
						if cur_selected == v then v.selected = true else v.selected = false end
						if imgui.Selectable(v.name[1],v.selected) then
							if cur_selected == v then cur_selected = nil else cur_selected = v end
						end
					end					
				imgui.TreePop()
			end
			imgui.Separator()
			if imgui.TreeNodeEx('Objects') then
				if imgui.TreeNodeEx('Rings') then
					imgui.TreePop()
				end
				imgui.TreePop()
			end
			imgui.Separator()
			if imgui.TreeNodeEx('Misc') then 
				if imgui.TreeNodeEx('Flags') then
					imgui.TreePop()
				end
				imgui.TreePop()	
			end			
			imgui.Separator()
		imgui.End()
	end
	--object properties
	if open_windows.object_properties then
		imgui.SetNextWindowSize(200,380)
		imgui.Begin('Object Properties',nil)
			if cur_selected ~= nil then
				for i,v in pairs(cur_selected) do
					if type(v) == 'table' then
						if v[2] == 'string' then
							imgui.Text(i); imgui.SameLine()
							imgui.InputText('##'..i, v[1],32);
						elseif v[2] == 'integer' then
							imgui.Text(i); imgui.SameLine()
							imgui.InputInt('##'..i, v[1],32);
						end
					end
				end
			end
		imgui.End()
	end
	imgui.Render()
end

local ghz = love.graphics.newImage('assets/sprites/editor/ui/greenhillzone.png')
local test = love.graphics.newImage('assets/sprites/editor/ui/point_closed.png')

function state_draw()
	love.graphics.setBackgroundColor(0.8,0.8,0.8,1)
	love.graphics.draw(ghz,0,0)
	
	camera_stuff()
	
	love.graphics.setCanvas(editor_view)
	love.graphics.clear(0,0,0)
	
	love.graphics.push()
	
    love.graphics.translate(-camera.x, camera.y)
	grids_draw()
	for i,v in pairs(placed.line) do
		drawedge(v.x1[1],v.y1[1],v.x2[1],v.y2[1],v.selected)
	end
	
	for i,v in pairs(placed.curved_line) do
		drawcurve(v.x1[1],v.y1[1],v.x2[1],v.y2[1],v.iterations[1],v.curvature[1],v.selected)
	end	
	
	love.graphics.draw(test,editor_cursor.x,editor_cursor.y)
	
	love.graphics.pop()
	
	love.graphics.setCanvas()
	
	imgui_stuff()
	
end

return state_draw