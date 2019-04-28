.model tiny
.code
org	100h	;first address
locals @@


CR = 0Dh
SYSCALL	=	21h
ESCAPE_SC = 01h
MAX_NOTE   =       119                     ; максимальный номер ноты

start:

include procs.asm
include macro.asm

terminate db 0

include int09.asm

main:
call install

read_key:

cmp [terminate], 0
jnz ex_it

xor bx, bx
mov bl, [tail]
cmp bl, [head]
jne @@buffer_not_empty
	call turn_note_off
	jmp read_key
	
@@buffer_not_empty:
add bx, offset kb_buffer
mov ax, [bx-1]


cmp al, 02h
jz @@song1
cmp al, 03h
jz @@song2
	call scancode2note
	push bx cx
	call get_note_freq
	pop cx bx
	test ax, ax
	jz read_key
	mov	bx, ax ;save quotient in BX

	call play_note
	jmp	read_key
	
@@song1:
	mov si, offset GUSI
	call play_song
	jmp	read_key

@@song2:
	mov si, offset FATHER
	call play_song
	jmp	read_key

ex_it:
	call uninstall
	call turn_note_off
	call_exit


play_note proc
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
	
	ret
play_note endp


turn_note_off:
	in	al, 61h	        ;read port into AL
	and	al, 11111100b	;mask lower 2 bits
	out	61h, al	        ;to turn off speaker
	ret

NoteFreqTable   DW      26580,25088,23680,22351,21096,19912,18795,17740,16744,15804,14917,14080 ; октава №9 (от "соль-диез" 7-й до "ля" 6-й), таблица для 120 значений (10 октав)


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
get_note_freq ENDP

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


Scan2NoteTable:
db 10h, 12*5+0
db 11h, 12*5+1
db 12h, 12*5+2
db 13h, 12*5+3
db 14h, 12*5+4
db 15h, 12*5+5
db 16h, 12*5+6
db 17h, 12*5+7
db 18h, 12*5+8
db 19h, 12*5+9
db 1ah, 12*5+10
db 1bh, 12*5+11

db 1eh, 12*4+0 ;C
db 1fh, 12*4+1 ;C#
db 20h, 12*4+2 ;D
db 21h, 12*4+3 ;D#
db 22h, 12*4+4 ;E
db 23h, 12*4+5 ;F
db 24h, 12*4+6 ;F#
db 25h, 12*4+7 ;G
db 26h, 12*4+8 ;G#
db 27h, 12*4+9 ;A
db 28h, 12*4+10 ;A#
db 2bh, 12*4+11 ;B

scancode2note proc
; Вход: AL = сканкод
; Выход: AL = нота
	push bx cx
	mov cx, 24
	xor bx, bx
@@find:
	cmp al, byte ptr (offset Scan2NoteTable + bx)
	jz @@found
	add bx, 2
	loop @@find
	mov al, MAX_NOTE
	inc al
	jmp @@exit
@@found:
	mov al, byte ptr (offset Scan2NoteTable + bx + 1)
@@exit:
	pop cx bx
	ret
scancode2note endp

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
	push cx
	call play_note
	pop cx
	loop @@loop

	call turn_note_off

	inc si
	loop @@play
@@make_pause:
		mov cx, 0fh
	@@loopp:
		push cx
		call note_pause
		pop cx
		loop @@loopp
	inc si
	loop @@play
@@exit:
	pop cx bx
	ret
play_song endp

note_pause proc
	mov cx, 0ffffh
	@@loop: loop $
	ret
note_pause endp

GUSI db F_NOTE, E_NOTE,D_NOTE, C_NOTE, G_NOTE,G_NOTE,G_NOTE, G_NOTE, F_NOTE,  E_NOTE, D_NOTE,C_NOTE, G_NOTE,G_NOTE,G_NOTE, G_NOTE, F_NOTE, A_NOTE,A_NOTE,F_NOTE,E_NOTE,G_NOTE,G_NOTE,E_NOTE,D_NOTE, E_NOTE,F_NOTE,D_NOTE, C_NOTE,C_NOTE,C_NOTE, C_NOTE,0

FATHER db G_NOTE, C5_NOTE, Dd5_NOTE, D5_NOTE, C5_NOTE, Dd5_NOTE, C5_NOTE, D5_NOTE, C5_NOTE, Gd_NOTE, Ad_NOTE, G_NOTE, G_NOTE, G_NOTE, G_NOTE,  MAX_NOTE+1, G_NOTE, C5_NOTE, Dd5_NOTE, D5_NOTE, C5_NOTE, Dd5_NOTE, C5_NOTE, D5_NOTE, C5_NOTE, G_NOTE, Fd_NOTE, F_NOTE, F_NOTE, F_NOTE, F_NOTE,  MAX_NOTE+1,  F_NOTE, Gd_NOTE, B_NOTE, D5_NOTE, D5_NOTE, D5_NOTE, D5_NOTE, MAX_NOTE+1, F_NOTE, Gd_NOTE, B_NOTE, C5_NOTE, C5_NOTE, C5_NOTE, C5_NOTE,  MAX_NOTE+1, C_NOTE, Dd_NOTE, Ad_NOTE, Gd_NOTE, G_NOTE, Ad_NOTE,Gd_NOTE,Gd_NOTE, G_NOTE, G_NOTE, C_NOTE - 1, C_NOTE, C_NOTE, C_NOTE,C_NOTE,0


end	start	;end assembly