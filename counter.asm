%include 		'functions.asm'

SECTION .data
fnmsg	db 		'Finished!', 0h
dbmsg	db 		'Debug', 0h

SECTION .text
global _start

_start:
	mov		esi, 10		; init counter

decrement:
	cmp		esi, 0
	jz		finish
	dec 	esi

output:
	mov 	eax, 48		; 0 in ascii
	add		eax, esi
	push 	eax
	mov 	eax, esp
	call	prints
	pop 	eax

	jmp 	decrement

finish:
	mov		eax, fnmsg	; write final message
	call 	prints

	mov 	ebx, 0
	mov 	eax, 1
	int 	80h