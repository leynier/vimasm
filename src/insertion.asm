%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE

extern scan
extern paint
extern shift_down
extern shift_up
extern move_cursor_left
extern move_cursor_right
extern move_cursor_down
extern move_cursor_up
extern erase
extern end_line
extern write

global insertion
insertion:
    mov dword [MODE], MODE_INSERTION
    call paint
    REG_CLEAR
    call scan

    ; Comprueba los shifts
    BIND [KEY], KEY.LEFTSHIFT.DOWN, shift_down
    BIND [KEY], KEY.RIGHTSHIFT.DOWN, shift_down
    BIND [KEY], KEY.LEFTSHIFT.UP, shift_up
    BIND [KEY], KEY.RIGHTSHIFT.UP, shift_up

    ; Comprueba las flechas de direccion
    BIND [KEY], KEY.LEFT.DOWN, move_cursor_left
    BIND [KEY], KEY.RIGHT.DOWN, move_cursor_right
    BIND [KEY], KEY.UP.DOWN, move_cursor_up
    BIND [KEY], KEY.DOWN.DOWN, move_cursor_down

    ; Comprueba el BACKSPACE
    BIND [KEY], KEY.BACK.DOWN, erase

    ; Comprueba el ENTER
    BIND [KEY], KEY.ENTER.DOWN, end_line

    ; Comprueba el ESC
    cmp dword [KEY], KEY.ESC.DOWN
    je .ret

    call write

    jmp insertion

    .ret:
        ret