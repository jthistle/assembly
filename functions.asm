; int slen(String eax)
; returns string length

slen:
    push    ebx
    mov     ebx, eax

nextchar:
    cmp     byte [eax], 0
    jz      finished
    inc     eax
    jmp     nextchar

finished:
    sub     eax, ebx
    pop     ebx
    ret

; void sprint(String eax)
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

; void sprintlf(String eax)
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

; void printi(int eax)
; prints an integer

printi:
    push    ebx         ; preserve ebx
    push    ecx         ; preserve ecx
    push    edx         ; preserve edx
    mov     ecx, 0

nextdigit:
    cmp     eax, 0     ; if finished, start printing
    jz      pdigit

    inc     ecx         ; update counter
    mov     edx, 0
    mov     ebx, 10
    idiv    ebx
    push    edx         ; push remainder to stack, this is a digit
    jmp     nextdigit

pdigit:
    cmp     ecx, 0          ; if 0, we've reached the end of the number
    jz      finishprinti    ; finish print if 0

    pop     eax             ; move on to next digit
    call    dprint          ; dprint prints from an int, no need to use address

    dec     ecx
    jmp     pdigit

finishprinti:
    mov     eax, 0h     
    push    eax
    mov     eax, esp
    call    prints      ; print newline
    pop     eax

    pop     edx         ; pop preserved edx
    pop     ecx         ; pop preserved ecx
    pop     ebx         ; pop preserved ebx

    ret

; void dprint(int eax)
; prints a digit < 10

dprint:
    add     eax, 48
    push    eax         ; push digit ascii to stack
    mov     eax, esp    ; move address of digit to eax
    call    sprint
    pop     eax         ; remove digit ascii from stack
    ret

; void quit()
; quits the programme

quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h

