%include "utils.mac"
%include "keyboard.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern TOGGLE_SHIFT
extern ASCII_NORMAL
extern ASCII_EXTRA
extern ASCII_CODE
extern KEY
extern translate
extern move_cursor

; end_line()
; Metodo que cumple la funcion de fin de linea con el ENTER
global end_line
end_line:
    pushad
    REG_CLEAR

    mov eax, [POS_POINTER]
    mov ebx, 80
    div ebx
    sub ebx, edx
    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]
    push ecx
    push ebx
    call translate
    push ebx
    call move_cursor

    end_line.ret:
        popad
        ret

; erase()
; Metodo que cumple la funcion de borrar con el BACKSPACE
global erase
erase:
    pushad

    mov edx, [POS_POINTER]
    call move_cursor_left
    cmp edx, [POS_POINTER]
    je erase.ret
    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]
    push ecx
    push dword -1
    call translate

    erase.ret:
        popad
        ret

; move_cursor_left()
; Mueve el cursor hacia la izquierda
global move_cursor_left
move_cursor_left:
    push -1
    call move_cursor
    ret

; move_cursor_right()
; Mueve el cursor hacia la derecha
global move_cursor_right
move_cursor_right:
    push 1
    call move_cursor
    ret

; move_cursor_down
; Mueve el cursor hacia abajo
global move_cursor_down
move_cursor_down:
    push 80
    call move_cursor
    ret

; move_cursor_up
; Mueve el cursor hacia arriba
global move_cursor_up
move_cursor_up:
    push -80
    call move_cursor
    ret

; shift_down()
; Activa el TOGGLE_SHIFT para saber que la tecla shift esta presionada
global shift_down
shift_down:
    mov dword [TOGGLE_SHIFT], 1
    mov dword [ASCII_CODE], ASCII_EXTRA
    mov eax, 1
    ret

; shift_up()
; Desactiva el TOGGLE_SHIFT para saber que la tecla shift NO esta presionada
global shift_up
shift_up:
    mov dword [TOGGLE_SHIFT], 0
    mov dword [ASCII_CODE], ASCII_NORMAL
    mov eax, 1
    ret

; scan()
; Espera hasta que se presione una tecla y la guarda en KEY
global scan
scan:
    push eax
    scan.loop:
        xor eax, eax
        in al, 0x64
        test al, 1
        je scan.loop
        test al, 32
        jne scan.loop
        in al, 0x60
        mov [KEY], eax
        jmp scan.ret

    scan.ret:
        pop eax
        ret
