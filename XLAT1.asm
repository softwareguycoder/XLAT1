;  Executable name : XLAT1
;  Version         : 1.0
;  Created date    : 13 Dec 2018
;  Last update     : 13 Dec 2018
;  Author          : Brian Hart
;  Description     : A simple program in assembly for Linux, using NASM, demonstrating
;                   the use of the XLAT instruction to alter text streams.
;
;  Run it this way:
;    XLAT1 < (input file)
;   
;  Build using these commands:
;     nasm -f elf64 -g -F stabs XLAT1.asm
;     ld -o XLAT1 XLAT1.o
;

READLEN     EQU 1024                ; Length of buffer

SYS_EXIT    EQU 1                   ; Syscall number for sys_exit
SYS_READ    EQU 3                   ; Syscall number for sys_read
SYS_WRITE   EQU 4                   ; Syscall number for sys_write

OK          EQU 0                   ; Operation completed without errors
ERROR       EQU -1                  ; Operation failed to complete; error flag

STDIN       EQU 0                   ; File Descriptor 0: Standard Input
STDOUT      EQU 1                   ; File Descriptor 1: Standard Output
STDERR      EQU 2                   ; File Descriptor 2: Standard Error

EOF         EQU 0                   ; End-of-file reached

SECTION .bss                        ; Section containing uninitialized data
   
    ReadBuffer:   resb    READLEN   ; Text buffer itself
    
SECTION .data                       ; Section containing initialized data

    StatMsg:    db  "Processing...",10
    StatLen:    EQU $-StatMsg
    DoneMsg:    db  "...done!",10
    DoneLen:    EQU $-DoneMsg
    
; The following translation table translates all lowercase characters to
; uppercase.  It also translates all non-printable characters to spaces,
; except for LF and HT.
    UpCase:
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 09h, 0Ah, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh, 2Eh, 2Fh
        db 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h, 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh
        db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h, 4Ah, 4Bh, 4Ch, 4Dh, 4Eh, 4Fh
        db 50h, 51h, 52h, 53h, 54h, 55h, 56h, 57h, 58h, 59h, 5Ah, 5Bh, 5Ch, 5Dh, 5Eh, 5Fh
        db 60h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h, 4Ah, 4Bh, 4Ch, 4Dh, 4Eh, 4Fh
        db 50h, 51h, 52h, 53h, 54h, 55h, 56h, 57h, 58h, 59h, 5Ah, 7Bh, 7Ch, 7Dh, 7Eh, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h

; The following translation table is "stock" in that it translates all
; printable characters as themselves, and converts all non-printable 
; characters to spaces except for LF and HT.  You can modify this to
; translate anything you want to any character you want.
    Custom:
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 09h, 0Ah, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh, 2Eh, 2Fh
        db 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h, 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh
        db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h, 4Ah, 4Bh, 4Ch, 4Dh, 4Eh, 4Fh
        db 50h, 51h, 52h, 53h, 54h, 55h, 56h, 57h, 58h, 59h, 5Ah, 5Bh, 5Ch, 5Dh, 5Eh, 5Fh
        db 60h, 61h, 62h, 63h, 64h, 65h, 66h, 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh
        db 70h, 71h, 72h, 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
        db 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
    
SECTION .text                       ; Section containing code

global _start                       ; Linker needs this to find the entry point!

_start:
    nop                             ; This no-op keeps gdb happy...
    
; Display the "I'm working..." message via stderr...
Read:
    mov eax, SYS_WRITE              ; Specify sys_write call
    mov ebx, STDERR                 ; Specify File Descriptor 2: Standard Error
    mov ecx, StatMsg                ; Pass offset of the message
    mov edx, StatLen                ; Pass the length of the message
    int 80h                         ; Make kernel call
    
; Read a buffer full of text from stdin:
read:
    mov eax, SYS_READ               ; Specify sys_read call
    mov ebx, STDIN                  ; Specify File Descriptor 0: Standard Input
    mov ecx, ReadBuffer             ; Pass offset of the buffer to read to
    mov edx, READLEN                ; Pass number of bytes to read at one pass
    int 80h                         ; Make kernel call
    
    mov ebp, eax                    ; Copy sys_read return value for safekeeping
    cmp eax, EOF                    ; If eax=0, (EOF) then read reached end-of-file
    je  done                        ; Jump if Equal (to 0, from compare)
    
; Set up the registers for the translate step:
    mov ebx, UpCase                 ; Place the offset of the table into EBX
    mov edx, ReadBuffer             ; Place the offset of the buffer into EDX
    mov ecx, ebp                    ; Place the number of bytes actually in the buffer into ECX
    
; Use the xlat instruction to translate the data in the buffer:
; (Note: htee commented-out instructions do the same work as XLAT;
; un-comment them and then comment out XLAT to try it!
translate:
;   xor eax, eax                    ; Clear high 24 bits of EAX
    mov al, BYTE [edx+ecx]          ; Load character into AL for translation
;   mov al, BYTE [UpCase+eax]       ; Translate character in AL via table
    xlat                            ; Translate character in AL via table
    mov BYTE [edx+ecx], al          ; Put the translated char back in the buffer
    dec ecx                         ; Decrement character count
    jnz translate                   ; If there are more chars in the buffer, repeat
    
; Write the buffer full of translated text to STDOUT:
write:
    mov eax, SYS_WRITE              ; Specify sys_write call
    mov ebx, STDOUT                 ; Specify File Descriptor 1: Standard output
    mov ecx, ReadBuffer             ; Pass offset of the buffer
    mov edx, ebp                    ; Pass the # of bytes of data in the buffer
    int 80h                         ; Make kernel call
    jmp read                        ; Loop back and load another buffer-full
    
; Display the "I'm done" message via stderr:
done:
    mov eax, SYS_WRITE              ; Specify sys_write call
    mov ebx, STDERR                 ; Specify File Descriptor 2: Standard error
    mov ecx, DoneMsg                ; Pass offset o fhte message
    mov edx, DoneLen                ; Pass the length of the message
    int 80h                         ; Make kernel call
    
; All done!  Let's end this party:
    mov eax, SYS_EXIT               ; Code for Exit Syscall
    mov ebx, OK                     ; Return a value of zero
    int 80h                         ; Make kernel call
