#include "mapa.h"
#include "state.h"



void atacar (STATE *st, MAP *map,int raio);
void mobatacar(STATE* st,MAP *map, MOBS *mob, int raio,WINDOW *wnd);
void atacardir (int dir, MAP *map,STATE *st);
void bossAttackdir (STATE *st,MOBS *mob,MAP *map,WINDOW *wnd);
void bossAttackdia (STATE *st,MOBS *mob,MAP *map,WINDOW *wnd);
void bossAttackcir (STATE *st,MOBS *mob,MAP *map,WINDOW *wnd);
void mobDeath (MOBS *mob,MAP *map,STATE *st);
void bossDrop (MOBS *mob,MAP *map);
void mobDrop (MAP *map,MOBS *mob,STATE *st);
void mobDropBtr (MAP *map,MOBS *mob,STATE *st);