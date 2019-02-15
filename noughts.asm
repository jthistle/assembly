; Noughts and Crosses
; (or, for the yanks, Tic Tac Toe)
; Feb 2019, JT

%include            "functions.asm"

SECTION .data
startgrid   db      "7 8 9", 0Ah, "4 5 6", 0Ah, "1 2 3", 0h
prompt1     db      "User [0] or computer [1] first: ", 0h
badinput    db      "Invalid input", 0h
prompt2     db      "Enter place to play: ", 0h
invalidmsg  db      "Invalid move", 0h
winmsg      db      "You have won!", 0h
losemsg     db      "The computer has won!", 0h
newline     db      0Ah, 0h

SECTION .bss
grid:       resb    18          ; store grid
userinput:  resb    255         ; reserve 255 bytes of memory for user input
turn:       resb    1           ; 1 byte to hold 0 or 1 for whose go it is - may not be needed
usersq:     resb    2           ; user squares, e.g. 1 = 1, 2 = 2, 3 = 4, 4 = 8 ... 9 = 128
compsq:     resb    2           ; computer squares, in same format

SECTION .text
global  _start

_start:
    mov     word [usersq], 273        ; DEBUG only
    mov     word [compsq], 72      ; DEBUG only
    call    showgrid

.firstturn:
    mov     eax, prompt1
    call    sprint

    mov     eax, userinput
    mov     ebx, 255
    call    input
    cmp     byte [userinput], 48    ; what number has the user entered? 0 or 1
    jz      userturn
    cmp     byte [userinput], 49    ; is 1, computer's turn
    jz      compturn

    mov     eax, badinput
    call    prints
    jmp     .firstturn              ; user has entered invalid input, retry

userturn:
    mov     byte [turn], 0
    mov     eax, prompt2
    call    sprint

    mov     eax, userinput
    mov     ebx, 255
    call    input

    mov     dl, 48
    mov     ecx, 0
    mov     cl, byte [userinput]
    sub     cl, dl                  ; set ecx to square number chosen
    cmp     cl, 1
    js      badmove                 ; if choice not number (too low), jump to bad move
    cmp     cl, 9
    jns     badmove                 ; if choice not number (too high), ditto

    ; TODO check move valid within game rules
    mov     eax, ecx
    call    moveisvalid

    call    printi

    jmp     finishup            ; DEBUG only for now

badmove:
    mov     eax, invalidmsg
    call    prints

    jmp     userturn

compturn:
    mov     byte [turn], 1

nextturn:

finishup:
    call    quit

; moveisvalid(int eax)
; takes move in eax as val 1-9
; returns 1 or 0 in eax for validity

moveisvalid:
    push    ebx
    push    edx
    mov     edx, [usersq]
    or      edx, [compsq]           ; this gets a full list of occupied squares in ebx

    sub     eax, 1
    mov     ebx, eax
    mov     eax, 2
    call    pow                 ; get binary flag equivalent of move

    and     edx, eax            ; compare to see if flag is set
    cmp     edx, 0      
    jz      .valid
    jmp     .invalid

.valid:
    mov     eax, 1
    jmp     .finish

.invalid:
    mov     eax, 0

.finish:
    pop     edx
    pop     ebx
    ret

; showgrid()
; prints the grid

showgrid:
    push    eax
    push    ebx
    push    ecx
    push    edx

    mov     ecx, 0
    mov     eax, startgrid
    mov     ebx, grid               ; reinit reserved space for grid from clean start
    call    copys

.nextchar:
    mov     eax, startgrid
    add     eax, ecx                ; get address of current byte, in eax

    mov     ebx, 0
    mov     bl, byte [eax]          ; bl holds ascii value of current byte

    cmp     ebx, 0
    jz      .finish

    sub     ebx, 49                 ; get index of grid number, 0-8
    js      .finnextchar            ; some checks for non numbers between 0-8
    cmp     ebx, 9
    jns     .finnextchar

    mov     eax, 2                  ; no need to preserve eax, it only served to get the current byte from grid
    call    pow                     ; ebx is still the number we want to use as index to get flag with
    mov     ebx, eax                ; ebx now holds flag value for this char

    mov     edx, [usersq]
    and     edx, ebx                ; check if flag set in usersq
    jnz     .setusersquare

    mov     edx, [compsq]
    and     edx, ebx                ; check if flag set in compsq
    jnz     .setcompsquare

    jmp     .finnextchar            ; if not set for either, just continue

.setusersquare:
    mov     eax, grid
    add     eax, ecx                ; get address of current byte, in eax, but to write this time
    mov     byte [eax], 79          ; 79 is O in ASCII
    jmp     .finnextchar

.setcompsquare:
    mov     eax, grid
    add     eax, ecx                ; get address of current byte, in eax, but to write this time
    mov     byte [eax], 88          ; 88 is X in ASCII
    jmp     .finnextchar

.finnextchar:
    inc     ecx
    jmp     .nextchar

.finish:
    mov     eax, grid               ; finally, actually display grid
    call    prints

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret
