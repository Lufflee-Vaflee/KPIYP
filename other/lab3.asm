name prog
.model small
.stack 100h
.data

    ENDLstr                 db 0Ah, 0Dh, '$';
    enter_matrix_msg        db "  Enter matrix elements:$";
    enter_element_msg_1     db "  [$";
    enter_element_msg_2     db "  ]$";
    enter_element_msg_3     db "  ]: $";

    matrix_output_msg       db "  : $";

    matrix_original_msg     db "  Original matrix:$";
    matrix_result_msg       db "  Result matrix:$";

    incorrect_num_msg       db "   Incorrect_num format, it will be setted to zero$"

    matrix                  dw 30 DUP(0);
    matrix_string_num       dw 3;
    matrix_column_num       dw 3;

    matrix_min_num          dw 32767;
    matrix_min_num_pos      dw 0;
    matrix_max_num          dw -32768;
    matrix_max_num_pos      dw 0;


    NumBuf16        db  8; 
    NumSize16       db  ?;                                                     
    NumSign16       db  ?;
    NumMod16        db  8   DUP ('$');

.code

    output_str  macro   outputAdress;

        push    AX;
        push    DX;

        mov     AH,     09h;
        lea     DX,     [outputAdress + 2];
        int     21h;

        pop     DX;
        pop     AX;

    endm

    enter_str   macro   enterAdress;

        push    AX;
        push    DX;

        mov     AH,     0Ah;
        lea     DX,     enterAdress;
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

    output_str enter_matrix_msg;
    endl;

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
            call Unsigned16Num_output;
            output_str enter_element_msg_2;
            output_str enter_element_msg_1;
            mov ax, dx;
            call Unsigned16Num_output;
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

    output_str matrix_original_msg;
    endl;
    call matrix_output;

    mov cx, [matrix_string_num]
    mov si, offset matrix;
    xor bx, bx;
    xor dx, dx;
    find_max_min_matrix:

        push cx;
        xor dx, dx;
        mov cx, [matrix_column_num]
        find_max_min_matrix_string:

            cmp dx, bx;
            ja  check_for_max;
            cmp dx, bx;
            jb  check_for_min;
            jmp continue_f;

            check_for_max:
            mov ax, [si];
            cmp ax, [matrix_max_num]
            jng continue_f;
            mov [matrix_max_num], ax;
            mov [matrix_max_num_pos], si;
            jmp continue_f;

            check_for_min:
            mov ax, [si];
            cmp ax, [matrix_min_num]
            jnl continue_f;
            mov [matrix_min_num], ax;
            mov [matrix_min_num_pos], si;
            jmp continue_f;

            continue_f:
            add si, 2;
            inc dx;
        loop find_max_min_matrix_string
        pop cx;

        inc bx;
    loop find_max_min_matrix;


    mov si, [matrix_max_num_pos];
    mov di, [matrix_min_num_pos];
    mov ax, [si];
    mov bx, [di];
    mov [si], bx;
    mov [di], ax;


    output_str matrix_result_msg;
    endl;
    call matrix_output;

    exit:

        mov ax,4C00h ; exit
        int 21h

main endp


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

    Unsigned16Num_output    proc;       ax - num

        PUSH BX;
        PUSH CX;
        PUSH DX;
        push ax;

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

        pop ax;
        pop DX;
        pop CX;
        pop BX;
        ret;

    Unsigned16Num_output    endp

    Setw                      proc;         ax - num, dx - length of field for num; output ' ' symbols  dx - length(ax) times

        push BX;
        push AX;
        push DX;
        push CX;

        cmp ax, 0;
        jg  next;
        neg ax;
        next:
        xor bx, bx;
        mov cx, 10;
        push dx;
        xor dx, dx;
        cycle_count_length:

            xor dx, dx;
            div cx;

            inc bx;
            cmp ax, 0;
        jne cycle_count_length
        pop dx;

        sub dx, bx;
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

    matrix_output           proc;

    push cx;
    push si;
    push ax;
    push dx;

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
            mov dx, 5;
            call setw;

            add si, 2;
        loop cycle_output_matrix_string
        pop cx;
        endl;

        inc bx;
    loop cycle_output_matrix;

    mov dx, 8;
    xor ax, ax;
    call setw;
    mov cx, matrix_column_num;
    cycle_ouput_head:

        call Unsigned16Num_output;
        push ax;
        mov dx, 6;
        call setw;
        pop ax;

        inc ax;
    loop cycle_ouput_head;

    endl;
    endl;

    pop dx;
    pop ax;
    pop si;
    pop cx;

    ret;

    matrix_output           endp;

end start