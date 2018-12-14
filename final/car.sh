#!/bin/bash
if [ "$1" = "--help" ]; then
	echo 'Usage: bash comprun <file>'
	echo 'Compile and run your assembler code!'
else 
	as $1.s -o $1.o
	as numprint.s -o numprint.o
	as is_dec_number.s -o is_dec_number.o
	as is_operator.s -o is_operator.o
	as dec_str_to_num.s -o dec_str_to_num.o
	as hex_str_to_num.s -o hex_str_to_num.o
	ld $1.o numprint.o is_dec_number.o is_operator.o dec_str_to_num.o hex_str_to_num.o -o  $1  
	./$1
fi
