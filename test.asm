; Comando para ensamblar: #nasm test.asm -o test.com

;======================================================================|
;							M 	A 	I 	N 	 	 	      	       	   |
;======================================================================|

ORG	100h
	mov dx, cadena 		; colocar direccion de cadena en DX
	mov ah, 09h      	; funcion 9, imprimir en pantalla
	int 21h         	; interrupcion DOS
	
	mov ah, 4ch			; funcion 4C, finalizar ejecucion
	int 21h				; interrupcion DOS

;======================================================================|
;							D 	A 	T 	A 		    		   		   |
;======================================================================|	

SEGMENT data

	cadena db "Hola Mundo Arqui1 B $" ;cadena de caracteres ASCII

;======================================================================