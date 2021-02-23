[ORG 0x7c00]

%define DISPLAY_SEGMENT 0xb800
%define STACK_POINTER   0x9c00

%define TERM_FG 10
%define TERM_BG 0
%define ENDL    10, 13

_start:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, STACK_POINTER

    cld

    mov ax, DISPLAY_SEGMENT
    mov es, ax

    mov si, msg
    call println

hang:
    jmp hang

msg:
    db "Hello world!", 0

println_next: call putc
println:
    lodsb
    cmp al, 0
    jne println_next
    mov byte [xpos], 0
    add byte [ypos], 1
    ret

putc:
    mov ah, TERM_BG ; Set background color
    shl ah, 4       ; ah <<= 4
    or  ah, TERM_FG ; Set foreground color
    mov cx, ax      ; Store char/color
    
    movzx ax, byte [ypos]   ; ax = ypos
    mov   dx, 160           ; dx = 160 (2 bytes times 80 columns)
    mul   dx                ; ax *= dx
    movzx bx, byte [xpos]   ; bx = xpos
    shl   bx, 1             ; bx *= 2 (2 bytes for each character)

    xor di, di  ; di = 0
    add di, ax  ; di += ax
    add di, bx  ; di += bx

    mov ax, cx          ; Load char/color
    stosw               ; Write char/color
    add byte [xpos], 1  ; Move the cursor

    ret

; Vars
xpos:   db 0
ypos:   db 0

sign:
    times 510-($-$$) db 0
    dw 0xaa55