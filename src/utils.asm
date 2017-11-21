%include "utils.mac"

section .text

global tranlate
tranlate:
    push ebp
    mov ebp, esp
    pusha

    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    mov edx, [ebp + 8] ; Start Direction Array
    mov eax, [ebp + 12] ; Pos Array
    mov ebx, [ebp + 16] ; Pos Tranlate

    cmp ebx, 0 ; Compara si es para la derecha o izquierda la translacion
    jg tranlate.right
    jl tranlate.left
    jmp tranlate.ret

    tranlate.right:
        mov edi, edx
        add edi, DOCUMENT_LEN ; Coloco edi en el final del array
        mov esi, edi
        sub esi, ebx ; Coloco esi en el final menos k del array, k = Pos Tranlate
        add eax, edx ; Convierto Pos Array en Direction Pos Array
        mov ecx, esi
        sub ecx, eax
        inc ecx
        std
        ciclo:
            movsb
            loop ciclo
        mov edi, eax
        xor eax, eax
        mov ecx, ebx
        cld
        ciclo2:
            stosb
            loop ciclo2
        jmp tranlate.ret
    
    tranlate.left:
        mov edi, edx
        add edi, eax
        mov esi, edi
        sub esi, ebx
        mov ecx, edx
        add ecx, DOCUMENT_LEN
        sub ecx, esi
        cld
        ciclo3:
           movsb
           loop ciclo3
        xor eax, eax
        xor ecx, ecx
        sub ecx, ebx
        ciclo4:
            stosb
            loop ciclo4
        jmp tranlate.ret

    tranlate.ret:
        popa
        pop ebp
        ret 12