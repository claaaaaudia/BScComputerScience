#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ncurses.h>
#include <time.h>

#include "mapa.h"
#include "state.h"
#include "changer.h"


void change_level (MAP *map,STATE *st,POS max,WINDOW *wnd) {

	wclear(wnd);

    gerarMapa(map,max);
	fronteiras(map,max);
	ajustarMapa3(map,max);
	ajustarMapa(map,max);
	ajustarMapa(map,max);
	ajustarMapa(map,max);
	ajustarMapa2(map,max);
	ajustarMapa2(map,max);
	ajustarMapa4(map,max);
	fronteiras(map,max);
	
	gerar(st,map,max);
	spawnporta(map,max);
	gerarMobs(map,max,st);
	gerarItem(map,max,st);


}

void change_level_final (MAP *map,STATE *st,POS max,WINDOW *wnd) {

	wclear(wnd);

    gerarMapa(map,max);
	fronteiras(map,max);
	ajustarMapa2(map,max);
	ajustarMapa(map,max);
	ajustarMapa(map,max);
	ajustarMapa3(map,max);
	fronteiras(map,max);
	gerarMobs(map,max,st);
	gerarItem(map,max,st);

	gerar(st,map,max);


}

void player_death (STATE *st,WINDOW *wnd) {

	int floor = st->floor;
	st->floor = -1;
	int floorremaining = 15 - floor;

	wclear(wnd);
	wclear(wnd);

	printw("Morreste no piso %d.\nEstavas a %d pisos de chegar ao Passadini.\nBoa sorte na proxima vez!\nAperta Q e roda ./jogo para recomecar.",floor,floorremaining);

}

void game_won (STATE *st,WINDOW *wnd) {
	st->floor = -1;
	wclear(wnd);
	wclear(wnd);

	printw("Parabens! Conseguiste infiltrar as cavernas do Passadini, derrota-lo e obter a receita secreta dele.\nO mundo sera um melhor lugar sem aquele louco!\nAgora podes abrir o teu restaurante e cozinhar sem ser incomodado!\nStats finais:\nHP: %d/%d\nLight: %d\nDmg: %d\nRadius: %d\nMobs mortos: %d\n\nObrigado por jogar o nosso jogo. Projeto feito por:\n Hugo Marques, a102934\n Jose Afonso Miranda, a102933\n Diogo Dias, a102943\n Claudia Faria, a105531\n\n\n\n\nA receita secreta e de Bacalhau com natas:\nfritar as batatas e guardar.\nlaminar as cebolas, picar os alhos, juntar azeite, louro, deixar a cebola ficar mole sem queimar.\njuntar o bacalhau esfiado cru, sem peles e sem espinhas, deixar cozer/refogar\njuntar as batatas fritas ao refugado do bacalhau, deitar as natas, noz moscada, pimenta e um quarto do bechamel, misturar tudo bem até obter uma mistura mais ou menos cremosa.\nverter o preparado num tabuleiro, barrar por cima com o resto do bechamel e levar ao forno a gratinar, mais ou menos 30/40 minutos.",st->health,st->maxhealth,st->light,st->damage,st->radius,st->mobskilled);

}
