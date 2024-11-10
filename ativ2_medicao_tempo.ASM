;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     JULHOO DE 2024                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		
		; DECLARAÇÃO DA VARIÁVEL CONTADOR_I
		CONTADOR_I
		; DECLARAÇÃO DA VARIÁVEL CONTADOR_J
		CONTADOR_J
		; FUNCIONAMENTO
		; A IDEIA É UTILIZAR AS VARIÁVEIS 'CONTADOR_I' E 'CONTADOR_J' PARA CRIAR UM LAÇO DE REPETIÇÃO ANINHADO A OUTRO LAÇO
		; A PRIMEIRA TENTATIVA PARA GERAÇÃO DE ATRASO INCLUIU APENAS UM ÚNICO CONTADOR, A IDEIA SERIA DE DAR A ELE UM VALOR
		; E ELE SERIA DECREMENTADO ATÉ O VALOR ZERO, ENTÃO A ROTINA DELAY CHEGAVA AO FIM E O FLUXO DE EXECUÇÃO VOLTAVA À MAIN
		; MAS O USO DE SÓ UM CONTADOR NÃO FOI SUFICIENTE: O ATRASO MÁXIMO FOI DE (APROX.) 1.028 ms COM CONTADOR DE VALOR 255
		; O LIMITE DE TAMANHO PARA UMA VARIÁVEL COMO AS DECLARADAS ACIMA É DE 255
		; ASSIM, A IMPLEMENTAÇÃO ATUAL TRAZ DOIS CONTADORES; 'CONTADOR_I' É DECREMENTADO ATÉ ZERO, APÓS ISSO
		; 'CONTADOR_J' É DECREMENTADO E, SE FOR IGUAL A ZERO, É O FIM DA ROTINA DELAY; CASO CONTRÁRIO, O FLUXO DE
		; EXECUÇÃO VOLTA AO COMEÇO DA ROTINA EM QUE 'CONTADOR_I' É DECREMENTADO NOVAMENTE (LAÇOS DE REPETIÇÃO ANINHADOS)
		

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

DELAY
	; É NECESSÁRIO DEFINIR O VALOR DE 'CONTADOR_I' ANTES DOS DECREMENTOS EM LOOP
	; CASO CONTRÁRIO, O PROGRAMA TEM COMPORTAMENTO QUE NÃO É ESPERADO ('CONTADOR_I' 
	; CHEGA A ZERO, E A REPETIÇÃO SEGUINTE DECREMENTA ZERO; A VARIÁVEL PASSA A TER VALOR 255) 
	
	; MOVE O NÚMERO DECIMAL PARA O REGISTRADOR WORK (WREG)
	MOVLW	.146	      ; 1us
	; MOVE O VALOR ARMAZENADO EM WORK (WREG) PARA A VARIÁVEL 'CONTADOR'
	MOVWF	CONTADOR_I    ; 1us 

VOLTA_FOR_I
	
	; DECF f, d - DECREMENTA (- 1) VALOR NO REGISTRADOR
	; SE 'd' É 1, RESULTADO DA OPERAÇÃO É GUARDADO EM f
	DECF	CONTADOR_I, 1 ; 1us
	
	; BTFSS f, b - VERIFICA BIT 'b' DO REGISTRADOR 'f'
	; SE 'b' É 0, EXECUTA A PRÓXIMA INSTRUÇÃO
	; SE 'b' É 1, DESCONSIDERA A PRÓXIMA INSTRUÇÃO, EXECUTA A SEGUINTE
	BTFSS	STATUS, Z     ; 1us
	; VERIFICA BIT 'Z' DO REGISTRADOR 'STATUS'
	
	; SE 'CONTADOR_I' NÃO É ZERO, 'Z' DE 'STATUS' É IGUAL A 0
	; SE 'CONTADOR_I' NÃO É ZERO, CONTADOR CONTINUA A DECREMENTAR (AINDA ESTAMOS NO LAÇO)
	GOTO	VOLTA_FOR_I   ; 2us

	; SE 'CONTADOR_I' CHEGA A ZERO, 'Z' DE 'STATUS' É IGUAL A 1
	; SE 'CONTADOR_I' CHEGA A ZERO, O LAÇO DE REPET CHEGA AO FIM E PASSAMOS À INSTRUÇÃO ABAIXO
	
	; ESTA PARTE DIZ RESPEITO AO LAÇO DE REPETIÇÃO QUE DECREMENTA A VARIÁVEL 'CONTADOR_J'
	; SÃO AS MESMAS OPERAÇÕES VISTAS PARA O 'CONTADOR_I'
	DECF	CONTADOR_J, 1 ; 1us
	BTFSS	STATUS, Z     ; 1us
	
	; SE 'CONTADOR_J' NÃO É ZERO, 'Z' DE 'STATUS' É IGUAL A 0
	; SE 'CONTADOR_J' NÃO É ZERO, AINDA ESTAMOS NO LAÇO
	GOTO	DELAY	      ; 2us
	
	; SE 'CONTADOR_J' CHEGA A ZERO, 'Z' DE 'STATUS' É IGUAL A 1
	; SE 'CONTADOR_J' CHEGA A ZERO, O LAÇO DE REPET CHEGA AO FIM E RETORNA À MAIN
	RETURN		      ; 2us
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	; A VARIÁVEL PODE SER INICIALIZADA AQUI, MAS PRECISA ASSUMIR SEU VALOR INICIAL A TODO NOVO COMEÇO DE LOOP
	; ENTÃO EU RESOLVI MANTER A MUDANÇA DE SEU VALOR ANTES DA CHAMADA DA ROTINA DE DELAY

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; FUNCIONAMENTO
	; BASICAMENTE, A PORTA DE SAÍDA GP5 É USADA PARA DEMONSTRAR O ATRASO GERADO PELO CÓDIGO
	; ENTÃO, GP5 ASSUME O VALOR BAIXO, O TEMPO DE ATRASO É GERADO COM A UTILIZAÇÃO DA SUBROTINA
	; DELAY QUE CHEGA AO FIM E RETORNA AO FLUXO NA MAIN, ENTÃO GP5 ASSUME O VALOR ALTO, LOGO 
	; TAMBÉM USANDO A SUBROTINA DELAY; ASSIM, O PROGRAMA REPETE ESSE FLUXO DE EXECUÇÃO
	; (EXPLICAÇÕES DE FUNCIONAMENTO EM DEFINIÇÃO DAS VARIÁVEIS E IMPLEMENTAÇÃO DA SUBR. DELAY)
	
	; OS BREAKPOINTS NAS INSTRUÇÕES 'BCF' E 'BSF' SÃO USADOS PARA MEDIR O TEMPO DE ATRASO
	; OS BREAKPOINTS SÃO COLOCADOS NA INSTRUÇÃO QUE REALIZA A MUDANÇA DE ESTADO DE GP5

	; BCF f, b - O BIT 'b' DO REGISTRADOR 'f' PASSA A TER VALOR ZERO
	; PARA MEDIÇÃO DE TEMPO, BREAKPOINT FOI COLOCADO NA INSTRUÇÃO ABAIXO
	BCF	GPIO, GP5   ; 1us
	
	; FORAM INSERIDOS DUAS INST. NOP PARA MANTER OS TEMPOS IGUAIS (GP5 ALTO E BAIXO)
	NOP		    ; 1us
	NOP		    ; 1us
	
	; FORAM FEITAS VÁRIAS TENTATIVAS DE VALORES PARA 'CONTADOR_I' E 'CONTADOR_J' QUE SE
	; APROXIMASSEM DO TEMPO DE ATRASO DESEJADO DE 31.25 ms; NENHUMA ALCANÇOU O VALOR EXATO
	; MAS, PARA OS VALORES ATUAIS DE 'CONTADOR_I' E 'CONTADOR_J', FOI OBTIDO O TEMPO DE
	; 31.225 ms, O MAIS PRÓXIMO QUE PUDE ENCONTRAR.
	; ASSIM, CONSIDEREI QUE A NECESSIDADE DE SE ALCANÇAR O TEMPO DE ATRASO É MAIS CRÍTICO,
	; POIS É NECESSÁRIA PRECISÃO PARA GERAÇÃO DO ATRASO E UM VALOR ACIMA OU ABAIXO, A DEPENDER
	; DA APLICAÇÃO, PODERIA TRAZER RESULTADOS PRÁTICOS INSATISFATÓRIOS
	; ENTÃO FOI NECESSÁRIO ADICIONAR 25 INSTRUÇÕES NOP PARA ATINGIR O REQUISITO
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	
	; MOVE O NÚMERO DECIMAL PARA O REGISTRADOR WORK (WREG)
	MOVLW	.53	    ; 1us
	; MOVE O VALOR ARMAZENADO EM WORK (WREG) PARA A VARIÁVEL 'CONTADOR'
	MOVWF	CONTADOR_J  ; 1us 
	
	; CHAMA ROTINA DELAY (DIRIGE FLUXO DE EXECUÇÃO PARA A ROTINA)
	CALL	DELAY	    ; 2us
	
	; BSF f, b - O BIT 'b' DO REGISTRADOR 'f' PASSA A TER VALOR UM
	; PARA MEDIÇÃO DE TEMPO, BREAKPOINT FOI COLOCADO NA INSTRUÇÃO ABAIXO
	BSF	GPIO, GP5   ; 1us
	
	; AS 25 INSTRUÇÕES NOP FORAM ADICIONADAS AQUI TAMBÉM PARA PARA MANTER OS TEMPOS IGUAIS (GP5 ALTO E BAIXO)
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	NOP		    ; 1us
	
	; MOVE O NÚMERO DECIMAL PARA O REGISTRADOR WORK (WREG)
	MOVLW	.53	    ; 1us
	; MOVE O VALOR ARMAZENADO EM WORK (WREG) PARA A VARIÁVEL 'CONTADOR'
	MOVWF	CONTADOR_J  ; 1us 
	
	; CHAMA ROTINA DELAY (DIRIGE FLUXO DE EXECUÇÃO PARA A ROTINA)
	CALL	DELAY	    ; 2us
	
	; VOLTA PARA O COMEÇO DO PROGRAMA (LABEL MAIN) E REPETE A EXECUÇÃO
	GOTO	MAIN	    ; 2us

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
