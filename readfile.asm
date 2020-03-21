;UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
;FACULTAD DE INGENIERIA
;ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1
;PROYECTO
;LESTER EFRAIN AJUCUM SANTOS
;201504510

ORG 100h
	;--------------- MY MACROS --------------------
%macro print 1		;this macro will print to screen    
	push ax
	push dx
	mov dx, %1		;refers to the first parameter to the macro call
	mov ah, 09h		;09h function write string    
    int 21h			;call the interruption
    pop dx
    pop ax
%endmacro

%macro printAt 3 					;PRINT A CHAR AT ROW,COL IN TEXT MODE 03H
; cursor x, cursor y , string
; column  , line     , data to write
	push ax
  	push bx
  	push dx

    mov bh,00h 	;Video page
 	mov dh,%2 	;set cursor line/row/y
 	mov dl,%1	;set cursor column/col/x
 	mov ah,02h 
 	int 10h

 	mov dx, %3	;offset addres of string
 	mov ah, 09h	;request write string
 	int 21h		;call interruption

 	pop dx
 	pop bx
 	pop ax
%endmacro


%macro printChar 1		;this macro will print to screen    
	push ax
	push dx

	mov dl,%1		;refers to the first parameter to the macro call

	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption
    pop dx
    pop ax
%endmacro

%macro printChar2 1		;this macro will print to screen    
	push ax
	push dx
	push bx
	push cx
	
	mov bx,1
	mov cx,1
	mov dx, %1		;refers to the first parameter to the macro call
	
	mov ah, 40h		;40h function write     
    int 21h			;call the interruption
    pop cx
    pop bx
    pop dx
    pop ax
%endmacro

%macro readInputChar 0
    mov ah, 01h    ;Return AL with the ASCII of the read char
    int 21h        ;call the interruption
%endmacro

;|- - - - - - - - - - - - -  FILE FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - -

%macro CreateFile 1
;%1 ASCIZ filename
	mov cx,00h	;file attribute 00h = normal file or maybe read only
	mov dx,%1 	;dx = ASCIZ filename 
	mov ah,3ch	;request create file
	int 21h
%endmacro

%macro openFile 1
;%1 ASCIZ filename
	mov al, 0h	;access mode (000b = 0h only read)
	mov dx, %1	;offset of ascii file name 
	mov ah, 3dh	;request open File interruption 
	int 21h		;call interruption 21h
%endmacro

%macro openWriteFile 1
;%1 ASCIZ filename
	mov al, 02h	;access mode (000b = 0h only read)
	mov dx, %1	;offset of ascii file name 
	mov ah, 3dh	;request open File interruption 
	int 21h		;call interruption 21h
%endmacro

%macro readFile 2
;%1 Handle from open File, %2 Buffer to store data
	mov bx, %1		;handle
	mov cx, 400h	;bytes to read UPDATE: may give an error 
					;if smaller than the bytes in the input file
	mov dx, %2 		;buffer
	mov ah, 3fh 	;request reading interruption
	int 21h 
%endmacro

%macro closeFile 1
;%1 Handle of file to get close
	;mov bh,[%1]		;copy the high order(8 bits more significant)of handle
	;mov bl,[%1+1]	;copy the low  order(8 bits less significant)of handle
	mov bx, %1
	mov ah,3eh		;request close file interruption
	int 21h 		;call 21h interruption
%endmacro

%macro writeInFile 3
;macro to write in the file
;parameters: %1 data to write, %2 handle, %3 num bytes to write
	;mov bh,[%2]		;copy the high order(8 bits more significant)of handle
	;mov bl,[%2+1]	;copy the low  order(8 bits less significant)of handle
	;push ax
	;push bx
	;push cx
	;push dx
	mov bx,%2		;Handle
	mov cx,%3		;copy num of bytes to write
	mov dx,%1 		;copy the data to write
	mov ah,40h		;request write to file interruption
	int 21h 		;call interruption
	;pop dx
	;pop cx
	;pop bx
	;pop ax
%endmacro

%macro DecToAscii 1
;DecToAscii DecNumberToConvert
	push ax
	push bx
	push dx

	
	mov ax,%1
	cmp ax,0ah 				;ax < 10 (One Digit Number)
	jl %%OneDigit
	cmp ax,63h				;ax > 99 (Three Digit Number)
	jg %%ThreeDigit

	;if not the number is a two digit number
	%%TwoDigit:
	xor bx,bx
	xor dx,dx
	mov bh,0ah				; bh = 10 (Divisor)
	div bh					; ax / bh = al(quotient) ah(remainder)

	add al,30h
	add ah,30h

	mov [numberBf],al
	mov [numberBf+1],ah
	mov al,'$'
	mov [numberBf+2],al
	jmp %%End

	%%OneDigit:
	add ax,30h
	mov [numberBf],al
	mov ah,'$'
	mov [numberBf+1],ah
	jmp %%End

	%%ThreeDigit:
	xor dx,dx
	mov bx,64h
	div bx

	add al,30h
	mov [numberBf],al

	mov ax,dx
	xor dx,dx
	mov bx,0ah
	div bx

	add ax,30h
	mov [numberBf+1],ax
	add dx,30h
	mov [numberBf+2],dx
	mov bx,'$'
	mov [numberBf+3],bx

	%%End:
	pop dx
	pop bx
	pop ax
%endmacro

%macro PreOrder 0
;------------------ DO OPERATIONES IN PREORDER AND SAVE RESULT--------------------
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp

	mov al,0h
	mov [counter],al
	mov [indexOp],al
	mov [indexNum],al

	xor si,si					;clean si
	xor di,di					;clean di
	xor bp,bp 					;clean bp
	xor ax,ax					;clean ax
	
	%%Operation:

	mov ah,[operationsBf+si] 			;ah = number/operator
	;printChar ah
	cmp ah,3bh
	je %%LastCheck
	mov al,[operators]
	cmp ah,al
	je %%StackOperator
	mov al,[operators+1]
	cmp ah,al
	je %%StackOperator
	mov al,[operators+2]
	cmp ah,al
	je %%StackOperator
	mov al,[operators+3]
	cmp ah,al
	je %%StackOperator
	cmp ah,39h
	jg %%Operation
	cmp ah,30h
	jl %%Operation


	%%StackNumber:
	;printChar ah

	mov al,ah
	xor ah,ah
	sub al,30h
	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	mov al,[counter]
	inc al
	mov [counter],al

	inc si

	mov al,[counter]
	cmp al,2 					;Two numbers counted send To Operation
	je %%DoOperation

	jmp %%Operation

	%%DoOperation:
	mov aL,[numStack+bp-3]
	mov ah,[numStack+bp-4]


	mov bl,[numStack+bp-1]
	mov bh,[numStack+bp-2]

	mov cl,[opStack+di-1]

	cmp cl,2ah 		;cl = * (2ah)
	je %%Multiply
	cmp cl,2fh		;cl = / (2fh)
	je %%Division
	cmp cl,2bh 		;cl = + (2bh)
	je %%Sum
	cmp cl,2dh		;cl = - (2dh)
	je %%Subtract

	%%Multiply:
	mul bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di
	
	mov al,'$'
	mov [opStack+di],al

	mov al,[counter]
	dec al
	mov [counter],al

	jmp %%End

	%%Division:
	xor dx,dx
	div bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di
	
	mov al,'$'
	mov [opStack+di],al

	mov al,[counter]
	dec al
	mov [counter],al	
	jmp %%End

	%%Sum:
	add ax,bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di
	
	mov al,'$'
	mov [opStack+di],al
	
	mov al,[counter]
	dec al
	mov [counter],al

	jmp %%End

	%%Subtract:
	sub ax,bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di

	mov al,'$'
	mov [opStack+di],al

	mov al,[counter]
	dec al
	mov [counter],al

	jmp %%End

	%%LastCheck:
	cmp bp,03h
	jg %%DoOperation
	jmp %%PrintResult

	%%StackOperator:
	;printChar ah
	mov [opStack+di],ah
	mov al,'$'
	mov [opStack+di+1],al
	inc di
	mov al,0
	mov [counter],al

	inc si	
	jmp %%Operation

	%%End:
	mov al,[counter]
	cmp al,0h
	jg %%Operation
	
	%%PrintResult:
	mov al,[numStack+1]
	mov ah,[numStack]


	mov [resultBf],ah
	mov [resultBf+1],al

	;print newline
	DecToAscii ax
	;print numberBf
	;print newline

	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
;------------------------------------ END PREORDER OPERATIONS---------------------------

%endmacro

%macro CopyResult 2
;CopyResult bf, bfToCopy
	mov al,[%2]
	mov [%1],al
	mov al,[%2+1]
	mov [%1+1],al
	mov al,[%2+2]
	mov [%1+2],al
	mov al,[%2+3]
	mov [%1+3],al
%endmacro 
global Main
;========================== SECTION .TEXT ======================================================|
;MY CODE GOES HERE. If I left a blank line 
;between this line and "segment .text" gives error                                                                  |
segment .text
;Program Start
Main:
print mainMenu
print newline
print optionLabel
.readOption:
	readInputChar
	cmp al, 49
	je Option1		;Cargar Archivo (1)
	cmp al, 50
	je Option2 		;Imprimir Datos (2)
	cmp al, 51
	je Option3 		;Exit (3)
	cmp al, 52
	je Option4 		;Debuggin (4)
	jmp Main

	Option1:
	call ClearScreen
;	printAt column, line, string
	printAt 24 ,1 ,loadFileLb
	
	xor si,si
	xor ax,ax

	print newline
	print inputPathLabel

	;------------------ GET CONFIG PATH INPUT  --------------------
	.GetUserInput:
	readInputChar			;read a new char from keyboard
	cmp al, 0dh				; al = CR (carriage return) if key enter
	je .EndUserInput
	mov [confPathFile+si],al
	inc si
	jmp .GetUserInput
	.EndUserInput:
	mov al,0
	mov cx,si
	mov [counter],cl
	mov [confPathFile+si],al
	mov al,'$'
	mov [confPathFile+si+1],al
	
	print confPathFile
	print newline
	;jmp Main
	;------------- OPEN FILE CONFIGURATIONS ----------------
;	openFile ASCIZ_file_name
	openFile confPathFile	
	jc .errorOpenFile
	
	;------------- READ FILE CONFIGURATIONS ----------------
;	readFile Handle, BufferToStoreData
	readFile ax, confReadBf
	jc .errorReadFile

	mov [bytesTr],ah
	mov [bytesTr+1],al
	;------------- CLOSE FILE CONFIGURATIONS ---------------
	closeFile bx
	jc .errorCloseFile

	print confReadBf

	;------------------- GET CONFIG DATA --------------------
	mov al,0h
	mov [counter],al
	xor ax,ax
	xor bx,bx
	xor si,si
	xor di,di
	xor bp,bp

	.Analisis:

	mov al,[counter]
	cmp al,02h					;counter = 2 (;) start to get operations
	je .GetOperation
	mov al,[confReadBf+si]
	cmp al, 04h				; al = end of trasmision 
	je .EndFile
	;cmp al, 10				; al = CR (carriage return) if key enter
	;je .EndFile
	cmp al,3bh 					;al = ; (3bh)
	je .CountSC
	inc si
	jmp .Analisis

	.CountSC:					;count semicolon
	mov al,[counter]
	inc al
	mov [counter],al
	inc si
	jmp .Analisis

	.GetOperation:
	mov al,[confReadBf+si]
	;printChar al
	;cmp al, 13				; al = CR (carriage return) if key enter
	;je .EndFile
	;cmp al, 10				; al = CR (carriage return) if key enter
	;je .EndFile
	cmp al, 3bh				; al = ;
	je .EndOperationInput
	mov [operationsBf+di],al
	inc si
	inc di
	jmp .GetOperation
	.EndOperationInput:
	mov [operationsBf+di],al
	inc di
	inc si
	;mov cx,di
	;mov [counter],cl
	mov al,'$'
	mov [operationsBf+di],al
	
	print newline
	print operationsBf
	print newline

	PreOrder

	xor di,di					;clean index for operationsBf
	;jmp .GetOperation

	;-------------------- WHERE TO SAVE -----------------

	mov al,[counterA]			;Level Counter
	cmp al,00h
	je .SaveIn1 				;Save al level 1 values
	cmp al,01
	je .SaveIn2 				;Save al level 2 values
	cmp al,02
	je .SaveIn3 				;Save al level 3 values
	cmp al,03
	je .SaveIn4 				;Save al level 4 values
	cmp al,04
	je .SaveIn5 				;Save al level 5 values
;---------------------------------------- SAVE VALUES CONF FOR LEVEL 1 ---------------------

	.SaveIn1:
	mov al,[counterB]			;Operation counter
	cmp al,00h
	je .Obstacle1
	cmp al,01h
	je .Premio1
	cmp al,02h
	je .Level1
	cmp al,03h
	je .Select1
	cmp al,04h
	je .Avoid1


	.Obstacle1:
	;mov al,[numberBf]
	;mov [obst1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult obst1Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Premio1:
	;mov al,[numberBf]
	;mov [pr1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult pr1Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Level1:
	;mov al,[numberBf]
	;mov [lvl1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult lvl1Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation
	
	.Select1:
	;mov al,[numberBf]
	;mov [ptsSe1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsSe1Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Avoid1:
	;mov al,[numberBf]
	;mov [ptsEs1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsEs1Bf,numberBf

	mov al,[counterB]
	mov al,0h						;clean counter B
	mov [counterB],al

	.GetColor:
	mov al,[confReadBf+si]
	;printChar al
	cmp al, 04h				; al = end of trasmision
	je .EndColorInput
	cmp al, 13				; al = CR (carriage return) if key enter
	je .EndColorInput
	cmp al, 10				; al = CR (carriage return) if key enter
	je .EndColorInput

	mov [color1+di],al
	inc si
	inc di
	jmp .GetColor
	.EndColorInput:
	mov al,'$'
	mov [color1+di],al
	xor di,di				;clean di for next buffer to fill
	;inc si
	print newline
	print color1
	print newline

	mov al,[counterA]		;increment to next save next level values
	inc al
	mov [counterA],al
	
	mov al,0
	mov [counter],al		;clean counter of ;

	jmp .Analisis

;---------------------------------------- SAVE VALUES CONF FOR LEVEL 2 ---------------------

	.SaveIn2:
	
	mov al,[counterB]			;Operation counter
	cmp al,00h
	je .Obstacle2
	cmp al,01h
	je .Premio2
	cmp al,02h
	je .Level2
	cmp al,03h
	je .Select2
	cmp al,04h
	je .Avoid2


	.Obstacle2:


	;mov al,[numberBf]
	;mov [obst1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult obst2Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Premio2:

	;mov al,[numberBf]
	;mov [pr1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult pr2Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Level2:

	;mov al,[numberBf]
	;mov [lvl1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult lvl2Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation
	
	.Select2:

	;mov al,[numberBf]
	;mov [ptsSe1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsSe2Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Avoid2:

	;mov al,[numberBf]
	;mov [ptsEs1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsEs2Bf,numberBf

	mov al,[counterB]
	mov al,0h						;clean counter B
	mov [counterB],al

	.GetColor2:
	mov al,[confReadBf+si]
	;printChar al
	cmp al, 04h				; al = end of trasmision
	je .EndColorInput2
	cmp al, 13				; al = CR (carriage return) if key enter
	je .EndColorInput2
	cmp al, 10				; al = CR (carriage return) if key enter
	je .EndColorInput2

	mov [color2+di],al
	inc si
	inc di
	jmp .GetColor2
	.EndColorInput2:
	mov al,'$'
	mov [color2+di],al
	xor di,di				;clean di for next buffer to fill
	;inc si
	print newline
	print color2
	print newline
	;jmp Main
	mov al,[counterA]		;increment to next save next level values
	inc al
	mov [counterA],al
	
	mov al,0
	mov [counter],al		;clean counter of ;

	jmp .Analisis	

;---------------------------------------- SAVE VALUES CONF FOR LEVEL 3 ---------------------

	.SaveIn3:
	
	mov al,[counterB]			;Operation counter
	cmp al,00h
	je .Obstacle3
	cmp al,01h
	je .Premio3
	cmp al,02h
	je .Level3
	cmp al,03h
	je .Select3
	cmp al,04h
	je .Avoid3


	.Obstacle3:

	;mov al,[numberBf]
	;mov [obst1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult obst3Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Premio3:

	;mov al,[numberBf]
	;mov [pr1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult pr3Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Level3:

	;mov al,[numberBf]
	;mov [lvl1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult lvl3Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation
	
	.Select3:

	;mov al,[numberBf]
	;mov [ptsSe1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsSe3Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Avoid3:

	;mov al,[numberBf]
	;mov [ptsEs1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsEs3Bf,numberBf

	mov al,[counterB]
	mov al,0h						;clean counter B
	mov [counterB],al

	.GetColor3:
	mov al,[confReadBf+si]
	;printChar al
	cmp al, 04h				; al = end of trasmision
	je .EndColorInput3
	;cmp al, 13				; al = CR (carriage return) if key enter
	;je .EndColorInput3
	cmp al, 10				; al = CR (carriage return) if key enter
	je .EndColorInput3

	mov [color3+di],al
	inc si
	inc di
	jmp .GetColor3
	.EndColorInput3:
	mov al,'$'
	mov [color3+di],al
	xor di,di				;clean di for next buffer to fill
	;inc si
	print newline
	print color3
	print newline
	;jmp Main
	mov al,[counterA]		;increment to next save next level values
	inc al
	mov [counterA],al
	
	mov al,0
	mov [counter],al		;clean counter of ;

	jmp .Analisis
;-----------------------------------------------------END LEVEL 3---------------------------------------------------
;---------------------------------------- SAVE VALUES CONF FOR LEVEL 4 ---------------------

	.SaveIn4:
	
	mov al,[counterB]			;Operation counter
	cmp al,00h
	je .Obstacle4
	cmp al,01h
	je .Premio4
	cmp al,02h
	je .Level4
	cmp al,03h
	je .Select4
	cmp al,04h
	je .Avoid4


	.Obstacle4:

	;mov al,[numberBf]
	;mov [obst1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult obst4Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Premio4:

	;mov al,[numberBf]
	;mov [pr1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult pr4Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Level4:

	;mov al,[numberBf]
	;mov [lvl1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult lvl4Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation
	
	.Select4:

	;mov al,[numberBf]
	;mov [ptsSe1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsSe4Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Avoid4:

	;mov al,[numberBf]
	;mov [ptsEs1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsEs4Bf,numberBf

	mov al,[counterB]
	mov al,0h						;clean counter B
	mov [counterB],al

	.GetColor4:
	mov al,[confReadBf+si]
	;printChar al
	cmp al, 04h				; al = end of trasmision
	je .EndColorInput4
	cmp al, 13				; al = CR (carriage return) if key enter
	je .EndColorInput4
	cmp al, 10				; al = CR (carriage return) if key enter
	je .EndColorInput4

	mov [color4+di],al
	inc si
	inc di
	jmp .GetColor4
	.EndColorInput4:
	mov al,'$'
	mov [color4+di],al
	xor di,di				;clean di for next buffer to fill
	;inc si
	print newline
	print color4
	print newline
	;jmp Main
	mov al,[counterA]		;increment to next save next level values
	inc al
	mov [counterA],al
	
	mov al,0
	mov [counter],al		;clean counter of ;

	jmp .Analisis
;-----------------------------------------------------END LEVEL 4---------------------------------------------------

;---------------------------------------- SAVE VALUES CONF FOR LEVEL 5 ---------------------

	.SaveIn5:
	
	mov al,[counterB]			;Operation counter
	cmp al,00h
	je .Obstacle5
	cmp al,01h
	je .Premio5
	cmp al,02h
	je .Level5
	cmp al,03h
	je .Select5
	cmp al,04h
	je .Avoid5


	.Obstacle5:

	;mov al,[numberBf]
	;mov [obst1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult obst5Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Premio5:

	;mov al,[numberBf]
	;mov [pr1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult pr5Bf,numberBf
	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Level5:

	;mov al,[numberBf]
	;mov [lvl1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult lvl5Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation
	
	.Select5:

	;mov al,[numberBf]
	;mov [ptsSe1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsSe5Bf,numberBf

	mov al,[counterB]
	inc al
	mov [counterB],al

	jmp .GetOperation

	.Avoid5:

	;mov al,[numberBf]
	;mov [ptsEs1Bf],al

;	CopyResult bf, bfToCopy
	CopyResult ptsEs5Bf,numberBf

	mov al,[counterB]
	mov al,0h						;clean counter B
	mov [counterB],al

	.GetColor5:
	mov al,[confReadBf+si]
	;printChar al
	cmp al, 04h				; al = end of trasmision 
	je .EndColorInput5
	cmp al, 10				; al = CR (carriage return) if key enter
	je .EndColorInput5

	mov [color5+di],al
	inc si
	inc di
	jmp .GetColor5
	.EndColorInput5:
	mov al,'$'
	mov [color5+di],al
	xor di,di				;clean di for next buffer to fill
	;inc si
	print newline
	print color5
	print newline
	;jmp Main
	mov al,[counterA]		;increment to next save next level values
	inc al
	mov [counterA],al
	
	mov al,0
	mov [counter],al		;clean counter of ;

	;jmp .Analisis
;-----------------------------------------------------END LEVEL 5---------------------------------------------------

	;jmp Main
	
	;jmp .GetOperation
	;print newline
	;print obst1Bf
	;print newline
	;print pr1Bf
	;print newline
	;print lvl1Bf
	;print newline
	;print ptsSe1Bf
	;print newline
	;print ptsEs1Bf
	;print newline
	;jmp Main


	.EndFile: 		;----------- USE THIS FOR CREATE THE FILE CONTAINING ALL VALUES
	;print newline
	print obst2Bf
	print newline
	print pr2Bf
	print newline
	print lvl2Bf
	print newline
	;print ptsSe1Bf
	;print newline
	;print ptsEs1Bf
	;print newline
	jmp Main
;--------------------------------------------------------------------------------	

	.errorOpenFile:
	print errOpenMsg
	jmp Main

	.errorReadFile:
	print errReadFileMsg
	jmp Main

	.errorCloseFile:
	print errCloseFileMsg
	jmp Main

	.errorPathInput:
	print errPathMsg
	jmp Main

	jmp Main

	Option2:				;PREORDER OPERATION
	;------------------ GET CONFIG PATH INPUT  --------------------
	print newline
	print inputOpLabel
	xor si,si
	xor ax,ax

	.GetUserInput:
	readInputChar			;read a new char from keyboard
	cmp al, 0dh				; al = CR (carriage return) if key enter
	je .EndUserInput
	mov [operationsBf+si],al
	inc si
	jmp .GetUserInput
	.EndUserInput:
	mov cx,si
	mov [counter],cl
	mov al,'$'
	mov [operationsBf+si],al
	
	print operationsBf
	print newline


	;------------------ DO OPERATIONES IN PREORDER AND SAVE RESULT--------------------
	mov al,0h
	mov [counter],al
	mov [indexOp],al
	mov [indexNum],al

	xor si,si					;clean si
	xor di,di					;clean di
	xor bp,bp 					;clean bp
	xor ax,ax					;clean ax
	
	.Operation:

	mov ah,[operationsBf+si] 			;ah = number/operator
	printChar ah
	cmp ah,3bh
	je .LastCheck
	mov al,[operators]
	cmp ah,al
	je .StackOperator
	mov al,[operators+1]
	cmp ah,al
	je .StackOperator
	mov al,[operators+2]
	cmp ah,al
	je .StackOperator
	mov al,[operators+3]
	cmp ah,al
	je .StackOperator
	cmp ah,39h
	jg .Operation
	cmp ah,30h
	jl .Operation


	.StackNumber:
	;printChar ah

	mov al,ah
	xor ah,ah
	sub al,30h
	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	mov al,[counter]
	inc al
	mov [counter],al

	inc si

	mov al,[counter]
	cmp al,2 					;Two numbers counted send To Operation
	je .DoOperation

	jmp .Operation

	.DoOperation:
	mov aL,[numStack+bp-3]
	mov ah,[numStack+bp-4]


	mov bl,[numStack+bp-1]
	mov bh,[numStack+bp-2]

	mov cl,[opStack+di-1]

	cmp cl,2ah 		;cl = * (2ah)
	je .Multiply
	cmp cl,2fh		;cl = / (2fh)
	je .Division
	cmp cl,2bh 		;cl = + (2bh)
	je .Sum
	cmp cl,2dh		;cl = - (2dh)
	je .Subtract

	.Multiply:
	mul bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di
	
	mov al,'$'
	mov [opStack+di],al

	mov al,[counter]
	dec al
	mov [counter],al

	jmp .End

	.Division:
	xor dx,dx
	div bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di
	
	mov al,'$'
	mov [opStack+di],al

	mov al,[counter]
	dec al
	mov [counter],al	
	jmp .End

	.Sum:
	add ax,bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di
	
	mov al,'$'
	mov [opStack+di],al
	
	mov al,[counter]
	dec al
	mov [counter],al

	jmp .End

	.Subtract:
	sub ax,bx

	sub bp,4

	mov [numStack+bp],ah
	mov [numStack+bp+1],al
	mov al,'$'
	mov [numStack+bp+2],al
	add bp,02h

	dec di

	mov al,'$'
	mov [opStack+di],al

	mov al,[counter]
	dec al
	mov [counter],al

	jmp .End

	.LastCheck:
	cmp bp,03h
	jg .DoOperation
	jmp .PrintResult


	.End:
	mov al,[counter]
	cmp al,0h
	jg .Operation
	
	.PrintResult:
	mov al,[numStack+1]
	mov ah,[numStack]


	mov [resultBf],ah
	mov [resultBf+1],al

	print newline
	DecToAscii ax
	print numberBf
	print newline
	
	;print opStack
	jmp Main


	.StackOperator:
	printChar ah
	mov [opStack+di],ah
	mov al,'$'
	mov [opStack+di+1],al
	inc di
	mov al,0
	mov [counter],al

	inc si	
	jmp .Operation

;------------------------------------ END PREORDER OPERATIONS---------------------------

	Option3:
	jmp exit

	Option4: 				;--------------- DEBUGGER ----------------
	print newline
	mov ax,4
	mov [mynum],ah
	mov [mynum+1],al
	xor ax,ax
	mov ax,3
	mov [mynum2],ah
	mov [mynum2+1],al
	xor ax,ax
	xor bx,bx
	xor dx,dx
	;mov ax,[mynum]			;DOESN'T WORK
	
	;mov al,[mynum]
	;mov ah,[mynum+1]		;This Output The Same above

	mov al,[mynum+1]		;WORKS
	mov ah,[mynum]			
	
	mov bl,[mynum2+1]
	mov bh,[mynum2]

	;mov dx,ax
	DecToAscii ax			;WORKS
	print numberBf
	print newline		

	;mov dx,bx
	DecToAscii bx			;WORKS
	print numberBf
	print newline

	;add ax,bx				;SUM
	mul bx

	;mov dx,ax
	DecToAscii ax			;WORKS
	print numberBf
	print newline
	jmp Main
exit:
 mov ah, 4ch
 int 21h

ClearScreen:
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
 	mov dh,01h ;row/y = 0
 	mov dl,0h  ;column/x = 0
 	int 10h	   ;call interruption
 	ret
;========================== SECTION .DATA ====================
segment .data

mynum db 0,0,'$'		;320
mynum2 db 0,0,'$' 	; 40

mainMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_________ MENU __________|', 13, 10
        db '|   1. Ingresar           |', 13, 10
        db '|   2. Registrar          |', 13, 10
        db '|   3. Salir              |', 13, 10
        db '|   4. Debugger           |', 13, 10
        db '|_________________________|',13,10,'$'

loadFileLb db '_________ LOAD FILE __________',10,'$'

userlb 	db 'User: ','$'
passlb	db 'Password: ','$'

adminlb db 'Administrador','$'
myuserlb db 'Mi User','$'

videoModeMsg db 'Video Mode: ','$'
name db 'pawz',10

inputPathLabel db 'Ingrese Ruta: ','$'

optionLabel db 'Escoja Opcion: ','$'

userSingLb db 'User (max 7 characters): ','$'

passwSingLb db 'Password (max 4 numbers): ','$'

errWriteFileMsg db 13,10,'Error al escribir en archivo',13,10,'$'

errPathMsg db 13,10,'Error ruta archivo Intente de nuevo',13,10,'$'

errOpenMsg db 13,10,'Error No se puedo Abrir el Archivo',13,10,'$'

openFileMsg db 13,10,'Archivo Abierto correctamente',13,10,'$'

readFileMsg db 13,10,'Archivo Leido correctamente',13,10,'$'

createFileMsg db 13,10,'Archivo Creado correctamente',13,10,'$'

errReadFileMsg db 13,10,'Error No se puedo Leer el Archivo',13,10,'$'

errCreateFileMsg db 13,10,'Error No se puedo Crear el Archivo',13,10,'$'

errCloseFileMsg db 13,10,'Error No se puedo Cerrar el Archivo',13,10,'$'

errUserMsg db 13,10,'Usuario No encontrado ','$' ;29 characters

errUserMatch db 13,10,'Usuario No existe ','$'

UserExistMsg db 13,10,'El usuario ya existe ','$'

userFoundMsg db 13,10,'Usuario correcto','$' ;29 characters

errPasswMsg db 13,10,'Password Incorrecto ','$' ;29 characters

errMaxPasswMsg db 13,10,'Password Incorrecto Solo numeros max 4 ','$' ;29 characters


newline db 13,10,'$'
blankSpace db 20h,'$'

usersBf times 20 db '$'
currentUser times 20 db '$'

counter  db 0,'$'
filePath db 50
fileReadBf times 600 db '$'
confReadBf times 600 db '$'
usersPathFile db 'users.txt',0
confPathFile times 15 db '$'
reportPathFile db 'topten.txt',0
fileHandle times 5 db '$'
char db '$$$'
isAdmin db '$$'
numberBf times 5 db '$'

reportHandle db 0,0,'$'

indexI db 0,'$'
indexJ db 0,'$'

hour db 0,'$','$'
minute db 0,'$','$'
seconds db 0,'$','$'

colors db 0,0,0,0,0,'$'
red db 'rojo','$'
blue db 'azul','$'
yellow db 'amarillo','$'
green db 'verde','$'

operationsBf times 20 db '$'
inputOpLabel db 'Ingrese Operacion: ','$'

opStack times 20 db '$'
numStack times 100 db '$'
resultBf times 4 db '$'
operators db '*','/','+','-','$'

indexOp db 0,'$'
indexNum db 0,'$'


counterB db 0,'$'
counterA db 0,'$'
obst1Bf times 5 db '$'
obst2Bf times 5 db '$'
obst3Bf times 5 db '$'
obst4Bf times 5 db '$'
obst5Bf times 5 db '$'

pr1Bf times 5 db '$'
pr2Bf times 5 db '$'
pr3Bf times 5 db '$'
pr4Bf times 5 db '$'
pr5Bf times 5 db '$'

lvl1Bf times 5 db '$'
lvl2Bf times 5 db '$'
lvl3Bf times 5 db '$'
lvl4Bf times 5 db '$'
lvl5Bf times 5 db '$'

ptsSe1Bf times 5 db '$'
ptsSe2Bf times 5 db '$'
ptsSe3Bf times 5 db '$'
ptsSe4Bf times 5 db '$'
ptsSe5Bf times 5 db '$'

ptsEs1Bf times 5 db '$'
ptsEs2Bf times 5 db '$'
ptsEs3Bf times 5 db '$'
ptsEs4Bf times 5 db '$'
ptsEs5Bf times 5 db '$'

color1 times 10 db '$'
color2 times 10 db '$'
color3 times 10 db '$'
color4 times 10 db '$'
color5 times 10 db '$'

levelTg	db 'NIVEL:' 				;Nivel label (6 bytes)
tmObsTg	db 'tiempo_Obstaculos:'		;tiempo obstaculos (18 bytes)
tmPrTg	db 'tiempo_Premios:' 		;tiempo premios  (15 bytes)
tmLvlTg	db 'tiempo_Nivel:' 			;tiempo nivel (13 bytes)
ptsSlTg	db 'puntos_Seleccion:'  	;puntos seleccion  (17 bytes)
ptsEsTg	db 'puntos_Esquivar:' 		;puntos esquivar (16 bytes)
colorTg	db 'color:' 				;color  (6 bytes)

bytesTr db 0,0,'$'
