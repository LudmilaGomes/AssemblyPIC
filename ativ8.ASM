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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_CLKOUT

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
		
		; VARIÁVEIS UTILIZADAS
		END_REC		; ARMAZENA BITS DO ENDEREÇO RECEBIDO DO MASTER
		MEU_END		; ARMAZENA O ENDEREÇO DESTE DISPOSTIVO SLAVE
		CONTADOR	; ARMAZENA VALOR 8; SERÁ USADO NO LOOP QUE ARMAZENA OS BITS RECEBIDOS

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
	MOVLW	B'00000011' 	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0			;RETORNA PARA O BANCO 0
	MOVLW	B'00110001'
	MOVWF	T1CON
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
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

	; GARANTE QUE VALOR DE GP5 NO COMEÇO DO PROGRAMA É 0
	BCF	GPIO, GP5
	; LIMPA FLAG Z DE STATUS
	BCF	STATUS, Z
	
VERIF_SDA_START
	
	; VERIFICA EM SDA SE HOUVE TRANSIÇÃO DE DESCIDA NO SINAL
	BTFSC	GPIO, GP1
	GOTO	VERIF_SDA_START ; GP1 (SDA) CONTINUA EM HIGH
	; GP1 (SDA) FOI PARA LOW
	
	; VERIFICA VALOR DE SCL, SE ESTÁ EM HIGH
	BTFSS	GPIO, GP0	; GP1 (SDA) FOI PARA LOW
	GOTO	VERIF_SDA_START	; START BIT NÃO É RECONHECIDO E VOLTAMOS PARA A PRIMEIRA VERIFICAÇÃO
	
	; CASO PROGRAMA PASSE DESSA ETAPA, QUER DIZER QUE O START BIT FOI RECONHECIDO E PRESSEGUIMOS
	
	; RECONHECIMENTO DO CLOCK (SUBIDA E DESCIDA; QUANDO EM HIGH, BIT DE END É RECEBIDO E EXECUTAMOS CÓDIGO PARA ARMAZENAR SEU VALOR)
	
	; =========================== SEGUNDA ETAPA - ARMAZENAR SUCESSIVAMENTE OS BITS DO ENDEREÇO RECEBIDOS DO MASTER E SALVAR NA VARIÁVEL END_REC
	
VERIF_SCL_LOW_LOOP
	; LOOP PARA VERIFICAR SE CLOCK ESTÁ EM ESTADO LOW
	BTFSC	GPIO, GP0
	GOTO	VERIF_SCL_LOW_LOOP  ; GP0 (SCL) AINDA ESTÁ EM HIGH
	; GP0 (SCL) FOI PARA LOW
VERIF_SCL_HIGH_LOOP
	; LOOP PARA VERIFICAR SE CLOCK ESTÁ EM ESTADO HIGH
	BTFSS	GPIO, GP0
	GOTO	VERIF_SCL_HIGH_LOOP ; GP0 (SCL) AINDA ESTÁ EM LOW
	; GP0 (SCL) FOI PARA HIGH
	
	; É USADO UM CONTADOR PARA SALVAR UM BIT 8 VEZES (O CONTADOR SERÁ DECREMENTADO ATÉ ZERO)
	
	; VERIFICA SE CONTADOR CHEGOU A ZERO A PARTIR DA FLAG Z DE STATUS
	BTFSS	STATUS, Z
	GOTO	SALVA_BIT_END	; CONTADOR AINDA NÃO CHEGOU A ZERO
	; CONTADOR CHEGOU A ZERO E VAMOS VERIFICAR SE ENDEREÇOS RECEBIDO E PRÓPRIO SÃO IGUAIS
	GOTO	VERIF_ENDERECOS
	
SALVA_BIT_END
	; PARA ARMAZENAR OS BITS, SERÁ USADA A FUNÇÃO RLF 
	; RLF f, d: ONDE O CONTEÚDO DO REG f É MOVIDO PARA A ESQUERDA; O VALOR DE STATUS, C É COLOCADO NO BIT
	; MENOS SIGNIFICATIVO DE f; SE d = 1, O RESULTADO É ARMAZENADO EM f
	
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
	; AGORA, VAMOS DECREMENTAR O CONTADOR (QUE IRÁ FAZER O LOOP EXECUTAR 9 VEZES) E USAR A FUNÇÃO RLF
	DECF	CONTADOR, 1
	RLF	END_REC, 1
	
	GOTO	VERIF_SCL_LOW_LOOP
	
	; =========================== TERCEIRA ETAPA - RESPONSÁVEL PELA IDENTIFICAÇÃO DO ENDEREÇO RECEBIDO COM O ENDEREÇO PRÓPRIO DO DISPOSITIVO E,
	; APÓS VERIFICAÇÃO, AÇÃO ADEQUADA PARA CASO DE IGUALDADE E DE DIFERENÇA DOS ENDEREÇOS
	
VERIF_ENDERECOS
	
	; SUBTRAÇÃO PARA VERIFICAR SE VALORES DE MEU_END E END_REC SÃO IGUAIS
	
	; PASSA VALOR DE MEU_END PARA WREG
	MOVFW	MEU_END
	; REALIZA SUBTRAÇÃO E VERIFICA STATUS
	SUBWF	END_REC, 0
	BTFSS	STATUS, Z
	; Z = 0 E ENDEREÇO RECEBIDO *NÃO É* O ENDEREÇO DO DISPOSITIVO
	GOTO	VERIF_STOP_GP1
	; Z = 1 E ENDEREÇO RECEBIDO *É* O ENDEREÇO DO DISPOSITIVO
	
	; AGORA, TRANSFORMA GP1 (SDA) EM SAÍDA PARA INDICAR ACK 1 PARA O MASTER
	BANK1
	MOVLW	B'00000001' 	;CONFIGURA GP1 COMO SAÍDA NO TRISIO
	MOVWF	TRISIO	
	BANK0
	; GP1 AGORA PASSA A SER SAÍDA E ESTÁ EM HIGH
	BSF	GPIO, GP1
	; DEFINE PORTA GP5 COMO HIGH (LED ACESO)
	BSF	GPIO, GP5
	
VERIF_TEMPO_ACK	
	; AGORA, VERIFICAMOS SE O TEMPO DO ACK NO CLOCK JÁ ACABOU
	BTFSC	GPIO, GP0
	; GP0 (SCL) AINDA ESTÁ EM HIGH
	GOTO	VERIF_TEMPO_ACK
	; GP0 (SCL) ESTÁ EM LOW 
	
	; AGORA, PODEMOS CONTROLAR O SCL (COLOCÁ-LO COMO SAÍDA E FORÇAR SEU VALOR PARA LOW)
	BANK1
	MOVLW	B'00000000' 	;CONFIGURA GP0 COMO SAÍDA NO TRISIO
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
	; SE AINDA NÃO HOUVE ESTOURO DO TIMER1, CONTINUAMOS VERIFICANDO
	GOTO	VERIF_ESTOURO_TIMER1
	; SE HOUVE ESTOURO DO TIMER1
	
	; SAÍDAS GP1 E GP5 VÃO PARA LOW
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
	
	; SE GP1 PASSOU PARA HIGH E GP0 TAMBÉM ESTÁ EM HIGH, STOP BIT FOI RECONHECIDO E O PROGRAMA RECOMEÇA!
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
