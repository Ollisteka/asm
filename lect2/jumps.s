.global _start
.text
_start:
	mov		$-127, %al  #127 инвертируем, прибавляем 1, получаем 0000001
	mov		$2, %bl
	cmp		%al, %bl    #сравниваем bl с al (bl-al)
	#ja 		1f			#jump above (bl>al),  без знаков
	#jg 		1f			#jump greater (bl>al),  умеет в знаки
	#js 		1f			#jump sign (SF == 1),  умеет в знаки
							#f - forward, b - backward
	#условие не выполнено
	movq	$mes1, %rsi
	movq	$l1, %rdx
	jmp		2f
	
#условие выполнено
1:
	movq	$mes2, %rsi
	movq	$l2, %rdx
	

#выводим на экран и выходим
2:
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
