.nolist

.macro read buf, lbuf
    mov		$0, 	%rax
	mov		$0, 	%rdi
    mov		\buf, 	%rsi
	mov		\lbuf,	%rdx
    syscall
.endm

.macro  echo   str len=1
	mov 		$1,    %rax
	mov 		$1,  %rdi
	mov 		$\str, %rsi
	mov 		$\len, %rdx
	syscall
.endm

.macro exit
	mov $60,    %rax
    syscall
.endm

.macro jmp_if_bit_set mask, label, flag_reg=%r12
	mov  $\mask, 	   %r15
    and  \flag_reg,   %r15
    cmp  $0,    	   %r15
	jne  \label # прыгнем, если бит установлен
.endm

.macro append_to_buf source, lsource, buffer
	mov \buffer, %rdi    
    mov \source, %rsi
	mov \lsource, %rcx
	call copy_str
    mov %rax, \buffer
.endm

.macro cell state, char, dest 
    .ascii "\char"
    .byte \state
    .word 0xDEAD, 0x00, 0x00
    .byte \dest, 0
    .word 0xFFFF, 0xFFFF, 0xFFFF
.endm

.macro cycle_letters source, dest 
    cell \source, "a", \dest
    cell \source, "b", \dest
    cell \source, "c", \dest
    cell \source, "d", \dest
    cell \source, "e", \dest
    cell \source, "f", \dest
.endm

.macro cycle_numbers source, dest 
    cell \source, 1, \dest
    cell \source, 2, \dest
    cell \source, 3, \dest
    cell \source, 4, \dest
    cell \source, 5, \dest
    cell \source, 6, \dest
    cell \source, 7, \dest
    cell \source, 8, \dest
    cell \source, 9, \dest
.endm

.macro exec_bin_operation func
    dec %r10 # оставшаяся длина
    inc %r8  # указатель на строку
    mov -8(%rbp), %rax
    cmp $2, %rax
    jb  fail_too_few_args
    dec %rax
    mov %rax, -8(%rbp)
    pop %rax
    pop %rbx
    call \func
    push %rax
    jmp lp
.endm


.macro run_fsm table, ltable
        mov $0, %dl         # state

    lp:
        cmp $0, %r10
        je success

        mov $0xDEADDEAD, %eax
        mov %dl, %ah
        movb (%rsi), %al

        cmp $0x20, %al # прочитали число до пробела
        je success

        mov $\ltable, %rcx
        mov $\table, %rdi
        repnz scasq     # rdi -> offset-part

        cmp $after, %rdi
        je fail

        movb (%rdi), %dl
        inc %rsi
        dec %r10

        jmp lp
.endm
