; Oi, Mundo MSX!
; Este programa exibe "Oi, Mundo MSX!" na tela.

; .header basic   ; Define o tipo de cabeçalho para um programa carregável via MSX-BASIC [3, 4]
org &4000      ; Define o endereço de origem do programa na memória [5].
                ; $C000 é um local comum para programas BASIC evitarem sobreposição [4].
db "AB"
dw INICIO

; Rotinas da BIOS do MSX usadas pelo programa [6, 7]
INIT32 equ 0x006F ; Rotina para mudar a tela para SCREEN 1 (texto) [2, 8]
CHPUT equ 0x00A2  ; Rotina para imprimir um caractere na tela (o caractere deve estar em A) [2, 9]
POSIT equ 0x00C6  ; Rotina para posicionar o cursor (coluna em H, linha em L) [2, 10]
romSize                 equ &8000       ; O tamanho que a ROM deve ter
romArea                 equ &4000       ; Minha ROM começa aqui
ramArea                 equ &E000       ; Inicio da área de variáveis

INICIO:
    call INIT32     ; Chama a rotina INIT32 para configurar a tela no modo texto (SCREEN 1) [2].
    ld hl, Message ; Carrega o endereço inicial da string MENSAGEM no par de registradores DE [2].
                    ; DE é um registrador de 16 bits [11].
		;ld H,10 ; Carrega o valor 10 (coluna x) no registrador H
		;ld L,5 ; Carrega o valor 5 (linha y) no registrador L
		;call POSIT ; Chama a rotina POSIT para posicionar o cursor na tela [2, 10].
		call ImprimeString
		DI
		Halt ; Desabilita interrupções e pausa a execução do programa [2, 12].
ImprimeString:
	ld a,(hl)
	cp 13
	jp z,EndString
	call CHPUT ; Chama a rotina CHPUT para imprimir o caractere atual na tela [2].
	inc hl ; Incrementa o ponteiro HL para o próximo caractere [2].	
	jp ImprimeString ; Salta de volta para imprimir o próximo caractere [2].
EndString:
ret
; Dados do programa
Message:
    db "Oi, Mundo MSX!",13 ; Define a string "Oi, Mundo MSX!" terminada com um byte nulo [2, 15].

										
romPad:
	ds romSize-(romPad-romArea),0