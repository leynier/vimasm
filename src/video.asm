%include "video.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern PAINT_POINTER

; clear(byte char, byte attrs)
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


; putc(byte chr, byte color, byte c, byte r)
;      8         9           10      11
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


; puts(start position, pointer position)
;      12              8  
; Pinta en la pantalla el cursor y el texto desde la posicion deseada
global puts
puts:
    push ebp
    mov ebp, esp
    pushad

    ; Pinta la pantalla de color negro
    push word BG.BLACK
    call clear

    xor eax, eax
    xor ebx, ebx
    xor esi, esi
    xor edi, edi

    ; Inicializa el PAINT_POINTER
    mov dword [PAINT_POINTER], 0

    ; Coloca el 'esi' apartir de donde se este mostrando el documento, el 'edi' al principio de la pantalla
    mov esi, START_DOCUMENT
    add esi, [POS_DOCUMENT]
    mov edi, FBUFFER
    cld

    puts.loop:
        xor eax, eax
        lodsb ; Carga hacia 'al' un caracter y avanza el 'esi'
        cmp ebx, [POS_POINTER] ; Comprueba si el caracter esta en la posicion del cursor
        jne not_pointer
        xor ax, FG.BLACK ; Le coloca el color al caracter
        xor ax, BG.GREEN | BG.BRIGHT ; Como el caracter esta en la posicion del cursor se le coloca el fondo blanco
        mov dword [PAINT_POINTER], 1 ; Marca el PAINT_POINTER para luego no pintarlo
        jmp pointer
        not_pointer:
        xor ax, FG.BRIGHT | FG.GREEN ; Le coloca el color al caracter
        xor ax, BG.BLACK
        pointer:
        cmp ebx, 1920 ; Comprueba si no se ha llegado al final de la pantalla
        je puts.ret ; Retorna porque se llego al final de la pantalla
        stosw ; Coloca en la pantalla el caracter con el color y mueve el 'edi'
        inc ebx ; Incrementa la posicion donde se esta pintando
        jmp puts.loop

    puts.ret:
    cmp dword [PAINT_POINTER], 1 ; Comprueba si se pinto el cursor, si no lo pinta
    je .ret
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    mov eax, [POS_POINTER]
    mov ecx, 2
    mul ecx
    mov bx, ' ' | BG.GRAY
    mov [FBUFFER + eax], bx
    .ret:
    popad
    pop ebp
    ret