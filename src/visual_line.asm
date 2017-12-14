%include "keyboard.mac"
%include "utils.mac"

section .text

extern KEY
extern MODE
extern TOGGLE_CTRL
extern TOGGLE_SHIFT
extern POS_POINTER
extern POS_SELECT
extern START_DOCUMENT
extern POS_DOCUMENT
extern BAR_BOTTOM
extern VISUAL_LINE_MSG

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
extern void
extern copy_select

global visual_line
visual_line:
    pushad
    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    mov [POS_SELECT], eax

    .loop:
        mov dword [MODE], MODE_VISUAL_LINE
        mov dword [BAR_BOTTOM], VISUAL_LINE_MSG
        call paint
        call scan
        REG_CLEAR

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

        ; Comprueba las teclas de direccion
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFT.DOWN, move_cursor_left, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHT.DOWN, move_cursor_right, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.UP.DOWN, move_cursor_up, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.DOWN.DOWN, move_cursor_down, .loop

        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.Y.DOWN, copy_select, .ret

        jmp .loop

    .ret:
        popad
        ret