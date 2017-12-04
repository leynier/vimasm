%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE
extern POS_POINTER
extern POS_SELECT
extern START_DOCUMENT
extern POS_DOCUMENT
extern TOGGLE_CTRL
extern TOGGLE_SHIFT

extern scan
extern paint
extern insertion
extern move_cursor_left
extern move_cursor_right
extern move_cursor_down
extern move_cursor_up
extern void

global visual
visual:
    pushad
    mov dword [TOGGLE_CTRL], 0
    mov dword [TOGGLE_SHIFT], 0
    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    mov [POS_SELECT], eax

    .loop:
        mov dword [MODE], MODE_VISUAL
        call paint
        call scan
        REG_CLEAR

        ; Comprueba el ESC
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.ESC.DOWN, void, .ret

        ; Comprueba las teclas de direccion
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFT.DOWN, move_cursor_left, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHT.DOWN, move_cursor_right, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.UP.DOWN, move_cursor_up, .loop
        BINDNORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.DOWN.DOWN, move_cursor_down, .loop

        jmp .loop

    .ret:
        popad
        ret