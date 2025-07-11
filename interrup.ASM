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

	ORG	0x04		;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

	; H� DOIS TIPOS DE INTERRUP��O, A INTERRUP��O DO TIMER0 E A INTERRUP��O
	; DA MUDAN�A DE ESTADO DA PORTA GP3; ASSIM, FAZEMOS A VERIFICA��O PARA
	; A INTERRUP��O DE GP3 (CUJA INTERRUP��O � ATIVADA PARA GP3 = 0) E, SE
	; N�O ESTIVERMOS NESSA INTERRUP��O, ESTAMOS NA INTERRUP��O DO TIMER0

	; !!! ALGUMA INTERRUP��O OCORRE E O FLUXO DE EXECU��O DO PROGRAMA
	; � DESVIADO PARA C� (TRATAMENTO DE INTERRUP��O); O PROGRAMA N�O
	; SABE QUAL FOI A INTERRUP��O QUE OCORREU, MAS � POR MEIO DE SOFTWARE
	; QUE SE DEFINE O TRATAMENTO ADEQUADO PARA CADA TIPO DE INTERRUP��O
	
	; SE A FLAG DE INTERRUP��O FOI ATIVADA, OU A INTERRUP��O DE GP3 OU A DE
	; TIMER0 OCORREU; ASSIM, VERIFICAMOS:
	
	; VERIFICA ESTADO DE GP3 - VERIFICA SE GP3 � IGUAL A 0
	BTFSS	GPIO, GP3
	; SE GP3 = 0, EXECUTA INSTRU��O SEGUINTE
	; SE GP3 = 0: A INTERRUP��O DE GP3 � A ATUAL
	GOTO	GP3_EH_ZERO
	; SE GP3 = 1, EXECUTA SEGUNDA INSTRU��O
	; SE GP3 = 1, A INTERRUP��O DE TIMER0 � A ATUAL
	GOTO	GP3_EH_UM
	
GP3_EH_ZERO
	; INTERRUP��O DE GP3
	
	BCF	INTCON, T0IE	; DESABILITAMOS A INTERRUP��O DE TIMER0
	BSF	GPIO, GP4	; VALOR DE GP4 PASSA A SER 1 (FREIO ATIVADO EM 0, LUZ EM 1)
	BCF	INTCON, GPIF	; CLEAR BIT DA FLAG DE INTERRUP��O DE MUDAN�A DA PORTA GP3
	GOTO	SAI_INT
	
GP3_EH_UM
	; INTERRUP��O DE TMR0
	
	BSF	INTCON, T0IE	; HABILITAMOS A INTERRUP��O DE TIMER0
	BCF	INTCON, GPIF	; CLEAR BIT DA FLAG DE INTERRUP��O DE MUDAN�A DA PORTA GP3
	CALL	TRAT_TIMER0	; CHAMA FUN��O DE TRATAMENTO DE ESTOURO DO TMR0
	GOTO	SAI_INT
	
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

TRAT_TIMER0
	; REALIZA TRATAMENTO DO TMR0
	
	BCF	INTCON, T0IF	; CLEAR BIT DE FLAG DE ESTOURO DE TMR0
	MOVLW	.131
	MOVWF	TMR0		; REGISTRADOR DO TMR0 RECEBE VALOR 131
	; VERIFICA VALOR DE GP4
	BTFSS	GPIO, GP4
	; SE GP4 = 0, EXECUTA INSTRU��O SEGUINTE
	; SE GP4 = 0: VALOR DE GP4 PASSA A SER 1
	GOTO	GP4_EH_ZERO
	; SE GP4 = 1, EXECUTA SEGUNDA INSTRU��O
	; SE GP4 = 1: VALOR DE GP4 PASSA A SER 0 
	BCF	GPIO, GP4	; CLEAR GP4
	; OFFSET 131
	RETURN
	
GP4_EH_ZERO
	BSF	GPIO, GP4	; SET GP4
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	
	; GP3 COMO ENTRADA, GP4 COMO SA�DA
	; TRISIO - 00001000
	
	; OPTION_REG PADR�O (PULL-UP DESABILITADO ETC)
	
	; HABILITAMOS INTERRUP��ES GLOBALMENTE, INTERRUP��O DE TMR0 E
	; INTERRUP��O EM TRANSI��O DE ESTADO DE PORTAS (USAMOS GP3)
	; INTCON - 10101000
	
	; COMO VAMOS USAR GP3 E TRANSI��ES NESSA PORTA SER�O CONSIDERADAS
	; PARA AS INTERRUP��ES, ATIVAMOS ESSA PORTA PARA INTERRUP��O EM IOC
	; IOC - 00001000
	
	MOVLW	B'00001000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10101000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00001000'
	MOVWF	IOC
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN	
	
	; L�GICA DO PROGRAMA IMPLEMENTADA NO TRATAMENTO DE INTERRUP��O
	GOTO	MAIN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
