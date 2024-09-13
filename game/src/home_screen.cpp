
// includes

#include "raylib.h"

#include "stateSystem.cpp"
#include "globals.cpp"

#include "imgui.h"
#include "rlImGui.h"

// variables

Texture2D defaultProjectIcon;
Sound editor_sounds[6]; // 0 = startup | 1 = popup | 2 = warning | 3 = error | 4 = mouse press | 5 = mouse release
static ImFont *mainFont;

//static int selected[100];
static bool openWindows[5] = {
	false // first time user popup [0]
};

// code

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
		ImGui::GetWindowDrawList()->AddRectFilled(ImGui::GetItemRectMin(), ImGui::GetItemRectMax(), IM_COL32(color.x * 255, color.y * 255, color.z * 255, color.w * 125));
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

		editor_sounds[0] = LoadSound("res/sounds/editor/editor_startup.wav");
		editor_sounds[1] = LoadSound("res/sounds/editor/editor_popup.wav");
		editor_sounds[2] = LoadSound("res/sounds/editor/editor_warning.wav");
		editor_sounds[3] = LoadSound("res/sounds/editor/editor_error.wav");
		editor_sounds[4] = LoadSound("res/sounds/editor/editor_click.wav");
		editor_sounds[5] = LoadSound("res/sounds/editor/editor_release.wav");

		PlaySound(editor_sounds[0]);
	}
}

void imgui_home(void)
{
	rlImGuiBegin();

	// popups

	// project manager window
	if (not openWindows[0])
	{
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
		ImGui::Button("Scan directory");
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
	}

	rlImGuiEnd();
}

void home_draw(void)
{
	ClearBackground(BLACK);
	imgui_home();
	if (IsMouseButtonPressed(0) or IsMouseButtonPressed(1))
	{
		PlaySound(editor_sounds[4]);
	}
	if (IsMouseButtonReleased(0) or IsMouseButtonReleased(1))
	{
		PlaySound(editor_sounds[5]);
	}
}

void home_unload(void)
{
}