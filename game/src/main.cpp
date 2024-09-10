#include "raylib.h"

#include "stateSystem.cpp"

State currentState;

void switch_state(State state)
{
    switch (currentState)
    {
        case HOME_SCREEN: home_unload(); break;     
        case EDITOR: editor_unload(); break;
        case HEIGHT_EDITOR: height_editor_unload(); break;        
        //case GAME: game_unload(); break;
        default: break;
    }

    switch (state)
    {
        case HOME_SCREEN: home_init(); break;        
        case EDITOR: editor_init(); break;
        case HEIGHT_EDITOR: height_editor_init(); break;             
        //case GAME: game_init(); break;
        default: break;
    }

    currentState = state;
}

int main(void)
{
    const int screenWidth = 1080;
    const int screenHeight = 640;
    
  	SetConfigFlags(FLAG_WINDOW_RESIZABLE);  
    InitWindow(screenWidth, screenHeight, "LuaSonicEngine");
    InitAudioDevice();
    SetTargetFPS(60);
    
    switch_state(HOME_SCREEN);
    
    while (!WindowShouldClose())
    {
        // update
        
         switch(currentState)
        {
            //case HOME_SCREEN: home_update(); break;      
            //case EDITOR: editor_update(); break;
            //case GAME: editor_update(); break;
            default: break;
        } 
            
        // draw

        BeginDrawing();
        switch(currentState)
        {
            case HOME_SCREEN: home_draw(); break;      
            case EDITOR: editor_draw(); break;
            case HEIGHT_EDITOR: height_editor_draw(); break;                     
            //case GAME: editor_draw(); break;
            default: break;
        }        
        EndDrawing();

    }
    
    CloseAudioDevice();
    CloseWindow();

    return 0;
}
