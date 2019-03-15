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

;************************************** END MY MACROS *****************************
global Main
;========================== SECTION .DATA ====================
segment .data

helloWorld db 0ah,0dh,'Hola mundo','$'

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
;MY CODE GOES HERE. I left a blank line between segment .text error                                                                  |
segment .text

ORG 100h
Main: ;non local label
 print headerString
 print mainMenu
 exit:
 mov ah, 4ch
 int 21h
	

;************************* END SECTION TEXT ********************************************************