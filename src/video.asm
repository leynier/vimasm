%include "video.mac"
%include "utils.mac"

section .text

extern START_DOCUMENT
extern POS_DOCUMENT
extern POS_POINTER
extern POS_SELECT
extern MODE
extern WELCOME_MSG
extern BAR_BOTTOM
extern NORMAL_MSG
extern INSERTION_MSG
extern REPLACE_MSG
extern VISUAL_MSG
extern VISUAL_LINE_MSG
extern VISUAL_BLOCK_MSG

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

    .loop:
        cmp byte [esi], 0
        je .ret
        lodsb
        stosw
        jmp .loop

    .ret:
        popad
        ret

; paint_select()
; Resalta segun el modo que este activado
global paint_select
paint_select:
    pushad
    REG_CLEAR

    BIND [MODE], MODE_NORMAL, paint_cursor, .ret
    BIND [MODE], MODE_INSERTION, paint_cursor, .ret
    BIND [MODE], MODE_VISUAL, paint_visual, .ret
    BIND [MODE], MODE_VISUAL_LINE, paint_visual_line, .ret
    BIND [MODE], MODE_VISUAL_BLOCK, paint_visual_block, .ret
    BIND [MODE], MODE_REPLACE, paint_cursor, .ret

    .ret:
        popad
        ret

; paint_visual_block()
; Pinta la seleccion del modo visual block
global paint_visual_block
paint_visual_block:
    pushad
    REG_CLEAR

    mov eax, [POS_SELECT]
    mov ebx, [POS_DOCUMENT]

    .loop1:
    cmp eax, ebx
    jge .not_less
        add eax, COLS
        jmp .loop1
    .not_less:
        add ebx, SCREEN_LEN
        .loop2:
        cmp eax, ebx
        jl .continue
        sub eax, COLS
        jmp .loop2
    .continue:
        sub eax, [POS_DOCUMENT]
        mov ebx, [POS_POINTER]

        cmp eax, ebx
        jle .not_swap
            mov ecx, eax
            mov eax, ebx
            mov ebx, ecx
        .not_swap:

        push eax
        push ebx

        mov esi, eax
        mov edi, ebx

        mov ebx, COLS

        xor edx, edx
        mov eax, esi
        div ebx
        mov esi, edx

        xor edx, edx
        mov eax, edi
        div ebx
        mov edi, edx

        pop ebx
        pop eax

        cmp esi, edi
        jle .not_swap2
            mov ecx, esi
            mov esi, edi
            mov edi, ecx
            mov ecx, edi
            sub ecx, esi
            sub eax, ecx
            add ebx, ecx
        .not_swap2:

        mov ecx, edi
        sub ecx, esi

        sub eax, COLS
        sub ebx, ecx
        inc ecx
        .start_loop:
            add eax, COLS
            push eax
            push ecx
            .main_loop:
                push eax
                call paint_pointer
                inc eax
                loop .main_loop
            pop ecx
            pop eax
            cmp eax, ebx
            jl .start_loop
        
    .ret:
        popad
        ret

; paint_visual_line()
; Pinta la seleccion del modo visual line
global paint_visual_line
paint_visual_line:
    pushad
    REG_CLEAR

    mov eax, [POS_DOCUMENT]
    mov ebx, eax
    add eax, [POS_POINTER]
    ; Coloco en 'eax' la posicion de puntero con respecto a principio del documento

    cmp [POS_SELECT], eax ; Comparo si el cursor de seleccion esta por la derecha o izquierda
    jl .less
        add ebx, SCREEN_LEN
        cmp [POS_SELECT], ebx ; Comparo si el cursor de seleccion esta por fuera de la pantalla
        jnge .notgreat
        mov ecx, ebx
        jmp .preloop1
        .notgreat:
        mov ecx, [POS_SELECT]
        push eax
        push ebx
        push edx
        mov ebx, COLS
        mov eax, ecx
        div ebx
        sub ebx, edx
        add ecx, ebx
        pop edx
        pop ebx
        pop eax
        .preloop1:
        push ebx
        push ecx
        push edx
        mov ebx, eax
        mov ecx, COLS
        div ecx
        sub ebx, edx
        mov eax, ebx
        pop edx
        pop ecx
        pop ebx
        sub ecx, eax
        sub ebx, SCREEN_LEN
        sub eax, ebx
        ; En 'ecx' queda la cantidad de posiciones que hay que resaltar
        ; En 'eax' queda la posicion inicial que se ira aumentando en el loop
        .loop1:
            push eax
            call paint_pointer
            inc eax
            loop .loop1
            jmp .ret
    .less:
        cmp [POS_SELECT], ebx ; Comparo si el cursor de seleccion esta por fuera de la pantalla
        jnle .notless
        mov ecx, ebx
        jmp .preloop2
        .notless:
        mov ecx, [POS_SELECT]
        push eax
        push ebx
        push edx
        mov ebx, COLS
        mov eax, ecx
        div ebx
        sub ecx, edx
        pop edx
        pop ebx
        pop eax
        .preloop2:
        push ebx
        push ecx
        push edx
        mov ebx, eax
        mov ecx, COLS
        div ecx
        sub ecx, edx
        add ebx, ecx
        mov eax, ebx
        pop edx
        pop ecx
        pop ebx
        mov edx, eax
        mov eax, ecx
        mov ecx, edx
        sub ecx, eax
        sub eax, ebx
        ; En 'ecx' queda la cantidad de posiciones que hay que resaltar
        ; En 'eax' queda la posicion inicial que se ira aumentando en el loop
        .loop2:
            push eax
            call paint_pointer
            inc eax
            loop .loop2
            jmp .ret

    .ret:
        popad
        ret

; paint_visual()
; Pinta la seleccion del modo visual
global paint_visual
paint_visual:
    pushad
    REG_CLEAR

    mov eax, [POS_DOCUMENT]
    mov ebx, eax
    add eax, [POS_POINTER]
    ; Coloco en 'eax' la posicion de puntero con respecto a principio del documento

    cmp [POS_SELECT], eax ; Comparo si el cursor de seleccion esta por la derecha o izquierda
    jl .less
        add ebx, SCREEN_LEN
        cmp [POS_SELECT], ebx ; Comparo si el cursor de seleccion esta por fuera de la pantalla
        jnge .notgreat
        mov ecx, ebx
        jmp .preloop1
        .notgreat:
        mov ecx, [POS_SELECT]
        .preloop1:
        sub ecx, eax
        mov eax, [POS_POINTER]
        inc ecx
        ; En 'ecx' queda la cantidad de posiciones que hay que resaltar
        ; En 'eax' queda la posicion inicial que se ira aumentando en el loop
        .loop1:
            push eax
            call paint_pointer
            inc eax
            loop .loop1
            jmp .ret
    .less:
        mov ecx, eax
        cmp [POS_SELECT], ebx ; Comparo si el cursor de seleccion esta por fuera de la pantalla
        jnle .notless
        sub ecx, ebx
        jmp .preloop2
        .notless:
        sub ecx, [POS_SELECT]
        .preloop2:
        mov eax, [POS_POINTER]
        sub eax, ecx
        inc ecx
        ; En 'ecx' queda la cantidad de posiciones que hay que resaltar
        ; En 'eax' queda la posicion inicial que se ira aumentando en el loop
        .loop2:
            push eax
            call paint_pointer
            inc eax
            loop .loop2
            jmp .ret

    .ret:
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

    mov eax, [ebp + 8] ; Posicion a la que hay que resaltar
    add eax, eax ; Se duplica porque la pantalla es en word
    mov bx, [FBUFFER + eax]
    cmp bl, 0 ; Si no hay nada no resalto
    je .ret
    ror bh, 4 ; Roto para cambiar el background por el foreground
    mov [FBUFFER + eax], bx

    .ret:
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

    .ret:
        popad
        pop ebp
        ret 2

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
    mov esi, [BAR_BOTTOM]
    mov edi, FBUFFER
    add edi, SCREEN_LEN2
    mov ecx, COLS
    .bottom:
        xor eax, eax
        lodsb
        or ax, FG.BRIGHT | FG.GREEN | BG.BLACK
        stosw
        loop .bottom

    ; Coloca el 'esi' apartir de donde se este mostrando el documento, el 'edi' al principio de la pantalla
    mov esi, START_DOCUMENT
    add esi, [POS_DOCUMENT]
    mov edi, FBUFFER
    cld

    .loop:
        xor eax, eax
        or ax, FG.BRIGHT | FG.GREEN | BG.BLACK ; Le coloca el color al caracter
        lodsb ; Carga hacia 'al' un caracter y avanza el 'esi'
        cmp al, EOF ; Comprueba si es el fin de fichero
        jne .not_eof
        mov al, ' ' ; Si es el fin de fichero lo remplaza con espacio en blanco
        .not_eof:
        cmp al, EOL ; Comprueba si es el fin de linea
        jne .not_eol
        mov al, ' ' ; Si es el fin de linea lo remplaza con espacio en blanco
        .not_eol:
        cmp ebx, SCREEN_LEN ; Comprueba si no se ha llegado al final de la pantalla
        je .ret ; Retorna porque se llego al final de la pantalla
        stosw ; Coloca en la pantalla el caracter con el color y mueve el 'edi'
        inc ebx ; Incrementa la posicion donde se esta pintando
        jmp .loop

    .ret:
        call paint_select
        popad
        ret