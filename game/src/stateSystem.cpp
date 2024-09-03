typedef enum State { EDITOR, HEIGHT_EDITOR, GAME } State;

extern State currentState;

extern void switch_state(State state);

//Editor Functions
void editor_init(void);
void editor_update(void);
void editor_draw(void);
void editor_unload(void);

//Data Height Editor Functions
void height_editor_init(void);
void height_editor_update(void);
void height_editor_draw(void);
void height_editor_unload(void);


//Game Functions
void game_init(void);
void game_update(void);
void game_draw(void);
void game_unload(void);
