%include 	'functions.asm'

SECTION .data
askmsg		db 		"Please enter your name: ", 0h
welcome		db		"Hello, ", 0h

SECTION .bss
userinput:	resb	255		; reserve 255 bytes of memory for user input

SECTION .text
global _start

_start:
	mov 	eax, askmsg
	call	sprint

	mov 	edx, 255			; the amount of bytes to read
	mov 	ecx, userinput 		; the buffer to write to
	mov 	ebx, 0				; write to STDIN
	mov 	eax, 3				; SYS_READ
	int 	80h

	mov 	eax, welcome
	call 	sprint

	mov 	eax, userinput
	call 	prints

	call 	quit