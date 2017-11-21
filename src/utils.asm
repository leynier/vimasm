%include "utils.mac"

section .text

global translate
translate:
    push ebp
    mov ebp, esp
    pusha

    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    mov edx, [ebp + 16] ; Start Direction Array
    mov eax, [ebp + 12] ; Pos Array
    mov ebx, [ebp + 8] ; Pos Translate

    cmp ebx, 0 ; Compara si es para la derecha o izquierda la translacion
    jg translate.right
    jl translate.left
    jmp translate.ret

    translate.right:
        mov edi, edx
        add edi, DOCUMENT_LEN
        dec edi
        mov esi, edi
        sub esi, ebx
        add eax, edx
        mov ecx, esi
        sub ecx, eax
        inc ecx
        std
        ciclo1:
            movsb
            loop ciclo1
        mov edi, eax
        mov ecx, ebx
        xor eax, eax
        cld
        ciclo2:
            stosb
            loop ciclo2
        jmp translate.ret
    
    translate.left:
        mov edi, edx
        add edi, eax
        mov esi, edi
        sub esi, ebx
        mov ecx, edx
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
        ciclo4:
            stosb
            loop ciclo4
        jmp translate.ret

    translate.ret:
        popa
        pop ebp
        ret 12