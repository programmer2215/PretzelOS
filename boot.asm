ORG 0 ; set origin of program to 0
BITS 16

_start: 
    jmp short start
    nop

times 33 db 0 ; account for BIOS Param Block

start:
    jmp 0x7c0:step2


; DISK - READ SECTOR(S) INTO MEMORY

; AH = 02h
; AL = number of sectors to read (must be nonzero)
; CH = low eight bits of cylinder number
; CL = sector number 1-63 (bits 0-5)
; high two bits of cylinder (bits 6-7, hard disk only)
; DH = head number
; DL = drive number (bit 7 set for hard disk)
; ES:BX -> data buffer

; Return:
; CF set on error
; if AH = 11h (corrected ECC error), AL = burst length
; CF clear if successful
; AH = status (see #00234)
; AL = number of sectors transferred (only valid if CF set for some
; BIOSes)


step2:
    cli ; Clear Interupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; start interupts

    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, buffer
    int 0x13

    jc error

    mov si, buffer
    call print

    
    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_chr
    jmp .loop
.done:
    ret


print_chr:
    mov ah, 0eh
    int 0x10
    ret

error_message: db "Failed to load sector", 0

times 510 - ($ - $$) db 0

dw 0xAA55

buffer: 