%include "utils.mac"
%include "keyboard.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern ASCII_NORMAL
extern ASCII_EXTRA
extern ASCII_CODE
extern KEY
extern move_cursor_right

; write()
; Metodo que comprueba si la tecla presionada fue una tecla valida para escribir, y la escribe en el documento
global write
write:
    pushad

    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    ; Comprueba si la tecla es de escritura
    IN_RANGE [KEY], KEY.ONE.DOWN, KEY.EQUAL.DOWN
    IN_RANGE [KEY], KEY.Q.DOWN, KEY.BRACECLOSE.DOWN
    IN_RANGE [KEY], KEY.A.DOWN, KEY.ACCENTLOW.DOWN
    IN_RANGE [KEY], KEY.BACKSLASH.DOWN, KEY.SLASH.DOWN
    IN_RANGE [KEY], KEY.SPACE.DOWN, KEY.SPACE.DOWN

    cmp eax, 0
    je write.ret ; Si no termina el metodo

    mov edx, [ASCII_CODE]
    add edx, [KEY]
    mov bl, [edx]
    mov ecx, [POS_DOCUMENT]
    add ecx, [POS_POINTER]
    push ecx
    push dword 1
    call translate
    mov [START_DOCUMENT + ecx], bl
    call move_cursor_right

    write.ret:
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
    jge not_pos_pointer_less
        ; Como el cursor se volvio negativo hay que bajar el texto
        sub dword [POS_DOCUMENT], 80
        cmp dword [POS_DOCUMENT], 0
        jge not_pos_document_less
            ; El texto no puede bajar mas, ya se llego al principio
            add dword [POS_DOCUMENT], 80
            sub [POS_POINTER], eax
            jmp move_cursor.ret
        not_pos_document_less:
            ; Muevo el cursor hacia abajo, para que quede en la misma posicion
            push dword 80
            call move_cursor
            jmp move_cursor.ret
    not_pos_pointer_less:

    cmp dword [POS_POINTER], 1920
    jl not_pos_pointer_greater
        ; Como el cursor se salio de la pantalla hay que subir el texto
        add dword [POS_DOCUMENT], 80
        cmp dword [POS_DOCUMENT], DOCUMENT_LEN
        jl not_pos_document_greater
            ; El texto no puede subir mas, ya se llego al final
            sub dword [POS_DOCUMENT], 80
            sub [POS_POINTER], eax
            jmp move_cursor.ret
        not_pos_document_greater:
            ; Muevo el cursor hacia arriba, para que quede en la misma posicion
            push dword -80
            call move_cursor
            jmp move_cursor.ret
    not_pos_pointer_greater:

    move_cursor.ret:
        popad
        pop ebp
        ret 4

; translate(dword pos, dword desp)
; Tranlada el texto o documento X cantidad de casillas a partir de casilla deseada
global translate
translate:
    push ebp
    mov ebp, esp
    pushad

    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    mov eax, [ebp + 12] ; Posicion desde donde se quiere transladar el documento
    mov ebx, [ebp + 8] ; Cantidad de posiciones por transladar

    cmp ebx, 0 ; Compara si es para la derecha o izquierda la translacion
    jg translate.right
    jl translate.left
    jmp translate.ret

    translate.right:
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
        ciclo1:
            movsb
            loop ciclo1
        ; Rellena con ceros el espacio transladado
        mov edi, eax
        mov ecx, ebx
        xor eax, eax
        cld
        ciclo2:
            stosb
            loop ciclo2
        jmp translate.ret
    
    translate.left:
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
        ciclo3:
           movsb
           loop ciclo3
        xor eax, eax
        xor ecx, ecx
        sub ecx, ebx
        ; Rellenar al final con ceros
        ciclo4:
            stosb
            loop ciclo4
        jmp translate.ret

    translate.ret:
        popad
        pop ebp
        ret 8