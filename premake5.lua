-- Copyright (c) 2020-2024 Jeffery Myers
--
--This software is provided "as-is", without any express or implied warranty. In no event 
--will the authors be held liable for any damages arising from the use of this software.

--Permission is granted to anyone to use this software for any purpose, including commercial 
--applications, and to alter it and redistribute it freely, subject to the following restrictions:

--  1. The origin of this software must not be misrepresented; you must not claim that you 
--  wrote the original software. If you use this software in a product, an acknowledgment 
--  in the product documentation would be appreciated but is not required.
--
--  2. Altered source versions must be plainly marked as such, and must not be misrepresented
--  as being the original software.
--
--  3. This notice may not be removed or altered from any source distribution.

newoption
{
    trigger = "graphics",
    value = "OPENGL_VERSION",
    description = "version of OpenGL to build raylib against",
    allowed = {
        { "opengl11", "OpenGL 1.1"},
        { "opengl21", "OpenGL 2.1"},
        { "opengl33", "OpenGL 3.3"},
        { "opengl43", "OpenGL 4.3"},
        { "opengles2", "OpenGLES 2.0"},
        { "opengles3", "OpenGLES 3.0"}
    },
    default = "opengl33"
}

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function link_to(lib)
    links (lib)
    includedirs ("../"..lib.."/include")
    includedirs ("../"..lib.."/" )
end

function download_progress(total, current)
    local ratio = current / total;
    ratio = math.min(math.max(ratio, 0), 1);
    local percent = math.floor(ratio * 100);
    print("Download progress (" .. percent .. "%/100%)")
end

function check_raylib()
    if(os.isdir("raylib") == false and os.isdir("raylib-master") == false) then
        if(not os.isfile("raylib-master.zip")) then
            print("Raylib not found, downloading from github")
            local result_str, response_code = http.download("https://github.com/raysan5/raylib/archive/refs/heads/master.zip", "raylib-master.zip", {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping to " ..  os.getcwd())
        zip.extract("raylib-master.zip", os.getcwd())
        os.remove("raylib-master.zip")
    end
end

function check_imgui()
	if(os.isdir("imgui") == false and os.isdir("imgui-master") == false) then
		if(not os.isfile("imgui-master.zip")) then
			print("imgui not found, downloading from github")
			local result_str, response_code = http.download("https://github.com/ocornut/imgui/archive/refs/heads/master.zip", "imgui-master.zip", {
				progress = download_progress,
				headers = { "From: Premake", "Referer: Premake" }
			})
		end
		print("Unzipping to " ..  os.getcwd())
		zip.extract("imgui-master.zip", os.getcwd())
		os.remove("imgui-master.zip")
	end
end


workspaceName = path.getbasename(os.getcwd())

if (string.lower(workspaceName) == "raylib") then
    print("raylib is a reserved name. Name your project directory something else.")
    -- Project generation will succeed, but compilation will definitely fail, so just abort here.
    os.exit()
end

workspace (workspaceName)
    configurations { "Debug", "Release"}
    platforms { "x64", "x86", "ARM64"}

    defaultplatform ("x64")

    filter "configurations:Debug"
        defines { "DEBUG" }
        symbols "On"

    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"

    filter { "platforms:x64" }
        architecture "x86_64"

    filter { "platforms:Arm64" }
        architecture "ARM64"

    filter {}

    targetdir "bin/%{cfg.buildcfg}/"


cdialect "C99"
cppdialect "C++17"
check_raylib();
check_imgui();

include ("raylib_premake5.lua")

project "rlImGui"
	kind "StaticLib"
	location "build"
	targetdir "bin/%{cfg.buildcfg}"
	language "C++"
	cdialect "C99"
	cppdialect "C++17"
	include_raylib()
	includedirs { "rlImGui", "imgui", "imgui-master"}
	vpaths 
	{
		["Header Files"] = { "*.h"},
		["Source Files"] = {"*.cpp"},
		["ImGui Files"] = { "imgui/*.h","imgui/*.cpp", "imgui-master/*.h","imgui-master/*.cpp" },
	}
	files {"imgui-master/*.h", "imgui-master/*.cpp", "imgui/*.h", "imgui/*.cpp", "*.cpp", "*.h", "extras/**.h"}

	defines {"IMGUI_DISABLE_OBSOLETE_FUNCTIONS","IMGUI_DISABLE_OBSOLETE_KEYIO"}

project "luasonicengine"
	kind "ConsoleApp"
	language "C++"
	cdialect "C99"
	cppdialect "C++17"
	location "build"
	targetdir "bin/%{cfg.buildcfg}"
	
	vpaths 
	{
		["Header Files"] = { "game/src/**.h"},
		["Source Files"] = {"game/scr/**.cpp", "game/src/**.c"},
	}
	files {"game/src/**.cpp","game/src/**.h"}
	link_raylib()
	links {"rlImGui"}
	includedirs {"./", "imgui", "imgui-master" }
		
    filter "action:vs*"
		debugdir "$(SolutionDir)"	
	
folders = os.matchdirs("*")
for _, folderName in ipairs(folders) do
    if (string.starts(folderName, "raylib") == false and string.starts(folderName, ".") == false) then
        if (os.isfile(folderName .. "/premake5.lua")) then
            print(folderName)
            include (folderName)
        end
    end
end
