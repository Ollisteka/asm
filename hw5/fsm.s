.globl _start
.include  "macro.s"

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
    cell \source, 0, \dest
    cell \source, 1, \dest
    cell \source, 2, \dest
    cell \source, 3, \dest
    cell \source, 4, \dest
.endm

EMPTY_ANCHOR = 128
END = 64
PROTOCOL = 32
HOST = 16
PORT = 8
PATH = 4
QUERY = 2
ANCHOR = 1
#  arg1  arg2  arg3  arg4  arg5  arg6  arg7
#  rdi   rsi   rdx   r10   r8    r9    -
.text
_start:
    echo example lexample
    echo newl
    xor %r9, %r9
    xor %r12, %r12 # EMPTY-ANCH_END_PROT_HOST_PORT_PATH_QUERY_ANCHOR
                   #     128    64  32    16   8    4    2      1

    mov $0, %dl         # state
    mov $example, %r8  # str
    mov $lexample, %r10 # length
lp:
    cmp $0, %r10
    je ex

    mov $0xDEADDEAD, %eax
    mov %dl, %ah        # source
    movb (%r8), %al    # letter

    push %rax
    cmp $4, %ah
    je protocol_pr
    cmp $8, %ah # прочитали хост
    je host_pr
    cmp $10, %ah # прочитали порт
    je port_pr
    cmp $12, %ah # прочитали path
    je path_pr
    cmp $15, %ah # прочитали query и есть anchor
    je query_pr
    jmp save_ch_to_buf
    
protocol_pr:
    jmp_if_bit_set PROTOCOL, save_ch_to_buf

    echo protocol lprotocol
    or $PROTOCOL, %r12
    add  $2, %r9
    jmp print_buf

host_pr:
    jmp_if_bit_set HOST, save_ch_to_buf

    echo host lhost
    or $HOST, %r12
    jmp print_buf

port_pr:
    jmp_if_bit_set HOST, cont_port

    or $PORT, %r12 # перепрыгнули на конец порта, на напечатав хост == порта не было
    jmp   host_pr
 
cont_port:
    jmp_if_bit_set PORT, save_ch_to_buf  # сюда возвращаемся, парся query

    echo port lport
    or $PORT, %r12
    jmp print_buf

path_pr:
    jmp_if_bit_set PORT, cont_path

    or $PATH, %r12  # перепрыгнули на конец пути, на напечатав порт == пути не было
    jmp  port_pr

cont_path:
    jmp_if_bit_set PATH, save_ch_to_buf

    echo path lpath
    or $PATH, %r12
    jmp print_buf

query_pr:
    jmp_if_bit_set PORT, cont_query

    or $QUERY, %r12 # перепрыгнули на конец query, на напечатав порт == query не было
    jmp   port_pr
 
cont_query:
    jmp_if_bit_set QUERY, save_ch_to_buf

    echo query lquery
    or $QUERY, %r12
    jmp print_buf

anchor_pr:
    jmp_if_bit_set QUERY, cont_anch

    or  $ANCHOR, %r12
    or  $EMPTY_ANCHOR, %r12
    inc %r9
    jmp query_pr

cont_anch:
    jmp_if_bit_set ANCHOR, save_ch_to_buf

    echo anchor lanchor
    or $ANCHOR, %r12
    jmp print_buf
    
print_buf:
    mov  $lexample, %rdx
    sub  %r10, %rdx
    sub  %r9, %rdx

    mov  $END, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne  cont_print

    dec  %rdx

cont_print:
    mov $1,    %rax
	mov $1,    %rdi
	mov $buffer, %rsi
	syscall
    cmp  $0,    %r15
    jne ex_it

clear_buf:    
    inc %rdx
    add %rdx, %r9 # столько символов мы стёрли в прошлые разы
    mov %rdx, %rcx
    mov $buffer, %rdi
    mov $32, %al
    repnz stosb
    echo newl

save_ch_to_buf:
    pop %rax
    mov $lexample, %rdx
    sub  %r10, %rdx # cдвиг относительно начала строки
    sub  %r9, %rdx
    movb %al,   buffer(%rdx)

    mov $ls, %rcx
    mov $ss, %rdi
    repnz scasq # rdi -> offset-part

b:
    cmp $after, %rdi
    je fail

    movb (%rdi), %dl
    inc %r8
    dec %r10

    jmp lp
ex:
    push %rdx
    or $END, %r12
    cmp $7, %dl # прочитали хост
    je host_pr
    cmp $9, %dl # прочитали порт
    je port_pr
    cmp $10, %dl # прочитали path
    je path_pr
    cmp $11, %dl # прочитали path
    je path_pr
    cmp $12, %dl # прочитали path
    je query_pr
    cmp $13, %dl # прочитали query
    je query_pr
    cmp $14, %dl # прочитали query
    je query_pr
    cmp $15, %dl # anchor
    je anchor_pr

fail:
    cls
    echo invalid linvalid
    exit

print:
    echo buffer lbuffer

ex_it:
    mov  $EMPTY_ANCHOR, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    je cont_ex
    echo newl
    echo   anchor lemptyanchor

cont_ex:
    echo newl
    pop %rdx
    mov  %dl,   %al
    call num_to_str
    movq $result, %rdi
    append %rax %rbx
    echo result 3
    exit

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cycle_letters 0, 1  # 6
    s1: cycle_letters 1, 1  # 6
        cell 1, ":", 2
        cell 1, ".", 6
    s2: cell 2, "/", 3
    s3: cell 3, "/", 4
    s4: cycle_letters 4, 5  # 6
    s5: cycle_letters 5, 5  # 6
        cell 5, ".", 6
    s6: cycle_letters 6, 7  # 6
    s7: cycle_letters 7, 7  # 6 
        cell 7, ":", 8
        cell 7, ".", 6
        cell 7, "/", 10
        cell 7, "?", 12
        cell 7, "#", 15
    s8: cycle_numbers 8, 9 # 5
    s9: cycle_numbers 9, 9 # 5
        cell 9, "/", 10
        cell 9, "?", 12
        cell 9, "#", 15
    s10: cycle_letters 10, 11  # 6 
    s11: cycle_letters 11, 11  # 6 
         cell 11, "/", 10
         cell 11, "?", 12
         cell 11, "#", 15
    s12: cycle_letters 12, 13  # 6
    s13: cell 13, "&", 12
         cycle_letters 13, 13  # 6
         cell 13, "=", 14
    s14: cycle_letters 14, 14  # 6
         cell 14, "&", 12
         cell 14, "#", 15
    s15: cycle_letters 15, 15  # 6

    # ls = 206 # (12*6 + 5*2 + 20) * 2 
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0

    example: .ascii "bace://a.bc.def:012334/a/b/c/d/e/f#abcddf"
    lexample = . - example

    result: .ascii "  \n"

    invalid: .ascii "INVALID_URL\n"
    linvalid = . - invalid

    buffer:	 .ascii	"                            \n" 
    lbuffer =  . - buffer

    protocol: .ascii "Protocol: "
    lprotocol = . - protocol

    host: .ascii "Host: "
    lhost = . - host

    port: .ascii "Port: "
    lport = . - port

    path: .ascii "Path: "
    lpath = . - path

    query: .ascii "Query: "
    lquery = . - query

    anchor: .ascii "Anchor: "
    lanchor = . - anchor

    emptyanchor: .ascii "empty"
    lemptyanchor = . - anchor
    space: .ascii " "
    newl: .ascii "\n"

    host_printed = 0
    last_printed_len = 0
    