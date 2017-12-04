;shift v
%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE
extern TOGGLE_SHIFT

extern scan
extern paint
extern insertion

global visual_line
visual_line:
    mov dword [TOGGLE_SHIFT], 0
    mov dword [MODE], MODE_VISUAL_LINE
    call paint
    REG_CLEAR
    call scan

    ; Comprueba el ESC
    cmp dword [KEY], KEY.ESC.DOWN
    je visual_line.ret

    ; Comprueba si se presiono la s
    ;BIND [KEY], KEY.S.DOWN, insertion

    jmp visual_line

    visual_line.ret:
        ret