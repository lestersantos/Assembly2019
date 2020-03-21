ORG 100h
%macro println 1 ;colocar nombre numero de parametros
;para llamar el parametro colocar %1
	mov dx, %1 ;cadena a imprimir
  	mov ah, 09h
  	int 21h
	mov ah, 02h ;salto d linea
    mov dl, 0ah
    int 21h
%endmacro
	println IngresarUsuarioCadena
	;limpiar registros
  	XOR SI, SI
    XOR DI, DI
    XOR al, al
	
	regresaIngUsu:
	    mov ah,01 
	    int 21h   
	    cmp al,13 
	    je VerificarUsuario
	    mov [UsuarioActual + SI],al ;pasar caracter leido al vector
	    inc SI   
	loop regresaIngUsu

	VerificarUsuario:
	xor di, di
	xor si, si
	xor ax, ax
	
	seguirComparando:
	
	;comparar si ya es el fin de la cadena
	mov al, [UsuarioActual + di]
	mov ah, [UsuarioQuemado + si]
	cmp ah, 0x24
	je mensajeCorrecto
	cmp al, ah ;comparar contenido de las cadenas
	jne mensajeError ;si no son iguales
	aumentarContadores: ;aumentar contadores
		add di, 1 ;di=di+1
		add si, 1 ;si=si+1
	jmp seguirComparando
	
mensajeError:
	println mensajeMalo
	jmp Salida
mensajeCorrecto: 
	println mensajeBueno
	jmp Salida
Salida:
  mov ah, 4ch
  int 21h
 
	SEGMENT data
   	IngresarUsuarioCadena db "Ingrese su nombre de usuario$"
   	UsuarioActual times 100 db "$"
	UsuarioQuemado db "julia$"
	mensajeMalo db "Usuario incorrecto :c$"
	mensajeBueno db "Usuario Correcto c:$"
	