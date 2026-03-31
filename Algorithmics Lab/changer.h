#include "mapa.h"
#include "state.h"




void change_level (MAP *map,STATE *st,POS max,WINDOW *wnd);
void player_death (STATE *st,WINDOW *wnd);
void change_level_final (MAP *map,STATE *st,POS max,WINDOW *wnd);
void game_won (STATE *st,WINDOW *wnd);