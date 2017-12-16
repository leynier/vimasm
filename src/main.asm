%include "keyboard.mac"
%include "utils.mac"

section .data

; Cada posicion de este array representa un hexadecimal de las teclas y el valor el ASCII correspondiente a la tecla sin presionar shift
global ASCII_NORMAL
ASCII_NORMAL db 0x00, 0x1B, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x2D, 0x3D, 0x08, 0x09, 0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69, 0x6F, 0x70, 0x5B, 0x5D, 0x0D, 0x00, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68, 0x6A, 0x6B, 0x6C, 0x3B, 0x27, 0x60, 0x00, 0x5C, 0x7A, 0x78, 0x63, 0x76, 0x62, 0x6E, 0x6D, 0x2C, 0x2E, 0x2F, 0x00, 0x2A, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x38, 0x39, 0x2D, 0x34, 0x35, 0x36, 0x2B, 0x31, 0x32, 0x33, 0x30, 0x2E

; Cada posicion de este array representa un hexadecimal de las teclas y el valor el ASCII correspondiente a la tecla presionado shift
global ASCII_EXTRA
ASCII_EXTRA db 0x00, 0x1B, 0x21, 0x40, 0x23, 0x24, 0x25, 0x5E, 0x26, 0x2A, 0x28, 0x29, 0x5F, 0x2B, 0x08, 0x09, 0x51, 0x57, 0x45, 0x52, 0x54, 0x59, 0x55, 0x49, 0x4F, 0x50, 0x7B, 0x7D, 0x0D, 0x00, 0x41, 0x53, 0x44, 0x46, 0x47, 0x48, 0x4A, 0x4B, 0x4C, 0x3A, 0x22, 0x7E, 0x00, 0x7C, 0x5A, 0x58, 0x43, 0x56, 0x42, 0x4E, 0x4D, 0x3C, 0x3E, 0x3F, 0x00, 0x2A, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x38, 0x39, 0x2D, 0x34, 0x35, 0x36, 0x2B, 0x31, 0x32, 0x33, 0x30, 0x2E

; Direccion de memoria que tenda la direccion del array a utilizar, (ASCII_NORMAL | ASCII_EXTRA)
global ASCII_CODE
ASCII_CODE dd ASCII_NORMAL

; Contiene 0 si el shift no esta presionado, 1 si lo esta
global TOGGLE_SHIFT
TOGGLE_SHIFT dd 0

; Contiene 0 si el ctrl no esta presionado, 1 si lo esta
global TOGGLE_CTRL
TOGGLE_CTRL dd 0

; Contiene 0 si el caps no esta precionado, 1 si lo esta
global TOGGLE_CAPS
TOGGLE_CAPS dd 0

; Posicion del documento donde se esta presentando en pantalla
global POS_DOCUMENT
POS_DOCUMENT dd 0

; Posicion del cursor de escritura, respecto al POS_DOCUMENT
global POS_POINTER
POS_POINTER dd 0

; Posicion del cursor de seleccion con respecto al START_DOCUMENT
global POS_SELECT
POS_SELECT dd 0

; Valor de la tecla presionada, actualizada por el metodo 'scan'
global KEY
KEY dd 0

; Variable que representa los modos de la aplicacion
global MODE
MODE dd 0

; Array que contiene la informacion que se encuentra en la ultima linea
global BAR_BOTTOM
BAR_BOTTOM dd NORMAL_MSG

global TIMER
TIMER dd 0, 0

; Texto de bienvenida
global WELCOME_MSG
WELCOME_MSG db "  ____________________________________________________________________________   |                                                                            |  |                           WELCOME TO VIMASM v1.0                           |  |                                                                            |  |                          Project of PM1 2017-2018                          |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                              ( PRESS  ENTER )                              |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |                                                                            |  |       Developers: Paula Rodriguez Perez & Leynier Gutierrez Gonzalez       |  |____________________________________________________________________________| ", 0

global NORMAL_MSG
NORMAL_MSG db "-- NORMAL --                                                                    ", 0

global INSERTION_MSG
INSERTION_MSG db "-- INSERTION --                                                                 ", 0

global REPLACE_MSG
REPLACE_MSG db "-- REPLACE --                                                                   ", 0

global VISUAL_MSG
VISUAL_MSG db "-- VISUAL --                                                                    ", 0

global VISUAL_LINE_MSG
VISUAL_LINE_MSG db "-- VISUAL LINE --                                                               ", 0

global VISUAL_BLOCK_MSG
VISUAL_BLOCK_MSG db "-- VISUAL BLOCK --                                                              ", 0

global MODE_COPY
MODE_COPY dd 0

global COPY_DOCUMENT
COPY_DOCUMENT times DOCUMENT_LEN db 0

global LEN_COPY
LEN_COPY dd 0

global PARTITION_COPY
PARTITION_COPY dd 0

; Array que representa el documento
global START_DOCUMENT
START_DOCUMENT times DOCUMENT_LEN db 0

section .text

extern scan
extern calibrate
extern paint_start
extern normal
extern shift_down
extern shift_up
extern ctrl_down
extern ctrl_up
extern reset_doc
extern caps_down

global main
main:
    ; Move text mode cursor off screen.
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    inc dx
    mov al, 0xFF
    out dx, al

    mov byte [START_DOCUMENT], EOF

    .loop:
        call calibrate
    
        call reset_doc
        
        mov dword [MODE], MODE_START
        REG_CLEAR

        mov dword [TIMER], 0
        mov dword [TIMER + 4], 0

        call paint_start
        call scan
        
        ; Comprueba el control
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.DOWN, ctrl_down, .loop
        BIND_CTRL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.CTRL.UP, ctrl_up, .loop

        ; Comprueba el shift
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.DOWN, shift_down, .loop
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.DOWN, shift_down, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.LEFTSHIFT.UP, shift_up, .loop
        BIND_SHIFT [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.RIGHTSHIFT.UP, shift_up, .loop

        BIND [KEY], KEY.CAPS.DOWN, caps_down, .loop

        ; Comprueba el enter para comenzar
        BIND_NORMAL [KEY], [TOGGLE_CTRL], [TOGGLE_SHIFT], KEY.ENTER.DOWN, normal, .loop

        jmp .loop