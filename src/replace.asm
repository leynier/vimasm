%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE
extern TOGGLE_CTRL
extern TOGGLE_SHIFT
extern BAR_BOTTOM
extern REPLACE_MSG

extern scan
extern paint
extern move_cursor_left
extern move_cursor_right
extern move_cursor_down
extern move_cursor_up
extern shift_down
extern shift_up
extern ctrl_down
extern ctrl_up
extern erase
extern end_line
extern re_write
extern void
extern caps_down
extern paste_select
extern erase_startword
extern erase_startline

global replace
replace:
    pushad

    .loop:
        mov dword [MODE], MODE_REPLACE
        mov dword [BAR_BOTTOM], REPLACE_MSG
        call paint
        call scan
        REG_CLEAR

        BIND [KEY], KEY.CAPS.DOWN, caps_down, .loop

        ; Comprueba el ESC
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.ESC.DOWN, void, .ret

        ; Comprueba el control
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.DOWN, ctrl_down, .loop
        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.UP, ctrl_up, .loop

        ; Comprueba el shift
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.DOWN, shift_down, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.DOWN, shift_down, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.UP, shift_up, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.UP, shift_up, .loop

        ; Comprueba el BACKSPACE
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.BACK.DOWN, erase, .loop

        ; Comprueba las teclas de direccion
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFT.DOWN, move_cursor_left, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHT.DOWN, move_cursor_right, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.UP.DOWN, move_cursor_up, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.DOWN.DOWN, move_cursor_down, .loop

        ; Comprueba el BACKSPACE
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.BACK.DOWN, erase, .loop

        ; Comprueba el ENTER
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.ENTER.DOWN, end_line, .loop
        
        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.Y.DOWN, paste_select, .loop

        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.W.DOWN, erase_startword, .loop

        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.U.DOWN, erase_startline, .loop

        call re_write

        jmp .loop

    .ret:
        popad
        ret