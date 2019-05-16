	mov si, 81h
	xor cx, cx
	mov cl, ds:[0080h*1]

	cmp cl, 0
	jne @@parse_loop
	jmp @@prog

@@parse_loop:
	call skip_spaces
	
	cmp cx, 2
	jae @@2

	jmp @@prog
	
@@2:
	mov bl, '/'
	cmp [si*1], bl
	je @@3
	jmp @@args_error
@@3:
	call move_pointer
	mov bl, '?'
	cmp bl, [si*1]
	jne @@try_length_parse
	jmp @@args_help
	
@@try_length_parse:
	mov bl, 'l'
	cmp bl, [si*1]
	je @@length_parse
	mov bl, 'L'
	cmp bl, [si*1]
	jne @@try_food_parse
	@@length_parse:
		push offset snake_init_length
		push offset @@double_arg_error
		push LENGTH_MASK
		call arg_parse; PAGE_MASK, error, page_num
		push cx
		mov ax, 1
		mov cx, 25
		xor bx, bx
		mov bl, [snake_init_length]
		call is_inside
		pop cx
		jz @@snake_error
		jmp @@parse_loop
		
@@try_food_parse:
	mov bl, 'f'
	cmp bl, [si*1]
	je @@food_parse
	mov bl, 'F'
	cmp bl, [si*1]
	jne @@try_blink_parse
	@@food_parse:
		push offset food_init_count
		push offset @@double_arg_error
		push FOOD_MASK
		call arg_parse; PAGE_MASK, error, page_num
		push cx
		mov ax, 1
		mov cx, 50
		xor bx, bx
		mov bl, [food_init_count]
		call is_inside
		pop cx
		jz @@food_error
		jmp @@parse_loop

@@try_blink_parse:
	jmp @@args_error
	
	@@args_help:
	call_print help_args_msg
	jmp @@just_exit
	
	@@args_error:
	call_print error_msg
	jmp @@just_exit
	
	@@double_arg_error:
	call_print double_arg_err_msg
	jmp @@just_exit
	
	@@snake_error:
	call_print snake_err_msg
	jmp @@just_exit

	@@food_error:
	call_print food_err_msg
	jmp @@just_exit
	
	


error_msg   	db "Some error with args. Check help (/?).", "$"
double_arg_err_msg  db "You can't use the same argument twice", "$"
snake_err_msg  db "Snake init length must be inside [1, 25] range", "$"
food_err_msg  db "Max food amount must be inside [1, 50] range", "$"
help_args_msg db "Play snake and enjoy your life!",CR,LF,"/s - self-cross mode:",CR,LF,"    0 - allowed;",CR,LF,"    1 - will cut a tail;",CR,LF,"    2 - deadly;",CR,LF,"/u - upper wall type:",CR,LF,"    0 - death wall;",CR,LF,"    1 - swap wall;",CR,LF,"    2 - teleport wall;",CR,LF,"/l - snake init length (default is 15, max is 25);",CR,LF,"/f - food init amount (default is 3, max is 50);",CR,LF,"/? - this help", "$"
args_flags db 0 ;X|X|X|X|X|X|L|F
FOOD_MASK = 1
LENGTH_MASK = 2