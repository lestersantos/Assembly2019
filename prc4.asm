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
        db 'FACULTAD DE INGENIERIA',13,10
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
	print gameStart
	jmp Main
Opcion2:
	print esDos
	jmp Main
Opcion3:
	print esTres
	jmp exit

exit:
 mov ah, 4ch
 int 21h
	

;************************* END SECTION TEXT ********************************************************