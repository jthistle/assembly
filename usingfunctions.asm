%include 		'functions.asm'
%include 		'fizzbuzz.asm'

SECTION .data
fzz		db		" Fizz ", 0h
bzz		db		" Buzz ", 0h
bng		db 		" Bang ", 0h

SECTION .bss

SECTION .txt
global _start

_start:
	mov 	ecx, 99		; how many to count

	call 	fizzbuzz

	call 	quit