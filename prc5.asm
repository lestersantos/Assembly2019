;UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
;FACULTAD DE INGENIERIA
;ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1
;PRACTICA 5
;LESTER EFRAIN AJUCUM SANTOS
;201504510

;====================================== MY MACROS =================================
%macro print 1		;this macro will print to screen    
	push ax
	push dx
	mov dx, %1		;refers to the first parameter to the macro call
	mov ah, 09h		;09h function write string    
    int 21h			;call the interruption
    pop dx
    pop ax
%endmacro

%macro printChar 1		;this macro will print to screen    
	push ax
	push dx
	mov dl, %1		;refers to the first parameter to the macro call
	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption
    pop dx
    pop ax
%endmacro

%macro readInputChar 0
    mov ah, 01h    ;Return AL with the ASCII of the read char
    int 21h        ;call the interruption
%endmacro

%macro readString 0

%endmacro;----------END MACRO READING STRING

%macro openFile 1
	mov al, 0h	;access mode (000b = 0h only read)
	mov dx, %1	;offset of ascii file name 
	mov ah, 3dh	;request open File interruption 
	int 21h		;call interruption 21h
%endmacro

%macro readFile 1
	mov bx, %1	;handle
	mov cx, 400h ;bytes to read UPDATE: may give an error if smaller than the bytes in the input file
	mov dx, fileReadBf
	mov ah, 3fh ;request reading interruption
	int 21h
 
%endmacro

%macro getString 1
	;due to procedure getStringOp both use di register. But getStringOp has to keep a sequence
	;of the last element add to array opNamesArray we push the index di to the stack
	;so that we can use di free to get a string in this procedure getString after the
	;procedure ends we restore de past di value
	push di 					
	xor di,di
	mov di,00h
	mov al,0h					;state = 0
	%%dfa:
	mov dh, [fileReadBf + si] 	;get a character from the file buffer
	cmp al, 0h 					;al = 0 state = 0
	je %%So
	cmp al, 01h					;al = 1 state = 1
	je %%S1
	
	%%So: 						;STATE = 0
	cmp dh, 22h					;dh = left " 
	jne errorInFile 			;if not equal to " then go to error IN File
	mov [%1+di],dh 				;add the first double quote "...
	mov al,01h					;al = 1  state = 1
	jmp %%transition 			;jump to transition

	%%S1: 						;STATE = 1
	cmp dh, 09h 				;dh = 09 (ascii tab)
	je %%concatenate
	cmp dh, 20h					;dh < 20 (ascii space)
	jl errorInFile
	cmp dh, 7eh 				;dh > 7e (ascii ~)
	jg errorInFile
	jmp %%concatenate 			;either case is a valid char concatenate
	
	%%concatenate:
	inc di
	mov [%1+di],dh 				;add a char after "char..
	cmp dh, 22h 				;dh = right " (ascii 22h)
	je %%EndString 				;go to EndString
	mov al,01h					;al = 1  state = 1
	jmp %%transition

	%%transition:
	inc si 						;increment to next char
	jmp %%dfa					;go back to dfa again like an automata
	%%EndString:
	inc di
	mov dh, '$'
	mov [%1+di],dh
	pop di
%endmacro
%macro getStringOp 1
	;pop di 						;at first di begins with 0. Each operation
								;continue after the last position of the last name read it 
	mov al,0h					;state = 0
	%%dfa:
	mov dh, [fileReadBf + si] 	;get a character from the file buffer
	;printChar dh
	cmp al, 0h 					;al = 0 state = 0
	je %%So
	cmp al, 01h					;al = 1 state = 1
	je %%S1
	
	%%So: 						;STATE = 0
	cmp dh, 22h					;dh = left " 
	jne errorInFile 			;if not equal to " then go to error IN File
	mov [%1+di],dh 				;add the first double quote "...
	mov al,01h					;al = 1  state = 1
	jmp %%transition 			;jump to transition

	%%S1: 						;STATE = 1
	cmp dh, 09h 				;dh = 09 (ascii tab)
	je %%concatenate
	cmp dh, 20h					;dh < 20 (ascii space)
	jl errorInFile
	cmp dh, 7eh 				;dh > 7e (ascii ~)
	jg errorInFile
	jmp %%concatenate 			;either case is a valid char concatenate
	
	%%concatenate:
	inc di
	mov [%1+di],dh 				;add a char after "char..
	cmp dh, 22h 				;dh = right " (ascii 22h)
	je %%EndString 				;go to EndString
	mov al,01h					;al = 1  state = 1
	jmp %%transition

	%%transition:
	inc si 						;increment to next char
	jmp %%dfa					;go back to dfa again like an automata
	%%EndString:
	;inc di
	;mov dh, '$'
	;mov [%1+di],dh
	;push di						;save the last index for next operation name
	inc di
	mov dh, '#'					;add # as delimitator for the last name agregate
	mov [%1+di],dh
	inc di 						;restore di value. See begining comment in this procedure ^
%endmacro

%macro showOpeNames 0
	;push di
	mov di, 00h
	%%while:
	print [opNamesArray + di]
	;pop di
%endmacro
%macro CmpString 3
	mov si,%1
	mov di,%2
	mov cx,%3
   	cld
   	repe  cmpsb
    jne  %%NoEqual             ;jump when ecx is zero
    print strEqualMsg
    mov al,01h
    jmp %%exit
    %%NoEqual:
    print strNoEqualMsg
    mov al,0h
    %%exit:

%endmacro
%macro parea 1
	%%CompareChar:
	mov dh, [fileReadBf + si] 	;get a character from the file buffer
	printChar dh
	;printChar %1
	cmp dh, 20h					;dh = blankSpace
	je %%WhiteSpace
	cmp dh, 9h					;dh = horizontal tab
	je %%WhiteSpace
	cmp dh, 0dh					;dh = carriage return CR
	je %%WhiteSpace
	cmp dh, 0ah					;dh = carriage return CR
	je %%WhiteSpace
	jmp %%TokenChar

	%%WhiteSpace:
	inc si						;do nothing just increment in one char
	jmp %%CompareChar			;jump to CompareChar

	%%TokenChar:
	cmp dh,%1					;compare it with the parameter
	je %%GetNextChar 			;if are equal jmp to GetNextChar
	jmp errorInFile
	%%GetNextChar:
	inc si 
%endmacro
%macro GetNextToken 1
	%%CompareChar:
	mov dh, [fileReadBf + si] 	;get a character from the file buffer
	printChar dh
	;printChar %1
	cmp dh, 20h					;dh = blankSpace
	je %%WhiteSpace
	cmp dh, 9h					;dh = horizontal tab
	je %%WhiteSpace
	cmp dh, 0dh					;dh = carriage return CR
	je %%WhiteSpace
	cmp dh, 0ah					;dh = carriage return CR
	je %%WhiteSpace
	jmp %%TokenChar

	%%WhiteSpace:
	inc si						;do nothing just increment in one char
	jmp %%CompareChar			;jump to CompareChar

	%%TokenChar:
	cmp dh,%1					;compare it with the parameter
	je %%GetNextChar 			;if are equal jmp to GetNextChar
	%%GetNextChar:
	inc si
%endmacro
;************************************** END MY MACROS *****************************

global Main
;========================== SECTION .DATA ====================
segment .data

headerLabel db 13,13,10
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
        db '|   1. Cargar Archivo     |', 13, 10
        db '|   2. Consola	          |', 13, 10
        db '|   3. Salir.             |', 13, 10
        db '|_________________________|',13,10,'$' 

loadFileLabel db '=============== CARGAR ARCHIVO ===============',13,10,'$'

inputPathLabel db 'Ingrese Ruta: ','$'

optionLabel db 'Escoja Opcion: ','$'

errPathMsg db 13,10,'Error ruta archivo Intente de nuevo',13,10,'$'

errOpenMsg db 13,10,'Error No se puedo Abrir el Archivo',13,10,'$'

openFileMsg db 13,10,'Archivo Abierto correctamente',13,10,'$'

readFileMsg db 13,10,'Archivo Leido correctamente',13,10,'$'

errReadFileMsg db 13,10,'Error No se puedo Leer el Archivo',13,10,'$'

errCreateFileMsg db 13,10,'Error No se puedo Crear el Archivo',13,10,'$'

errSintMsg db 13,10,'Error Caracter no esperado: ','$' ;29 characters

newline db 13,10,'$'
blankSpace db 20h,'$'

esUno	db 0ah,0dh,'es uno',10,'$'
esDos	db 0ah,0dh,'es dos',10,'$'
esTres	db 0ah,0dh,'es tres',10,'$'

filePath db 50
fileReadBf times 300 db '$' 

fatherObj times 50 db '$' 		;array to save the name of the father

opNamesArray times 100 db '$'

OperObj times 10 db '$'

OperaNObj times 10 db '$'

divOpName db 22h,'div',22h,'$'
mulOpName db 22h,'mul',22h,'$'
subOpName db 22h,'sub',22h,'$'
addOpName db 22h,'add',22h,'$'
divOpSym db 22h,'/',22h,'$'
mulOpSym db 22h,'*',22h,'$'
subOpSym db 22h,'-',22h,'$'
addOpSym db 22h,'+',22h,'$'
numOpSym db 22h,'#',22h,'$'
idOpName db 22h,'id',22h,'$'

lenOpName equ 3
lenOpSym equ 1
lenIdOp equ 2


mytest db 'div','$'
strEqualMsg db 13,10,'Strings son iguales',13,10,'$'
strNoEqualMsg db 13,10,'Strings No son iguales',13,10,'$'
;************************** END SECTION DATA***********************************

 
;==========================  SECTION .BSS  =================================================|
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
 print headerLabel
 print mainMenu
 print newline
 print optionLabel
 readInputChar
	cmp al, 49
	je Option1
	cmp al, 50
	je Option2
	cmp al, 51
	je Option3
;=====OPTION 1=============
Option1:
	print esUno
	print loadFileLabel
	print inputPathLabel
	xor si,si				;SI will be used for index of filePath array
	mov si,0
	;geth the input path				
	GetPath:
	readInputChar
	cmp al, 0dh    		 	; al = CR(carriage return)
	je errorPathInput 		; if is CR is an error jump to errorPathInput
	cmp al, 2eh			 	; al = DOT(ascii 46) 
	je GetPathExt			; jump to extJSON to check json extension
						 	; use dot as delimitator to end of input file path	
	mov [filePath + si],al	; is a char for file path name
	inc si					;increment si = si + 1 to the next position of array
	jmp GetPath 			;return to loop GetPath
	jmp Main 				;just a label for return to Main menu
    ;Get the path extension
	GetPathExt:				;get the extension of file
	mov [filePath + si] ,al ;concatenate dot (.)
	inc si					;increment si to next position in filePath array
	checkExt:				;check json extension - update: any other extension
	readInputChar 			;read a new char for the extension path file
	cmp al, 0dh    		 	; al = CR(carriage return) if key enter pressed end of reading 
	je EndOfFilePath 		;if not CR then a char is coming
	mov [filePath + si] ,al ;concatenate letter (anything)
	inc si
	jmp checkExt 			;return to checkExt and keep reading

	EndOfFilePath:
	mov al, 0			 	;null character due to ASCIZ
    mov [filePath+si],al	;add null character/end of string
    inc si					;increment si 
	mov al , '$'			;
	mov [filePath + si],al	;add end of string '$'
	OpeningFile:			;label open file 
	print newline
	print filePath 			;print the file path input
	print newline
	;========== OPEN THE FILE ===========
	openFile filePath 		;call macro for open the file pass the path input
	jc errorOpenFile 		;if the file couldn't be open jump to error
	;push ax 				;push handle into stack before print message
	print openFileMsg 		;print the file got open
	;pop ax 					;retrieve the file handle
	;========== READ THE FILE ===========
	readFile ax 			;call macro readFile and pass the handle as parameter
	jc errorReadFile 		;if file couldn't be read jump to error
	print readFileMsg  		;print message file read
	jmp Scanner
	jmp Main
;================================= OPTION 2 AND 3 ==================
Option2:
	print esDos
	jmp Main
Option3:
	print esTres
	jmp exit

;====================== ANALISYS OF THE FILE ===============
Scanner:
mov si,0h
mov al,0h
call Start
;showOpeNames
print fatherObj
print opNamesArray
;CmpString subOpName,mytest,lenOpName
jmp Main
;============== START ::= lbrace BODY rbrace
Start: 						;START Production
parea 7bh					;send character = { (Ascii 7bh)
call Body
parea 7dh					;send character = } (Ascii 7dh)
ret
;============= BODY ::= ARRAY ==============================
Body:
call Array
ret
;============= ARRAY::= string colon lbrack LISTOP rbrack =================
Array:
parea 22h					;send character = left " (Ascii 22h)
dec si
getString fatherObj 		;the last index in si was for left "
;print fatherObj
mov di, 00h 				;intialize di = 0 after getting the name of the father
xor di,di
inc si 						;increment si to get the next char
parea 3ah					;send character = colon : (Ascii 3a)
parea 5bh					;send character = lbracket [ (Ascii 5bh)
call ListOP
parea 5dh					;send character = rbracket ] (Ascii 5dh)
ret
;============ LISTOP ::= LISTOP coma OP 
;						|OP
ListOP:
call OP
GetNextToken 2ch			;send character = coma , (Ascii 2ch)
							;iscoma help to delete all tabs and space
							;and reach the next char after rbrace }
cmp dh, 2ch					;dh = coma ,compare if the next char is a coma or not 
je ListOP 
dec si 						;decrease SI so we can have the character after rbrace }
							;when return after the call
ret
;============ OP::= lbrace OPOBJ rbrace
OP:							;production for a single operation {"operation"},{"operation2"}...
parea 7bh					;send character = lbrace { (Ascii 7bh)
call OPOBJ					;Call to operation object wich has operators in it
parea 7dh					;send character = } (Ascii 7dh)
ret
;=========== OPOBJ::= string colon lbrace OPERATORBJ rbrace
OPOBJ:
parea 22h					;send character = left ".. (Ascii 22h)
dec si 						;decrement si so it can read left ".. again
getStringOp opNamesArray	;Get The name of the current operation and append it to an array
inc si 						;increment si due to last char was right .."

parea 3ah					;send character = colon : (Ascii 3a)
parea 7bh					;send character = lbrace { (Ascii 7bh)
call OPERTOBJ				;Call to OPERATORobject production
parea 7dh					;send character = } (Ascii 7dh)
ret
;OPERATOR OBJECT -> IDOPER can be either "div","/","mul","*","sub","-","add","+"
;=========== OPERTOBJ::= IDOPER colon lbrace PROPER rbrace
OPERTOBJ:
parea 22h					;send character = left ".. (Ascii 22h)
dec si 						;decrement si so it can read left ".. again
getString OperObj   	    ;Get The name of the current OPERATOR and append it to an array
inc si 						;increment si due to last char was right .."
;print OperObj
parea 3ah					;send character = colon : (Ascii 3a)
parea 7bh					;send character = lbrace { (Ascii 7bh)
;call PROPERT 				;production PROPERT
parea 7dh					;send character = rbrace } (Ascii 7dh)
ret
;========== PROPERT::= OPERAND coma OPERAND
;PROPERT:
;dec si 						;decrement si so it can read left ".. again
;getString OperNObj   	    ;Get The name of the current OPERATOR and append it to an array
;inc si 						;increment si due to last char was right .."
;parea 3ah					;send character = colon : (Ascii 3a)
;GetNextToken 7bh			;send character = lbrace { (Ascii 7b)
;cmp dh, 7bh					;compare if dh = lbrace { (Ascii 7b)
;jne OPERAND 				;if not equal means that is a "#" or "id"
;call OPERAND

ret
;========== OPERAND::= OPERTOBJ
;					 | ONEOPER
OPERAND:
;CmpString OperNObj,numOpSym,lenOpSym
;cmp ah,01h			;if is "#"
;je NUM:
;NUM:
;parea 3ah


ret
;======================== REGULAR EXPRESIONS =========================


;======================== PRINT ERRORS SECTION =======================
errorOpenFile:
print errOpenMsg
jmp Main

errorReadFile:
print errReadFileMsg
jmp Main

errorPathInput:
print newline
print errPathMsg
jmp Main

errorInFile:
print errSintMsg
printChar dh
print newline
jmp Main

exit:
 mov ah, 4ch
 int 21h
;************************* END SECTION TEXT ********************************************************