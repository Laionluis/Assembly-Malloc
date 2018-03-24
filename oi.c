// wget www.inf.ufpr.br/bmuller/CI064/teste.c . 


#include <stdio.h>

main () {
	void *a,*b,*c,*d;
	iniciaAlocador();
	a=( void * ) alocaMem(100);
	 imprMapa();
	b=( void * ) alocaMem(200);
	 imprMapa();
	c=( void * ) alocaMem(300);
	 imprMapa();
	d=( void * ) alocaMem(400);
	 imprMapa();

	liberaMem(b);
	imprMapa(); 
	
	b=( void * ) alocaMem(50);
	 imprMapa();
	
	liberaMem(c);
	 imprMapa(); 
	liberaMem(a);
	 imprMapa();
	liberaMem(b);
	 imprMapa();
	liberaMem(d);
	 imprMapa();

	finalizaAlocador();
}
