.686
.model flat, C

.CODE
extern f : near

public findMin
findMin proc
    push ebp
    mov ebp, esp
    
    sub esp, 12

    fld dword ptr [ebp + 12]
    fsub dword ptr [ebp + 8]
    fild dword ptr [ebp + 16]
    fdivp st(1), st(0)
    fstp dword ptr [ebp - 12]

    fld dword ptr [ebp + 8]
    fstp dword ptr [ebp - 4]

    mov dword ptr [ebp - 8], 7F7FFFFFh

    mov ecx, dword ptr [ebp + 16]
    inc ecx

loop_start:
    push ecx
    
    push dword ptr [ebp - 4]
    call f
    add esp, 4

    fld dword ptr [ebp - 8]
    fcomi st(0), st(1)
    ja update_min
    fstp st(0)
    jmp next_step

update_min:
    fstp st(0)
    fld st(0)
    fstp dword ptr [ebp - 8]

    mov eax, dword ptr [ebp + 20]
    mov edx, dword ptr [ebp - 4]
    mov dword ptr [eax], edx

next_step:
    fstp st(0)
    
    fld dword ptr [ebp - 4]
    fadd dword ptr [ebp - 12]
    fstp dword ptr [ebp - 4]

    pop ecx
    loop loop_start

    fld dword ptr [ebp - 8]
    
    mov esp, ebp
    pop ebp
    ret
findMin endp

end