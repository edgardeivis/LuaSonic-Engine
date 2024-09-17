
// includes

#include "raylib.h"

#include "stateSystem.cpp"
#include "globals.cpp"

#include "imgui.h"
#include "rlImGui.h"

// variables

Texture2D defaultProjectIcon;
Sound editorSounds[6]; // 0 = startup | 1 = popup | 2 = warning | 3 = error | 4 = mouse press | 5 = mouse release
static ImFont *mainFont;

static char currentDirectory[2048];

// static int selected[100];
static bool openWindows[5] = {
	false // file explorer [0]
};

// code

void file_explorer(void)
{
	FilePathList paths;

	if (DirectoryExists(currentDirectory)) {
		paths = LoadDirectoryFiles(currentDirectory);
	} else {
		paths = LoadDirectoryFiles(GetWorkingDirectory());
	}

	ImGui::OpenPopup("File Explorer");
	ImGui::BeginPopupModal("File Explorer",NULL);
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
		if (not IsPathFile(paths.paths[i])) //for some reason LoadDirectoryFilesEx lags the hell out of it, so i had to go with this
		{
			if (ImGui::Selectable(GetFileName(paths.paths[i])))
			{
				TextCopy(currentDirectory,paths.paths[i]);
			}
		}
	}
	ImGui::EndChild();
	ImGui::Button("Select Directory");
	ImGui::SameLine();
	if (ImGui::Button("Cancel")) 
	{
		openWindows[0] = false;
		ImGui::CloseCurrentPopup();
	}
	ImGui::EndPopup();
	UnloadDirectoryFiles(paths);
}

void project_element(void)
{

	ImGui::GetWindowDrawList()->ChannelsSplit(2);
	ImGui::GetWindowDrawList()->ChannelsSetCurrent(1);
	ImGui::BeginGroup();
	ImGui::Image(&defaultProjectIcon, ImVec2(80, 80));
	// draw project title
	ImGui::SetCursorPosX(95);
	ImGui::SetCursorPosY(ImGui::GetCursorPosY() - 60);
	ImGui::Text("Project_Name");
	// draw project description
	ImGui::SetCursorPosX(95);
	ImGui::TextColored(ImVec4(1, 1, 1, 0.5), "C://Documents/LuaSonicEngine/Projects");
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
	TextCopy(currentDirectory,GetWorkingDirectory());
}

void imgui_home(void)
{
	rlImGuiBegin();

	// popups
	if (openWindows[0]) //file explorer
	{
		file_explorer();
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
	for (int i = 0; i < 100; i++)
	{
		project_element();
	}
	ImGui::EndChild();

	ImGui::SameLine();

	ImGui::BeginChild("SideBar", ImVec2(GetScreenWidth() / 4, GetScreenHeight() - 70), ImGuiChildFlags_Border);
	ImGui::Button("New project");
	if (ImGui::Button("Scan directory"))
	{
		openWindows[0] = true;
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