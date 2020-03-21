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
 	mov bl, 07h
 	mov ah, 09h
 	mov cx, %3
 	int 10h

 	pop cx
 	pop dx
 	pop bx
 	pop ax
 %endmacro

 %macro pixel 3
 	push ax
  	push bx
  	push dx
  	push di

  	mov ax, %3         ;ax = Posicion y
  	mov bx, 140h       ;Decimal 320
  	mul bx             ;ax = y*320 = ax * 320

  	add ax, %2         ;Punto(x,y) = x + y(320) = 
  	mov di, ax

  	mov es, word[vga]
  	mov ax, %1
  	mov[es:di], ax

  	pop di
  	pop dx
 	pop bx
 	pop ax
 %endmacro

 %macro pixelarea2 5
 	push ax
  	push bx
  	push si
  	push di

  	xor di, di
  	xor si, si
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

 %macro pixelarea 5
 	push ax
  	push bx
  	push si
  	push di

  	mov si, %2         ;copia pos x
  	mov bx, si
  	add bx, %3         ;suma largo en x
  	%%x:
  	cmp si, bx
  	je %%finx
  	mov di, %4         ;copia pos y
  	mov ax, di
  	add ax, %5         ;suma largo de y
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

 %macro fprint 3
 	mov bh, [%2]
 	mov bl, [%2+1]
 	mov cx, %3
 	mov dx, %1
 	mov ah, 40h
 	int 21h
 %endmacro

 %macro closefile 1
 	mov bh, [%1]
 	mov bl, [%1+1]
 	mov ah, 3eh
 	int 21h
 %endmacro

 %macro newfile 2
 	mov cx, 00
 	mov dx, %1
 	mov ah , 3ch
 	int 21h 
 	mov [%2], ah
 	mov [%2+1],al
 %endmacro

 %macro ascii 2
 	mov ax, %1
 	mov bx, 0ah
 	xor si, si
 	%%while:
 	xor dx, dx
 	div bx
 	add dx, 30h
 	mov [%2+si], dl
 	inc si
 	cmp ax, 0h
 	jne %%while
 	mov al, '$'
 	mov [%2+si], al 
 %endmacro
 
 %macro setchar 2
 	mov ah, %1
 	mov [%2], ah
 	mov ah, 0ah
 	mov [%2+1], ah
 %endmacro

;macro que pinta el dino
 %macro printdino 3
 	push ax
 	push cx
 	xor cx, cx
 	mov cl, %3
 	add cl, 7
 	pixel %2, 60, cx
 	mov cl, %3
 	add cl, 8
 	pixelarea %1, 60, 1, cx, 7
 	mov cl, %3
 	add cl, 15
 	pixel %2, 60, cx
 	mov cl, %3
 	add cl, 10
 	pixel %2, 61, cx
 	mov cl, %3
 	add cl, 11	
 	pixelarea %1, 61, 1, cx, 5
 	mov cl, %3
 	add cl, 16
 	pixel %2, 61, cx
 	mov cl, %3
 	add cl, 11
 	pixel %2, 62, cx
 	mov cl, %3
 	add cl, 12
 	pixelarea %1, 62, 1, cx, 5
 	mov cl, %3
 	add cl, 17
 	pixel %2, 62, cx
 	mov cl, %3
 	add cl, 12
 	pixelarea %2, 63, 2, cx, 1
 	mov cl, %3
 	add cl, 13
 	pixelarea %1, 63, 1, cx, 5
 	mov cl, %3
 	add cl, 18
 	pixel %2, 63, cx
 	mov cl, %3
 	add cl, 13
 	pixelarea %1, 64, 1, cx, 6
 	mov cl, %3
 	add cl, 19
 	pixel %2, 64, cx
 	mov cl, %3
 	add cl, 11
 	pixel %2, 65, cx
 	mov cl, %3
 	add cl, 12
 	pixelarea %1, 65, 1, cx, 8
 	mov cl, %3
 	add cl, 20
 	pixel %2, 65, cx
 	mov cl, %3
 	add cl, 10
 	pixelarea %2, 66, 2, cx, 1
 	mov cl, %3
 	add cl, 11
 	pixelarea %1, 66, 1, cx, 13
 	mov cl, %3
 	add cl, 11
 	pixelarea %1, 67, 1, cx, 13
 	mov cl, %3
 	add cl, 22
 	pixel %2, 67, cx
 	mov cl, %3
 	add cl, 24
 	pixelarea %2, 66, 2, cx, 1
 	mov cl, %3
 	add cl, 9
 	pixelarea %2, 68, 2, cx, 1
 	mov cl, %3
 	add cl, 10
 	pixelarea %1, 68, 1, cx, 11
 	mov cl, %3
 	add cl, 21
 	pixel %2, 68, cx
 	mov cl, %3
 	add cl, 10
 	pixelarea %1, 69, 1, cx, 10
 	mov cl, %3
 	add cl, 20
 	pixel %2, 69, cx
 	mov cl, %3
 	add cl, 8
 	pixel %2, 70, cx
 	mov cl, %3
 	add cl, 9
 	pixelarea %1, 70, 1, cx, 12
 	mov cl, %3
 	add cl, 21
 	pixel %2, 70, cx
 	mov cl, %3
 	add cl, 1
 	pixelarea %1, 71, 1, cx, 23
 	mov cl, %3
 	add cl, 23
 	pixel %1, 72, cx
 	mov cl, %3
 	add cl, 24
 	pixelarea %2, 71, 2, cx, 1
 	mov cl, %3
 	add cl, 1
 	pixelarea %1, 72, 1, cx, 18
 	mov cl, %3
 	add cl, 19
 	pixel %2, 72, cx
 	mov cl, %3
 	add cl, 1
 	pixelarea %1, 73, 1, cx, 17
 	mov cl, %3
 	add cl, 18
 	pixel %2, 73, cx
 	mov cl, %3
 	add cl, 2
 	pixel %2, 73, cx
 	mov cl, %3
 	add cl, 1
 	pixelarea %1, 74, 1, cx, 15
 	mov cl, %3
 	add cl, 1
 	pixelarea %1, 75, 1, cx, 7
 	mov cl, %3
 	add cl, 16
 	pixel %2, 74, cx
 	mov cl, %3
 	add cl, 12
 	pixel %2, 75, cx
 	mov cl, %3
 	add cl, 13
 	pixel %2, 76, cx
 	mov cl, %3
 	add cl, 11
 	pixelarea %1, 75, 2, cx, 1
 	mov cl, %3
 	add cl, 12
 	pixel %1, 76, cx
 	mov cl, %3
 	add cl, 1
 	pixelarea %1, 76, 6, cx, 5
 	mov cl, %3
 	add cl, 7
 	pixelarea %1, 76, 4, cx, 1
 	mov cl, %3
 	pixelarea %2, 71, 11, cx, 1
 	mov cl, %3
 	add cl, 6
 	pixelarea %2, 76, 6, cx, 1
 	mov cl, %3
 	add cl, 8
 	pixelarea %2, 75, 5, cx, 1
 	mov cl, %3
 	add cl, 22
 	pixel %2, 72, cx
 	mov cl, %3
 	add cl, 10
 	pixelarea %2, 75, 2, cx, 1

 	pop cx
 	pop ax
 %endmacro

 %macro dinohead 2
 	push cx
 	push ax
 	xor ch, ch
 	mov cl, %2
 	add cl, 1
 	pixelarea %1, 71, 11, cx, 5
 	mov cl, %2
 	add cl, 7
 	pixelarea %1, 71, 9, cx, 1
 	mov cl, %2
 	add cl, 6
 	pixelarea %1, 71, 5, cx, 1
 	mov cl, %2
 	add cl, 8
 	pixelarea %1, 71, 4, cx, 1
 	mov cl, %2
 	add cl, 2h
 	pixelarea %1, 72, 2, cx, 2
 	pop cx
 	pop ax
 %endmacro

 %macro printobs 2
 	push bx
 	mov bx, %2
 	pixelarea %1, bx, 2, 71, 8
 	add bx, 2h
 	pixelarea %1, bx, 1, 77, 2
 	add bx, 1h
 	pixelarea %1, bx, 3, 68, 18
 	add bx, 3h
 	pixelarea %1, bx, 1, 74, 2
 	add bx, 1h
 	pixelarea %1, bx, 2, 69, 7
 	pop bx
 %endmacro

 %macro printobs2 2
 	push bx
 	mov bx, %2
 	pixelarea %1, bx, 1, 63, 1
 	add bx, 1h
 	pixelarea %1, bx, 3, 62, 3
 	add bx, 1h
 	pixelarea %1, bx, 1, 61, 1
 	pixelarea %1, bx, 1, 65, 1
 	add bx, 2h
 	pixelarea %1, bx, 1, 63, 1
 	add bx, 2h
 	pixelarea %1, bx, 2, 62, 1
 	pixelarea %1, bx, 3, 63, 1
 	pixelarea %1, bx, 2, 64, 1
 	pop bx
 %endmacro

 mov al, 'a'
 mov [users], al
 mov al, 'd'
 mov [users+1], al
 mov al, 'm'
 mov [users+2], al
 mov al, 'i'
 mov [users+3], al
 mov al, 'n'
 mov [users+4], al
 mov al, '$'
 mov [users+5], al

 mov al, '1'
 mov [passwords], al
 mov al, '2'
 mov [passwords+1], al
 mov al, '3'
 mov [passwords+2], al
 mov al, '4'
 mov [passwords+3], al
 mov al, '$'
 mov [passwords+4], al
 mov ax, 10h
 mov [size], ah
 mov [size+1], al

 menu:
 setvideo 2h
 call clean 
 printin mnu, 10ah
 print msg3
 print msg4
 print msg5
 print msg6

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
 call clean
 printin login, 10ah
 leer_user:
 print msg1
 mov si, 0h
 .read:
 cmp si, 0eh
 je .finloop
 mov ah, 01h
 int 21h
 cmp al, 0dh
 je .finloop
 mov [buffer+si], al
 inc si
 jmp .read
 .finloop:
 cmp si, 04h
 jg .salir
 print msgfe
 jmp leer_user
 .salir:
 mov al, '$'
 mov [buffer+si], al

 mov si, 0h
 mov di, 0h
 mov bp, 0h
 mov ax, 0h
 search_user:
 cmp al, '$'
 je .salir
 cmp si, 640h
 je .salir
 mov al, [buffer+bp]
 mov ah, [users+si]
 inc si
 inc bp
 cmp al, ah
 je search_user
 mov bp, 0h
 add di, 10h
 mov si, di
 mov ah, [users+si]
 cmp ah, '$'
 je .unexist
 jmp search_user
 .unexist:
 print msg16
 jmp leer_user
 .salir:
 
 mov cx, 0h
 mov al, [buffer]
 cmp al, 'a'
 jne leer_pass
 mov al, [buffer+1]
 cmp al, 'd'
 jne leer_pass
 mov al, [buffer+2]
 cmp al, 'm'
 jne leer_pass
 mov al, [buffer+3]
 cmp al, 'i'
 jne leer_pass
 mov al, [buffer+4]
 cmp al, 'n'
 jne leer_pass
 mov al, [buffer+5]
 cmp al, '$'
 jne leer_pass
 mov cx, 01h

 leer_pass:
 print msg2
 mov si, 0h
 .read:
 cmp si, 0eh
 je .finloop
 mov ah, 01h
 int 21h
 cmp al, 0dh
 je .finloop
 cmp al, 30h
 jl .errornum
 cmp al, 39h
 jg .errornum
 mov [buffer+si], al
 inc si
 jmp .read
 .errornum:
 print msgse
 jmp leer_pass
 .finloop:
 cmp si, 03h
 jg .salir
 print msgre
 jmp leer_pass
 .salir:
 mov al, '$'
 mov [buffer+si], al

 push di
 mov si, di
 mov bp, 0h
 mov ax, 0h
 add di, 10h
 search_pass:
 cmp al, '$'
 je .salir
 cmp si, di
 je .unexist
 mov al, [buffer+bp]
 mov ah, [passwords+si]
 inc si
 inc bp
 cmp al, ah
 je search_pass
 .unexist:
 pop di
 print msg17
 jmp leer_pass
 .salir:
 pop di

 mov dx, di
 mov [pospoin], dh
 mov [pospoin+1], dl
 cmp cx, 01h
 jne susses
 call createfile
 jmp menu

 op2:
 call clean
 printin logup, 10h
 leer_user1:
 print msg1
 mov si, 0h
 .read:
 cmp si, 0fh
 je .finloop
 mov ah, 01h
 int 21h
 cmp al, 0dh
 je .finloop
 mov [buffer+si], al
 inc si
 jmp .read
 .finloop:
 cmp si, 04h
 jg .salir
 print msgfe
 jmp leer_user1
 .salir:
 mov al, '$'
 mov [buffer+si], al

 mov si, 0h
 mov di, 0h
 mov bp, 0h
 mov ax, 0h
 search_user1:
 cmp al, '$'
 je .exist
 mov al, [buffer+bp]
 mov ah, [users+si]
 inc si
 inc bp
 cmp al, ah
 je search_user1
 mov bp, 0h
 add di, 10h
 mov si, di
 mov ah, [users+si]
 cmp ah, '$'
 je .save
 jmp search_user1
 .exist:
 print msg16
 jmp leer_user1
 .save:
 mov di, 0h
 mov ah, [size]
 mov al, [size+1]
 mov si, ax
 add ax, 0fh
 .while:
 cmp si, ax
 je .salir
 mov bl, [buffer+di]
 mov [users+si], bl
 inc di
 inc si
 jmp .while
 .salir:

 leer_pass1:
 print msg2
 mov si, 0h
 .read:
 cmp si, 0fh
 je .finloop
 mov ah, 01h
 int 21h
 cmp al, 0dh
 je .finloop
 cmp al, 30h
 jl .errornum
 cmp al, 39h
 jg .errornum
 mov [buffer+si], al
 inc si
 jmp .read
 .errornum:
 print msgse
 jmp leer_pass
 .finloop:
 cmp si, 04h
 jg .salir
 print msgre
 jmp leer_pass1
 .salir:
 mov al, '$'
 mov [buffer+si], al

 save_pass:
 mov di, 0h
 mov ah, [size]
 mov al, [size+1]
 mov si, ax
 add ax, 0fh
 .while:
 cmp si, ax
 je .salir
 mov bl, [buffer+di]
 mov [passwords+si], bl
 inc di
 inc si
 jmp .while
 .salir:
 mov ah, [size]
 mov al, [size+1]
 add ax, 10h
 mov [size], ah
 mov [size+1], al

 jmp menu
 op3:
 mov ah, 4Ch
 int 21h
 def:
 jmp menu 


 ;=========================== |JUEGO| =====================
 susses:
 setvideo 13h
 printin n1, 10h
 printdino 0ah, 0h, 3eh
 mov bl, 01h
 mov [nvl], bl
 mov bl, 3eh
 mov bh, 0h

 .while: 
 cmp bh, 0h
 jne .while1
 call keystatus
 .while1:
 call movdin
 call isdead
 mov dl, [nvl]
 cmp dl, 1h
 je .nivel1
 cmp dl, 2h
 je .nivel2
 cmp dl, 3h
 je .nivel3
 printin cct, 1210h
 sleep2 900h
 jmp fin
 .nivel1:
 call nivel1
 jmp .while
 .nivel2:
 call nivel2
 jmp .while
 .nivel3:
 call nivel3
 jmp .while

 addpoints:
 mov dh, [pospoin]
 mov dl, [pospoin+1]
 mov ax, dx
 mov cx, 16
 div cx
 mov cx, 5
 mul cx
 mov bp, ax
 mov cx, [points+3]
 cmp cx, 57
 mov cx, [points+2]
 cmp cx, 57
 mov cx, [points+1]
 cmp cx, 57
 .return:
 ret

 keystatus:
 mov ah, 01h
 int 16h
 je .return
 .keypress:
 mov ah, 08h
 int 21h
 mov ah, 08h
 int 21h
 cmp al, 1bh
 je fin
 cmp al, 48h
 je up
 cmp al, 50h
 je down
 .return:
 ret

 up:
 mov ah, [dn]
 cmp ah, 2h
 jne .jump
 mov ah, 1h
 mov [dn], ah
 dinohead 0h, 70
 printdino 0ah, 0h, 3eh
 jmp keystatus.return
 .jump:
 mov bh, 1h 
 jmp keystatus.return

 down:
 mov ah, 2h
 mov [dn], ah
 dinohead 0h, 62
 dinohead 0ah, 70
 jmp keystatus.return

 movdin:
 cmp bh, 0h
 je .return1
 cmp bh, 1h
 je .case1
 cmp bl, 3fh
 je .ground
 printdino 0ah, 0h, bl
 inc bl
 jmp .return
 .ground:
 mov bh, 0h
 jmp .return
 .case1:
 cmp bl, 1ah
 je .down
 printdino 0ah, 0h, bl
 dec bl
 jmp .return
 .down:
 mov bh, 02h
 .return1:
 sleep2 3ah
 .return:
 ret

 nivel1:
 sleep2 80h
 mov bp, 0h
 .for:
 mov ah, [Nivel1+bp]
 mov dh, [Nivel1+bp+1]
 mov dl, [Nivel1+bp+2]
 cmp ah, 01h
 jne .obs2
 cmp dx, 20
 je .erase
 cmp dx, 300
 jg .subs
 printobs 0ah, dx
 .subs:
 dec dx
 mov [Nivel1+bp+1], dh
 mov [Nivel1+bp+2], dl
 jmp .comp
 .erase:
 printobs 0h, dx
 jmp .comp

 .obs2:
 cmp dx, 20
 je .erase1
 cmp dx, 300
 jg .subs1
 printobs2 0ah, dx
 .subs1:
 dec dx
 mov [Nivel1+bp+1], dh
 mov [Nivel1+bp+2], dl
 jmp .comp
 .erase1:
 printobs2 0h, dx 
 .comp:
 add bp, 03h
 cmp bp, 0fh
 jne .for
 mov dh, [Nivel1+13]
 mov dl, [Nivel1+14]
 cmp dx, 20
 jne .return
 mov dl, 2h
 mov [nvl], dl
 printobs2 0h, 20
 printin n2, 10h 
 .return:
 pixelarea 07h, 0, 250, 86, 1;color,posX,largo linea, posY,ancho/grosor linea
 ret

 nivel2:
 sleep2 50h
 mov bp, 0h
 .for:
 mov ah, [Nivel2+bp]
 mov dh, [Nivel2+bp+1]
 mov dl, [Nivel2+bp+2]

 cmp ah, 01h
 jne .obs2
 cmp dx, 20
 je .erase
 cmp dx, 300
 jg .subs
 printobs 0ah, dx
 .subs:
 dec dx
 mov [Nivel2+bp+1], dh
 mov [Nivel2+bp+2], dl
 jmp .comp
 .erase:
 printobs 0h, dx
 jmp .comp

 .obs2:
 cmp dx, 20
 je .erase1
 cmp dx, 300
 jg .subs1
 printobs2 0ah, dx
 .subs1:
 dec dx
 mov [Nivel2+bp+1], dh
 mov [Nivel2+bp+2], dl
 jmp .comp
 .erase1:
 printobs2 0h, dx
 .comp:
 add bp, 03h
 cmp bp, 12h
 jne .for
 mov dh, [Nivel2+16]
 mov dl, [Nivel2+17]
 cmp dx, 20
 jne .return
 mov dl, 3h
 mov [nvl], dl 
 printobs 0h, 20
 printin n3, 10h
 .return:
 pixelarea 0ah, 0, 320, 86, 1
 ret

 nivel3:
 sleep2 20h
 mov bp, 0h
 .for:
 mov ah, [Nivel3+bp]
 mov dh, [Nivel3+bp+1]
 mov dl, [Nivel3+bp+2]

 cmp ah, 01h
 jne .obs2
 cmp dx, 20
 je .erase
 cmp dx, 300
 jg .subs
 printobs 0ah, dx
 .subs:
 dec dx
 mov [Nivel3+bp+1], dh
 mov [Nivel3+bp+2], dl
 jmp .comp
 .erase:
 printobs 0h, dx
 jmp .comp

 .obs2:
 cmp dx, 20
 je .erase1
 cmp dx, 300
 jg .subs1
 printobs2 0ah, dx
 .subs1:
 dec dx
 mov [Nivel3+bp+1], dh
 mov [Nivel3+bp+2], dl
 jmp .comp
 .erase1:
 printobs2 0h, dx 
 .comp:
 add bp, 03h
 cmp bp, 15h
 jne .for
 mov dh, [Nivel3+19]
 mov dl, [Nivel3+20]
 cmp dx, 20
 jne .return
 mov dl, 4h
 mov [nvl], dl
 printobs 0h, 20
 .return:
 pixelarea 0ah, 0, 320, 86, 1
 ret

 isdead:
 mov dl, [nvl]
 cmp dl, 01h
 je level1
 cmp dl, 02h
 je level2
 cmp dl, 03h
 je level3
 jmp level3.return
 level1:
 mov bp, 0h
 .for1:
 mov ah, [Nivel1+bp]
 mov dh, [Nivel1+bp+1]
 mov dl, [Nivel1+bp+2]
 cmp ah, 1h
 jne .obs2
 cmp dx, 74
 jg .compare
 cmp dx, 58
 jl .compare
 cmp bl, 45
 jl .compare
 printin tlc, 1210h
 sleep2 900h
 jmp fin
 .obs2:
 mov dl, [dn]
 cmp dl, 2h
 je .compare
 mov dh, [Nivel1+bp+1]
 mov dl, [Nivel1+bp+2]
 cmp dx, 74
 jg .compare
 cmp dx, 66
 jl .compare
 cmp bl, 24
 jl .compare
 printin tlc, 1210h
 sleep2 900h
 jmp fin
 .compare:
 add bp, 03h
 cmp bp, 0fh
 jne .for1 
 jmp level3.return

 level2:
 mov bp, 0h
 .for2:
 mov ah, [Nivel2+bp]
 mov dh, [Nivel2+bp+1]
 mov dl, [Nivel2+bp+2]
 cmp ah, 1h
 jne .obs2
 cmp dx, 74
 jg .compare
 cmp dx, 58
 jl .compare
 cmp bl, 45
 jl .compare
 printin tlc, 1210h
 sleep2 900h
 jmp fin
 .obs2:
 mov dl, [dn]
 cmp dl, 2h
 je .compare
 mov dh, [Nivel2+bp+1]
 mov dl, [Nivel2+bp+2]
 cmp dx, 74
 jg .compare
 cmp dx, 66
 jl .compare
 cmp bl, 24
 jl .compare
 printin tlc, 1210h
 sleep2 900h
 jmp fin
 .compare:
 add bp, 03h
 cmp bp, 12h
 jne .for2
 jmp level3.return

 level3:
 mov bp, 0h
 .for3:
 mov ah, [Nivel3+bp]
 mov dh, [Nivel3+bp+1]
 mov dl, [Nivel3+bp+2]
 cmp ah, 1h
 jne .obs2
 cmp dx, 74
 jg .compare
 cmp dx, 58
 jl .compare
 cmp bl, 45
 jl .compare
 printin tlc, 1210h
 sleep2 900h
 jmp fin
 .obs2:
 mov dl, [dn]
 cmp dl, 2h
 je .compare
 mov dh, [Nivel3+bp+1]
 mov dl, [Nivel3+bp+2]
 cmp dx, 74
 jg .compare
 cmp dx, 66
 jl .compare
 cmp bl, 24
 jl .compare
 printin tlc, 1210h
 sleep2 900h
 jmp fin
 .compare:
 add bp, 03h
 cmp bp, 15h
 jne .for3
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

 ;=================== reporte =====================
 createfile:
 newfile name, handle
 fprint open, handle, 01h
 fprint sm, handle, 0bh
 setchar 91, char
 fprint char, handle, 2h
 mov si, 10h
 .for:
 mov ah, [size]
 mov al, [size+1]
 cmp si, ax
 je .salir
 fprint open, handle, 01h
 mov di, si
 mov ah, [size]
 mov al, [size+1]
 fprint tuc, handle, 07h
 setchar 34, char
 fprint char, handle, 1h
 .for2:
 mov bl, [users+di]
 cmp bl, '$'
 je .finfor2
 setchar bl, char
 fprint char, handle, 1h
 inc di
 jmp .for2
 .finfor2:
 setchar 34, char
 fprint char, handle, 1h
 setchar 44, char
 fprint char, handle, 1h
 setchar 10, char
 fprint char, handle, 1h
 fprint tcp, handle, 0bh
 mov di, si
 .for3:
 mov bl, [passwords+di]
 cmp bl, '$'
 je .finfor3
 setchar bl, char
 fprint char, handle, 1h
 inc di
 jmp .for3
 .finfor3:
 add si, 10h
 fprint close, handle, 01h
 mov ah, [size]
 mov al, [size+1]
 cmp ax, si
 je .for
 setchar 44, char
 fprint char, handle, 1h
 setchar 10, char
 fprint char, handle, 1h
 jmp .for
 .salir:
 setchar 93, char
 fprint char, handle, 2h
 fprint close, handle, 01h
 closefile handle
 ret

 fin:
 setvideo 2h
 call clean
 mov ah, 4Ch
 int 21h


 size db 1,'$$'
 dn db "$$$"
 nvl db '$$'
 Nivel1 db 1h, 1, 44, 2h, 1, 194, 1h, 2, 138, 1h, 2, 238, 2h, 3, 132, 0
 Nivel2 db 2h, 1, 44, 1h, 1, 144, 1h, 2, 138, 2h, 3, 82, 1h, 3, 182, 1h, 4, 126, 0
 Nivel3 db 1h, 1, 44, 1h, 1, 194, 2h, 2, 38, 1h, 2, 238, 2h, 3, 82, 2h, 3, 182, 1h, 4, 76, 0
 n1 db 'Nivel 1', '$'
 n2 db 'Nivel 2', '$'
 n3 db 'Nivel 3', '$'
 handle db '$$'
 name db 'rep4.txt', 0, '$'
 open db '{',10
 close db '}'
 fecha db '"Fecha":'
 fecha2 db '",/',10,
 carnet db '"Carnet":"201513744",',10
 nombre db '"Nombre":"Edwin Pernilla",',10
 tlc db 'Game Over','$'
 tuc db '"User":'
 tcp db '"Password":'
 sm db '"Usuarios":'
 cct db 'You Win','$'
 rvs db '"ReverseString":'
 tsg db '"toString":'
 resultado db '"Resultado":'
 mnu db 'MENU',10,'$'
 login db 'LogIn',10,'$'
 logup db 'LogUp',10,'$'
 msg1 db '   User: ','$'      
 msg2 db '   Password: ','$' 
 msg3 db '   1.Ingresar',10,'$' 
 msg4 db '   2.Registrarse',10,'$' 
 msg5 db '   3.Salir',10,'$'  
 charcl db '                           ','$'  
 msg6 db '   >> ','$'   
 msg16 db '   El usuario no existe, intente de nuevo', 10,'$'
 msg17 db '   El password es incorrecto, intente de nuevo', 10,'$'
 msgre db '   El Password debe poseer mas de 4 caracteres', 10,'$'
 msgfe db '   El User debe poseer mas de 4 caracters', 10,'$'
 msgse db 10,'   Solo se adminten numeros en el Password', 10,'$'   
 number times 10 db '$'
 char db '$$$'
 buffer times 0fh db '$'
 users times 1600 db '$'
 passwords  times 1600 db '$'
 points times 100 db '0000$'
 pospoin db '$$$'
 SEGMENT data
 vga dw 0a000h