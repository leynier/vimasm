;v

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

extern scan
extern paint
extern insertion
extern move_cursor_left
extern move_cursor_right
extern move_cursor_down
extern move_cursor_up

global visual
visual:
    pushad
    mov eax, START_DOCUMENT
    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    mov [POS_SELECT], eax

    visual.loop:
        mov dword [MODE], MODE_VISUAL
        REG_CLEAR

        call paint
        call scan

        ; Comprueba el ESC
        cmp dword [KEY], KEY.ESC.DOWN
        je visual.ret

        ; Comprueba las flechas de direccion
        BIND [KEY], KEY.LEFT.DOWN, move_cursor_left
        BIND [KEY], KEY.RIGHT.DOWN, move_cursor_right
        BIND [KEY], KEY.UP.DOWN, move_cursor_up
        BIND [KEY], KEY.DOWN.DOWN, move_cursor_down

        ; Comprueba si se presiono la s
        ;BIND [KEY], KEY.S.DOWN, insertion

        jmp visual.loop

    visual.ret:
        popad
        ret