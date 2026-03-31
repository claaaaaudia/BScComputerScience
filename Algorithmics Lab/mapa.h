#include "state.h"


#ifndef ___MAP_H___
#define ___MAP_H___

typedef struct mob{
    char nome;
    int vida;
    int dano;
    int raio;
    int posx;
    int posy;
} MOBS;

typedef struct map{
    char cord[500][500];
    int seen[500][500];
    int distance[500][500];
    MOBS mobs[50];
} MAP;

typedef struct itens {
	char nome;
	int funcionalidade;
} ITENS;

#endif


void gerar(STATE *s,MAP *map,POS max);

void gerarMapa (MAP *map,POS max);
void spawnporta (MAP *map,POS max);
int vizinhanca (MAP *map,int x,int y,int n);
int vizinhanca2 (MAP *map,int x,int y,int n);
void ajustarMapa (MAP *map,POS max);
void ajustarMapa2 (MAP *map,POS max);
void ajustarMapa3 (MAP *map,POS max);
void ajustarMapa4 (MAP *map,POS max);
void fronteiras (MAP *map,POS max);
void radius (MAP *map, STATE *st,int radius);
void radius2 (MAP *map, STATE *st,int radius);
void radiusdistance (MAP *map, STATE *st,int radius);

void gerarMobs (MAP *map, POS max, STATE* st);

void atualizarPos (STATE *st,MOBS *mob, MAP *map,WINDOW *wnd);

void gerarSpawn(MOBS *s,MAP *map,POS max);
void gerarBossSpawn(MOBS *s, MAP *map, POS max);

void randomPos (MOBS *mob, MAP *map);
void gerarSpawn2(ITENS *s,MAP *map,POS max);
void gerarItem(MAP *map, POS max, STATE* st);
void apanhaItem(STATE *st,MAP *map,WINDOW *wnd);
void bossAttackSpawn (MOBS *boss,MAP *map);
