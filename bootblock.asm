[ORG 0x7c00]

%define DISPLAY_SEGMENT 0xb800
%define STACK_POINTER   0x9c00

%define TERM_FG 10
%define TERM_BG 0
%define ENDL    10, 13

%define PRINT_N_MEM 12

_start:
    jmp start

%include "functions.asm"

start:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, STACK_POINTER

    cld

    mov ax, DISPLAY_SEGMENT
    mov es, ax

    ; Disable cursor
    mov ah, 1
    mov ch, 0x3f
    int 0x10

    ; Clear screen
    call clear

    ; Hello world
    mov si, hello_msg
    call println

    ; Print memory from DISPLAY_SEGMENT
    mov cx, PRINT_N_MEM
    shl cx, 8
    mov cl, ch
printmem:
    mov ax, DISPLAY_SEGMENT
    mov gs, ax
    mov bx, cx
    sub bl, bh
    xor bh, bh
    shl bx, 1
    mov ax, [gs:bx]
    mov word [memdump_addr], ax
    
    push cx
    call memdump
    pop  cx
    dec  ch
    jnz  printmem

hang:
    jmp hang

; === Variables ===

hello_msg db "Hello world!", 0

; === Padd and sign ===
    times 510-($-$$) db 0
    dw 0xaa55