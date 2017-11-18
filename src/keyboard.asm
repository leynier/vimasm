section .data

; Previous scancode.
key db 0

section .text

; scan()
; Scan for new keypress. Returns new scancode if changed since last call, zero
; otherwise.
global scan
scan:
    ; Scan.
    in al, 0x60

    ; If scancode has changed, update key and return it.
    cmp al, [key]
    je scan.zero
    mov [key], al
    jmp scan.ret

    ; Otherwise, return zero.
    scan.zero:
        xor eax, eax
        jmp scan

    scan.ret:
        ret
