%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE
extern TOGGLE_SHIFT
extern TOGGLE_CTRL

extern scan
extern paint
extern insertion
extern visual
extern visual_block
extern visual_line
extern shift_down
extern shift_up
extern ctrl_down
extern ctrl_up
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
    ;BIND [KEY], KEY.S.DOWN, insertion

    BIND [KEY], KEY.LEFTSHIFT.DOWN, shift_down
    BIND [KEY], KEY.RIGHTSHIFT.DOWN, shift_down
    BIND [KEY], KEY.LEFTSHIFT.UP, shift_up
    BIND [KEY], KEY.RIGHTSHIFT.UP, shift_up
 
    BIND [KEY], KEY.CTRL.DOWN, ctrl_down
    BIND [KEY], KEY.CTRL.UP, ctrl_up

    cmp dword [TOGGLE_SHIFT],0
    jne visualline
    cmp dword [TOGGLE_CTRL],0
    jne visualblock
    BIND [KEY], KEY.V.UP, visual
    jmp end   
    visualline:
    BIND [KEY], KEY.V.DOWN, visual_line
    jmp end
    visualblock:
    BIND [KEY], KEY.V.DOWN, visual_block
    end:

    ; Comprueba las flechas de direccion
    BIND [KEY], KEY.LEFT.DOWN, move_cursor_left
    BIND [KEY], KEY.RIGHT.DOWN, move_cursor_right
    BIND [KEY], KEY.UP.DOWN, move_cursor_up
    BIND [KEY], KEY.DOWN.DOWN, move_cursor_down

    jmp normal

    normal.ret:
        ret