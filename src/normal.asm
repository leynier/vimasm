%include "keyboard.mac"
%include "utils.mac"

section .data

global number
number dd 0

section .text

extern KEY
extern MODE
extern TOGGLE_SHIFT
extern TOGGLE_CTRL
extern BAR_BOTTOM
extern NORMAL_MSG
extern TIMER
extern TOGGLE_CAPS

extern scan
extern paint
extern insertion
extern visual
extern visual_block
extern visual_line
extern replace
extern shift_down
extern shift_up
extern ctrl_down
extern ctrl_up
extern move_cursor_left
extern move_cursor_right
extern move_cursor_down
extern move_cursor_up
extern void
extern paste_select
extern caps_down
extern jumpStart
extern jumpEnd
extern saveNumber
extern emptyNumber

global normal
normal:
    pushad

    rdtsc
    mov [TIMER], eax
    mov [TIMER + 4], edx

    .loop:
        mov dword [MODE], MODE_NORMAL
        mov dword [BAR_BOTTOM], NORMAL_MSG
        REG_CLEAR
        call paint
        call scan

        call emptyNumber
       
        BIND [KEY], KEY.CAPS.DOWN, caps_down, .loop

        ; Comprueba el control
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.DOWN, ctrl_down, .loop
        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.UP, ctrl_up, .loop

        ; Comprueba el shift
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.DOWN, shift_down, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.DOWN, shift_down, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.UP, shift_up, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.UP, shift_up, .loop

        ; Comprueba la combinacion con 'V' para entrar a los modos visuales
        BIND_CAPS [KEY], [TOGGLE_CAPS], [TOGGLE_SHIFT], KEY.V.DOWN, visual, .loop
        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.V.DOWN, visual_block, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.V.DOWN, visual_line, .loop
        BIND_SHIFT [KEY], [TOGGLE_SHIFT], [TOGGLE_CAPS], KEY.V.DOWN, visual_line, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.V.DOWN, visual, .loop

        ; Comprueba las teclas de direccion
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFT.DOWN, move_cursor_left, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHT.DOWN, move_cursor_right, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.UP.DOWN, move_cursor_up, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.DOWN.DOWN, move_cursor_down, .loop

        ; Comprueba el 'H', 'J', 'K', 'L' para los moivmientos
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.H.DOWN, move_cursor_left, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.L.DOWN, move_cursor_right, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.K.DOWN, move_cursor_up, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.J.DOWN, move_cursor_down, .loop

        ; Comprueba si es la 'I' para el modo insertion
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.I.DOWN, insertion, .loop

        ; Comprueba si es el Shift-R para el modo remplazar
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.R.DOWN, replace, .loop
        BIND_SHIFT [KEY], [TOGGLE_SHIFT], [TOGGLE_CAPS], KEY.R.DOWN, replace, .loop

        ; Comprueba los saltos al comienzo, a una linea especifica y al final del documento (g y  shift+g)
        BIND_CAPS [KEY], [TOGGLE_CAPS], [TOGGLE_SHIFT], KEY.G.DOWN, jumpStart, .loop
        cmp dword [number], 0
        je .toEnd
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.G.DOWN, jumpStart, .loop
        BIND_SHIFT [KEY], [TOGGLE_SHIFT], [TOGGLE_CAPS], KEY.G.DOWN, jumpStart, .loop
        .toEnd:
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.G.DOWN, jumpEnd, .loop
        BIND_SHIFT [KEY], [TOGGLE_SHIFT], [TOGGLE_CAPS], KEY.G.DOWN, jumpEnd, .loop
        BIND_NORMAL [KEY],[TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.G.DOWN, jumpStart, .loop

        ; Comprueba si es el CTRL-C para retornar
        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.C.DOWN, void, .ret

        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.P.DOWN, paste_select, .loop

        IN_RANGE [KEY], KEY.ONE.DOWN, KEY.ZERO.DOWN
        cmp eax, 1
        jne .loop
        call saveNumber

        jmp .loop

    .ret:
        popad
        ret