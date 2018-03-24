all:
	as -g trabalho.s -o trabalho.o
	ld -g trabalho.o -e iniciaAlocador -lc -o trabalho
	ld -g trabalho.o -e alocaMem -lc -o trabalho
	ld -g trabalho.o -e liberaMem -lc -o trabalho
	ld -g trabalho.o -e finalizaAlocador -lc -o trabalho
	ld -g trabalho.o -e imprMapa -lc -o trabalho
	gcc -g -o oi oi.c trabalho.s
