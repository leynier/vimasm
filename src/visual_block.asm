;ctrl v
%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE
extern TOGGLE_CTRL

extern insertion
extern scan
extern paint

global visual_block
visual_block:
    mov dword [TOGGLE_CTRL], 0
    mov dword [MODE], MODE_VISUAL_BLOCK
    call paint
    REG_CLEAR
    call scan

    ; Comprueba el ESC
    cmp dword [KEY], KEY.ESC.DOWN
    je visual_block.ret

    ; Comprueba si se presiono la s
    ;BIND [KEY], KEY.S.DOWN, insertion

    jmp visual_block

    visual_block.ret:
        ret