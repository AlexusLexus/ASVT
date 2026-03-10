.686
.model flat, stdcall
.stack 100h

.data
X dw 15
Y dw 79
Z dw 81
S1 dw ?

.code
ExitProcess PROTO STDCALL :DWORD

; M = ((X + Y) / 4) or (Z - Y - X)
Start:
    mov ax, X
    add ax, Y
    
    ;shr ax, 2
    xor dx, dx
    mov bx, 4
    div bx
    mov S1, ax
    
    mov ax, Z
    sub ax, Y
    sub ax, X
    
    or ax, S1

exit:
    Invoke ExitProcess, ax

END Start