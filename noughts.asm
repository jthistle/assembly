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
drawmsg     db      "The game is a draw!", 0h
playagain   db      "Play again? [y/n]: ", 0h
newline     db      0Ah, 0h

SECTION .bss
grid:       resb    18          ; store grid
userinput:  resb    255         ; reserve 255 bytes of memory for user input
turn:       resb    1           ; 1 byte to hold 0 or 1 for whose go it is - may not be needed
usersq:     resb    2           ; user squares, e.g. 1 = 1, 2 = 2, 3 = 4, 4 = 8 ... 9 = 128
compsq:     resb    2           ; computer squares, in same format

SECTION .text
global  _start

restart:
    mov     word [usersq], 0
    mov     word [compsq], 0
    jmp     firstturn

_start:
    nop

firstturn:
    mov     eax, prompt1
    call    sprint

    mov     eax, userinput
    mov     ebx, 255
    call    input
    cmp     byte [userinput], 48    ; what number has the user entered? 0 or 1
    jz      fulluserturn
    cmp     byte [userinput], 49    ; is 1, computer's turn
    jz      compturn

    mov     eax, badinput
    call    prints
    jmp     firstturn               ; user has entered invalid input, retry

fulluserturn:
    call    showgrid

.userturn:
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
    js      .badmove                 ; if choice not number (too low), jump to bad move
    cmp     cl, 10
    jns     .badmove                 ; if choice not number (too high), ditto

    ; check move valid within game rules
    mov     eax, ecx
    call    moveisvalid
    cmp     eax, 0
    jz      .badmove

    mov     eax, ecx
    call    placesq                 ; actually add the square

    call    checkwin

    jmp     compturn            ; now it's the computer's go

.badmove:
    mov     eax, invalidmsg
    call    prints

    jmp     .userturn

compturn:
    mov     byte [turn], 1
    mov     ecx, 1

.dwnextnum:                     ; direct win - check if comp can win in 1 move
    ; first, check comp win
    ; check if comp can actually play in square first
    mov     eax, ecx
    call    moveisvalid
    cmp     eax, 0
    jz      .dwfinishup          ; if can't play anyway, skip checks

    mov     edx, 0
    mov     dx, word [compsq]

    mov     eax, ecx
    call    getflag             ; eax now holds flag
    or      edx, eax            ; temp add eax to edx to get compsq as if that flag had been added in edx

    push    ecx
    push    edx
    mov     edx, esp            ; put pointer to temp compsq in edx
    call    checkonesq          ; eax now holds 1 or 0 if this causes a win
    pop     edx
    pop     ecx

    cmp     eax, 1
    jz      .compplacesq

.dwfinishup:
    ; finish up, move to next num
    inc     ecx
    cmp     ecx, 10
    jns     .blockuser     ; out of range, move on
    jmp     .dwnextnum

.blockuser:
    mov     ecx, 1

.bunextnum:
    ; check user win
    mov     eax, ecx
    call    moveisvalid
    cmp     eax, 0
    jz      .bufinishup          ; if can't play anyway, skip checks

    mov     edx, 0
    mov     dx, word [usersq]
    mov     eax, ecx
    call    getflag
    or      edx, eax

    push    ecx
    push    edx
    mov     edx, esp            ; put pointer to temp compsq in edx
    call    checkonesq          ; eax now holds 1 or 0 if this causes a win
    pop     edx
    pop     ecx

    cmp     eax, 1
    jz      .compplacesq

.bufinishup:
    ; finish up, move to next num
    inc     ecx
    cmp     ecx, 10
    jns     .compfork     ; out of range, move on
    jmp     .bunextnum

.compfork:      ; try to create two opportunities to win
    mov     edx, compsq
    mov     ebx, usersq
    call    findforks
    cmp     eax, 0
    jnz     .foundfork
    jmp     .userfork

.userfork:      ; try and block any user forks
    mov     edx, usersq
    mov     ebx, compsq
    call    findforks
    cmp     eax, 0
    jnz     .foundfork
    jmp     .checkcentre    ; move on to next check

.foundfork:
    mov     ecx, eax
    jmp     .compplacesq

.checkcentre:
    mov     eax, 5
    call    moveisvalid
    mov     ecx, 5
    cmp     eax, 1
    jz      .compplacesq
    jmp     .checkcorners

.checkcorners:
    mov     ebx, 0
    mov     bx, word [usersq]   ; ebx now holds user square

    mov     eax, 9
    call    moveisvalid
    cmp     eax, 1
    mov     eax, 1
    call    .cornervalid

    mov     eax, 7
    call    moveisvalid
    cmp     eax, 1
    mov     eax, 4
    call    .cornervalid

    mov     eax, 3
    call    moveisvalid
    cmp     eax, 1
    mov     eax, 64
    call    .cornervalid

    mov     eax, 1
    call    moveisvalid
    cmp     eax, 1
    mov     eax, 256
    call    .cornervalid

    jmp     .emptycorner     ; move on to next check

.cornervalid:
    jnz     .cornernotvalid     ; this will be zero if the move is valid
    push    ebx
    sub     ebx, eax
    cmp     ebx, 0
    pop     ebx
    jz      .compplacesq
    ret

.cornernotvalid:
    ret

.emptycorner:           ; I could do this programmatically rather than hardcoded, but it's more complicated
    mov     eax, 1
    mov     ecx, 1
    call    moveisvalid
    cmp     eax, 1
    jz      .compplacesq

    mov     eax, 3
    mov     ecx, 3
    call    moveisvalid
    cmp     eax, 1
    jz      .compplacesq

    mov     eax, 7
    mov     ecx, 7
    call    moveisvalid
    cmp     eax, 1
    jz      .compplacesq

    mov     eax, 9
    mov     ecx, 9
    call    moveisvalid
    cmp     eax, 1
    jz      .compplacesq

    jmp     .emptyside     ; move on to next check

.emptyside:                 ; plays in the middle square
    mov     ecx, 2

.nextside:
    mov     eax, ecx
    call    moveisvalid
    cmp     eax, 1
    jz      .compplacesq

    add     ecx, 2
    cmp     ecx, 10
    jns     .finishcompturn
    jmp     .nextside

.compplacesq:               ; places value in ecx
    mov     eax, ecx
    call    placesq
    jmp     .finishcompturn

.finishcompturn:
    call    checkwin
    jmp     fulluserturn

finishup:
    mov     eax, playagain
    call    sprint
    mov     eax, userinput
    mov     ebx, 255
    call    input

    cmp     byte [userinput], 121
    jz      restart

    cmp     byte [userinput], 110
    jz      endprogramme

    mov     eax, badinput
    call    prints
    jmp     finishup 

endprogramme:
    call    quit

; findforks(int* edx, int* ebx)
; finds forks in square at eax, provided ebx is the other square
; returns where to play to create/prevent fork in eax as num 1-9. 0 if no forks

findforks:
    push    ecx
    mov     ecx, 1

.nextsq:
    mov     eax, ecx
    call    moveisvalid         ; this preserves edx and ebx anyway
    cmp     eax, 0
    jz      .nextsqfinishup     ; if can't play anyway, skip checks

    mov     edi, 0
    mov     di, word[edx]

    mov     eax, ecx
    call    getflag
    or      edi, eax            ; now edi has the square with ecx played

    push    ebx
    push    edi
    mov     eax, esp

    call    checkisfork         ; ebx is already set as the second square
    cmp     eax, 0
    pop     edi
    pop     ebx
    jnz     .finishyesfork      ; if it's not zero, we've found a fork!

.nextsqfinishup:
    inc     ecx
    cmp     ecx, 10
    jns     .finishnofork       ; out of range, finish
    jmp     .nextsq

.finishyesfork:
    mov     eax, ecx            ; ecx still holds the 'current' sq num we're on
    pop     ecx
    ret

.finishnofork:
    pop     ecx
    mov     eax, 0
    ret

; checkisfork(int eax*, int* ebx)
; check if the square in eax can be won in two ways
; provided that ebx is the other square

checkisfork:
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi             ; this will store how many ways we can win
    mov     ecx, 1

.nextnum:
    push    eax
    mov     eax, ecx
    call    moveisvalid     ; if move is valid, we can skip this num and continue
    cmp     eax, 0
    pop     eax
    jz      .nextnumfin

    push    eax
    mov     eax, ecx
    call    getflag
    mov     edx, eax        ; edx now has the flag for the num in ecx
    pop     eax

    push    eax             ; checkonesq has no protections, so push important stuff
    push    ebx
    push    ecx
    push    esi

    mov     edi, 0          ; we'll use edi to hold the eax grid with the edx flag played
    mov     di, word [eax]
    or      edi, edx        ; edi now has the grid with flag in edx played in it
    push    edi
    mov     edx, esp        ; checkonesq takes an address of the sq, so put edx on the stack
    call    checkonesq
    cmp     eax, 0          ; if eax is 1, we the square in edx is a winning square
    pop     edi
    
    pop     esi
    pop     ecx
    pop     ebx
    pop     eax
    jz      .nextnumfin     ; we can't win by placing it there, continue

    inc     esi             ; we CAN win. Inc win count
    cmp     esi, 2          ; have we reached the required number of wins?
    jz      .finishyes

.nextnumfin:
    inc     ecx
    cmp     ecx, 10
    jns     .finishno
    jmp     .nextnum

.finishyes:
    mov     eax, 1
    jmp     .finish

.finishno:
    mov     eax, 0

.finish:
    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    ret

; moveisvalid(int eax)
; takes move in eax as val 1-9
; returns 1 or 0 in eax for validity

moveisvalid:
    push    ebx
    push    edx
    mov     edx, [usersq]
    or      edx, [compsq]           ; this gets a full list of occupied squares in ebx

    call    getflag             ; get binary flag equivalent of move

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

    add     ebx, 1                  ; set ebx to a val 1-9 again
    mov     eax, ebx                ; get flag takes argument in eax
    call    getflag                 ; no need to preserve eax, it only served to get the current byte from grid
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

; placesq(int eax)
; place an O (user) or X (comp) in square in eax, val 1-9
; uses value in turn to work out what to add to

placesq:
    push    ebx
    push    eax

    call    getflag         ; eax now holds flag value

    cmp     byte [turn], 0  ; check whose turn it is in order to place correct square
    jz      .adduser
    jmp     .addcomp

.adduser:
    or      word [usersq], ax
    jmp     .fin

.addcomp:
    or      word [compsq], ax
    jmp     .fin

.fin:
    pop     eax
    pop     ebx
    ret

; checkwin()
; checks the grids for a winning combo and ends game if found
; win can be scored with:
;   - three nums three apart e.g. 1,4,7
;   - three consecutive nums e.g. 1,2,3
;   - three numbers that are 1,5,9 or 3,5,7

checkwin:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi

    mov     edx, 0
    mov     dx, word [usersq]
    or      dx, word [compsq]
    cmp     edx, 511            ; 511 is a full grid
    jz      endnowin            ; grid full, draw

    mov     edx, usersq         ; do user sq check
    call    checkonesq
    cmp     eax, 1
    jz      enduserwin

    mov     edx, compsq         ; do comp sq check
    call    checkonesq
    cmp     eax, 1
    jz      endcompwin

    jmp     .finish

.finish:
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

; checkonesq(int* edx)
; checks for win in square at address edx
; returns 1 or 0 in eax

checkonesq:
    mov     ecx, 1

.nextsqv:                        ; check vertical matches
    call    .checkvertical       ; do checks for start square ecx

    inc     ecx
    cmp     ecx, 4
    jz      .checkonesqh    ; check if we've done all numbers, if so end this and move to horizontal checks
    jmp     .nextsqv        ; move to the next base square

.checkonesqh:               ; now horizontal checks
    mov     ecx, 1

.nextsqh:
    call    .checkhorizontal    ; do checks for start square ecx

    mov     ebx, 3
    add     ecx, ebx
    cmp     ecx, 10
    jns     .checkonesqdiag ; check if we've done all numbers, if so end this sq check - TEMPDEBUG
    jmp     .nextsqh        ; move to the next square on left side

.checkonesqdiag:
    call    .checkdiagonal  ; if diagonal exists, this will redirect to win
    jmp     .onesqnowin

; start check vertical

.checkvertical:             ; ecx holds init number to check, must not be changed
    mov     edi, 0          ; this holds the flag combo needed for a win
    mov     ebx, ecx

.nextonev:
    mov     eax, ebx
    call    getflag

    add     edi, eax
    add     ebx, 3              ; inc ebx by three to get next sq up
    cmp     ebx, 10
    jns     .fincheckvertical   ; out of range, finish
    jmp     .nextonev

.fincheckvertical:
    mov     ebx, 0     
    mov     bx, word [ edx ]    ; move sq at edx to bx
    and     ebx, edi
    cmp     ebx, edi
    jz      .onesqwin       ; we have a win, finish all checks, otherwise continue
    ret                     ; returns to .nextsqv
    
; end check vertical

; start check horizontal

.checkhorizontal:
    mov     edi, 0          ; again, this holds the flag combo needed for a win
    mov     ebx, ecx

.nextoneh:
    mov     eax, ebx
    call    getflag

    add     edi, eax
    inc     ebx                 ; inc ebx to get next sq along
    
    push    ecx
    add     ecx, 3
    cmp     ebx, ecx
    pop     ecx
    jns     .fincheckhoriz      ; out of range, finish
    jmp     .nextoneh

.fincheckhoriz:
    mov     ebx, 0     
    mov     bx, word [ edx ]    ; move sq at edx to bx
    and     ebx, edi
    cmp     ebx, edi
    jz      .onesqwin       ; we have a win, finish all checks, otherwise continue
    ret                     ; returns to .nextsqh

; end check horizontal

; start check diagonal
; simpler to do hardcoded combos

.checkdiagonal:
    mov     eax, 273        ; 1,5,9 combo
    call    .againstgriddiag

    mov     eax, 84         ; 3,5,7 combo
    call    .againstgriddiag
    ret

.againstgriddiag:
    mov     ebx, 0     
    mov     bx, word [ edx ]    ; move sq at edx to bx
    and     ebx, eax
    cmp     ebx, eax
    jz      .windiag
    ret

.windiag:
    pop     eax         ; pop return pointer off so we return to calling function from onesqwin
    jmp     .onesqwin

; end check diagonal

; win condition functions for checkonesq

.onesqnowin:
    mov     eax, 0
    ret                     ; this will return to checkwin

.onesqwin:                  ; this will be called inside a .checkx function
    pop     eax             ; pop off return pointer so we'll return to checkwin
    mov     eax, 1
    ret

; if win conditions are met, use one of these

enduserwin:
    call    showgrid

    mov     eax, winmsg
    call    prints
    jmp     endwinfin
    
endcompwin:
    call    showgrid

    mov     eax, losemsg
    call    prints
    jmp     endwinfin

endnowin:
    call    showgrid

    mov     eax, drawmsg
    call    prints
    jmp     endwinfin

endwinfin:
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    pop     eax         ; pop return pointer off stack
    jmp     finishup

; getflag(int eax)
; gets a flag value from the number in eax
; where eax is a num 1-9

getflag:
    push    ebx
    mov     ebx, eax
    sub     ebx, 1
    mov     eax, 2
    call    pow             ; now eax has the flag needed

    pop     ebx
    ret
