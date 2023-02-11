;много полезных процедур и макросов

name prog
.model small
.stack 100h
.data

    ENDLstr                 db  0Ah, 0Dh, '$';
    string_buf              db 200;
    string_size             db ?
    string                  db 201 dup('$')  ;строка для ввода и поиска слов содержащих символ

    del_symbol              db 0;           символ удаления

    found_symb_flag         db 0;           флаг найденного символа в слове

    enter_matrix_msg        db "  Enter matrix elements:$";
    enter_element_msg_1     db "  [$";
    enter_element_msg_2     db "  ]$";
    enter_element_msg_3     db "  ]: $";
    incorrect_num_msg       db "   Incorrect_num format, it will be setted to zero$"
    matrix_output_msg       db "  : $";

    matrix                  dw 30 DUP(0);
    matrix_string_num       dw 3;
    matrix_column_num       dw 3;

    NumBuf16                db  8; 
    NumSize16               db  ?;
    NumSign16               db  ?;
    NumMod16                db  8   DUP ('$');

    UNumBuf16                db  8; 
    UNumSize16               db  ?;
    UNumMod16                db  8   DUP ('$');
.code

     enter_str   macro   enterAdress; макросы поддерживают параметры - при использование макроса, параметр просто вставиться(буквально текстом) во все места его использования

        push    AX;     стандартный вариант использования стека
        push    DX;     ;сохраняем значения регистров использующихся в макросе, чтобы вызывающий код, мог расчитывать на выполнение операции без задевания других служебных данных

        mov     AH,     0Ah;
        lea     DX,     enterAdress;
        int     21h;

        pop     DX;
        pop     AX;

    endm

    output_str  macro   outputAdress;

        push    AX;
        push    DX;

        mov     AH,     09h;
        lea     DX,     [outputAdress + 2];
        int     21h;

        pop     DX;
        pop     AX;

    endm

    endl        macro

        push    AX;
        push    DX;

        mov     AH,     09h;
        lea     DX,     ENDLstr;
        int     21h; 

        pop     DX;
        pop     AX;

    endm


    exit        macro 

        mov     AX,     4c00h;
        int     21h;

    endm

    clearBuf    macro   strBuf

        push    CX;
        push    AX;
        push    DI;

        xor     CX,     CX;
        xor     AX,     AX;


        mov     CL,     strBuf;
        lea     DI,     strBuf + 1;
        mov     AL,     '$';

        rep    stosb;


        pop     DI;
        pop     AX;
        pop     CX;

    endm;

main proc

    start:

    mov ax, @data;           register adressation
    mov ds, ax;
    mov es, ax;

    exit;

main endp


DeleteSubString         proc;       di = pos, cx - len

    push ax;
    push cx;
    push di;
    push si;

    mov ax, di;
    add ax, offset string;
    mov di, ax;

    push cx;
    add cx, ax;
    mov si, cx;

    pop ax;
    xor cx, cx;
    mov cl, [string_size];
    sub cx, ax;
    mov [string_size], cl;

    cld;
    rep movsb;


    pop si;
    pop di;
    pop cx;
    pop ax;
    ret;

DeleteSubString         endp;

FindSymbInSubString     proc; di = pos, cx - len

    push ax;
    push cx;
    push di;
    push si;

    mov [found_symb_flag], 0;    обнуляем флаг

    mov ax, di;
    add ax, offset string;
    mov di, ax;                 вычисляем адрес обрабатываемой подстроки

    mov al, [del_symbol];       заносим в al символ который мы ищем

    cld;
    repne scasb;                сканируем строку

    cmp cx, 0                  ;если cx = 0 значит не нашли такого символа, либо символ стоит в самом конце слова
    je check_for_the_last;              ;если нашли - устанавливаем флаг
    mov [found_symb_flag], 1;
    jmp find_exit;

    check_for_the_last:        ;проверяем, возможно символ в конце
    dec di;
    cmp [di], al;
    jne find_exit;
    mov [found_symb_flag], 1;

    find_exit:
    pop si;
    pop di;
    pop cx;
    pop ax;
    ret;


FindSymbInSubString     endp;

InsertEmptySubString    proc;   si = pos, cx - len;

    push ax;
    push cx;
    push di;
    push si;
    push dx;

    push cx;
    push si;

    xor dx, dx;
    mov dl, [string_size];

    push cx;
    xor ax, ax;
    mov al, [string_size];
    add cx, ax;
    mov [string_size], cl;

    xor ax, ax;
    mov al, [string_size];
    mov di, offset string;
    add di, ax;

    pop cx;
    push si;
    mov si, di;
    sub si, cx;
    mov ax, si;

    pop si;
    mov cx, dx;
    inc cx;
    sub cx, si;
    mov si, ax;

    std;
    rep movsb;
    cld;

    pop si;
    pop cx;
    mov di, offset string;
    add di, si;
    mov al, ' ';
    rep stosb;

    pop dx;
    pop si;
    pop di;
    pop cx;
    pop ax;
    ret;

InsertEmptySubString    endp;

Signed16Input           proc;
    
    push    BX;
    push    CX;
    push    DI;
    push    SI;
    push    DX;
    
    xor     AX,     AX;
    xor     BX,     BX;
    xor     CX,     CX;
    xor     DI,     DI
    mov     SI,     10;
        
    enter_str       NumBuf16;
    mov     CL,     NumSize16;
    dec     CL;       
    
    CYCLE_16SI_1:
    
        mov     BL,     NumMod16 + DI;
        sub     BL,     '0';                  
        add     AL,     BL;
        rcl     AX,     1;
        jb      undefined_16SI;
        rcr     AX,     1;
        inc     DI;
        dec     CX;
        jcxz    exit_CYCLE_16SI_1;
        mul     SI;
        jo      undefined_16SI;
        inc     CX;
        
    loop    CYCLE_16SI_1;   
    exit_CYCLE_16SI_1:
    
    cmp     NumSign16,  '-';
    je      negative_16SI;
    
    cmp     NumSign16,  '+';
    jne     undefined_16SI;                        
    
    jmp     end_16SI;
            
    undefined_16SI:
    output_str incorrect_num_msg;
    xor     AX,     AX;
    jmp     end_16SI; 
    
    negative_16SI:
    neg     AX;
        
    end_16SI:
    clearBuf        NumBuf16;
    pop     DX;
    pop     SI;
    pop     DI;
    pop     CX;
    pop     BX;
    ret;

Signed16Input           endp;


Signed16Output          proc;

    push    AX;
    push    BX;
    push    CX;
    push    DX;
    push    DI;
    push    SI;
    
    cld;
    xor     BX,     BX;
    xor     DI,     DI;
    xor     DX,     DX;
    mov     SI,     10;
    mov     CX,     1;
    mov     byte ptr NumSign16,     '+';


    rcl     AX,     1;
    jnb     mark_16S0_1;
    
    rcr     AX,     1;
    mov     byte ptr NumSign16,     '-';
    not     AX;
    add     AX,     1;
    jmp     CYCLE_16SO_1;
    
    mark_16S0_1:
    rcr     AX,     1;
    CYCLE_16SO_1:
            
        div     SI;            
        add     DL,     '0';
        push    DX;
        inc     DI;
        xor     DX,     DX;
    
    mov     CX,     AX;
    inc     CX;
    loop    CYCLE_16SO_1; 
    
    mov     CX,     DI;
    inc     CX;
    mov     byte ptr NumSize16,     CL;
    
    dec     CX;
    lea     DI,     NumMod16;
    CYCLE_16SO_2:
        
        pop     AX;
        stosb;
    
    loop    CYCLE_16SO_2;
    

    output_str NumBuf16;
    clearBuf   NumBuf16;
    pop     SI;
    pop     DI;
    pop     DX;
    pop     CX;
    pop     BX;
    pop     AX;
    
    ret;

Signed16Output          endp;

Unsigned16Input           proc;
    
    push    BX;
    push    CX;
    push    DI;
    push    SI;
    push    DX;
    
    xor     AX,     AX;
    xor     BX,     BX;
    xor     CX,     CX;
    xor     DI,     DI
    mov     SI,     10;
        
    enter_str       UNumBuf16;
    mov     CL,     UNumSize16;
    
    CYCLE_16UI_1:
    
        mov     BL,     UNumMod16 + DI;
        sub     BL,     '0';                  
        add     AL,     BL;
        rcl     AX,     1;
        jb      undefined_16UI;
        rcr     AX,     1;
        inc     DI;
        dec     CX;
        jcxz    exit_CYCLE_16UI_1;
        mul     SI;
        jo      undefined_16UI;
        inc     CX;
        
    loop    CYCLE_16UI_1;   
    exit_CYCLE_16UI_1:
    jmp end_16UI;

            
    undefined_16UI:
    xor     AX,     AX;
    jmp     end_16UI;

    end_16UI:
    pop     DX;
    pop     SI;
    pop     DI;
    pop     CX;
    pop     BX;
    ret;

Unsigned16Input           endp;

Unsigned16Output    proc;       ax - num

    PUSH BX;
    PUSH CX;
    PUSH DX;
    push AX;

    mov BX, 10;
    mov cx, 0;
    cycle1:

        xor dx, dx;
        div bx;
        push dx;
        inc cx;

    cmp ax, 0;
    jnz cycle1

    cycle2:

        pop dx;
        add dl, '0';
        mov al, dl;
        mov ah, 06h;
        int 21h;

    loop cycle2

    pop AX;
    pop DX;
    pop CX;
    pop BX;
    ret;

Unsigned16Output    endp

Setw                      proc;         ax - size of string num representation, dx - length of field for num; output ' ' symbols  dx - ax times

    push BX;
    push AX;
    push DX;
    push CX;

    sub dx, ax;
    mov cx, dx;
    mov ah, 02h;
    mov dl, ' ';
    cycle_output_space_symbols:

        int 21h;

    loop cycle_output_space_symbols;

    pop CX;
    pop DX;
    pop AX;
    pop BX;
    ret;

Setw                      endp;

matrix_input            proc;

    push cx;
    push ax;
    push bx;
    push si;

    mov cx, [matrix_string_num];
    mov si, offset matrix;
    xor bx, bx;
    cycle_enter_matrix:

        xor dx, dx;
        push cx;
        mov cx, [matrix_column_num];
        cycle_enter_matrix_string:

            output_str enter_element_msg_1;
            mov ax, bx;
            call Unsigned16Output;
            output_str enter_element_msg_2;
            output_str enter_element_msg_1;
            mov ax, dx;
            call Unsigned16Output;
            output_str enter_element_msg_3;
            call Signed16Input;
            endl;

            mov [si], ax;

            add si, 2;
            inc dx;
        loop cycle_enter_matrix_string;
        pop cx;

        inc bx;
    loop cycle_enter_matrix;

    pop si;
    pop bx;
    pop ax;
    pop cx;

    ret;

matrix_input            endp;

matrix_output           proc;

    push cx;
    push si;
    push ax;
    push dx;

    mov dx, 8;
    xor ax, ax;
    call setw;
    mov cx, matrix_column_num;
    cycle_ouput_head:

        call Unsigned16Num_output;
        push ax;
        mov dx, 9;
        call setw;
        pop ax;

        inc ax;
    loop cycle_ouput_head;

    endl;

    mov cx, [matrix_string_num]
    mov si, offset matrix;
    xor bx, bx;
    cycle_output_matrix:

        mov ax, bx;
        call Unsigned16Num_output;
        output_str matrix_output_msg;
        mov dx, 5;
        call setw;

        push cx;
        mov cx, matrix_column_num;
        cycle_output_matrix_string:

            mov ax, [si];
            call Signed16Output;
            mov dx, 8;
            call setw;

            add si, 2;
        loop cycle_output_matrix_string
        pop cx;
        endl;

        inc bx;
    loop cycle_output_matrix;

    pop dx;
    pop ax;
    pop si;
    pop cx;

    ret;

matrix_output           endp;

    end start