.globl _start
.include  "macro.s"

EMPTY_ANCHOR = 128
END = 64
PROTOCOL = 32
HOST = 16
PORT = 8
PATH = 4
QUERY = 2
ANCHOR = 1

STACK_OFFSET = 16

.text
_start:
    read $in_buffer, $lin_buffer # в rax - количество прочитанных символов, включая \n  
    dec  %rax

    mov %rsp, %rbp
    sub $STACK_OFFSET, %rsp
    mov %rax, -8(%rbp)  # длина прочитанного урла 
    movq $out_buffer, -16(%rbp) # указатель на следующий символ out буфера

    echo newl
    xor %r9, %r9
    xor %r12, %r12 # EMPTY-ANCH_END_PROT_HOST_PORT_PATH_QUERY_ANCHOR  - флаги, чтобы отслеживать, что уже прочитали
                   #     128    64  32    16   8    4    2      1

    mov $0, %dl         # state
    mov $in_buffer, %r8   # str
    mov -8(%rbp), %r10  # length
   
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

    append_to_buf  $protocol, $lprotocol, -16(%rbp)

    or $PROTOCOL, %r12
    add  $2, %r9
    jmp print_buf

host_pr:
    jmp_if_bit_set HOST, save_ch_to_buf

    append_to_buf  $host, $lhost, -16(%rbp)

    or $HOST, %r12
    jmp print_buf

port_pr:
    jmp_if_bit_set HOST, cont_port

    or $PORT, %r12 # перепрыгнули на конец порта, на напечатав хост == порта не было
    jmp   host_pr
 
cont_port:
    jmp_if_bit_set PORT, save_ch_to_buf  # сюда возвращаемся, парся query

    append_to_buf  $port, $lport, -16(%rbp)

    or $PORT, %r12
    jmp print_buf

path_pr:
    jmp_if_bit_set PORT, cont_path

    or $PATH, %r12  # перепрыгнули на конец пути, на напечатав порт == пути не было
    jmp  port_pr

cont_path:
    jmp_if_bit_set PATH, save_ch_to_buf

    append_to_buf  $path, $lpath, -16(%rbp)

    or $PATH, %r12
    jmp print_buf

query_pr:
    jmp_if_bit_set PORT, cont_query

    or $QUERY, %r12 # перепрыгнули на конец query, на напечатав порт == query не было
    jmp   port_pr
 
cont_query:
    jmp_if_bit_set QUERY, save_ch_to_buf

    append_to_buf  $query, $lquery, -16(%rbp)

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

    append_to_buf  $anchor, $lanchor, -16(%rbp)

    or $ANCHOR, %r12
    jmp print_buf
    
print_buf:
    mov  -8(%rbp), %rdx
    sub  %r10, %rdx
    sub  %r9, %rdx

    mov  $END, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    jne  cont_print

    dec  %rdx

cont_print:
    append_to_buf  $buffer, %rdx, -16(%rbp)
    append_to_buf  $newl, $1, -16(%rbp)
    cmp  $0,    %r15
    jne ex_it

clear_buf:    
    inc %rdx
    add %rdx, %r9 # столько символов мы стёрли в прошлые разы
    mov %rdx, %rcx
    mov $buffer, %rdi
    mov $32, %al
    repnz stosb

save_ch_to_buf:
    pop %rax
    mov -8(%rbp), %rdx
    sub  %r10, %rdx # cдвиг относительно начала строки
    sub  %r9, %rdx
    movb %al,   buffer(%rdx)

    mov $ls, %rcx
    mov $ss, %rdi
    repnz scasq # rdi -> offset-part

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
    echo invalid linvalid
    exit

ex_it:
    mov  $EMPTY_ANCHOR, %r15
    and  %r12,   %r15
    cmp  $0,    %r15
    je cont_ex
    append_to_buf  $anchor, $lemptyanchor, -16(%rbp)
    append_to_buf  $newl, $1, -16(%rbp)

cont_ex:
    echo out_buffer lout_buffer
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

    in_buffer: .skip 50
    lin_buffer = . - in_buffer

    result: .ascii "  \n"

    invalid: .ascii "INVALID_URL\n"
    linvalid = . - invalid

    buffer:	 .skip 20
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

    out_buffer: .skip 150
    lout_buffer = . - out_buffer
