%include "video.mac"
%include "keyboard.mac"

section .data

ASCII_CODE db 0,0,49,50,51,52,53,54,55,56,57,48,45,61,0,0,113,119,101,114,116,121,117,105,111,112,91,93,10,0,97,115,100,102,103,104,106,107,108,59,39,96,0,92,122,120,99,118,98,110,109,44,46,47,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,52,53,54,43,49,50,51,48,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ASCII_CODE_LEN dd 167 

section .text

extern clear
extern scan
extern calibrate
extern putc

%macro FILL_SCREEN 1
  push word %1
  call clear
%endmacro

global main
main:
  ; Move text mode cursor off screen.
  mov dx, 0x3D4
  mov al, 0x0E
  out dx, al
  inc dx
  mov al, 0xFF
  out dx, al

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

  xor ecx, ecx

  main.loop:
    .input:
      xor eax, eax
      call scan
      cmp eax, 100
      ja .input
      mov al, [ASCII_CODE + eax]
      xor ax, FG.BRIGHT | FG.GREEN
      push cx
      push ax
      call putc
      inc cx

    jmp main.loop