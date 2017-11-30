;v

%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE

extern scan
extern paint
extern insertion

global visual
visual:
    mov dword [MODE], MODE_VISUAL
    call paint
    REG_CLEAR
    call scan

    ; Comprueba si se presiono la s
    cmp dword [KEY], KEY.S.DOWN
    je insertion

    ; Comprueba el ESC
    cmp dword [KEY], KEY.ESC.DOWN
    je visual.ret

    jmp visual

    visual.ret:
       ret