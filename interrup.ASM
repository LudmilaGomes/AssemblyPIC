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

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

	; HÁ DOIS TIPOS DE INTERRUPÇÃO, A INTERRUPÇÃO DO TIMER0 E A INTERRUPÇÃO
	; DA MUDANÇA DE ESTADO DA PORTA GP3; ASSIM, FAZEMOS A VERIFICAÇÃO PARA
	; A INTERRUPÇÃO DE GP3 (CUJA INTERRUPÇÃO É ATIVADA PARA GP3 = 0) E, SE
	; NÃO ESTIVERMOS NESSA INTERRUPÇÃO, ESTAMOS NA INTERRUPÇÃO DO TIMER0

	; !!! ALGUMA INTERRUPÇÃO OCORRE E O FLUXO DE EXECUÇÃO DO PROGRAMA
	; É DESVIADO PARA CÁ (TRATAMENTO DE INTERRUPÇÃO); O PROGRAMA NÃO
	; SABE QUAL FOI A INTERRUPÇÃO QUE OCORREU, MAS É POR MEIO DE SOFTWARE
	; QUE SE DEFINE O TRATAMENTO ADEQUADO PARA CADA TIPO DE INTERRUPÇÃO
	
	; SE A FLAG DE INTERRUPÇÃO FOI ATIVADA, OU A INTERRUPÇÃO DE GP3 OU A DE
	; TIMER0 OCORREU; ASSIM, VERIFICAMOS:
	
	; VERIFICA ESTADO DE GP3 - VERIFICA SE GP3 É IGUAL A 0
	BTFSS	GPIO, GP3
	; SE GP3 = 0, EXECUTA INSTRUÇÃO SEGUINTE
	; SE GP3 = 0: A INTERRUPÇÃO DE GP3 É A ATUAL
	GOTO	GP3_EH_ZERO
	; SE GP3 = 1, EXECUTA SEGUNDA INSTRUÇÃO
	; SE GP3 = 1, A INTERRUPÇÃO DE TIMER0 É A ATUAL
	GOTO	GP3_EH_UM
	
GP3_EH_ZERO
	; INTERRUPÇÃO DE GP3
	
	BCF	INTCON, T0IE	; DESABILITAMOS A INTERRUPÇÃO DE TIMER0
	BSF	GPIO, GP4	; VALOR DE GP4 PASSA A SER 1 (FREIO ATIVADO EM 0, LUZ EM 1)
	BCF	INTCON, GPIF	; CLEAR BIT DA FLAG DE INTERRUPÇÃO DE MUDANÇA DA PORTA GP3
	GOTO	SAI_INT
	
GP3_EH_UM
	; INTERRUPÇÃO DE TMR0
	
	BSF	INTCON, T0IE	; HABILITAMOS A INTERRUPÇÃO DE TIMER0
	BCF	INTCON, GPIF	; CLEAR BIT DA FLAG DE INTERRUPÇÃO DE MUDANÇA DA PORTA GP3
	CALL	TRAT_TIMER0	; CHAMA FUNÇÃO DE TRATAMENTO DE ESTOURO DO TMR0
	GOTO	SAI_INT
	
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

TRAT_TIMER0
	; REALIZA TRATAMENTO DO TMR0
	
	BCF	INTCON, T0IF	; CLEAR BIT DE FLAG DE ESTOURO DE TMR0
	MOVLW	.131
	MOVWF	TMR0		; REGISTRADOR DO TMR0 RECEBE VALOR 131
	; VERIFICA VALOR DE GP4
	BTFSS	GPIO, GP4
	; SE GP4 = 0, EXECUTA INSTRUÇÃO SEGUINTE
	; SE GP4 = 0: VALOR DE GP4 PASSA A SER 1
	GOTO	GP4_EH_ZERO
	; SE GP4 = 1, EXECUTA SEGUNDA INSTRUÇÃO
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
	
	; GP3 COMO ENTRADA, GP4 COMO SAÍDA
	; TRISIO - 00001000
	
	; OPTION_REG PADRÃO (PULL-UP DESABILITADO ETC)
	
	; HABILITAMOS INTERRUPÇÕES GLOBALMENTE, INTERRUPÇÃO DE TMR0 E
	; INTERRUPÇÃO EM TRANSIÇÃO DE ESTADO DE PORTAS (USAMOS GP3)
	; INTCON - 10101000
	
	; COMO VAMOS USAR GP3 E TRANSIÇÕES NESSA PORTA SERÃO CONSIDERADAS
	; PARA AS INTERRUPÇÕES, ATIVAMOS ESSA PORTA PARA INTERRUPÇÃO EM IOC
	; IOC - 00001000
	
	MOVLW	B'00001000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10101000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00001000'
	MOVWF	IOC
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN	
	
	; LÓGICA DO PROGRAMA IMPLEMENTADA NO TRATAMENTO DE INTERRUPÇÃO
	GOTO	MAIN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
