.686
.model flat, stdcall
.stack 100h

.data
X dw 5429h
Y dw 7844h
Z dw 0AD43h
Q dw 5622h
L dw 0
M dw ?
R dw ?

.code
ExitProcess PROTO STDCALL :DWORD

Start:
    mov ecx, 4
    mov esi, offset X
    xor eax, eax

body:
    inc word ptr [esi]
    add ax, [esi]
    add esi, 2
    loop body

    mov L, ax

    mov ax, L
    and ax, X
    mov bx, ax
    mov ax, L
    and ax, Y
    sub bx, ax
    mov M, bx

    mov ax, M
    cmp ax, 921Bh
    jge pod1
    call pod2
    jmp after_party

pod1 proc
    mov ax, M
    mov dx, 0
    mov bx, 2
    div bx
    sub ax, 12B9h
    mov R, ax
    ret
pod1 endp

pod2 proc
    mov ax, Q
    inc ax
    mov dx, 0
    mov bx, 2
    div bx
    mov bx, ax
    mov ax, M
    sub ax, bx
    mov R, ax
    ret
pod2 endp

after_party:
    test R, 1
    jz addr1
    call addr2
    jmp exit

addr1:
    or R, 009Fh
    ret

addr2:
    dec R
    ret

exit:
    invoke ExitProcess, R

END Start