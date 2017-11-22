%include "utils.mac"
%include "keyboard.mac"

section .text

extern START_DOCUMENT
extern TOGGLE_SHIFT
extern ASCII_NORMAL
extern ASCII_EXTRA
extern ASCII_CODE

; update_shift(dword hex tecla)
; Actualiza el TOGGLE_SHIFT y el ASCII_CODE
global update_shift
update_shift:
    push ebp
    mov ebp, esp
    push ebx

    xor eax, eax
    xor ebx, ebx

    mov ebx, [ebp + 8] ; Hexadecimal que representa la tecla pulsada

    cmp ebx, KEY.LEFTSHIFT.DOWN
    jne not_leftshiftdown
    mov dword [TOGGLE_SHIFT], 1
    mov dword [ASCII_CODE], ASCII_EXTRA
    mov eax, 1
    jmp update_shift.ret
    not_leftshiftdown:
    cmp ebx, KEY.LEFTSHIFT.UP
    jne not_leftshiftup
    mov dword [TOGGLE_SHIFT], 0
    mov dword [ASCII_CODE], ASCII_NORMAL
    mov eax, 1
    jmp update_shift.ret
    not_leftshiftup:
    cmp ebx, KEY.RIGHTSHIFT.DOWN
    jne not_rightshiftdown
    mov dword [TOGGLE_SHIFT], 1
    mov dword [ASCII_CODE], ASCII_EXTRA
    mov eax, 1
    jmp update_shift.ret
    not_rightshiftdown:
    cmp ebx, KEY.RIGHTSHIFT.UP
    jne not_rightshiftup
    mov dword [TOGGLE_SHIFT], 0
    mov dword [ASCII_CODE], ASCII_NORMAL
    mov eax, 1
    jmp update_shift.ret
    not_rightshiftup:

    update_shift.ret:
        pop ebx
        pop ebp
        ret 4


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