 org 100h
 ;============= muestra el mensaje inicial ==============
  %macro print 1
  	push ax
  	push dx
 	mov dx, %1
 	mov ah, 09h
 	int 21h
 	pop dx
 	pop ax
 %endmacro

 %macro setvideo 1
 	mov ah, 00h
 	mov al, %1
 	int 10h
 %endmacro

;pintar un pixel
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

  	mov es, word[vga]
  	mov ax, %1
  	mov[es:di], ax

  	pop di
  	pop dx
 	pop bx
 	pop ax
 %endmacro

;pintar un area 
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

 ;dibujar el carro, y agregarle a los lados uncontorno negro
 ;para que la moverce se borre automaticamente
 %macro print_car 1
 	push ax
 	push cx

 	xor cx, cx;
 	mov cl, %1;

; pixlearea color,x,ancho,y,alto
 	pixelarea 0h, cx, 5, 080h, 35
 	add cl, 5
 	pixelarea 0h, cx, 5, 080h, 35
 	pixelarea 7h, cx, 5, 085h, 8
 	pixelarea 7h, cx, 5, 095h, 8 	
 	add cl, 5
 	pixelarea 01h, cx, 20, 080h, 35
 	add cl, 20
 	pixelarea 0h, cx, 5, 080h, 35
 	pixelarea 7h, cx, 5, 085h, 8
 	pixelarea 7h, cx, 5, 095h, 8
 	add cl, 5
 	pixelarea 0h, cx, 5, 080h, 35


 	pop cx
 	pop ax
 %endmacro

; tambien tienen que llevar un controno negro
 %macro print_ob 3
 	push ax
 	push cx

 	pixelarea %1, %2, 10, %3, 10

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

 %macro sleep2 1
 	push si
 	push di

 	mov si, %1
 	%%b1:
 	mov di, %1
 	%%b2:
 	dec di
 	jne %%b2
 	dec si
 	jnz %%b1

 	pop di
 	pop si
 %endmacro

 %macro printchar 3
   	push ax
  	push bx
  	push dx
  	push cx

    mov bh,00h
 	mov dx,%2
 	mov ah,02h 
 	int 10h

 	mov al, %1
 	mov bh, 00h
 	mov bl, 0fh
 	mov ah, 09h
 	mov cx, %3
 	int 10h

 	pop cx
 	pop dx
 	pop bx
 	pop ax
 %endmacro

 %macro getchar 1
 ; devuelve el contenido en ax
  	push bx
  	push dx
  	push cx

    mov bh,00h
 	mov dx,%1
 	mov ah,02h 
 	int 10h

 	mov ah, 08h
 	int 10h

 	pop cx
 	pop dx
 	pop bx
 %endmacro

 %macro printin 2
  	push ax
  	push bx
  	push dx

    mov bh,00h
 	mov dx,%2
 	mov ah,02h 
 	int 10h

 	mov dx, %1
 	mov ah, 09h
 	int 21h

 	pop dx
 	pop bx
 	pop ax
 %endmacro

 menu:
 setvideo 2h
 call clean

 printin mnu, 10ah
 print msg3
 print msg5
 print msg6

 ;=============================== menu ==============================
 mov ah, 01h
 int 21h 
 sub al, 30h
 cmp al, 1h
 je op1
 cmp al, 2h
 je op3
 jmp def

 op1:
 jmp susses
 call clean
 op3:
 mov ah, 4Ch
 int 21h
 def:
 jmp menu 


 ;================================== Juego ================================
 susses:
 setvideo 13h

 pixel 14,160,100
 ; pintar el cuadro verde
;pixlearea color,x,ancho,y,alto
 pixelarea 2h, 0bh, 5h, 10h, 150
 pixelarea 2h, 0bh, 160, 0bh, 5 
 ;pixelarea 1h, 10h, 150, 10h, 150
 pixelarea 2h, 0a6h, 5h, 10h, 150
 pixelarea 2h, 0bh, 160, 0a6h, 5
 mov al, [dir]

 ;pintar inicial mente el carro
 print_car al


 .while:
 ; leer el teclado
 call keystatus
 ; manejar los obstaculos(no programado)
 call obstacles
 ; retarndo general
 sleep 100h
 jmp .while
 jmp menu

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
 je fin
 cmp al, 4bh
 je .movleft
 cmp al, 4dh
 je .movright
 ;segun la tecla que se presiono se elije una accion
 .movleft:
 mov al, [dir]
 sub al, 5h
 ;si sale de los limites del escenario no permite el movimiento
 cmp al, 11h
 jb .return
 mov [dir], al
 print_car al
 jmp .return

 .movright:
 mov al, [dir]
 add al, 5h
 ;lo mismo si sale de los limites nel perro
 cmp al, 07eh
 ja .return
 mov [dir], al
 print_car al
 je .return

 mov al, 01h
 mov [dir], al
 .return:
 ret

 obstacles:
 ; aqui se suponia que iba lo de los obstaculos, pero la cosa no coopera
 .return:
 ret

 ;=================== limpiar pantalla ==================
 clean:
 mov bh, 07h
 mov cx,0000h 
 mov dx,194Fh  
 mov ax,0600h
 int 10h 
 
 mov bh,00h
 mov dx,00h
 mov ah,02h 
 int 10h
 ret

 fin:
 setvideo 2h
 call clean
 mov ah, 4Ch
 int 21h

SEGMENT .data
 dir db 20h,'$'
 mnu db 'MENU',10,'$'
 msg3 db '   1.Jugar',10,'$'  
 msg5 db '   3.Salir',10,'$'  
 charcl db '                           ','$'  
 msg6 db '   >> ','$'
 obs times 100 db '$'
 red db 25, 100, 40, 120, 50
 green db 30, 60,70, 40 , 100
 
 vga dw 0a000h