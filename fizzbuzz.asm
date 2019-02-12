fizzbuzz:
    mov     eax, 100
    sub     eax, ecx        ; eax now holds the number we're on

    push    eax
    call    printi
    pop     eax

    call    fizzcheck       ; eax now holds the flags

    push    eax
    mov     ebx, 1
    call    verifyflag
    cmp     eax, 1
    mov     eax, fzz
    call    peax
    pop     eax

    push    eax
    mov     ebx, 2
    call    verifyflag
    cmp     eax, 1
    mov     eax, bzz
    call    peax
    pop     eax

    push    eax
    mov     ebx, 4
    call    verifyflag
    cmp     eax, 1
    mov     eax, bng
    call    peax
    pop     eax

    push    eax
    mov     eax, 0Ah
    push    eax
    mov     eax, esp
    call    sprint
    pop     eax
    pop     eax

    dec     ecx
    cmp     ecx, 0
    jnz     fizzbuzz


fizzfin:
    ret

; peax prints the eax if ZF is set

peax:
    jnz     peaxfinish
    call    sprint

peaxfinish:
    ret

; int fizzcheck(int eax)
; returns eax with flags
; 001 - fizz
; 010 - buzz
; 100 - bang

fizzcheck:
    push    ebx
    push    ecx
    push    edx
    push    esi         ; esi will temporarily hold the flags

    mov     ebx, eax    ; allows us to reset eax each time

    mov     edx, 0      ; clear edx, which will hold the remainder
    mov     ecx, 3      ; check fizz
    idiv    ecx         ; divides eax by ecx
    call    addflagfizz

    mov     eax, ebx
    mov     edx, 0
    mov     ecx, 4      ; check buzz
    idiv    ecx
    call    addflagbuzz

    mov     eax, ebx
    mov     edx, 0
    mov     ecx, 5      ; check bang
    idiv    ecx
    call    addflagbang

    mov     eax, esi    ; set eax for return

    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

addflagfizz:
    cmp     edx, 0
    jnz     addflagfinish

    add     esi, 1
    jmp     addflagfinish
    
addflagbuzz:
    cmp     edx, 0
    jnz     addflagfinish

    add     esi, 2
    jmp     addflagfinish

addflagbang:
    cmp     edx, 0
    jnz     addflagfinish

    add     esi, 4
    jmp     addflagfinish
    
addflagfinish:
    ret

; verifyflag(int eax, int ebx)
; takes eax as flags, ebx as flag that needs verifying
; returns eax with 1 or 0 depending on verification

verifyflag:
    and     eax, ebx
    cmp     eax, ebx
    jz      setverify

    mov     eax, 0
    ret

setverify:
    mov     eax, 1
    ret