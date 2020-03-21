;UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
;FACULTAD DE INGENIERIA
;ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1
;PRACTICA 6
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
	push bx
	;xor dx,dx
	mov bx,%1
	mov dx, bx		;refers to the first parameter to the macro call
	;xor ax,ax
	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption
    pop bx
    pop dx
    pop ax
%endmacro

%macro readInputChar 0
    mov ah, 01h    ;Return AL with the ASCII of the read char
    int 21h        ;call the interruption
%endmacro

%macro fprint 3
;macro to write in the file
;parameters: %1 data to write, %2 handle, %3 num bytes to write
	mov bh,[%2]		;copy the high order(8 bits more significant)of handle
	mov bl,[%2+1]	;copy the low  order(8 bits less significant)of handle
	mov cx,%3		;copy num of bytes to write
	mov dx,%1 		;copy the data to write
	mov ah,40h		;request write to file interruption
	int 21h 		;call interruption
%endmacro
;================================VIDEO MODE PROCEDURES =================================================
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
	mov bx, 140h				;140h = 320 decimal
	mul bx 						;ax*di = y*320
								;dx ax = result
	add ax,%2					;ax = %2 + y*320
	mov di,ax 					

	mov es,word[vgaStartAddr]	;es ->extra segment =0a000h
	mov ax,%1					;color of the pixel
	mov [es:di],ax

	pop bx
	pop di
	pop ax
%endmacro

%macro DrawArea 5 			;DRAW AN AREA IN VIDEO MODE 13H
;%1 , %2 ,   %3  ,  %4    ,  %5
; x ,  y , width , height , color
;si , di ,				  ,  %5
	push cx
	push ax
	push si
	push di
	;printChar %1
	;printChar %2
	;printChar %4
	xor di,di
	mov di,%2			;y coordinate
	mov cx,di			;di = Yindex starting at = y
	add cx,%4			;bx = Yend = Ystart + height
	;printChar %1		;WARNING. NOTE 1 notebook: if a register is sent as parameter
						;and then the same register is use whitin the macro
						;the value of the parameter change 
	;mov [Height],cl
	;printChar [Height]
	;printChar 32
	;printChar di
	;printChar cx
	%%Height:			;Y coordinate
	;printChar di
	;printChar cx
	cmp di,cx 			;di = height ? -> Yindex = Yend ?
	je %%EndHeight	
	;printChar %1
	mov si,%1			;x coordinate
	mov ax,si			;si = Xindex starting at = x
	push cx
	mov cl,[%3]
	add ax,cx			;ax = Xend = Xstart + width
	pop cx
	%%Width:			;X coordinate
	cmp si,ax			;si = width ? -> Xindex = Xend ?
	je %%EndWidth

	plotPixel %5,si,di
	inc si 				;x = x + 1
	jmp %%Width

	%%EndWidth:
	inc di				;y = y + 1
	jmp %%Height
	%%EndHeight:

	pop di
	pop si
	pop ax
	pop cx

%endmacro

%macro PlotChar 3
; row, column, Hexanum Ascii Char 
; %1 ,	%2   ,	%3 
	push ax
	push bx
	push cx

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
	drawChar %1,%2,A
	jmp %%End
	%%lB:
	drawChar %1,%2,B
	jmp %%End
	%%lC:
	drawChar %1,%2,C
	jmp %%End
	%%lD:
	drawChar %1,%2,D
	jmp %%End
	%%lE:
	drawChar %1,%2,E
	jmp %%End
	%%lF:
	drawChar %1,%2,F
	jmp %%End
	%%lG:
	drawChar %1,%2,G
	jmp %%End
	%%lH:
	drawChar %1,%2,H
	jmp %%End
	%%lI:
	drawChar %1,%2,I
	jmp %%End
	%%lJ:
	drawChar %1,%2,J
	jmp %%End
	%%lK:
	drawChar %1,%2,K
	jmp %%End
	%%lL:
	drawChar %1,%2,L
	jmp %%End
	%%lM:
	drawChar %1,%2,M
	jmp %%End
	%%lN:
	drawChar %1,%2,N
	jmp %%End
	%%lO:
	drawChar %1,%2,O
	jmp %%End
	%%lP:
	drawChar %1,%2,P
	jmp %%End
	%%lQ:
	drawChar %1,%2,Q
	jmp %%End
	%%lR:
	drawChar %1,%2,R
	jmp %%End
	%%lS:
	drawChar %1,%2,S
	jmp %%End
	%%lT:
	drawChar %1,%2,T
	jmp %%End
	%%lU:
	drawChar %1,%2,U
	jmp %%End
	%%lV:
	drawChar %1,%2,V
	jmp %%End
	%%lW:
	drawChar %1,%2,W
	jmp %%End
	%%lX:
	drawChar %1,%2,X
	jmp %%End
	%%lY:
	drawChar %1,%2,Y
	jmp %%End
	%%lZ:
	drawChar %1,%2,Z
	jmp %%End
	%%cero:
	drawChar %1,%2,ZERO
	jmp %%End
	%%uno:
	drawChar %1,%2,ONE
	jmp %%End
	%%dos:
	drawChar %1,%2,TWO
	jmp %%End
	%%tres:
	drawChar %1,%2,THREE
	jmp %%End
	%%cuatro:
	drawChar %1,%2,FOUR
	jmp %%End
	%%cinco:
	drawChar %1,%2,FIVE
	jmp %%End
	%%seis:
	drawChar %1,%2,SIX
	jmp %%End
	%%siete:
	drawChar %1,%2,SEVEN
	jmp %%End
	%%ocho:
	drawChar %1,%2,EIGHT
	jmp %%End
	%%nueve:
	drawChar %1,%2,NINE
	jmp %%End
	%%dospuntos:
	drawChar %1,%2,COLON
	jmp %%End

	%%End:
	pop cx
	pop bx
	pop ax

%endmacro
%macro drawChar 3 				;DRAW A CHAR IN VIDEO MODE 13H
; row, column, bitArray
; %1 ,	%2   ,	%3 

; x , y   , end x , end y
;si , di  , cx= 4  , bx = 5
	push cx
	push ax
	push bx
	push si
	push di

	mov bx,0h			;y coordinate = 0
	mov di,bx			;di = Yindex starting at = y
	add bx,05h			;bx = Yend = Ystart +  5(height)

	%%Height:			;Y coordinate
	cmp di,bx 			;di = height ? -> Yindex = Yend ?
	je %%EndHeight		
	mov cx,0h			;x coordinate = 0
	mov si,cx			;si = Xindex starting at = x
	add cx,04h			;ax = Xend = Xstart + (4)width
	%%Width:			;X coordinate
	cmp si,cx			;si = width ? -> Xindex = Xend ?
	je %%EndWidth
	
	;LEXICAL MAP for matrix 5*4 -> vector 20 positions
	;lexical map..
	;P(x,y) = x + y(4)
	mov ax,di					;ax = di = Y (coordinate) 
	push di 					;save y index
	mov di, 04h				    ;04h = 4 decimal
	mul di 						;ax*di = y*4
								;dx ax = result
	add ax,si					;ax = si + y*4
	mov di,ax 					;di = ax
	mov ax,[%3+di]				;ax = bitArray[di]
	pop di						;di = restore yindex
	cmp al,0h					;bitArray[di] != 1 
	je %%PaintBlack
	push di
	push si
	push cx
	push bx

	mov al,%1 				;row
	mov dl,5
	mul dl

	add di, ax

	mov al,[%2]				;col
	mov dl,4
	mul dl

	add si,ax

	plotPixel 0fh,si,di 		;plotPixel color,x,y
	pop bx
	pop cx
	pop si
	pop di
	jmp %%Next
	;je %%Next 					;if bitArray[di] = 0 don't paint

	;push di						;save y index
	;push si 					;save x index
	;add di,%1*5					;di = yindex + row*5
	;push ax
	;push bx
	;mov ax,[%2]
	;mov bl,4
	;mul bl

	;add si,ax					;si = xindex + column*4
	;pop bx
	;pop ax
	;plotPixel 0fh,si,di 		;plotPixel color,x,y
	;%1 color, %2 x ,%3 y
	;pop si 						;si = restore yindex
	;pop di						;di = restore xindex

	%%PaintBlack:
	push di
	push si
	push cx
	push bx

	mov al,%1 				;row
	mov dl,5
	mul dl

	add di, ax

	mov al,[%2]				;col
	mov dl,4
	mul dl

	add si,ax

	plotPixel 00h,si,di 		;plotPixel color,x,y
	pop bx
	pop cx
	pop si
	pop di


	%%Next:
	inc si 						;x = x + 1
	jmp %%Width

	%%EndWidth:
	inc di						;y = y + 1
	jmp %%Height
	%%EndHeight:

	pop di
	pop si
	pop bx
	pop ax
	pop cx

%endmacro
%macro printAt 3 					;PRINT A CHAR AT ROW,COL IN TEXT MODE 03H
; cursor x, cursor y , string
; column  , line     , data to write
	push ax
  	push bx
  	push dx

  	
  	;mov ah,01h
  	;int 10h

    mov bh,00h 	;Video page
    mov ch,01h
  	mov cl,01h
 	mov dh,%2 	;set cursor line
 	mov dl,%1	;set cursor column
 	mov ah,03h 
 	int 10h

 	mov dx, %3	;offset addres of string
 	mov ah, 09h	;request write string
 	int 21h		;call interruption

 	pop dx
 	pop bx
 	pop ax
%endmacro

%macro DrawBarGraph 2
; arrayNumbers , sizeOfArray
	push ax
	push bx
	push dx
	push di

	xor ah,ah
	mov al,[%2]
	xor di,di
	mov di,00h
	mov bx,10

	push ax
	mov ax,600
	mov cl,[%2]
	div cl
	sub al,4
	mov [Width],al
	pop ax

	;printChar [%2]
	
	%%for:
	;cmp di,[%2]
	;printChar di
	;printChar ax
	cmp di,ax
	je %%EndFor
	
	mov dl,[%1+di+1]
	;%1 , %2 ,   %3  ,  %4    ,  %5
	; x ,  y , width , height , color
	mov cl,180
	sub cl,dl
	sub cl,80
	mov dl,cl
	DrawArea bx,11,Width,dx,00h 	;paint black the complement of
									;height of the bar
	push bx
	push ax
	;push dx
	mov ax,bx
	mov bx,80
	mul bx
	mov dx,00h
	mov bx,320
	div bx
	mov [charCol],al
	;mov dl,al

	;printChar dx
	;print blankSpace
	mov bh,[auxArray+di]
	mov bl,[auxArray+di+1]
	DecToAscii bx,numCharArray
	;print numCharArray
	PlotChar 39,charCol,[numCharArray]
	mov al,[charCol]
	inc al
	mov [charCol],al
	PlotChar 39,charCol,[numCharArray+1]
	pop ax
	pop bx

	;mov bh,[auxArray]
	;mov bl,[auxArray+1]
	;DecToAscii bx,numCharArray
	;print numCharArray
	;printChar [numCharArray]
	;printChar [numCharArray+1]
	
	mov dl,[%1+di+1]
	mov cl,180
	sub cl,dl
	add cl,11
	sub cl,80
	push ax
	mov al,cl

	cmp dx,21
	jb %%Red
	cmp dx,41
	jb %%Blue
	cmp dx,61
	jb %%Yellow
	cmp dx,81
	jb %%Green
	cmp dx,100
	jb %%White
	;DrawArea bx,ax,4,dx,02h 	
	;bx = x start position,ax = y start position,dx = height of the bar,color	
	%%Red:
	add dl,80
	DrawArea bx,ax,Width,dx,04h 	
	;bx = x start position,ax = y start position,dx = height of the bar,color								
	jmp %%EndBar

	%%Blue:
	add dl,80
	DrawArea bx,ax,Width,dx,01h 	
	;bx = x start position,ax = y start position,dx = height of the bar,color								
	jmp %%EndBar

	%%Yellow:
	add dl,80
	DrawArea bx,ax,Width,dx,0eh 	
	;bx = x start position,ax = y start position,dx = height of the bar,color								
	jmp %%EndBar

	%%Green:
	add dl,80
	DrawArea bx,ax,Width,dx,02h 	
	;bx = x start position,ax = y start position,dx = height of the bar,color								
	jmp %%EndBar

	%%White:
	add dl,80
	DrawArea bx,ax,Width,dx,0fh 	
	;bx = x start position,ax = y start position,dx = height of the bar,color								
	jmp %%EndBar

	%%EndBar:
	pop ax

	inc di
	inc di

	;add bx,12
	push ax
	mov al,[Width]
	add bx,ax
	add bx,4
	pop ax
	jmp %%for

	%%EndFor:


	pop di
	pop dx
	pop bx
	pop ax

%endmacro

%macro DrawLabels 0
	
%endmacro
;================================END VIDEO MODE PROCEDURES =============================================
;== DELAY 
%macro Delay 1
;%1 delay Time
	push si
	push di

	mov si,%1
	%%lapse1:
	dec si
	jz %%EndDelay
	mov di,%1
	%%lapse2:
	dec di
	jnz %%lapse2
	jmp %%lapse1
	%%EndDelay:
	pop di
	pop si
%endmacro
;============================== REPORT PROCEDURE ========================================================
%macro CreateReport 0
	;Write in the Created File: 

	fprint openRepTg,fileHandle,08h
	fprint opHeadTg,fileHandle,0dh
	;Universidad De San Carlos..
	fprint opUTg,fileHandle,0dh
	fprint unLb,fileHandle,26h
	fprint clUTg,fileHandle,0fh
	;Facultad De Ingenieria...
	fprint opFacTg,fileHandle,0ah
	fprint facLb,fileHandle,16h
	fprint clFacTg,fileHandle,0ch
	;Ciencias y Sistemas
	fprint opSchTg,fileHandle,09h
	fprint schLb,fileHandle,13h
	fprint clSchTg,fileHandle,0bh
	;<Curso>
	fprint opCrsTg,fileHandle,08h
	;Arquitectura De Computadores...
	fprint opNmTg,fileHandle,08h
	fprint crLb,fileHandle,2eh
	fprint clNmTg,fileHandle,0ah
	;Seccion...
	fprint opSnTg,fileHandle,09h
	fprint snLb,fileHandle,09h
	fprint clSnTg,fileHandle,0bh

	fprint clCrsTg,fileHandle,09h
	;</Curso>
	;<Ciclo>
	fprint opCiTg,fileHandle,07h
	fprint ciLb,fileHandle,14h
	fprint clCiTg,fileHandle,09h
	;</Ciclo>
	;fecha......
	;<Fecha>
	fprint opDtTg,fileHandle,08h
	;Dia.....
	fprint opDdTg,fileHandle,05h
	fprint clDdTg,fileHandle,07h
	;Mes.......
	fprint opMmTg,fileHandle,05h
	fprint clMmTg,fileHandle,07h
	;Año....
	fprint opYyTg,fileHandle,06h
	fprint clYyTg,fileHandle,08h

	fprint clDtTg,fileHandle,09h
	;</Fecha>

	;Hora.......
	;<Hora>
	fprint opTcTg,fileHandle,07h
	;Hora.....
	fprint opHrTg,fileHandle,06h
	fprint clHrTg,fileHandle,08h
	;Minutos...
	fprint opMnTg,fileHandle,09h
	fprint clMnTg,fileHandle,0bh
	;Segundos...
	fprint opScTg,fileHandle,0ah
	fprint clScTg,fileHandle,0ch

	fprint clTcTg,fileHandle,08h
	;</Hora>

	;Alumno......
	;<Alumno>
	fprint opStTg,fileHandle,09h
	;Nombre....
	fprint opNmTg,fileHandle,08h
	fprint stLb,fileHandle,1bh
	fprint clNmTg,fileHandle,0ah
	;Carnet....
	fprint opIdTg,fileHandle,08h
	fprint idLb,fileHandle,09h
	fprint clIdTg,fileHandle,0ah

	fprint clStTg,fileHandle,0ah
	;</Alumno>
	;</Encabezado>
	fprint clHeadTg,fileHandle,0eh
	
	;------ Resultados -----------
	;Resultados.....
	;<Resultados>
	fprint opRsTg,fileHandle,0dh
	;ListaEntrada......
	fprint opLeTg,fileHandle,0fh
	fprint clLeTg,fileHandle,11h
	;BubbleSort...
	;<Ordenamiento_BubbleSort>
	fprint opBsTg,fileHandle,1ah
	;Tipo....
	fprint opTyTg,fileHandle,06h
	fprint clTyTg,fileHandle,08h
	;ListaOrdenada
	fprint opLsTg,fileHandle,10h
	fprint clLsTg,fileHandle,12h
	;Velocidad....
	fprint opSpTg,fileHandle,0bh
	fprint clSpTg,fileHandle,0dh
	;Tiempo....
	;<Tiempo>
	fprint opTmTg,fileHandle,09h
	;Minutos....
	fprint opMnTg,fileHandle,09h
	fprint clMnTg,fileHandle,0bh
	;Segundos...
	fprint opScTg,fileHandle,0ah
	fprint clScTg,fileHandle,0ch
	;Milisegundos..
	fprint opMsTg,fileHandle,0eh
	fprint clMsTg,fileHandle,10h
	;</Tiempo>
	fprint clTmTg,fileHandle,0ah
	;</Ordenamiento_BubbleSort>
	fprint clBsTg,fileHandle,1bh
	
	;QuickSort....
	;<Ordenamiento_QuickSort>
	fprint opQsTg,fileHandle,19h

	;Tipo....
	fprint opTyTg,fileHandle,06h
	fprint clTyTg,fileHandle,08h
	;ListaOrdenada
	fprint opLsTg,fileHandle,10h
	fprint clLsTg,fileHandle,12h
	;Velocidad....
	fprint opSpTg,fileHandle,0bh
	fprint clSpTg,fileHandle,0dh
	;Tiempo....
	;<Tiempo>
	fprint opTmTg,fileHandle,09h
	;Minutos....
	fprint opMnTg,fileHandle,09h
	fprint clMnTg,fileHandle,0bh
	;Segundos...
	fprint opScTg,fileHandle,0ah
	fprint clScTg,fileHandle,0ch
	;Milisegundos..
	fprint opMsTg,fileHandle,0eh
	fprint clMsTg,fileHandle,10h
	;</Tiempo>
	fprint clTmTg,fileHandle,0ah

	;</Ordenamiento_QuickSort>
	fprint clQsTg,fileHandle,1ah

	;ShellSort...
	;<Ordenamiento_ShellSort>
	fprint opSsTg,fileHandle,19h

	;Tipo....
	fprint opTyTg,fileHandle,06h
	fprint clTyTg,fileHandle,08h
	;ListaOrdenada
	fprint opLsTg,fileHandle,10h
	fprint clLsTg,fileHandle,12h
	;Velocidad....
	fprint opSpTg,fileHandle,0bh
	fprint clSpTg,fileHandle,0dh
	;Tiempo....
	;<Tiempo>
	fprint opTmTg,fileHandle,09h
	;Minutos....
	fprint opMnTg,fileHandle,09h
	fprint clMnTg,fileHandle,0bh
	;Segundos...
	fprint opScTg,fileHandle,0ah
	fprint clScTg,fileHandle,0ch
	;Milisegundos..
	fprint opMsTg,fileHandle,0eh
	fprint clMsTg,fileHandle,10h
	;</Tiempo>
	fprint clTmTg,fileHandle,0ah
	
	;</Ordenamiento_ShellSort>
	fprint clSsTg,fileHandle,1ah


	;</Resultados>
	fprint clRsTg,fileHandle,0eh
	
	;</Arqui>
	fprint closeRepTg,fileHandle,08h
	;close te file
	closeFile fileHandle
%endmacro
;==============================FILE PROCEDURES===========================================================
%macro openFile 1
	mov al, 0h	;access mode (000b = 0h only read)
	mov dx, %1	;offset of ascii file name 
	mov ah, 3dh	;request open File interruption 
	int 21h		;call interruption 21h
%endmacro

%macro readFile 2
	mov bx, %1		;handle
	mov cx, 400h	;bytes to read UPDATE: may give an error 
					;if smaller than the bytes in the input file
	mov dx, %2 		;buffer
	mov ah, 3fh ;request reading interruption
	int 21h 
%endmacro

%macro CreateFile 2
;parameters %1 ASCIZ filename,%2 handleArray
	mov cx,00h	;file attribute 00h = normal file or maybe read only
	mov dx,%1 	;dx = ASCIZ filename 
	mov ah,3ch	;request create file
	int 21h
	jc errorCreateFile
;Saving Handle after file created AX = Handle
	mov [%2],ah
	mov [%2+1],al
	print createFileMsg
	CreateReport
%endmacro

%macro closeFile 1
	mov bh,[%1]		;copy the high order(8 bits more significant)of handle
	mov bl,[%1+1]	;copy the low  order(8 bits less significant)of handle
	mov ah,3eh		;request close file interruption
	int 21h 		;call 21h interruption
%endmacro
;=============================END FILE PROCEDURES======================================
%macro GetTag 1
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
	cmp dh, 3ch					;dh = left < 
	jne errorInFile 			;if not equal to " then go to error IN File
	mov [%1+di],dh 				;add the first les than <..
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
	cmp dh, 3eh 				;dh = right > (ascii 3eh)
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
	;printChar dh
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
	je %%TokenFound 			;if are equal jmp to GetNextChar
	%%TokenFound:
	inc si
%endmacro

%macro GetData 0
	;-----------------------------START::=openDocTag LISTOFCHILDS closeDocTag
	%%StartTag:
	xor di,di
	xor si,si
	mov si,00h 					;index for fileReadBf
	mov di,00h 					;index for numArray
	GetNextToken 3ch 			;send character =  < (Ascii 3ch)
	dec si
	GetTag currentTag 			;retrieve the tag < "anything"  >
	print currentTag
	;print newline
	print openTag

	CmpString currentTag,openTag,09h ;if currentTag = <Numeros>
	cmp al, 01h					;flag al = 1 (open tag found = true )
	jne errorXmlTag 			;erro no start tag found <Numeros>
	inc si 						;si + 1 (Next Character)
	
	;---------------------------CHILD::=openTgChild num=<Numero>..</Numero> closeTgChild
	; 									|

	GetNextToken 3ch			;send character =  < (Ascii 3eh)
	dec si 						
	GetTag currentTag 			;retrieve the tag < "anything"  >
	print currentTag
	CmpString currentTag,openTgChild,09h ;if currentTag = <Numero>
	cmp al,01h					;flag al = 1 (open tag found = true )
	jne %%EmptyList				;if not equal jump to EmptyList just the firsTime
								;if equal continue to.. TheChilds
	
	;---------------------------LISTOFCHILDS::=LISTCHILDS CHILD
	;											|CHILD
	%%TheChilds:
	GetChild 					;Macro Get Childs list of numbers
	inc si
	GetNextToken 3ch			;send character =  < (Ascii 3eh)
	dec si
	GetTag currentTag 			;retrieve the tag < "anything" >
	print currentTag
	CmpString currentTag,openTgChild,09h ;if currentTag = <Numero>
	cmp al,01h					;flag al = 1 (open tag found = true )
	je %%TheChilds 				;jump to The Childs
	jmp %%EndTag				;No more numbers got to end tag
	
	%%EmptyList:
	print errEmptyListMsg 		;print the list is empty
	
	%%EndTag:
	print currentTag
	print closeTag
	CmpString currentTag,closeTag,08h ;if currentTag = </Numeros> end tag of xml doc
	cmp al,01h 					;flag al = 1 (open tag found = true )
	jne errorXmlTag 			;if not equal ->error close tag not found
	;--------------------------- GET LENGTH OF ITEMS IN numArray --------------------------
	mov ax, di 					;copy to ax the array index DI = count of items in array
	 							;use ax because dividend is assumed to be in Ax register
	;mov bh,02h 					;8 bit divisor 
								;(decimal num 2 due to each number 
								;fill 2 byte space in numArray) Eg: 10(byte space)/2 = 5 numbers
	;div bh 						;div divisor
	mov [sizeArray],al 			; al = quotient ah = remainder
								;sizeArray = number of items in array
	print analysisMsg
	
%endmacro

%macro GetChild 0

								;last si value = <Numero>num
	inc si 						;inc si = num
	%%GetNum:
	mov dl, [fileReadBf+si+1] 	;
	cmp dl,3ch 					;dl = < (Ascii 3ch)
	je %%GetDigit1				;is 1 digit number
	mov dl,[fileReadBf+si+2]	 
	cmp dl,3ch 					;dl = < (Ascii 3ch)
	je %%GetDigit2 				;is 2 digit number
	mov dh, [fileReadBf+si] 	;save the current character to print as an error
	jmp errorInFile 			;jump to error file. expected a number
	
	%%GetDigit1:
	mov dl, [fileReadBf+si] 	;first digit
	xor dh,dh 					;clean dh = 0
	sub dx,30h 					;subtract 30h('0') to convert to decimal 
	mov [numArray+di],dh		;copy the high order(8 bits more significant)before
	mov [numArray+di+1],dl 		;copy the low  order(8 bits less significant)after

	add di,02h 					;increment DI by 2,  de high and low part of number
	add si,01h 					;increment SI by 1, 1 digit number
	jmp %%EndTag

	%%GetDigit2:
	mov al, [fileReadBf+si] 	;first digit is the ten(10^1)
								;use al register due to MUL instruction
	xor ah,ah 					;clean ah = 0
	sub ax,30h 					;subtract 30h('0') to convert to decimal
	mov bl, [fileReadBf+si+1]	;second digit is the unity(10^0)
	xor bh,bh 					;clean bh = 0
	sub bx,30h 					;subtract 30h('0') to convert to decimal
	mov cx,0ah 					;prepare multiplier (cx= 0ah = 10)
	mul cx 						;multiply(al*cx = Digit1*10^1 = ten = ah al)
	add ax,bx 					;sum ax and bx = ten + unity = digit1*(10^1) + digit2*(10^0)
	mov [numArray+di],ah 		;copy the high order(8 bits more significant)before
	mov [numArray+di+1],al 		;copy the low  order(8 bits less significant)after

	add di,02h 					;increment DI by 2,  de high and low part of number
	add si,02h 					;increment SI by 2, 2 digit number
	jmp %%EndTag

	%%EndTag:
	GetNextToken 3ch			;send character =  < (Ascii 3eh)
	dec si
	GetTag currentTag
	print currentTag
	print closeTgChild
	CmpString currentTag,closeTgChild,09h ;if currentTag = </Numero>
	cmp al,01h					;flag al = 1 (open tag found = true )
	jne errorXmlTag
	;jne errorPathInput
%endmacro

%macro CmpString 3
	push si 				    ;push SI to save its current value and been able 
								;to use SI without loose the previous value
	push di 					;push DI to save its current value and been able 
								;to use DI without loose the previous value
	push cx

	
	mov si,%1 					;first param  = string 1
	mov di,%2 					;second param = string 2
	mov ch,0h
	cld
	mov cl,%3 					;third param  = length of string comparation
   	
   	;print reportName
   	repe  cmpsb
    jne  %%NoEqual				;jump when ecx is zero
    print strEqualMsg
    mov al,01h					;flag al = 01 = equal , 
    jmp %%exit
    
    %%NoEqual:
    dec si
    dec di
    print strNoEqualMsg
    mov al,0h					;flag al = 00 = equal ,
    
    %%exit:
    
    pop cx
    pop di 						;pop out DI previous value
    pop si 						;pop out SI previous value

%endmacro

%macro CopyArray 3 ;1 size 2 name copy array, 3 actual array
	;print %1
	;mov al,00h
	;mov ah,00h
	xor al,al		;clean al
	xor ah,ah		;clean ah
	mov di,00h		;di = 0
	mov al,[%1]		;al = sizeArray

	%%for:
	mov cl,[%3+di]	;cl = actualArray[di]
	mov [%2+di],cl 	;copyArray[di] = cl
	inc di			;di = di + 1
	cmp di,ax 		;di = ax ? 
	jne %%for 		; di != ax jmp For
%endmacro

%macro DecToAscii 2 ;%1 number, %2 charArray
	;to convert a decimal number of the form: 234..
	;divide decimalnum/10
	;keep dividing quotient/10 till quotient is zero
	;using div for 16bit division = dx ax/16 bit divisor
	;ax(quotient) dx(remainder)
	push ax
	push bx
	push dx
	push cx
	push si
	push di
;---------counter of positions ---------------------------
	mov ax,%1		;save the number to convert in ax register
	push ax
	mov bx,0ah		;save dividend in bx = 0ah = 10
	xor di,di		;clean di 
	%%counter:
	xor dx,dx 		;clean dx
	div bx 			;divide by 10
	inc di 			;increment to save in the next position (count how many digits)
	cmp ax,0h		;if ax(quotient) = 0 stop 
	jne %%counter   ;if not continue..
					;end of counter
	dec di			;start saving at lenght - 1
;----------- Convert Decimal to Ascii ----------------------
	pop ax
	xor si,si		;clean SI 
	%%while:
	xor dx,dx 		;clean dx
	div bx 			;divide by 10
	add dx,30h		;add 30h('0') to remainder to convert to Ascii
	mov [%2+di],dl 	;save 8 lsb bits in numCharArray backwards
	dec di			;decrement di till get to zero 
	inc si 			;increment to save in the next position
	cmp ax,0h		;if ax(quotient) = 0 stop 
	jne %%while		;if not continue..
	mov al,'$'
	mov [%2+si],al	;save end of string in las postino of array

	pop di
	pop si
	pop cx
	pop dx
	pop bx
	pop ax

%endmacro
;-------------------------------------- SORT FUNCTIONS ----------------------------
%macro BubbleSort 2 ; 1 Array to sort,2 size
	push ax
	push bx
	push cx
	push si
	push di
	xor al,al
	xor ah,ah 				;clean ah = 0
	xor cx,cx
	mov di,00h				;i = 0
	mov si,00h 				;j = 0
	mov al,[%2]				;length
	;mov cx,02h 				
	;mul cx
	

	%%for1:
	;print mytest
	mov si,00h 				;j = 0
	cmp di,ax				; if di = ax ; i = length
	je %%EndSort 			;if i = length -> then EndSort
							;if not continue...
	add di,02h 				; di = di + 2 -> i = i + 1
	%%for2: 	

	;add si,02h 			; si = si + 2 -> j = j + 1
	cmp si,ax				; if j = length - 1 
	;cmp si,08h
	je %%for1 				; then jump back to for1
	 						;if not equal
	;---------------- auxArray[j] = bx ----------------------------------------	
	mov bh, [%1+si] 		;copy the high order(8 bits more significant)before
	mov bl, [%1+si+1] 		;copy the low  order(8 bits less significant)after	
	;---------------- auxArray[j+1] = cx ----------------------------------------		
	mov ch, [%1+si+2]  		;copy the high order(8 bits more significant)before
	mov cl, [%1+si+3] 		;copy the low  order(8 bits less significant)after
	;---------------- if(auxArray[j] > auxArray[j+1]) ---------------------------
	cmp bx,cx
	jg %%Swap				;if true then swap
	add si,02h 				;if not si + 2 -> j + 1
	jmp %%for2
	%%Swap:
	mov [%1+si],ch
	mov [%1+si+1],cl
	mov [%1+si+2],bh
	mov [%1+si+3],bl
	add si,02h
	
	DrawBarGraph auxArray,sizeArray
	Delay 8
	jmp %%for2
	%%EndSort:
	pop di
	pop si
	pop cx
	pop bx
	pop ax
%endmacro
%macro BubbleSortDesc 2 ; 1 Array to sort,2 size
	push ax
	push bx
	push cx
	push si
	push di
	xor al,al
	xor ah,ah 				;clean ah = 0
	xor cx,cx
	mov di,00h				;i = 0
	mov si,00h 				;j = 0
	mov al,[%2]				;length
	mov cl,[%2]
	sub cl,2
	;mov al,4
	;mov cl,2
	%%for1:
	cmp di,ax				;di = length
	je %%EndSort
	mov si,00h
	
	%%for2:
	cmp si,cx				;si = length - 1
	je %%EndFor2
	push cx
	;---------------- auxArray[j] = bx ----------------------------------------	
	mov bh, [%1+si] 		;copy the high order(8 bits more significant)before
	mov bl, [%1+si+1] 		;copy the low  order(8 bits less significant)after	
	;---------------- auxArray[j+1] = cx ----------------------------------------		
	mov ch, [%1+si+2]  		;copy the high order(8 bits more significant)before
	mov cl, [%1+si+3] 		;copy the low  order(8 bits less significant)after
	;---------------- if(auxArray[j] > auxArray[j+1]) ---------------------------
	
	cmp bx,cx
	jl %%Swap
	jmp %%IncFor2
	%%Swap:
	;printChar bx
	;printChar si
	;printChar 31h
	mov [%1+si],ch
	mov [%1+si+1],cl
	mov [%1+si+2],bh
	mov [%1+si+3],bl
	pop cx
	%%IncFor2:
	;add si,02h
	inc si
	inc si
	DrawBarGraph auxArray,sizeArray
	Delay 5
	jmp %%for2
	%%EndFor2:
	add di,02h
	;inc di 			    ;si = si + 2
	jmp %%for1

	%%EndSort:
	pop di
	pop si
	pop cx
	pop bx
	pop ax
%endmacro

;=========================================END SORT FUNCTIONS ===============================

;************************************** END MY MACROS *****************************

global Main
;========================== SECTION .DATA ====================
segment .data

vgaStartAddr dw 0A000h 		;start positon of vga memory
							;0a0000h - bffffh

headerLabel db 13,13,10
        db 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',13,10
        db 'FACULTAD DE INGENIERIA ',13,10
        db 'CIENCIAS Y SISTEMAS',13,10
        db 'ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1',13,10
        db 'NOMBRE: LESTER EFRAIN AJUCUM SANTOS',13,10
        db 'CARNET: 201504510',13,10
        db 'SECCION: A',13,10
        db 'PRACTICA 6',13,10,'$' 

mainMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_________ MENU __________|', 13, 10
        db '|   1. Cargar Archivo     |', 13, 10
        db '|   2. Ordenar	          |', 13, 10
        db '|   3. Salir              |', 13, 10
        db '|   4. Generar Reporte    |', 13, 10
        db '|_________________________|',13,10,'$' 

sortMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_________ MENU __________|', 13, 10
        db '|   1. Bubble Sort        |', 13, 10
        db '|   2. Quick Sort         |', 13, 10
        db '|   3. Shell Sort         |', 13, 10
        db '|   4. Regresar           |', 13, 10
        db '|_________________________|',13,10,'$'

loadFileLabel db '=============== CARGAR ARCHIVO ===============',13,10,'$'

inputPathLabel db 'Ingrese Ruta: ','$'

optionLabel db 'Escoja Opcion: ','$'

sortLabel db 'Ordenamiento: ','$'

bubbleLabel db 'BubbleSort','$'

errPathMsg db 13,10,'Error ruta archivo Intente de nuevo',13,10,'$'

errOpenMsg db 13,10,'Error No se puedo Abrir el Archivo',13,10,'$'

openFileMsg db 13,10,'Archivo Abierto correctamente',13,10,'$'

readFileMsg db 13,10,'Archivo Leido correctamente',13,10,'$'

createFileMsg db 13,10,'Archivo Creado correctamente',13,10,'$'

errReadFileMsg db 13,10,'Error No se puedo Leer el Archivo',13,10,'$'

errCreateFileMsg db 13,10,'Error No se puedo Crear el Archivo',13,10,'$'

errSintMsg db 13,10,'Error Caracter no esperado: ','$' ;29 characters

errTagMsg db 13,10,'Error etiqueta no esperada','$' ;29 characters

errEmptyListMsg db 13,10,'La lista de numeros esta vacia','$' ;29 characters

analysisMsg db 13,10,'Analisis realizado correctamente',13,10,'$'

bubbleSortMsg db 13,10,'Ordenamiento Burbuja: ',13,10,'$'

beforeSortMsg db 13,10,'Antes De Ordenamiento: ',13,10,'$'

afterSortMsg db 13,10,'Despues De Ordenamiento: ',13,10,'$'

newline db 13,10,'$'
blankSpace db 20h,'$'

esUno	db 0ah,0dh,'es uno',10,'$'
esDos	db 0ah,0dh,'es dos',10,'$'
esTres	db 0ah,0dh,'es tres',10,'$'

filePath db 50
fileReadBf times 600 db '$'

numArray times 100 db '$' 
sizeArray db 2,'$'

Height db 2,'$'

Width db 4,'$'

charCol db 1,'$'
charRow db 1,'$'

auxArray times 100 db '$'
numCharArray times 10 db '$'
arrayTest db 1,'$'
arrayTest2 db 1,'$'
openTag db '<Numeros>','$'
closeTag db '</Numeros>','$'
lenTag equ 10 

openTgChild db '<Numero>','$'
closeTgChild db '</Numero>','$'
mytest db '<Numero>','$'

currentTag times 10 db '$' 		;array to save A tag <Numeros>,</Numeros>
								;<Numero>,</Numero>

strEqualMsg db 13,10,'Strings son iguales',13,10,'$'
strNoEqualMsg db 13,10,'Strings No son iguales',13,10,'$'

;Report Text ________________________________

reportName db 'reporte.xml',0,'$'	;ASCIZ filename
fileHandle db 0 					;array to save handle of newfile
		   db '$'
unLb	db 'Universidad De San Carlos De Guatemala'			;38 bytes
facLb	db 'Facultad De Ingenieria'							;22 bytes
schLb	db 'Ciencias Y Sistemas'							;19 bytes
crLb	db 'Arquitectura De Computadoras Y Ensambladores 1' ;46 bytes
snLb	db 'Seccion A'										; 9 bytes
ciLb	db 'Primer Semestre 2019'							;20 bytes
stLb	db 'Lester Efrain Ajucum Santos'					;27 bytes
idLb	db '201504510'										; 9 bytes
srALb	db 'Ascendente'										;10 bytes
srDLb	db 'Descendete'										;10 bytes

openRepTg	db '<Arqui>' ,10 		;Open Tag for Report (8 bytes)
closeRepTg	db '</Arqui>',10	 	;Close Tag for Report (8 bytes)
opHeadTg	db '<Encabezado>',10 	;Open Tag for Header (13 bytes)
clHeadTg	db '</Encabezado>',10 	;Close Tag for Header (14 bytes)
opUTg		db '<Universidad>'  	;Open Tag  (13 bytes)
clUTg		db '</Universidad>',10 	;Close Tag (15 bytes)
opFacTg		db '<Facultad>' 		;Open Tag  (10 bytes)
clFacTg		db '</Facultad>',10 	;Close Tag (12 bytes)
opSchTg		db '<Escuela>'  		;Open Tag  (9 bytes)
clSchTg		db '</Escuela>',10 		;Close Tag (11 bytes)
opCrsTg		db '<Curso>',10 		;Open Tag  (8 bytes)
clCrsTg		db '</Curso>',10 		;Close Tag (9 bytes)
opNmTg		db '<Nombre>'   		;Open Tag  (8 bytes)
clNmTg		db '</Nombre>',10 		;Close Tag (10 bytes)
opSnTg		db '<Seccion>'  		;Open Tag  (9 bytes)
clSnTg		db '</Seccion>',10 		;Close Tag (11 bytes)
opCiTg		db '<Ciclo>'    		;Open Tag  (7 bytes)
clCiTg		db '</Ciclo>',10 		;Close Tag (9 bytes)
opDtTg		db '<Fecha>',10 		;Open Tag  (8 bytes)
clDtTg		db '</Fecha>',10 		;Close Tag (9 bytes)
opDdTg		db '<Dia>'  			;Open Tag  (5 bytes)
clDdTg		db '</Dia>',10 			;Close Tag (7 bytes)
opMmTg		db '<Mes>'	 			;Open Tag  (5 bytes)
clMmTg		db '</Mes>',10 			;Close Tag (7 bytes)
opYyTg		db '<Año>'          	;Open Tag  (6 bytes)
clYyTg		db '</Año>',10 			;Close Tag (8 bytes)
opTcTg		db '<Hora>',10 			;Open Tag  (7 bytes)
clTcTg		db '</Hora>',10 		;Close Tag (8 bytes)
opHrTg		db '<Hora>' 			;Open Tag  (6 bytes)
clHrTg		db '</Hora>',10 		;Close Tag (8 bytes)
opMnTg		db '<Minutos>'  		;Open Tag  (9 bytes)
clMnTg		db '</Minutos>',10 		;Close Tag (11 bytes)
opScTg		db '<Segundos>' 		;Open Tag  (10 bytes)
clScTg		db '</Segundos>',10 	;Close Tag (12 bytes)
opStTg		db '<Alumno>',10 		;Open Tag  (9 bytes)
clStTg		db '</Alumno>',10 		;Close Tag (10 bytes)
opIdTg		db '<Carnet>'   		;Open Tag  (8 bytes)
clIdTg		db '</Carnet>',10 		;Close Tag (10 bytes)
opRsTg		db '<Resultados>',10 	;Open Tag  (13 bytes)
clRsTg		db '</Resultados>',10 	;Close Tag (14 bytes)
opTyTg		db '<Tipo>' 			;Open Tag  (6 bytes)
clTyTg		db '</Tipo>',10 		;Close Tag (8 bytes)
opLeTg		db '<Lista_Entrada>' 		    ;Open Tag  (15 bytes)
clLeTg		db '</Lista_Entrada>',10 		;Close Tag (17 bytes)
opLsTg		db '<Lista_Ordenada>'	 		;Open Tag  (16 bytes)
clLsTg		db '</Lista_Ordenada>',10 		;Close Tag (18 bytes)
opSpTg		db '<Velocidad>'	 			;Open Tag  (11 bytes)
clSpTg		db '</Velocidad>',10 			;Close Tag (13 bytes)
opTmTg		db '<Tiempo>',10 				;Open Tag  (9 bytes)
clTmTg		db '</Tiempo>',10 				;Close Tag (10 bytes)
opMsTg		db '<Milisegundos>' 			;Open Tag  (14 bytes)
clMsTg		db '</Milisegundos>',10 		;Close Tag (16 bytes)
opBsTg	db '<Ordenamiento_BubbleSort>',10 	;Open Tag  (26 bytes)
clBsTg	db '</Ordenamiento_BubbleSort>',10 	;Close Tag (27 bytes)
opQsTg	db '<Ordenamiento_QuickSort>',10 	;Open Tag  (25 bytes)
clQsTg	db '</Ordenamiento_QuickSort>',10 	;Close Tag (26 bytes)
opSsTg	db '<Ordenamiento_ShellSort>',10 	;Open Tag  (25 bytes)
clSsTg	db '</Ordenamiento_ShellSort>',10 	;Close Tag (26 bytes)


A db 0,0,1,0
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1
  db 0,1,0,1

B db 0,1,1,0
  db 0,1,0,1
  db 0,1,1,0
  db 0,1,0,1
  db 0,1,1,0

C db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,0
  db 0,1,0,1
  db 0,0,1,0

D db 0,1,1,0
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,0

E db 0,1,1,1
  db 0,1,0,0
  db 0,1,1,0
  db 0,1,0,0
  db 0,1,1,1

F db 0,1,1,1
  db 0,1,0,0
  db 0,1,1,1
  db 0,1,0,0
  db 0,1,0,0

G db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,0
  db 0,1,1,1
  db 0,1,1,0

H db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1
  db 0,1,0,1

I db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0

J db 0,0,0,1
  db 0,0,0,1
  db 0,0,0,1
  db 0,1,0,1
  db 0,0,1,0

K db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,0
  db 0,1,0,1
  db 0,1,0,1

L db 0,1,0,0
  db 0,1,0,0
  db 0,1,0,0
  db 0,1,0,0
  db 0,1,1,1

M db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1
  db 0,1,0,1

N db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1

O db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0

P db 0,1,1,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,0
  db 0,1,0,0

Q db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,1

R db 0,1,1,1
  db 0,1,0,1
  db 0,1,1,0
  db 0,1,0,1
  db 0,1,0,1

S db 0,0,1,0
  db 0,1,0,1
  db 0,0,1,0
  db 0,1,0,1
  db 0,0,1,0

T db 0,1,1,1
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0

U db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1

V db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0

W db 0,1,0,1
  db 0,1,0,1
  db 0,1,0,1
  db 0,1,1,1
  db 0,1,0,1

X db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0
  db 0,1,0,1
  db 0,1,0,1

Y db 0,1,0,1
  db 0,1,0,1
  db 0,0,1,0
  db 0,0,1,0
  db 0,0,1,0 

Z db 0,1,1,1
  db 0,0,0,1
  db 0,0,1,0
  db 0,1,0,0
  db 0,1,1,1

ONE db 0,0,1,0
	db 0,1,1,0
  	db 0,0,1,0
  	db 0,0,1,0
  	db 0,0,1,0

TWO db 0,1,1,1
  	db 0,0,0,1
  	db 0,1,1,1
  	db 0,1,0,0
  	db 0,1,1,1

THREE 	db 0,1,1,0
  		db 0,0,0,1
  		db 0,0,1,0
  		db 0,0,0,1
  		db 0,1,1,0

FOUR	db 0,1,0,1
  		db 0,1,0,1
  		db 0,1,1,1
  		db 0,0,0,1
  		db 0,0,0,1

FIVE	db 0,1,1,1
  		db 0,1,0,0
  		db 0,1,1,1
  		db 0,0,0,1
  		db 0,1,1,1

SIX		db 0,0,1,1
  		db 0,1,0,0
  		db 0,1,1,1
  		db 0,1,0,1
  		db 0,0,1,0

SEVEN	db 0,1,1,0
  		db 0,0,1,0
  		db 0,1,1,1
  		db 0,0,1,0
  		db 0,0,1,0

EIGHT db 0,0,1,0
  	  db 0,1,0,1
  	  db 0,0,1,0
  	  db 0,1,0,1
  	  db 0,0,1,0

NINE db 0,1,1,1
     db 0,1,0,1
  	 db 0,1,1,1
  	 db 0,0,0,1
  	 db 0,0,0,1

ZERO db 0,1,1,1
  	 db 0,1,0,1
  	 db 0,1,0,1
  	 db 0,1,0,1
  	 db 0,1,1,1

COLON 	db 0,0,1,0
  		db 0,0,1,0
  		db 0,0,0,0
  		db 0,0,1,0
  		db 0,0,1,0 
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
 ;print headerLabel
 print mainMenu
 print newline
 print optionLabel
 
 readInputChar
	cmp al, 49
	je Option1		;Load File (1)
	cmp al, 50
	je Option2 		;Sort (2)
	cmp al, 51
	je Option3 		;Exit (3)
	cmp al, 52
	je Option4 		;Create Report (4)
	cmp al,53
	je Video		;To Test video mode (5)
	cmp al,54 		
	je Text			;To return text mode (6)
	jmp Main
;=========================================OPTION 1========================
Option1:
	print esUno
	print loadFileLabel
	print inputPathLabel
	xor si,si				;SI will be used for index of filePath array
	mov si,0
	;-------------geth the input path-------------------------------
	readInputChar				
	cmp al, 25h 			; al = % (Ascii 25h)
	jne errorPathInput 		;if is no % then error ask path again
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
	cmp al, 0dh 			; al = CR (carriage return) if key enter
	je errorPathInput
	checkExt:				;check json extension - update: any other extension
	readInputChar 			;read a new char for the extension path file	
	cmp al, 0dh 			; al = CR (carriage return) if key enter
	je errorPathInput
	cmp al, 25h    		 	; al = %(Ascii 25h) if char % pressed end of reading 
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
	readFile ax,fileReadBf	;call macro readFile and pass the handle and buffer as parameter
	jc errorReadFile 		;if file couldn't be read jump to error
	print readFileMsg  		;print message file read
	jmp Scanner
	jmp Main
;================================= OPTION 2 - 4 ===========================
Option2:
	print esDos
	print beforeSortMsg
	print numArray
	jmp SortMenu
Option3:
	print esTres
	xor cl,cl
	for:
	;printChar cl
	inc cl 
	cmp cl,165
	jne for
	jmp exit
Option4:
	print esTres
;Create a new File : NAME, array to save handle
	CreateFile reportName,fileHandle

	jmp Main
Video:
setVideoMode 13h
mov al,1
mov [charCol],al
;drawChar 1,charCol,P
PlotChar 1,charCol,43h
mov al,2
mov [charCol],al
drawChar 1,charCol,R
mov al,3
mov [charCol],al
drawChar 1,charCol,O
mov al,4
mov [charCol],al
drawChar 1,charCol,C
mov al,5
mov [charCol],al
drawChar 1,charCol,E
mov al,6
mov [charCol],al
drawChar 1,charCol,D
mov al,7
mov [charCol],al
drawChar 1,charCol,I
mov al,8
mov [charCol],al
drawChar 1,charCol,M
mov al,9
mov [charCol],al
drawChar 1,charCol,I
mov al,10
mov [charCol],al
drawChar 1,charCol,E
mov al,11
mov [charCol],al
drawChar 1,charCol,N
mov al,12
mov [charCol],al
drawChar 1,charCol,T
mov al,13
mov [charCol],al
drawChar 1,charCol,O
mov al,14
mov [charCol],al
drawChar 1,charCol,COLON

mov al,16
mov [charCol],al
drawChar 1,charCol,B
mov al,17
mov [charCol],al 
drawChar 1,charCol,U
mov al,18
mov [charCol],al
drawChar 1,charCol,B
mov al,19
mov [charCol],al
drawChar 1,charCol,B
mov al,20
mov [charCol],al
drawChar 1,charCol,L
mov al,21
mov [charCol],al
drawChar 1,charCol,E
mov al,22
mov [charCol],al
drawChar 1,charCol,S
mov al,23
mov [charCol],al
drawChar 1,charCol,O
mov al,24
mov [charCol],al
drawChar 1,charCol,R
mov al,25
mov [charCol],al
drawChar 1,charCol,T

mov al,27
mov [charCol],al
drawChar 1,charCol,T
mov al,28
mov [charCol],al
drawChar 1,charCol,I
mov al,29
mov [charCol],al
drawChar 1,charCol,E
mov al,30
mov [charCol],al
drawChar 1,charCol,M
mov al,31
mov [charCol],al
drawChar 1,charCol,P
mov al,32
mov [charCol],al
drawChar 1,charCol,O
mov al,33
mov [charCol],al
drawChar 1,charCol,COLON

mov al,35
mov [charCol],al
drawChar 1,charCol,ZERO
mov al,36
mov [charCol],al
drawChar 1,charCol,ZERO
mov al,37
mov [charCol],al
drawChar 1,charCol,COLON
mov al,38
mov [charCol],al
drawChar 1,charCol,ZERO
mov al,39
mov [charCol],al
drawChar 1,charCol,ZERO

mov al,41
mov [charCol],al
drawChar 1,charCol,V
mov al,42
mov [charCol],al
drawChar 1,charCol,E
mov al,43
mov [charCol],al
drawChar 1,charCol,L
mov al,44
mov [charCol],al
drawChar 1,charCol,O
mov al,45
mov [charCol],al
drawChar 1,charCol,C
mov al,46
mov [charCol],al
drawChar 1,charCol,I
mov al,47
mov [charCol],al
drawChar 1,charCol,D
mov al,48
mov [charCol],al
drawChar 1,charCol,A
mov al,49
mov [charCol],al
drawChar 1,charCol,D
mov al,50
mov [charCol],al
drawChar 1,charCol,COLON
mov al,51
mov [charCol],al
drawChar 1,charCol,ZERO

;===DRAW THE LABELS

;print sizeArray
BubbleSort auxArray,sizeArray
;BubbleSortDesc auxArray,sizeArray 		;Run bubbleSort procedure
;DrawBarGraph auxArray,sizeArray
;DrawArea 156,0,8,200, 03h
;DrawArea 166,50,8,150, 03h
;DrawArea 0,96,320,8,04h
readInputChar
jmp Main

Text:
setVideoMode 03h
jmp Main
;================================ SORT MENU =========================
SortMenu:
	print sortMenu
	print optionLabel
	readInputChar
	cmp al, 49
	je BubbleSortOp
	cmp al, 50
	je QuickSortOp
	cmp al, 51
	je ShellSortOp
	cmp al, 52
	je BackMain

BubbleSortOp:
setVideoMode 13h
mov al,1
mov [charCol],al
;drawChar 1,charCol,P
PlotChar 1,charCol,43h
mov al,2
mov [charCol],al
drawChar 1,charCol,R
mov al,3
mov [charCol],al
drawChar 1,charCol,O
mov al,4
mov [charCol],al
drawChar 1,charCol,C
mov al,5
mov [charCol],al
drawChar 1,charCol,E
mov al,6
mov [charCol],al
drawChar 1,charCol,D
mov al,7
mov [charCol],al
drawChar 1,charCol,I
mov al,8
mov [charCol],al
drawChar 1,charCol,M
mov al,9
mov [charCol],al
drawChar 1,charCol,I
mov al,10
mov [charCol],al
drawChar 1,charCol,E
mov al,11
mov [charCol],al
drawChar 1,charCol,N
mov al,12
mov [charCol],al
drawChar 1,charCol,T
mov al,13
mov [charCol],al
drawChar 1,charCol,O
mov al,14
mov [charCol],al
drawChar 1,charCol,COLON

mov al,16
mov [charCol],al
drawChar 1,charCol,B
mov al,17
mov [charCol],al 
drawChar 1,charCol,U
mov al,18
mov [charCol],al
drawChar 1,charCol,B
mov al,19
mov [charCol],al
drawChar 1,charCol,B
mov al,20
mov [charCol],al
drawChar 1,charCol,L
mov al,21
mov [charCol],al
drawChar 1,charCol,E
mov al,22
mov [charCol],al
drawChar 1,charCol,S
mov al,23
mov [charCol],al
drawChar 1,charCol,O
mov al,24
mov [charCol],al
drawChar 1,charCol,R
mov al,25
mov [charCol],al
drawChar 1,charCol,T

mov al,27
mov [charCol],al
drawChar 1,charCol,T
mov al,28
mov [charCol],al
drawChar 1,charCol,I
mov al,29
mov [charCol],al
drawChar 1,charCol,E
mov al,30
mov [charCol],al
drawChar 1,charCol,M
mov al,31
mov [charCol],al
drawChar 1,charCol,P
mov al,32
mov [charCol],al
drawChar 1,charCol,O
mov al,33
mov [charCol],al
drawChar 1,charCol,COLON

mov al,35
mov [charCol],al
drawChar 1,charCol,ZERO
mov al,36
mov [charCol],al
drawChar 1,charCol,ZERO
mov al,37
mov [charCol],al
drawChar 1,charCol,COLON
mov al,38
mov [charCol],al
drawChar 1,charCol,ZERO
mov al,39
mov [charCol],al
drawChar 1,charCol,ZERO

mov al,41
mov [charCol],al
drawChar 1,charCol,V
mov al,42
mov [charCol],al
drawChar 1,charCol,E
mov al,43
mov [charCol],al
drawChar 1,charCol,L
mov al,44
mov [charCol],al
drawChar 1,charCol,O
mov al,45
mov [charCol],al
drawChar 1,charCol,C
mov al,46
mov [charCol],al
drawChar 1,charCol,I
mov al,47
mov [charCol],al
drawChar 1,charCol,D
mov al,48
mov [charCol],al
drawChar 1,charCol,A
mov al,49
mov [charCol],al
drawChar 1,charCol,D
mov al,50
mov [charCol],al
drawChar 1,charCol,COLON
mov al,51
mov [charCol],al
drawChar 1,charCol,EIGHT
CopyArray sizeArray,auxArray,numArray 	;makes a copy of the data
print bubbleSortMsg 				;Print Bubble Sort on screen
print sizeArray 					;Print the size of array as a character
print newline
print auxArray 						;Print each num still not as Ascii
BubbleSort auxArray,sizeArray 		;Run bubbleSort procedure
;BubbleSortDesc auxArray,sizeArray
;print newline 						;Print a newline on screen
;print afterSortMsg 					
;print auxArray 						;Print the num array after BubbleSorted


;mov bh,[auxArray]
;mov bl,[auxArray+1]
;DecToAscii bx,numCharArray
;print numCharArray
;printChar [numCharArray]
;printChar [numCharArray+1]
;mov bh,[auxArray+2]
;mov bl,[auxArray+3]
;DecToAscii bx,numCharArray
;print numCharArray
;mov bh,[auxArray+4]
;mov bl,[auxArray+5]
;DecToAscii bx,numCharArray
;print numCharArray
readInputChar
jmp Main

QuickSortOp:
;DoubleArray
print newline
;print auxArray
print numCharArray
jmp Main

ShellSortOp:
jmp Main
	
BackMain:

jmp Main
;====================== ANALISYS OF THE FILE ===============
Scanner:
mov al,0h
GetData
CopyArray sizeArray,auxArray,numArray 	;makes a copy of the data
jmp Main
;======================== PRINT ERRORS SECTION =======================
errorOpenFile:
print errOpenMsg
jmp Main

errorReadFile:
print errReadFileMsg
jmp Main

errorCreateFile:
print errCreateFileMsg
jmp Main

errorPathInput:
print newline
print errPathMsg
jmp Main

errorInFile:
print errSintMsg
;printChar dx
print newline
jmp Main

errorXmlTag:
print errTagMsg
print currentTag
print newline
jmp Main


exit:
 mov ah, 4ch
 int 21h
;nasm -f bin prc6.asm -o prc6.com
;prc6
;************************* END SECTION TEXT ********************************************************

;-=== PRINT STRING ON SCREEN WITH BIOS INTERRUPT
	;mov ax,cs
	;mov es,ax
	;mov bp, userlb

	;mov ah, 13h
	
	;mov cx, 06h
	;mov dh, 01h
	;mov dl, 27
	;mov al, 01h
	;mov bh,00h
	;mov bl, 15

	;int 10h
	;---------------------------------------