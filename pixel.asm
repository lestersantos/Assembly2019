; Comando para ensamblar: #nasm pixel.asm -o pixel.com
; Presionar ENTER para finalizar
;======================================================================|
;							M 	A 	I 	N 						       |
;======================================================================|

ORG	100h

mov ah,00h 			;modo video
mov al,13h			;320x200 256 colores
int 10h 			;servicio de pantalla
		
call Pixel 			;pintar pixel
call GetCh2 		;leer caracter

					;regrear al modo anterior
mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla

mov ah, 4ch			; funcion 4C, finalizar ejecucion
int 21h				; interrupcion DOS

;======================================================================
	; funcion Pixel
	; pinta un pixel en el centro de la pantalla

Pixel:
	mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ax, 14					;color amarillo = 14

	;f(160,100) = x + y*320
	mov di, 32000				;y*320 = 100*320 = 32000
	add di, 160					;sumar x
	mov [es:di],ax 				;setear color al pixel
	
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