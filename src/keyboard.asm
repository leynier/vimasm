%include "utils.mac"
%include "keyboard.mac"
%include "video.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern POS_SELECT
extern TOGGLE_SHIFT
extern TOGGLE_CTRL
extern ASCII_NORMAL
extern ASCII_EXTRA
extern ASCII_CODE
extern KEY
extern TIMER
extern MODE_COPY
extern COPY_DOCUMENT
extern LEN_COPY
extern MODE
extern TOGGLE_CAPS
extern PARTITION_COPY

extern traslate
extern move_cursor
extern fix_eol
extern interval
extern paint_cursor
extern paste_partition
extern fix_block

; paste_select()
; Metodo que detecta el modo de pegar, segun el modo en quese haya copiado.
global paste_select
paste_select:
    pushad
    REG_CLEAR

    BIND [MODE_COPY], MODE_VISUAL, paste, .ret
    BIND [MODE_COPY], MODE_VISUAL_LINE, paste_line, .ret
    BIND [MODE_COPY], MODE_VISUAL_BLOCK, paste_block, .ret

    .ret:
        popad
        ret

; paste_block()
; Metodo que pega lo copiado en el modo visual block
global paste_block
paste_block:
    pushad
    REG_CLEAR

    mov eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]

    mov ecx, [LEN_COPY]

    jmp .start

    .loop:
        push eax
        add eax, 80
        push eax
        call fix_block

        .start:

        push eax
        push ebx
        call paste_partition

        add ebx, [PARTITION_COPY]
        cmp ebx, ecx
        jl .loop

    .ret:
        popad
        ret

; paste_line()
; Metodo que pega lo copiado en el modo visual line
global paste_line
paste_line:
    pushad
    REG_CLEAR

    mov eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    push eax
    mov ebx, 80
    div ebx
    sub ebx, edx
    pop eax
    add ebx, eax

    .find_right:
    cmp byte [START_DOCUMENT + eax], EOL
    jne .not_eol
        inc eax
        jmp .continue
    .not_eol:
    cmp byte [START_DOCUMENT + eax], EOF
    jne .not_eof
        push eax
        push dword 1
        call traslate
        mov byte [START_DOCUMENT + eax], EOL
        inc eax
        jmp .continue
    .not_eof:
    cmp eax, ebx
    jne .not_end
        jmp .continue
    .not_end:
        inc eax
        jmp .find_right
    .continue:

    mov ebx, [LEN_COPY]
    inc ebx

    push eax
    push ebx
    call traslate

    mov esi, COPY_DOCUMENT
    mov edi, START_DOCUMENT
    add edi, eax

    mov ecx, [LEN_COPY]
    inc ecx

    .loop:
        movsb
        loop .loop

    call fix_eol

    .ret:
        popad
        ret

; paste()
; Metodo que pega lo copiado en el modo visual
global paste
paste:
    pushad
    REG_CLEAR

    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]

    mov ebx, [LEN_COPY]
    inc ebx

    push ecx
    push ebx
    call traslate

    mov esi, COPY_DOCUMENT
    mov edi, START_DOCUMENT
    add edi, ecx

    mov ecx, [LEN_COPY]
    inc ecx

    .loop:
        movsb
        loop .loop

    call fix_eol

    .ret:
        popad
        ret

; copy_select()
; Metodo que detecta el modo de copiar, segun el modo en el que se este.
global copy_select
copy_select:
    pushad
    REG_CLEAR

    BIND [MODE], MODE_VISUAL, copy, .ret
    BIND [MODE], MODE_VISUAL_LINE, copy_line, .ret
    BIND [MODE], MODE_VISUAL_BLOCK, copy_block, .ret

    .ret:
        popad
        ret

; copy_block()
; Metodo que copia en el modo visual block
global copy_block
copy_block:
    pushad
    REG_CLEAR

    mov dword [MODE_COPY], MODE_VISUAL_BLOCK

    mov eax, [POS_SELECT]
    mov ebx, [POS_DOCUMENT]
    add ebx, [POS_POINTER]

    cmp eax, ebx
    jle .not_swap
        mov ecx, eax
        mov eax, ebx
        mov ebx, ecx
    .not_swap:
    
    push eax
    push ebx

    mov esi, eax
    mov edi, ebx

    mov ebx, COLS

    xor edx, edx
    mov eax, esi
    div ebx
    mov esi, edx

    xor edx, edx
    mov eax, edi
    div ebx
    mov edi, edx

    pop ebx
    pop eax

    cmp esi, edi
    jle .not_swap2
        mov ecx, esi
        mov esi, edi
        mov edi, ecx
        mov ecx, edi
        sub ecx, esi
        sub eax, ecx
        add ebx, ecx
    .not_swap2:

    mov ecx, edi
    sub ecx, esi

    mov ecx, edi
    sub ecx, esi

    inc ecx
    mov [PARTITION_COPY], ecx

    push eax
    push ebx
    push ecx

    sub ebx, eax
    mov eax, ebx
    xor edx, edx
    mov ebx, 80
    div ebx
    inc eax
    mul ecx
    mov edx, eax

    pop ecx
    pop ebx
    pop eax
    dec ecx

    mov [LEN_COPY], edx

    sub eax, COLS
    sub ebx, ecx
    inc ecx
    xor edx, edx
    .start_loop:
        add eax, COLS
        push eax
        push ebx
        push ecx
        .main_loop:
            mov bl, [START_DOCUMENT + eax]
            mov [COPY_DOCUMENT + edx], bl
            inc edx
            inc eax
            loop .main_loop
        pop ecx
        pop ebx
        pop eax
        cmp eax, ebx
        jl .start_loop

    mov eax, COPY_DOCUMENT
    mov ecx, [LEN_COPY]
    inc ecx
    .loop:
        cmp byte [eax], EOF
        je .not_valid
        cmp byte [eax], EOL
        je .not_valid
        cmp byte [eax], 0
        je .not_valid
        jmp .valid
        .not_valid:
            mov byte [eax], ' '
        .valid:
        inc eax
        loop .loop

    .ret:
        popad
        ret

; copy_line()
; Metodo que copia en el modo visual line
global copy_line
copy_line:
    pushad
    REG_CLEAR

    mov dword [MODE_COPY], MODE_VISUAL_LINE

    mov eax, [POS_SELECT]
    mov ebx, [POS_DOCUMENT]
    add ebx, [POS_POINTER]

    cmp eax, ebx
    jle .not_swap
        mov ecx, ebx
        mov ebx, eax
        mov eax, ecx
    .not_swap:

    push eax
    push ebx
        xor edx, edx
        mov ecx, eax
        mov ebx, 80
        div ebx
        sub ecx, edx
    pop ebx
    pop eax

    mov eax, ecx

    push eax
    push ebx
        xor edx, edx
        mov ecx, ebx
        mov eax, ebx
        mov ebx, 80
        div ebx
        sub ebx, edx
        add ecx, ebx
    pop ebx
    pop eax

    mov ebx, ecx

    mov esi, START_DOCUMENT
    mov edi, COPY_DOCUMENT

    add esi, eax
 
    inc ebx

    .find_left:
    dec ebx
    cmp byte [START_DOCUMENT + ebx], 0
    je .find_left

    cmp byte [START_DOCUMENT + ebx], EOF
    jne .not_eof
    inc ebx
    .not_eof:

    mov ecx, ebx
    sub ecx, eax

    dec ecx
    mov [LEN_COPY], ecx
    inc ecx

    .loop:
        movsb
        loop .loop

    mov ecx, COPY_DOCUMENT
    add ecx, [LEN_COPY]
    cmp byte [ecx], EOF
    jne .not_equal
        mov byte [ecx], EOL
    .not_equal:

    .ret:
        popad
        ret

; copy()
; Metodo que copia en el modo visual
global copy
copy:
    pushad
    REG_CLEAR

    mov dword [MODE_COPY], MODE_VISUAL

    mov esi, START_DOCUMENT
    mov edi, COPY_DOCUMENT

    mov ebx, [POS_DOCUMENT]
    add ebx, [POS_POINTER]

    cmp [POS_SELECT], ebx
    jg .great
        mov eax, ebx
        sub eax, [POS_SELECT]
        add esi, [POS_SELECT]
        jmp .continue
    .great:
        mov eax, [POS_SELECT]
        sub eax, ebx
        add esi, ebx
    .continue:
        mov [LEN_COPY], eax

    mov ecx, [LEN_COPY]
    inc ecx

    .loop:
        movsb
        loop .loop

    mov ecx, COPY_DOCUMENT
    add ecx, [LEN_COPY]
    cmp byte [ecx], EOF
    jne .not_equal
        mov byte [ecx], ' '
    .not_equal:

    .ret:
        popad
        ret

; end_line()
; Metodo que cumple la funcion de fin de linea con el ENTER
global end_line
end_line:
    pushad
    REG_CLEAR

    mov eax, [POS_POINTER]
    mov ebx, COLS
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

global erase_startline
erase_startline:
    pushad
    REG_CLEAR

    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    dec eax
    mov ecx, eax
    mov ebx, 80
    div ebx
    mov eax, ecx
    sub eax, edx

    push eax
    sub eax, ecx
    dec eax
    push eax
    call traslate
    push eax
    call move_cursor
    call fix_eol

    .ret:
        popad
        ret

global erase_startword
erase_startword:
    pushad
    REG_CLEAR

    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    mov ebx, eax
    dec eax

    .loop:
    cmp eax, 0
    jl .continue
        cmp byte [START_DOCUMENT + eax], ' '
        je .continue
        cmp byte [START_DOCUMENT + eax], 0
        je .continue
        cmp byte [START_DOCUMENT + eax], EOF
        je .continue
        cmp byte [START_DOCUMENT + eax], EOL
        je .continue
        dec eax
        jmp .loop
    .continue:
    inc eax
    push eax
    sub eax, ebx
    push eax
    call traslate
    push eax
    call move_cursor
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
    push COLS
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
    push COLSN
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

; caps_down()
; Activa y desactiva el TOGGLE_CAPS para saber que el estado de la tecla CapsLock
global caps_down
caps_down:
    cmp dword [TOGGLE_CAPS], 1
    jne .activate
    mov dword [TOGGLE_CAPS], 0
    mov dword [ASCII_CODE], ASCII_NORMAL
    jmp .ret
    .activate:
    mov dword [TOGGLE_CAPS], 1
    mov dword [ASCII_CODE], ASCII_EXTRA
    .ret:
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
