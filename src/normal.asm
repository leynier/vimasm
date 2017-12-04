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
extern void

global normal
normal:
    pushad
    mov dword [TOGGLE_CTRL], 0
    mov dword [TOGGLE_SHIFT], 0

    .loop:
        mov dword [MODE], MODE_NORMAL
        REG_CLEAR
        call paint
        call scan

        ; Comprueba el control
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.DOWN, ctrl_down, .loop
        BINDCTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.UP, ctrl_up, .loop

        ; Comprueba el shift
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.DOWN, shift_down, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.DOWN, shift_down, .loop
        BINDSHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.UP, shift_up, .loop
        BINDSHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.UP, shift_up, .loop

        ; Comprueba la combinacion con 'V' para entrar a los modos visuales
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.V.DOWN, visual, .loop
        BINDCTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.V.DOWN, visual_block, .loop
        BINDSHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.V.DOWN, visual_line, .loop

        ; Comprueba las teclas de direccion
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFT.DOWN, move_cursor_left, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHT.DOWN, move_cursor_right, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.UP.DOWN, move_cursor_up, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.DOWN.DOWN, move_cursor_down, .loop

        ; Comprueba si es la 'I' para el modo insertion
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.I.DOWN, insertion, .loop

        ; Comprueba si es el CTRL-C para retornar
        BINDCTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.C.DOWN, void, .ret

        jmp .loop

    .ret:
        popad
        ret