%macro print 1		;this macro will print to screen    
	mov dx, %1		;refers to the first parameter to the macro call
	mov ah, 09h		;09h function write string    
    int 21h			;call the interruption
%endmacro
 org 100h
 ;============= muestra el mensaje inicial ==============
 menu:
 ;call clean 
 mov dx,msg1
 mov ah, 09h
 int 21h
 mov dx,msg2
 mov ah, 09h
 int 21h
 mov dx,msg3
 mov ah, 09h
 int 21h
 mov dx,msg4
 mov ah, 09h
 int 21h
 mov dx,msg5
 mov ah, 09h
 int 21h
 mov dx,msg6
 mov ah, 09h
 int 21h
 mov dx,msg7
 mov ah, 09h
 int 21h
 mov dx,msg8
 mov ah, 09h
 int 21h
 mov dx,msg9
 mov ah, 09h
 int 21h
 mov dx,msg10
 mov ah, 09h
 int 21h
 mov dx,msg11
 mov ah, 09h
 int 21h
 mov dx,msg12
 mov ah, 09h
 int 21h
 mov dx,msg13
 mov ah, 09h
 int 21h
 mov dx,msg14
 mov ah, 09h
 int 21h

 ;=============================== menu ==============================
 mov ah, 01h
 int 21h 
 sub al, 30h
 cmp al, 1h
 je op1
 cmp al, 2h
 je op2
 cmp al, 3h
 je op3
 jmp def


 op1:
 mov dx,msg15
 mov ah, 09h
 int 21h

 mov ah, 01h                            
 int 21h 
 cmp al, 25h	;lee signo %
 jne rooterror  ;si no es igual salta al estado rooterror
 mov ah, 01h                            
 int 21h 
 cmp al, 25h	;lee el segundo signo %
 jne rooterror 	;si no es igual salta al estado rooterror
 				;si si es igual continua...
 mov si, 0   	;inicializa el registro si con 0                            
 leer:
 mov ah, 01h                            
 int 21h  			;lee caracter despues de verificar %%
 cmp al, 0dh		;compara si es retorno de carro
 je rooterror 		;si es igual salta al estado rooterror
 cmp al, 25h 		;compara si es el primer signo % de cierre
 je segur       	;si es igual salta al estado segur
 mov [root+si], al  ;si no es igual, es por que viene un caracter de id para el archivo                    
 inc si 			;se incrementa el contador para la posicion del arreglo que guarda el root
 jmp leer   		;regresa al loop de lectura 'leer' del nombre de root archivo
 segur:
 mov al, 0			;limpia el registro o agrega el simbolo caracter null
 mov [root+si],al	;agrega el signo null a variable root
 mov al, '$'		;agrega delimitador de fin de cadena a root
 mov [root+si+1],al

 mov ah, 01h        ;lee un caracter                    
 int 21h
 cmp al, 25h		;compara si es el segundo signo % de cierre
 jne rooterror		;si no es igual salta al estado rooterror
;ABRIR ARCHIVO 		;de lo contrario... 
 mov al, 0h			;lee el archivo 000b solo lee
 mov dx, root 		;agrega el segmento de desplazamiento de una cadena Ascii con el nombre del fichero
 mov ah, 3dh		;solicita la interrupcion 3dh abrir fichero
 int 21h			;llama a la interrupcion int 21h
 
 jc error 			;si la bandera carry es 1 error al abrir fichero

;LEER ARCHIVO
 mov bx, ax 		;agrega el handle devuleto por la interrupcion 3dh abrir fichero
 mov cx, 64h 		;numero de bytes a leer
 mov dx, file 		;Segmento: Desplazamiento del buffer donde se depositarán los caracteres leídos
 mov ah, 3fh 		;solicita la interrupcion de lectura de fichero 
 int 21h 			;llama a la interrupcion int 21h
 jmp scaner     	;salta al estado scaner
 op2:
 call createfile

 mov dx, msg16
 mov ah, 09h
 int 21h
 mov ah, 01h
 int 21h 
 jmp menu
 op3:
 mov ah, 4Ch
 int 21h
 def:
 jmp menu 

 ;========================= analicis inicial del archivo ====================== 
 scaner:
 mov si, 0h 		;si para indexar en file
 mov al, 0h 		;contador global de estados
 dfa:
 mov dh, [file+si]

 cmp al, 0h 		;compara si el estado es 0
 je so
 cmp al, 1h 		;compara si el estado es 1
 je s1
 cmp al, 2h 		;compara si el estado es 2
 je s2
 cmp al, 3h 		;compara si el estado es 3
 je s3
 cmp al, 4h 		;compara si el estado es 4
 je s4

 so:
 cmp dh,30h 		;si el caracter es menor a numero 0
 jl filerror
 cmp dh,39h 		;si el caracter es mayor a numero 9
 jg filerror
 mov al, 1h 		;en todo caso cambia al estado 1
 jmp break 			;jump a break donde incrementa si y regresa a dfa
 s1:
 cmp dh, 2ch
 je coma
 cmp dh, 3bh
 je semicolon
 cmp dh,30h 		;si el caracter es menor a numero 0
 jl filerror
 cmp dh,39h 		;si el caracter es mayor a numero 9
 jg filerror
 mov al, 2h
 jmp break
 coma:
 mov al, 0h
 jmp break
 semicolon:
 mov al, 4h
 jmp break
 s2:
 cmp dh, 2ch
 je coma
 cmp dh, 3bh
 je semicolon
 cmp dh,30h 		;si el caracter es menor a numero 0
 jl filerror
 cmp dh,39h 		;si el caracter es mayor a numero 9
 jg filerror
 mov al, 3h
 jmp break
 s3:
 cmp dh, 2ch
 je coma
 cmp dh, 3bh
 je semicolon
 jmp filerror
 s4:
 jmp susses
 break:
 inc si
 jmp dfa

 ;================== mensajes error =====================
 filerror:
 mov [msgse+29], dh
 mov dx, msgse
 mov ah, 09h
 int 21h
 jmp op1

 susses:
 mov dx,msgfs
 mov ah, 09h
 int 21h
 mov ah, 01h
 int 21h 
 jmp llenaroper


 error:
 mov dx,msgfe
 mov ah, 09h
 int 21h
 jmp op1

 rooterror:
 mov dx,msgre
 mov ah, 09h
 int 21h
 jmp op1

 ;=================== limpiar pantalla ==================
 clean:
 mov ax,0600h ; Peticion para limpiar pantalla
 mov bh, 07h; Color de letra ==9 "Azul Claro"
 mov cx,0000h ; Se posiciona el cursor en Ren=0 Col=0
 mov dx,194Fh ; Cursor al final de la pantalla Ren=24(18) 
 int 10h ; INTERRUPCION AL BIOS
 
 mov ah,02h ; Peticion para colocar el cursor
 mov bh,00h
 mov dx,00h; Cursor en la columna 05
 int 10h
 ret

 ;=================== operaciones =====================
 llenaroper:
 mov si, 00h
 mov di, 00h
 llenarop:

 mov dl, [file+si+1]
 cmp dl, 2ch 			;dl = coma -> es un numero de 1 digito
 je digit1
 cmp dl, 3bh
 je digit1
 mov dl, [file+si+2] 	;es un numero de 2 digitos
 cmp dl, 2ch
 je digit2
 cmp dl, 3bh
 je digit2

 mov al,[file+si] 		;numero de 3 digitos
 xor ah, ah 			;limpiar registro ah = 0
 sub ax, 30h 			;restar 30h para volver decimal
 mov cx, 64h 			;multiplicar por 100, para centena
 mul cx

 mov bx, ax 			;mover resultado a bx

 mov al, [file+si+1] 	;obtener las decenas
 xor ah, ah 			;limpiar registro ah = 0
 sub ax, 30h 			;restar 30h para volver decimal
 mov cx, 0ah 			;multiplicar por 10 para decena
 mul cx 				

 add bx, ax 			;sumar el resultado a bx, centena + decena

 mov al, [file+si+2] 	;obtener la unidad
 xor ah, ah 			;limpiar registro ah = 0
 sub ax, 30h 			;restar 30h para volver decimal

 add bx, ax 			;sumar a bx. centena + decena + unidad->numero de 3 digitos

 mov [oper+di], bh      ;
 mov [oper+di+1], bl

 add di,02h 			;se aumenta di dos veces, parte alta y baja.

 mov dl, [file+si+3] 	;si fue un numero de 3 digitos y fue el ultimo numero
 cmp dl, 3bh 			;comparar si la siguiente posicion es ;
 je filled

 add si, 04h 			;si no, sumar 4 caracters 3 ditios y coma. para el siguiente dato
 jmp llenarop 			;regresar al estado llenarop
 digit1: 				;Es un numero de 1 digito

 mov dl,[file+si] 		;se obtiene el digito
 xor dh, dh 			;se limpia dh = 0
 sub dx, 30h 			;se resta 30h para volverlo decimal
 mov [oper+di], dh 		;se copia la parte alta(8 bits superiores)antes
 mov [oper+di+1], dl 	;se copia la parte baja(8 bits inferiores)despues

 add di,02h 			;se aumenta di dos veces, parte alta y baja.

 mov dl, [file+si+1] 	;verifica si es punto y coma. se termino la lista
 cmp dl, 3bh
 je filled 				;saltar a filled, ya se completo el llenado de datos

 add si, 2h 			;si no, sumar 2 caracters 1 digito y coma. para el siguiente dato
 jmp llenarop 			;regresar a llenarop 

 digit2:

 mov al,[file+si] 		;se obtiene el digito 1 decena
 xor ah, ah 			;se limpia ah = 0
 mov bl,[file+si+1]		;se obtiene el digito 2 unidad
 xor bh, bh 			;se limpia bh,bh
 sub bx, 30h 			;se resta 30h a bx para volverlo decimal
 sub ax, 30h 			;se resta 30h a ax para volverlo decimal
 mov cx, 0ah 			;se copia 0ah(10 decimal) a cx
 mul cx 				;se multiplica la decena por 10 al*8bitreg
 add ax, bx 		    ;se suma ax con bx, decena + unidad
 mov [oper+di], ah 		;se copia la parte alta(8 bits superiores)antes
 mov [oper+di+1], al 	;se copia la parte baja(8 bits inferiores)despues

 add di, 02h 			;se aumenta di dos veces, parte alta y baja

 mov dl, [file+si+2] 	;verifica si es punto y coma. se termino la lista
 cmp dl, 3bh 			; dl = ;
 je filled

 add si, 03h 			;si no avanzar 3 posiciones(2 digitos 1 coma) en el arreglo de archivo entrada.
 jmp llenarop 			;regresar a llenarop

 filled:
 ;mov ch, [oper]
 ;mov cl, [oper+1]
 ;call ascii
 mov ax, di
 mov bh, 02h 			;funciona por que al final se suma un 2 lo que hace un numero par siempre
 div bh
 mov [size], al
 call ordenar
 call average 
 call median
 call mode
 call variance
 call dstandadr
 jmp menu

;=================== ASCII ===============
 ascii:
 ;xor ch, ch
 cmp cx, 0ah 			;cx < 10 (1 digito)
 jl a1
 cmp cx, 63h 			;cx > 99 (3 digitos)
 jg a3
 						;cx >10 && cx<100 (2 digitos)
 mov ax, cx 			;copiar cx en ax
 mov bh, 0ah 			;preparar divisor (bh=10)
 div bh 				;dividir ax/bh = al(cociente) ah(residuo)
 add al, 30h 			;sumar al + 30h para convertir a ascii en hexa
 add ah, 30h			;sumar ah + 30h para convertir a ascii en hexa
 mov [number], al
 mov [number+1], ah
 mov bx, '$'
 mov [number+2], bx
 jmp a4
 a1: 					;un numero de 1 digito
 add cx, 30h 			;sumar 30h para pasar a ascii en hexa
 mov [number], cx
 mov bx, '$'
 mov [number+1], bx
 jmp a4
 a3:					;un numero de 3 digitos
 xor dx, dx 			
 xor ax, ax
 mov ax, cx 			;copiar cx en ax
 						;division de 16 bits dx ax / 16 bit divisor
 mov bx, 64h 			;divisor bx =64h=100
 div bx 				;dividir ax/bx =ax(cociente) dx(residuo)
 add ax, 30h  			;sumar 30h para pasar a ascii en hexa
 mov [number], ax

 mov ax, dx
 xor dx, dx
 mov bx, 0ah
 div bx
 add ax, 30h
 mov [number+1], ax
 add dx, 30h
 mov [number+2], dx
 mov bx, '$'
 mov [number+3], bx
 a4:
 ret
;====================END ASCII ===============
 average:
 mov di,0h
 mov si,0h
 xor eax, eax
 sumdata:
 mov ch, [oper+si]
 cmp ch, '$'
 je calcdiv
 xor ebx, ebx
 mov bh, [oper+si]
 mov bl, [oper+si+1]
 add eax, ebx
 inc di
 add si, 02h
 jmp sumdata 
 calcdiv:
 xor edx, edx
 xor ebx, ebx
 mov bx, di
 div ebx
 mov [result], ah
 mov [result+1], al
 ret

 median:
 xor ax, ax
 mov al, [size]
 mov bh, 02h
 div bh
 cmp ah, 00h

 mov cx, 0h
 mov cl,[size]
 mov si, cx

 jne odd

 mov bh, [oper+si]
 mov bl, [oper+si+1]
 sub si, 02h
 mov ah, [oper+si]
 mov al, [oper+si+1]

 xor dx, dx
 add ax, bx
 mov bx, 02h
 div bx
 mov cx, ax
 ;call ascii
 ;mov dx, number
 ;mov ah, 09h
 ;int 21h
 jmp finmedian
 odd:
 xor cx, cx
 sub si, 01h
 mov ch, [oper+si]
 mov cl, [oper+si+1]
 ;call ascii
 ;mov dx, number
 ;mov ah, 09h
 ;int 21h
 finmedian:
 mov [result+2], ch 
 mov [result+3], cl
 ret

 mode:
 mov si, 0h
 mov dh, 0h
 mov cl, 0h
 mov di, 0h
 mode1:
 mov dh, 0h
 mov ch, [oper+si]
 cmp ch, '$'
 je finmode
 mov ah, [oper+si]
 mov al, [oper+si+1]
 mode2:
 mov ch, [oper+si]
 cmp ch, '$'
 je mode1
 mov bh, [oper+si]
 mov bl, [oper+si+1]
 cmp ax, bx
 je  mode3
 cmp cl, dh
 jl sust
 jmp mode1
 sust:
 mov [result+4], ah
 mov [result+5], al
 mov cl, dh
 jmp mode1
 mode3:
 add dh, 02h 
 add si, 02h
 jmp mode2
 finmode:
 mov ch, [result+4]
 mov cl, [result+5]
 call ascii
 mov dx, number
 mov ah, 09h
 ;int 21h
 ret

 variance:
 mov ch, [result]
 mov cl, [result+1]
 call ascii
 mov dx, number
 mov ah, 09h 
 ;int 21h
 mov di,0h
 mov si,0h
 xor ebx, ebx
 sumelevdata:
 mov ch, [oper+si]
 cmp ch, '$'
 je calcelvdiv
 xor eax, eax
 mov ah, [oper+si]
 mov al, [oper+si+1]
 mov dh, [result]
 mov dl, [result+1]
 cmp ax, dx
 jl islower
 sub ax, dx
 jmp makethis
 islower:
 sub dx, ax
 mov ax, dx
 makethis:
 mul ax
 add ebx, eax
 inc di
 add si, 02h
 jmp sumelevdata
 calcelvdiv:
 sub di, 01h
 mov eax, ebx
 xor edx, edx
 xor ebx, ebx 
 mov bx, di
 div ebx
 mov [result+10], ah
 mov [result+11], al
 mov cx,ax
 call dstandadr
 mov ch, [result+10]
 mov cl, [result+11]
 call ascii
 mov dx, number
 mov ah, 09h
 ;int 21h
 ret

 dstandadr:
 mov si, 0h
 sroot:
 mov ax, si
 mul ax
 cmp ax, cx
 jg bigger
 jl smaller 
 je equal
 bigger:
 dec si
 jmp equal 
 smaller:
 inc si
 jmp sroot
 equal:
 mov cx, si
 mov [result+12], ch
 mov [result+13], cl
 call ascii
 mov dx, number
 mov ah, 09h
 ;int 21h
 ret 


 ordenar:
 mov si, 0h
 ord1:
 mov di, 0h
 mov ch, [oper+si]
 cmp ch, '$'
 je finord
 add si, 02h
 ord2:
 mov ch, [oper+di+2]
 cmp ch, '$'
 je ord1
 mov ah, [oper+di]
 mov al, [oper+di+1]
 mov bh, [oper+di+2]
 mov bl, [oper+di+3]
 cmp ax, bx
 jg  change
 add di, 02h
 jmp ord2
 change:
 mov ah, [oper+di]
 mov al, [oper+di+1]
 mov bh, [oper+di+2]
 mov bl, [oper+di+3]
 mov [oper+di], bh
 mov [oper+di+1], bl
 mov [oper+di+2], ah
 mov [oper+di+3], al
 add di, 02h
 jmp ord2
 finord:
 ret

 createfile:
 mov cx, 6h
 mov dx, name
 mov ah , 3ch
 int 21h 
 mov [handle], ax

 mov bx, [handle]
 mov cx, 02h
 mov dx, open
 mov ah, 40h
 int 21h

 mov ah, 2ah
 int 21h

 xor ch, ch
 mov cl, dl
 call ascii
 mov ch, [number]
 mov [fecha+9], ch 
 mov ch, [number+1]
 mov [fecha+10], ch
 mov ah, 2ah
 int 21h
 cmp dh, 09h
 jg fecha1
 xor cx, cx
 mov cl, dh
 call ascii 
 mov ch, 30h
 mov [fecha+12], ch 
 mov ch, [number]
 mov [fecha+13], ch
 jmp fecha2
 fecha1:
 xor cx, cx
 mov cl, dh
 call ascii
 mov ch, [number]
 mov [fecha+12], ch 
 mov ch, [number+1]
 mov [fecha+13], ch

 fecha2:

 mov bx, [handle]
 mov cx, 16h
 mov dx, fecha
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov cx, 16h
 mov dx, carnet
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov cx, 1bh
 mov dx, nombre
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov cx, 0ch
 mov dx, resultado
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov cx, 02h
 mov dx, open
 mov ah, 40h
 int 21h

 mov ah,[result]
 mov al,[result+1]
 cmp ax, 0ah
 jl mediap1
 cmp ax, 63h
 jg mediap2
 mov ch, [result]
 mov cl, [result+1]
 call ascii
 mov ah, [number]
 mov [media+10], ah
 mov ah, [number+1]
 mov [media+11], ah
 jmp mediap3
 mediap1:
 mov ch, [result]
 mov cl, [result+1]
 call ascii
 mov ah, [number]
 mov [media+11], ah
 jmp mediap3
 mediap2:
 mov ch, [result]
 mov cl, [result+1]
 call ascii
 mov ah, [number]
 mov [media+9], ah
 mov ah, [number+1]
 mov [media+10], ah
 mov ah, [number+2]
 mov [media+11], ah
 mediap3:
 mov bx, [handle]
 mov cx, 0Fh
 mov dx, media
 mov ah, 40h
 int 21h


 mov ah,[result+2]
 mov al,[result+3]
 cmp ax, 0ah
 jl medianap1
 cmp ax, 63h
 jg medianap2
 mov ch, [result+2]
 mov cl, [result+3]
 call ascii
 mov ah, [number]
 mov [mediana+12], ah
 mov ah, [number+1]
 mov [mediana+13], ah
 jmp medianap3
 medianap1:
 mov ch, [result+2]
 mov cl, [result+3]
 call ascii
 mov ah, [number]
 mov [mediana+13], ah
 jmp medianap3
 medianap2:
 mov ch, [result+2]
 mov cl, [result+3]
 call ascii
 mov ah, [number]
 mov [mediana+11], ah
 mov ah, [number+1]
 mov [mediana+12], ah
 mov ah, [number+2]
 mov [mediana+13], ah
 medianap3:
 mov bx, [handle]
 mov cx, 11h
 mov dx, mediana
 mov ah, 40h
 int 21h

 mov ah,[result+4]
 mov al,[result+5]
 cmp ax, 0ah
 jl modap1
 cmp ax, 63h
 jg modap2

 mov ch, [result+4]
 mov cl, [result+5]
 call ascii
 mov ah, [number]
 mov [moda+9], ah
 mov ah, [number+1]
 mov [moda+10], ah
 jmp modap3
 modap1:
 mov ch, [result+4]
 mov cl, [result+5]
 call ascii
 mov ah, [number]
 mov [moda+10], ah
 jmp modap3
 modap2:
 mov ch, [result+4]
 mov cl, [result+5]
 call ascii
 mov ah, [number]
 mov [moda+8], ah
 mov ah, [number+1]
 mov [moda+9], ah
 mov ah, [number+2]
 mov [moda+10], ah
 modap3:
 mov bx, [handle]
 mov cx, 0eh
 mov dx, moda
 mov ah, 40h
 int 21h

 mov al, [size]
 xor ah, ah
 mov bx, 02h
 mul bx
 sub ax, 02h
 mov si, ax

 mov ah,[oper+si]
 mov al,[oper+si+1]
 cmp ax, 0ah
 jl maxp1
 cmp ax, 63h
 jg maxp2
 mov ch, [oper+si]
 mov cl, [oper+si+1]
 call ascii
 mov ah, [number]
 mov [maximo+11], ah
 mov ah, [number+1]
 mov [maximo+12], ah
 jmp maxp3
 maxp1:
 mov ch, [oper+si]
 mov cl, [oper+si+1]
 call ascii
 mov ah, [number]
 mov [maximo+12], ah
 jmp maxp3
 maxp2:
 mov ch, [oper+si]
 mov cl, [oper+si+1]
 call ascii
 mov ah, [number]
 mov [maximo+10], ah
 mov ah, [number+1]
 mov [maximo+11], ah
 mov ah, [number+2]
 mov [maximo+12], ah
 maxp3:
 mov bx, [handle]
 mov cx, 10h
 mov dx, maximo
 mov ah, 40h
 int 21h

 mov ah,[oper]
 mov al,[oper+1]
 cmp ax, 0ah
 jl minp1
 cmp ax, 63h
 jg minp2

 mov ch, [oper]
 mov cl, [oper+1]
 call ascii
 mov ah, [number]
 mov [minimo+11], ah
 mov ah, [number+1]
 mov [minimo+12], ah
 jmp minp3
 minp1:
 mov ch, [oper]
 mov cl, [oper+1]
 call ascii
 mov ah, [number]
 mov [minimo+12], ah
 jmp minp3
 minp2:
 mov ch, [oper]
 mov cl, [oper+1]
 call ascii
 mov ah, [number]
 mov [minimo+10], ah
 mov ah, [number+1]
 mov [minimo+11], ah
 mov ah, [number+2]
 mov [minimo+12], ah
 minp3:
 mov bx, [handle]
 mov cx, 10h
 mov dx, minimo
 mov ah, 40h
 int 21h

 mov ah,[result+10]
 mov al,[result+11]
 cmp ax, 0ah
 jl varianp1
 cmp ax, 63h
 jg varianp2

 mov ch, [result+10]
 mov cl, [result+11]
 call ascii
 mov ah, [number]
 mov [varianza+13], ah
 mov ah, [number+1]
 mov [varianza+14], ah
 jmp varianp3
 varianp1:
 mov ch, [result+10]
 mov cl, [result+11]
 call ascii
 mov ah, [number]
 mov [varianza+14], ah
 jmp varianp3
 varianp2:
 mov ch, [result+10]
 mov cl, [result+11]
 call ascii
 mov ah, [number]
 mov [varianza+12], ah
 mov ah, [number+1]
 mov [varianza+13], ah
 mov ah, [number+2]
 mov [varianza+14], ah
 varianp3:
 mov bx, [handle]
 mov cx, 12h
 mov dx, varianza
 mov ah, 40h
 int 21h

 mov ah,[result+12]
 mov al,[result+13]
 cmp ax, 0ah
 jl desp1
 cmp ax, 63h
 jg desp2

 mov ch, [result+12]
 mov cl, [result+13]
 call ascii
 mov ah, [number]
 mov [desviacion+15], ah
 mov ah, [number+1]
 mov [desviacion+16], ah
 jmp desp3
 desp1:
 mov ch, [result+12]
 mov cl, [result+13]
 call ascii
 mov ah, [number]
 mov [desviacion+16], ah
 jmp desp3
 desp2:
 mov ch, [result+12]
 mov cl, [result+13]
 call ascii
 mov ah, [number]
 mov [desviacion+14], ah
 mov ah, [number+1]
 mov [desviacion+15], ah
 mov ah, [number+2]
 mov [desviacion+16], ah
 desp3:
 mov bx, [handle]
 mov cx, 13h
 mov dx, desviacion
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov cx, 01h
 mov dx, close
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov cx, 01h
 mov dx, close
 mov ah, 40h
 int 21h

 mov bx, [handle]
 mov ah, 3eh
 int 21h

 ret

 fin:
 mov ah, 4Ch
 int 21h

 size db 2
 handle db 1
 result times 16 db '$'
 name db 'rep.txt', 0, '$'
 open db '{',10
 close db '}'
 fecha db '"Fecha":"  /  /2018",',10
 carnet db '"Carnet":"201513744",',10
 nombre db '"Nombre":"Edwin Pernilla",',10
 mediana db '"Mediana":"   ",',10
 media db '"Media":"   ",',10
 moda db '"Moda":"   ",',10
 maximo db '"Maximo":"   ",',10
 minimo db '"Minimo":"   ",',10
 varianza db '"Varianza":"   ",',10
 desviacion db '"Desviacion":"   "',10
 resultado db '"Resultado":'
 msg1 db 10,'Universidad de San Carlos de Guatemala', 10,'$'          ;mensaje a desplegar
 msg2 db 'Facultad de Ingenieria', 10,'$'          ;mensaje a desplegar
 msg3 db 'Escuela de Ciencias y Sistemas', 10,'$'          ;mensaje a desplegar
 msg4 db 'Arquitectura de Computadores y Ensambladores 1',10,'$'          ;mensaje a desplegar
 msg5 db 'Segundo Semestre 2018', 10,'$'          ;mensaje a desplegar
 msg6 db 'Edwin Efrain Pernilla Perez', 10,'$'          ;mensaje a desplegar
 msg7 db '201513744', 10,'$'      
 msg8 db 'Practica 2', 10,'$'          ;mensaje a desplegar
 msg9 db '******************************', 10,'$'
 msg10 db '***** 1.Cargar Archivo  ******', 10,'$' 
 msg11 db '***** 2.Crear Reporte   ******', 10,'$' 
 msg12 db '***** 3.Salir           ******', 10,'$' 
 msg13 db '******************************', 10,'$'  
 msg14 db '>>  ','$'          ;mensaje a desplegar  
 msg15 db 10,'Ingrese la ruta: ',10,'$'
 msg16 db 10,'Reporte Creado, presione cualquier tecla', 10,'$'
 msgre db 10,'Erro en la ruta intente de nuevo', 10,'$'
 msgfe db 10,'Erro archivo no encontrado', 10,'$'
 msgse db 10,'Error caracter no esperado:  ', 10,'$'
 msgfs db 10,'archivo cargado con exito, presione cualquier tecla', 10,'$'
 number db 5
 data times 100 db '$'      
 file times 100 db '$'
 oper times 100 db '$'
 root db 50