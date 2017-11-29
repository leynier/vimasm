%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE

extern scan
extern paint
extern insertion
extern move_cursor_left
extern move_cursor_right
extern move_cursor_down
extern move_cursor_up

global normal
normal:
    mov dword [MODE], MODE_NORMAL
    call paint
    REG_CLEAR
    call scan

    cmp dword [KEY], KEY.ESC.DOWN
    je normal.ret

    BIND [KEY], KEY.I.DOWN, insertion

    ; Comprueba las flechas de direccion
    BIND [KEY], KEY.LEFT.DOWN, move_cursor_left
    BIND [KEY], KEY.RIGHT.DOWN, move_cursor_right
    BIND [KEY], KEY.UP.DOWN, move_cursor_up
    BIND [KEY], KEY.DOWN.DOWN, move_cursor_down

    jmp normal

    normal.ret:
        ret