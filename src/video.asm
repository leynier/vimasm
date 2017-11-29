%include "video.mac"
%include "utils.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern BAR_BOTTOM
extern MODE

global paint_start
paint_start:
    push ebp
    mov ebp, esp
    pushad

    ; Pinta la pantalla de color negro
    push word BG.BLACK
    call clear

    REG_CLEAR

    cld
    mov edi, FBUFFER
    mov ax, 'V' | FG.GREEN | FG.BRIGHT
    stosw
    mov ax, 'I' | FG.GREEN | FG.BRIGHT
    stosw
    mov ax, 'M' | FG.GREEN | FG.BRIGHT
    stosw
    mov ax, 'A' | FG.GREEN | FG.BRIGHT
    stosw
    mov ax, 'S' | FG.GREEN | FG.BRIGHT
    stosw
    mov ax, 'M' | FG.GREEN | FG.BRIGHT
    stosw

    paint_start.ret:
        popad
        pop ebp
        ret

; clear(word char|attrs)
; Pinta en toda la pantalla un caracter con el color deseado
global clear
clear:
    push ebp
    mov ebp, esp
    pushad

    mov ax, [ebp + 8] ; char, attrs
    mov edi, FBUFFER
    mov ecx, COLS * ROWS
    cld
    rep stosw

    popad
    pop ebp
    ret 2


; putc(word col|row, word chr|color)
; Pinta en una posicion de la pantalla un caracter del color deseado
global putc
putc:
    push ebp
    mov ebp, esp
    pushad

    ; calc famebuffer offset 2 * (r * COLS + c)
    FBOFFSET [ebp + 11], [ebp + 10]
    mov bx, [ebp + 8]
    mov [FBUFFER + eax], bx

    popad
    pop ebp
    ret 4


; paint()
; Pinta en la pantalla segun los valores del POS_DOCUMENT y el POS_POINTER
global paint
paint:
    push ebp
    mov ebp, esp
    pushad

    ; Pinta la pantalla de color negro
    push word BG.BLACK
    call clear

    REG_CLEAR

    cld
    cmp dword [MODE], MODE_NORMAL
    jne not_mode_normal
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'N'
        stosb
        mov al, 'O'
        stosb
        mov al, 'R'
        stosb
        mov al, 'M'
        stosb
        mov al, 'A'
        stosb
        mov al, 'L'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_normal:
    cmp dword [MODE], MODE_INSERTION
    jne not_mode_insertion
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'I'
        stosb
        mov al, 'N'
        stosb
        mov al, 'S'
        stosb
        mov al, 'E'
        stosb
        mov al, 'R'
        stosb
        mov al, 'T'
        stosb
        mov al, 'I'
        stosb
        mov al, 'O'
        stosb
        mov al, 'N'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_insertion:
    mov esi, BAR_BOTTOM
    mov edi, FBUFFER
    add edi, 3840
    mov ecx, 80
    paint.bottom:
        xor eax, eax
        lodsb
        or ax, FG.GREEN | FG.BRIGHT
        stosw
        loop paint.bottom

    ; Coloca el 'esi' apartir de donde se este mostrando el documento, el 'edi' al principio de la pantalla
    mov esi, START_DOCUMENT
    add esi, [POS_DOCUMENT]
    mov edi, FBUFFER
    cld

    paint.loop:
        xor eax, eax
        lodsb ; Carga hacia 'al' un caracter y avanza el 'esi'
        cmp al, EOF ; Comprueba si es el fin de fichero
        jne not_eof
        mov al, ' ' ; Si es el fin de fichero lo remplaza con espacio en blanco
        not_eof:
        cmp al, EOL ; Comprueba si es el fin de linea
        jne not_eol
        mov al, ' ' ; Si es el fin de linea lo remplaza con espacio en blanco
        not_eol:
        cmp ebx, [POS_POINTER] ; Comprueba si el caracter esta en la posicion del cursor
        jne not_pointer
        xor ax, FG.BLACK ; Le coloca el color al caracter
        xor ax, BG.GREEN | BG.BRIGHT ; Como el caracter esta en la posicion del cursor se le coloca el fondo blanco
        jmp pointer
        not_pointer:
        xor ax, FG.BRIGHT | FG.GREEN ; Le coloca el color al caracter
        xor ax, BG.BLACK
        pointer:
        cmp ebx, 1920 ; Comprueba si no se ha llegado al final de la pantalla
        je paint.ret ; Retorna porque se llego al final de la pantalla
        stosw ; Coloca en la pantalla el caracter con el color y mueve el 'edi'
        inc ebx ; Incrementa la posicion donde se esta pintando
        jmp paint.loop

    paint.ret:
        popad
        pop ebp
        ret