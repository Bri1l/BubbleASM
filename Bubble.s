section .rodata
    arr DB 3, 4, 7, 1, 6, 0 ; Unsorted array
    newline: db 0x0a ; newline character

section .bss
    ; Stores int result and ASCII result
    result resb 1
    resprint resb 1

global _start

section .text

_start:
    mov ebx, 0 ; Base offset value, must use and index register like ebx, eax doesnt work
    call sorter

    mov rax, 60 ; Exit
    mov rdi, 0 ; Exit success
    syscall ; Call kernel

; Sorts numbs, does the heavy lifting
sorter:
    mov al, byte [arr + ebx] ; Moves element arr[offset] into ebx
    mov [result], al ; Stores this in result, will be used after itoc
    call itoc ; Call int print function. Overwrites registers and zero flag
    inc ebx ; Increments index. Cannot go after cmp, modifies zero flag
    mov al, [result] ; Copies result back into al
    ; Checks if current array element == 0. Restarts sorter if element != 0
    cmp byte al, 0
    jne sorter
    ret

; Integer to Character. Prints ints. Can only accept single integers. 1=Good, 15=Bad
itoc:
    add al, 0x30 ; Adds 0x30 (ASCII for 0) to result
    mov [resprint], al ; Returns this calculation to resprint

    ; Prints numeric character
    mov rax, 1 ; Write mode
    mov rdi, 1 ; STDOUT
    mov rsi, resprint ; address of resprint
    mov rdx, 1 ; length of resprint
    syscall ; Call kernel

    ; Prints newline
    mov rax, 1 ; Write mode
    mov rdi, 1 ; STDOUT
    mov rsi, newline ; address of newline
    mov rdx, 1 ; length of newline
    syscall ; Call kernel
    ret