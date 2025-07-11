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
		
		; DECLARA��O DA VARI�VEL CONTADOR_I
		CONTADOR_I
		; DECLARA��O DA VARI�VEL CONTADOR_J
		CONTADOR_J
		; FUNCIONAMENTO
		; A IDEIA � UTILIZAR AS VARI�VEIS 'CONTADOR_I' E 'CONTADOR_J' PARA CRIAR UM LA�O DE REPETI��O ANINHADO A OUTRO LA�O
		; A PRIMEIRA TENTATIVA PARA GERA��O DE ATRASO INCLUIU APENAS UM �NICO CONTADOR, A IDEIA SERIA DE DAR A ELE UM VALOR
		; E ELE SERIA DECREMENTADO AT� O VALOR ZERO, ENT�O A ROTINA DELAY CHEGAVA AO FIM E O FLUXO DE EXECU��O VOLTAVA � MAIN
		; MAS O USO DE S� UM CONTADOR N�O FOI SUFICIENTE: O ATRASO M�XIMO FOI DE (APROX.) 1.028 ms COM CONTADOR DE VALOR 255
		; O LIMITE DE TAMANHO PARA UMA VARI�VEL COMO AS DECLARADAS ACIMA � DE 255
		; ASSIM, A IMPLEMENTA��O ATUAL TRAZ DOIS CONTADORES; 'CONTADOR_I' � DECREMENTADO AT� ZERO, AP�S ISSO
		; 'CONTADOR_J' � DECREMENTADO E, SE FOR IGUAL A ZERO, � O FIM DA ROTINA DELAY; CASO CONTR�RIO, O FLUXO DE
		; EXECU��O VOLTA AO COME�O DA ROTINA EM QUE 'CONTADOR_I' � DECREMENTADO NOVAMENTE (LA�OS DE REPETI��O ANINHADOS)
		

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

DELAY
	; � NECESS�RIO DEFINIR O VALOR DE 'CONTADOR_I' ANTES DOS DECREMENTOS EM LOOP
	; CASO CONTR�RIO, O PROGRAMA TEM COMPORTAMENTO QUE N�O � ESPERADO ('CONTADOR_I' 
	; CHEGA A ZERO, E A REPETI��O SEGUINTE DECREMENTA ZERO; A VARI�VEL PASSA A TER VALOR 255) 
	
	; MOVE O N�MERO DECIMAL PARA O REGISTRADOR WORK (WREG)
	MOVLW	.146	      ; 1us
	; MOVE O VALOR ARMAZENADO EM WORK (WREG) PARA A VARI�VEL 'CONTADOR'
	MOVWF	CONTADOR_I    ; 1us 

VOLTA_FOR_I
	
	; DECF f, d - DECREMENTA (- 1) VALOR NO REGISTRADOR
	; SE 'd' � 1, RESULTADO DA OPERA��O � GUARDADO EM f
	DECF	CONTADOR_I, 1 ; 1us
	
	; BTFSS f, b - VERIFICA BIT 'b' DO REGISTRADOR 'f'
	; SE 'b' � 0, EXECUTA A PR�XIMA INSTRU��O
	; SE 'b' � 1, DESCONSIDERA A PR�XIMA INSTRU��O, EXECUTA A SEGUINTE
	BTFSS	STATUS, Z     ; 1us
	; VERIFICA BIT 'Z' DO REGISTRADOR 'STATUS'
	
	; SE 'CONTADOR_I' N�O � ZERO, 'Z' DE 'STATUS' � IGUAL A 0
	; SE 'CONTADOR_I' N�O � ZERO, CONTADOR CONTINUA A DECREMENTAR (AINDA ESTAMOS NO LA�O)
	GOTO	VOLTA_FOR_I   ; 2us

	; SE 'CONTADOR_I' CHEGA A ZERO, 'Z' DE 'STATUS' � IGUAL A 1
	; SE 'CONTADOR_I' CHEGA A ZERO, O LA�O DE REPET CHEGA AO FIM E PASSAMOS � INSTRU��O ABAIXO
	
	; ESTA PARTE DIZ RESPEITO AO LA�O DE REPETI��O QUE DECREMENTA A VARI�VEL 'CONTADOR_J'
	; S�O AS MESMAS OPERA��ES VISTAS PARA O 'CONTADOR_I'
	DECF	CONTADOR_J, 1 ; 1us
	BTFSS	STATUS, Z     ; 1us
	
	; SE 'CONTADOR_J' N�O � ZERO, 'Z' DE 'STATUS' � IGUAL A 0
	; SE 'CONTADOR_J' N�O � ZERO, AINDA ESTAMOS NO LA�O
	GOTO	DELAY	      ; 2us
	
	; SE 'CONTADOR_J' CHEGA A ZERO, 'Z' DE 'STATUS' � IGUAL A 1
	; SE 'CONTADOR_J' CHEGA A ZERO, O LA�O DE REPET CHEGA AO FIM E RETORNA � MAIN
	RETURN		      ; 2us
	

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
	
	; A VARI�VEL PODE SER INICIALIZADA AQUI, MAS PRECISA ASSUMIR SEU VALOR INICIAL A TODO NOVO COME�O DE LOOP
	; ENT�O EU RESOLVI MANTER A MUDAN�A DE SEU VALOR ANTES DA CHAMADA DA ROTINA DE DELAY

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; FUNCIONAMENTO
	; BASICAMENTE, A PORTA DE SA�DA GP5 � USADA PARA DEMONSTRAR O ATRASO GERADO PELO C�DIGO
	; ENT�O, GP5 ASSUME O VALOR BAIXO, O TEMPO DE ATRASO � GERADO COM A UTILIZA��O DA SUBROTINA
	; DELAY QUE CHEGA AO FIM E RETORNA AO FLUXO NA MAIN, ENT�O GP5 ASSUME O VALOR ALTO, LOGO 
	; TAMB�M USANDO A SUBROTINA DELAY; ASSIM, O PROGRAMA REPETE ESSE FLUXO DE EXECU��O
	; (EXPLICA��ES DE FUNCIONAMENTO EM DEFINI��O DAS VARI�VEIS E IMPLEMENTA��O DA SUBR. DELAY)
	
	; OS BREAKPOINTS NAS INSTRU��ES 'BCF' E 'BSF' S�O USADOS PARA MEDIR O TEMPO DE ATRASO
	; OS BREAKPOINTS S�O COLOCADOS NA INSTRU��O QUE REALIZA A MUDAN�A DE ESTADO DE GP5

	; BCF f, b - O BIT 'b' DO REGISTRADOR 'f' PASSA A TER VALOR ZERO
	; PARA MEDI��O DE TEMPO, BREAKPOINT FOI COLOCADO NA INSTRU��O ABAIXO
	BCF	GPIO, GP5   ; 1us
	
	; FORAM INSERIDOS DUAS INST. NOP PARA MANTER OS TEMPOS IGUAIS (GP5 ALTO E BAIXO)
	NOP		    ; 1us
	NOP		    ; 1us
	
	; FORAM FEITAS V�RIAS TENTATIVAS DE VALORES PARA 'CONTADOR_I' E 'CONTADOR_J' QUE SE
	; APROXIMASSEM DO TEMPO DE ATRASO DESEJADO DE 31.25 ms; NENHUMA ALCAN�OU O VALOR EXATO
	; MAS, PARA OS VALORES ATUAIS DE 'CONTADOR_I' E 'CONTADOR_J', FOI OBTIDO O TEMPO DE
	; 31.225 ms, O MAIS PR�XIMO QUE PUDE ENCONTRAR.
	; ASSIM, CONSIDEREI QUE A NECESSIDADE DE SE ALCAN�AR O TEMPO DE ATRASO � MAIS CR�TICO,
	; POIS � NECESS�RIA PRECIS�O PARA GERA��O DO ATRASO E UM VALOR ACIMA OU ABAIXO, A DEPENDER
	; DA APLICA��O, PODERIA TRAZER RESULTADOS PR�TICOS INSATISFAT�RIOS
	; ENT�O FOI NECESS�RIO ADICIONAR 25 INSTRU��ES NOP PARA ATINGIR O REQUISITO
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
	
	; MOVE O N�MERO DECIMAL PARA O REGISTRADOR WORK (WREG)
	MOVLW	.53	    ; 1us
	; MOVE O VALOR ARMAZENADO EM WORK (WREG) PARA A VARI�VEL 'CONTADOR'
	MOVWF	CONTADOR_J  ; 1us 
	
	; CHAMA ROTINA DELAY (DIRIGE FLUXO DE EXECU��O PARA A ROTINA)
	CALL	DELAY	    ; 2us
	
	; BSF f, b - O BIT 'b' DO REGISTRADOR 'f' PASSA A TER VALOR UM
	; PARA MEDI��O DE TEMPO, BREAKPOINT FOI COLOCADO NA INSTRU��O ABAIXO
	BSF	GPIO, GP5   ; 1us
	
	; AS 25 INSTRU��ES NOP FORAM ADICIONADAS AQUI TAMB�M PARA PARA MANTER OS TEMPOS IGUAIS (GP5 ALTO E BAIXO)
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
	
	; MOVE O N�MERO DECIMAL PARA O REGISTRADOR WORK (WREG)
	MOVLW	.53	    ; 1us
	; MOVE O VALOR ARMAZENADO EM WORK (WREG) PARA A VARI�VEL 'CONTADOR'
	MOVWF	CONTADOR_J  ; 1us 
	
	; CHAMA ROTINA DELAY (DIRIGE FLUXO DE EXECU��O PARA A ROTINA)
	CALL	DELAY	    ; 2us
	
	; VOLTA PARA O COME�O DO PROGRAMA (LABEL MAIN) E REPETE A EXECU��O
	GOTO	MAIN	    ; 2us

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
