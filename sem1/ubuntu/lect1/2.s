.globl _start   #точка входа
.text 			#секция кода с исполняемыми машинными командами

_start:
	mov		$4,  %eax
	mov		$1,  %ebx
	mov		$messg,  %ecx
	mov		$lmessg,  %edx
	int		$0x80		#генерируем прерывание
	
	#функция выхода
	mov 	$1, %eax
	mov 	$37, %ebx 	#код возврата
	int 	$0x80

.data
messg:	.ascii "Hello, world!\n"
		.byte  10

lmessg = . - messg  #вычитаем из текущего адреса адрес строки
