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

section .data

START_DOCUMENT dd 0
POS_DOCUMENT dd 0
POS_POINTER dd 0
PAINT_POINTER dd 0

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


; puts(string direction, start position, pointer position)
;      16                12              8  
global puts
puts:
    push ebp
    mov ebp, esp
    pusha

    push word BG.BLACK
    call clear

    xor eax, eax
    xor ebx, ebx
    xor esi, esi
    xor edi, edi
    mov dword [PAINT_POINTER], 0
    mov eax, [ebp + 16]
    mov [START_DOCUMENT], eax
    xor eax, eax
    mov eax, [ebp + 12]
    mov [POS_DOCUMENT], eax
    xor eax, eax
    mov eax, [ebp + 8]
    mov [POS_POINTER], eax
    mov esi, [START_DOCUMENT]
    add esi, [POS_DOCUMENT]
    mov edi, FBUFFER

    puts.loop:
        xor eax, eax
        lodsb
        xor ax, FG.BRIGHT | FG.GREEN
        cmp ebx, [POS_POINTER]
        jne not_pointer
        xor ax, BG.GRAY
        mov dword [PAINT_POINTER], 1
        not_pointer:
        cmp ebx, 1920
        je puts.ret
        stosw
        inc ebx
        jmp puts.loop

    puts.ret:
    cmp dword [PAINT_POINTER], 1
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
    popa
    pop ebp
    ret 12