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
	
	; FLAG DE INTERRUP��O DO COMPARADOR EM 0
	BCF	PIR1, CMIF
	; DESABILITA MOMENTAMEAMENTE INTERRUP��O POR MUDAN�A DO OUTPUT DO COMPARADOR
	BCF	PIE1, CMIE
	
	; COME�AMOS COM REFER�NCIA INTERNA DE 0.5V
	; VAMOS VERIFICAR SE COUT == 1
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 0.5V
	; ALTERAMOS PARA A REFER�NCIA INTERNA SEGUINTE (QUE � 1V) E MUDAMOS A SA�DA PARA 001
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR0
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDAN�A DO VALOR DA REFER�NCIA INTERNA PARA 1V
	BANK1
	MOVLW	B'10100101'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 1V
	; ALTERAMOS PARA A REFER�NCIA INTERNA SEGUINTE (QUE � 1.5V) E MUDAMOS A SA�DA PARA 010
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR1
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDAN�A DO VALOR DA REFER�NCIA INTERNA PARA 1.5V
	BANK1
	MOVLW	B'10100111'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 1.5V
	; ALTERAMOS PARA A REFER�NCIA INTERNA SEGUINTE (QUE � 2V) E MUDAMOS A SA�DA PARA 011
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR2
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDAN�A DO VALOR DA REFER�NCIA INTERNA PARA 2V
	BANK1
	MOVLW	B'10000101'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 2V
	; ALTERAMOS PARA A REFER�NCIA INTERNA SEGUINTE (QUE � 2.5V) E MUDAMOS A SA�DA PARA 100
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR3
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDAN�A DO VALOR DA REFER�NCIA INTERNA PARA 2.5V
	BANK1
	MOVLW	B'10101100'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 2.5V
	; ALTERAMOS PARA A REFER�NCIA INTERNA SEGUINTE (QUE � 3V) E MUDAMOS A SA�DA PARA 101
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR4
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDAN�A DO VALOR DA REFER�NCIA INTERNA PARA 3V
	BANK1
	MOVLW	B'10001011'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 3V
	; ALTERAMOS PARA A REFER�NCIA INTERNA SEGUINTE (QUE � 3.5V) E MUDAMOS A SA�DA PARA 110
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR5
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDAN�A DO VALOR DA REFER�NCIA INTERNA PARA 3.5V
	BANK1
	MOVLW	B'10001110'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA � MAIOR QUE 3.5V E MUDAMOS A SA�DA PARA 111
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRU��O SEGUINTE
	GOTO	SAIDA_VALOR6
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRU��O
	GOTO	SAIDA_VALOR7
	
SAIDA_VALOR7
	; SA�DA EM 111 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BSF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR6
	; SA�DA EM 110 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BSF	GPIO, GP2
	BCF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR5
	; SA�DA EM 101 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BCF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR4
	; SA�DA EM 100 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BCF	GPIO, GP2
	BCF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR3
	; SA�DA EM 011 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BSF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR2
	; SA�DA EM 010 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BSF	GPIO, GP2
	BCF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
	
SAIDA_VALOR1
	; SA�DA EM 001 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BCF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
	
SAIDA_VALOR0
	
	; SA�DA EM 000 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BCF	GPIO, GP2
	BCF	GPIO, GP0
	
ANTES_SAIDA
	
	; POR FIM, ALTERAMOS O VALOR DA REFER�NCIA INTERNA DE VOLTA PARA 0,5V
	BANK1
	MOVLW	B'10100010'
	MOVWF	VRCON
	BANK0
	
	; EM SEGUIDA, HABILITA INTERRUP��O POR MUDAN�A DO OUTPUT DO COMPARADOR
	BSF	PIE1, CMIE
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; SA�DA DA INTERRUP��O
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
	; TRISIO - ENTRADAS: GP1; SA�DAS: GP4, GP2, GP0
	MOVLW	B'00000010' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	
	; VRCON - HABILITA CIRCUITO PARA USO DE VREF;
	; CONFIGURA��ES INICIAIS SER�O: LOW RANGE; N = 0010
	; A MEDIDA QUE REALIZAMOS A VERIFICA��O DO VALOR DE ENTRADA, MUDAMOS ESSAS CONFIGURA��ES
	MOVLW	B'10100010'
	MOVWF	VRCON
	
	; ANSEL - PERMITIR QUE ENTRADA GP1 SEJA ANAL�GICA
	MOVLW	B'00000010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	
	; USO DE INTERRUP��O! A ESPECIFICA��O DA ATIVIDADE 5 INDICA QUE INDICA��O DE
	; MUDAN�A DA SA�DA DEVE SER FEITA DE FORMA C�CLICA E T�O R�PIDA QUANTO FOR
	; POSS�VEL; INTERPRETO DA SEGUINTE FORMA: PARA UMA MUDAN�A DO OUTPUT DO COMPARADOR,
	; TEMOS UMA RESPOSTA IMEDIATA � ESSA MUDAN�A COM O USO DE INTERRUP��O; ENT�O, 
	; VAMOS TER UMA INTERRUP��O CADA VEZ QUE O COUT DO COMPARADOR FOR 1
	
	; INTCON - HABILITA INTERRUP��O GLOBAL E INTERRUP��O DE PERIF�RICO
	MOVLW	B'11000000'
	MOVWF	INTCON
	
	; PIE1 - HABILITA INTERRUP��O DE COMPARADOR
	MOVLW	B'00001000'
	MOVWF	PIE1
	
	BANK0			;RETORNA PARA O BANCO 0
	
	; DEFINE COUTPUT INVERTIDO (QUANDO GP1 > VREF: A SA�DA � 1)
	; MODO DO COMPARADOR 100 (COMPARADOR SEM OUTPUT EM GP2 E COM USO DE REFER�NCIA INTERNA)
	MOVLW	B'00010100'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; MAIN VAZIA
	; L�GICA DE IMPLEMENTA��O NO TRATAMENTO DE INTERRUP��O
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
