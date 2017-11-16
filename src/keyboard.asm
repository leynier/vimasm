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
  je .zero
  mov [key], al
  jmp .ret

  ; Otherwise, return zero.
  .zero:
    xor eax, eax
    jmp scan

  .ret:
    ret
