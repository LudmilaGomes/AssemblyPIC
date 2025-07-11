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
		
		; VARI�VEL PARA ARMAZENAR MAIOR VALOR DE ALTITUDE REGISTRADO
		MAIOR
		; CONTADOR PARA ALCAN�AR 2 SEGUNDOS COM USO DO TIMER1
		CONTADOR_T_2S
		; CONTADOR PARA ALCAN�AR 5 SEGUNDOS COM USO DO TIMER1
		CONTADOR_T_5S

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
	
	; DEFINE ENTRADAS (GP0 E GP1) E SA�DA (GP5)
	MOVLW	B'00000011' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	
	; DEFINA ENTRADA ANAL�GICA EM GP1 (AN1) E CLOCK DO CONVERSOR A/D
	MOVLW	B'00010010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0			;RETORNA PARA O BANCO 0
	
	; CONFIGURA FUNCIONAMENTO DO CONVERSOR A/D
	MOVLW	B'00000101' 	
	MOVWF	ADCON0		
	
	; CONFIGURA FUNCIONAMENTO DO TRM1 (HABILITADO; PRESCALER 1:8)
	MOVLW	B'00110001' 	
	MOVWF	T1CON		
	
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	; EXPLICA��O DOS VALORES MAIS ABAIXO
	MOVLW	.4
	MOVWF	CONTADOR_T_2S

	MOVLW	.10
	MOVWF	CONTADOR_T_5S
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; VERIFICA VALOR DE ENTRADA GP0
	; QUANDO GP0 = 0, PROGRAMA COME�A AQUISI��O DOS PONTOS PELO CAD
	BTFSC	GPIO, GP0
	; SE GP0 = 1, EXECUTA INSTRU��O SEGUINTE
	GOTO	MAIN
	; SE GP0 = 0, EXECUTA SEGUNDA INSTRU��O
	
	; AQUI, COME�AMOS A L�GICA DO PROGRAMA

COM_CONV1
	; AQUISI��O DE PONTOS COM CAD ENQUANTO ALTITUDE OBTIDA < 10 m
	BSF	ADCON0, 1   ; SETA BIT PARA COME�AR CONVERS�O DO CAD
	
VER_CONV1
	; VERIFICA SE CONVERS�O ACABOU
	BTFSC	ADCON0, 1
	; SE GP0 = 1, EXECUTA INSTRU��O SEGUINTE (CONVERS�O N�O TERMINOU AINDA E VOLTAMOS � VERIFICA��O)
	GOTO	VER_CONV1
	; SE GP0 = 0, EXECUTA SEGUNDA INSTRU��O (CONVERS�O TERMINOU)
	
	; AGORA, VERIFICA SE VALOR OBTIDO � MAIOR QUE 10 m DE ALTITUDE
	
	; 10 m => 0.1 V
	
	; 5   => 255
	; 0.1 => X
	; X = 5.1 ~= 5
	
	MOVLW	.5
	; REALIZA SUBTRA��O F - W = ADRESL - 5
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; SE C = 0, EXECUTA INSTRU��O SEGUINTE (SIGNIFICA QUE ADRESL < 10)
	GOTO	COM_CONV1 ; E CONTINUAMOS COM AQUISI��O DE PONTOS AT� QUE ALTITUDE SUPERE VALOR 10 m
	; SE C = 1, EXECUTA SEGUNDA INSTRU��O  (SIGNIFICA QUE ADRESL > 10)
	
	; SALVA VALOR ATUAL DE ADRESL NA VARI�VEL MAIOR (QUE � O VALOR REGISTRADO DA ALTITUDE DA �LTIMA AQUISI��O DE PONTO)
	MOVFW	ADRESH
	MOVWF	MAIOR
	
COM_CONV2
	; AQUISI��O DE PONTOS COM CAD ENQUANTO ALTITUDE ATUAL N�O FOR APOGEU
	BSF	ADCON0, 1   ; SETA BIT PARA COME�AR CONVERS�O DO CAD
	
VER_CONV2
	; VERIFICA SE CONVERS�O ACABOU
	BTFSC	ADCON0, 1
	; SE GP0 = 1, EXECUTA INSTRU��O SEGUINTE (CONVERS�O N�O TERMINOU AINDA E VOLTAMOS � VERIFICA��O)
	GOTO	VER_CONV2
	; SE GP0 = 0, EXECUTA SEGUNDA INSTRU��O (CONVERS�O TERMINOU)
	
	; VERIFICA��O DE VALOR DE ALTITUDE
	MOVFW	MAIOR
	; REALIZA SUBTRA��O F - W = ADRESL - MAIOR
	SUBWF	ADRESH, W
	; VERIFICA SE CARRY DE STATUS FOI ALTERADO
	BTFSS	STATUS, C
	; SE C = 0, EXECUTA INSTRU��O SEGUINTE(SIGNIFICA QUE ADRESL < MAIOR)
	GOTO	ALTIT_APOGEU	; QUANDO ENCONTRAMOS VALOR DE APOGEU
	; SE C = 1, EXECUTA SEGUNDA INSTRU��O (SIGNIFICA QUE ADRESL > MAIOR)
	; AINDA N�O ENCONTRAMOS VALOR DE APOGEU E CONTINUAMOS NO LOOP DE AQUISI��ES DE PONTOS
	
	; SALVAMOS VALOR ATUAL DE ADRESL (QUE � VALOR DE ALTITUDE)
	MOVFW	ADRESH
	MOVWF	MAIOR
	GOTO	COM_CONV2
	
ALTIT_APOGEU
	; VAMOS SALVAR O VALOR DE MAIOR ALTITUDE ENCONTRADA NO ENDERE�O 17h DA EEPROM
	BANK1
	; SALVA ENDERE�O DE ESCRITA
	MOVLW	17h
	MOVWF	EEADR
	; SALVA DADO A SER ESCRITO
	MOVFW	MAIOR
	MOVWF	EEDATA
	
	; HABILITA CICLOS DE ESCRITA
	BSF	EECON1, WREN
	; DESBLOQUEIO DE ESCRITA
	MOVLW	0x55
	MOVWF	EECON2
	MOVLW	0xaa
	MOVWF	EECON2
	BSF	EECON1, WR
	BANK0
	
DEF_OFFS_5S
	; ALTITUDE DE APOGEU FOI OBTIDA; AGORA, VAMOS CONTAR 5 SEGUNDOS PARA ABERTURA DE PARAQUEDAS
	
	; TIMER1 PERMITE QUE ALCANCEMOS UM VALOR DE 0.5 s, ENT�O VAMOS USAR ESSE TIMER 10 VEZES
	; PARA QUE TENHAMOS 5 SEGUNDOS NECESS�RIOS NA ESPERA PARA ABERTURA DE PARAQUEDAS (POIS 0.5 * 10 = 5 SEGUNDOS)
	; A MESMA IDEIA � USADA COM O TIMER PARA ALCAN�AR 2 SEGUNDOS, MAS USAMOS O TIMER 4 VEZES
	
	; OFFSET DO TIMER1 PARA QUE OBTENHAMOS 0.5 s � DE 3035d => 0000101111011011
	MOVLW	B'00001011'
	MOVWF	ADRESH
	MOVLW	B'11011011'
	MOVWF	ADRESL
	
VER_TMR1_1
	; VERIFICA SE HOUVE OVERFLOW EM TMR1
	BTFSS	PIR1, TMR1IF
	; SE TMR1IF = 0, EXECUTA INSTRU��O SEGUINTE (E N�O HOUVE ESTOURO DO TMR1)
	GOTO	VER_TMR1_1
	; SE TMR1IF = 1, EXECUTA SEGUNDA INSTRU��O (E HOUVE ESTOURO DO TMR1)
	
	; LIMPA FLAG DE ESTOURO DO TMR1 ANTES DE VERIFICAR ESSE BIT DE NOVO
	BCF	PIR1, TMR1IF
	; DECREMENTAMOS EM UMA UNIDADE O CONTADOR CONTADOR_T_5S DE 5 SEGUNDOS 
	DECF	CONTADOR_T_5S, 1
	; AGORA, VERIFICAMOS SE CONTADOR_T_5S TEM VALOR 0 POR MEIO DO REG STATUS
	BTFSS	STATUS, Z
	; SE Z = 0, EXECUTA INSTRU��O SEGUINTE (E N�O PASSARAM 5 SEGUNDOS AINDA)
	GOTO	VER_TMR1_1
	; SE Z = 1, EXECUTA SEGUNDA INSTRU��O (E OS 5 SEGUNDOS PASSARAM)
	
	; SE OS 5 SEGUNDOS PASSARAM, AGORA SETAMOS GP5 POR 2 SEGUNDOS
	BSF	GPIO, GP5
	
DEF_OFFS_2S
	; OFFSET DO TIMER1 PARA QUE OBTENHAMOS 0.5 s � DE 3035d => 0000101111011011
	MOVLW	B'00001011'
	MOVWF	ADRESH
	MOVLW	B'11011011'
	MOVWF	ADRESL
	
VER_TMR1_2
	; VERIFICA SE HOUVE OVERFLOW EM TMR1
	BTFSS	PIR1, TMR1IF
	; SE TMR1IF = 0, EXECUTA INSTRU��O SEGUINTE (E N�O HOUVE ESTOURO DO TMR1)
	GOTO	VER_TMR1_2
	; SE TMR1IF = 1, EXECUTA SEGUNDA INSTRU��O (E HOUVE ESTOURO DO TMR1)
	
	; LIMPA FLAG DE ESTOURO DO TMR1 ANTES DE VERIFICAR ESSE BIT DE NOVO
	BCF	PIR1, TMR1IF
	; DECREMENTAMOS EM UMA UNIDADE O CONTADOR CONTADOR_T_2S DE 2 SEGUNDOS 
	DECF	CONTADOR_T_2S, 1
	; AGORA, VERIFICAMOS SE CONTADOR_T_2S TEM VALOR 0 POR MEIO DO REG STATUS
	BTFSS	STATUS, Z
	; SE Z = 0, EXECUTA INSTRU��O SEGUINTE (E N�O PASSARAM 2 SEGUNDOS AINDA)
	GOTO	VER_TMR1_2
	; SE Z = 1, EXECUTA SEGUNDA INSTRU��O (E OS 2 SEGUNDOS PASSARAM)
	
	; SE OS 2 SEGUNDOS PASSARAM, AGORA DAMOS CLEAR EM GP5
	BCF	GPIO, GP5
	
FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
