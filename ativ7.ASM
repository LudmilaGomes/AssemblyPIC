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

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES
		
		; VARIÁVEL PARA ARMAZENAR MAIOR VALOR DE ALTITUDE REGISTRADO
		MAIOR
		; CONTADOR PARA ALCANÇAR 2 SEGUNDOS COM USO DO TIMER1
		CONTADOR_T_2S
		; CONTADOR PARA ALCANÇAR 5 SEGUNDOS COM USO DO TIMER1
		CONTADOR_T_5S

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

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	
	; DEFINE ENTRADAS (GP0 E GP1) E SAÍDA (GP5)
	MOVLW	B'00000011' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	
	; DEFINA ENTRADA ANALÓGICA EM GP1 (AN1) E CLOCK DO CONVERSOR A/D
	MOVLW	B'00010010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0			;RETORNA PARA O BANCO 0
	
	; CONFIGURA FUNCIONAMENTO DO CONVERSOR A/D
	MOVLW	B'00000101' 	
	MOVWF	ADCON0		
	
	; CONFIGURA FUNCIONAMENTO DO TRM1 (HABILITADO; PRESCALER 1:8)
	MOVLW	B'00110001' 	
	MOVWF	T1CON		
	
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	; EXPLICAÇÃO DOS VALORES MAIS ABAIXO
	MOVLW	.4
	MOVWF	CONTADOR_T_2S

	MOVLW	.10
	MOVWF	CONTADOR_T_5S
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; VERIFICA VALOR DE ENTRADA GP0
	; QUANDO GP0 = 0, PROGRAMA COMEÇA AQUISIÇÃO DOS PONTOS PELO CAD
	BTFSC	GPIO, GP0
	; SE GP0 = 1, EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	MAIN
	; SE GP0 = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; AQUI, COMEÇAMOS A LÓGICA DO PROGRAMA

COM_CONV1
	; AQUISIÇÃO DE PONTOS COM CAD ENQUANTO ALTITUDE OBTIDA < 10 m
	BSF	ADCON0, 1   ; SETA BIT PARA COMEÇAR CONVERSÃO DO CAD
	
VER_CONV1
	; VERIFICA SE CONVERSÃO ACABOU
	BTFSC	ADCON0, 1
	; SE GP0 = 1, EXECUTA INSTRUÇÃO SEGUINTE (CONVERSÃO NÃO TERMINOU AINDA E VOLTAMOS À VERIFICAÇÃO)
	GOTO	VER_CONV1
	; SE GP0 = 0, EXECUTA SEGUNDA INSTRUÇÃO (CONVERSÃO TERMINOU)
	
	; AGORA, VERIFICA SE VALOR OBTIDO É MAIOR QUE 10 m DE ALTITUDE
	
	; 10 m => 0.1 V
	
	; 5   => 255
	; 0.1 => X
	; X = 5.1 ~= 5
	
	MOVLW	.5
	; REALIZA SUBTRAÇÃO F - W = ADRESL - 5
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; SE C = 0, EXECUTA INSTRUÇÃO SEGUINTE (SIGNIFICA QUE ADRESL < 10)
	GOTO	COM_CONV1 ; E CONTINUAMOS COM AQUISIÇÃO DE PONTOS ATÉ QUE ALTITUDE SUPERE VALOR 10 m
	; SE C = 1, EXECUTA SEGUNDA INSTRUÇÃO  (SIGNIFICA QUE ADRESL > 10)
	
	; SALVA VALOR ATUAL DE ADRESL NA VARIÁVEL MAIOR (QUE É O VALOR REGISTRADO DA ALTITUDE DA ÚLTIMA AQUISIÇÃO DE PONTO)
	MOVFW	ADRESH
	MOVWF	MAIOR
	
COM_CONV2
	; AQUISIÇÃO DE PONTOS COM CAD ENQUANTO ALTITUDE ATUAL NÃO FOR APOGEU
	BSF	ADCON0, 1   ; SETA BIT PARA COMEÇAR CONVERSÃO DO CAD
	
VER_CONV2
	; VERIFICA SE CONVERSÃO ACABOU
	BTFSC	ADCON0, 1
	; SE GP0 = 1, EXECUTA INSTRUÇÃO SEGUINTE (CONVERSÃO NÃO TERMINOU AINDA E VOLTAMOS À VERIFICAÇÃO)
	GOTO	VER_CONV2
	; SE GP0 = 0, EXECUTA SEGUNDA INSTRUÇÃO (CONVERSÃO TERMINOU)
	
	; VERIFICAÇÃO DE VALOR DE ALTITUDE
	MOVFW	MAIOR
	; REALIZA SUBTRAÇÃO F - W = ADRESL - MAIOR
	SUBWF	ADRESH, W
	; VERIFICA SE CARRY DE STATUS FOI ALTERADO
	BTFSS	STATUS, C
	; SE C = 0, EXECUTA INSTRUÇÃO SEGUINTE(SIGNIFICA QUE ADRESL < MAIOR)
	GOTO	ALTIT_APOGEU	; QUANDO ENCONTRAMOS VALOR DE APOGEU
	; SE C = 1, EXECUTA SEGUNDA INSTRUÇÃO (SIGNIFICA QUE ADRESL > MAIOR)
	; AINDA NÃO ENCONTRAMOS VALOR DE APOGEU E CONTINUAMOS NO LOOP DE AQUISIÇÕES DE PONTOS
	
	; SALVAMOS VALOR ATUAL DE ADRESL (QUE É VALOR DE ALTITUDE)
	MOVFW	ADRESH
	MOVWF	MAIOR
	GOTO	COM_CONV2
	
ALTIT_APOGEU
	; VAMOS SALVAR O VALOR DE MAIOR ALTITUDE ENCONTRADA NO ENDEREÇO 17h DA EEPROM
	BANK1
	; SALVA ENDEREÇO DE ESCRITA
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
	
	; TIMER1 PERMITE QUE ALCANCEMOS UM VALOR DE 0.5 s, ENTÃO VAMOS USAR ESSE TIMER 10 VEZES
	; PARA QUE TENHAMOS 5 SEGUNDOS NECESSÁRIOS NA ESPERA PARA ABERTURA DE PARAQUEDAS (POIS 0.5 * 10 = 5 SEGUNDOS)
	; A MESMA IDEIA É USADA COM O TIMER PARA ALCANÇAR 2 SEGUNDOS, MAS USAMOS O TIMER 4 VEZES
	
	; OFFSET DO TIMER1 PARA QUE OBTENHAMOS 0.5 s É DE 3035d => 0000101111011011
	MOVLW	B'00001011'
	MOVWF	ADRESH
	MOVLW	B'11011011'
	MOVWF	ADRESL
	
VER_TMR1_1
	; VERIFICA SE HOUVE OVERFLOW EM TMR1
	BTFSS	PIR1, TMR1IF
	; SE TMR1IF = 0, EXECUTA INSTRUÇÃO SEGUINTE (E NÃO HOUVE ESTOURO DO TMR1)
	GOTO	VER_TMR1_1
	; SE TMR1IF = 1, EXECUTA SEGUNDA INSTRUÇÃO (E HOUVE ESTOURO DO TMR1)
	
	; LIMPA FLAG DE ESTOURO DO TMR1 ANTES DE VERIFICAR ESSE BIT DE NOVO
	BCF	PIR1, TMR1IF
	; DECREMENTAMOS EM UMA UNIDADE O CONTADOR CONTADOR_T_5S DE 5 SEGUNDOS 
	DECF	CONTADOR_T_5S, 1
	; AGORA, VERIFICAMOS SE CONTADOR_T_5S TEM VALOR 0 POR MEIO DO REG STATUS
	BTFSS	STATUS, Z
	; SE Z = 0, EXECUTA INSTRUÇÃO SEGUINTE (E NÃO PASSARAM 5 SEGUNDOS AINDA)
	GOTO	VER_TMR1_1
	; SE Z = 1, EXECUTA SEGUNDA INSTRUÇÃO (E OS 5 SEGUNDOS PASSARAM)
	
	; SE OS 5 SEGUNDOS PASSARAM, AGORA SETAMOS GP5 POR 2 SEGUNDOS
	BSF	GPIO, GP5
	
DEF_OFFS_2S
	; OFFSET DO TIMER1 PARA QUE OBTENHAMOS 0.5 s É DE 3035d => 0000101111011011
	MOVLW	B'00001011'
	MOVWF	ADRESH
	MOVLW	B'11011011'
	MOVWF	ADRESL
	
VER_TMR1_2
	; VERIFICA SE HOUVE OVERFLOW EM TMR1
	BTFSS	PIR1, TMR1IF
	; SE TMR1IF = 0, EXECUTA INSTRUÇÃO SEGUINTE (E NÃO HOUVE ESTOURO DO TMR1)
	GOTO	VER_TMR1_2
	; SE TMR1IF = 1, EXECUTA SEGUNDA INSTRUÇÃO (E HOUVE ESTOURO DO TMR1)
	
	; LIMPA FLAG DE ESTOURO DO TMR1 ANTES DE VERIFICAR ESSE BIT DE NOVO
	BCF	PIR1, TMR1IF
	; DECREMENTAMOS EM UMA UNIDADE O CONTADOR CONTADOR_T_2S DE 2 SEGUNDOS 
	DECF	CONTADOR_T_2S, 1
	; AGORA, VERIFICAMOS SE CONTADOR_T_2S TEM VALOR 0 POR MEIO DO REG STATUS
	BTFSS	STATUS, Z
	; SE Z = 0, EXECUTA INSTRUÇÃO SEGUINTE (E NÃO PASSARAM 2 SEGUNDOS AINDA)
	GOTO	VER_TMR1_2
	; SE Z = 1, EXECUTA SEGUNDA INSTRUÇÃO (E OS 2 SEGUNDOS PASSARAM)
	
	; SE OS 2 SEGUNDOS PASSARAM, AGORA DAMOS CLEAR EM GP5
	BCF	GPIO, GP5
	
FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
