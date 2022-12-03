name prog
.model small
.stack 100h
.data

    ENDLstr                 db 0Ah, 0Dh, '$';
    enter_matrix_msg        db "  Enter matrix elements:$";
    enter_element_msg_1     db "  [$";
    enter_element_msg_2     db "  ]$";
    enter_element_msg_3     db "  ]: $";
    incorrect_num_msg       db "   Incorrect_num format, it will be setted to zero$"
    overflow_msg            db "  Error, to big multiplication result in string $";
    max_string_msg          db "  Max string index:$";

    matrix                  dw 30 DUP(0);
    matrix_string_num       dw 3;
    matrix_column_num       dw 3;

    max_string_index        dw 0;

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

;    mov cx, [matrix_string_num];
;    mov si, offset matrix;
;    xor bx, bx;
;    cycle_output_matrix:

;        xor dx, dx;
;        push cx;
;        mov cx, [matrix_column_num];
;        cycle_output_matrix_string:

;            output_str enter_element_msg_1;
;            mov ax, bx;
;            call Unsigned16Num_output;
;            output_str enter_element_msg_2;
;            output_str enter_element_msg_1;
;            mov ax, dx;
;            call Unsigned16Num_output;
;            output_str enter_element_msg_3;
;            mov ax, [si];
;            call Signed16Output;
;            endl;

;            add si, 2;
;            inc dx;
;        loop cycle_output_matrix_string;
;        pop cx;

;        inc bx;
;    loop cycle_output_matrix;

    mov cx, [matrix_string_num];
    mov si, offset matrix;
    mov bx, 8000h;
    xor di, di;
    cycle_find_max:

        push cx;
        mov ax, 1;
        mov cx, [matrix_column_num];
        cycle_find_max_string:

            mov dx, [si];
            imul dx;
            not dx;

            add si, 2;
        loop cycle_find_max_string;
        pop cx;

        cmp ax, bx;
        jl continue_cycle_find_max;
        mov bx, ax;
        mov [max_string_index], di;

        continue_cycle_find_max:
        inc di;
    loop cycle_find_max;

    output_str max_string_msg;
    mov ax, [max_string_index];
    call Unsigned16Num_output;
    endl;

    jmp exit;

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

    end start