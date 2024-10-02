
// includes
#include <filesystem>
#include <fstream>

#include "raylib.h"

#include "stateSystem.cpp"
#include "globals.cpp"

#include "imgui.h"
#include "rlImGui.h"
#include "nlohmann-json/json.hpp"

using json = nlohmann::json;

// variables

Texture2D defaultProjectIcon;
Sound editorSounds[6]; // 0 = startup | 1 = popup | 2 = warning | 3 = error | 4 = mouse press | 5 = mouse release
static ImFont *mainFont;

static char currentDirectory[2048];

typedef struct {
	char paths[100][2048];
	int count;
	int selected;
} PROJECTPATHS;

static PROJECTPATHS projectDirectories;

static char newProjectName[128];
static char newProjectPath[2048];

static bool openWindows[5] = {
	false, // path explorer [0]
	false, // project paths [1]
	false //    new project [2]
};

// code

void project_paths(void)
{
	ImGui::OpenPopup("Project paths");
	ImGui::BeginPopupModal("Project paths",NULL);
	ImGui::SetItemDefaultFocus();
	ImGui::BeginChild("##Folders",ImVec2(ImGui::GetWindowWidth()-15,ImGui::GetWindowHeight()-60),ImGuiChildFlags_Border);
	for (int i = 0; i < projectDirectories.count; i++) 
	{
		bool selected;
		if (projectDirectories.selected == i) { selected = true; } else { selected = false; }
		if (ImGui::Selectable(projectDirectories.paths[i],selected)) {
			projectDirectories.selected = i;
		}
	}
	ImGui::EndChild();
	if (ImGui::Button("Add path")) 
	{
		openWindows[0] = true;
		openWindows[1] = false;
		ImGui::CloseCurrentPopup();

	}
	ImGui::SameLine();
	bool shouldBeDisabled = false;

	if (projectDirectories.count == 0) {
		shouldBeDisabled = true;
	}
	
	ImGui::BeginDisabled(shouldBeDisabled);
	ImGui::Button("Remove path");
	ImGui::EndDisabled();

	ImGui::SameLine();
	if (ImGui::Button("Cancel")) 
	{
		openWindows[1] = false;
		ImGui::CloseCurrentPopup();
	}
	ImGui::EndPopup();
}

void path_explorer(void)
{
	FilePathList paths;

	if (DirectoryExists(currentDirectory)) {
		paths = LoadDirectoryFiles(currentDirectory);
	} else {
		paths = LoadDirectoryFiles(GetWorkingDirectory());
	}

	ImGui::OpenPopup("Choose path");
	ImGui::BeginPopupModal("Choose path",NULL);
	ImGui::SetItemDefaultFocus();
	if (ImGui::Button("##back",ImVec2(20,20))) 
	{
		TextCopy(currentDirectory,GetPrevDirectoryPath(currentDirectory));
	}
	ImGui::SameLine();
	ImGui::SetNextItemWidth(ImGui::GetWindowWidth()-43);
	ImGui::InputText("##path",currentDirectory,2048);
	ImGui::BeginChild("##Folders",ImVec2(ImGui::GetWindowWidth()-15,ImGui::GetWindowHeight()-85),ImGuiChildFlags_Border);
	for (int i = 0; i < paths.count; i++) 
	{
		if (!IsPathFile(paths.paths[i])) //for some reason LoadDirectoryFilesEx lags the hell out of it, so i had to go with this
		{
			if (ImGui::Selectable(GetFileName(paths.paths[i])))
			{
				TextCopy(currentDirectory,paths.paths[i]);
			}
		}
	}
	ImGui::EndChild();
	if (ImGui::Button("Select Directory")) {
		TextCopy(projectDirectories.paths[projectDirectories.count],currentDirectory);
		projectDirectories.count++;
		openWindows[0] = false;
		openWindows[1] = true;
		ImGui::CloseCurrentPopup();
	}
	ImGui::SameLine();
	if (ImGui::Button("Cancel")) 
	{
		openWindows[0] = false;
		openWindows[1] = true;
		ImGui::CloseCurrentPopup();
	}
	ImGui::EndPopup();
	UnloadDirectoryFiles(paths);
}

void project_element(const char projectName[],char projectPath[])
{

	ImGui::GetWindowDrawList()->ChannelsSplit(2);
	ImGui::GetWindowDrawList()->ChannelsSetCurrent(1);
	ImGui::BeginGroup();
	ImGui::Image(&defaultProjectIcon, ImVec2(80, 80));
	// draw project title
	ImGui::SetCursorPosX(95);
	ImGui::SetCursorPosY(ImGui::GetCursorPosY() - 60);
	ImGui::Text(projectName);
	// draw project description
	ImGui::SetCursorPosX(95);
	ImGui::TextColored(ImVec4(1, 1, 1, 0.5), projectPath);
	ImGui::EndGroup();
	ImGui::GetWindowDrawList()->ChannelsSetCurrent(0);
	if (ImGui::IsItemHovered())
	{
		static ImVec4 color = ImGui::GetStyle().Colors[ImGuiCol_ButtonHovered];
		ImGui::GetWindowDrawList()->AddRectFilled(ImVec2(ImGui::GetItemRectMin().x-15,ImGui::GetItemRectMin().y-3), ImVec2(ImGui::GetWindowWidth(),ImGui::GetItemRectMax().y+3), IM_COL32(color.x * 255, color.y * 255, color.z * 255, color.w * 125));
	}
	ImGui::GetWindowDrawList()->ChannelsMerge();

}

void home_init(void)
{
	if (ImGui::GetCurrentContext() == NULL)
	{
		rlImGuiBeginInitImGui();

		ImGui::GetIO().Fonts->Clear();
		mainFont = ImGui::GetIO().Fonts->AddFontFromFileTTF("res/fonts/CascadiaMono.ttf", 14);
		ImGuiStyle *style = &ImGui::GetStyle();
		style->WindowTitleAlign = ImVec2(0.50f, 0.50f);
		style->WindowRounding = 3;
		style->TabRounding = 3;
		style->WindowBorderSize = 0;

		rlImGuiEndInitImGui();

		defaultProjectIcon = LoadTexture("res/images/editor/icon_project.png");
		SetTextureFilter(defaultProjectIcon, TEXTURE_FILTER_TRILINEAR);

		editorSounds[0] = LoadSound("res/sounds/editor/editor_startup.wav");
		editorSounds[1] = LoadSound("res/sounds/editor/editor_popup.wav");
		editorSounds[2] = LoadSound("res/sounds/editor/editor_warning.wav");
		editorSounds[3] = LoadSound("res/sounds/editor/editor_error.wav");
		editorSounds[4] = LoadSound("res/sounds/editor/editor_click.wav");
		editorSounds[5] = LoadSound("res/sounds/editor/editor_release.wav");

		PlaySound(editorSounds[0]);
	}

	ChangeDirectory(GetDirectoryPath(GetApplicationDirectory()));

	if (not DirectoryExists("Projects")) {
		std::filesystem::create_directory("Projects");
	}

	TextCopy(currentDirectory,GetWorkingDirectory());

	TextCopy(projectDirectories.paths[projectDirectories.count],TextFormat("%s\\Projects",GetWorkingDirectory()));
	projectDirectories.count++;

}

void imgui_home(void)
{
	rlImGuiBegin();

	// popups
	if (openWindows[0]) //path explorer
	{
		path_explorer();
	}
	if (openWindows[1]) //project paths manager
	{
		project_paths();
	}
	// project manager window
	ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0);
	ImGui::SetNextWindowSize(ImVec2(GetScreenWidth(), GetScreenHeight()));
	ImGui::SetNextWindowPos(ImVec2(0, 0));
	ImGui::Begin("##Projects", NULL, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize);
	ImGui::SetCursorPosX(GetScreenWidth() / 2 - ImGui::CalcTextSize("LuaSonicEngine").x / 2);
	ImGui::Text("LuaSonicEngine");
	ImGui::Separator();
	ImGui::BeginTabBar("project_bar");
	ImGui::BeginTabItem("Projects");

	ImGui::BeginChild("Projects", ImVec2(GetScreenWidth() / 4 * 3 - 20, GetScreenHeight() - 70), ImGuiChildFlags_Border);
	for (int i = 0; i < projectDirectories.count; i++) 
	{
		FilePathList paths;

		paths = LoadDirectoryFiles(projectDirectories.paths[i]);

		for (int projects = 0; projects < paths.count; projects++) {
			project_element(GetFileName(paths.paths[projects]),projectDirectories.paths[i]);
		}

		UnloadDirectoryFiles(paths);
	}
	ImGui::EndChild();

	ImGui::SameLine();

	ImGui::BeginChild("SideBar", ImVec2(GetScreenWidth() / 4, GetScreenHeight() - 70), ImGuiChildFlags_Border);
	if (ImGui::Button("New project"))
	{
		openWindows[2] = true;
	}
	if (ImGui::Button("Scan directory"))
	{
		openWindows[1] = true;
		PlaySound(editorSounds[1]);
	}
	ImGui::Separator();
	ImGui::BeginDisabled();
	ImGui::Button("Open");
	ImGui::Button("Rename");
	ImGui::Button("Delete");
	ImGui::EndDisabled();
	ImGui::Separator();
	ImGui::Button("Settings");
	ImGui::EndChild();

	ImGui::EndTabItem();
	ImGui::EndTabBar();
	
	ImGui::End();
	ImGui::PopStyleVar();

	//project creation window
	if (openWindows[2])
	{
		ImGui::OpenPopup("New project");
		ImGui::SetItemDefaultFocus();
		ImGui::BeginPopupModal("New project",NULL);
		ImGui::Text("Project name");
		ImGui::InputText("##project_name",newProjectName,128);
		ImGui::Text("Project location");
		ImGui::InputText("##project_path",newProjectPath,2048);
		ImGui::SameLine();
		ImGui::Button("...");
		if (ImGui::Button("Create")) 
		{
			std::filesystem::create_directory(TextFormat("%s\\%s",newProjectPath,newProjectName));
			json projectJson;
			projectJson["name"] = newProjectName;
			std::ofstream outfile (TextFormat("%s\\%s\\project.json",newProjectPath,newProjectName));
			outfile << projectJson << std::endl;
			outfile.close();
			openWindows[2] = false;	
		}
		ImGui::SameLine();
		if (ImGui::Button("Cancel"))
		{
			openWindows[2] = false;
		}
		ImGui::EndPopup();
	}
	
	rlImGuiEnd();
}

void home_draw(void)
{
	ClearBackground(BLACK);
	imgui_home();
	if (IsMouseButtonPressed(0) or IsMouseButtonPressed(1))
	{
		PlaySound(editorSounds[4]);
	}
	if (IsMouseButtonReleased(0) or IsMouseButtonReleased(1))
	{
		PlaySound(editorSounds[5]);
	}
}

void home_unload(void)
{
}