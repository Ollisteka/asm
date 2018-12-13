#!/bin/bash
if [ "$1" = "--help" ]; then
	echo 'Usage: bash comprun <file>'
	echo 'Compile and run your assembler code!'
else 
	as $1.s -o $1.o
	as numprint.s -o numprint.o
	as is_dec_number.s -o is_dec_number.o
	ld $1.o numprint.o is_dec_number.o -o  $1  
	./$1
fi
