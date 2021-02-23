[ORG 0x7c00]

%define DISPLAY_SEGMENT 0xb800
%define STACK_POINTER   0x9c00

%define X_MAX   80
%define Y_MAX   25
%define TERM_FG 10
%define TERM_BG 0
%define ENDL    10, 13

%define PRINT_N_MEM 12

_start:
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

; === Functions ===

; --- clear ---
clear_line:
    times X_MAX db 0x20 ; clear_line = " " * X_MAX
    db 0
clear:
    mov byte [xpos], 0  ; Reset xpos
    mov byte [ypos], 0  ; Reset ypos
    mov cx, Y_MAX       ; Repeat Y_MAX times
clear_loop:
    push cx             ; Store the loop counter
    mov si, clear_line  ; Load clear_line
    call println        ; Print clear_line
    pop cx              ; Load the loop counter
    dec cx              ; Decrement the loop counter
    jnz clear_loop      ; Repeat if not done
    mov byte [xpos], 0  ; Reset xpos
    mov byte [ypos], 0  ; Reset ypos
    ret                 ; Return

; --- println ---
println_next: call putc ; Write next char
println:
    lodsb               ; Load next char
    cmp al, 0           ; Check if null
    jne println_next    ; Print if not, else:
    mov byte [xpos], 0  ; Carriage return
    add byte [ypos], 1  ; Line feed
    ret                 ; Return

; --- putc ---
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

; --- memdump ---
memdump_addr dw 0
memdump_str  times 5 db 0
memdump_hex  db '0123456789ABCDEF'
memdump:
    mov di, memdump_str     ; Set output to `memdump_str`
    mov ax, [memdump_addr]  ; Load word from address
    mov si, memdump_hex     ; Load hexstring
    mov cx, 4               ; Initialize loop counter
memdump_loop:
    rol ax, 4           ; Rotate next nibble in place
    mov bx, ax          ; Copy nibbles
    and bx, 0x000f      ; Mask out next nibble
    mov bl, [si + bx]   ; Get corresponding character
    mov [di], bl        ; Put character in output

    inc di              ; Move output to next char
    dec cx              ; Decrement loop counter
    jnz memdump_loop    ; Repeat if not done

    mov  byte [di], 0            ; Terminate string
    mov  si, memdump_str    ; Pass output to `println`
    call println            ; Call `println`
    ret                     ; Return

; === Variables ===

xpos db 0
ypos db 0

hello_msg db "Hello world!", 0

; === Padd and sign ===
    times 510-($-$$) db 0
    dw 0xaa55