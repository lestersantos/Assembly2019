; Comando para ensamblar: #nasm fruta.asm -o fruta.com
; Presionar tecla para finalizar
;======================================================================|
;							M 	A 	I 	N 						       |
;======================================================================|

ORG	100h

mov ah,00h 			;modo video
mov al,13h			;320x200 256 colores
int 10h 			;servicio de pantalla
		
call Poner_Estrella	;pintar estrella
call GetCh2 		;leer caracter

mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla

mov ah, 4ch			; funcion 4C, finalizar ejecucion
int 21h				; interrupcion DOS

;======================================================================
	; funcion Poner_Estrella
	; coloca la fruta, usando MOVS (DI = posicion destino, SI = posicion fuente)

Poner_Estrella:
	mov es, word[startaddr]		;colocar direccion de segmento de video en ES

	;f(158,98) = x + y*320
	mov di, 31360				;y*320 = 98*320 = 31360
	add di, 158					;sumar x

	mov si, estrella1 				;colocar direccion de dato source
	mov cx, 5 					;tamaño del dato a mover
	cld 						;clear direction flag (direccion en que se copian los datos)
	rep movsb 					;mover dato

	mov si, estrella2 				;colocar direccion de dato source
	add di, 315 				;cambiar de fila
	mov cx, 5 					;tamaño del dato a mover
	cld  						;clear direction flag (direccion en que se copian los datos)
	rep movsb 					;mover dato

	mov si, estrella3 				;colocar direccion de dato source
	add di, 315 				;cambiar de fila
	mov cx, 5 					;tamaño del dato a mover
	cld  						;clear direction flag (direccion en que se copian los datos)
	rep movsb  					;mover dato

	mov si, estrella4 				;colocar direccion de dato source
	add di, 315  				;cambiar de fila
	mov cx, 5 					;tamaño del dato a mover
	cld  						;clear direction flag (direccion en que se copian los datos)
	rep movsb 					;mover dato

	mov si, estrella5 				;colocar direccion de dato source
	add di, 315 				;cambiar de fila
	mov cx, 5 					;tamaño del dato a mover
	cld  						;clear direction flag (direccion en que se copian los datos)
	rep movsb 					;mover dato

	ret

;======================================================================
	; funcion GetCh2
	; ascii tecla presionada

GetCh2:
	mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
	int 21h				; interrupcion DOS
	ret					; return

;======================================================================|
;							D 	A 	T 	A 						       |
;======================================================================|	

SEGMENT data 
  	startaddr dw 0A000h				;inicio del segmento de memoria de video

  	;estrella
	estrella1 DB 00, 00, 14, 00, 00
	estrella2 DB 00, 14, 14, 14, 00
	estrella3 DB 14, 14, 14, 14, 14
	estrella4 DB 00, 14, 14, 14, 00
	estrella5 DB 00, 00, 14, 00, 00
	