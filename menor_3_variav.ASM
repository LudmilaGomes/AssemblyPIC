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
		
		A1
		A2
		A3
		MENOR

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
	MOVLW	B'00000000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	
	; PROGRAMA TEM TRÊS VALORES E DEVE INDICAR QUAL DOS TRÊS É O MENOR
	; O RESULTADO (O MENOR DENTRE OS TRÊS) É ARMAZENADO NO FILE 'MENOR' AO FIM DA EXECUÇÃO
	
	; COLOCAMOS VALORES EM DOIS TIPOS DE REG
	; W DE WORK (REG TEMPORÁRIO, USADO COMO INTERMEDIÁRIO), F DE FILE (GUARDA DE FATO AS VARIÁVEIS)
	; L DE LITERAL, QUE SIGNIFICA O VALOR ESCRITO (COMO .9, QUE É 9 NO FORMATO DECIMAL)
	MOVLW	.2	    ; MOVE O LITERAL DECIMAL 9 PARA WORK
	MOVWF	A1	    ; MOVE DO WORK PARA FILE DE IDENTIFICADOR A1
	MOVLW	.4	    ; MOVE O LITERAL DECIMAL 2 PARA WORK 
	MOVWF	A2	    ; MOVE DO WORK PARA FILE DE IDENTIFICADOR A2
	MOVLW	.7	    ; MOVE O LITERAL DECIMAL 5 PARA WORK 
	MOVWF	A3	    ; MOVE DO WORK PARA FILE DE IDENTIFICADOR A3
	MOVFW	A1	    ; MOVE DO FILE A1 PARA WORK (AGORA WORK TEM VALOR .9 DE A1)
	MOVWF	MENOR	    ; MOVE DO WORK (MESMO VALOR DE A1) PARA FILE DE IDENTIFICADOR MENOR
	
	; SUBTRAÇÃO É USADA PARA SABER SE A1 (EM WORK) É MENOR QUE A2
	; RESULTADO DA SUBTRAÇÃO É GUARDADO EM WORK
	SUBWF	A2, W	    ; SUBTRAI W DE FILE (F - W => A2 - A1)
	
	; POSSÍVEIS RESULTADOS DA SUBTRAÇÃO: 
	; A2 > A1 E O RESULTADO É POSITIVO - E O CARRY É 1
	; A2 = A1 E O RESULTADO É NULO	   - E O CARRY É 1 (?) E A FLAG ZERO É 1
	; A2 < A1 E O RESULTADO É NEGATIVO - E O CARRY É 0
	
	; NA SUBTRAÇÃO, DIZER QUE HOUVE CARRY É DIZER QUE FOI PRECISO
	; 'PEGAR EMPRESTADO'; O BIT 'C' DO REG 'STATUS' INDICA QUE O
	; CARRY OCORREU QUANDO CLEAR, ISTO É, C = 0 E HOUVE CARRY!
	; SE NÃO HOUVE CARRY, C = 1
	
	; BIT TEST F, SKIP IF SET - BTFSS f, b
	; SE O BIT 'b' DO REGISTRADOR 'f' É ZERO, A PRÓX INSTRUÇÃO É EXECUTADA (PRIMEIRA INSTRUÇÃO)
	; SE O BIT 'b' DO REGISTRADOR 'f' É UM, A PRÓX INSTRUÇÃO É DESCONSIDERADA (SEGUNDA INSTRUÇÃO)
	; E NOP É EXECUTADO EM SEU LUGAR
	BTFSS	STATUS, C   ; VERIFICA O BIT 'C' (É O BIT 0) DO REG 'STATUS'
	
	; SE O BIT C FOR IGUAL A 1 É PORQUE A SUBTRAÇÃO TEVE RESULTADO POSITIVO
	; ISTO É, A2 É MAIOR QUE A1 E O VALOR DA VAR 'MENOR' NÃO É ALTERADA
	; E A PRÓX INSTRUÇÃO É DESCONSIDERADA
	
	; SE O BIT C FOR IGUAL A 0 É PORQUE A SUBTRAÇÃO TEVE RESULTADO NEGATIVO
	; ISTO É, A2 É MENOR QUE A1 E O VALOR DA VAR 'MENOR' DEVE SER ALTERADA
	; E A PRÓX INSTRUÇÃO É EXECUTADA
	
	; (1º INST) PRÓX INSTRUÇÃO: SE A2 < A1 E BIT C DO STATUS É 0
	GOTO A2_MENOR	    ; VAI PARA LABEL A2_MENOR_A1, MENOR É ATUALIZADO E VOLTA AO PROGRAMA
	
	; (2º INST) PRÓX INSTRUÇÃO DESCONSIDERADA: SE A2 > A1 E BIT C DO STATUS É 1
	; VERIFICAÇÃO DA DIFERENÇA ENTRE A3 E 'MENOR':
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
