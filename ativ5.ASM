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
	
	; FLAG DE INTERRUPÇÃO DO COMPARADOR EM 0
	BCF	PIR1, CMIF
	; DESABILITA MOMENTAMEAMENTE INTERRUPÇÃO POR MUDANÇA DO OUTPUT DO COMPARADOR
	BCF	PIE1, CMIE
	
	; COMEÇAMOS COM REFERÊNCIA INTERNA DE 0.5V
	; VAMOS VERIFICAR SE COUT == 1
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 0.5V
	; ALTERAMOS PARA A REFERÊNCIA INTERNA SEGUINTE (QUE É 1V) E MUDAMOS A SAÍDA PARA 001
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR0
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDANÇA DO VALOR DA REFERÊNCIA INTERNA PARA 1V
	BANK1
	MOVLW	B'10100101'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 1V
	; ALTERAMOS PARA A REFERÊNCIA INTERNA SEGUINTE (QUE É 1.5V) E MUDAMOS A SAÍDA PARA 010
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR1
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDANÇA DO VALOR DA REFERÊNCIA INTERNA PARA 1.5V
	BANK1
	MOVLW	B'10100111'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 1.5V
	; ALTERAMOS PARA A REFERÊNCIA INTERNA SEGUINTE (QUE É 2V) E MUDAMOS A SAÍDA PARA 011
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR2
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDANÇA DO VALOR DA REFERÊNCIA INTERNA PARA 2V
	BANK1
	MOVLW	B'10000101'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 2V
	; ALTERAMOS PARA A REFERÊNCIA INTERNA SEGUINTE (QUE É 2.5V) E MUDAMOS A SAÍDA PARA 100
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR3
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDANÇA DO VALOR DA REFERÊNCIA INTERNA PARA 2.5V
	BANK1
	MOVLW	B'10101100'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 2.5V
	; ALTERAMOS PARA A REFERÊNCIA INTERNA SEGUINTE (QUE É 3V) E MUDAMOS A SAÍDA PARA 101
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR4
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDANÇA DO VALOR DA REFERÊNCIA INTERNA PARA 3V
	BANK1
	MOVLW	B'10001011'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 3V
	; ALTERAMOS PARA A REFERÊNCIA INTERNA SEGUINTE (QUE É 3.5V) E MUDAMOS A SAÍDA PARA 110
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR5
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; MUDANÇA DO VALOR DA REFERÊNCIA INTERNA PARA 3.5V
	BANK1
	MOVLW	B'10001110'
	MOVWF	VRCON
	BANK0
	
	; SE COUT == 1, VALOR DE ENTRADA É MAIOR QUE 3.5V E MUDAMOS A SAÍDA PARA 111
	
	; VERIFICA VALOR ATUAL DE COUT
	BTFSS	CMCON, COUT
	; SE VALOR ATUAL DE COUT == 0: EXECUTA INSTRUÇÃO SEGUINTE
	GOTO	SAIDA_VALOR6
	; SE VALOR ATUAL DE COUT == 1: EXECUTA SEGUNDA INSTRUÇÃO
	GOTO	SAIDA_VALOR7
	
SAIDA_VALOR7
	; SAÍDA EM 111 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BSF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR6
	; SAÍDA EM 110 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BSF	GPIO, GP2
	BCF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR5
	; SAÍDA EM 101 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BCF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR4
	; SAÍDA EM 100 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BSF	GPIO, GP4
	BCF	GPIO, GP2
	BCF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR3
	; SAÍDA EM 011 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BSF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
SAIDA_VALOR2
	; SAÍDA EM 010 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BSF	GPIO, GP2
	BCF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
	
SAIDA_VALOR1
	; SAÍDA EM 001 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BCF	GPIO, GP2
	BSF	GPIO, GP0
	
	GOTO	ANTES_SAIDA
	
SAIDA_VALOR0
	
	; SAÍDA EM 000 (RESPECTIVAMENTE, GP4, GP2, GP0)
	BCF	GPIO, GP4
	BCF	GPIO, GP2
	BCF	GPIO, GP0
	
ANTES_SAIDA
	
	; POR FIM, ALTERAMOS O VALOR DA REFERÊNCIA INTERNA DE VOLTA PARA 0,5V
	BANK1
	MOVLW	B'10100010'
	MOVWF	VRCON
	BANK0
	
	; EM SEGUIDA, HABILITA INTERRUPÇÃO POR MUDANÇA DO OUTPUT DO COMPARADOR
	BSF	PIE1, CMIE
	
	; VALOR DE COUT VOLTA PARA 0
	BCF	CMCON, COUT
	
	; SAÍDA DA INTERRUPÇÃO
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
	; TRISIO - ENTRADAS: GP1; SAÍDAS: GP4, GP2, GP0
	MOVLW	B'00000010' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	
	; VRCON - HABILITA CIRCUITO PARA USO DE VREF;
	; CONFIGURAÇÕES INICIAIS SERÃO: LOW RANGE; N = 0010
	; A MEDIDA QUE REALIZAMOS A VERIFICAÇÃO DO VALOR DE ENTRADA, MUDAMOS ESSAS CONFIGURAÇÕES
	MOVLW	B'10100010'
	MOVWF	VRCON
	
	; ANSEL - PERMITIR QUE ENTRADA GP1 SEJA ANALÓGICA
	MOVLW	B'00000010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	
	; USO DE INTERRUPÇÃO! A ESPECIFICAÇÃO DA ATIVIDADE 5 INDICA QUE INDICAÇÃO DE
	; MUDANÇA DA SAÍDA DEVE SER FEITA DE FORMA CÍCLICA E TÃO RÁPIDA QUANTO FOR
	; POSSÍVEL; INTERPRETO DA SEGUINTE FORMA: PARA UMA MUDANÇA DO OUTPUT DO COMPARADOR,
	; TEMOS UMA RESPOSTA IMEDIATA À ESSA MUDANÇA COM O USO DE INTERRUPÇÃO; ENTÃO, 
	; VAMOS TER UMA INTERRUPÇÃO CADA VEZ QUE O COUT DO COMPARADOR FOR 1
	
	; INTCON - HABILITA INTERRUPÇÃO GLOBAL E INTERRUPÇÃO DE PERIFÉRICO
	MOVLW	B'11000000'
	MOVWF	INTCON
	
	; PIE1 - HABILITA INTERRUPÇÃO DE COMPARADOR
	MOVLW	B'00001000'
	MOVWF	PIE1
	
	BANK0			;RETORNA PARA O BANCO 0
	
	; DEFINE COUTPUT INVERTIDO (QUANDO GP1 > VREF: A SAÍDA É 1)
	; MODO DO COMPARADOR 100 (COMPARADOR SEM OUTPUT EM GP2 E COM USO DE REFERÊNCIA INTERNA)
	MOVLW	B'00010100'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; MAIN VAZIA
	; LÓGICA DE IMPLEMENTAÇÃO NO TRATAMENTO DE INTERRUPÇÃO
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
