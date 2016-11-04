%include "video.mac"

; Frame buffer location
%define FBUFFER 0xB8000

section .text

; clear(byte char, byte attrs)
; Clear the screen by filling it with char and attributes.
global clear
clear:
  mov ax, [esp + 4] ; char, attrs
  mov edi, FBUFFER
  mov ecx, COLS * ROWS
  rep stosw
  ret
