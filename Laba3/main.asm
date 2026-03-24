; Лаба 3 
.686
.model flat, stdcall
option casemap: none

ExitProcess PROTO STDCALL :DWORD

.data
inputString     db "-123.456", 0
resultMsg       db 13, 10, "Result: Valid number", 13, 10, 0
hasDigit        db 0
hasPoint        db 0
sign            db 0
result          dq ?

.code

;---------------------------------------------------------------------------
; Главная процедура
;---------------------------------------------------------------------------
Start:
    lea esi, inputString
    
    ; проверка знака
    mov al, [esi]
    cmp al, '+'
    je skip_sign
    cmp al, '-'
    jne check_char
skip_sign:
    inc esi
    
    ; проверка первого символа после знака
check_char:
    mov al, [esi]
    cmp al, '.'
    je check_point
    
    ; основной цикл проверки символов
check_loop:
    mov al, [esi]
    cmp al, 0
    je end_check
    
    cmp al, '.'
    je handle_point
    
    cmp al, '0'
    jb invalid
    cmp al, '9'
    ja invalid
    
    mov byte ptr [hasDigit], 1
    jmp next_char
    
handle_point:
    cmp byte ptr [hasPoint], 1
    je invalid
    mov byte ptr [hasPoint], 1
    jmp next_char
    
next_char:
    inc esi
    jmp check_loop
    
end_check:
    cmp byte ptr [hasPoint], 1
    jne invalid
    cmp byte ptr [hasDigit], 1
    jne invalid
    jmp valid
    
invalid:
    mov edx, offset resultMsg + 2    ; пропускаем CRLF, выводим "Invalid number"
    call print_string
    jmp exit
    
valid:
    ; демонстрация работы FPU - преобразование строки в число
    finit
    lea eax, inputString
    call string_to_float
    
    mov edx, offset resultMsg
    call print_string
    
exit:
    push 0
    call ExitProcess


;---------------------------------------------------------------------------
; Преобразование строки в число с плавающей точкой (FPU)
; Вход: EAX = адрес строки
;---------------------------------------------------------------------------
string_to_float proc
    push esi
    mov esi, eax
    
    fldz                    ; st(0) = 0 (результат)
    mov al, [esi]
    cmp al, '-'
    jne parse_start
    mov byte ptr [sign], 1  ; запоминаем знак
    inc esi
    
parse_start:
    ; парсинг целой части
    xor ecx, ecx            ; целая часть = 0
    
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
    imul ecx, 10
    add ecx, eax
    inc esi
    jmp parse_int
    
done_int:
    push ecx
    fild dword ptr [esp]    ; загружаем целую часть
    add esp, 4
    jmp parse_frac_end
    
parse_frac:
    inc esi
    fldz                    ; st(0) = 0 (дробная часть), st(1) = целая часть
    mov ecx, 10             ; делитель
    
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
    fild dword ptr [esp]    ; делим цифру на делитель
    add esp, 4
    fdivp st(1), st(0)
    faddp st(2), st(0)      ; добавляем к дробной части
    
    imul ecx, 10            ; увеличиваем делитель
    inc esi
    jmp parse_frac_digits
    
done_frac:
    faddp st(1), st(0)      ; складываем целую и дробную части
    
parse_frac_end:
    cmp byte ptr [sign], 1
    jne positive
    fchs
    
positive:
    fstp qword ptr [result]
    
    pop esi
    ret
string_to_float endp


;---------------------------------------------------------------------------
; Вывод строки через прерывание DOS
; Вход: EDX = адрес строки
;---------------------------------------------------------------------------
print_string proc
    push eax
    push edx
    
print_loop:
    mov al, [edx]
    cmp al, 0
    je print_done
    mov ah, 2
    int 21h
    inc edx
    jmp print_loop
    
print_done:
    pop edx
    pop eax
    ret
print_string endp

end Start
