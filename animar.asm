; Comando para ensamblar: #nasm animar.asm -o animar.com 
; Finaliza cuando el pixel llega al extremo derecho de la pantalla
;======================================================================|
;							M 	A 	I 	N 						       |
;======================================================================|

ORG	100h

mov ah,00h 			;modo video
mov al,13h			;320x200 256 colores
int 10h 			;servicio de pantalla
		
Mover:
	call Clean
	call Delay
	call Coordenada
	
	mov ax, [CoorX] 	;obtener coordenada x 
	inc ax 				;incrementar coordenada
	mov [CoorX], ax 	;setear nuevo valor
	
	cmp ax, 320 		;la coordenada ya llego al otro extremo?
	jae Fin 			;si es mayor o igual, salir

	jmp Mover

Fin:
	mov ah,00h 			;modo video
	mov al,03h 			;80x25 16 colores
	int 10h 			;servicio de pantalla

	mov ah, 4ch			; funcion 4C, finalizar ejecucion
	int 21h				; interrupcion DOS

;======================================================================
    ; Esta funcion causa retardos 

Delay:
	mov cx, 00h 		; tiempo del delay
	mov dx, 00h 		; tiempo del delay
	mov ah , 86h
	int 15h

	ret    

;======================================================================
	; funcion Clean
	; limpia la memoria de video (llena de 0s o pixeles negros)

Clean:
	mov es, word[startaddr]		;put segment address in es
	mov di, 0					;row 0
	add di, 0					;column 0
	mov cx, 64000				;loop counter
	mov ax, 0					;cannot do mem-mem copy so use reg

	Refresh:
		mov [es:di], ax			;set pixel to colour
		inc di					;move to next pixel
	loop Refresh

	ret

;======================================================================
	; funcion Coordenada
	; pinta segun las coordenadas CoorX y CoorY

Coordenada:
	mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov bx, 14					;color amarillo = 14

	;f(x,y) = x + y*320
	mov ax, [CoorY]		
	mov dx, 320		
	mul dx						;y*320 
	add ax, [CoorX]				;sumar x
	mov di, ax 					;se debe usar DI para direccionamiento de base + indice
	mov [es:di], bx 			;setear color al pixel
	
	ret

;======================================================================|
;							D 	A 	T 	A 						       |
;======================================================================|	

SEGMENT data 
	CoorX dw 0
	CoorY dw 100
  	startaddr dw 0A000h				;inicio del segmento de memoria de video