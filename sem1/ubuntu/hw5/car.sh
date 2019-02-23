#!/bin/bash
if [ "$1" = "--help" ]; then
	echo 'Usage: bash comprun <file>'
	echo 'Compile and run your assembler code!'
else 
	as $1.s -o $1.o
	as copy_str.s -o copy_str.o
	ld $1.o copy_str.o -o $1  
	./$1
fi
