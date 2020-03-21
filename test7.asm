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
	push si
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

	pop si
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
	

	%%PaintBlack:
	;push di
	;push si
	;push cx
	;push bx

	;mov al,%1 				;row
	;mov dl,5
	;mul dl

	;add di, ax

	;mov al,[%2]				;col
	;mov dl,4
	;mul dl

	;add si,ax

	;plotPixel 00h,si,di 		;plotPixel color,x,y
	;pop bx
	;pop cx
	;pop si
	;pop di
	;jmp %%Next

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
	
	jmp Main
;================================= OPTION 2 - 4 ===========================
Option2:
	print esDos
	
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
	jmp Main

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

readInputChar
jmp Main





exit:
 mov ah, 4ch
 int 21h
;nasm -f bin prc6.asm -o prc6.com
;prc6
;************************* END SECTION TEXT ********************************************************