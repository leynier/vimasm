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
  mov ax, [esp + 4] ; char, attrs
  mov edi, FBUFFER
  mov ecx, COLS * ROWS
  cld
  rep stosw
  ret 2


; putc(char chr, byte color, byte c, byte r)
;      4         5           6       7
global putc
putc:
    ; calc famebuffer offset 2 * (r * COLS + c)
    FBOFFSET [esp + 7], [esp + 6]

    mov bx, [esp + 4]
    mov [FBUFFER + eax], bx

    ret 4