
//includes

#include "raylib.h"
#include "raylib-master/src/rlgl.h"

#include "stateSystem.cpp"
#include "globals.cpp"

#include "imgui.h"
#include "rlImGui.h"

//variables

static ImFont* mainFont;

static Camera2D editorCamera;
static RenderTexture editorView;

static bool openWindows[5] = {
    true, //editor view [0]
    true, //object properties [1]
    true, //object list [2]
    true, //object browser [3]
    false //first time user popup [4]
};

//code

void editor_init(void)
{
    if (ImGui::GetCurrentContext() == NULL) {
        rlImGuiBeginInitImGui();
        
        ImGui::GetIO().Fonts->Clear();
        mainFont = ImGui::GetIO().Fonts->AddFontFromFileTTF("res/fonts/CascadiaMono.ttf", 14);
        ImGuiStyle* style = &ImGui::GetStyle();
        style->WindowTitleAlign = ImVec2(0.50f,0.50f);
        style->WindowRounding = 3;
        style->TabRounding = 3;
        style->WindowBorderSize = 0;   
        
        rlImGuiEndInitImGui();
    
        editorView = LoadRenderTexture(GetScreenWidth(),GetScreenHeight());
        
        editorBG = LoadTexture("res/images/editor/greenhillzone.png");
        
        editor_sounds[0] = LoadSound("res/sounds/editor/editor_startup.wav");
        editor_sounds[1] = LoadSound("res/sounds/editor/editor_popup.wav");
        editor_sounds[2] = LoadSound("res/sounds/editor/editor_warning.wav");
        editor_sounds[3] = LoadSound("res/sounds/editor/editor_error.wav");
        editor_sounds[4] = LoadSound("res/sounds/editor/editor_click.wav");
        editor_sounds[5] = LoadSound("res/sounds/editor/editor_release.wav");
        
        PlaySound(editor_sounds[0]);
    }
    //check if this is the user's first time on the editor
    if (!FileExists("imgui.ini")) {
        openWindows[4] = true;
        PlaySound(editor_sounds[1]);
    }
}

void camera_editor(void)
{
    BeginTextureMode(editorView);
    ClearBackground(BLACK);
    
    EndTextureMode();
}

void imgui_editor(void)
{
    rlImGuiBegin();
    

    //popups
    if (openWindows[4]) {
        ImGui::OpenPopup("Welcome!");
		ImGui::BeginPopupModal("Welcome!",NULL,ImGuiWindowFlags_AlwaysAutoResize);
        ImGui::SetItemDefaultFocus();
		ImGui::Text("It looks like it's your first time using LuaSonicEngine");
		ImGui::Text("Check out the wiki if confused");
		ImGui::Separator();
		if (ImGui::Button("Ok")) {
            ImGui::CloseCurrentPopup();
			openWindows[4] = false;
        }
		ImGui::SameLine();
		if (ImGui::Button("Open Wiki")) {
            //open url to wiki
			ImGui::CloseCurrentPopup();
			openWindows[4] = false;
        }
		ImGui::EndPopup();
    }
    
    //main menu bar
    ImGui::BeginMainMenuBar();
	if (ImGui::BeginMenu("File")) {
        ImGui::MenuItem("New");
		ImGui::MenuItem("Open","Ctrl+O");
        ImGui::MenuItem("Save","Ctrl+S");
		ImGui::Separator();
		ImGui::MenuItem("Settings");
		ImGui::Separator();
		if (ImGui::MenuItem("Exit","Alt+F4")) {
            rlImGuiShutdown();            
            CloseAudioDevice();
            CloseWindow();
		}			
		ImGui::EndMenu();
    }
		
	if (ImGui::BeginMenu("Edit")) {
        ImGui::MenuItem("placeholder");
		ImGui::EndMenu();
	}	
		
	if (ImGui::BeginMenu("View")) {
		if (ImGui::MenuItem("Editor View",NULL,openWindows[0])) {
			openWindows[0] = not openWindows[0];
		}
		if (ImGui::MenuItem("Object Properties",NULL,openWindows[1])) {
			openWindows[1] = not openWindows[1];
		}
		if (ImGui::MenuItem("Object List",NULL,openWindows[2])) {
			openWindows[2] = not openWindows[2];
		}
		if (ImGui::MenuItem("Object Browser",NULL,openWindows[3])) {	
			openWindows[3] = not openWindows[3];
		}
		ImGui::EndMenu();
	}
    
	if (ImGui::BeginMenu("Tools")) {
		ImGui::MenuItem("Level Editor",NULL,true);
		ImGui::MenuItem("Chunk Editor");
		if (ImGui::MenuItem("Height Data Editor")) {
            switch_state(HEIGHT_EDITOR);
        }
		ImGui::EndMenu();
	}	
    
	if (ImGui::BeginMenu("Help")) {
		if (ImGui::MenuItem("Wiki")) {
			//open url to wiki
		}
		if (ImGui::MenuItem("Issues")) {
			//open url to issues
		}
		ImGui::EndMenu();
	}	
		
	ImGui::SetCursorPosX(GetScreenWidth()/2 - ImGui::CalcTextSize("LuaSonicEngine - Level Editor").x/2);
	ImGui::Text("LuaSonicEngine - Level Editor");
		
	ImGui::EndMainMenuBar();
    
    //status bar
    ImGui::SetNextWindowPos(ImVec2(0,GetScreenHeight() - 30));
	ImGui::SetNextWindowSize(ImVec2(GetScreenWidth(),30));
	
	ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0);
	
	ImGui::Begin("##Status Bar", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings);
	ImGui::Text("ver 0.1.0 - developed by edgardeivis");
	ImGui::SameLine();
	ImGui::Text( TextFormat("| FPS: %i",GetFPS()) );
	ImGui::End();
	ImGui::PopStyleVar();
    
    //editor view
    if (openWindows[0]) {
		ImGui::Begin("Editor View",&openWindows[0],ImGuiWindowFlags_AlwaysAutoResize); //ImGuiWindowFlags_NoDocking doesn't exist for some reason
		ImGui::BeginChild("##inside_view",ImVec2(540,320),false,ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoScrollWithMouse);
		ImGui::Image(&editorView.texture,ImVec2(540,320),ImVec2(0,0),ImVec2(1,-1));
		ImGui::EndChild();
		ImGui::End();
	}
    
	rlImGuiEnd();
}

void editor_draw(void)
{
    ClearBackground(LIGHTGRAY);
    DrawTexture(editorBG,0,0,WHITE);
    camera_editor();
    imgui_editor();
    if (IsMouseButtonPressed(0) or IsMouseButtonPressed(1)) {
        PlaySound(editor_sounds[4]); 
    }
    if (IsMouseButtonReleased(0) or IsMouseButtonReleased(1)) {
        PlaySound(editor_sounds[5]); 
    }
}

void editor_unload(void)
{

}