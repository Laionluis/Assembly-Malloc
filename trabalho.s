
.section .data
	inicioHeap: .quad 0
	topoHeap: .quad 0
	header: .string "################"
	byte_ocupado: .string "+"
	byte_livre: .string "-"
	pula_linha: .string "\n "

.section .text

.globl iniciaAlocador
.type iniciaAlocador, @function

iniciaAlocador:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %rdi
	movq $12, %rax
	syscall
	movq %rax, topoHeap
	movq %rax, inicioHeap
	popq %rbp
	ret

.globl finalizaAlocador
.type finalizaAlocador, @function

finalizaAlocador:
	pushq %rbp
	movq %rsp, %rbp
	movq inicioHeap, %rdi                  	
	movq $12, %rax
	syscall
	popq %rbp
	ret

.globl liberaMem
.type liberaMem, @function

liberaMem:
	pushq %rbp
	movq %rsp, %rbp

	movq topoHeap, %rcx								# %rcx = topoHeap
	movq inicioHeap, %r14

	movq %rdi, %r10									# grava o endereco de memoria em %r10
	subq $16, %r10
	movq 8(%r10), %r9
	movq $0, (%r10)									# grava 0 no campo livre

	movq %r14, %r10									# coloca o inicioHeap em %r10

	loopezera:

		cmpq $1, 0(%r10)							# sempre verifica se o inicio da heap e tambem se o bloco que voce quer juntar está ocupado
		je continua2				

		movq 8(%r10), %r9 							# pula pro
		addq $16, %r9								# proximo
		addq %r9, %r10								# bloco

		cmpq %r10, %rcx								# se for topo, ele pula para o fim
		je fim2
		movq 0(%r10), %r9
		cmpq $0, 0(%r10)							# se for zero, quer dizer que está livre, pula para o continua
		je continua
		cmpq $1, 0(%r10)							# garante que nao tá comparando com lixo de memoria
		je continua2								# se tiver comparando com algum lixo, para de juntar os blocos livres e sai da função
		jmp fim2

													# tem que pular duas vezes de bloco, porque voce une de dois em dois, ou seja
													# se o bloco que voce verificou à frente estiver em 1, você tem que ir pro próximo bloco e verificar se ele é zero
													# pra daí sim poder unir
													# exemplo: 0 100 ------- 0 100 ------- 1 100 ------- 0 100 ------- 0 100 ------- topo
													# une os dois primeiros 0 200 ---------1 100 ------- 0 100 ------- 0 100 ------- topo
													# tenta unir com o proximo, nota que é 1, tem que passar pro proximo bloco pra daí poder unir 2
													# une os outros dois 0 200 ----------- 1 100 ------- 0 200 ------------ topo, sai da função

	continua2:

		movq 8(%r10), %r9							# pula para
		addq $16, %r9								# proximo
		addq %r9, %r10								# bloco
		cmpq %r10, %rcx								# se for topo, ele pula para o fim
		je fim2
		jmp loopezera

	continua:

		movq 8(%r10), %r8   						# pega tamanho q esta no bloco
		addq $16, %r8								# soma 16 para todos os bytes até o prox bloco
		subq %r9, %r10
		subq $16, %r9
		addq %r9, %r8
		movq %r8, 8(%r10)
		jmp loopezera

	fim2:
		popq %rbp
		ret



.globl alocaMem
.type alocaMem, @function

alocaMem:
	pushq %rbp
	movq %rsp, %rbp

	movq inicioHeap, %r15							# %r15 = inicioHeap
	movq topoHeap, %rcx								# %rcx = topoHeap
	movq %rdi, %r8								    # %r8 = num_bytes

	
	loop:
		cmpq %rcx , %r15							# if (%r15 == topoHeap)
		je aumentaHeap								# vai para o aloca 
		
		movq 0(%r15), %r9
		cmpq $0, 0(%r15)							# if (campo livre == 0)
		je compara_tam								# compara se num_bytes e menor ou igual ao tamanho alocado
													
		movq 8(%r15), %r9							# guarda tam da estrutura em %r9
		addq $16, %r9								# pula para o inicio da memoria alocada
		addq %r9, %r15								# %r15 pula para a proxima estrutura

		jmp loop									# tenta alocar de novo

	compara_tam:
		movq 8(%r15), %r13
		subq $16, %r13
		cmpq %r13, %r8								# compara num_bytes com tam
		jl aloca_menor								# se for menor, aloca							
		cmpq 8(%r15),%r8							# compara de novo
		je aloca_igual								# se for igual, aloca
													# se for maior:
		movq 8(%r15), %r9							# guarda tam da estrutura em %r9
		addq $16, %r9								# pula para o inicio da memoria alocada
		addq %r9, %r15								# %r15 pula para a proxima estrutura
		jmp loop									# tenta alocar de novo

	aloca_menor:
		movq $1, 0(%r15)							# marca como ocupado
		movq %r15, %r14
		addq $16, %r14
		movq %r14, %rax
		movq 8(%r15), %r10							# guarda o valor tam antigo em %r10
		movq %r8, 8(%r15)
		addq $16, %r15								# pula para o inicio da memoria alocada
		addq %r8, %r15								# pula para o final da estrutura
		movq $0, 0(%r15)							# marca a proxima estrutura como livre
		movq %r8, 8(%r15)							# guarda o valor num_bytes no campo tam
		subq 8(%r15), %r10							# subtrai 8(%r15) de %r10
		subq $16, %r10								# subtrai 16 de %r10
		movq %r10, 8(%r15)							# guarda o valor %r10 - 8(%r15) - 16 no campo tam
		jmp fim 									# termina de alocar

	aloca_igual:
		movq $1, 0(%r15)							# marca como ocupado
		addq $16, %r15
		movq %r15, %rax
		jmp fim										# termina de alocar
 
 	aumentaHeap:

 		movq $4080, %r12

 	loopzinho:
 		cmpq %r12, %r8
 		jl aloca

 		addq $4080, %r12
 		jmp loopzinho

	aloca:
		#movq %r8, %r12								# r8 é o num_bytes, e r12 um temporario
		movq topoHeap, %rdi							# coloca topo atual na rdi
		addq $16, %r12								# adiciona 16, q sao os campos de ocupacao e tam
		addq %r12, %rdi								# e manda aumentar a heap
		movq $12, %rax
		syscall
		movq $0, %rdi								# faz syscall para pegar topoheap atual
		movq $12, %rax
		syscall
		movq %rax, topoHeap 						
		subq %r12, %rax								# coloca "endereco" no bloco que acabou de alocar
		movq %rax, %r14								

		movq $1, 0(%r14)						    # marca como ocupado
		movq %r8, 8(%r14)							# grava num_bytes no campo do tamanho

		addq $16, %r8
		addq %r8, %r14
		movq $0, 0(%r14)
		subq %r8, %r12
		movq %r12, 8(%r14)
		
		addq $16, %r15
		movq %r15, %rax
		jmp fim

	fim:
		popq %rbp
		ret

.globl imprMapa
.type imprMapa, @function

imprMapa:
	pushq %rbp
	movq %rsp, %rbp
	movq inicioHeap, %r14
	movq topoHeap, %r12
	loop_impr:
		cmpq %r14, %r12						#compara inicioHeap com topoHeap
		je fim_impr							#se for igual termina
		movq 8(%r14), %r15					#%r15 = tam
		cmpq $0, (%r14)						#se bloco estiver livre
		je imprLivre						#pula para imprLivre
	imprOcupado:							#se nao imprOcupado
		movq $header, %rdi					
		call printf							#imprime o cabecalho
		movq $0, %r13						# %r10 = 1
	loop_ocupado:
		movq $byte_ocupado, %rdi			
		call printf							# imprime + para byte ocupado
		addq $1, %r13						# %r13++
		cmpq %r15, %r13						# se %r13 >= %r15
		jge fim_loop_ocupado				# termina
		cmpq $50000, %r15
		jg fim_impr
		jmp loop_ocupado 					# senao imprime mais
	fim_loop_ocupado:
		addq $16, %r14
		addq %r15, %r14
		jmp loop_impr
	imprLivre:
		movq $header, %rdi
		call printf
		movq $0, %r13
	loop_livre:
		movq $byte_livre, %rdi
		call printf
		addq $1, %r13
		cmpq %r15, %r13
		jge fim_loop_livre
		jmp loop_livre
	fim_loop_livre:
		addq $16, %r14
		addq %r15, %r14
		jmp loop_impr

	fim_impr:
		movq $pula_linha, %rdi
		call printf
		popq %rbp
		ret







