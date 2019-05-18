jmp main

C_NOTE = 12*4+0 ;C
Cd_NOTE = 12*4+1 ;C#
D_NOTE = 12*4+2 ;D
Dd_NOTE = 12*4+3 ;D#
E_NOTE = 12*4+4 ;E
F_NOTE = 12*4+5 ;F
Fd_NOTE = 12*4+6 ;F#
G_NOTE = 12*4+7 ;G
Gd_NOTE = 12*4+8 ;G#
A_NOTE = 12*4+9 ;A
Ad_NOTE = 12*4+10 ;A#
B_NOTE = 12*4+11 ;B

C5_NOTE = 12*5+0 ;C
Cd5_NOTE = 12*5+1 ;C#
D5_NOTE = 12*5+2 ;D
Dd5_NOTE = 12*5+3 ;D#
E5_NOTE = 12*5+4 ;E
F5_NOTE = 12*5+5 ;F
Fd5_NOTE = 12*5+6 ;F#
G5_NOTE = 12*5+7 ;G
Gd5_NOTE = 12*5+8 ;G#
A5_NOTE = 12*5+9 ;A
Ad5_NOTE = 12*5+10 ;A#
B5_NOTE = 12*5+11 ;B

MAX_NOTE   =       119                     ; максимальный номер ноты


FATHER db G_NOTE, C5_NOTE, Dd5_NOTE, D5_NOTE, C5_NOTE, Dd5_NOTE, C5_NOTE, D5_NOTE, C5_NOTE, Gd_NOTE, Ad_NOTE, G_NOTE, G_NOTE, G_NOTE, G_NOTE,  MAX_NOTE+1, G_NOTE, C5_NOTE, Dd5_NOTE, D5_NOTE, C5_NOTE, Dd5_NOTE, C5_NOTE, D5_NOTE, C5_NOTE, G_NOTE, Fd_NOTE, F_NOTE, F_NOTE, F_NOTE, F_NOTE,  MAX_NOTE+1,  F_NOTE, Gd_NOTE, B_NOTE, D5_NOTE, D5_NOTE, D5_NOTE, D5_NOTE, MAX_NOTE+1, F_NOTE, Gd_NOTE, B_NOTE, C5_NOTE, C5_NOTE, C5_NOTE, C5_NOTE,  MAX_NOTE+1, C_NOTE, Dd_NOTE, Ad_NOTE, Gd_NOTE, G_NOTE, Ad_NOTE,Gd_NOTE,Gd_NOTE, G_NOTE, G_NOTE, C_NOTE - 1, C_NOTE, C_NOTE, C_NOTE,C_NOTE,0

FAIL db D_NOTE, Cd_NOTE, C_NOTE, C_NOTE-1, C_NOTE-1, C_NOTE-1, 0

NoteFreqTable   DW      26580,25088,23680,22351,21096,19912,18795,17740,16744,15804,14917,14080 ; октава №9 (от "соль-диез" 7-й до "ля" 6-й), таблица для 120 значений (10 октав)

play_super_food_creation_sound:
	mov al, Cd_NOTE
	call play_one_note
	mov al, Dd_NOTE
	call play_one_note
	mov al, Cd_NOTE
	call play_one_note
	mov al, Dd_NOTE
	call play_one_note
	ret

play_super_food_sound:
	mov al, Fd_NOTE
	call play_one_note
	mov al, Gd_NOTE
	call play_one_note
	mov al, Ad_NOTE
	call play_one_note
	ret

play_good_food_sound:
	mov al, C_NOTE
	call play_one_note
	ret
	

play_strange_food_sound:
	mov al, Gd_NOTE
	call play_one_note
	ret
	
play_one_note:
;AL - note
	call get_note_freq
	mov bx, ax
	call play_note
	call turn_note_off
	ret

play_note proc
	push cx
	mov	al,  10110110b	;заносим слово состояния  
	out	43h, al ;в командный регистр
	mov	ax, bx  ;1/pitch into AX
	out	42h, al ;LSB into timer2
	mov	al, ah   ;MSB to AL, then
	out	42h, al
	in	al, 61h	 
	or	al, 3    ;turn on bits 0 and 1
	out	61h, al	 ;to turn on speaker
	
	;sound note for a while
	mov	cx, 0ffffh	;set up for delay
	.wait:	loop	$ ;delay
	pop cx
	ret
play_note endp


turn_note_off:
	in	al, 61h	        ;read port into AL
	and	al, 11111100b	;mask lower 2 bits
	out	61h, al	        ;to turn off speaker
	ret
	
get_note_freq PROC
; Вход: AL = нота (от 0 - "ля" субконтроктавы до 119 (MAX_NOTE) - "соль-диез" 7-й октавы)
; Выход: AX = частота ноты или ноль при входном значении > MAX_NOTE
	push bx cx
	cmp     al, MAX_NOTE
	jbe     @@note_ok
	xor     ax, ax
	jmp @@exit
@@note_ok:
	cbw
	mov     bl, 12
	div     bl                      ; AL = октава (0=субконтроктава, 1=контроктава, 2=большая, 3=малая, 4=первая...), ah=нота в октаве (0..11, начиная с "ля")
	xchg    cx, ax                   ; CL = октава, CH - нота
	mov     bl, ch
	xor     bh, bh
	shl     bx, 1                    ; BX = нота*2
	mov     ax, NoteFreqTable[bx]
	shr     ax, cl                   ; AX = частота ноты
	adc     ax, 0                    ; правильное округление
@@exit:
	pop cx bx
	ret
endp get_note_freq

play_song proc
; SI - offset SONG
	push bx cx
@@play:
	mov al, [si]
	test al, al
	jz @@exit
	call get_note_freq
	cmp ax, 0
	je @@make_pause
	mov	bx, ax ;save quotient in BX
mov cx, 0fh
@@loop:
	call check_for_key_press
	jz @@no_keystroke

	cmp ah, ESC_KEY
	je @@exit
	
	cmp ah, R_KEY
	je @@exit
@@no_keystroke:
	call play_note
	loop @@loop

	call turn_note_off

	inc si
	loop @@play
@@make_pause:
		mov cx, 0fh
	@@loopp:
		call note_pause
		loop @@loopp
	inc si
	loop @@play
@@exit:
	call turn_note_off
	pop cx bx
	ret
play_song endp

note_pause proc
	push cx
	mov cx, 0ffffh
	@@loop: loop $
	pop cx
	ret
note_pause endp