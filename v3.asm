;         C O L U M N A
;     0  1  2  3  4  5  6  7
;  0  01 02 03 04 05 06 07 08    R
;  1  09 10 11 12 13 14 15 16    E
;  2  17 18 19 20 21 22 23 24    N
;  3  25 26 27 28 29 30 31 32    G
;  4  33 34 35 36 37 38 39 40    L
;  5  41 42 43 44 45 46 47 48    O
;  6  49 50 51 52 53 54 55 56    N
;  7  57 58 59 60 61 62 63 64

.model small
.stack 200h 

VAL_LF EQU 10 ; constante de la line fide
VAL_RET EQU 13 ; variable de retorno
CHR_FIN EQU '$'

MAX_COL EQU 8  ; son 4 porque esta normal (imprime normal 2 lines)
MAX_COL2 EQU 10 ; son 6 porque se le suma el fin y salto de linea (imprime como matriz)


;====================================================================================
;====================================================================================
;====================================================================================
;====================================================================================

.data


; Definimos un nuevo arreglo de 4 por 4----> duplico 4 bites 
;y dentro de ellos otros 4 OJO en si 4 reglones 6 columnas esta es para desplegar ya como 
;     0  1  2  3  4  VAL_LF VAL_RET
;  0  01 02 03 04 05   -       -
;  1  06 07 08 09 10   -       -
;  2  11 12 13 14 15   -       -
;  3  16 17 18 19 20   -       -
;  4  21 22 23 24 25   -       -
matIntEdades2 DB 8 DUP (8 DUP ("x"),VAL_LF,VAL_RET)
strFin2       DB VAL_LF,VAL_RET,CHR_FIN

;MENSAJES DE LA CARATULA
    titulo db 13,10,'Universidad de Sancarlos de Guatemala',13,10,'$'
    titulo2 db 13,10,'Facultad de Ingenieria',13,10,'$'
    titulo3 db 13,10,'Ciencias y Sistemas',13,10,'$'
    titulo4 db 13,10,'Arquitectura de Computadores y Ensambladores 1',13,10,'$'
    titulo5 db 13,10,'Nombre: Cesar Alejandro Sazo Quisquinay',13,10,'$'
    titulo6 db 13,10,'Carnet: 201513858',13,10,'$'
    titulo7 db 13,10,'Seccion: A',13,10,'$'
    mensaje db '-1 Iniciar Juego',13,10,'-2 Cargar Juego',13,10,'-3 Salir',13,10,'$'
    mensaje1 db 'Pantalla en color azul',13,10,'$'
    mensaje2 db 'Pantalla en color morado',13,10,'$'
    mensaje3 db 'Pantalla en color gris con letras negras',13,10,'$'

;MENSJAES DEL JUEGO 
    mensajejuego db 13,10,'Turno Blancas: ','$'
    mensajejuego2 db 13,10,'Turno Negras: ','$'
    mensajejuego3 db 13,10,'Casilla Actual x-y: ','$'
    mensajejuego4 db 13,10,'Casilla Destino x-y: ','$'


    mensajejuego5 db 13,10,'Casilla Actual y-x: ','$'
    mensajejuego6 db 13,10,'Casilla Destino y-x: ','$'
    mensajejuego7 db 13,10,'Casilla Actual/Destino: ','$'
;variables para la posicion del juego a moverser 
    n_xActual db ?
    n_yActual db ?
    n_xDestino db ?
    n_yDestino db ?

;====================================================================================
;====================================================================================
;====================================================================================
;====================================================================================

  cadena db 100 dup(' '),'$'
  cadenaTurnos db 100 dup(' '),'$'

.code
 


codigo segment
    assume ds:@data, cs:codigo

    inicio:   
 mov ax,@data     ;llamar a .data
 mov ds,ax        ;guardar los datos en ds
 
 mov ah,0  ;limpia el registro
;================CARATULA===============================
;========================================================
 lea dx,titulo    ;imprimir el mensaje 
 mov ah,9h
 int 21h
 lea dx,titulo2   ;imprimir el mensaje 
 mov ah,9h
 int 21h
 lea dx,titulo3    ;imprimir el mensaje 
 mov ah,9h
 int 21h
 lea dx,titulo4    ;imprimir el mensaje 
 mov ah,9h
 int 21h
 lea dx,titulo5    ;imprimir el mensaje 
 mov ah,9h
 int 21h
 lea dx,titulo6   ;imprimir el mensaje 
 mov ah,9h
 int 21h
 lea dx,titulo7    ;imprimir el mensaje 
 mov ah,9h
 int 21h
 ;=====================================================================0



 lea dx,mensaje   ;imprimir mensaje
 mov ah,9h
 int 21h

;nueva comparacion
mov ah, 3fh
mov bx,00
mov cx,100
mov dx, offset[cadena]
int 21h
mov ah, 09h
mov dx, offset[cadena]
int 21h
;para los otros comandos
cmp cadena[0],'e'; para exit
jz CarharJuegoMetodo
cmp cadena[0],'s'; para exit
jz CarharJuegoMetodo
cmp cadena[1],'h'; para show
jz CarharJuegoMetodo
;para los comandos 
cmp cadena[0],'1'
jz IniciarJuegoMetodo   ; inicar juego 
cmp cadena[0],'2'
jz CarharJuegoMetodo ; cargar juego
cmp cadena[0],'3'
jz FinalizarJuego  
;termina nueva comparacion
 

FinalizarJuego:
 mov ax,4c00h       ;funcion que termina el programa
 int 21h

IniciarJuegoMetodo:
 ;llama al procedimiento
 CALL CargarTablero

CarharJuegoMetodo:
 CALL MORADOPROC    ;llama  al procedimiento

CargarTableroMetodo:
 CALL CargarTablero
              

CargarTablero PROC NEAR
  ; movemos a ax los datos
     mov ax, @data
    ; movesmo a ds ax 
     mov ds,ax

    
     ;PARTE DE MODIFICACION DE LA MATRIZ modificamos un valor en la matriz normal 
     ;FORMULA= REN * MAX_COL + COL

    ; movemos para mostrar el mensaje
    mov dx,offset matIntEdades2
    mov ah,09
    int 21h
    ;FORMULA= REN * MAX_COL + COL
    

    ;FICHASNEGRAS
    mov matIntEdades2 + 0 * MAX_COL2 + 1,78 ; muevo e 0 a REN 0 COL 2
    mov matIntEdades2 + 0 * MAX_COL2 + 3,78
    mov matIntEdades2 + 0 * MAX_COL2 + 5,78
    mov matIntEdades2 + 0 * MAX_COL2 + 7,78
    mov matIntEdades2 + 1 * MAX_COL2 + 0,78
    mov matIntEdades2 + 1 * MAX_COL2 + 2,78
    mov matIntEdades2 + 1 * MAX_COL2 + 4,78
    mov matIntEdades2 + 2 * MAX_COL2 + 1,78
    mov matIntEdades2 + 2 * MAX_COL2 + 3,78
    mov matIntEdades2 + 2 * MAX_COL2 + 5,78
    mov matIntEdades2 + 2 * MAX_COL2 + 7,78
  


    ;FICHASBLANCAS
    mov matIntEdades2 + 7 * MAX_COL2 + 0,66 ; muevo e 0 a REN 0 COL 2
    mov matIntEdades2 + 7 * MAX_COL2 + 2,66
    mov matIntEdades2 + 7 * MAX_COL2 + 4,66
    mov matIntEdades2 + 7 * MAX_COL2 + 6,66
    mov matIntEdades2 + 6 * MAX_COL2 + 1,66
    mov matIntEdades2 + 6 * MAX_COL2 + 3,66
    mov matIntEdades2 + 6 * MAX_COL2 + 5,66
    mov matIntEdades2 + 6 * MAX_COL2 + 7,66
    mov matIntEdades2 + 5 * MAX_COL2 + 0,66 
    mov matIntEdades2 + 5 * MAX_COL2 + 2,66
    mov matIntEdades2 + 5 * MAX_COL2 + 4,66
    mov matIntEdades2 + 5 * MAX_COL2 + 6,66

    int 21h
    
     mov ah,08              ;pausa y espera a que el usuario precione una tecla
     int 21h                ;interrupcion para capturar

    CALL PROBLANCASACTUAL
    RET
CargarTablero ENDP

;PROCESO DE BLANCAS=========================================================================================================
;PROCESOSTEMPORALES si sirve es para movimiento blancas ACTUAL
PROBLANCASACTUAL PROC NEAR
 mov ah,0  ;limpia el registro
 mov al,3h  ;modo de texto
 int 10h

 mov ah,08              ;pausa y espera a que el usuario precione una tecla
 int 21h                ;interrupcion para capturar
 
  ;imprimios
 lea dx,mensajejuego; =turno de blancas
 mov ah,9h
 int 21h
 ; imprmimos 
 lea dx,mensajejuego3; posicion actual x-y
 mov ah,9h
 int 21h
 ;===
 ;nueva comparacion
mov ah, 3fh
mov bx,00
mov cx,100
mov dx, offset[cadena]
int 21h
mov ah, 09h
mov dx, offset[cadena]
int 21h
;para los otros comandos
cmp cadena[0],'E'; para exit
jz LLAMARAINICIO

;para los comandos 
cmp cadena[0],'a'
jz VariableXactualM   ; inicar juego 
cmp cadena[0],'b'
jz VariableXactualM ; cargar juego
cmp cadena[0],'c'
jz VariableXactualM  
cmp cadena[0],'d'
jz VariableXactualM 
cmp cadena[0],'e'
jz VariableXactualM 
cmp cadena[0],'f'
jz VariableXactualM
cmp cadena[0],'g'
jz VariableXactualM 
cmp cadena[0],'h'
jz VariableXactualM
cmp cadena[0],'1'
jz VariableYactualM  
cmp cadena[0],'2'
jz VariableYactualM 
cmp cadena[0],'3'
jz VariableYactualM  
cmp cadena[0],'4'
jz VariableYactualM 
cmp cadena[0],'5'
jz VariableYactualM 
cmp cadena[0],'6'
jz VariableYactualM
cmp cadena[0],'7'
jz VariableYactualM 
cmp cadena[0],'8'
jz VariableYactualM

 CALL PROBLANCASACTUAL
 RET
PROBLANCASACTUAL ENDP
;TERMINAPROCESOSTEMPORALES====

VariableXactualM:
CALL GuardarVariablexActual

VariableYactualM:
CALL GuardarVariableyActual

LLAMARAINICIO:
CALL prollamarinicio



;PROCESOSTEMPORALES si sirve es para movimiento blancas DESTINO
PROBLANCASDESTINO PROC NEAR
 mov ah,0  ;limpia el registro
 mov al,3h  ;modo de texto
 int 10h

 mov ah,08              ;pausa y espera a que el usuario precione una tecla
 int 21h                ;interrupcion para capturar
 
  ;imprimios
 lea dx,mensajejuego; =turno de blancas
 mov ah,9h
 int 21h
 ; imprmimos 
 lea dx,mensajejuego4; posicion destino x-y
 mov ah,9h
 int 21h
 ;===
 ;nueva comparacion
mov ah, 3fh
mov bx,00
mov cx,100
mov dx, offset[cadena]
int 21h
mov ah, 09h
mov dx, offset[cadena]
int 21h
;para los otros comandos
cmp cadena[0],'E'; para exit
jz LLAMARAINICIODestino

;para los comandos 
cmp cadena[0],'a'
jz VariableXMDestino  ; inicar juego 
cmp cadena[0],'b'
jz VariableXMDestino ; cargar juego
cmp cadena[0],'c'
jz VariableXMDestino  
cmp cadena[0],'d'
jz VariableXMDestino 
cmp cadena[0],'e'
jz VariableXMDestino 
cmp cadena[0],'f'
jz VariableXMDestino
cmp cadena[0],'g'
jz VariableXMDestino 
cmp cadena[0],'h'
jz VariableXMDestino
cmp cadena[0],'1'
jz VariableYMDestino  
cmp cadena[0],'2'
jz VariableYMDestino 
cmp cadena[0],'3'
jz VariableYMDestino  
cmp cadena[0],'4'
jz VariableYMDestino 
cmp cadena[0],'5'
jz VariableYMDestino 
cmp cadena[0],'6'
jz VariableYMDestino
cmp cadena[0],'7'
jz VariableYMDestino 
cmp cadena[0],'8'
jz VariableYMDestino

;termina nueva comparacion
 ;===
 mov ah,08              ;pausa y espera a que el usuario precione una tecla
 int 21h 

 CALL PROBLANCASDESTINO
 RET
PROBLANCASDESTINO ENDP
;TERMINAPROCESOSTEMPORALES====

VariableXMDestino:
CALL GuaradarVariablexDestino

VariableYMDestino:
CALL GuardarVariableyDestino

LLAMARAINICIODestino:
CALL prollamarinicio

prollamarinicio PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
CALL inicio
 RET
prollamarinicio ENDP

GuaradarVariablexDestino PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
; imprmimos 
 mov ah, 01h
 int 21h
 sub al,30h
 mov n_xDestino,al
 CALL PROBLANCASDESTINO
 RET
GuaradarVariablexDestino ENDP

GuardarVariableyDestino PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
; imprmimos 
 mov ah, 01h
 int 21h
 sub al,30h
 mov n_yDestino,al

;IMPRESION DE TODOS LOS DATOS 
 lea dx,mensajejuego7; posicion actual x-y
 mov ah,9h
 int 21h

 mov ah,02h
 mov dl,n_xActual
 add dl,30h
 int 21h
 mov ah,02h
 mov dl,n_yActual
 add dl,30h
 int 21h
 mov ah,02h
 mov dl,n_xDestino
 add dl,30h
 int 21h
 mov ah,02h
 mov dl,n_yDestino
 add dl,30h
 int 21h


     mov ah,08              ;pausa y espera a que el usuario precione una tecla
     int 21h                ;interrupcion para capturar

 CALL PRONEGRASACTUAL
 RET
GuardarVariableyDestino ENDP

GuardarVariablexActual PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h

 mov ah, 01h
 int 21h
 sub al,30h
 mov n_xActual,al

 CALL PROBLANCASACTUAL
 RET
GuardarVariablexActual ENDP

GuardarVariableyActual PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
 ;leemos
 mov ah, 01h
 int 21h
 sub al,30h
 mov n_yActual,al

 mov ah,08              ;pausa y espera a que el usuario precione una tecla
     int 21h   

 CALL PROBLANCASDESTINO
 RET
GuardarVariableyActual ENDP
;PROCESO DE BLANCAS=========================================================================================================






;PROCESO DE NEGRAS=========================================================================================================
;MOVIEMIENTO ACTUAL de las negras
PRONEGRASACTUAL PROC NEAR
 mov ah,0  ;limpia el registro
 mov al,3h  ;modo de texto
 int 10h

 mov ah,08              ;pausa y espera a que el usuario precione una tecla
 int 21h                ;interrupcion para capturar
 
  ;imprimios
 lea dx,mensajejuego2; =turno de negras
 mov ah,9h
 int 21h
 ; imprmimos 
 lea dx,mensajejuego3; posicion actual x-y
 mov ah,9h
 int 21h
 ;===
 ;nueva comparacion
mov ah, 3fh
mov bx,00
mov cx,100
mov dx, offset[cadena]
int 21h
mov ah, 09h
mov dx, offset[cadena]
int 21h
;para los otros comandos
cmp cadena[0],'E'; para exit
jz LLAMARAINICION

;para los comandos 
cmp cadena[0],'a'
jz VariableXactualMN   ; inicar juego 
cmp cadena[0],'b'
jz VariableXactualMN ; cargar juego
cmp cadena[0],'c'
jz VariableXactualMN  
cmp cadena[0],'d'
jz VariableXactualMN 
cmp cadena[0],'e'
jz VariableXactualMN 
cmp cadena[0],'f'
jz VariableXactualMN
cmp cadena[0],'g'
jz VariableXactualMN 
cmp cadena[0],'h'
jz VariableXactualMN
cmp cadena[0],'1'
jz VariableYactualMN  
cmp cadena[0],'2'
jz VariableYactualMN 
cmp cadena[0],'3'
jz VariableYactualMN  
cmp cadena[0],'4'
jz VariableYactualMN 
cmp cadena[0],'5'
jz VariableYactualMN 
cmp cadena[0],'6'
jz VariableYactualMN
cmp cadena[0],'7'
jz VariableYactualMN 
cmp cadena[0],'8'
jz VariableYactualMN

 CALL PRONEGRASACTUAL
 RET
PRONEGRASACTUAL ENDP
;TERMINAPROCESOSTEMPORALES====

VariableXactualMN:
CALL GuardarVariablexActualN

VariableYactualMN:
CALL GuardarVariableyActualN

LLAMARAINICION:
CALL prollamarinicioN


prollamarinicioN PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
CALL inicio
 RET
prollamarinicioN ENDP

;PROCESOSTEMPORALES si sirve es para movimiento blancas DESTINO
PRONEGRASDESTINO PROC NEAR
 mov ah,0  ;limpia el registro
 mov al,3h  ;modo de texto
 int 10h

 mov ah,08              ;pausa y espera a que el usuario precione una tecla
 int 21h                ;interrupcion para capturar
 
  ;imprimios
 lea dx,mensajejuego2; =turno de blancas
 mov ah,9h
 int 21h
 ; imprmimos 
 lea dx,mensajejuego4; posicion destino x-y
 mov ah,9h
 int 21h
 ;===
 ;nueva comparacion
mov ah, 3fh
mov bx,00
mov cx,100
mov dx, offset[cadena]
int 21h
mov ah, 09h
mov dx, offset[cadena]
int 21h
;para los otros comandos
cmp cadena[0],'E'; para exit
jz LLAMARAINICIODestinoN

;para los comandos 
cmp cadena[0],'a'
jz VariableXMDestinoN  ; inicar juego 
cmp cadena[0],'b'
jz VariableXMDestinoN    ; cargar juego
cmp cadena[0],'c'
jz VariableXMDestinoN  
cmp cadena[0],'d'
jz VariableXMDestinoN 
cmp cadena[0],'e'
jz VariableXMDestinoN 
cmp cadena[0],'f'
jz VariableXMDestinoN
cmp cadena[0],'g'
jz VariableXMDestinoN 
cmp cadena[0],'h'
jz VariableXMDestinoN
cmp cadena[0],'1'
jz VariableYMDestinoN  
cmp cadena[0],'2'
jz VariableYMDestinoN 
cmp cadena[0],'3'
jz VariableYMDestinoN  
cmp cadena[0],'4'
jz VariableYMDestinoN 
cmp cadena[0],'5'
jz VariableYMDestinoN 
cmp cadena[0],'6'
jz VariableYMDestinoN
cmp cadena[0],'7'
jz VariableYMDestinoN 
cmp cadena[0],'8'
jz VariableYMDestinoN

;termina nueva comparacion
 ;===
 mov ah,08              ;pausa y espera a que el usuario precione una tecla
 int 21h 

 CALL PRONEGRASDESTINO
 RET
PRONEGRASDESTINO ENDP
;TERMINAPROCESOSTEMPORALES====

VariableXMDestinoN:
CALL GuaradarVariablexDestinoN

VariableYMDestinoN:
CALL GuardarVariableyDestinoN

LLAMARAINICIODestinoN:
CALL prollamarinicioN2

prollamarinicioN2 PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
CALL inicio
 RET
prollamarinicioN2 ENDP

GuaradarVariablexDestinoN PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
; imprmimos 
 mov ah, 01h
 int 21h
 sub al,30h
 mov n_xDestino,al
 CALL PRONEGRASDESTINO
 RET
GuaradarVariablexDestinoN ENDP

GuardarVariableyDestinoN PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
; imprmimos 
 mov ah, 01h
 int 21h
 sub al,30h
 mov n_yDestino,al

;IMPRESION DE TODOS LOS DATOS 
 lea dx,mensajejuego7; posicion actual x-y
 mov ah,9h
 int 21h

 mov ah,02h
 mov dl,n_xActual
 add dl,30h
 int 21h
 mov ah,02h
 mov dl,n_yActual
 add dl,30h
 int 21h
 mov ah,02h
 mov dl,n_xDestino
 add dl,30h
 int 21h
 mov ah,02h
 mov dl,n_yDestino
 add dl,30h
 int 21h


     mov ah,08              ;pausa y espera a que el usuario precione una tecla
     int 21h                ;interrupcion para capturar

 CALL MODIFICARMATRIZ;clavo  lo que ivaPROBLANCASACTUAL
 RET
GuardarVariableyDestinoN ENDP

GuardarVariablexActualN PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h

 mov ah, 01h
 int 21h
 sub al,30h
 mov n_xActual,al

 CALL PRONEGRASACTUAL
 RET
GuardarVariablexActualN ENDP

GuardarVariableyActualN PROC NEAR
mov ah,0  ;limpia el registro
mov al,3h  ;modo de texto
int 10h
 ;leemos
 mov ah, 01h
 int 21h
 sub al,30h
 mov n_yActual,al

 mov ah,08              ;pausa y espera a que el usuario precione una tecla
     int 21h   

 CALL PRONEGRASDESTINO
 RET
GuardarVariableyActualN ENDP
;PROCESO DE BLANCAS=========================================================================================================



MORADOPROC PROC NEAR
 mov ah,0
 mov al,3h
 int 10h
   
 mov ax,0600h
 mov bh,5fh
 mov cx,0000h
 mov dx,184Fh
 int 10h   
  
 lea dx,mensaje2  
 mov ah,9h
 int 21h
  
 CALL inicio
 RET
MORADOPROC ENDP


COMPARACIONDEFICHASNEGRAS PROC NEAR
 mov ah,0
 mov al,3h
 int 10h

cmp n_xActual,'a'
jz MODIFICARMATRIZ
cmp n_yActual,'1'
jz MODIFICARMATRIZ

 CALL MODIFICARMATRIZ
 RET
COMPARACIONDEFICHASNEGRAS ENDP

MODIFICARMATRIZ PROC NEAR
mov ah,0
mov al,3h
int 10h
 
     ;PARTE DE MODIFICACION DE LA MATRIZ modificamos un valor en la matriz normal 
     ;FORMULA= REN * MAX_COL + COL

    ; movemos para mostrar el mensaje
    mov dx,offset matIntEdades2
    mov ah,09
    int 21h
    ;FORMULA= REN * MAX_COL + COL
    
    cmp n_xActual,'a' ;esto es la columna
    jz x1; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'b' ;esto es la columna
    jz x2; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'c' ;esto es la columna
    jz x3; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'d' ;esto es la columna
    jz x4; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'e' ;esto es la columna
    jz x5; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'f' ;esto es la columna
    jz x6; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'g' ;esto es la columna
    jz x7; muevo e 0 a REN 0 COL 2
    cmp n_xActual,'h' ;esto es la columna
    jz x8; muevo e 0 a REN 0 COL 2
  
   ; mov matIntEdades2 + n_xActual * MAX_COL2 + n_yActual,87 ; muevo e 0 a REN 0 COL 2
   
  x1:
  mov matIntEdades2 + 1 * MAX_COL2 + 0,87 ; muevo e 0 a REN 0 COL 2
  x2:
  mov matIntEdades2 + 1 * MAX_COL2 + 1,87 ; muevo e 0 a REN 0 COL 2
  x3:
  mov matIntEdades2 + 1 * MAX_COL2 + 2,87 ; muevo e 0 a REN 0 COL 2  
  x4:
  mov matIntEdades2 + 1 * MAX_COL2 + 3,87 ; muevo e 0 a REN 0 COL 2
  x5:
  mov matIntEdades2 + 1 * MAX_COL2 + 4,87 ; muevo e 0 a REN 0 COL 2
  x6:
  mov matIntEdades2 + 1 * MAX_COL2 + 5,87 ; muevo e 0 a REN 0 COL 2
  x7:
  mov matIntEdades2 + 1 * MAX_COL2 + 6,87 ; muevo e 0 a REN 0 COL 2
  x8:
  mov matIntEdades2 + 1 * MAX_COL2 + 7,87 ; muevo e 0 a REN 0 COL 2


    ;FICHASBLANCAS
  ;  mov matIntEdades2 + n_xDestino * MAX_COL2 + n_xDestino,87 ; muevo e 0 a REN 0 COL 2
    

   ; int 21h

mov dx,offset matIntEdades2
    mov ah,09
    int 21h

    
     mov ah,08              ;pausa y espera a que el usuario precione una tecla
     int 21h                ;interrupcion para capturar

    

CALL inicio
RET
MODIFICARMATRIZ ENDP

codigo ends
end inicio  
