section .text

extern KEY

; scan()
; Scan for new keypress. Returns new scancode if changed since last call, zero
; otherwise.
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
