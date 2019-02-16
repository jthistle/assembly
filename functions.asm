; A basic functions library

; slen(String eax)
; returns string length in eax

slen:
    push    ebx
    mov     ebx, eax

.nextchar:
    cmp     byte [eax], 0
    jz      .finished
    inc     eax
    jmp     .nextchar

.finished:
    sub     eax, ebx
    pop     ebx
    ret

; sprint(String eax)
; prints a string wout linefeed

sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax         ; eax is last on stack

    call    slen
    mov     edx, eax    ; eax holds string length
    pop     eax         ; put string back into eax

    mov     ecx, eax    ; write buffer length
    mov     ebx, 1
    mov     eax, 4      ; SYSOP code for write
    int     80h

    pop     ebx
    pop     ecx
    pop     edx
    ret

; prints(String eax)
; prints string with linefeed

prints:
    call    sprint

    push    eax
    mov     eax, 0Ah    ; put linefeed in eax
    push    eax
    mov     eax, esp    ; esp gives the address of the current stack pointer
    call    sprint
    pop     eax
    pop     eax
    ret

; iprint(int eax)
; prints a positive integer, no linefeed

iprint:
    push    ebx         ; preserve ebx
    push    ecx         ; preserve ecx
    push    edx         ; preserve edx
    cmp     eax, 0
    jz      .pzero

    mov     ecx, 0

.nextdigit:
    cmp     eax, 0     ; if finished, start printing
    jz      .pdigit

    inc     ecx         ; update counter
    mov     edx, 0
    mov     ebx, 10
    idiv    ebx
    push    edx         ; push remainder to stack, this is a digit
    jmp     .nextdigit

.pdigit:
    cmp     ecx, 0          ; if 0, we've reached the end of the number
    jz      .finishiprint    ; finish print if 0

    pop     eax             ; move on to next digit
    call    dprint          ; dprint prints from an int, no need to use address

    dec     ecx
    jmp     .pdigit

.pzero:                     ; special case for 0
    mov     eax, 0
    call    dprint

.finishiprint:
    pop     edx         ; pop preserved edx
    pop     ecx         ; pop preserved ecx
    pop     ebx         ; pop preserved ebx

    ret

; printi(int eax)
; prints a positive integer, with linefeed

printi:
    call    iprint

    push    eax
    mov     eax, 0h     
    push    eax
    mov     eax, esp
    call    prints      ; print newline
    pop     eax
    pop     eax
    ret

; dprint(int eax)
; prints a digit < 10

dprint:
    add     eax, 48
    push    eax         ; push digit ascii to stack
    mov     eax, esp    ; move address of digit to eax
    call    sprint
    pop     eax         ; remove digit ascii from stack
    ret

; void input(string* eax, int ebx)
; gets input, writes to label at eax
; ebx is the amount of bytes to read

input:
    push    eax
    push    ebx
    push    ecx
    push    edx

    mov     edx, ebx            ; the amount of bytes to read
    mov     ecx, eax            ; the buffer to write to
    mov     ebx, 0              ; write to STDIN
    mov     eax, 3              ; SYS_READ
    int     80h

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

; void copys(string* eax, string* ebx)
; copy string at address in eax to address at ebx

copys:
    push    ecx
    push    ebx
    mov     ecx, 0

.nextchar:
    push    eax
    push    ebx
    add     eax, ecx            ; move to correct memory address for this byte
    add     ebx, ecx            ; update memory address for destination
    
    mov     al, byte [eax]      ; al now holds value at byte eax
    mov     byte [ebx], al      ; set byte at ebx to value of byte at al
    cmp     al, 0h              ; check if we're at the end of the string

    pop     ebx
    pop     eax
    jz      .finish

    inc     ecx                 ; next byte
    jmp     .nextchar

.finish:
    pop     ebx
    pop     ecx
    ret

; void pow(int eax, int ebx)
; does power of eax to ebx, for ebx >= 0
; returns val in eax

pow:
    push    ecx
    push    edx
    push    edi
    cmp     ebx, 0
    jz      .ret1

    mov     ecx, ebx
    mov     edi, eax    ; edi will store the original number to mul by

.next:
    cmp     ecx, 1
    jz      .fin        ; no more to do, finish
    mul     edi         ; multiply eax by the original eax
    dec     ecx         ; dec counter
    jmp     .next

.fin:
    pop     edi
    pop     edx
    pop     ecx
    ret

.ret1:
    pop     edi
    pop     edx
    pop     ecx
    mov     eax, 1      ; special case, return 1
    ret

; void quit()
; quits the programme

quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
