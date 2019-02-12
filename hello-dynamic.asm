SECTION .data
msg		db		"Hello cheesy world!", 0Ah		; message

SECTION .text
global _start

_start:
	mov		ebx, msg 		; move address of string to ebx
	mov		eax, ebx 		; copy address to eax

nextchar:
	cmp		byte [eax], 0	; compare byte in eax to 0
	jz		finished
	inc		eax
	jmp		nextchar

finished:
	sub 	eax, ebx		; subtract address at ebx from eax
	mov 	edx, eax		; edx now has num of bytes in string
	mov 	ecx, msg
	mov 	ebx, 1			; STDOUT
	mov 	eax, 4			; SYS_WRITE
	int		80h

	mov 	ebx, 0
	mov 	eax, 1
	int 	80h