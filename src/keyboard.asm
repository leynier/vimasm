section .text

extern KEY

; scan()
; Scan for new keypress. Returns new scancode if changed since last call, zero
; otherwise.
global scan
scan:
    xor eax, eax
    ; Scan.
    in al, 0x64

    test al, 1
    je scan.zero

    test al, 32
    jne scan.zero

    in al, 0x60
    mov [KEY], al
    jmp scan.ret

    ; Otherwise, return zero.
    scan.zero:
        jmp scan

    scan.ret:
        ret
