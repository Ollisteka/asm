.globl _start #директивна globl говорит, что точка входа - это старт. Используем main, если компилируем с помощью gcc

.text #секция кода
_start:

	#write
	mov	$4, %eax	#write
	mov $1, %ebx  	#sys.out
	mov $msg, %ecx	
	mov $msglen, %edx
	int $0x80
	
	#exit
	mov $1, %eax 	#положили в региcтр eax номер функции exit
	int $0x80  		#позвали syscall, который из eax возмёт функцию exit
	
.data #секция данных
msg: .ascii "Hello!"
msglen = . - msg  #. - текущий адрес
