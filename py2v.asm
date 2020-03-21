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

%macro printChar 1		;this macro will print to screen    
	push ax
	push dx

	mov dl,%1		;refers to the first parameter to the macro call

	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption
    pop dx
    pop ax
%endmacro

%macro readInputChar 0
    mov ah, 01h    ;Return AL with the ASCII of the read char
    int 21h        ;call the interruption
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

%macro printCar 1
;%1 posicion X
	

%endmacro


%macro PlotChar 3
; row, column,  
; %1 ,	%2   ,	%3 
	;push ax


	mov al,%3
	;printChar al
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

%macro sleep 1
 	push si
 	mov si, %1
 	%%b1:
 	dec si
 	jnz %%b1
 	pop si
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
	je Option1		;Set Video Mode (1)
	cmp al, 50
	je Option2 		;Get Video Mode (2)
	cmp al, 51
	je Option3 		;Exit (3)
	cmp al, 52
	je Option4 		;Set Text Mode (4)
	cmp al, 53
	je Option5 		;Test (4)
	jmp Main

exit:
 mov ah, 4ch
 int 21h

Option1: 				;SET VIDEO MODE
	;mov ah,0h
	;mov al,13h
	;int 10h
	setVideoMode 13h

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
	;DrawArea 80,20,50,30,02h
	;-------- DRAW CONTOUR --------------------------
	DrawArea 80,5,20,150,02h 			;LEFT 
	DrawArea 80,160,15,5,02h			;TOP
	DrawArea 235,5,20,150,02h			;RIGHT
	DrawArea 80,160,170,5,02h			;BOTTOM
;	pixlearea	color,x,ancho,y,alto
	;pixelarea 02h,80,20,50,30

;	DrawChar bitArray,row,column
	
	DrawChar K,1,5
	DrawChar R,1,6
	DrawChar A,1,7
	DrawChar K,1,8
	DrawChar E,1,9
	DrawChar N,1,10

	DrawChar N,1,25
	DrawChar ONE,1,26

	DrawChar ZERO,1,35
	DrawChar ZERO,1,36
	DrawChar ZERO,1,37

	DrawChar ZERO,1,55
	DrawChar ZERO,1,56
	DrawChar COLON,1,57
	DrawChar ZERO,1,58
	DrawChar ZERO,1,59
	DrawChar COLON,1,60
	DrawChar ZERO,1,61
	DrawChar THREE,1,62	

	;TIME OF THE SYSTEM
	.while:
	mov ah,2ch
	int 21h
	;mov ah,01h
	;int 16h
	cmp cl,22
	je .EndWhile
	mov dl,dh
	mov dh,0h

	cmp dl,0ah
	jl .Print1


	DecToAscii dx
;	PlotChar row, column, Character
	;mov al,[numberBf]
	;PlotChar 1,61,al
	;mov ah,[numberBf]
	xor di,di
	xor si,si
	xor bx,bx
	xor dx,dx
	PlotChar 1,62,[numberBf+1]
	xor di,di
	xor si,si
	xor bx,bx
	xor dx,dx
	xor ax,ax
	sleep 50h
	;printChar ah
	;mov [seconds],dl
	;print seconds
	;printChar [numberBf]
	;printChar [numberBf+1]
	;print newline
	jmp .Continue
	
	.Print1:
	DecToAscii dx
	;PlotChar 1,61,0h
	mov al,[numberBf]
	PlotChar 1,62,al

	.Continue:
	jmp .while
	.EndWhile:


	readInputChar
	cmp al,1bh		;al = escape (Ascii 1bh)
	je Option4
	jmp Main
Option2:				;GET CURRENT VIDEO MODE
	print newline
	mov ah, 0xf
	int 0x10
	printChar ah
	print newline
	print videoModeMsg

	mov dl,al		;refers to the first parameter to the macro call
	mov ah, 06h		;09h function write string    
    int 21h			;call the interruption

	jmp Main
Option3:
	jmp exit
Option4:				;SET TEXT MODE
	;mov ah,0h
	;mov al,03h
	;int 10h
	setVideoMode 03h
	jmp Main
Option5:				;TEST
	;mov ah,0h
	;mov al,03h
	;int 10h
	;setVideoMode 03h
	print newline
	printChar [indexJ]
	mov si, 0h
	mov [indexJ],si
	printChar [indexJ]
	mov si, 01h
	mov [indexJ],si
	printChar [indexJ]
	mov si, 02h
	mov [indexJ],si
	printChar [indexJ]
	mov si, 03h
	mov [indexJ],si
	printChar [indexJ]
	mov si, 04h
	mov [indexJ],si
	printChar [indexJ]
	mov al,0h
	mov [indexJ],al
	print newline
;	DrawChar bitArray,row,column
	;DrawChar A,2,2
	;PrintArray A
	;print newline
	;print A

	;TIME OF THE SYSTEM
	.while:
	mov ah,2ch
	int 21h
	cmp cl,9
	je .EndWhile
	mov dl,dh
	mov dh,0h
	DecToAscii dx
	;mov [seconds],dl
	;print seconds
	print numberBf
	print newline
	jmp .while
	.EndWhile:

	;mov ax,30
	;mov bh,0ah
	;div bh

	;add ax,30h

	;add al,30h
	;add ah,30h

	;mov [numberBf],ax
	;mov al,'$'
	;mov [numberBf+2],al
	;mov []
;	DecToAscii DecNumberToConvert
	DecToAscii 30
	print numberBf

	print newline
	;xor dx,dx
	;mov ax,320
	;mov bx,64h
	;div bx

	;add al,30h
	;mov [numberBf],al

	;mov ax,dx
	;xor dx,dx
	;mov bx,0ah
	;div bx

	;add ax,30h
	;mov [numberBf+1],ax
	;add dx,30h
	;mov [numberBf+2],dx
	;mov bx,'$'
	;mov [numberBf+3],bx
	DecToAscii 320
	print numberBf
	print newline
	DecToAscii 4
	print numberBf
	print newline
	jmp Main	
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
        db '|   1. Set Video Mode     |', 13, 10
        db '|   2. Get Video Mode     |', 13, 10
        db '|   3. Salir              |', 13, 10
        db '|   4. Set Text Mode      |', 13, 10
        db '|   5. Test               |', 13, 10
        db '|_________________________|',13,10,'$'

userMenu    db '', 13, 10
        db ' _________________________', 13, 10
        db '|_______ CRASH CAR _______|', 13, 10
        db '|   1. Cargar Archivo     |', 13, 10
        db '|   2. Jugar	          |', 13, 10
        db '|   3. Salir              |', 13, 10
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
counter  db 0,'$'
filePath db 50
fileReadBf times 600 db '$'
usersPathFile db 'users.txt',0
fileHandle times 5 db '$'
char db '$$$'
isAdmin db '$$'
numberBf times 5 db '$'


indexI db 0,'$'
indexJ db 0,'$'

hour db 0,'$'
minute db 0,'$'
seconds db 0,'$'

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


;==========================  SECTION .BSS  =================================================|
;uninitialized-data sections                                                                            |
segment .bss
;************************** END SECTION BSS **********************************************
