name prog
.model small
.stack 100h
.data

    ENDLstr                 db  0Ah, 0Dh, '$';
    enter_size_msg          db "  Enter size of array(up to 30):$";
    enter_num_msg_1         db "  Enter element [$";
    enter_num_msg_2         db "  ]:$";
    incorrect_num_msg       db "   Incorrect_num format, it will be setted to zero$"
    result_msg              db "  Result sum is:$";
    error_msg               db "  Error Incorrect array size$";
    low_interval_msg        db "  Enter low interval$";
    hight_interval_msg      db "  Enter hight interval$";


    num_array               dw 30 DUP(0);
    num_array_size          db 0;
    array_low_interval      dw 0;
    array_hight_interval    dw 0;

    NumBuf16                db  8; 
    NumSize16               db  ?;
    NumSign16               db  ?;
    NumMod16                db  8   DUP ('$');

    UNumBuf16                db  8; 
    UNumSize16               db  ?;
    UNumMod16                db  8   DUP ('$');

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


    output_str enter_size_msg;
    endl;
    call Unsigned16Input;
    endl;
    mov [num_array_size], al;


    mov cx, ax;
    mov si, offset num_array;
    xor dx, dx;
    enter_array_cycle:

        output_str enter_num_msg_1;
        mov ax, dx;
        call Signed16Output;
        output_str  enter_num_msg_2;
        endl;
        call Signed16Input;
        endl;
        mov [si], ax;

        inc si;
        inc si;
        inc dx;
    loop enter_array_cycle;

    output_str low_interval_msg;
    endl;
    call Signed16Input;
    mov [array_low_interval], ax;
    output_str hight_interval_msg;
    endl;
    call Signed16Input;
    mov [array_hight_interval], ax;


    xor cx, cx;
    mov cl, [num_array_size];
    mov si, offset num_array;
    xor ax, ax;
    xor bx, bx;
    array_calc_num_cycle:

        mov ax, [si];
        cmp ax, [array_low_interval];
        jng array_calc_num_cycle_continue;
        cmp ax, [array_hight_interval];
        jnl array_calc_num_cycle_continue;
        inc bx;

        array_calc_num_cycle_continue:
        inc si;
        inc si;
    loop array_calc_num_cycle

    output_str result_msg;
    endl;

    mov ax, bx;
    call Signed16Output
    endl;


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

    end start