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
	
	; INTERRUPÇÕES PARA ESTOURO DE TMR1 E PARA FIM DE PROCESSAMENTO DE UMA CONVERSÃO DO CAD
	
	; VERIFICA SE INTERRUPÇÃO FOI DO TIMER1
	BTFSS	PIR1, TMR1IF
	; SE PIR1 = 0, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	INTERR_CAD ; TRATAMOS A INTERRUPÇÃO DO CAD
	; SE PIR1 = 1, EXECUTA SEGUNDA INSTRUÇÃO
	
	; SEGUIMOS COM O TRATAMENTO DA INTERRUPÇÃO DE TMR1
	
	; DESABILITA FLAG DE INTERRUPÇÃO DE TMR1
	BCF	PIR1, TMR1IF
	; REDEFINIMOS OFFSET DE TMR1
	MOVLW	B'00111100'
	MOVWF	TMR1H
	MOVLW	B'10101111'
	MOVWF	TMR1L
	; ATIVA UMA CONVERSÃO DO CAD
	BSF	ADCON0, 1
	
	GOTO	SAI_INT
	
INTERR_CAD 
	; TRATAMENTO DA INTERRUPÇÃO DO CAD
	
	; DESABILITA FLAG DE INTERRUPÇÃO DE CAD
	BCF	PIR1, ADIF
	
	MOVLW	.25
	; SUBTRAÇÃO É USADA PARA SABER SE ADRESH (EM WORK) É MENOR QUE 0.5V (VALOR EQUIVALENTE A 25 EM TERMOS DO CONVERSOR)
	SUBWF	ADRESH, W
	
	; ADRESH > 0.5V E O RESULTADO É POSITIVO - E O CARRY É 1
	; ADRESH < 0.5V E O RESULTADO É NEGATIVO - E O CARRY É 0
	
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0000 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 1.0V
	MOVLW	.51
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0001 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 1.5V
	MOVLW	.76
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0010 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 2.0V
	MOVLW	.102
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0011 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 2.5V
	MOVLW	.127
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0100 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 3.0V
	MOVLW	.153
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0101 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 3.5V
	MOVLW	.178
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0110 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 4.0V
	MOVLW	.204
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_0111 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	
	; CONTINUA VERIFICANDO VALOR DE TENSÃO DE ENTRADA
	; VERIFICA COM 4.5V
	MOVLW	.229
	SUBWF	ADRESH, W
	BTFSS	STATUS, C
	; C = 1, EXECUTA PRIMEIRA INSTRUÇÃO
	GOTO	LABEL_1000 ; DEFINE SAÍDA COMO 0000
	; C = 0, EXECUTA SEGUNDA INSTRUÇÃO
	GOTO	LABEL_1001
	
	; ABAIXO, CADA LABEL É USADO PARA AS SAÍDAS POSSÍVEIS SOLICITADAS PARA A ATIVIDADE
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
	
	; GP2 COMO ENTRADA; GP0, GP1, GP4, GP5 COMO SAÍDAS
	MOVLW	B'00000100' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	
	; DEFINE GP2 COMO ENTRADA ANALÓGICA (AN2)
	; DEFINE CLOCK DO CONVERSOR
	MOVLW	B'00010100' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	ANSEL
	
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	
	; HABILITA INTERRUPÇÕES GLOBAL E DE PERIFÉRICOS
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	
	; HABILITA INTERRUPÇÕES DO CONVERSOR A/D E DO TIMER1
	MOVLW	B'01000001' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	PIE1
	
	BANK0			;RETORNA PARA O BANCO 0
	
	; DEFINE CONFIGURAÇÕES DO CAD
	; JUSTIFICADO À ESQUERDA (USAMOS 8 BITS)
	; TENSÃO DE REFERÊNCIA É VDD
	; CANAL DE ENTRADA DO CONVERSOR É AN2 (GP2)
	MOVLW	B'00001001' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	ADCON0
	
	; DEFINE CONFIGURAÇÕES DO TIMER1
	; HABILITA FUNCIONAMENTO DO TMR1; FUNCIONAMENTO A PARTIR DO CLOCK INTERNO; PRESCALER 1:2
	MOVLW	B'00011001' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	T1CON
	
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; HABILITA PRIMEIRA CONVERSÃO DO CAD
	BSF	ADCON0, 1
	
	; DEFINE OFFSET DO TMR1 PARA CONTAR 100 ms (PASSAR VALORES PARA REG HIGH E LOW, POIS TMR1 É DE 16 BITS)
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
