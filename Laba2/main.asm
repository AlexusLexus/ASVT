.686
.model flat, stdcall
.stack 100h

.data
X dw 5429h
Y dw 7844h
Z dw 0AD43h
Q dw 5622h
L dw ?
M dw ?
R dw ?

.code
ExitProcess PROTO STDCALL :DWORD

; R = M/2 - 12B9h
Subprogram1 PROC
    mov ax, M
    mov dx, 0
    mov bx, 2
    div bx
    sub ax, 12B9h
    mov R, ax
    ret
Subprogram1 ENDP

; R = M - Q'/2
Subprogram2 PROC
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
Subprogram2 ENDP

Start:
    mov ecx, 4
    mov esi, offset X
    xor ax, ax

cycle:
    inc word ptr [esi]
    add ax, [esi]
    add esi, 2
    loop cycle

    ;  M = (L & X) - (L & Y)
    mov [L], ax
    mov ax, L
    and ax, X
    mov bx, ax
    mov ax, L
    and ax, Y
    sub bx, ax
    mov [M], bx
    ; if M < 921Bh
    cmp M, 921Bh
    jge call_subprg1
    call Subprogram2
    jmp continue

call_subprg1:
    ; (M >= 921Bh)
    call Subprogram1

continue:
    mov [R], ax
    ; Чётность R
    test ax, 1
    jnz addr2

addr1:
    mov ax, R
    or ax, 009Fh
    jmp finish

addr2:
    mov ax, R
    dec ax

finish:
    ;mov [R], ax
    invoke ExitProcess, ax

END Start