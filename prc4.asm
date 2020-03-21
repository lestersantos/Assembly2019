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

%macro printChar 1		;this macro will print to screen    
	mov dl, %1		;refers to the first parameter to the macro call
	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption
%endmacro

%macro readInputChar 0
    mov ah, 01h    ;Return AL with the ASCII of the read char
    int 21h        ;call the interruption
%endmacro

%macro readString 0
	mov si, 0			;initialize counter in 0
	%%while:
	mov ah, 01h
	int 21h
	cmp al, 0dh    		 ; al = CR(carriage return)
	je %%skip 
	cmp al, 45h 		 ; al = letter E
	je %%letterE
	cmp al, 53h 		 ; al = letter S
	je %%letterS		 ;jump to state S either for SAVE or SHOW
	jmp %%endReading	 ;end macro readString
	%%letterE:
	mov [option + si],al ;save letter E in option[0]
	inc si				 ;increase counter to 1
	mov ah, 01h
	int 21h
	cmp al, 58H ;al = letter X
	je %%letterX
	jmp %%endReading
	%%letterX:
	mov [option + si],al ;save letter X in option[1]
	inc si				 ;increase counter to 2
	mov ah, 01h
	int 21h
	cmp al, 49h ;al = letter I
	je %%letterI
	jmp %%endReading
	%%letterI:
	mov [option + si],al ;save letter I in option[2]
	inc si				 ;increase counter to 3
	mov ah, 01h
	int 21h
	cmp al, 54h ;al = letter T
	je %%letterT
	jmp %%endReading
	%%letterT: 			 ;last state for option EXIT
	mov [option + si],al ;save letter T in option[3]
	print newline
	print optionMsg
	print option
	mov ah,'0'	 ;the option to run is optionRun = (EXIT,0)
	mov [optionRun],ah		
	jmp %%endReading	 ;end macro readingString
	%%letterS:
	mov [option + si],al ;save letter S in option[0]
	inc si				 ;increase counter to 1
	mov ah, 01h			 ;request reading character
	int 21h				 ;call interruption
	cmp al, 41H 		 ;if al = letter A
	je %%letterA		 ;jump to state letter A
	cmp al, 48h 		 ;if al = letter H
	je %%letterH         ;then jump to state H for SHOW
	jmp %%endReading	 ;Error no input match end macro
	%%letterA:			 
	mov [option + si],al ;save letter A in option[1]
	inc si				 ;increase counter to 2
	mov ah, 01h
	int 21h
	cmp al, 56h 		 ;if al = letter V
	je %%letterV
	jmp %%endReading
	%%letterV:
	mov [option + si],al ;save letter V in option[2]
	inc si				 ;increase counter to 3
	mov ah, 01h
	int 21h
	cmp al, 45h 		 ;if al = letter E
	je %%letterE2
	jmp %%endReading
	%%letterE2: 		 ;las state for option SAVE
	mov [option + si],al ;save letter E in option[3]
	print newline
	print optionMsg
	print option
	mov ah , '1'		 ;the option to run is optionRun = (SAVE,1)
	mov [optionRun],ah
	jmp %%endReading	 ;end macro readingString
	%%letterH:
	mov [option + si],al ;save letter H in option[1]
	inc si				 ;increase counter to 2
	mov ah, 01h
	int 21h
	cmp al, 4fh 		 ;if al = letter O
	je %%letterO
	jmp %%endReading
	%%letterO:
	mov [option + si],al ;save letter O in option[2]
	inc si				 ;increase counter to 3
	mov ah, 01h
	int 21h
	cmp al, 57h 		 ;if al = letter W
	je %%letterW
	jmp %%endReading
	%%letterW: 			 ;last state for option SHOW
	mov [option + si],al ;save letter W in option[3]
	print newline
	print optionMsg
	print option
	mov ah,'2' 			 ;the option to run is optionRun = (SHOW,2)
	mov [optionRun],ah
	jmp %%endReading	 ;end macro readingString
	%%skip:
	cmp si,3
	jne %%while
	%%endReading:
%endmacro;----------END MACRO READING STRING

%macro PrintBoard 0

	mov si,0
	mov di,0
	xor cl,cl
	xor ch,ch
	;SCROLL SCREEN UP
	mov ah, 06h	 ;request scroll up
	mov al, 00h	 ;number of lines to scroll up
	mov bh, 07h	 ;black background
	mov cx,0000h ;starting row:column
	mov dx, 194Fh;ending row:column
	int 10h	

	;SET CURSOR POSITION
	mov ah,02h ;request set cursor position
 	mov bh,00h ;number of page
 	mov dh,02h ;row/y = 0
 	mov dl,0h  ;column/x = 0
 	int 10h	   ;call interruption
 	print boardUpperLine
 	mov al,[columnLabel]	;copy the data from columnLabel to AL register
	mov al,'8'					;decrease in 1 the column labels-> columnLabel = columnLabel - 1
	mov [columnLabel],al	;copy the data from AL register to columnLabel 
	%%for1:
		printChar [columnLabel]	;print the rows labels columnLabel = 8
		;print newline			;print a new line for each row label
		mov al,[columnLabel]	;copy the data from columnLabel to AL register
		dec al					;decrease in 1 the column labels-> columnLabel = columnLabel - 1
		mov [columnLabel],al	;copy the data from AL register to columnLabel 
		
		mov ax, si
		
		mov bl, 2

		div bl
		;add ax,'0'
		;add ah,'0'
		mov [remainder],ah
		mov [quotient],al
		inc si
		;inc cl
		push ax
		print remainder
		pop ax
		mov cl,0
		test ah, 1h
		je %%forEven
		mov ch,0
		jmp %%forOdd
		;test ah,1h
		;je %%forOdd
		;print quotient
		;print evenSplitLine
		%%escape:
		cmp si,8
		jne %%for1
		jmp %%end
	%%forEven:
	print emptyBox
	print boxSpliteLine
	print whitePawn ;this way of paint is just for demostration
	inc cl 			;here we need to do an if statement for check
	cmp cl,4 		;which pawn or queen is in the current box then paint it
	jne %%forEven
	print boxSpliteLine
	print newline
	print evenSplitLine
	jmp %%escape
	%%forOdd:
	print oddSplitLine
	jmp %%escape
	%%end:
	print newline
    print boardUpperLine
    

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
	print boardUpperLine
	print newline
	print boardImage
	print blankSpace
	print blankSpace
	xor cl,cl
	mov cl,0h
	print boardUpperLine

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

quotient db '0','$'
option db 'endd','$'	;an array to save the string SHOW,SAVE,SHOW
optionRun db '0','$'		;option to run SHOW,0. SAVE,1. SHOW,2
remainder db '0','$'

headerString db 13,13,10
        db 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',13,10
        db 'FACULTAD DE INGENIERIA ',13,10
        db 'CIENCIAS Y SISTEMAS',13,10
        db 'ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1',13,10
        db 'NOMBRE: LESTER EFRAIN AJUCUM SANTOS',13,10
        db 'CARNET: 201504510',13,10
        db 'SECCION: A',13,10,'$' 

mainMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_________ MENU __________|', 13, 10
        db '|   1. Iniciar Juego      |', 13, 10
        db '|   2. Cargar Juego       |', 13, 10
        db '|   3. Salir.             |', 13, 10
        db '|_________________________|',13,10,'$'      ;Menu para interactuar con el programa

boardUpperLine db 32,32,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,
			   db 250,250,250,250,250,250,250,250,250,250,13,10,'$' ;symbol interpunct or space dot

boardImage db '8 |  |FB|  |FB|  |FB|  |FB| ',10
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

optionMsg db 'The Option Is: ','$'
<<<<<<< HEAD
columnLabel db '8','$'
emptyBox  db '|  ','$'
whitePawn db 'FB','$'
blackPawn db 'FN','$'
boxSpliteLine db '|','$'
evenSplitLine db '   -- == -- == -- == -- ==  ',10,'$'
oddSplitLine  db '   == -- == -- == -- == --  ',10,'$'
boardBtLabel  db '   A  B  C  D  E  F  G  H   ',10,'$'

=======
>>>>>>> 9fbe3e3f9bb71f90efab2e3caf96bbcc297f8384
newline db 13,10,'$'
blankSpace db 20h,'$'

var db 3,'$'
tVar db 'var: ','$'
var2 db 4,'$'
tVar2 db 'var2: ','$'
var3 db 0,'$'
tVar3 db 'var3: ','$'
justvar db 13,10,'A SYMBOL: ',0,1,2,3,4,5,6,7,8,9,11,12,14,15,16,13,10,'$'
;empty space 0
;white pawn  1
;black pawn  2
;white queen 3
;black queen 4
 ;0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
board db 1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2 ;an array of 32 positions


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
	;print gameStart
	;GameStart
	print newline
	;readString
	;print newline
	;print option
	;print blankSpace
	;print optionRun
	PrintBoard
	readInputChar
Opcion2:
	print esDos
	jmp Main
Opcion3:
	print esTres
	jmp exit

prueba:
	print boardImage
	jmp Main
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