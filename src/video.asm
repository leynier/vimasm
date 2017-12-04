%include "video.mac"
%include "utils.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern POS_SELECT
extern BAR_BOTTOM
extern MODE
extern WELCOME_MSG

; paint_start()
; Pinta la presentacion
global paint_start
paint_start:
    pushad
    ; Pinta la pantalla de color negro
    push word BG.BLACK
    call clear
    REG_CLEAR
    cld
    mov esi, WELCOME_MSG
    mov edi, FBUFFER
    or ax, FG.GREEN | FG.BRIGHT
    paint_start.loop:
        cmp byte [esi], 0
        je paint_start.ret
        lodsb
        stosw
        jmp paint_start.loop
    paint_start.ret:
        popad
        ret

; paint_select()
; Resalta segun el modo que este activado
global paint_select
paint_select:
    pushad
    REG_CLEAR
    BIND [MODE], MODE_NORMAL, paint_cursor
    BIND [MODE], MODE_INSERTION, paint_cursor
    BIND [MODE], MODE_VISUAL, paint_visual
    popad
    ret

; paint_visual()
; Pinta la seleccion del modo visual
global paint_visual
paint_visual:
    pushad
    REG_CLEAR

    mov eax, START_DOCUMENT
    add eax, [POS_DOCUMENT]
    mov ebx, eax
    add eax, [POS_POINTER]
    cmp [POS_SELECT], eax
    jl paint_visual.less
        add ebx, 1920
        cmp [POS_SELECT], ebx
        jnge paint_visual.notgreat
        mov ecx, ebx
        jmp paint_visual.preciclo1
        paint_visual.notgreat:
        mov ecx, [POS_SELECT]
        paint_visual.preciclo1:
        sub ecx, eax
        mov eax, [POS_POINTER]
        inc ecx
        paint_visual.ciclo1:
            push eax
            call paint_pointer
            inc eax
            loop paint_visual.ciclo1
            jmp paint_visual.ret
    paint_visual.less:
        mov ecx, eax
        cmp [POS_SELECT], ebx
        jnle paint_visual.notless
        sub ecx, ebx
        jmp paint_visual.preciclo2
        paint_visual.notless:
        sub ecx, [POS_SELECT]
        paint_visual.preciclo2:
        mov eax, [POS_POINTER]
        sub eax, ecx
        inc ecx
        paint_visual.ciclo2:
            push eax
            call paint_pointer
            inc eax
            loop paint_visual.ciclo2
            jmp paint_visual.ret
    paint_visual.ret:
        popad
        ret

; paint_cursor()
; Resalta solamente la posicion del cursor
global paint_cursor
paint_cursor:
    push dword [POS_POINTER]
    call paint_pointer
    ret

; paint_pointer(dword pos) 
; Resalta la posicion que se le pasa por parametro.
global paint_pointer
paint_pointer:
    push ebp
    mov ebp, esp
    pushad
    REG_CLEAR

    mov eax, [ebp + 8]
    add eax, eax
    mov bx, [FBUFFER + eax]
    cmp bl, 0
    je paint_pointer.ret
    ror bh, 4
    mov [FBUFFER + eax], bx

    paint_pointer.ret:
        popad
        pop ebp
        ret 4

; clear(word char|attrs)
; Pinta en toda la pantalla un caracter con el color deseado
global clear
clear:
    push ebp
    mov ebp, esp
    pushad
    REG_CLEAR
    mov ax, [ebp + 8] ; char, attrs
    mov edi, FBUFFER
    mov ecx, COLS * ROWS
    cld
    rep stosw
    clear.ret:
        popad
        pop ebp
        ret 2

; putc(word col|row, word chr|color)
; Pinta en una posicion de la pantalla un caracter del color deseado
global putc
putc:
    push ebp
    mov ebp, esp
    pushad
    ; calc famebuffer offset 2 * (r * COLS + c)
    FBOFFSET [ebp + 11], [ebp + 10]
    mov bx, [ebp + 8]
    mov [FBUFFER + eax], bx
    popad
    pop ebp
    ret 4

; paint()
; Pinta en la pantalla segun los valores del POS_DOCUMENT y el POS_POINTER
global paint
paint:
    pushad
    ; Pinta la pantalla de color negro
    push word BG.BLACK
    call clear
    REG_CLEAR
    cld
    cmp dword [MODE], MODE_NORMAL
    jne not_mode_normal
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'N'
        stosb
        mov al, 'O'
        stosb
        mov al, 'R'
        stosb
        mov al, 'M'
        stosb
        mov al, 'A'
        stosb
        mov al, 'L'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_normal:
    cmp dword [MODE], MODE_INSERTION
    jne not_mode_insertion
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'I'
        stosb
        mov al, 'N'
        stosb
        mov al, 'S'
        stosb
        mov al, 'E'
        stosb
        mov al, 'R'
        stosb
        mov al, 'T'
        stosb
        mov al, 'I'
        stosb
        mov al, 'O'
        stosb
        mov al, 'N'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_insertion:
    cmp dword [MODE], MODE_VISUAL
    jne not_mode_visual
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'V'
        stosb
        mov al, 'I'
        stosb
        mov al, 'S'
        stosb
        mov al, 'U'
        stosb
        mov al, 'A'
        stosb
        mov al, 'L'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_visual:
    cmp dword [MODE], MODE_VISUAL_BLOCK
    jne not_mode_visual_block
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'V'
        stosb
        mov al, 'I'
        stosb
        mov al, 'S'
        stosb
        mov al, 'U'
        stosb
        mov al, 'A'
        stosb
        mov al, 'L'
        stosb
        mov al, ' '
        stosb
        mov al, 'B'
        stosb
        mov al, 'L'
        stosb
        mov al, 'O'
        stosb
        mov al, 'C'
        stosb
        mov al, 'K'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_visual_block:
    cmp dword [MODE], MODE_VISUAL_LINE
    jne not_mode_visual_line
        mov edi, BAR_BOTTOM
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, 'V'
        stosb
        mov al, 'I'
        stosb
        mov al, 'S'
        stosb
        mov al, 'U'
        stosb
        mov al, 'A'
        stosb
        mov al, 'L'
        stosb
        mov al, ' '
        stosb
        mov al, 'L'
        stosb
        mov al, 'I'
        stosb
        mov al, 'N'
        stosb
        mov al, 'E'
        stosb
        mov al, ' '
        stosb
        mov al, '-'
        stosb
        mov al, '-'
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
        mov al, ' '
        stosb
    not_mode_visual_line:
    mov esi, BAR_BOTTOM
    mov edi, FBUFFER
    add edi, 3840
    mov ecx, 80
    paint.bottom:
        xor eax, eax
        lodsb
        or ax, FG.BRIGHT | FG.GREEN | BG.BLACK
        stosw
        loop paint.bottom
    ; Coloca el 'esi' apartir de donde se este mostrando el documento, el 'edi' al principio de la pantalla
    mov esi, START_DOCUMENT
    add esi, [POS_DOCUMENT]
    mov edi, FBUFFER
    cld
    paint.loop:
        xor eax, eax
        or ax, FG.BRIGHT | FG.GREEN | BG.BLACK ; Le coloca el color al caracter
        lodsb ; Carga hacia 'al' un caracter y avanza el 'esi'
        cmp al, EOF ; Comprueba si es el fin de fichero
        jne not_eof
        mov al, ' ' ; Si es el fin de fichero lo remplaza con espacio en blanco
        not_eof:
        cmp al, EOL ; Comprueba si es el fin de linea
        jne not_eol
        mov al, ' ' ; Si es el fin de linea lo remplaza con espacio en blanco
        not_eol:
        cmp ebx, 1920 ; Comprueba si no se ha llegado al final de la pantalla
        je paint.ret ; Retorna porque se llego al final de la pantalla
        stosw ; Coloca en la pantalla el caracter con el color y mueve el 'edi'
        inc ebx ; Incrementa la posicion donde se esta pintando
        jmp paint.loop
    paint.ret:
        call paint_select
        popad
        ret