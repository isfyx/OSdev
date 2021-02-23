%define BOOT_SEGMENT 0x07c0
%define ENDL         10, 13

    mov ax, BOOT_SEGMENT
    mov ds, ax
    cld

    mov si, msg
    call BIOS_print

hang:
    jmp hang

msg:
    db "Hello world!", ENDL, 0

BIOS_print:
    lodsb
    or al, al
    jz BIOS_print_done
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    jmp BIOS_print
BIOS_print_done:
    ret

sign:
    times 510-($-$$) db 0
    dw 0xaa55