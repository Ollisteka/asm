.global _start
.text
_start:
	mov		$-127, %al  #127 инвертируем, прибавляем 1, получаем 0000001
	mov		$2, %bl	
	mov		$15, %cx
	
1:
	inc		%al
	dec		%bl
	dec		%cx
	jnz		1b
	#loop 1b
	
	cmp		%al, %bl
	ja 		2f
	
	#условие не выполнено
	movq	$mes1, %rsi
	movq	$l1, %rdx
	jmp		3f
	
#условие не выполнено
2:
	movq	$mes2, %rsi
	movq	$l2, %rdx

3:
	movq	$1, %rax
	movq	$1, %rdi
	syscall
	movq	$60, %rax
	syscall
	
.data
mes1:	.ascii "Условие не выполнено!\n"
l1 = . - mes1
mes2:	.ascii "Условие выполнено!\n"
l2 = . - mes2
