;========================== MACROS MODO GRAFICO ===================================
;---------REGRESAR AL MODO DE TEXTO------------------
ModoTexto macro
;Regresar a modo texto  
mov ax,0003h    
int 10h
mov ax,@data
mov ds,ax
endm

;--------MODO GRAFICO-------------------
ModoGrafico macro
;Iniciacion de modo video  
mov ax,0013h ;nos da una resolución de 200x320 (pixeles (alto,ancho))
int 10h
mov ax, 0A000h
mov ds, ax  ; DS = A000h (memoria de graficos).
endm

;=========================== LOS SIGUIENTE MACROS UTILIZAN LA LLAMADA A LA INTERRUPCION PARA PINTAR =======================
;------PINTAR PIXEL GRAFICO
pixel macro x0, y0, color  
push cx
mov ah, 0ch
mov al, color ;color, número representado del 0-255 (256 colores)
mov bh, 0h
mov dx, y0
mov cx, x0
int 10h 
pop cx
endm

;--------------------Pintar eje X
PintarX macro
LOCAL eje_x
;Dibujar eje de las abscisas  
mov cx,13eh 
eje_x:  
pixel cx,63h,4fh
loop eje_x 
endm

;-----------------Pintar eje Y
PintarY macro cent
LOCAL eje_y
;Dibujar eje de las ordenadas  
mov cx,0c6h
eje_y:  
pixel cent,cx,4fh  
loop eje_y 
endm

;========================= LOS SIGUIENTES MACROS UTILIZAN LA MEMORIA DE VIDEO DIRECTAMENTE (MEJOR) =======================
;----------------Pintar eje X (Forma 2)
PintarX2 macro 
LOCAL eje_x
;Dibujar eje de las abscisas  
mov cx,13eh ;número de iteraciones
mov dl,4fh ;color
eje_x:
mov di,cx ;número de iteración
mov [di+7d00h],dl ;32,000 -> este 32,000 representa los 320 pixeles de ancho por los 100 pixeles de alto para que quede al centro
loop eje_x 
endm

;----------------Pintar eje Y (Forma 2)
PintarY2 macro 
LOCAL eje_y
;Dibujar eje de las abscisas  
mov cx,0c6h ;número de iteraciones
mov dl,4fh ;color
eje_y:
mov di,cx
mov ax,318
mul di
mov di,ax
mov [di+160],dl ;160 -> este 160 representa los 160 pixeles de ancho que es la distancia a la que se estarán pintando las de Y
loop eje_y
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
	enc0 db 0ah,0dh, '	UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',0ah,0dh,'	FACULTAD DE INGENIERIA', 0ah,0dh, '	ESCUELA DE CIENCIAS Y SISTEMAS',0ah,0dh, '	ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 A',0ah,0dh, '	PRIMER SEMESTRE 2019',0ah,0dh, '	OSCAR RENE CUELLAR MANCILLA',0ah,0dh, '	201503712',0ah,0dh, '	EJEMPLO MODO VIDEO','$'
	;MENU PRINCIPAL
	enc1 db 0ah,0dh, '	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0ah,0dh,'	%%%%%%% MENU PRINCIPAL %%%%%%%',0ah,0dh,'	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0ah,0dh,'	%%%% 1. VIDEO 1           %%%%',0ah,0dh,'	%%%% 2. VIDEO 2  	  %%%%',0ah,0dh,'	%%%% 3. SALIR             %%%%',0ah,0dh,'	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%','$'

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
		je Video1
		cmp al,32h ;comparo con el ascii del numero 2
		je Video2
		cmp al,33h
		je Salir
		jmp MenuPrincipal

		;LLAMANDO AL MACRO DE PINTAR PIXEL CADA VEZ
	Video1:
		ModoGrafico
		PintarX
		PintarY 160 ;160 <- representa el centro del eje Y, en este caso tenemos resolución de 200x320, entonces el centro es 160
		getChar
		ModoTexto
		jmp MenuPrincipal

		;UTILIZANDO LA MEMORIA DE VIDEO DIRECTAMENTE, COMO UN ARREGLO MAPEADO (ESTA FORMA ES MAS SENCILLA Y MAS FLUIDA)
	Video2:
		ModoGrafico
		;al mapear el cuadro de modo video de 200x320, se tiene un arreglo de 64,000 posiciones
		PintarX2
		PintarY2
		getChar
		ModoTexto
		jmp MenuPrincipal

;---------------------METODO PARA FINALIZAR EL PROGRAMA-----------------------------
	Salir:
		mov ah, 4ch
		mov al, 00h
		int 21h
main endp ;Termina proceso
end main