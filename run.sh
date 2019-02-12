#!/usr/bin/env bash

if [ -z $1 ]; then
	echo "You must specify a asm programme name"
	exit 1;
fi

echo "Assembling..."
if ( nasm -f elf -F dwarf -g $1.asm ); then
	echo "Linking..."
	ld -m elf_i386 -o $1 $1.o

	mv $1.o	objects/
	mv $1	objects/
	echo -e "Running...\n"
	./objects/$1
else
	echo "Encountered errors assembling"
fi
