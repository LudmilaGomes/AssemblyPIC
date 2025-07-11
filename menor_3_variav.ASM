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
		
		A1
		A2
		A3
		MENOR

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
	MOVLW	B'00000000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	
	; PROGRAMA TEM TR�S VALORES E DEVE INDICAR QUAL DOS TR�S � O MENOR
	; O RESULTADO (O MENOR DENTRE OS TR�S) � ARMAZENADO NO FILE 'MENOR' AO FIM DA EXECU��O
	
	; COLOCAMOS VALORES EM DOIS TIPOS DE REG
	; W DE WORK (REG TEMPOR�RIO, USADO COMO INTERMEDI�RIO), F DE FILE (GUARDA DE FATO AS VARI�VEIS)
	; L DE LITERAL, QUE SIGNIFICA O VALOR ESCRITO (COMO .9, QUE � 9 NO FORMATO DECIMAL)
	MOVLW	.2	    ; MOVE O LITERAL DECIMAL 9 PARA WORK
	MOVWF	A1	    ; MOVE DO WORK PARA FILE DE IDENTIFICADOR A1
	MOVLW	.4	    ; MOVE O LITERAL DECIMAL 2 PARA WORK 
	MOVWF	A2	    ; MOVE DO WORK PARA FILE DE IDENTIFICADOR A2
	MOVLW	.7	    ; MOVE O LITERAL DECIMAL 5 PARA WORK 
	MOVWF	A3	    ; MOVE DO WORK PARA FILE DE IDENTIFICADOR A3
	MOVFW	A1	    ; MOVE DO FILE A1 PARA WORK (AGORA WORK TEM VALOR .9 DE A1)
	MOVWF	MENOR	    ; MOVE DO WORK (MESMO VALOR DE A1) PARA FILE DE IDENTIFICADOR MENOR
	
	; SUBTRA��O � USADA PARA SABER SE A1 (EM WORK) � MENOR QUE A2
	; RESULTADO DA SUBTRA��O � GUARDADO EM WORK
	SUBWF	A2, W	    ; SUBTRAI W DE FILE (F - W => A2 - A1)
	
	; POSS�VEIS RESULTADOS DA SUBTRA��O: 
	; A2 > A1 E O RESULTADO � POSITIVO - E O CARRY � 1
	; A2 = A1 E O RESULTADO � NULO	   - E O CARRY � 1 (?) E A FLAG ZERO � 1
	; A2 < A1 E O RESULTADO � NEGATIVO - E O CARRY � 0
	
	; NA SUBTRA��O, DIZER QUE HOUVE CARRY � DIZER QUE FOI PRECISO
	; 'PEGAR EMPRESTADO'; O BIT 'C' DO REG 'STATUS' INDICA QUE O
	; CARRY OCORREU QUANDO CLEAR, ISTO �, C = 0 E HOUVE CARRY!
	; SE N�O HOUVE CARRY, C = 1
	
	; BIT TEST F, SKIP IF SET - BTFSS f, b
	; SE O BIT 'b' DO REGISTRADOR 'f' � ZERO, A PR�X INSTRU��O � EXECUTADA (PRIMEIRA INSTRU��O)
	; SE O BIT 'b' DO REGISTRADOR 'f' � UM, A PR�X INSTRU��O � DESCONSIDERADA (SEGUNDA INSTRU��O)
	; E NOP � EXECUTADO EM SEU LUGAR
	BTFSS	STATUS, C   ; VERIFICA O BIT 'C' (� O BIT 0) DO REG 'STATUS'
	
	; SE O BIT C FOR IGUAL A 1 � PORQUE A SUBTRA��O TEVE RESULTADO POSITIVO
	; ISTO �, A2 � MAIOR QUE A1 E O VALOR DA VAR 'MENOR' N�O � ALTERADA
	; E A PR�X INSTRU��O � DESCONSIDERADA
	
	; SE O BIT C FOR IGUAL A 0 � PORQUE A SUBTRA��O TEVE RESULTADO NEGATIVO
	; ISTO �, A2 � MENOR QUE A1 E O VALOR DA VAR 'MENOR' DEVE SER ALTERADA
	; E A PR�X INSTRU��O � EXECUTADA
	
	; (1� INST) PR�X INSTRU��O: SE A2 < A1 E BIT C DO STATUS � 0
	GOTO A2_MENOR	    ; VAI PARA LABEL A2_MENOR_A1, MENOR � ATUALIZADO E VOLTA AO PROGRAMA
	
	; (2� INST) PR�X INSTRU��O DESCONSIDERADA: SE A2 > A1 E BIT C DO STATUS � 1
	; VERIFICA��O DA DIFEREN�A ENTRE A3 E 'MENOR':
VOLTA_1
	MOVFW	MENOR	    ; MOVE VALOR DE 'MENOR' PARA REG WORK
	SUBWF	A3, W	    ; SUBTRAI W DE FILE (F - W => A3 - MENOR)
	BTFSS	STATUS, C   ; VERIFICA O BIT 'C' (BIT 0) DO REG 'STATUS'
	
	; SE A3 < MENOR
	GOTO A3_MENOR
	
	; SE A3 > MENOR	
FIM
	GOTO FIM
	
A2_MENOR
	MOVFW A2	    ; MOVE VALOR DE A2 PARA REG WORK 
	MOVWF MENOR	    ; MOVE VALOR DO WORK PARA REG 'MENOR'
	GOTO VOLTA_1	    ; VOLTA PARA LABEL
	
A3_MENOR
	MOVFW A3	    ; MOVE VALOR DE A3 PARA REG WORK 
	MOVWF MENOR	    ; MOVE VALOR DO WORK PARA REG 'MENOR'
	GOTO FIM    	    ; VOLTA PARA LABEL
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
