;UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
;FACULTAD DE INGENIERIA
;ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1
;PRACTICA 4
;LESTER EFRAIN AJUCUM SANTOS
;201504510

;My first program in assembly!!!


global Main
;========================== SECTION .DATA ====================
segment .data

helloWorld db 0ah,0dh,'Hola mundo','$'
;************************** END SECTION DATA***********************************


;========================== SECTION .BSS  =================================================|
;uninitialized-data sections                                                                            |
segment .bss
;************************** END SECTION BSS **********************************************


;========================== SECTION .TEXT ======================================================|
;MY CODE GOES HERE                                                                   |
segment .text

ORG 100h
Main: ;non local label
 mov ah, 09h
 mov dx, helloWorld
 int 21h
 exit:
 mov ah, 4ch
 int 21h
	

;************************* END SECTION TEXT ********************************************************