.global _start
.text
_start:
	jmp *eee
	
	metka1:
		.byte 0, 1, 0xf
		.align 4
	
	metka2:
		.word 2, 2, 0x0, 0x25
		.align 8
	
	metka3:
		.long 3, 3, 23
		.align 4
	metka4:
		.quad 1, 2, 3, 4, 5
	d0:
		mov $1, %eax
		mov $1, %edi
		mov $mess, %rsi
		mov $lmess, %edx
		syscall

		mov $60, %eax
		mov $1, %edi
		syscall
.data
xxx: .quad 0, 0, 0
eee: .quad d0
mess: .ascii "goood\n"
lmess = . - mess
