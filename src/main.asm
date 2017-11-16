%include "video.mac"
%include "keyboard.mac"

section .text

extern clear
extern scan
extern calibrate

%macro FILL_SCREEN 1
  push word %1
  call clear
  add esp, 2
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

  main.loop:
    .input:
      call scan
      cmp al, KEY.UP
      jne not_up
      FILL_SCREEN BG.RED
      not_up:
      cmp al, KEY.DOWN
      jne not_down
      FILL_SCREEN BG.GREEN
      not_down:

    jmp main.loop