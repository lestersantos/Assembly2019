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

;------------------ GRAPHIC FUNCTIONS -------------------------------------------
%macro setVideoMode 1
	mov ah,00h
	mov al,%1
	int 10h
%endmacro 

%macro plotPixel 3
;%1 color, %2 x ,%3 y
;x = x axis Plane (max 320 pixels) ______ x
;y = y axi Planes (max 200 pixels)|
;								 y|	

	push ax
	push di
	push bx
;lexical maph..
;P(x,y) = x + y(320)
	mov ax,%3					;ax = %3 = Y (coordinate) 
	mov bx, 320				;140h = 320 decimal
	mul bx 						;ax*bx = y*320
								;dx ax = result
	mov bx,%2 					;bx = x
	add ax,bx					;ax = x + y*320
	mov di,ax 					

	mov es,word[vgaStartAddr]	;es ->extra segment =0a000h
	mov ax,%1					;color of the pixel
	mov [es:di],ax

	pop bx
	pop di
	pop ax
%endmacro

 %macro pixel 3
 	push ax
  	push bx
  	push dx
  	push di

  	mov ax, %3
  	mov bx, 140h
  	mul bx

  	add ax, %2
  	mov di, ax

  	mov es, word[vgaStartAddr]
  	mov ax, %1
  	mov[es:di], ax

  	pop di
  	pop dx
 	pop bx
 	pop ax
 %endmacro

%macro DrawArea 5 			;DRAW AN AREA IN VIDEO MODE 13H
;%1 , %2 ,   %3  ,  %4    ,  %5
;x,width,y,height,color

; x ,  y , width , height , color
;di , si ,				  ,  %5
	push ax
	push bx
	push si
	push di

	
	mov si,%3			;y coordinate
	mov bx,si			;di = Yindex starting at = y
	add bx,%4			;bx = Yend = Ystart + height
	
	mov di,%1			; di = x coordinate
	mov ax,di			; ax = x
	add ax,%2			; ax = Xend = Xstart + width


	%%Height:			;Y coordinate
	push di
	cmp si,bx 			;si = height ? -> Yindex = Yend ?
	je %%EndHeight	


	%%Width:			;X coordinate
	cmp di,ax			;si = width ? -> Xindex = Xend ?
	je %%EndWidth
	

;	plotPixel %1 color, %2 x ,%3 y
	plotPixel %5,di,si
	inc di 				;x = x + 1
	jmp %%Width

	%%EndWidth:
	inc si				;y = y + 1
	pop di
	jmp %%Height
	%%EndHeight:

	pop di
	pop si
	pop bx
	pop ax

%endmacro
%macro PrintArray 1 			;DRAW AN AREA IN VIDEO MODE 13H
;%1 , 
; bitArray

; x ,  y ,
;di , si 
	push ax
	push bx
	push si
	push di

	
	mov si,0h			;y coordinate
	mov bx,00h			;di = Yindex starting at = y
	add bx,05h			;bx = Yend = Ystart + height
	
	mov di,0h			; di = x coordinate
	mov ax,0h			; ax = x
	add ax,04h			; ax = Xend = Xstart + width


	%%Height:			;si = Y coordinate
	push di
	cmp si,bx 			;si = height ? -> Yindex = Yend ?
	je %%EndHeight	


	%%Width:			;di = X coordinate
	cmp di,ax			;si = width ? -> Xindex = Xend ?
	je %%EndWidth
	
	;LEXICAL MAP for matrix 5*4 -> vector 20 positions
	;P(x,y) = x + y(4)
	push ax
	push bx
	push di
	mov ax,si					;ax  = si = Y (coordinate) 
	mov bx,4					;04h = 4 decimal
	mul bx 						;ax*bx = y*4
								;dx ax = result
	mov bx,di 					;bx = x = di
	add ax,bx					;ax = x + y*4
	mov di,ax

	mov al,[%1+di]
	cmp al,01h
	jne %%PaintBlack
	printChar 01h
	jmp %%End
	%%PaintBlack:
	printChar 0h
	;printChar al

	%%End:
	pop di
	pop bx
	pop ax
	;push ax
	
	
	;printChar 49
	;pop ax
	inc di 				;x = x + 1
	jmp %%Width

	%%EndWidth:
	inc si				;y = y + 1
	pop di
	jmp %%Height
	%%EndHeight:

	pop di
	pop si
	pop bx
	pop ax

%endmacro


%macro DrawChar 3
;DrawChar bitArray,row,column
;		  	%1    , %2,	 %3

; di = x, si = y 
; x ,  y ,
;di , si 
	;push ax
	;push bx
	;push si
	;push di

	
	mov si,0h			;y coordinate
	mov bx,00h			;di = Yindex starting at = y
	add bx,05h			;bx = Yend = Ystart + height
	
	mov di,0h			; di = x coordinate
	mov ax,0h			; ax = x
	add ax,04h			; ax = Xend = Xstart + width


	%%Height:			;si = Y coordinate
	push di
	;print newline
	
	mov [indexI],si
	;printChar [indexI]
	cmp si,bx 			;si = height ? -> Yindex = Yend ?
	je %%EndHeight	
	;printChar [indexI]

	%%Width:			;di = X coordinate
	
	mov [indexJ],di
	cmp di,ax			;si = width ? -> Xindex = Xend ?
	je %%EndWidth
	;printChar [indexJ]
	;LEXICAL MAP for matrix 5*4 -> vector 20 positions
	;P(x,y) = x + y(4)
	push ax
	push bx
	push di
	push si
	mov ax,si					;ax  = si = Y (coordinate) 
	mov bx,4					;04h = 4 decimal
	mul bx 						;ax*bx = y*4
								;dx ax = result
	mov bx,di 					;bx = x = di
	add ax,bx					;ax = x + y*4
	mov di,ax

	mov al,[%1+di]
	cmp al,01h
	jne %%PaintBlack

	mov ax,%2					;ax = row 
	mov bx,5					;bx = 5
	mul bx 						;ax = ax*bx = row*5
	mov si,ax

	mov bx,0h
	mov bl,[indexI]
	add si,bx

	mov ax,%3 					;ax = col
	mov bx,4					;bx = 4
	mul bx						;ax = ax*bx = col*4
	mov di,ax

	mov bx,0h
	mov bl,[indexJ]
	add di,bx
	;printChar 01h
;	plotPixel %1 color, %2 x ,%3 y
	plotPixel 15,di,si
	jmp %%End
	%%PaintBlack:
	mov ax,%2					;ax = row 
	mov bx,5					;bx = 5
	mul bx 						;ax = ax*bx = row*5
	mov si,ax

	mov bx,0h
	mov bl,[indexI]
	add si,bx

	mov ax,%3 					;ax = col
	mov bx,4					;bx = 4
	mul bx						;ax = ax*bx = col*4
	mov di,ax

	mov bx,0h
	mov bl,[indexJ]
	add di,bx
	;printChar 01h
;	plotPixel %1 color, %2 x ,%3 y
	plotPixel 104,di,si
	;printChar 0h
	;printChar al

	%%End:
	pop si
	pop di
	pop bx
	pop ax
	
	inc di 				;x = x + 1
	jmp %%Width

	%%EndWidth:
	inc si				;y = y + 1
	pop di
	jmp %%Height
	%%EndHeight:

	;pop di
	;pop si
	;pop bx
	;pop ax

	
%endmacro

%macro PlotChar 3
; row, column,  
; %1 ,	%2   ,	%3 
	;push ax


	mov al,%3

	%%SearchChar:
	cmp al,41h
	je %%lA
	cmp al,42h
	je %%lB
	cmp al,43h
	je %%lC
	cmp al,44h
	je %%lD
	cmp al,45h
	je %%lE
	cmp al,46h
	je %%lF
	cmp al,47h
	je %%lG
	cmp al,48h
	je %%lH
	cmp al,49h
	je %%lI
	cmp al,4ah
	je %%lJ		
	cmp al,4bh
	je %%lK		
	cmp al,4ch
	je %%lL
	cmp al,4dh
	je %%lM		
	cmp al,4eh
	je %%lN		
	cmp al,4fh
	je %%lO		
	cmp al,50h
	je %%lP
	cmp al,51h
	je %%lQ		
	cmp al,52h
	je %%lR
	cmp al,53h
	je %%lS
	cmp al,54h
	je %%lT
	cmp al,55h
	je %%lU
	cmp al,56h
	je %%lV
	cmp al,57h
	je %%lW
	cmp al,58h
	je %%lX
	cmp al,59h
	je %%lY
	cmp al,5ah
	je %%lZ
	cmp al,30h
	je %%cero
	cmp al,31h
	je %%uno
	cmp al,32h
	je %%dos
	cmp al,33h
	je %%tres
	cmp al,34h
	je %%cuatro
	cmp al,35h
	je %%cinco
	cmp al,36h
	je %%seis
	cmp al,37h
	je %%siete
	cmp al,38h
	je %%ocho
	cmp al,39h
	je %%nueve
	cmp al,3ah
	je %%dospuntos
	jmp %%End
	%%lA:
	DrawChar A,%1,%2
	jmp %%End
	%%lB:
	DrawChar B,%1,%2
	jmp %%End
	%%lC:
	DrawChar C,%1,%2
	jmp %%End
	%%lD:
	DrawChar D,%1,%2
	jmp %%End
	%%lE:
	DrawChar E,%1,%2
	jmp %%End
	%%lF:
	DrawChar F,%1,%2
	jmp %%End
	%%lG:
	DrawChar G,%1,%2
	jmp %%End
	%%lH:
	DrawChar H,%1,%2
	jmp %%End
	%%lI:
	DrawChar I,%1,%2
	jmp %%End
	%%lJ:
	DrawChar J,%1,%2
	jmp %%End
	%%lK:
	DrawChar K,%1,%2
	jmp %%End
	%%lL:
	DrawChar L,%1,%2
	jmp %%End
	%%lM:
	DrawChar M,%1,%2
	jmp %%End
	%%lN:
	DrawChar N,%1,%2
	jmp %%End
	%%lO:
	DrawChar O,%1,%2
	jmp %%End
	%%lP:
	DrawChar P,%1,%2
	jmp %%End
	%%lQ:
	DrawChar Q,%1,%2
	jmp %%End
	%%lR:
	DrawChar R,%1,%2
	jmp %%End
	%%lS:
	DrawChar S,%1,%2
	jmp %%End
	%%lT:
	DrawChar T,%1,%2
	jmp %%End
	%%lU:
	DrawChar U,%1,%2
	jmp %%End
	%%lV:
	DrawChar V,%1,%2
	jmp %%End
	%%lW:
	DrawChar W,%1,%2
	jmp %%End
	%%lX:
	DrawChar X,%1,%2
	jmp %%End
	%%lY:
	DrawChar Y,%1,%2
	jmp %%End
	%%lZ:
	DrawChar Z,%1,%2
	jmp %%End
	%%cero:
	DrawChar ZERO,%1,%2
	jmp %%End
	%%uno:
	DrawChar ONE,%1,%2
	jmp %%End
	%%dos:
	DrawChar TWO,%1,%2
	jmp %%End
	%%tres:
	DrawChar THREE,%1,%2
	jmp %%End
	%%cuatro:
	DrawChar FOUR,%1,%2
	jmp %%End
	%%cinco:
	DrawChar FIVE,%1,%2
	jmp %%End
	%%seis:
	DrawChar SIX,%1,%2
	jmp %%End
	%%siete:
	DrawChar SEVEN,%1,%2
	jmp %%End
	%%ocho:
	DrawChar EIGHT,%1,%2
	jmp %%End
	%%nueve:
	DrawChar NINE,%1,%2
	jmp %%End
	%%dospuntos:
	DrawChar COLON,%1,%2
	jmp %%End

	%%End:
	;pop ax

%endmacro

%macro pixelarea 5
 	push ax
  	push bx
  	push si
  	push di

  	mov si, %2
  	mov bx, si
  	add bx, %3
  	%%x:
  	cmp si, bx
  	je %%finx
  	mov di, %4
  	mov ax, di
  	add ax, %5
  	%%y:
  	cmp di, ax
  	je %%finy
  	pixel %1, si, di
  	inc di
  	jmp %%y
  	%%finy:
  	inc si
  	jmp %%x
  	%%finx:

  	pop si
  	pop di
 	pop bx
 	pop ax
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
%macro print_car 1
 	push ax
 	push cx

 	xor cx, cx;
 	mov cl, %1;

; 	pixlearea color,x,ancho,y,alto
 	pixelarea 0h, cx, 5, 140, 35 		;Contorno iz
 	add cl, 5
 	pixelarea 0h, cx, 5, 140, 35 		;contorno iz
 	pixelarea 7h, cx, 5, 145, 8 		;llanta superior iz
 	pixelarea 7h, cx, 5, 161, 8 		;llanta inferior iz
 	add cl, 5
 	pixelarea 01h, cx, 20,140, 35 	;carro
 	add cl, 20
 	pixelarea 0h, cx, 5, 140, 35 		;contorno derecho
 	pixelarea 7h, cx, 5, 145, 8 		;llanta superior der
 	pixelarea 7h, cx, 5, 161, 8 		;llanta inferior der
 	add cl, 5
 	pixelarea 0h, cx, 5, 140, 35 		;contorno derecho


 	pop cx
 	pop ax
%endmacro

%macro print_Obstacle 2
 	push ax
 	push cx

 	xor cx, cx;
 	xor dx,dx
 	mov cl, %1;
 	mov dl,	%2

; 	pixlearea color,x,ancho,y,alto
 	pixelarea 0, cx, 5, dx, 25 		;Contorno iz
 	;---outside star---
 	add dx,10
 	pixelarea 14, cx, 5,dx, 5 		;middel rectangel H
 	add cl,5
 	sub dx,10
 	pixelarea 0, cx, 5, dx, 25 			;Contorno iz
 	add dx,5
 	pixelarea 14, cx, 5,dx,15 			;left rectangle V
 	add dx,5
 	pixelarea 43, cx, 5,dx,5 			;middle rectangle H
 	add cl,5
 	sub dx, 10
 	pixelarea 0, cx, 5, dx, 25 			;Contorno medio
 	pixelarea 14, cx, 5, dx,25 			;middle rectangle V
 	add dx,5
 	pixelarea 43, cx,5,dx,15 			;middle rectangle V
 	add cl,5
 	sub dx,5
 	pixelarea 0, cx, 5, dx, 25 			;Contorno der
 	add dx,5
 	pixelarea 14, cx, 5, dx, 15 		;right rectangle V
 	add dx,5
 	pixelarea 43, cx, 5,dx,5 			;middle rectangle H
 	add cl,5
 	sub dx,10
 	pixelarea 0, cx, 5, dx, 25 			;Contorno der	
 	add dx,10
 	pixelarea 14, cx, 5, dx, 5 		;middel rectangel H
 	
 	
 	pop cx
 	pop ax
%endmacro

%macro print_Obstacle2 2
 	push ax
 	push cx

 	xor cx, cx;
 	xor dx,dx
 	mov cl, %1;
 	mov dl,	%2

; 	pixlearea color,x,ancho,y,alto
 	pixelarea 0, cx, 5, dx, 25 		;Contorno iz
 	;---outside star---
 	add dx,10
 	pixelarea 02, cx, 5,dx, 5 		;middel rectangel H
 	add cl,5
 	sub dx,10
 	pixelarea 0, cx, 5, dx, 25 			;Contorno iz
 	add dx,5
 	pixelarea 02, cx, 5,dx,15 			;left rectangle V
 	add dx,5
 	pixelarea 45, cx, 5,dx,5 			;middle rectangle H
 	add cl,5
 	sub dx, 10
 	pixelarea 0, cx, 5, dx, 25 			;Contorno medio
 	pixelarea 02, cx, 5, dx,25 			;middle rectangle V
 	add dx,5
 	pixelarea 45, cx,5,dx,15 			;middle rectangle V
 	add cl,5
 	sub dx,5
 	pixelarea 0, cx, 5, dx, 25 			;Contorno der
 	add dx,5
 	pixelarea 02, cx, 5, dx, 15 		;right rectangle V
 	add dx,5
 	pixelarea 45, cx, 5,dx,5 			;middle rectangle H
 	add cl,5
 	sub dx,10
 	pixelarea 0, cx, 5, dx, 25 			;Contorno der	
 	add dx,10
 	pixelarea 02, cx, 5, dx, 5 		;middel rectangel H
 	
 	
 	pop cx
 	pop ax
%endmacro

%macro sleep 1
 	push si
 	mov si, %1
 	%%b1:
 	dec si
 	jnz %%b1
 	pop si
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
	mov al,'$'
	mov [%1+4],al
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
	je Option1		;Log In (1)
	cmp al, 50
	je Option2 		;Sing up (2)
	cmp al, 51
	je Option3 		;Exit (3)
	cmp al, 52
	je Option4 		;Debuggin (4)
	jmp Main

AdminMenu:			;-------------------- ADMIN MENU ---------
print adminMenu
print newline
print optionLabel
	.readOption:
	readInputChar
	cmp al, 49
	je .Option1		;Top 10 Puntos (1)
	cmp al, 50
	je Main 		;Salir Y Menu Principal (2)
	jmp Main

	.Option1: 					;-----> CREATE TOP 10 FILE
	call ClearScreen
;	printAt column, line, string
	printAt 24 ,1 ,topTenLb
		;------------ CREATE FILE --------------
	;CreateFile reportPathFile
	;jc .errorCreateFile
	
	;------------- CLOSE FILE ---------------
	;closeFile ax
	;jc .errorCloseFile
	;print createFileMsg
		;------------- OPEN FILE ----------------
;	openFile ASCIZ_file_name
	openFile reportPathFile	
	jc .errorOpenFile
	print openFileMsg
	;------------- READ FILE ----------------
;	readFile Handle, BufferToStoreData
	readFile ax, fileReadBf
	jc .errorReadFile
	print readFileMsg
	;------------- CLOSE FILE ---------------
	closeFile bx
	jc .errorCloseFile

	print fileReadBf

	jmp AdminMenu

	.errorCreateFile:
	print errCreateFileMsg
	jmp Main

	.errorOpenFile:
	print errOpenMsg
	jmp Main

	.errorReadFile:
	print errReadFileMsg
	jmp Main

	.errorCloseFile:
	print errCloseFileMsg
	jmp Main

UserMenu:			;--------------- MENU DE USUARIOS --------------
print headerLabel
print userMenu
print newline
print optionLabel
	.readOption:
	readInputChar
	cmp al, 49
	je .Option1		;Cargar Archivo (1) also file with results created
	cmp al, 50
	je .Option2 	;Jugar (2)
	cmp al, 51
	je Main 		;Exit (3)
	cmp al,52
	je .Option3 	;Crear Archivo Configuraciones
	jmp Main

	.Option1:					;-------------------CARGAR ARCHIVO-----------
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
	print obst1Bf
	print newline
	;print pr2Bf
	;print newline
	;print lvl2Bf
	;print newline
	;print ptsSe1Bf
	;print newline
	;print ptsEs1Bf
	;print newline

	;-------- CREATE FILE (MY CONFIGURATIONS) -------------
;	CreateFile %1 ASCIZ filename
	;CreateFile myconfPathFile
	;jc .errCreateFile
	;print createFileMsg

	;------------- CLOSE (MY CONFIGURATIONS)---------------
	;closeFile ax 
	;jc .errorCloseFile
	

	;-------- OPEN FILE (MY CONFIGURATIONS) ------
	;openWriteFile myconfPathFile	
	;jc .errorOpenFile
	;print openFileMsg

	
	;-------- WRITE IN FILE (MY CONFIGURATIONS)------------------
	;writeInFile data,handle,numBytes
	
	;writeInFile level1Tg,ax,07h 
	;mov bl,3bh					;al = ; (Ascii 3bh)
	;mov [char], bl
	;writeInFile char,ax,01h
	;jc .errorWriteFile
	
	;------------- CLOSE FILE (SING UP)---------------
	;closeFile bx 
	;jc .errorCloseFile
	jmp UserMenu
;--------------------------------------------------------------------------------	
;--------------------------------------------USER MENU CREATE MY CONFIG FILE -----------------------
	.Option3:
		;----level 1----
		print newline
		print level1Tg 
		print newline
		print tmObsTg
		print obst1Bf
		print newline
		print tmPrTg
		print pr1Bf
		print newline
		print tmLvlTg
		print lvl1Bf
		print newline
		print ptsSlTg
		print ptsSe1Bf
		print newline
		print ptsEsTg
		print ptsEs1Bf
		print newline
		print colorTg
		print color1
		print newline

		readInputChar
		;----level 2 ---
		print newline
		print level2Tg 
		print newline
		print tmObsTg
		print obst2Bf

		print newline
		print tmPrTg
		print pr2Bf

		print newline
		print tmLvlTg
		print lvl2Bf

		print newline
		print ptsSlTg
		print ptsSe2Bf

		print newline
		print ptsEsTg
		print ptsEs2Bf

		print newline
		print colorTg
		print color2
		print newline		
		readInputChar
		;------------ level 3----------
		print newline
		print level3Tg 
		print newline
		print tmObsTg
		print obst3Bf

		print newline
		print tmPrTg
		print pr3Bf

		print newline
		print tmLvlTg
		print lvl3Bf

		print newline
		print ptsSlTg
		print ptsSe3Bf

		print newline
		print ptsEsTg
		print ptsEs3Bf

		print newline
		print colorTg
		print color3
		print newline	
		readInputChar	
		;------------ level 4----------
		print newline
		print level4Tg 
		print newline
		print tmObsTg
		print obst4Bf

		print newline
		print tmPrTg
		print pr4Bf

		print newline
		print tmLvlTg
		print lvl4Bf

		print newline
		print ptsSlTg
		print ptsSe4Bf

		print newline
		print ptsEsTg
		print ptsEs4Bf

		print newline
		print colorTg
		print color4
		print newline
		readInputChar
		;------------ level 5----------
		print newline
		print level5Tg 
		print newline
		print tmObsTg
		print obst5Bf

		print newline
		print tmPrTg
		print pr5Bf

		print newline
		print tmLvlTg
		print lvl5Bf

		print newline
		print ptsSlTg
		print ptsSe5Bf

		print newline
		print ptsEsTg
		print ptsEs5Bf

		print newline
		print colorTg
		print color5
		print newline				
	jmp UserMenu
;--------------------------------------------------------------------------------	

	jmp UserMenu


	.errorWriteFile:
	print errWriteFileMsg
	jmp UserMenu

	.errorOpenFile:
	print errOpenMsg
	jmp UserMenu

	.errorReadFile:
	print errReadFileMsg
	jmp Main

	.errorCloseFile:
	print errCloseFileMsg
	jmp Main

	.errorPathInput:
	print errPathMsg
	jmp Main

	.errorCreateFile:
	print errCreateFileMsg
	jmp Main

	jmp UserMenu
	




	.Option2:;-------------------------------------JUGAR --------------
	call ClearScreen
;	printAt column, line, string
	printAt 17 ,1 ,gameLb
	setVideoMode 13h

;------------------------------ DRAW GAME FRAME ---------------------
;	plotPixel %1 color, %2 x ,%3 y
	plotPixel 14,0,100

	plotPixel 14,0,0

	plotPixel 14,160,0

	plotPixel 14,319,0

	plotPixel 14,160,100

	plotPixel 14,319,100

	plotPixel 14,319,199

	plotPixel 14,160,199

	plotPixel 14,0,199


;	DrawArea x,width,y,height,color
;	DrawArea 80,20,50,30,02h
	;-------- DRAW CONTOUR --------------------------
	DrawArea 80,5,30,150,02h 			;LEFT 
	DrawArea 80,160,25,5,02h			;TOP
	DrawArea 235,5,30,150,02h			;RIGHT
	DrawArea 80,160,180,5,02h			;BOTTOM

;----------------------------- PRINT HEADER ---------------------------------

	;	printAt column, line, string
	printAt 2 ,0 ,currentUser

	DrawChar N,1,25
	DrawChar ONE,1,26

	DrawChar ZERO,1,35
	DrawChar ZERO,1,36
	DrawChar ZERO,1,37

;---------------- PRINT TIME OF SYSTEM -----------------


	 mov al, [dir]

 	;pintar inicial mente el carro
 	print_car al

 	;mov al,[dirXObs]
 	;mov ah,[dirYObs]
 	print_Obstacle [dirXObs],[dirYObs]
	
	mov al,[dirXObs]
	add al, 30
	mov [dirXObs],al
 	print_Obstacle [dirXObs],[dirYObs]
	
	mov al,[dirXObs]
	add al, 30
	mov [dirXObs],al
	mov al,[dirYObs]
	add al,30
	mov [dirYObs],al
 	print_Obstacle2 [dirXObs],[dirYObs]

	.while:
	mov ah,2ch
	int 21h
	mov [hour],ch
	mov [minute],cl
	mov [seconds],dh

	mov dh,0h
	mov dl,[hour]
	DecToAscii dx
;	printAt column, line, string
	printAt 27,0,numberBf
 	
	mov dh,0h
	mov dl,[minute]
	DecToAscii dx
;	printAt column, line, string
	printAt 30,0,numberBf

	mov dh,0h
	mov dl,[seconds]
	DecToAscii dx
;	printAt column, line, string
	printAt 33,0,numberBf


 	; leer el teclado
 	call keystatus
 	; manejar los obstaculos(no programado)
 	;call obstacles
 	; retarndo general
 	sleep 100h
 	jmp .while
 	jmp Main

 	
	.SetTextMode:
	setVideoMode 03h
	jmp Main
;this part of code tell when a key is pressed
keystatus:
 ;lee si se ha presionado una tecla o no
 mov ah, 01h
 int 16h
 je .return
 ;si se presiona una tecla lee que tecla se ha presionado
 ;las teclas de direccion son combinaciones de dos teclas por eso se lee dos 
 ;veces la tecla que se presiono
 .keypress:
 mov ah, 08h
 int 21h
 mov ah, 08h
 int 21h
 cmp al, 1bh
 je UserMenu.SetTextMode
 cmp al, 4bh
 je .movleft
 cmp al, 4dh
 je .movright
 ;segun la tecla que se presiono se elije una accion
 .movleft:
 mov al, [dir]
 sub al, 5h
 ;si sale de los limites del escenario no permite el movimiento
 cmp al, 85
 jb .return
 mov [dir], al
 print_car al
 jmp .return

 .movright:
 mov al, [dir]
 add al, 5h
 ;lo mismo si sale de los limites nel perro
 cmp al, 194
 ja .return
 mov [dir], al
 print_car al
 je .return

 mov al, 01h
 mov [dir], al
 .return:
 ret

exit:
 mov ah, 4ch
 int 21h

Option1: 				;LOG IN OPTION
	call ClearScreen
  ; printAt column, line, string
	printAt 24 ,1 ,logInLb
	print userlb
	xor si,si
	xor ax,ax

	;------------------ GET INPUT USER  --------------------
	.GetUserInput:
	readInputChar			;read a new char from keyboard
	cmp al, 0dh				; al = CR (carriage return) if key enter
	je .EndUserInput
	mov [usersBf+si],al
	mov [currentUser+si],al
	inc si
	jmp .GetUserInput
	.EndUserInput:
	mov al,'$'
	mov cx,si
	mov [counter],cl
	mov [usersBf+si],al
	mov [currentUser+si],al
	print usersBf
	print newline
	;------------- OPEN FILE ----------------
;	openFile ASCIZ_file_name
	openFile usersPathFile	
	jc .errorOpenFile
	
	;------------- READ FILE ----------------
;	readFile Handle, BufferToStoreData
	readFile ax, fileReadBf
	jc .errorReadFile
	;------------- CLOSE FILE ---------------
	closeFile bx
	jc .errorCloseFile
	;jmp Main

	;print fileReadBf

	;------------------ SEARCH FOR USER --------------------
	xor si,si					;clean si
	xor di,di					;clean di
	xor bp,bp 					;clean bp
	xor ax,ax					;clean ax

	.searchUser:
	mov al, [usersBf+di]		;input user name
	mov ah, [fileReadBf+si]		;current data 


	cmp ah, '$'					;ah = $ (Ascii 24h) end of users file
	je .userNotFound
	cmp ah, 2ch					;ah = , (Ascii 2ch) 
	je .userFound				;if , it's been reach then user matches
	cmp al,ah					;if inputUser match current user in buffer 
	jne .userNotMatch			
	inc si						;then increment si
	inc di						;also increment di
	jmp .searchUser				;return and keep searching...

	.userNotFound:
	print errUserMsg
	jmp Main

	.userNotMatch:				;if failed at matching user with current in buffer
	;print errUserMatch
	xor di,di					;clean userinput index
	mov ah, [fileReadBf+si]		;move forward till find a comma
	
	push ax
	push dx

	mov dl,ah		;refers to the first parameter to the macro call

	mov ah, 06h		;09h function write string    
    ;int 21h			;call the interruption
    pop dx
    pop ax
    
	cmp ah,2ch				;ah = , (Ascii 3bh)
	je .NextUser			;if comma jump NextUser
	inc si
	jmp .userNotMatch
	
	.NextUser:				
	add si,08h				;increment si till next User in database
	jmp .searchUser

	.userFound:
	;------------------------------ CHECK IF ADMIN CREDENTIALS -------------------------
	xor di,di
	mov al, [usersBf+di]		;input user name
	cmp al,'a'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'d'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'m'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'i'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'n'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'N'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'P'
	jne .NotAdmin
	inc di
	mov al, [usersBf+di]		;input user name
	cmp al,'$'
	jne .NotAdmin
	mov al,01h
	mov [isAdmin],al
	jmp .EndUserFound

	.NotAdmin:
	mov al,00h
	mov [isAdmin],al

	.EndUserFound:
	inc si					;last char found it in [fileReadBf] was a comma inc to passw first number
	print userFoundMsg
	print newline

	;------------------ GET INPUT PASSWORD  --------------------
	;mov di,si				;save current fileReadBf index
	;mov bp,si
	.ReadPassword:
	push si
	mov di,si
	print passlb
	xor si,si
	xor ax,ax

	.GetPasswordInput:
	cmp si,04h
	je .EndPasswordInput
	readInputChar			;read a new char from keyboard
	cmp al, 0dh				; al = CR (carriage return) if key enter
	je .ErrPassword
	mov [usersBf+si],al
	inc si
	jmp .GetPasswordInput

	.ErrPassword:
	print errPasswMsg
	print newline
	pop si
	jmp .ReadPassword

	.EndPasswordInput:
	mov al,'$'
	mov [usersBf+si],al
	print newline
	print usersBf
	print newline
	;jmp Main

	;------------------ SEARCH FOR PASSWORD --------------------
	mov si,di					;restore fileReadBf index
	xor di,di					;clean di
	xor ax,ax					;clean ax

	.searchPassword:
	mov al, [usersBf+di]		;input user password
	mov ah, [fileReadBf+si]		;current data 

	cmp ah, 3bh					;ah = ; (Ascii 2ch) 
	je .passwFound				;if ; it's been reach then password matches
	cmp al,ah					;if inputPassword match current password in buffer 
	jne .passwNotMatch			
	inc si						;then increment si
	inc di						;also increment di
	jmp .searchPassword			;return and keep searching...

	.passwNotMatch:				;if failed at matching passw with current in buffer
	print errPasswMsg
	print newline
	pop si
	jmp .ReadPassword

	.passwFound:
	print userFoundMsg
	print newline
	mov al,[isAdmin]
	cmp al,01h
	je .IsAdmin
	print myuserlb
	print newline
	jmp UserMenu 			;---------> USER IS CORRECT CHANGE TO USER MENU

	.IsAdmin:
	print adminlb
	print newline
	jmp AdminMenu

	.errorOpenFile:
	print errOpenMsg
	jmp Main

	.errorReadFile:
	print errReadFileMsg
	jmp Main

	.errorCloseFile:
	print errCloseFileMsg
	jmp Main

Option2:	;---------- SING UP OPTION ----------
	call ClearScreen
	printAt 24 ,1 ,singUpLb
	print userSingLb
	xor si,si
	xor ax,ax
	xor cx,cx		;user name characters counter
	;------------------ GET INPUT USER (SING UP) --------------------
	.GetUserInput:
	cmp si,07h
	je .EndUserInput
	readInputChar			;read a new char from keyboard
	cmp al, 0dh				; al = CR (carriage return) if key enter
	je .EndUserInput
	mov [usersBf+si],al
	inc si
	jmp .GetUserInput
	.EndUserInput:
	mov cx,si
	mov [counter],cl
	mov al,'$'
	mov [usersBf+si],al
	
	print newline
	print usersBf
	print newline

	;push cx			;save counter
	;------------- OPEN FILE (SING UP) ----------------
;	openFile ASCIZ_file_name
	openFile usersPathFile	
	jc .errorOpenFile
	
	;------------- READ FILE (SING UP)----------------
;	readFile Handle, BufferToStoreData
	readFile ax, fileReadBf
	jc .errorReadFile
	;------------- CLOSE FILE (SING UP)---------------
	closeFile bx
	jc .errorCloseFile
	;jmp Main

	print fileReadBf
	;pop cx			;restore counter
	;------------------ SEARCH FOR USER (SING UP)--------------------
	xor si,si					;clean si
	xor di,di					;clean di
	xor bp,bp 					;clean bp
	xor ax,ax					;clean ax

	.searchUser:
	mov al, [usersBf+di]		;input user name
	mov ah, [fileReadBf+si]		;current data 


	cmp ah, '$'					;ah = $ (Ascii 24h) end of users file
	je .userNotFound
	cmp ah, 2ch					;ah = , (Ascii 2ch) 
	je .userFound				;if , it's been reach then user matches
	cmp al,ah					;if inputUser match current user in buffer 
	jne .userNotMatch			
	inc si						;then increment si
	inc di						;also increment di
	jmp .searchUser				;return and keep searching...

	.userNotFound:
	print errUserMsg



;---------------------------------------------OPEN REPORT FILE ------------------------------------------------------
;-------- OPEN FILE (REPORT FILE) ------
	openWriteFile reportPathFile	
	jc .errorOpenFile
	print openFileMsg

	;push cx						;save counter
	;------- READ FILE (REPORT FILE) -------
;	readFile Handle, BufferToStoreData
	readFile ax, fileReadBf
	jc .errorReadFile


	;-------- SET CURRENT FILE POSITION (FOR REPOR FILE )----------
	dec ax
	mov dx,ax
	mov ah, 42h
	mov al,00h
	mov cx,0h
	;mov dx,0ah
	int 21h
	;pop cx						;restore counter
	
	;-------- WRITE IN FILE (REPORT FILE)------------------
	;writeInFile usersBf,bx,0ah
	mov cl,[counter]
	writeInFile usersBf,bx,cx

	mov al,2ch						;al = , (Ascii 2ch)
	mov [char], al
	writeInFile char,bx,01h

	mov al,30h						;al = 0 (Ascii 30h)
	mov [char], al
	writeInFile char,bx,01h

	mov al,2ch						;al = , (Ascii 2ch)
	mov [char], al
	writeInFile char,bx,01h

	mov al,30h						;al = 0 (Ascii 30h)
	mov [char], al
	writeInFile char,bx,01h

	mov al,2ch						;al = , (Ascii 2ch)
	mov [char], al
	writeInFile char,bx,01h

	mov al,30h						;al = 0 (Ascii 30h)
	mov [char], al
	writeInFile char,bx,01h
	mov al,3bh						;al = ; (Ascii 3bh)
	mov [char], al
	writeInFile char,bx,01h
	
	mov al,0ah						;al = linefeed (Ascii 0ah)
	mov [char], al
	writeInFile char,bx,01h
	
	mov al,0dh						;al = carriage return (Ascii 0dh)
	mov [char], al
	writeInFile char,bx,01h

	mov al,24h						;al = $ (24h)
	mov [char], al
	writeInFile char,bx,01h
	jc .errorWriteFile
	
	;------------- CLOSE FILE (SING UP-PASSWORD)---------------
	closeFile bx 
	jc .errorCloseFile
;---------------------------------------------------------------------------------------------------------------------


	;-------- OPEN FILE (SIGN UP ADD IN DATABASE) ------
	openWriteFile usersPathFile	
	jc .errorOpenFile
	print openFileMsg

	;push cx						;save counter
	;------- READ FILE (SIGN UP ADD IN DATABASE) -------
;	readFile Handle, BufferToStoreData
	readFile ax, fileReadBf
	jc .errorReadFile


	;-------- SET CURRENT FILE POSITION (SIGN UP ADD IN DATABASE)----------
	dec ax
	mov dx,ax
	mov ah, 42h
	mov al,00h
	mov cx,0h
	;mov dx,0ah
	int 21h
	;pop cx						;restore counter
	
	;-------- WRITE IN FILE (SIGN UP ADD IN DATABASE)------------------
	;writeInFile data,handle,numBytes
	mov cl,[counter]
	writeInFile usersBf,bx,cx 	;username
	mov al,2ch					;al = , (Ascii 2ch)
	mov [char], al
	writeInFile char,bx,01h
	jc .errorWriteFile
	
	;------------- CLOSE FILE (SING UP)---------------
	closeFile bx 
	jc .errorCloseFile
	jmp .ReadPassword
	;jmp Main



	.userNotMatch:				;if failed at matching user with current in buffer
	;print errUserMatch
	xor di,di					;clean userinput index
	mov ah, [fileReadBf+si]		;move forward till find a comma
	
	push ax
	push dx

	mov dl,ah		;refers to the first parameter to the macro call

	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption
    pop dx
    pop ax
    
	cmp ah,2ch				;ah = , (Ascii 3bh)
	je .NextUser			;if comma jump NextUser
	inc si
	jmp .userNotMatch
	
	.NextUser:				
	add si,08h				;increment si till next User in database
	jmp .searchUser

	.userFound:
	inc si					;last char found it was a comma inc to passw first number
	print UserExistMsg
	print newline
	jmp Main
	;------------------ GET INPUT PASSWORD (SIGN UP) --------------------
	.ReadPassword:
	print passwSingLb
	xor si,si
	xor ax,ax

	.GetPasswordInput:
	cmp si,04h
	je .EndPasswordInput
	readInputChar			;read a new char from keyboard
	cmp al, 0dh				; al = CR (carriage return) if key enter
	je .ErrPassWord
	mov [usersBf+si],al
	inc si
	jmp .GetPasswordInput

	.ErrPassWord:
	print errPasswMsg
	print newline
	jmp .ReadPassword

	.EndPasswordInput:
	mov cx,si
	mov [counter],cl
	mov al,'$'
	mov [usersBf+si],al
	;print newline
	;print usersBf
	print newline


	;-------- OPEN FILE (SIGN UP ADD IN DATABASE-PASSWORD) ------
	openWriteFile usersPathFile	
	jc .errorOpenFile
	print openFileMsg

	;push cx						;save counter
	;------- READ FILE (SIGN UP ADD IN DATABASE-PASSWORD) -------
;	readFile Handle, BufferToStoreData
	readFile ax, fileReadBf
	jc .errorReadFile


	;-------- SET CURRENT FILE POSITION (SIGN UP ADD IN DATABASE-PASSWORD)----------
	;dec ax
	mov dx,ax
	mov ah, 42h
	mov al,00h
	mov cx,0h
	;mov dx,0ah
	int 21h
	;pop cx						;restore counter
	
	;-------- WRITE IN FILE (SIGN UP ADD IN DATABASE-PASSWORD)------------------
	;writeInFile usersBf,bx,0ah
	mov cl,[counter]
	writeInFile usersBf,bx,cx
	mov al,3bh						;al = ; (Ascii 3bh)
	mov [char], al
	writeInFile char,bx,01h
	
	mov al,0ah						;al = linefeed (Ascii 0ah)
	mov [char], al
	writeInFile char,bx,01h
	
	mov al,0dh						;al = carriage return (Ascii 0dh)
	mov [char], al
	writeInFile char,bx,01h

	mov al,24h						;al = $ (24h)
	mov [char], al
	writeInFile char,bx,01h
	jc .errorWriteFile
	
	;------------- CLOSE FILE (SING UP-PASSWORD)---------------
	closeFile bx 
	jc .errorCloseFile

	jmp Main



	.errorOpenFile:
	print errOpenMsg
	jmp Main

	.errorWriteFile:
	print errWriteFileMsg
	jmp Main

	.errorReadFile:
	print errReadFileMsg
	jmp Main

	.errorCloseFile:
	print errCloseFileMsg
	jmp Main
;-------------------OPTION 2 -- END SIGN UP -----------------------------

Option3:
	jmp exit
Option4:

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

vgaStartAddr dw 0A000h 		;start positon of vga memory
							;0a0000h - bffffh
dir db 90,'$'

dirXObs db 100,'$'
dirYObs db 30,'$'

headerLabel db 13,13,10
        db 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',13,10
        db 'FACULTAD DE INGENIERIA ',13,10
        db 'CIENCIAS Y SISTEMAS',13,10
        db 'ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1 B',13,10
        db 'VACACIONES JUNIO 2019',13,10
        db 'NOMBRE: LESTER EFRAIN AJUCUM SANTOS',13,10
        db 'CARNET: 201504510',13,10
        db 'PROYECTO ',13,10,'$'

mainMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_________ MENU __________|', 13, 10
        db '|   1. Ingresar           |', 13, 10
        db '|   2. Registrar          |', 13, 10
        db '|   3. Salir              |', 13, 10
        db '|   4. Debugger           |', 13, 10
        db '|_________________________|',13,10,'$'

userMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_______ CRASH CAR _______|', 13, 10
        db '|   1. Cargar Archivo     |', 13, 10
        db '|   2. Jugar	          |', 13, 10
        db '|   3. Salir              |', 13, 10
        db '|   4. Mostrar Configura  |', 13, 10
        db '|_________________________|',13,10,'$'

adminMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_______ CRASH CAR _______|', 13, 10
        db '|   1. Top 10 Puntos      |', 13, 10
        db '|   2. Menu Principal	  |', 13, 10
        db '|_________________________|',13,10,'$'        


logInLb	db '_________ LOG IN __________',10,'$'
singUpLb	db '_________ SIGN UP __________',10,'$'
topTenLb	db '_________ TOP TEN __________',10,'$'
loadFileLb db '_________ LOAD FILE __________',10,'$'
gameLb db '____________ G A M E ____________',10,'$'


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
myconfPathFile db 'myconf.txt',0
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

level1Tg	db 'NIVEL1:','$' 				;Nivel label (7 bytes)
level2Tg	db 'NIVEL2:','$' 				;Nivel label (7 bytes)
level3Tg	db 'NIVEL3:','$' 				;Nivel label (7 bytes)
level4Tg	db 'NIVEL4:','$' 				;Nivel label (7 bytes)
level5Tg	db 'NIVEL5:','$' 				;Nivel label (7 bytes)
tmObsTg	db 'tiempo_Obstaculos: ','$'		;tiempo obstaculos (18 bytes)
tmPrTg	db 'tiempo_Premios: ','$' 		;tiempo premios  (15 bytes)
tmLvlTg	db 'tiempo_Nivel: ','$' 			;tiempo nivel (13 bytes)
ptsSlTg	db 'puntos_Seleccion: ','$'  	;puntos seleccion  (17 bytes)
ptsEsTg	db 'puntos_Esquivar: ','$' 		;puntos esquivar (16 bytes)
colorTg	db 'color: ','$' 				;color  (6 bytes)

bytesTr db 0,0,'$'

A db 0,0,1,0
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1
  db 0,1,0,1,'$'

B db 0,1,1,0
  db 0,1,0,1
  db 0,1,1,0
  db 0,1,0,1
  db 0,1,1,0,'$'

C db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,0
  db 0,1,0,1
  db 0,0,1,0,'$'

D db 0,1,1,0
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,0,'$'

E db 0,1,1,1
  db 0,1,0,0
  db 0,1,1,0
  db 0,1,0,0
  db 0,1,1,1,'$'

F db 0,1,1,1
  db 0,1,0,0
  db 0,1,1,1
  db 0,1,0,0
  db 0,1,0,0,'$'

G db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,0
  db 0,1,1,1
  db 0,1,1,0,'$'

H db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1
  db 0,1,0,1,'$'

I db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0,'$'

J db 0,0,0,1
  db 0,0,0,1
  db 0,0,0,1
  db 0,1,0,1
  db 0,0,1,0,'$'

K db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,0
  db 0,1,0,1
  db 0,1,0,1,'$'

L db 0,1,0,0
  db 0,1,0,0
  db 0,1,0,0
  db 0,1,0,0
  db 0,1,1,1,'$'

M db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1
  db 0,1,0,1,'$'

N db 1,0,0,1
  db 1,1,0,1
  db 1,1,0,1
  db 1,0,1,1
  db 1,0,0,1,'$'

O db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0,'$'

P db 0,1,1,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,0
  db 0,1,0,0,'$'

Q db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,1,'$'

R db 0,1,1,1
  db 0,1,0,1
  db 0,1,1,0
  db 0,1,0,1
  db 0,1,0,1,'$'

S db 0,0,1,0
  db 0,1,0,1
  db 0,0,1,0
  db 0,1,0,1
  db 0,0,1,0,'$'

T db 0,1,1,1
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0,'$'

U db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1,'$'

V db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0,'$'

W db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1,'$'

X db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,1,'$'

Y db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0,'$'

Z db 0,1,1,1
  db 0,0,0,1
  db 0,0,1,0
  db 0,1,0,0
  db 0,1,1,1,'$'

ONE db 0,0,1,0
	db 0,1,1,0
  	db 0,0,1,0
  	db 0,0,1,0
  	db 0,0,1,0,'$'

TWO db 0,1,1,1
  	db 0,0,0,1
  	db 0,1,1,1
  	db 0,1,0,0
  	db 0,1,1,1,'$'

THREE 	db 0,1,1,0
  		db 0,0,0,1
  		db 0,0,1,0
  		db 0,0,0,1
  		db 0,1,1,0,'$'

FOUR	db 0,1,0,1
  		db 0,1,0,1
  		db 0,1,1,1
  		db 0,0,0,1
  		db 0,0,0,1,'$'

FIVE	db 0,1,1,1
  		db 0,1,0,0
  		db 0,1,1,1
  		db 0,0,0,1
  		db 0,1,1,1,'$'

SIX		db 0,0,1,1
  		db 0,1,0,0
  		db 0,1,1,1
  		db 0,1,0,1
  		db 0,0,1,0,'$'

SEVEN	db 0,1,1,0
  		db 0,0,1,0
  		db 0,1,1,1
  		db 0,0,1,0
  		db 0,0,1,0,'$'

EIGHT db 0,0,1,0
  	  db 0,1,0,1
  	  db 0,0,1,0
  	  db 0,1,0,1
  	  db 0,0,1,0,'$'

NINE db 0,1,1,1
     db 0,1,0,1
  	 db 0,1,1,1
  	 db 0,0,0,1
  	 db 0,0,0,1,'$'

ZERO db 0,1,1,1
  	 db 0,1,0,1
  	 db 0,1,0,1
  	 db 0,1,0,1
  	 db 0,1,1,1,'$'

COLON 	db 0,0,1,0
  		db 0,0,1,0
  		db 0,0,0,0
  		db 0,0,1,0
  		db 0,0,1,0,'$' 
;************************** END SECTION DATA***********************************
;************************** END SECTION DATA***********************************


;==========================  SECTION .BSS  =================================================|
;uninitialized-data sections                                                                            |
segment .bss
;************************** END SECTION BSS **********************************************
