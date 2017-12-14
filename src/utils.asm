%include "utils.mac"
%include "keyboard.mac"
%include "video.mac"

section .data

global g
g dd 0

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern ASCII_NORMAL
extern ASCII_EXTRA
extern ASCII_CODE
extern KEY
extern TOGGLE_SHIFT
extern TOGGLE_CTRL
extern POS_SELECT
extern TOGGLE_CAPS

extern move_cursor_right
extern move_cursor_left
extern move_cursor_down
extern number

; fix_eol(dword pos)
; Metodo que corrige todos los saltos de linea
global fix_eol
fix_eol:
    pushad
    REG_CLEAR

    mov eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    dec eax ; Posicion desde la cual se debe arreglar los salto de linea

    .loop:
        inc eax
        cmp byte [START_DOCUMENT + eax], EOF
        je .ret
        cmp byte [START_DOCUMENT + eax], EOL
        jne .loop
            push eax
            xor ecx, ecx
            xor edx, edx
            mov ebx, COLS
            div ebx
            sub ebx, edx
            pop eax
            ; En 'ebx' esta la cantidad de posicion para llegar al final de linea
            mov edx, eax
            .loop2:
                inc edx
                inc ecx
                cmp byte [START_DOCUMENT + edx], 0
                je .loop2
            ; En 'ecx' esta la cantidad actual de espacio vacios
            mov byte [START_DOCUMENT + eax], 0
            mov edx, ebx
            sub edx, ecx
            ; En 'edx' queda la diferencia de espacios
            push eax
            push edx
            call traslate
            mov byte [START_DOCUMENT + eax], EOL
            add eax, ebx
            dec eax
            jmp .loop

    .ret:
        popad
        ret

; re_write()
; Metodo que comprueba si la tecla presionada fue una tecla valida para rescribir, y la rescribe en el documento
global re_write
re_write:
    pushad

    REG_CLEAR
    
    cmp dword [TOGGLE_CAPS], 1
    jne .continue
    mov dword [ASCII_CODE], ASCII_EXTRA
    cmp dword [TOGGLE_SHIFT], 1
    jne .continue
    mov dword [ASCII_CODE], ASCII_NORMAL

    .continue:

    ; Comprueba si la tecla es de escritura
    IN_RANGE [KEY], KEY.ONE.DOWN, KEY.EQUAL.DOWN
    IN_RANGE [KEY], KEY.BACKSLASH.DOWN, KEY.BACKSLASH.DOWN
    IN_RANGE [KEY], KEY.SPACE.DOWN, KEY.SPACE.DOWN
    IN_RANGE [KEY], KEY.BRACEOPEN.DOWN, KEY.BRACECLOSE.DOWN
    IN_RANGE [KEY], KEY.SEMICOLON.DOWN, KEY.ACCENTLOW.DOWN
    IN_RANGE [KEY],KEY.COMMA.DOWN, KEY.SLASH.DOWN
   
    cmp eax, 1
    jne .continue1
    cmp dword [TOGGLE_CAPS], 1
    jne .continue1
    mov dword [ASCII_CODE], ASCII_NORMAL
    cmp dword [TOGGLE_SHIFT], 1
    jne .continue1
    mov dword [ASCII_CODE], ASCII_EXTRA
    
    .continue1:
    
    IN_RANGE [KEY], KEY.Q.DOWN, KEY.P.DOWN
    IN_RANGE [KEY], KEY.A.DOWN, KEY.L.DOWN
    IN_RANGE [KEY], KEY.Z.DOWN, KEY.M.DOWN

    cmp eax, 0
    je .ret ; Si no termina el metodo

    mov edx, [ASCII_CODE]
    add edx, [KEY]
    mov bl, [edx]
    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]
    cmp byte [START_DOCUMENT + ecx], EOL
    je .traslate
    cmp byte [START_DOCUMENT + ecx], EOF
    je .traslate
    jmp .not_traslate
    .traslate:
    push ecx
    push dword 1
    call traslate
    .not_traslate:
    mov [START_DOCUMENT + ecx], bl
    call move_cursor_right
    call fix_eol

    .ret:
        popad
        ret

; write()
; Metodo que comprueba si la tecla presionada fue una tecla valida para escribir, y la escribe en el documento
global write
write:
    pushad

    REG_CLEAR

    cmp dword [TOGGLE_CAPS], 1
    jne .continue
    mov dword [ASCII_CODE], ASCII_EXTRA
    cmp dword [TOGGLE_SHIFT], 1
    jne .continue
    mov dword [ASCII_CODE], ASCII_NORMAL

    .continue:

    ; Comprueba si la tecla es de escritura
    IN_RANGE [KEY], KEY.ONE.DOWN, KEY.EQUAL.DOWN
    IN_RANGE [KEY], KEY.BACKSLASH.DOWN, KEY.BACKSLASH.DOWN
    IN_RANGE [KEY], KEY.SPACE.DOWN, KEY.SPACE.DOWN
    IN_RANGE [KEY], KEY.BRACEOPEN.DOWN, KEY.BRACECLOSE.DOWN
    IN_RANGE [KEY], KEY.SEMICOLON.DOWN, KEY.ACCENTLOW.DOWN
    IN_RANGE [KEY],KEY.COMMA.DOWN, KEY.SLASH.DOWN
    cmp eax, 1
    jne .continue1
    cmp dword [TOGGLE_CAPS], 1
    jne .continue1
    mov dword [ASCII_CODE], ASCII_NORMAL
    cmp dword [TOGGLE_SHIFT], 1
    jne .continue1
    mov dword [ASCII_CODE], ASCII_EXTRA
    
    .continue1:
    
    IN_RANGE [KEY], KEY.Q.DOWN, KEY.P.DOWN
    IN_RANGE [KEY], KEY.A.DOWN, KEY.L.DOWN
    IN_RANGE [KEY], KEY.Z.DOWN, KEY.M.DOWN

    cmp eax, 0
    je .ret ; Si no termina el metodo

    mov edx, [ASCII_CODE]
    add edx, [KEY]
    mov bl, [edx]
    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]
    push ecx
    push dword 1
    call traslate
    mov [START_DOCUMENT + ecx], bl
    call move_cursor_right
    call fix_eol

    .ret:
        popad
        ret

; move_cursor(dword pos)
; Mueve el cursor una X cantidad de posiciones
global move_cursor
move_cursor:
    push ebp
    mov ebp, esp
    pushad

    xor eax, eax

    mov eax, [ebp + 8] ; Numero de posiciones a mover el cursor

    add [POS_POINTER], eax ; Mover el cursor

    cmp dword [POS_POINTER], 0
    jge .not_pos_pointer_less
        ; Como el cursor se volvio negativo hay que bajar el texto
        sub dword [POS_DOCUMENT], COLS
        cmp dword [POS_DOCUMENT], 0
        jge .not_pos_document_less
            ; El texto no puede bajar mas, ya se llego al principio
            add dword [POS_DOCUMENT], COLS
            sub [POS_POINTER], eax
            jmp .ret
        .not_pos_document_less:
            ; Muevo el cursor hacia abajo, para que quede en la misma posicion
            push dword COLS
            call move_cursor
            jmp .ret
    .not_pos_pointer_less:

    cmp dword [POS_POINTER], SCREEN_LEN
    jl .not_pos_pointer_greater
        ; Como el cursor se salio de la pantalla hay que subir el texto
        add dword [POS_DOCUMENT], COLS
        cmp dword [POS_DOCUMENT], DOCUMENT_LEN
        jl .not_pos_document_greater
            ; El texto no puede subir mas, ya se llego al final
            sub dword [POS_DOCUMENT], COLS
            sub [POS_POINTER], eax
            jmp .ret
        .not_pos_document_greater:
            ; Muevo el cursor hacia arriba, para que quede en la misma posicion
            push dword COLSN
            call move_cursor
            jmp .ret
    .not_pos_pointer_greater:

    .ret:
        popad
        pop ebp
        ret 4

; traslate(dword pos, dword desp)
; Tranlada el texto o documento X cantidad de casillas a partir de casilla deseada
global traslate
traslate:
    push ebp
    mov ebp, esp
    pushad

    REG_CLEAR

    mov eax, [ebp + 12] ; Posicion desde donde se quiere transladar el documento
    mov ebx, [ebp + 8] ; Cantidad de posiciones por transladar

    cmp ebx, 0 ; Compara si es para la derecha o izquierda la translacion
    jg .right
    jl .left
    jmp .ret

    .right:
        ; Coloca el 'edi' al final de documento
        mov edi, START_DOCUMENT
        add edi, DOCUMENT_LEN
        dec edi
        ; Coloca el 'esi' 'ebx' posiciones antes del final del documento
        mov esi, edi
        sub esi, ebx
        ; Coloca en 'ecx' la cantidad de corrimientos que hay que hacer
        add eax, START_DOCUMENT
        mov ecx, esi
        sub ecx, eax
        inc ecx
        std
        .loop1:
            movsb
            loop .loop1
        ; Rellena con ceros el espacio transladado
        mov edi, eax
        mov ecx, ebx
        xor eax, eax
        cld
        .loop2:
            stosb
            loop .loop2
        jmp .ret
    
    .left:
        ; Coloca el 'edi' en la posicion desde donde se desea transladar el documento
        mov edi, START_DOCUMENT
        add edi, eax
        ; Coloca el 'esi' 'ebx' posiciones a la derecha de donde se quiere transladar
        mov esi, edi
        sub esi, ebx
        ; Coloca en 'ecx' la cantidad de corrimientos que se debe hacer
        mov ecx, START_DOCUMENT
        add ecx, DOCUMENT_LEN
        sub ecx, esi
        dec ecx
        cld
        .loop3:
           movsb
           loop .loop3
        xor eax, eax
        xor ecx, ecx
        sub ecx, ebx
        ; Rellenar al final con ceros
        .loop4:
            stosb
            loop .loop4
        jmp .ret

    .ret:
        popad
        pop ebp
        ret 8

global void
void:
    ret

; Reinicia el documento 
global reset_doc
reset_doc:
    pushad 
    REG_CLEAR
   
    .loop:
    cmp byte [START_DOCUMENT + ecx], EOF
    je .end
    mov byte [START_DOCUMENT + ecx], 0
    inc ecx
    jmp .loop
    
    .end:
    mov byte [START_DOCUMENT + ecx], 0
    mov byte [START_DOCUMENT], EOF
    
    popad
    ret

; El cursor se coloca en el inicio de la primera linea del documento
global jumpStart
jumpStart:
    pushad
    REG_CLEAR

    mov ecx, [number]

    cmp dword [TOGGLE_SHIFT], 1
    je .continue

    cmp dword [g], 0
    jne .continue
    mov dword [g], 1
    je .ret
    .continue:
    mov dword [g], 0
    mov dword [TOGGLE_SHIFT], 0

    mov eax, -1
    mul dword [POS_POINTER]
    push eax
    call move_cursor

    .loop:
    cmp dword [POS_DOCUMENT], 0
    je .loop1
    mov ebx, -80
    mul dword [POS_POINTER]
    push ebx
    call move_cursor
    jmp .loop

    .loop1:
    cmp ecx, 1
    jle .continue1
    mov eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    add eax, 1
    cmp dword [START_DOCUMENT + eax], EOF
    je .continue1
    call move_cursor_down
    dec ecx
    jmp .loop1
   
    .continue1:
    mov dword [number], 0

    .ret:
    popad
    ret

; El cursor se coloca en el inicio de la ultima linea del documento
global jumpEnd
jumpEnd:
    pushad
    REG_CLEAR

    .loop:
    mov eax, START_DOCUMENT
    add eax, [POS_DOCUMENT]
    add eax, [POS_POINTER]
    cmp byte [eax], EOF
    je .loop1
    call move_cursor_right
    jmp .loop

    .loop1:
    mov edx, 0
    mov eax, [POS_POINTER]
    mov ebx, 80
    div ebx
    cmp edx, 0
    je .ret
    call move_cursor_left
    jmp .loop1

    .ret:
    popad
    ret

global saveNumber
saveNumber:
    pushad
    REG_CLEAR

    mov eax, [number]
    mov ecx, 10
    mul ecx
    mov ecx, eax

    IN_RANGE [KEY], KEY.ONE.DOWN, KEY.ONE.DOWN
    cmp eax, 1
    jne .no1
    add ecx, 1
    jmp .ret
    .no1:
    IN_RANGE [KEY], KEY.TWO.DOWN, KEY.TWO.DOWN
    cmp eax, 1
    jne .no2
    add ecx, 2
    jmp .ret
    .no2:
    IN_RANGE [KEY], KEY.THREE.DOWN, KEY.THREE.DOWN
    cmp eax, 1
    jne .no3
    add ecx, 3
    jmp .ret
    .no3:
    IN_RANGE [KEY], KEY.FOUR.DOWN, KEY.FOUR.DOWN
    cmp eax, 1
    jne .no4
    add ecx, 4
    jmp .ret
    .no4:
    IN_RANGE [KEY], KEY.FIVE.DOWN, KEY.FIVE.DOWN
    cmp eax, 1
    jne .no5
    add ecx, 5
    jmp .ret
    .no5:
    IN_RANGE [KEY], KEY.SIX.DOWN, KEY.SIX.DOWN
    cmp eax, 1
    jne .no6
    add ecx, 6
    jmp .ret
    .no6:
    IN_RANGE [KEY], KEY.SEVEN.DOWN, KEY.SEVEN.DOWN
    cmp eax, 1
    jne .no7
    add ecx, 7
    jmp .ret
    .no7:
    IN_RANGE [KEY], KEY.EIGHT.DOWN, KEY.EIGHT.DOWN
    cmp eax, 1
    jne .no8
    add ecx, 8
    jmp .ret
    .no8:
    IN_RANGE [KEY], KEY.NINE.DOWN, KEY.NINE.DOWN
    cmp eax, 1
    jne .ret
    add ecx, 9

    .ret:
    mov dword [number], ecx
    popad
    ret

global emptyNumber
emptyNumber:
    pushad
    REG_CLEAR  

    IN_RANGE [KEY], KEY.ONE.DOWN, KEY.ZERO.DOWN
    IN_RANGE [KEY], KEY.ONE.UP, KEY.ZERO.UP
    IN_RANGE [KEY], KEY.G.DOWN, KEY.G.DOWN
    IN_RANGE [KEY], KEY.G.UP, KEY.G.UP
    IN_RANGE [KEY], KEY.CAPS.DOWN, KEY.CAPS.DOWN
    IN_RANGE [KEY], KEY.CAPS.UP, KEY.CAPS.UP
    IN_RANGE [KEY], KEY.LEFTSHIFT.DOWN, KEY.LEFTSHIFT.DOWN
    IN_RANGE [KEY], KEY.LEFTSHIFT.UP, KEY.LEFTSHIFT.UP
    IN_RANGE [KEY], KEY.RIGHTSHIFT.DOWN, KEY.RIGHTSHIFT.DOWN
    IN_RANGE [KEY], KEY.RIGHTSHIFT.UP, KEY.RIGHTSHIFT.UP
    IN_RANGE [KEY], KEY.CTRL.DOWN, KEY.CTRL.DOWN
    IN_RANGE [KEY], KEY.CTRL.UP, KEY.CTRL.UP   
    
    cmp eax, 1
    je .ret
    mov dword [number], 0

    .ret:
    popad
    ret