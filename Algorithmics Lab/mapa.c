#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ncurses.h>
#include <time.h>
#include <math.h>

#include "mapa.h"
#include "combat.h"
#include "changer.h"

int vizinhanca (MAP *map,int x,int y,int n) {

	int i,j,count=0;

	for (i=-n;i<=n;i++) {

		if (x-i <= 0 && x-i >= 499) {continue;}

		for (j=-n;j<=n;j++) {

			if (y-j <= 0 && y-j >= 499) {continue;}

			if (map->cord[x-i][y-j] == '#') count++;

		}

	}

return count;

}

void spawnporta (MAP *map,POS max) {

    int randomx = rand() % max.x;
	int randomy = rand() % max.y;

	if (vizinhanca(map,randomx,randomy,4) < 5) {
		map->cord[randomx][randomy] = 'D';
	} else spawnporta(map,max);

}

void gerar(STATE *s,MAP *map,POS max) {
	int randomx = rand() % max.x;
	int randomy = rand() % max.y;

	if (vizinhanca(map,randomx,randomy,3) < 5) {
		s->playerX = randomx;
		s->playerY = randomy;
	} else gerar(s,map,max);
}

int vizinhanca2 (MAP *map,int x,int y,int n) {

	int j,count=0;

		for (j=-n;j<=n;j++) {

			if (y-j <= 0 && y-j >= 499) {continue;}

			if (map->cord[x][y-j] == '#') count++;

		}

return count;

}

void gerarMapa (MAP *map,POS max) {

	int i,j;


	for (i=1;i<max.x;i++) {

		for (j=1;j<max.y;j++) {

				int random = rand() % 100; //0-9

				if (random <= 46) {map->cord[i][j] = '#';} 
				else {map->cord[i][j] = '.';}
				

		}


	}

}

void ajustarMapa (MAP *map,POS max) {

	int i,j;

	MAP clone;
	clone = *map;


	for (i=1;i<max.x;i++) {

		for (j=1;j<max.y;j++) {

			if (vizinhanca(&clone,i,j,1) >= 5 || vizinhanca(&clone,i,j,2) <= 2) {

				clone.cord[i][j] = '#';

			} else {

				clone.cord[i][j] = '.';

			}

		}

	}

	*map = clone;

}

void ajustarMapa2 (MAP *map,POS max) {

	int i,j;

	MAP clone;
	clone = *map;


	for (i=1;i<max.x;i++) {

		for (j=1;j<max.y;j++) {

			if (vizinhanca(&clone,i,j,1) < 5) {

				clone.cord[i][j] = '.';

			}

		}

	}

	*map = clone;

}

void ajustarMapa3 (MAP *map,POS max) {

	int i,j;

	MAP clone;
	clone = *map;


	for (i=1;i<max.x;i++) {

		for (j=1;j<max.y;j++) {

			if (vizinhanca(&clone,i,j,1) < 4) {

				clone.cord[i][j] = '.';

			}

		}

	}

	*map = clone;

}

void ajustarMapa4 (MAP *map,POS max) {

	int i,j;

	MAP clone;
	clone = *map;


	for (i=1;i<max.x;i++) {

		for (j=1;j<max.y;j++) {

			if (vizinhanca2(&clone,i,j,7) == 3) {

				clone.cord[i][j] = '.';

			}

		}

	}

	*map = clone;

}

void fronteiras (MAP *map,POS max) {

	int i,j;


	for (i=0;i<max.x;i++) {

		for (j=0;j<max.y;j++) {

			if (i==0 || i==max.x-2 || j==0 || j==max.y-1) {map->cord[i][j] = '#';}
			map->seen[i][j] = 0;
			map->distance[i][j] = 0;
		}

	}

	for (i=0;i<50;i++) {

		map->mobs[i].nome = '\0';
		map->mobs[i].vida = 0;
		map->mobs[i].dano = 0;
		map->mobs[i].posx = 0;
		map->mobs[i].posy = 0;

	}


}

void radius (MAP *map, STATE *st,int radius) {

	double i; int j,x,y;
	for (i=0;i<6.28;i+=0.05) {

		for (j=1;j<radius;j++) {

			x = round(sin(i)*j);
			y = round(cos(i)*j);

			if (x==radius) {x=radius - 1;}
			if (x==-radius) {x=-radius + 1;}
			if (map->seen[st->playerX + x][st->playerY + y] <= 2) {
				map->seen[st->playerX + x][st->playerY + y] = 2;
			}

			if (map->cord[st->playerX + x][st->playerY + y] == '#') {

				break;

			}

		}
	}

}

void radius2 (MAP *map, STATE *st,int radius) {

	double i; int j,x,y;
	
	for (i=0;i<6.28;i+=0.05) {

		for (j=radius;j<radius*2;j++) {

			x = round(sin(i)*j);
			y = round(cos(i)*j);

			if (st->playerX + x < 0 || st->playerX + x > 500 || st->playerY + y < 0 || st->playerY + y > 500) {continue;}

			if (map->seen[st->playerX + x][st->playerY + y] == 2) {

				map->seen[st->playerX + x][st->playerY + y] = 1;

			}

		}
	}

}

void radiusdistance (MAP *map, STATE *st,int radius) {

	double i; int j,x,y;
	
	for (i=0;i<6.28;i+=0.05) {

		for (j=1;j<radius + 4;j++) {

			x = round(sin(i)*j);
			y = round(cos(i)*j);

			if (j < radius) {

			 

			if (map->cord[st->playerX + x][st->playerY + y] == '#') {

				break;

			}

			map->distance[st->playerX + x][st->playerY + y] = sqrt(x*x + y*y);
			}
			else {

				map->distance[st->playerX + x][st->playerY + y] = 0;

			}
		}
	}

}


void gerarSpawn(MOBS *s, MAP *map, POS max) {
    int randomx = rand() % max.x;
    int randomy = rand() % max.y;

    if (vizinhanca(map,randomx,randomy,3) < 5) {
        s->posx = randomx;
        s->posy = randomy;
    } else gerarSpawn(s,map,max);
}

void gerarBossSpawn(MOBS *s, MAP *map, POS max) {
    int randomx = rand() % (max.x/10);
    int randomy = rand() % (max.y/10);

	int fixedx = max.x/2 + randomx;
	int fixedy = max.y/2 + randomy;

    if (vizinhanca(map,fixedx,fixedy,5) < 5) {
        s->posx = fixedx;
        s->posy = fixedy;
    } else gerarBossSpawn(s,map,max);
}

void gerarMobs (MAP *map, POS max, STATE *st) {
    int i, k, numMobs, nivel, tipomob;
    MOBS mob;

    nivel = st->floor;

    MOBS tiposMobs[5] = {
        {'J', 10, 5,2,0,0},
        {'G', 20, 8,2,0,0},
        {'S', 30, 12,3,0,0},
		{'C', 45, 15,4,0,0},
		{'P', 300, 30,10,0,0},
    };
    
    if (nivel >= 15) {

		mob.nome = tiposMobs[4].nome;
		mob.dano = tiposMobs[4].dano;
		mob.vida = tiposMobs[4].vida + (st->damage/2);

        gerarBossSpawn(&mob,map,max);
		map->mobs[49] = mob;
	}
    else if (nivel == 5 || nivel == 10) {
			numMobs = nivel; //4 ou 9 mobs

			for (k=0; k<numMobs; k++) {
				
				if (k==1 || k==2) { //k=0 nao spawna; miniboss
					mob.nome = tiposMobs[3].nome;
					mob.dano = tiposMobs[3].dano + nivel;
					mob.vida = tiposMobs[3].vida + nivel*2 + (st->damage/2);
					
					map->mobs[k] = mob;
					gerarSpawn(&mob,map,max);
				}
				else
				{
					tipomob = rand() % (nivel / 5 + 1);
					if (tipomob >= 3) {tipomob = 2;}

					mob.nome = tiposMobs[tipomob].nome;
					mob.dano = tiposMobs[tipomob].dano + nivel;
					mob.vida = tiposMobs[tipomob].vida + nivel*2 + (st->damage/2);
					
					map->mobs[k] = mob;
					gerarSpawn(&mob,map,max);
				}
			}
	}
	else
		{
			numMobs = nivel+2;
			
			for (i=0; i<numMobs; i++) {
				tipomob = rand() % (nivel / 5 + 1);
				if (tipomob >= 3) {tipomob = 2;}

				mob.nome = tiposMobs[tipomob].nome;
				mob.dano = tiposMobs[tipomob].dano + nivel;
				mob.vida = tiposMobs[tipomob].vida + nivel*2 + (st->damage/2);
				
				map->mobs[i] = mob;
				gerarSpawn(&mob,map,max);
			}
    }
	
}

void atualizarPos(STATE* st, MOBS* mob, MAP* map,WINDOW *wnd) {
    int direcaoX, direcaoY;

    if (map->distance[mob->posx][mob->posy] > 1) {
        direcaoX = st->playerX - mob->posx;
        direcaoY = st->playerY - mob->posy;
        if (abs(direcaoX) > abs(direcaoY)) {
            if (direcaoX > 0) {
                if (map->cord[mob->posx + 1][mob->posy] != '#') {
                    mob->posx++;
                } else {
                    randomPos(mob, map);
                }
            } else if (direcaoX < 0) {
                if (map->cord[mob->posx - 1][mob->posy] != '#') {
                    mob->posx--;
                } else {
                    randomPos(mob, map);
                }
            }
        } else {
            if (direcaoY > 0) {
                if (map->cord[mob->posx][mob->posy + 1] != '#') {
                    mob->posy++;
                } else {
                    randomPos(mob, map);
                }
            } else if (direcaoY < 0) {
                if (map->cord[mob->posx][mob->posy - 1] != '#') {
                    mob->posy--;
                } else {
                    randomPos(mob, map);
                }
            }
        }
    } else if (map->distance[mob->posx][mob->posy] == 1) {
		int random = rand() %2;
		if (random == 0) {
			mobatacar(st,map,mob,1,wnd);
		} else {
        	randomPos(mob, map);
		}
    } else {randomPos(mob,map);}
}

void randomPos (MOBS *mob, MAP *map){
	int direcao;
	char anterior = 's';

	direcao = rand() % 4;

        switch (direcao) {
            case 0: //cima
                if (map->cord[mob->posx][mob->posy+1] != '#') {
                    if (anterior != 'b') {
						mob->posy++;
						anterior = 'c';
					} 
					else
					{
						randomPos (mob, map);	
					} 
				}
				else
				{
					randomPos (mob, map);
				} break;
            case 1://baixo
                if (map->cord[mob->posx][mob->posy-1] != '#') {
                    if (anterior != 'c') {
						mob->posy--;
						anterior = 'b';
					} 
					else
					{
						randomPos (mob, map);	
					}	
				}
				else
				{
					randomPos (mob, map);	
				} break;
            case 2: //direita
                if (map->cord[mob->posx+1][mob->posy] != '#') {
                    if (anterior != 'e') {
						mob->posx++;
						anterior = 'd';
					} 
					else
					{
						randomPos (mob, map);	
					}
				} 
				else
				{
					randomPos (mob, map);	
				} break;
            case 3: //esquerda
                if (map->cord[mob->posx-1][mob->posy] != '#') {
                    if (anterior != 'd') {
						mob->posx--;
						anterior = 'e';
					} 
					else
					{
						randomPos (mob, map);	
					}	
				}
				else
				{
					randomPos (mob, map);	
				} break;
	}
}

void gerarSpawn2(ITENS *s,MAP *map,POS max) {
	int randomx = rand() % max.x;
	int randomy = rand() % max.y;

	if (vizinhanca(map,randomx,randomy,3) < 5) {
		map->cord[randomx][randomy] = s->nome;
	} else gerarSpawn2(s,map,max);
}



void gerarItem(MAP *map, POS max, STATE* st) { 
	int i, j, tipo=0, nivel;
	nivel = st->floor;
	if (nivel == 1) {nivel++;}
	
	ITENS tiposTocha[2] = {
		{'l', 1}, //luz
		{'L', 2},
	};
	
	ITENS tiposArma[4] = { 
		{'g', 2}, //garfo
		{'f', 3}, //faca
		{'t', 5}, //tacho
		{'c', 7}, //colher de pau
	};
	
	ITENS tiposCura[2] = { 
		{'h', 2*nivel}, //cura
		{'m', 4*nivel}, //medikit
	};
	
	ITENS aumentaVida[1] = { 
		{'v', 10}, 
	};

	ITENS tiposArmadilha[2] = {
		{'a', 2 * nivel},
		{'A', 4 * nivel},
	};
	
	ITENS aumentaRaio[2] = {
		{'r', 1},
		{'R', 2},
	};
	
	for (i=0; i<3; i++) { //3 armas em cada nivel, qualidade aumenta a cada 5 niveis
		tipo = nivel / 3;
		if (tipo > 3) {tipo = 3;}
		gerarSpawn2(&tiposArma[tipo],map,max);
	}

	for (i=0; i<nivel; i++) { 
		j=0;
		tipo = 0;
		if (nivel >= 10) {tipo=1;}
		gerarSpawn2(&tiposArmadilha[tipo],map,max);
		if (st->light < 25) {gerarSpawn2(&tiposTocha[tipo],map,max);gerarSpawn2(&tiposTocha[tipo],map,max); gerarSpawn2(&tiposTocha[tipo],map,max);} //so aparece tochas se tiver menos de 25 de luz
		if (st->radius < 8) gerarSpawn2(&aumentaRaio[tipo],map,max);
		while (j<3) {
			tipo = rand() % 2; 
			gerarSpawn2(&tiposCura[tipo],map,max);
			j++;
		}
	}
	
	gerarSpawn2(&aumentaVida[0],map,max); //1 aumentavida por nivel
}

void apanhaItem(STATE *st,MAP *map,WINDOW *wnd) {
	int i;
	char tipoItem[13] = {'L', 'l', 'g', 'f', 't', 'c', 'm', 'h', 'v', 'A', 'a', 'R', 'r'};
	int nivel = st->floor;

	ITENS tiposTocha[2] = {
		{'l', 1}, //luz
		{'L', 2},
	};
	
	ITENS tiposArma[4] = { 
		{'g', 2}, //garfo
		{'f', 3}, //faca
		{'t', 5}, //tacho
		{'c', 7}, //colher de pau
	};
	
	ITENS tiposCura[2] = { 
		{'h', 2*nivel}, //cura
		{'m', 4*nivel}, //medikit
	};
	
	ITENS aumentaVida[1] = { 
		{'v', 10}, 
	};

	ITENS tiposArmadilha[2] = {
		{'a', 2 * nivel},
		{'A', 4 * nivel},
	};
	
	ITENS aumentaRaio[2] = {
		{'r', 1},
		{'R', 2},
	};

	for (i=0; i<13; i++) {
		if (map->cord[st->playerX][st->playerY] == tipoItem[i]) {
			if (i==0 || i==1) {if (st->light + tiposTocha[i].funcionalidade > 25) {st->light = 25;} else {st->light += tiposTocha[i].funcionalidade;}}
			if (i==2 || i==3 || i==4 || i==5) st->damage += tiposArma[i-2].funcionalidade;
			if (i==6 || i==7) {if (st->health == st->maxhealth) {return;} else if (st->health + tiposCura[i-6].funcionalidade > st->maxhealth) {st->health = st->maxhealth;} else {st->health += tiposCura[i-6].funcionalidade;}}
			if (i==8) {st->maxhealth += aumentaVida[i-8].funcionalidade; st->health += aumentaVida[i-8].funcionalidade;}
			if (i==9 || i==10) {st->health -= tiposArmadilha[i-9].funcionalidade; if (st->health <= 0) {player_death(st,wnd);}}
			if (i==11 || i==12) {if (st->radius + aumentaRaio[i-11].funcionalidade > 8) {st->radius = 8;} else {st->radius += aumentaRaio[i-11].funcionalidade;}} //adicionar raio maximo
			map->cord[st->playerX][st->playerY] = '.';
		}
	}
	
}

void bossAttackSpawn (MOBS *boss,MAP *map) {
    int i;
    MOBS mob;

    MOBS tiposMobs[5] = {
        {'J', 10, 5,2,0,0},
        {'G', 20, 8,2,0,0},
        {'S', 30, 12,3,0,0},
		{'C', 45, 15,4,0,0},
    };

	for (i=0;i<49;i++) {
		if (map->mobs[i].nome == '\0') {break;}
	}
        mob.nome = tiposMobs[2].nome;
		mob.dano = tiposMobs[2].dano + 10;
		mob.vida = tiposMobs[2].vida + 20;
			
        int randx = rand() % 6;
		int randy = rand() % 6;
		mob.posx = boss->posx + randx;
		mob.posy = boss->posy + randy;

		map->mobs[i] = mob;

}