%include "video.mac"
%include "keyboard.mac"
%include "utils.mac"

section .data

ASCII_NORMAL db 0x00, 0x1B, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x2D, 0x3D, 0x08, 0x09, 0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69, 0x6F, 0x70, 0x5B, 0x5D, 0x0D, 0x00, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68, 0x6A, 0x6B, 0x6C, 0x3B, 0x27, 0x60, 0x00, 0x5C, 0x7A, 0x78, 0x63, 0x76, 0x62, 0x6E, 0x6D, 0x2C, 0x2E, 0x2F, 0x00, 0x2A, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x38, 0x39, 0x2D, 0x34, 0x35, 0x36, 0x2B, 0x31, 0x32, 0x33, 0x30, 0x2E
ASCII_EXTRA db 0x00, 0x1B, 0x21, 0x40, 0x23, 0x24, 0x25, 0x5E, 0x26, 0x2A, 0x28, 0x29, 0x5F, 0x2B, 0x08, 0x09, 0x51, 0x57, 0x45, 0x52, 0x54, 0x59, 0x55, 0x49, 0x4F, 0x50, 0x7B, 0x7D, 0x0D, 0x00, 0x41, 0x53, 0x44, 0x46, 0x47, 0x48, 0x4A, 0x4B, 0x4C, 0x3A, 0x22, 0x7E, 0x00, 0x7C, 0x5A, 0x58, 0x43, 0x56, 0x42, 0x4E, 0x4D, 0x3C, 0x3E, 0x3F, 0x00, 0x2A, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x38, 0x39, 0x2D, 0x34, 0x35, 0x36, 0x2B, 0x31, 0x32, 0x33, 0x30, 0x2E
ASCII_CODE dd ASCII_NORMAL
TOGGLE_SHIFT dd 0
POS_DOCUMENT dd 0
POS_POINTER dd 0
START_DOCUMENT times DOCUMENT_LEN db 0

section .text

extern scan
extern calibrate
extern puts
extern translate

global main
main:
    ; Move text mode cursor off screen.
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    inc dx
    mov al, 0xFF
    out dx, al

    FILL_SCREEN BG.BLACK

    ; Calibrate the timing
    call calibrate

    push dword START_DOCUMENT
    push dword [POS_DOCUMENT]
    push dword [POS_POINTER]
    call puts

    main.loop:
        xor eax, eax
        xor ecx, ecx
        call scan
        cmp eax, KEY.LEFTSHIFT.DOWN
        jne not_leftshiftdown
        mov dword [TOGGLE_SHIFT], 1
        mov dword [ASCII_CODE], ASCII_EXTRA
        jmp main.loop
        not_leftshiftdown:
        cmp eax, KEY.LEFTSHIFT.UP
        jne not_leftshiftup
        mov dword [TOGGLE_SHIFT], 0
        mov dword [ASCII_CODE], ASCII_NORMAL
        jmp main.loop
        not_leftshiftup:
        cmp eax, KEY.RIGHTSHIFT.DOWN
        jne not_rightshiftdown
        mov dword [TOGGLE_SHIFT], 1
        mov dword [ASCII_CODE], ASCII_EXTRA
        jmp main.loop
        not_rightshiftdown:
        cmp eax, KEY.RIGHTSHIFT.UP
        jne not_rightshiftup
        mov dword [TOGGLE_SHIFT], 0
        mov dword [ASCII_CODE], ASCII_NORMAL
        jmp main.loop
        not_rightshiftup:
        cmp eax, KEY.LEFT.DOWN
        jne not_left
        cmp dword [POS_POINTER], 0
        je left.is_zero
        dec dword [POS_POINTER]
        left.is_zero:
        push dword START_DOCUMENT
        push dword [POS_DOCUMENT]
        push dword [POS_POINTER]
        call puts
        jmp main.loop
        not_left:
        cmp eax, KEY.RIGHT.DOWN
        jne not_right
        cmp dword [POS_POINTER], 1920
        je right.is_end
        inc dword [POS_POINTER]
        right.is_end:
        push dword START_DOCUMENT
        push dword [POS_DOCUMENT]
        push dword [POS_POINTER]
        call puts
        jmp main.loop
        not_right:
        cmp eax, ASCII_LEN
        jae main.loop
        cmp eax, KEY.BACK.DOWN
        jne not_backspace
        cmp dword [POS_POINTER], 0
        je is_zero
        dec dword [POS_POINTER]
        mov ecx, [POS_DOCUMENT]
        add ecx, [POS_POINTER]
        push dword START_DOCUMENT
        push ecx
        push dword -1
        call translate
        push dword START_DOCUMENT
        push dword [POS_DOCUMENT]
        push dword [POS_POINTER]
        call puts
        jmp main.loop
        is_zero:
        push dword START_DOCUMENT
        push dword [POS_DOCUMENT]
        push dword [POS_POINTER]
        call puts
        jmp main.loop
        not_backspace:
        cmp eax, ASCII_LEN
        jae main.loop
        mov edx, [ASCII_CODE]
        mov al, [edx + eax]
        mov ecx, [POS_DOCUMENT]
        add ecx, [POS_POINTER]
        inc dword [POS_POINTER]
        push dword START_DOCUMENT
        push ecx
        push dword 1
        call translate
        mov [START_DOCUMENT + ecx], al
        push dword START_DOCUMENT
        push dword [POS_DOCUMENT]
        push dword [POS_POINTER]
        call puts

        jmp main.loop