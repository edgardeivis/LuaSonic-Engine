
// includes

#include "raylib.h"

#include "stateSystem.cpp"
#include "globals.cpp"

#include "imgui.h"
#include "rlImGui.h"

// variables

Texture2D editorBG;
Sound editor_sounds[6]; // 0 = startup | 1 = popup | 2 = warning | 3 = error | 4 = mouse press | 5 = mouse release
static ImFont *mainFont;

static bool openWindows[5] = {
	false // first time user popup [0]
};

// code

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

		editorBG = LoadTexture("res/images/editor/greenhillzone.png");

		editor_sounds[0] = LoadSound("res/sounds/editor/editor_startup.wav");
		editor_sounds[1] = LoadSound("res/sounds/editor/editor_popup.wav");
		editor_sounds[2] = LoadSound("res/sounds/editor/editor_warning.wav");
		editor_sounds[3] = LoadSound("res/sounds/editor/editor_error.wav");
		editor_sounds[4] = LoadSound("res/sounds/editor/editor_click.wav");
		editor_sounds[5] = LoadSound("res/sounds/editor/editor_release.wav");

		PlaySound(editor_sounds[0]);
	}
	// check if this is the user's first time on the editor
	if (!FileExists("imgui.ini"))
	{
		openWindows[4] = true;
		PlaySound(editor_sounds[1]);
	}
}

void imgui_home(void)
{
	rlImGuiBegin();

	// popups
	if (openWindows[0])
	{
		ImGui::OpenPopup("Welcome!");
		ImGui::BeginPopupModal("Welcome!", NULL, ImGuiWindowFlags_AlwaysAutoResize);
		ImGui::SetItemDefaultFocus();
		ImGui::Text("It looks like it's your first time using LuaSonicEngine");
		ImGui::Text("Check out the wiki if confused");
		ImGui::Separator();
		if (ImGui::Button("Ok"))
		{
			ImGui::CloseCurrentPopup();
			openWindows[0] = false;
		}
		ImGui::SameLine();
		if (ImGui::Button("Open Wiki"))
		{
			// open url to wiki
			ImGui::CloseCurrentPopup();
			openWindows[0] = false;
		}
		ImGui::EndPopup();
	}


	// project manager window
	if (not openWindows[0])
	{
		ImGui::SetNextWindowSize(ImVec2(GetScreenWidth(),GetScreenHeight()));
		ImGui::SetNextWindowPos(ImVec2(0,0));		
		ImGui::Begin("##Projects",NULL, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize);
		ImGui::SetCursorPosX(GetScreenWidth() / 2 - ImGui::CalcTextSize("LuaSonicEngine").x / 2);
		ImGui::Text("LuaSonicEngine");
		ImGui::Separator();
		ImGui::BeginTabBar("project_bar");
		ImGui::BeginTabItem("Projects");

		ImGui::BeginChild("Projects",ImVec2(GetScreenWidth()/4*3-20,GetScreenHeight()-70),ImGuiChildFlags_Border);
		for (int i=0;i<100;i++) {
		ImGui::Text("Hello World");
		}
		ImGui::EndChild();

		ImGui::SameLine();

		ImGui::BeginChild("SideBar",ImVec2(GetScreenWidth()/4,GetScreenHeight()-70),ImGuiChildFlags_Border);
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
	}

	rlImGuiEnd();
}

void home_draw(void)
{
	ClearBackground(LIGHTGRAY);
	DrawTexture(editorBG, 0, 0, WHITE);
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