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

.macro start_exec operator_len, operands_number
    sub $\operator_len, %r10 # оставшаяся длина
    add $\operator_len, %r8  # указатель на строку
    mov -8(%rbp), %rax
    cmp $\operands_number, %rax
    jb  fail_too_few_args
.endm

.macro exec_bin_operation func, operator_len=1
    start_exec \operator_len, 2
    dec %rax
    mov %rax, -8(%rbp)
    pop %rax
    pop %rbx
    call_and_end_exec \func
.endm

.macro exec_unar_operation func, operator_len=1
    start_exec \operator_len, 1
    pop %rax
    call_and_end_exec \func
.endm


.macro call_and_end_exec func
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

.macro cycle_hex_symbols source, dest
    cell \source, 0, \dest
    cycle_numbers \source, \dest
    cell \source, "a", \dest
    cell \source, "A", \dest
    cell \source, "b", \dest
    cell \source, "B", \dest
    cell \source, "c", \dest
    cell \source, "C", \dest
    cell \source, "d", \dest
    cell \source, "D", \dest
    cell \source, "e", \dest
    cell \source, "E", \dest
    cell \source, "f", \dest
    cell \source, "F", \dest
.endm

.macro find_hex_let big_let, little_let, digit
        1:
            cmp $\big_let, %cl
            jne 1f
            mov $\digit, %cl
            jmp mult

        1:
            cmp $\little_let, %cl
            jne 1f
            mov $\digit, %cl
            jmp mult
.endm

.macro raise_error error_msg, error_msg_len
    echo \error_msg, \error_msg_len
    exit
.endm

REMAINDR = 37
MULT 	 = 42
PLUS     = 43
MINUS 	 = 45
DIVIDE 	 = 47
SGN      = 60
POWER    = 94
AND_ST   = 97
OR_ST    = 111
XOR_ST   = 120
MODULO   = 124
UNAR_MINUS = 126

.macro operator_switch
        cmp $PLUS, %al
        jne 1f
        exec_bin_operation plus_op
    1:
        cmp $MINUS, %al
        jne 1f
        exec_bin_operation minus_op

    1:
        cmp $MULT, %al
        jne 1f
        exec_bin_operation mult_op

    1:
        cmp $DIVIDE, %al
        jne 1f
        exec_bin_operation div_op

    1:
        cmp $REMAINDR, %al
        jne 1f
        exec_bin_operation remainder_op

    1:
        cmp $AND_ST, %al
        jne 1f
        exec_bin_operation and_op, 3

    1:
        cmp $OR_ST, %al
        jne 1f
        exec_bin_operation or_op, 2

    1:
        cmp $XOR_ST, %al
        jne 1f
        exec_bin_operation xor_op, 3

    1:
        cmp $UNAR_MINUS, %al
        jne 1f
        exec_unar_operation unar_min_op

    1:
        cmp $MODULO, %al
        jne 1f
        exec_unar_operation modulo_op, 2

    1:
        cmp $SGN, %al
        jne 1f
        exec_unar_operation sgn_op, 2

    1:
        cmp $POWER, %al
        jne 1f
        exec_bin_operation power_op
.endm
