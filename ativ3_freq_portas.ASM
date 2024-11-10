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
		
		; VARIÁVEL QUE DEFINE ESTADO ATUAL
		ESTADO

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

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

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
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
	
	
; SUBROTINA RESPONSÁVEL POR ALTERAR VALOR DE ESTADO
; FUNCIONAMENTO
; CADA UM DOS BITS DE ENTRADA (GP0, GP1, GP2) É VERIFICADO, DE FORMA QUE
; PARA GP0 = 0 -> SAÍDA GP4 EM ZERO (CONTINUA ATÉ QUE HAJA MUDANÇA DE GP0 PARA 1)
; É USADA A LÓGICA DOS NÚMEROS BINÁRIOS PARA DECIMAIS; 
; GP1 = 0 GP2 = 0 -> ESTADO 0
; GP1 = 0 GP2 = 1 -> ESTADO 1
; GP1 = 1 GP2 = 0 -> ESTADO 2
; GP1 = 1 GP2 = 1 -> ESTADO 3
ALTERA_ESTADO
	
	; CERTIFICA QUE A VARIÁVEL ESTADO TEM VALOR 0 NO COMEÇO
	; DA EXECUÇÃO DA SUBROTINA; ISSO É ESSENCIAL, POIS O
	; VALOR DE ESTADO NÃO PODE SAIR DO INTERVALO [0, 3]
	MOVLW	.0
	MOVWF	ESTADO
	
LOOP_VERIF
	; SE 1, EXECUTA PRÓX INSTRUÇÃO; SE 0, EXECUTA SEGUNDA INSTRUÇÃO
	BTFSC	GPIO, GP0
	; SE GP0 == 1, TEMOS UMA ONDA QUADRADA NA SAÍDA
	GOTO	VERIF_GP1   ; EXECUTA A VERIFICAÇÃO DO VALOR DE GP1
	; SE GP0 == 0, TEMOS NÍVEL BAIXO/LOW NA SAÍDA
	BCF	GPIO, GP4   ; CLEAR GP4
	GOTO	LOOP_VERIF  ; A VERIFICAÇÃO PERSISTE ATÉ QUE GP0 MUDE PARA 1
	
VERIF_GP1
	; VERIFICAÇÃO DO VALOR DE GP1
	; SE 0, EXECUTA PRÓX INSTRUÇÃO; SE 1, EXECUTA SEGUNDA INSTRUÇÃO
	BTFSS	GPIO, GP1
	; SE GP1 == 0, SEGUE DIRETAMENTE PARA A VERIFICAÇÃO DE GP2
	GOTO	VERIF_GP2
	; SE GP1 == 1, INCREMENTA 'ESTADO' DUAS VEZES (ESTADO == 2)
	INCF	ESTADO, 1
	INCF	ESTADO, 1
	
VERIF_GP2
	; VERIFICAÇÃO DE VALOR DE GP2
	; SE 1, EXECUTA PRÓX INSTRUÇÃO; SE 0, EXECUTA SEGUNDA INSTRUÇÃO
	BTFSC	GPIO, GP2
	; SE GP2 == 1, INCREMENTA 'ESTADO' UMA VEZ (ESTADO == 1 OU ESTADO == 3)
	INCF	ESTADO, 1
	; SE GP2 == 0, A SUBROTINA RETORNA À EXECUÇÃO DA MAIN
	
	; A IDEIA É DE QUE, SE GP1 E GP2 SÃO IGUAIS A ZERO, ESTADO NÃO É INCREMENTADO
	; E, PORTANTO, TEM VALOR 0 TAMBÉM
	RETURN

	
; SUBROTINA RESPONSÁVEL POR VERIFICAR VALOR DE ESTADO
; A PARTIR DO ESTADO, DEFINE PRESCALER E VALOR DE OFFSET DE TMR0
VERIFICA_ESTADO
	
	; VERIFICA CADA POSSIBILIDADE (0, 1, 2, 3) PARA VALOR DE ESTADO
	
	; VERIFICA SE ESTADO == 0
	; MOVE O VALOR DE ESTADO PARA O PRÓPRIO ESTADO; SE ESTADO == 0, Z EM STATUS É 1
	MOVF	ESTADO, 1
	; SE 1, PRÓX INSTRUÇÃO; SE 0, SEGUNDA INSTRUÇÃO
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO É 0 E EXECUTAMOS O LABEL CORRESPONDENTE
	GOTO	ESTADO_EH_0
	; SE Z == 0, ESTADO É DIFERENTE DE 0
	
	; VERIFICA SE ESTADO == 1
	; DECREMENTA O VALOR DE ESTADO, RESULTADO DA OPERAÇÃO É SALVO EM 'ESTADO'
	DECF	ESTADO, 1
	; SE 1, PRÓX INSTRUÇÃO; SE 0, SEGUNDA INSTRUÇÃO
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO É 1 E EXECUTAMOS O LABEL CORRESPONDENTE (ESTADO - 1 => 1 - 1 = 0)
	GOTO	ESTADO_EH_1
	; SE Z == 0, CONTINUA A VERIFICAR
	
	; VERIFICA SE ESTADO == 2
	; LEMBRAR QUE AS OPERAÇÕES DE DECREMENTO ATUALIZAM O VALOR DE ESTADO
	DECF	ESTADO, 1
	; SE 1, PRÓX INSTRUÇÃO; SE 0, SEGUNDA INSTRUÇÃO
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO É 2 E EXECUTAMOS O LABEL CORRESPONDENTE (ESTADO - 1 => 1 - 1 = 0)
	GOTO	ESTADO_EH_2
	; SE Z == 0, CONTINUA A VERIFICAR
	
	; VERIFICA SE ESTADO == 3
	DECF	ESTADO, 1
	; SE 1, PRÓX INSTRUÇÃO; SE 0, SEGUNDA INSTRUÇÃO
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO É 3 E EXECUTAMOS O LABEL CORRESPONDENTE (ESTADO - 1 => 1 - 1 = 0)
	GOTO	ESTADO_EH_3
	; Z NUNCA SERÁ 0, AO CHEGAR NESSA VERIFICAÇÃO
	
ESTADO_EH_0
	
	; USO DE INSTRUÇÕES NOP PARA ALCANÇAR TEMPO ESPERADO PARA A FREQ 
	NOP
	NOP
	
	; MOVE VALOR 139 PARA TMR0 - VALOR DE OFFSET ADEQUADO PARA A FREQ 
	MOVLW	.139
	MOVWF	TMR0
	; VAI ATÉ ESSE LABEL PARA ALTERAR CONFIGURAÇÃO DE PRESCALER
	GOTO	MUDA_OPT_REG_16
	
ESTADO_EH_1
	
	; USO DE INSTRUÇÕES NOP PARA ALCANÇAR TEMPO ESPERADO PARA A FREQ 
	NOP
	NOP
	NOP
	
	; MOVE VALOR 169 PARA TMR0 - VALOR DE OFFSET ADEQUADO PARA A FREQ 
	MOVLW	.169
	MOVWF	TMR0
	; VAI ATÉ ESSE LABEL PARA ALTERAR CONFIGURAÇÃO DE PRESCALER
	GOTO	MUDA_OPT_REG_16
	
ESTADO_EH_2
	
	; USO DE INSTRUÇÕES NOP PARA ALCANÇAR TEMPO ESPERADO PARA A FREQ 
	NOP
	NOP
	NOP
	NOP
	NOP
	
	; MOVE VALOR 188 PARA TMR0 - VALOR DE OFFSET ADEQUADO PARA A FREQ 
	MOVLW	.188
	MOVWF	TMR0
	
MUDA_OPT_REG_16
	
	BANK1	; ALTERA PARA O BANCO 1
	; PRESCALER NECESSÁRIO PARA 1:16 É DE [PS2, PS0] = [011]
	; COMO PS1 E PS2 NÃO MUDAM, ALTERAMOS APENAS PS0
	; SET PS0
	BSF	OPTION_REG, PS0
	BANK0	; ALTERA PARA O BANCO 0
	
	RETURN
	
ESTADO_EH_3
	
	; USO DE INSTRUÇÕES NOP PARA ALCANÇAR TEMPO ESPERADO PARA A FREQ 
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	
	; MOVE VALOR 143 PARA TMR0 - VALOR DE OFFSET ADEQUADO PARA A FREQ 
	MOVLW	.143
	MOVWF	TMR0
	
MUDA_OPT_REG_8
	
	BANK1	; ALTERA PARA O BANCO 1
	; PRESCALER NECESSÁRIO PARA 1:16 É DE [PS2, PS0] = [010]
	; COMO PS1 E PS2 NÃO MUDAM, ALTERAMOS APENAS PS0
	; CLEAR PS0 
	BCF	OPTION_REG, PS0
	BANK0	; ALTERA PARA O BANCO 0
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	; ENTRADAS: GP0, GP1, GP2; SAÍDA: GP4
	MOVLW	B'00000111' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	; TIMER MODE ESCOLHIDO; PRESCALER DO TMR0; PRESCALER 1:16
	MOVLW	B'00000011' 
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0			;RETORNA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; FUNCIONAMENTO
	; ENTRADAS: GP0, GP1, GP2; SAÍDA: GP4
	; VARIÁVEL INTERMEDIÁRIA USADA: ESTADO
	; TIMER0 É USADO PARA GERAÇÃO DO SINAL DE SAÍDA (UMA ONDA QUADRADA) DE ACORDO COM A FREQUÊNCIA ESCOLHIDA
	; PELO USUÁRIO, QUE DEFINE ESSA FREQUÊNCIA A PARTIR DE GP0, GP1, GP2; TAMBÉM A PARTIR DAS ENTRADAS, TEMOS
	; A DEFINIÇÃO DE QUAL ESTADO É O ESTADO ATUAL DO PROGRAMA:
	
	; GP0 = 0, GP1 = X, GP2 = X - SAÍDA EM LOW (SEM ESTADO)
	; GP0 = 1, GP1 = 0, GP2 = 0 - SAÍDA EM HIGH EM FREQUÊNCIA 262 Hz/1908 us    (ESTADO 0)
	; GP0 = 1, GP1 = 0, GP2 = 1 - SAÍDA EM HIGH EM FREQUÊNCIA 349 Hz/1432.5 us  (ESTADO 1)
	; GP0 = 1, GP1 = 1, GP2 = 0 - SAÍDA EM HIGH EM FREQUÊNCIA 440 Hz/1136 us    (ESTADO 2)
	; GP0 = 1, GP1 = 1, GP2 = 1 - SAÍDA EM HIGH EM FREQUÊNCIA 523 Hz/956 us	    (ESTADO 3)
	
	; ESTADO É USADO PARA REALIZAÇÃO DA VERIFICAÇÃO DA ENTRADA; A PARTIR DA VERIFICAÇÃO, SABE-SE QUAL É A FREQ DE SAÍDA,
	; QUAL O OFFSET DE TMR0 A SER USADO E QUAL PRESCALER USAR (1:16 PARA ESTADOS 0, 1, 2 | 1:8 PARA ESTADO 3)
	
	; PROGRAMA INICIA EM BANK0
	
	; CHAMADA DA SUBROTINA RESPONSÁVEL POR FAZER A ALTERAÇÃO DO ESTADO A PARTIR DE GP0, GP1, GP2
	CALL	ALTERA_ESTADO
	; A PARTIR DAQUI, TEMOS O VALOR DE ESTADO DEFINIDO
	
	; CHAMADA DA SUBROTINA RESPONSÁVEL POR VERIFICAR O ESTADO E REALIZAR AS
	; DEVIDAS ALTERAÇÕES DE CONFIGURAÇÃO PARA FUNCIONAMENTO DA SAÍDA GP4 NA FREQUÊNCIA ESPERADA
	CALL	VERIFICA_ESTADO
	
	; APÓS VERIFICAÇÃO DO ESTADO ATUAL, A LÓGICA PARA A SAÍDA DE UMA ONDA QUADRADA É EXECUTADA
	
	; GARANTE QUE T0IF ESTÁ EM ZERO (CLEAR T0IF)
	; T0IF - BIT QUE INDICA QUE HOUVE ESTOURO EM TMR0 
	BCF	INTCON, T0IF
LOOP_T0IF
	; SE 0, PRÓX INSTRUÇÃO; SE 1, SEGUNDA INSTRUÇÃO
	BTFSS	INTCON, T0IF
	; SE T0IF == 0, CONTINUA EM LOOP ATÉ T0IF ATINGIR VALOR 1
	GOTO	LOOP_T0IF
	; SE T0IF == 1, HOUVE ESTOURO EM TMR0 E MUDAMOS NÍVEL DA SAÍDA GP4
	; SE 0, PRÓX INSTRUÇÃO; SE 1, SEGUNDA INSTRUÇÃO
	
	; !!! BREAKPOINT NESSA LINHA SEGUINTE PARA MEDIÇÃO DE TEMPO
	; ATENÇÃO! PARA GP0 == 0, A MEDIÇÃO DE TEMPO COM BREAKPOINT AQUI NÃO FUNCIONA
	; FLUXO DE EXECUÇÃO QUANDO GP0 == 0 NUNCA CHEGA AQUI
	BTFSS	GPIO, GP4   
	
	; SE GP4 == 0, ENTÃO AGORA GP4 ASSUME VALOR 1 (ESTÁ EM LOW, PASSA PARA HIGH)
	GOTO	GP4_RECEBE_1
	; SE GP4 == 1, ENTÃO AGORA GP4 ASSUME VALOR 0 (ESTÁ EM HIGH, PASSA PARA LOW) 
	BCF	GPIO, GP4   ; CLEAR GP4
	GOTO	T0IF_RECEBE_0
	
GP4_RECEBE_1
	; ADICIONA UMA INSTRUÇÃO NOP PARA QUE A ONDA TENHA OS MESMOS TEMPOS QUANDO EM HIGH E EM LOW
	NOP		    ; SEM ESSE NOP, OS TEMPOS DIFEREM EM 1 us
	BSF	GPIO, GP4   ; SET GP4
	
T0IF_RECEBE_0
	; GARANTE QUE T0IF ESTÁ EM ZERO (CLEAR T0IF)
	BCF	INTCON, T0IF
	
	; LOOP DO PROGRAMA (VOLTA AO LABEL MAIN)
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
