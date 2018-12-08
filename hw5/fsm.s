.globl _start
.include  "macro.s"

.macro cell state, char, dest 
    .ascii "\char"
    .byte \state
    .word 0xDEAD, 0x00, 0x00
    .byte \dest, 0
    .word 0xFFFF, 0xFFFF, 0xFFFF
.endm

EMPTY_ANCHOR = 128
EMPTY_ANCHOR_MASK = 0b10000000
END = 64
END_MASK = 0b1000000
PROTOCOL = 32
PROTOCOL_MASK = 0b100000
HOST = 16
HOST_MASK = 0b010000
PORT = 8
PORT_MASK = 0b001000
PATH = 4
PATH_MASK = 0b000100
QUERY = 2
QUERY_MASK = 0b000010
ANCHOR = 1
ANCHOR_MASK = 0b000001
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
    jmp 1f
    
protocol_pr:
    mov  $PROTOCOL_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne 1f
    echo protocol lprotocol
    or $PROTOCOL, %r12
    add  $2, %r9
    jmp print_buf

host_pr:
    mov  $HOST_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne 1f
    echo host lhost
    or $HOST, %r12
cont:
    jmp print_buf

port_pr:
    mov  $HOST, %r15 
    and  %r12,   %r15
    cmp  $0,    %r15 # перепрыгнули на конец порта, на напечатав хост
    jne  cont_port
    or $PORT, %r12
    jmp   host_pr
 
cont_port:
    mov  $PORT_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne 1f

    echo port lport
    or $PORT, %r12
    jmp print_buf

path_pr:
    mov  $PORT, %r15 
    and  %r12,   %r15
    cmp  $0,    %r15 # перепрыгнули на конец порта, на напечатав хост
    jne  cont_path
    or $PATH, %r12
    jmp   port_pr

cont_path:
    mov  $PATH_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne 1f

    echo path lpath
    or $PATH, %r12
    jmp print_buf

query_pr:
    mov  $PORT, %r15 
    and  %r12,   %r15
    cmp  $0,    %r15 # перепрыгнули на конец query, на напечатав порт
    jne  cont_query
    or $QUERY, %r12
    jmp   port_pr
 
cont_query:
    mov  $QUERY_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne 1f

    echo query lquery
    or $QUERY, %r12
    jmp print_buf

anchor_pr:
    mov  $QUERY_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne cont_anch
    or  $ANCHOR, %r12
    or  $EMPTY_ANCHOR, %r12
    inc %r9
    jmp query_pr

cont_anch:
    mov  $ANCHOR_MASK, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne 1f
    echo anchor lanchor
    or $ANCHOR, %r12
    jmp print_buf
    
print_buf:
    mov $lexample, %rdx
    sub  %r10, %rdx
    sub  %r9, %rdx
    mov  $END_MASK, %r15
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

1:
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
    s0: cell 0, "a", 1
    s1: cell 1, "a", 1
        cell 1, ":", 2
        cell 1, ".", 6
    s2: cell 2, "/", 3
    s3: cell 3, "/", 4
    s4: cell 4, "a", 5
    s5: cell 5, "a", 5
        cell 5, ".", 6
    s6: cell 6, "a", 7
    s7: cell 7, "a", 7
        cell 7, ":", 8
        cell 7, ".", 6
        cell 7, "/", 10
        cell 7, "?", 12
        cell 7, "#", 15
    s8: cell 8, "0", 9
    s9: cell 9, "0", 9
        cell 9, "/", 10
        cell 9, "?", 12
        cell 9, "#", 15
    s10: cell 10, "a", 11
    s11: cell 11, "a", 11
         cell 11, "/", 10
         cell 11, "?", 12
         cell 11, "#", 15
    s12: cell 12, "a", 13
    s13: cell 13, "&", 12
         cell 13, "a", 13
         cell 13, "=", 14
    s14: cell 14, "a", 14
         cell 14, "&", 12
         cell 14, "#", 15
    s15: cell 15, "a", 15
         cell 15, "#", 99
         cell 15, "&", 99
    s99: cell 99, "a", 99
    ls = . - ss
    after: .word 0, 0, 0, 0

    example: .ascii "a.aa:000/aa/a"
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
    