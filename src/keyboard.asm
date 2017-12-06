%include "utils.mac"
%include "keyboard.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern TOGGLE_SHIFT
extern TOGGLE_CTRL
extern ASCII_NORMAL
extern ASCII_EXTRA
extern ASCII_CODE
extern KEY
extern TIMER

extern traslate
extern move_cursor
extern fix_eol
extern interval
extern paint_cursor

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
    ; En 'ebx' esta la cantidad de posicion para llegar al final de linea

    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]
    push ecx
    push ebx
    call traslate
    ; Tralado o empujo el texto las posiciones necesarias, antes calculadas

    mov byte [START_DOCUMENT + ecx], EOL
    ; Coloco el simbolo de fin de linea

    push ebx
    call move_cursor
    ; Muevo el cursor hacia donde le corresponde
    call fix_eol

    .ret:
        popad
        ret

; erase()
; Metodo que cumple la funcion de borrar con el BACKSPACE
global erase
erase:
    pushad
    REG_CLEAR

    ; Comprubo si no es el principio del documento
    cmp dword [POS_DOCUMENT], 0
    jne .not_start
    cmp dword [POS_POINTER], 0
    jne .not_start
    jmp .ret

    .not_start:
        ; Calculo cuantas posiciones tengo que correr para la izquierda
        ; Porque si habia un salto de linea o algo por el estilo no es
        ; solamente una posicion.
        call move_cursor_left
        mov eax, [POS_DOCUMENT]
        add eax, [POS_POINTER]
        mov ebx, eax
        .loop:
            inc ebx
            dec ecx
            cmp byte [START_DOCUMENT + ebx], 0
            je .loop
        push eax
        push ecx
        call traslate
        
        call fix_eol
    
    .ret:
        popad
        ret

; move_cursor_left()
; Mueve el cursor hacia la izquierda
global move_cursor_left
move_cursor_left:
    pushad
    push -1
    call move_cursor

    .loop:
        ; Mueve el cursor hacia la izquierda hasta que encuentre una caracter diferente de cero
        mov eax, START_DOCUMENT
        add eax, [POS_DOCUMENT]
        add eax, [POS_POINTER]
        cmp byte [eax], 0
        jne .ret
        push -1
        call move_cursor
        jmp .loop     

    .ret:
        popad
        ret

; move_cursor_right()
; Mueve el cursor hacia la derecha
global move_cursor_right
move_cursor_right:
    pushad
    mov eax, START_DOCUMENT
    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    cmp byte [eax], EOF
    je .ret
    push 1
    call move_cursor

    .loop:
    ; Mueve el cursor hacia la derecha hasta que encuentre una caracter diferente de cero
        mov eax, START_DOCUMENT
        add eax, [POS_DOCUMENT]
        add eax, [POS_POINTER]
        cmp byte [eax], 0
        jne .ret
        push 1
        call move_cursor
        jmp .loop     

    .ret:
        popad
        ret

; move_cursor_down
; Mueve el cursor hacia abajo
global move_cursor_down
move_cursor_down:
    pushad
    push 80
    call move_cursor

    .loop:
        ; Mueve el cursor hacia la izquierda hasta que encuentre una caracter diferente de cero
        mov eax, START_DOCUMENT
        add eax, [POS_DOCUMENT]
        add eax, [POS_POINTER]
        cmp byte [eax], 0
        jne .ret
        push -1
        call move_cursor
        jmp .loop     

    .ret:
        popad
        ret

; move_cursor_up
; Mueve el cursor hacia arriba
global move_cursor_up
move_cursor_up:
    pushad
    push -80
    call move_cursor

    .loop:
        ; Mueve el cursor hacia la izquierda hasta que encuentre una caracter diferente de cero
        mov eax, START_DOCUMENT
        add eax, [POS_DOCUMENT]
        add eax, [POS_POINTER]
        cmp byte [eax], 0
        jne .ret
        push -1
        call move_cursor
        jmp .loop     

    .ret:
        popad
        ret

; shift_down()
; Activa el TOGGLE_SHIFT para saber que la tecla shift esta presionada
global shift_down
shift_down:
    mov dword [TOGGLE_SHIFT], 1
    mov dword [ASCII_CODE], ASCII_EXTRA
    ret

; shift_up()
; Desactiva el TOGGLE_SHIFT para saber que la tecla shift NO esta presionada
global shift_up
shift_up:
    mov dword [TOGGLE_SHIFT], 0
    mov dword [ASCII_CODE], ASCII_NORMAL
    ret

; ctrl_down()
; Activa el TOGGLE_CTRL para saber que la tecla ctrl esta presionada
global ctrl_down
ctrl_down:
    mov dword [TOGGLE_CTRL], 1
    ret

; ctrl_up()
; Desactiva el TOGGLE_CTRL para saber que la tecla ctrl NO esta presionada
global ctrl_up
ctrl_up:
    mov dword [TOGGLE_CTRL], 0
    ret

; scan()        
; Espera hasta que se presione una tecla y la guarda en KEY
global scan
scan:
    push eax
    .loop:
        cmp dword [TIMER], 0
        jne .blinking
        cmp dword [TIMER + 4], 0
        jne .blinking
        jmp .not_blinking
        .blinking:
        push dword 500
        push dword TIMER
        call interval
        cmp eax, 0
        je .not_blinking
        call paint_cursor
        .not_blinking:
        xor eax, eax
        in al, 0x64
        test al, 1
        je .loop
        test al, 32
        jne .loop
        in al, 0x60
        mov [KEY], eax
        jmp .ret

    .ret:
        pop eax
        ret
