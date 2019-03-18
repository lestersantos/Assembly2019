;UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
;FACULTAD DE INGENIERIA
;ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1
;PRACTICA 4
;LESTER EFRAIN AJUCUM SANTOS
;201504510

;My first program in assembly!!!

;====================================== MY MACROS =================================
%macro print 1		;this macro will print to screen    
	mov dx, %1		;refers to the first parameter to the macro call
	mov ah, 09h		;09h function write string    
    int 21h			;call the interruption
%endmacro

%macro readInputChar 0
    mov ah, 01h    ;Return AL with the ASCII of the read char
    int 21h        ;call the interruption
%endmacro

%macro GameStart 0
	;call clean

	
	;SCROLL SCREEN UP
	mov ah, 06h
	mov al, 01h
	mov bh, 07h
	mov cx,0000h
	mov dx, 194Fh
	int 10h
	;SCROLL SCREEN DOWN
	;mov ah,07h
	;mov al,08h
	;mov bh, 07h
	;mov cx,0000h
	;mov dx,194fh
	;int 10h
	;SET CURSOR POSITION
	;mov ah,02h 
 	;mov bh,00h
 	;mov dh,00h
 	;mov dl,0h
 	;int 10h
 	print gameStart
	xor cl,cl
	mov cl,0h
	print blankSpace
	print blankSpace
	%%for:
		print boardUpperLine
		inc cl
		cmp cl,25
		jne %%for
	print newline
	print board
	print blankSpace
	print blankSpace
	xor cl,cl
	mov cl,0h
	%%for1:
		print boardUpperLine
		inc cl
		cmp cl,25
		jne %%for1
	print newline
%endmacro
; ·························
;8 |  |FB|  |FB|  |FB|  |FB|  
;   -- == -- ━━ -- ━━ -- ━━
;7 |FB|  |FB|  |FB|  |FB|  |  
 ;  ━━ -- ━━ -- ━━ -- ━━ --
;6 |  |FB|  |FB|  |FB|  |FB|  
 ;  -- ━━ -- ━━ -- ━━ -- ━━
;5 |  |  |  |  |  |  |  |  |  
 ;  ━━ -- ━━ -- ━━ -- ━━ --
;4 |  |  |  |  |  |  |  |  |  
 ;  -- ━━ -- ━━ -- ━━ -- ━━
;3 |FN|  |FN|  |FN|  |FN|  |  
 ;  ━━ -- ━━ -- ━━ -- ━━ --
;2 |  |FN|  |FN|  |FN|  |FN|  
 ;  -- ━━ -- ━━ -- ━━ -- ━━
;1 |FN|  |FN|  |FN|  |FN|  |
 ;  ━━ -- ━━ -- ━━ -- ━━ --  
 ;  A  B  C  D  E  F  G  H
 ; ·························

;************************************** END MY MACROS *****************************
global Main
;========================== SECTION .DATA ====================
segment .data

opcion	db  10,0ah,0dh,'$'

helloWorld db 0ah,0dh,'Hola mundo','$'
esUno	db 0ah,0dh,'es uno',10,'$'
esDos	db 0ah,0dh,'es dos',10,'$'
esTres	db 0ah,0dh,'es tres',10,'$'
gameStart db 10,13,'Juego Iniciado',10,13,'$'

headerString db 13,13,10
        db 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',13,10
        db 'FACULTAD DE INGENIERIA ',13,10
        db 'CIENCIAS Y SISTEMAS',13,10
        db 'ARQUITECTURA DE COMPUTADORAS '
        db 'Y ENSAMBLADORES 1',13,10
        db 'NOMBRE: '
        db 'LESTER EFRAIN AJUCUM SANTOS',13,10
        db 'CARNET: 201504510',13,10
        db 'SECCION: A',13,10,'$' 

mainMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_________ MENU __________|', 13, 10
        db '|   1. Iniciar Juego      |', 13, 10
        db '|   2. Cargar Juego       |', 13, 10
        db '|   3. Salir.             |', 13, 10
        db '|_________________________|',13,10,'$'      ;Menu para interactuar con el programa

boardUpperLine db 250,'$' ;symbol interpunct or space dot

board db '8 |  |FB|  |FB|  |FB|  |FB| ',10
	  db '   -- == -- == -- == -- ==  ',10
	  db '7 |FB|  |FB|  |FB|  |FB|  | ',10 
 	  db '   == -- == -- == -- == --  ',10
	  db '6 |  |FB|  |FB|  |FB|  |FB| ',10  
 	  db '   -- == -- == -- == -- ==  ',10
	  db '5 |  |  |  |  |  |  |  |  | ',10  
 	  db '   == -- == -- == -- == --  ',10
	  db '4 |  |  |  |  |  |  |  |  | ',10 
 	  db '   -- == -- == -- == -- ==  ',10
	  db '3 |FN|  |FN|  |FN|  |FN|  | ',10 
 	  db '   == -- == -- == -- == --  ',10
	  db '2 |  |FN|  |FN|  |FN|  |FN| ',10  
 	  db '   -- == -- == -- == -- ==  ',10
	  db '1 |FN|  |FN|  |FN|  |FN|  | ',10
 	  db '   == -- == -- == -- == --  ',10  
 	  db '   A  B  C  D  E  F  G  H   ',10,'$'

newline db 13,10,'$'
blankSpace db 20h,'$'
;************************** END SECTION DATA***********************************

 
;========================== SECTION .BSS  =================================================|
;uninitialized-data sections                                                                            |
segment .bss
;************************** END SECTION BSS **********************************************


;========================== SECTION .TEXT ======================================================|
;MY CODE GOES HERE. If I left a blank line 
;between this line and "segment .text" gives error                                                                  |
segment .text

ORG 100h
Main: ;non local label
 ;call clean
 print headerString
 print mainMenu

Menu:
	
	readInputChar
	cmp al, 49
	je Opcion1
	cmp al, 50
	je Opcion2
	cmp al, 51
	je Opcion3
	

Opcion1:
	print esUno
	print boardUpperLine
	;print gameStart
	GameStart
	readInputChar
	;jmp Main

Opcion2:
	print esDos
	jmp Main
Opcion3:
	print esTres
	jmp exit

Reset:
    mov ah, 02h         ;Colocar el cursor (02h salida de caracter)
    mov dx, 0000h       ;Colocar en dx las coordenadas
    int 10h             ;interrupcion 10h
    mov ax, 0600h       ;limpiar pantalla ;ah 06(es un recorrido), al 00(pantalla completa)
    mov bh, 07h         ;atributos fondo negro y fuente blanco
    mov cx, 0000h       ;movemos a cx las nuevas coordenadas columna 0 y fila 0 ;es la esquina superior izquierda reglon: columna
    mov dx, 194fh       ;movemos a dx las coordenadas finales fila 24 y columna 79
    int 10h             ;interrupcion 10h
    jmp Main            ;Volvemos a iniciar el programa

clean:
 mov ax,0600h
 mov bh, 07h
 mov cx,0000h 
 mov dx,194Fh  
 int 10h 
 
 mov ah,02h 
 mov bh,00h
 mov dx,00h
 int 10h
 ret

exit:
 mov ah, 4ch
 int 21h
	

;************************* END SECTION TEXT ********************************************************