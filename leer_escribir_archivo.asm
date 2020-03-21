ORG 100h


%macro write_archivo 2
  mov dx, %1      ; prepara la ruta del archivo
  mov ah, 3ch     ; funcion 3c, crear un archivo
  mov cx, 0     ; crear un archivo normal
  int 21h       ; interrupcion DOS

  mov bx, ax      ; se guarda el puntero del archivo retornado de la funcion
  mov ah, 40h     ; funcion 40, escribir un archivo
  mov cx, 999
  mov dx, %2      ; preparacion del texto a escribir
  int 21h       ; interrupcion DOS

  mov ah, 3eh     ; funcion 3e, cerrar un archivo
  int 21h       ; interrupcion DOS
%endmacro
LeerArchivo:
	xor ax, ax
	mov ax, cs
	mov ds,ax
	mov ah, 3dh
	mov al, 0h 
	mov dx, rutaArchivo
	int 21h
	jc errorAbriendo
	mov bx, ax
	mov ah, 3fh
	mov cx, 499
	mov dx, leido
	int 21h
	;cerrar archivo
	mov ah, 3eh
	int 21h
	;imprimir contenido
	mov dx, leido
	mov ah, 9
	int 21h

EscribirArchivo:
	write_archivo rutaArchivo2, TextoAImprimir
	
Leer:
	mov ah, 01h
	int 21h
Salida:
	mov ah, 4ch
	int 21h	

errorAbriendo:
	mov dx, rutaIncorrecta
	mov ah,09h
	int 21h
	jmp Salida

SEGMENT data
	leido times 800 db "$"
	rutaArchivo db "usuarios.txt",0
	rutaArchivo2 db "usuarios1.txt",0
	rutaIncorrecta db "LA RUTA NO EXISTE $"
	TextoAImprimir db "Mensaje de Prueba:3$"
