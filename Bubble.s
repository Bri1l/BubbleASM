section .rodata
    arr DB 3, 4, 7, 1, 6, 0 ; Unsorted array

section .bss
    ; Stores int result and ASCII result
    result resb 1
    resprint resb 1

global _start

section .text

_start:
    mov eax, 0 ; Base offset value
    call sorter

    mov rax, 1       ; Exit
    mov rdi, 0        ; Exit success
    syscall           ; Call kernel

; Sorts numbs, does the heavy lifting
sorter:
    mov ebx, [arr + eax] ; Moves mem address arr[0] + offset to ebx
    mov [result], ebx ; Stores this in result
    call itoc ; Call int print function
    cmp ebx, 0 ; Checks if current array element == 0
    jne incoffset ; Runs sorter again if this is not the case
    ret

incoffset:
    inc eax ; Increment offset
    jmp sorter

; Integer to Character. Prints ints. Can only accept single integers. 1=Good, 15=Bad
itoc:
    mov al, 0x30 ; Moves 0x30 into memory, ASCII for 0
    add al, [result] ; Add integer to 0x30
    mov [resprint], al ; Returns this calculation to resprint

    mov rax, 1        ; Write mode
    mov rdi, 1        ; STDOUT
    mov rsi, resprint ; address of resprint
    mov rdx, 1        ; length of resprint
    syscall           ; Call kernel
    ret