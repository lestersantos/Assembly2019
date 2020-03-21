;-------------DELAY DOBLE LAZO RECURSIÓN
Delay macro constante
LOCAL D1,D2,Fin
push si
push di

mov si,constante
D1:
dec si
jz Fin
mov di,constante
D2:
dec di
jnz D2
jmp D1

Fin:
pop di
pop si
endm

;----------------- SONIDO EN HZ
Sound macro hz
mov al, 86h
out 43h, al
mov ax, (1193180 / hz) ;numero de hz
out 42h, al
mov al, ah
out 42h, al 
in al, 61h
or al, 00000011b
out 61h, al
 
delay 1500 ;mando a ejecutar el delay para que se escuche el sonido por varios segundos
 
; apagar la bocina
in al, 61h
and al, 11111100b
out 61h, al
endm


;================================================================================
;--------------OBTENER CARACTER DE CONSOLA CON ECHO A PANTALLA----------------------
getChar macro
mov ah,0dh
int 21h
mov ah,01h
int 21h
endm
;--------------MACRO IMPRESION DE CADENA---------------------------
print macro cadena
push ax
push dx
;push ds
mov ax,@data
mov ds,ax
mov ah,09
mov dx,offset cadena
int 21h
;equivalente a lea dx,cadena, inicializa en dx la posicion donde comienza la cadena
;pop ds
pop dx
pop ax
endm

.model small
;-------------------SEGMENTO DE PILA--------------------------
.stack
;-------------------SEGMENTO DE DATO--------------------------
.data
	;----------------------------MENSAJES---------------------------------------------------
	salt db 0ah,0dh, '	','$'
	;ENCABEZADO
	enc0 db 0ah,0dh, '	UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',0ah,0dh,'	FACULTAD DE INGENIERIA', 0ah,0dh, '	ESCUELA DE CIENCIAS Y SISTEMAS',0ah,0dh, '	ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 A',0ah,0dh, '	PRIMER SEMESTRE 2019',0ah,0dh, '	OSCAR RENE CUELLAR MANCILLA',0ah,0dh, '	201503712',0ah,0dh, '	EJEMPLO SONIDO','$'
	;MENU PRINCIPAL
	enc1 db 0ah,0dh, '	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0ah,0dh,'	%%%%%%% MENU PRINCIPAL %%%%%%%',0ah,0dh,'	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0ah,0dh,'	%%%% 1. SONIDO 100 HZ      %%%%',0ah,0dh,'	%%%% 2. SONIDO 800 HZ      %%%%',0ah,0dh,'	%%%% 3. SONIDO 500 HZ      %%%%',0ah,0dh,'	%%%% 4. SALIR             %%%%',0ah,0dh,'	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%','$'

;-------------------SEGMENTO DE CODIGO------------------------
.code
main proc

	MenuPrincipal:
		;--------MOSTRANDO EL MENU PRINCIPAL--------------------------
		print enc0
		print enc1
		print salt
		;--------OBTENIENDO EL NUMERO ESCOGIDO------------------------
		getChar
		cmp al,31h; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
		je Sonido
		cmp al,32h ;comparo con el ascii del numero 2
		je Sonido2
		cmp al,33h
		je Sonido3
		cmp al,34h
		jmp Salir
		jmp MenuPrincipal
	Sonido:
		Sound 100
		jmp MenuPrincipal
	Sonido2:
		Sound 800
		jmp MenuPrincipal
	Sonido3:
		Sound 500
		jmp MenuPrincipal

;---------------------METODO PARA FINALIZAR EL PROGRAMA-----------------------------
	Salir:
		mov ah, 4ch
		mov al, 00h
		int 21h
main endp ;Termina proceso
end main