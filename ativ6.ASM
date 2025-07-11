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

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	; INTERRUP��ES PARA ESTOURO DE TMR1 E PARA FIM DE PROCESSAMENTO DE UMA CONVERS�O DO CAD
	
	; VERIFICA SE INTERRUP��O FOI DO TIMER1
	BTFSS	PIR1, TMR1IF
	; SE PIR1 = 0, EXECUTA PRIMEIRA INSTRU��O
	GOTO	INTERR_CAD ; TRATAMOS A INTERRUP��O DO CAD
	; SE PIR1 = 1, EXECUTA SEGUNDA INSTRU��O
	
	; SEGUIMOS COM O TRATAMENTO DA INTERRUP��O DE TMR1
	
	; DESABILITA FLAG DE INTERRUP��O DE TMR1
	BCF	PIR1, TMR1IF
	; REDEFINIMOS OFFSET DE TMR1
	MOVLW	B'00111100'
	MOVWF	TMR1H
	MOVLW	B'10101111'
	MOVWF	TMR1L
	; ATIVA UMA CONVERS�O DO CAD
	BSF	ADCON0, 1
	
	GOTO	SAI_INT
	
INTERR_CAD 
	; TRATAMENTO DA INTERRUP��O DO CAD
	
	; DESABILITA FLAG DE INTERRUP��O DE CAD
	BCF	PIR1, ADIF
	
	MOVLW	.25
	; SUBTRA��O � USADA PARA SABER SE ADRESH (EM WORK) � MENOR QUE 0.5V (VALOR EQUIVALENTE A 25 EM TERMOS DO CONVERSOR)
	SUBWF	ADRESH, W
	
	; ADRESH > 0.5V E O RESULTADO � POSITIVO - E O CARRY � 1
	; ADRESH < 0.5V E O RESULTADO � NEGATIVO - E O CARRY � 0
	
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0000 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 1.0V
	MOVLW	.51
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0001 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 1.5V
	MOVLW	.76
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0010 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 2.0V
	MOVLW	.102
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0011 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 2.5V
	MOVLW	.127
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0100 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 3.0V
	MOVLW	.153
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0101 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 3.5V
	MOVLW	.178
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0110 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 4.0V
	MOVLW	.204
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_0111 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	
	; CONTINUA VERIFICANDO VALOR DE TENS�O DE ENTRADA
	; VERIFICA COM 4.5V
	MOVLW	.229
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRU��O
	GOTO	LABEL_1000 ; DEFINE SA�DA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRU��O
	GOTO	LABEL_1001
	
	; ABAIXO, CADA LABEL � USADO PARA AS SA�DAS POSS�VEIS SOLICITADAS PARA A ATIVIDADE
LABEL_0000
	BCF	GPIO, GP5
	BCF	GPIO, GP4
	BCF	GPIO, GP1
	BCF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0001
	BCF	GPIO, GP5
	BCF	GPIO, GP4
	BCF	GPIO, GP1
	BSF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0010	
	BCF	GPIO, GP5
	BCF	GPIO, GP4
	BSF	GPIO, GP1
	BCF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0011	
	BCF	GPIO, GP5
	BCF	GPIO, GP4
	BSF	GPIO, GP1
	BSF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0100	
	BCF	GPIO, GP5
	BSF	GPIO, GP4
	BCF	GPIO, GP1
	BCF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0101	
	BCF	GPIO, GP5
	BSF	GPIO, GP4
	BCF	GPIO, GP1
	BSF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0110	
	BCF	GPIO, GP5
	BSF	GPIO, GP4
	BSF	GPIO, GP1
	BCF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_0111	
	BCF	GPIO, GP5
	BSF	GPIO, GP4
	BSF	GPIO, GP1
	BSF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_1000	
	BSF	GPIO, GP5
	BCF	GPIO, GP4
	BCF	GPIO, GP1
	BCF	GPIO, GP0
	GOTO	SAI_INT
	
LABEL_1001
	BSF	GPIO, GP5
	BCF	GPIO, GP4
	BCF	GPIO, GP1
	BSF	GPIO, GP0
	GOTO	SAI_INT
	
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

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	
	; GP2 COMO ENTRADA; GP0, GP1, GP4, GP5 COMO SA�DAS
	MOVLW	B'00000100' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	
	; DEFINE GP2 COMO ENTRADA ANAL�GICA (AN2)
	; DEFINE CLOCK DO CONVERSOR
	MOVLW	B'00010100' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	ANSEL
	
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	
	; HABILITA INTERRUP��ES GLOBAL E DE PERIF�RICOS
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	
	; HABILITA INTERRUP��ES DO CONVERSOR A/D E DO TIMER1
	MOVLW	B'01000001' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	PIE1
	
	BANK0			;RETORNA PARA O BANCO 0
	
	; DEFINE CONFIGURA��ES DO CAD
	; JUSTIFICADO � ESQUERDA (USAMOS 8 BITS)
	; TENS�O DE REFER�NCIA � VDD
	; CANAL DE ENTRADA DO CONVERSOR � AN2 (GP2)
	MOVLW	B'00001001' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	ADCON0
	
	; DEFINE CONFIGURA��ES DO TIMER1
	; HABILITA FUNCIONAMENTO DO TMR1; FUNCIONAMENTO A PARTIR DO CLOCK INTERNO; PRESCALER 1:2
	MOVLW	B'00011001' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	T1CON
	
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; HABILITA PRIMEIRA CONVERS�O DO CAD
	BSF	ADCON0, 1
	
	; DEFINE OFFSET DO TMR1 PARA CONTAR 100 ms (PASSAR VALORES PARA REG HIGH E LOW, POIS TMR1 � DE 16 BITS)
	MOVLW	B'00111100'
	MOVWF	TMR1H
	MOVLW	B'10101111'
	MOVWF	TMR1L
	
LOOP
	
	GOTO	LOOP
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
