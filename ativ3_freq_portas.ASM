;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     JULHOO DE 2024                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		
		; VARI�VEL QUE DEFINE ESTADO ATUAL
		ESTADO

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04		;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.
	
	
; SUBROTINA RESPONS�VEL POR ALTERAR VALOR DE ESTADO
; FUNCIONAMENTO
; CADA UM DOS BITS DE ENTRADA (GP0, GP1, GP2) � VERIFICADO, DE FORMA QUE
; PARA GP0 = 0 -> SA�DA GP4 EM ZERO (CONTINUA AT� QUE HAJA MUDAN�A DE GP0 PARA 1)
; � USADA A L�GICA DOS N�MEROS BIN�RIOS PARA DECIMAIS; 
; GP1 = 0 GP2 = 0 -> ESTADO 0
; GP1 = 0 GP2 = 1 -> ESTADO 1
; GP1 = 1 GP2 = 0 -> ESTADO 2
; GP1 = 1 GP2 = 1 -> ESTADO 3
ALTERA_ESTADO
	
	; CERTIFICA QUE A VARI�VEL ESTADO TEM VALOR 0 NO COME�O
	; DA EXECU��O DA SUBROTINA; ISSO � ESSENCIAL, POIS O
	; VALOR DE ESTADO N�O PODE SAIR DO INTERVALO [0, 3]
	MOVLW	.0
	MOVWF	ESTADO
	
LOOP_VERIF
	; SE 1, EXECUTA PR�X INSTRU��O; SE 0, EXECUTA SEGUNDA INSTRU��O
	BTFSC	GPIO, GP0
	; SE GP0 == 1, TEMOS UMA ONDA QUADRADA NA SA�DA
	GOTO	VERIF_GP1   ; EXECUTA A VERIFICA��O DO VALOR DE GP1
	; SE GP0 == 0, TEMOS N�VEL BAIXO/LOW NA SA�DA
	BCF	GPIO, GP4   ; CLEAR GP4
	GOTO	LOOP_VERIF  ; A VERIFICA��O PERSISTE AT� QUE GP0 MUDE PARA 1
	
VERIF_GP1
	; VERIFICA��O DO VALOR DE GP1
	; SE 0, EXECUTA PR�X INSTRU��O; SE 1, EXECUTA SEGUNDA INSTRU��O
	BTFSS	GPIO, GP1
	; SE GP1 == 0, SEGUE DIRETAMENTE PARA A VERIFICA��O DE GP2
	GOTO	VERIF_GP2
	; SE GP1 == 1, INCREMENTA 'ESTADO' DUAS VEZES (ESTADO == 2)
	INCF	ESTADO, 1
	INCF	ESTADO, 1
	
VERIF_GP2
	; VERIFICA��O DE VALOR DE GP2
	; SE 1, EXECUTA PR�X INSTRU��O; SE 0, EXECUTA SEGUNDA INSTRU��O
	BTFSC	GPIO, GP2
	; SE GP2 == 1, INCREMENTA 'ESTADO' UMA VEZ (ESTADO == 1 OU ESTADO == 3)
	INCF	ESTADO, 1
	; SE GP2 == 0, A SUBROTINA RETORNA � EXECU��O DA MAIN
	
	; A IDEIA � DE QUE, SE GP1 E GP2 S�O IGUAIS A ZERO, ESTADO N�O � INCREMENTADO
	; E, PORTANTO, TEM VALOR 0 TAMB�M
	RETURN

	
; SUBROTINA RESPONS�VEL POR VERIFICAR VALOR DE ESTADO
; A PARTIR DO ESTADO, DEFINE PRESCALER E VALOR DE OFFSET DE TMR0
VERIFICA_ESTADO
	
	; VERIFICA CADA POSSIBILIDADE (0, 1, 2, 3) PARA VALOR DE ESTADO
	
	; VERIFICA SE ESTADO == 0
	; MOVE O VALOR DE ESTADO PARA O PR�PRIO ESTADO; SE ESTADO == 0, Z EM STATUS � 1
	MOVF	ESTADO, 1
	; SE 1, PR�X INSTRU��O; SE 0, SEGUNDA INSTRU��O
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO � 0 E EXECUTAMOS O LABEL CORRESPONDENTE
	GOTO	ESTADO_EH_0
	; SE Z == 0, ESTADO � DIFERENTE DE 0
	
	; VERIFICA SE ESTADO == 1
	; DECREMENTA O VALOR DE ESTADO, RESULTADO DA OPERA��O � SALVO EM 'ESTADO'
	DECF	ESTADO, 1
	; SE 1, PR�X INSTRU��O; SE 0, SEGUNDA INSTRU��O
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO � 1 E EXECUTAMOS O LABEL CORRESPONDENTE (ESTADO - 1 => 1 - 1 = 0)
	GOTO	ESTADO_EH_1
	; SE Z == 0, CONTINUA A VERIFICAR
	
	; VERIFICA SE ESTADO == 2
	; LEMBRAR QUE AS OPERA��ES DE DECREMENTO ATUALIZAM O VALOR DE ESTADO
	DECF	ESTADO, 1
	; SE 1, PR�X INSTRU��O; SE 0, SEGUNDA INSTRU��O
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO � 2 E EXECUTAMOS O LABEL CORRESPONDENTE (ESTADO - 1 => 1 - 1 = 0)
	GOTO	ESTADO_EH_2
	; SE Z == 0, CONTINUA A VERIFICAR
	
	; VERIFICA SE ESTADO == 3
	DECF	ESTADO, 1
	; SE 1, PR�X INSTRU��O; SE 0, SEGUNDA INSTRU��O
	BTFSC	STATUS, Z
	; SE Z == 1, ESTADO � 3 E EXECUTAMOS O LABEL CORRESPONDENTE (ESTADO - 1 => 1 - 1 = 0)
	GOTO	ESTADO_EH_3
	; Z NUNCA SER� 0, AO CHEGAR NESSA VERIFICA��O
	
ESTADO_EH_0
	
	; USO DE INSTRU��ES NOP PARA ALCAN�AR TEMPO ESPERADO PARA A FREQ 
	NOP
	NOP
	
	; MOVE VALOR 139 PARA TMR0 - VALOR DE OFFSET ADEQUADO PARA A FREQ 
	MOVLW	.139
	MOVWF	TMR0
	; VAI AT� ESSE LABEL PARA ALTERAR CONFIGURA��O DE PRESCALER
	GOTO	MUDA_OPT_REG_16
	
ESTADO_EH_1
	
	; USO DE INSTRU��ES NOP PARA ALCAN�AR TEMPO ESPERADO PARA A FREQ 
	NOP
	NOP
	NOP
	
	; MOVE VALOR 169 PARA TMR0 - VALOR DE OFFSET ADEQUADO PARA A FREQ 
	MOVLW	.169
	MOVWF	TMR0
	; VAI AT� ESSE LABEL PARA ALTERAR CONFIGURA��O DE PRESCALER
	GOTO	MUDA_OPT_REG_16
	
ESTADO_EH_2
	
	; USO DE INSTRU��ES NOP PARA ALCAN�AR TEMPO ESPERADO PARA A FREQ 
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
	; PRESCALER NECESS�RIO PARA 1:16 � DE [PS2, PS0] = [011]
	; COMO PS1 E PS2 N�O MUDAM, ALTERAMOS APENAS PS0
	; SET PS0
	BSF	OPTION_REG, PS0
	BANK0	; ALTERA PARA O BANCO 0
	
	RETURN
	
ESTADO_EH_3
	
	; USO DE INSTRU��ES NOP PARA ALCAN�AR TEMPO ESPERADO PARA A FREQ 
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
	; PRESCALER NECESS�RIO PARA 1:16 � DE [PS2, PS0] = [010]
	; COMO PS1 E PS2 N�O MUDAM, ALTERAMOS APENAS PS0
	; CLEAR PS0 
	BCF	OPTION_REG, PS0
	BANK0	; ALTERA PARA O BANCO 0
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	; ENTRADAS: GP0, GP1, GP2; SA�DA: GP4
	MOVLW	B'00000111' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	; TIMER MODE ESCOLHIDO; PRESCALER DO TMR0; PRESCALER 1:16
	MOVLW	B'00000011' 
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0			;RETORNA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; FUNCIONAMENTO
	; ENTRADAS: GP0, GP1, GP2; SA�DA: GP4
	; VARI�VEL INTERMEDI�RIA USADA: ESTADO
	; TIMER0 � USADO PARA GERA��O DO SINAL DE SA�DA (UMA ONDA QUADRADA) DE ACORDO COM A FREQU�NCIA ESCOLHIDA
	; PELO USU�RIO, QUE DEFINE ESSA FREQU�NCIA A PARTIR DE GP0, GP1, GP2; TAMB�M A PARTIR DAS ENTRADAS, TEMOS
	; A DEFINI��O DE QUAL ESTADO � O ESTADO ATUAL DO PROGRAMA:
	
	; GP0 = 0, GP1 = X, GP2 = X - SA�DA EM LOW (SEM ESTADO)
	; GP0 = 1, GP1 = 0, GP2 = 0 - SA�DA EM HIGH EM FREQU�NCIA 262 Hz/1908 us    (ESTADO 0)
	; GP0 = 1, GP1 = 0, GP2 = 1 - SA�DA EM HIGH EM FREQU�NCIA 349 Hz/1432.5 us  (ESTADO 1)
	; GP0 = 1, GP1 = 1, GP2 = 0 - SA�DA EM HIGH EM FREQU�NCIA 440 Hz/1136 us    (ESTADO 2)
	; GP0 = 1, GP1 = 1, GP2 = 1 - SA�DA EM HIGH EM FREQU�NCIA 523 Hz/956 us	    (ESTADO 3)
	
	; ESTADO � USADO PARA REALIZA��O DA VERIFICA��O DA ENTRADA; A PARTIR DA VERIFICA��O, SABE-SE QUAL � A FREQ DE SA�DA,
	; QUAL O OFFSET DE TMR0 A SER USADO E QUAL PRESCALER USAR (1:16 PARA ESTADOS 0, 1, 2 | 1:8 PARA ESTADO 3)
	
	; PROGRAMA INICIA EM BANK0
	
	; CHAMADA DA SUBROTINA RESPONS�VEL POR FAZER A ALTERA��O DO ESTADO A PARTIR DE GP0, GP1, GP2
	CALL	ALTERA_ESTADO
	; A PARTIR DAQUI, TEMOS O VALOR DE ESTADO DEFINIDO
	
	; CHAMADA DA SUBROTINA RESPONS�VEL POR VERIFICAR O ESTADO E REALIZAR AS
	; DEVIDAS ALTERA��ES DE CONFIGURA��O PARA FUNCIONAMENTO DA SA�DA GP4 NA FREQU�NCIA ESPERADA
	CALL	VERIFICA_ESTADO
	
	; AP�S VERIFICA��O DO ESTADO ATUAL, A L�GICA PARA A SA�DA DE UMA ONDA QUADRADA � EXECUTADA
	
	; GARANTE QUE T0IF EST� EM ZERO (CLEAR T0IF)
	; T0IF - BIT QUE INDICA QUE HOUVE ESTOURO EM TMR0 
	BCF	INTCON, T0IF
LOOP_T0IF
	; SE 0, PR�X INSTRU��O; SE 1, SEGUNDA INSTRU��O
	BTFSS	INTCON, T0IF
	; SE T0IF == 0, CONTINUA EM LOOP AT� T0IF ATINGIR VALOR 1
	GOTO	LOOP_T0IF
	; SE T0IF == 1, HOUVE ESTOURO EM TMR0 E MUDAMOS N�VEL DA SA�DA GP4
	; SE 0, PR�X INSTRU��O; SE 1, SEGUNDA INSTRU��O
	
	; !!! BREAKPOINT NESSA LINHA SEGUINTE PARA MEDI��O DE TEMPO
	; ATEN��O! PARA GP0 == 0, A MEDI��O DE TEMPO COM BREAKPOINT AQUI N�O FUNCIONA
	; FLUXO DE EXECU��O QUANDO GP0 == 0 NUNCA CHEGA AQUI
	BTFSS	GPIO, GP4   
	
	; SE GP4 == 0, ENT�O AGORA GP4 ASSUME VALOR 1 (EST� EM LOW, PASSA PARA HIGH)
	GOTO	GP4_RECEBE_1
	; SE GP4 == 1, ENT�O AGORA GP4 ASSUME VALOR 0 (EST� EM HIGH, PASSA PARA LOW) 
	BCF	GPIO, GP4   ; CLEAR GP4
	GOTO	T0IF_RECEBE_0
	
GP4_RECEBE_1
	; ADICIONA UMA INSTRU��O NOP PARA QUE A ONDA TENHA OS MESMOS TEMPOS QUANDO EM HIGH E EM LOW
	NOP		    ; SEM ESSE NOP, OS TEMPOS DIFEREM EM 1 us
	BSF	GPIO, GP4   ; SET GP4
	
T0IF_RECEBE_0
	; GARANTE QUE T0IF EST� EM ZERO (CLEAR T0IF)
	BCF	INTCON, T0IF
	
	; LOOP DO PROGRAMA (VOLTA AO LABEL MAIN)
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
