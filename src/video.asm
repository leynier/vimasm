%include "video.mac"

; Frame buffer location
%define FBUFFER 0xB8000

; FBOFFSET(byte row, byte column)
%macro FBOFFSET 2.nolist
    xor eax, eax
    mov al, COLS
    mul byte %1
    add al, %2
    adc ah, 0
    shl ax, 1
%endmacro

section .text

; clear(byte char, byte attrs)
; Clear the screen by filling it with char and attributes.
global clear
clear:
    push ebp
    mov ebp, esp
    pusha

    mov ax, [ebp + 8] ; char, attrs
    mov edi, FBUFFER
    mov ecx, COLS * ROWS
    cld
    rep stosw

    popa
    pop ebp
    ret 2


; putc(char chr, byte color, byte c, byte r)
;      8         9           10      11
global putc
putc:
    push ebp
    mov ebp, esp
    pusha

    ; calc famebuffer offset 2 * (r * COLS + c)
    FBOFFSET [ebp + 11], [ebp + 10]
    mov bx, [ebp + 8]
    mov [FBUFFER + eax], bx

    popa
    pop ebp
    ret 4


; puts(string direction, start position)
;      12                8
global puts
puts:
    push ebp
    mov ebp, esp
    pusha

    push word BG.BLACK
    call clear

    mov ebx, [ebp + 12] ; Direccion del array que contiene el texto
    add ebx, [ebp + 8] ; Se le suma la posicion desde donde debe comenzar
    mov esi, ebx
    mov edi, FBUFFER
    xor ebx, ebx

    puts.loop:
        xor eax, eax
        lodsb
        cmp al, 0 ; Ver si no es el final del array
        je puts.ret
        xor ax, FG.BRIGHT | FG.GREEN
        cmp bl, COLS2
        jne not_end
        mov bl, 0
        inc bh
        cmp bh, ROWS2
        jne not_end
        jmp puts.ret
        not_end:
        push bx
        push ax
        call putc
        inc bl
        jmp puts.loop

    puts.ret:
    popa
    pop ebp
    ret 8