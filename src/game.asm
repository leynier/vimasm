%include "video.mac"
%include "keyboard.mac"

section .text

extern clear
extern scan

; Bind a key to a procedure
%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  %%next:
%endmacro

; Fill the screen with the given background color
%macro FILL_SCREEN 1
  push word %1
  call clear
  add esp, 2
%endmacro

global game
game:
  ; Initialize game

  ; Snakasm main loop
  game.loop:
    call get_input

    ; Main loop.

    ; Here is where you will place your game logic.
    ; Develop procedures like paint_map and update_content,
    ; declare it extern and use here.

    jmp game.loop


draw.red:
  FILL_SCREEN BG.RED
  ret


draw.green:
  FILL_SCREEN BG.GREEN
  ret


get_input:
    call scan
    push ax
    ; The value of the input is on 'word [esp]'

    ; Your bindings here
    bind KEY.UP, draw.red
    bind KEY.DOWN, draw.green

    add esp, 2 ; free the stack
    ret
