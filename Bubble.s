section .rodata
    uarr DB 3, 4, 7, 1, 6, 0 ; Unsorted array
    uarrSize equ $-uarr ; Gets size of uarr
    newline: db 0x0a ; Newline character

section .bss
    resprint resb 1 ; Stores ASCII result to print
    sArr resb uarrSize ; New array, uarr cannot be operated on, this keeps data intact

global _start

section .text

_start:
    mov ecx, 0 ; initsArr offset value, must use and index register like ecx, eax doesnt work
    call initsArr
    call Sorter

    mov rax, 60 ; Exit
    mov rdi, 0 ; Exit success
    syscall ; Call kernel

; Initialises sArr with 0's
initsArr:
    ; Move element from uarr into sArr
    mov al, [uarr + ecx]
    mov [sArr + ecx], al
    inc ecx ; Increment loop index
    ; Check that all data has been copied, if not, then restart, if so, then return to _start
    cmp ecx, uarrSize - 1
    jl initsArr
    mov ecx, -1 ; Sorter base offset value, -1 cause Sorter performs increment
    ret

; Sorts numbs, does the heavy lifting
Sorter:
    inc ecx ; Before cmp, overwrites zero flag
    ; Check index does not surpass array, if so, reset index
    cmp ecx, uarrSize - 1
    jge OffReset
    mov al, byte [sArr + ecx] ; Moves element arr[offset] into al
    mov ah, byte [sArr + ecx + 1] ; Moves element arr[offset + 1] into ah

    push rcx ; ecx to be used in Checker, so this index data is saved
    ; Checks if sentinel value has been reached, if so, then go straight to checker and dont move it
    cmp ah, 0
    je CheckerInit
    ; Compare al and ah, then jump to a function depending on this result
    cmp al, ah
    je CheckerInit
    jg Bigger
    jl Smaller

sortRet:
    ret ; returns back from last function called to stack, in this case: the sorter call in _start

; If al is bigger than ah
Bigger:
    mov [sArr + ecx + 1], al
    mov [sArr + ecx], ah
    jmp CheckerInit ; Unconditional jump

; If al is smaller than ah. Probably redundant due to initialisation. CHECK
Smaller:
    mov [sArr + ecx + 1], ah
    mov [sArr + ecx], al
    jmp CheckerInit ; Unconditional jump

; Checks if sArr is in correct order
Checker:
    cmp ecx, uarrSize - 2 ; Checks if index reached limit (-2 cause -1 is sentinel), if so, program is successful & prints
    je Popper ; Go to popper first because RAX data is offsetting the stack, this will affect the return call later
    mov al, [sArr + ecx] ; Move sArr[ecx] into al
    mov ah, [sArr + ecx + 1] ; Move sArr[ecx + 1] into ah
    inc ecx ; Increment loop
    ; If al (first index) is smaller than ah (second index), then restart loop
    cmp al, ah
    jl Checker
    pop rcx ; Give ecx its data back
    jmp Sorter ; Unconditional jump

; Resets offset (index)
OffReset:
    mov ecx, -1 ; Will be incremented to 0 in sorter
    jmp Sorter

CheckerInit:
    mov ecx, 0
    jmp Checker

; Give ecx its data back so as to not offset the stack, then go to itoc
Popper:
    pop rcx
    mov ebx, 0 ; For itoc offset
    jmp itoc

; Integer to Character. Prints ints. Can only accept single integers. 1=Good, 15=Bad
itoc:
    mov al, [sArr + ebx] ; Move value into al
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

    cmp ebx, uarrSize - 2 ; "- 2" Stops printing of 0
    je sortRet ; If print finished, program successful, then exit program
    inc ebx ; Increment printing index
    jmp itoc ; Unconditional jump if nothing is met to continue printing