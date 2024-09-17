
// includes

#include "raylib.h"
#include "raylib-master/src/raymath.h"

#include "raylib-master/src/rlgl.h"

#include "stateSystem.cpp"
#include "globals.cpp"

#include "imgui.h"
#include "rlImGui.h"

// code

#define MAX_TILES 224

static Camera2D editorCamera;
static RenderTexture dataView;
static RenderTexture tilePreview[MAX_TILES];

static int loaded = 0;
static bool loading = true;
static State stateToSwitch;

static int tileData[2][MAX_TILES+1][16];
// first array: [0] Height [1] Width ## I would just make them the same but ended up deciding to separate
// second array: the tile id
// third array: the height values of the tile, going to 16
static float tileDataAngle[MAX_TILES+1];
// angle of the tiles

static int tileSelected = 0;

static bool openWindows[5] = {
    true, // data view [0]
    true, // height values [1]
    true, // object list [2]
    true, // object browser [3]
    false // first time user popup [4]
};

static int dataViewSize = 2; // the default is 2 for now, user data saving will be for another time
static bool ViewSizes[3] = {false, true, false};

void update_tile(int tile)
{
    BeginTextureMode(tilePreview[tile]);

    ClearBackground(BLACK);
    for (int i = 0; i < 16; i++)
    {
        int positionRender = 16 - tileData[0][tile][i];
        DrawPixel(i, (float)positionRender, RAYWHITE);
        for (int i2 = 1; i2 < 16; i2++)
        {
            if (positionRender + i2 < 16)
            {
                DrawPixel(i, (float)positionRender + i2, RAYWHITE);
            }
        }
    }
    EndTextureMode();
    loaded++;
    if (loaded == MAX_TILES)
    {
        loading = false;
    }
}

void height_editor_init(void)
{
    dataView = LoadRenderTexture(145, 145);
    editorCamera.zoom = 9;
}

void camera_data(void)
{
    BeginTextureMode(dataView);

    ClearBackground(BLACK);
    BeginMode2D(editorCamera);
    for (int i = 0; i < 16; i++)
    {
        int positionRender = 16 - tileData[0][tileSelected][i];
        DrawPixel(i, (float)positionRender, RAYWHITE);
        for (int i2 = 1; i2 < 16; i2++)
        {
            if (positionRender + i2 < 16)
            {
                DrawPixel(i, (float)positionRender + i2, RAYWHITE);
            }
        }
    }
    EndMode2D();

    for (int i = 0; i <= 16; i++)
    {
        float line = (9 * i) + 1;
        DrawLineV((Vector2){line, 0}, (Vector2){line, 145}, DARKGRAY);
        DrawLineV((Vector2){0, line}, (Vector2){145, line}, DARKGRAY);
    }

    float angle = tileDataAngle[tileSelected] * RAD2DEG;

    if (angle < 360)
    {
        float angle = tileDataAngle[tileSelected];
        float point_angle = ((angle * RAD2DEG) + 90) * DEG2RAD;
        DrawLineV((Vector2){72.5, 72.5}, (Vector2){72.5f + cosf(-angle) * 145, 72.5f + sinf(-angle) * 145}, BLUE);
        DrawLineV((Vector2){72.5, 72.5}, (Vector2){72.5f - cosf(-angle) * 145, 72.5f - sinf(-angle) * 145}, DARKBLUE);
        DrawLineV((Vector2){72.5, 72.5}, (Vector2){72.5f + cosf(-point_angle) * 145, 72.5f + sinf(-point_angle) * 145}, RED);
    }

    EndTextureMode();
}

void imgui_data(void)
{
    rlImGuiBegin();

    // popups
    if (loaded < MAX_TILES)
    {
        ImGui::OpenPopup("Loading");
        ImGui::BeginPopup("Loading", ImGuiWindowFlags_NoMove);
        ImGui::SetWindowPos(ImVec2(GetScreenWidth() / 2 - ImGui::GetWindowWidth() / 2, GetScreenHeight() / 2 - ImGui::GetWindowHeight() / 2));
        ImGui::SetItemDefaultFocus();
        if (loading)
        {
            ImGui::Text(TextFormat("Loading tiles... %i/%i", loaded,MAX_TILES));
        }
        else
        {
            ImGui::Text(TextFormat("Unloading tiles... %i/%i", loaded,MAX_TILES));
        }
        ImGui::EndPopup();
    }
    // main menu bar
    ImGui::BeginMainMenuBar();
    if (ImGui::BeginMenu("File"))
    {
        ImGui::MenuItem("Settings");
        ImGui::Separator();
        if (ImGui::MenuItem("Exit", "Alt+F4"))
        {
            rlImGuiShutdown();
            CloseAudioDevice();
            CloseWindow();
        }
        ImGui::EndMenu();
    }

    if (ImGui::BeginMenu("Edit"))
    {
        ImGui::MenuItem("placeholder");
        ImGui::EndMenu();
    }

    if (ImGui::BeginMenu("View"))
    {
        if (ImGui::MenuItem("Data View", NULL, openWindows[0]))
        {
            openWindows[0] = not openWindows[0];
        }
        if (ImGui::MenuItem("Height Values", NULL, openWindows[1]))
        {
            openWindows[1] = not openWindows[1];
        }
        if (ImGui::BeginMenu("Data View Size"))
        {
            if (ImGui::MenuItem("1x", NULL, ViewSizes[0]))
            {
                ViewSizes[0] = true;
                ViewSizes[1] = false;
                ViewSizes[2] = false;
                dataViewSize = 1;
            }
            if (ImGui::MenuItem("2x", NULL, ViewSizes[1]))
            {
                ViewSizes[0] = false;
                ViewSizes[1] = true;
                ViewSizes[2] = false;
                dataViewSize = 2;
            }
            if (ImGui::MenuItem("3x", NULL, ViewSizes[2]))
            {
                ViewSizes[0] = false;
                ViewSizes[1] = false;
                ViewSizes[2] = true;
                dataViewSize = 3;
            }
            ImGui::EndMenu();
        }
        ImGui::EndMenu();
    }

    if (ImGui::BeginMenu("Tools"))
    {
        if (ImGui::MenuItem("Level Editor"))
        {
            if (not loading)
            {
                loaded = 0;
                stateToSwitch = EDITOR;
            }
        }
        ImGui::MenuItem("Chunk Editor");
        ImGui::MenuItem("Height Data Editor", NULL, true);
        ImGui::EndMenu();
    }

    if (ImGui::BeginMenu("Help"))
    {
        if (ImGui::MenuItem("Wiki"))
        {
            // open url to wiki
        }
        if (ImGui::MenuItem("Issues"))
        {
            // open url to issues
        }
        ImGui::EndMenu();
    }

    ImGui::SetCursorPosX(GetScreenWidth() / 2 - ImGui::CalcTextSize("LuaSonicEngine - Height Data Editor").x / 2);
    ImGui::Text("LuaSonicEngine - Height Data Editor");

    ImGui::EndMainMenuBar();

    // status bar
    ImGui::SetNextWindowPos(ImVec2(0, GetScreenHeight() - 30));
    ImGui::SetNextWindowSize(ImVec2(GetScreenWidth(), 30));

    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0);

    ImGui::Begin("##Status Bar", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings);
    ImGui::Text("ver 0.1.0 - developed by edgardeivis");
    ImGui::SameLine();
    ImGui::Text(TextFormat("| FPS: %i", GetFPS()));
    ImGui::End();
    ImGui::PopStyleVar();

    // data view
    if (openWindows[0])
    {
        int size = 145 * dataViewSize;
        ImGui::Begin("Data View", &openWindows[0], ImGuiWindowFlags_AlwaysAutoResize);
        ImGui::BeginChild("##inside_view", ImVec2(size, size), false, ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoScrollWithMouse);
        ImGui::Image(&dataView.texture, ImVec2(size, size), ImVec2(0, 0), ImVec2(1, -1));
        ImGui::EndChild();
        ImGui::End();
    }

    // height values
    ImGui::Begin("Height Values", &openWindows[1], ImGuiWindowFlags_AlwaysAutoResize);

    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(5, 5));

    for (int i = 0; i < 16; i++)
    {
        if (ImGui::VSliderInt(TextFormat("##value_ %i", i), ImVec2(20, 100), &tileData[0][tileSelected][i], 0, 16))
        {
            update_tile(tileSelected);
        }
        ImGui::SameLine();
    }
    ImGui::NewLine();
    ImGui::AlignTextToFramePadding();
    ImGui::Text("Tile angle: ");
    ImGui::SameLine();
    ImGui::SetNextItemWidth(185);
    ImGui::SliderAngle("##value_angle", &tileDataAngle[tileSelected], 0, 360);
    ImGui::SameLine();
    if (ImGui::Button("Calculate angle"))
    {
        // calculate the angle between the first and last height point, maybe using atan2
    }

    ImGui::PopStyleVar();

    ImGui::End();

    // data browser
    ImGui::Begin("Data Browser", &openWindows[0]);

    float windowVisibleX = ImGui::GetWindowPos().x + ImGui::GetWindowWidth();
    for (int i = 0; i < MAX_TILES; i++)
    { // wrapping content inside the frame
        ImVec4 colorSelected = (tileSelected == i) ? ImVec4(1.0, 1.0, 1.0, 1.0) : ImVec4(0.5, 0.5, 0.5, 1.0);
        if (ImGui::ImageButton(TextFormat("##tile_%i", i), &tilePreview[i].texture, ImVec2(64, 64), ImVec2(0, 0), ImVec2(1, -1), ImVec4(0, 0, 0, 0), colorSelected))
        {
            tileSelected = i;
        }
        float lastX = ImGui::GetItemRectMax().x;
        float nextX = lastX + ImGui::GetStyle().ItemSpacing.x + 84;
        if (nextX < windowVisibleX)
        {
            ImGui::SameLine();
        }
    }

    ImGui::End();

    rlImGuiEnd();
}

void height_editor_draw(void)
{
    ClearBackground(LIGHTGRAY);
    DrawTexture(editorBG, 0, 0, WHITE);
    for (int tile = 0; tile < 1; tile++)
    {
        if (loaded < MAX_TILES)
        {
            if (loading)
            {
                tilePreview[loaded] = LoadRenderTexture(16, 16);
                update_tile(loaded);
            }
            else
            {
                ExportImage(LoadImageFromTexture(tilePreview[loaded].texture), TextFormat("debug/img_tile_%i.png", loaded));
                UnloadTexture(tilePreview[loaded].texture);
                UnloadRenderTexture(tilePreview[loaded]);
                loaded++;
                if (loaded > 223)
                {
                    loading = true;
                    switch_state(stateToSwitch);
                }
            }
        }
    }
    camera_data();
    imgui_data();
    if (IsMouseButtonPressed(0) or IsMouseButtonPressed(1))
    {
        PlaySound(editorSounds[4]);
    }
    if (IsMouseButtonReleased(0) or IsMouseButtonReleased(1))
    {
        PlaySound(editorSounds[5]);
    }
}

void height_editor_unload(void)
{
    UnloadTexture(dataView.texture);
    UnloadRenderTexture(dataView);
    loaded = 0;
}