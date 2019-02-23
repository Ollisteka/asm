.model tiny
.code
org 100h

entry:  mov cx, len
        lea di, flag
		lea si, flag
        mov bx, 01337h
@l:     lodsw
        xor ax, bx
        stosw
        loop @l
        mov ah, 09h
        lea dx, flag
        int 21h
        ret
flag db "q_vThZdLv@zQ{A~@d\rRdJ"
db '$'
len dw ($-flag-1)/2
end entry

;FLAG_IS_ASMBLRISSOEASY