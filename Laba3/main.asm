; Лаба 3, вариант 7
.686
.model flat, stdcall
option casemap: none

ExitProcess PROTO STDCALL :DWORD

.data
inputString     db "-123.456", 0
hasDigit        db 0
hasPoint        db 0
sign            db 0
result          dq ?

.code

Start:
    lea esi, inputString
    xor ecx, ecx
    mov hasDigit, 0
    mov hasPoint, 0
    mov sign, 0

    mov ecx, 0
get_length:
    cmp byte ptr [esi + ecx], 0
    je init_loop
    inc ecx
    jmp get_length

init_loop:
    mov ecx, 0

check_loop:
    mov al, [esi + ecx]
    cmp al, 0
    je end_check

    cmp al, '+'
    je handle_sign
    cmp al, '-'
    je handle_sign

    cmp al, '.'
    je handle_point

    cmp al, '0'
    jb invalid
    cmp al, '9'
    ja invalid

    mov byte ptr [hasDigit], 1
    inc ecx
    loop check_loop

handle_sign:
    test ecx, ecx
    jnz invalid
    mov byte ptr [sign], 1
    inc ecx
    loop check_loop

handle_point:
    cmp byte ptr [hasPoint], 1
    je invalid
    mov byte ptr [hasPoint], 1
    inc ecx
    loop check_loop

end_check:
    cmp byte ptr [hasPoint], 1
    jne invalid
    cmp byte ptr [hasDigit], 1
    jne invalid

    finit
    lea eax, inputString
    call string_to_float

    push 0
    call ExitProcess

invalid:
    push 1
    call ExitProcess

;---------------------------------------------------------------------------
; Преобразование строки в число с плавающей точкой используя FPU
;---------------------------------------------------------------------------
string_to_float PROC
    push esi
    mov esi, eax

    fldz
    mov al, [esi]
    cmp al, '-'
    jne parse_start
    mov byte ptr [sign], 1
    inc esi

parse_start:
    xor edx, edx
    xor ebx, ebx

parse_int:
    mov al, [esi]
    cmp al, '.'
    je parse_frac
    cmp al, 0
    je done_int
    sub al, '0'
    cmp al, 9
    ja done_int

    movzx eax, al
    imul edx, 10
    add edx, eax
    inc esi
    jmp parse_int

done_int:
    push edx
    fild dword ptr [esp]
    add esp, 4
    jmp parse_frac_end

parse_frac:
    inc esi
    fldz
    mov ecx, 1

parse_frac_digits:
    mov al, [esi]
    cmp al, 0
    je done_frac
    sub al, '0'
    cmp al, 9
    ja done_frac

    movzx eax, al
    push eax
    fild dword ptr [esp]
    add esp, 4

    push ecx
    fild dword ptr [esp]
    add esp, 4
    fdivp st(1), st(0)
    faddp st(2), st(0)

    imul ecx, 10
    inc esi
    jmp parse_frac_digits

done_frac:
    faddp st(1), st(0)

parse_frac_end:
    cmp byte ptr [sign], 1
    jne positive
    fchs

positive:
    fstp qword ptr [result]

    pop esi
    ret
string_to_float ENDP

end Start