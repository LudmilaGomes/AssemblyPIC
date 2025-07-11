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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_CLKOUT

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
		
		; VARI�VEIS UTILIZADAS
		END_REC		; ARMAZENA BITS DO ENDERE�O RECEBIDO DO MASTER
		MEU_END		; ARMAZENA O ENDERE�O DESTE DISPOSTIVO SLAVE
		CONTADOR	; ARMAZENA VALOR 8; SER� USADO NO LOOP QUE ARMAZENA OS BITS RECEBIDOS

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
	MOVLW	B'00000011' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0			;RETORNA PARA O BANCO 0
	MOVLW	B'00110001'
	MOVWF	T1CON
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	; INICIALIZA CONTADOR EM 8
	MOVLW	.8
	MOVWF	CONTADOR
	MOVLW	B'01101011'
	MOVWF	MEU_END
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; PARA LEMBRAR: GP1 (SDA), GP0 (SCL)
	
	; =========================== PRIMEIRA ETAPA - IDENTIFICAR START BIT DA ENTRADA

	; GARANTE QUE VALOR DE GP5 NO COME�O DO PROGRAMA � 0
	BCF	GPIO, GP5
	; LIMPA FLAG Z DE STATUS
	BCF	STATUS, Z
	
VERIF_SDA_START
	
	; VERIFICA EM SDA SE HOUVE TRANSI��O DE DESCIDA NO SINAL
	BTFSC	GPIO, GP1
	GOTO	VERIF_SDA_START ; GP1 (SDA) CONTINUA EM HIGH
	; GP1 (SDA) FOI PARA LOW
	
	; VERIFICA VALOR DE SCL, SE EST� EM HIGH
	BTFSS	GPIO, GP0	; GP1 (SDA) FOI PARA LOW
	GOTO	VERIF_SDA_START	; START BIT N�O � RECONHECIDO E VOLTAMOS PARA A PRIMEIRA VERIFICA��O
	
	; CASO PROGRAMA PASSE DESSA ETAPA, QUER DIZER QUE O START BIT FOI RECONHECIDO E PRESSEGUIMOS
	
	; RECONHECIMENTO DO CLOCK (SUBIDA E DESCIDA; QUANDO EM HIGH, BIT DE END � RECEBIDO E EXECUTAMOS C�DIGO PARA ARMAZENAR SEU VALOR)
	
	; =========================== SEGUNDA ETAPA - ARMAZENAR SUCESSIVAMENTE OS BITS DO ENDERE�O RECEBIDOS DO MASTER E SALVAR NA VARI�VEL END_REC
	
VERIF_SCL_LOW_LOOP
	; LOOP PARA VERIFICAR SE CLOCK EST� EM ESTADO LOW
	BTFSC	GPIO, GP0
	GOTO	VERIF_SCL_LOW_LOOP  ; GP0 (SCL) AINDA EST� EM HIGH
	; GP0 (SCL) FOI PARA LOW
VERIF_SCL_HIGH_LOOP
	; LOOP PARA VERIFICAR SE CLOCK EST� EM ESTADO HIGH
	BTFSS	GPIO, GP0
	GOTO	VERIF_SCL_HIGH_LOOP ; GP0 (SCL) AINDA EST� EM LOW
	; GP0 (SCL) FOI PARA HIGH
	
	; � USADO UM CONTADOR PARA SALVAR UM BIT 8 VEZES (O CONTADOR SER� DECREMENTADO AT� ZERO)
	
	; VERIFICA SE CONTADOR CHEGOU A ZERO A PARTIR DA FLAG Z DE STATUS
	BTFSS	STATUS, Z
	GOTO	SALVA_BIT_END	; CONTADOR AINDA N�O CHEGOU A ZERO
	; CONTADOR CHEGOU A ZERO E VAMOS VERIFICAR SE ENDERE�OS RECEBIDO E PR�PRIO S�O IGUAIS
	GOTO	VERIF_ENDERECOS
	
SALVA_BIT_END
	; PARA ARMAZENAR OS BITS, SER� USADA A FUN��O RLF 
	; RLF f, d: ONDE O CONTE�DO DO REG f � MOVIDO PARA A ESQUERDA; O VALOR DE STATUS, C � COLOCADO NO BIT
	; MENOS SIGNIFICATIVO DE f; SE d = 1, O RESULTADO � ARMAZENADO EM f
	
	; VAMOS VERIFICAR VALOR DE GP1 PARA, A PARTIR DO SEU VALOR, PASSAR O SEU BIT ARMAZENADO EM STATUS, C
	BTFSS	GPIO, GP1
	GOTO	BIT_LOW_GP1
	GOTO	BIT_HIGH_GP1
	
BIT_LOW_GP1
	BCF	STATUS, C
	GOTO	SALVA_BIT_END_RLF
	
BIT_HIGH_GP1
	BSF	STATUS, C
	GOTO	SALVA_BIT_END_RLF
	
SALVA_BIT_END_RLF
	; AGORA, VAMOS DECREMENTAR O CONTADOR (QUE IR� FAZER O LOOP EXECUTAR 9 VEZES) E USAR A FUN��O RLF
	DECF	CONTADOR, 1
	RLF	END_REC, 1
	
	GOTO	VERIF_SCL_LOW_LOOP
	
	; =========================== TERCEIRA ETAPA - RESPONS�VEL PELA IDENTIFICA��O DO ENDERE�O RECEBIDO COM O ENDERE�O PR�PRIO DO DISPOSITIVO E,
	; AP�S VERIFICA��O, A��O ADEQUADA PARA CASO DE IGUALDADE E DE DIFEREN�A DOS ENDERE�OS
	
VERIF_ENDERECOS
	
	; SUBTRA��O PARA VERIFICAR SE VALORES DE MEU_END E END_REC S�O IGUAIS
	
	; PASSA VALOR DE MEU_END PARA WREG
	MOVFW	MEU_END
	; REALIZA SUBTRA��O E VERIFICA STATUS
	SUBWF	END_REC, 0
	BTFSS	STATUS, Z
	; Z = 0 E ENDERE�O RECEBIDO *N�O �* O ENDERE�O DO DISPOSITIVO
	GOTO	VERIF_STOP_GP1
	; Z = 1 E ENDERE�O RECEBIDO *�* O ENDERE�O DO DISPOSITIVO
	
	; AGORA, TRANSFORMA GP1 (SDA) EM SA�DA PARA INDICAR ACK 1 PARA O MASTER
	BANK1
	MOVLW	B'00000001' 	;CONFIGURA GP1 COMO SA�DA NO TRISIO
	MOVWF	TRISIO	
	BANK0
	; GP1 AGORA PASSA A SER SA�DA E EST� EM HIGH
	BSF	GPIO, GP1
	; DEFINE PORTA GP5 COMO HIGH (LED ACESO)
	BSF	GPIO, GP5
	
VERIF_TEMPO_ACK	
	; AGORA, VERIFICAMOS SE O TEMPO DO ACK NO CLOCK J� ACABOU
	BTFSC	GPIO, GP0
	; GP0 (SCL) AINDA EST� EM HIGH
	GOTO	VERIF_TEMPO_ACK
	; GP0 (SCL) EST� EM LOW 
	
	; AGORA, PODEMOS CONTROLAR O SCL (COLOC�-LO COMO SA�DA E FOR�AR SEU VALOR PARA LOW)
	BANK1
	MOVLW	B'00000000' 	;CONFIGURA GP0 COMO SA�DA NO TRISIO
	MOVWF	TRISIO	
	BANK0
	
	; VALOR DE GP0 COLOCADO EM LOW
	BCF	GPIO, GP0
	
	; CONFIGURA VALOR DE OFFSET DE TIMER1 PARA QUE ESTE ESTOURE COM 500ms
	MOVLW	B'00001011' 	
	MOVWF	TMR1H
	MOVLW	B'11011011' 	
	MOVWF	TMR1L

VERIF_ESTOURO_TIMER1
	BTFSS	PIR1, TMR1IF
	; SE AINDA N�O HOUVE ESTOURO DO TIMER1, CONTINUAMOS VERIFICANDO
	GOTO	VERIF_ESTOURO_TIMER1
	; SE HOUVE ESTOURO DO TIMER1
	
	; SA�DAS GP1 E GP5 V�O PARA LOW
	BCF	GPIO, GP1
	BCF	GPIO, GP5
	BSF	GPIO, GP0
	; REESTABELE TRISIO COM GP0 E GP1 COMO ENTRADAS
	MOVLW	B'00000011' 	
	MOVWF	TRISIO
	
	; =========================== QUARTA ETAPA - IDENTIFICAR STOP BIT DA ENTRADA
	
	; AGORA, POR FIM, VAMOS VERIFICAR SE ENTRADAS REPRESENTAM STOP BIT
	
VERIF_STOP_GP1
	BTFSC	GPIO, GP1
	GOTO	VERIF_STOP_GP1

VERIF_STOP_GP1_HIGH
	BTFSS	GPIO, GP1
	GOTO	VERIF_STOP_GP1_HIGH
	
	BTFSS	GPIO, GP0
	GOTO	VERIF_STOP_GP1
	
	; SE GP1 PASSOU PARA HIGH E GP0 TAMB�M EST� EM HIGH, STOP BIT FOI RECONHECIDO E O PROGRAMA RECOME�A!
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
