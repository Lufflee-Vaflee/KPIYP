name prog
.model small
.stack 100h
.data

    ENDLstr                 db 0Ah, 0Dh, '$';
    enter_str_msg           db "  Enter string:$";
    enter_size_msg          db "  Enter size of array(up to 30):$";
    enter_num_msg_1         db "  Enter element [$";
    enter_num_msg_2         db "  ]:$";
    histogramm_msg          db "  Result histogramm:$";
    last_line_start_msg     db "  "

    num_array               db 30 DUP(0);
    num_array_size          db 0;

    NumBuf16                db  8; 
    NumSize16               db  ?;
    NumMod16                db  8   DUP ('$');

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
        call Unsigned16Num_output;
        output_str  enter_num_msg_2;
        endl;
        call Unsigned16Input;
        endl;
        mov [si], al;

        inc si;
        inc dx;
    loop enter_array_cycle;


    xor cx, cx;
    mov cl, [num_array_size];
    mov si, offset num_array;
    xor ax, ax;
    find_max_cycle:

        cmp al, [si];
        ja find_max_cycle_continue;
        mov al, [si];
        mov di, si;


        find_max_cycle_continue:
        inc si;
    loop find_max_cycle;


    output_str histogramm_msg;
    endl;

    mov cx, ax;
    histogramm_output_cycle:

        mov ax, cx;
        push ax;
        call Unsigned16Num_output;
        pop ax;
        mov dx, 3;
        call setw;
        mov si, offset num_array;
        push cx;
        mov cl, num_array_size;
        histogramm_output_string_cycle:

            cmp al, [si];
            ja histogramm_output_string_cycle_skip_element;
            push ax;
            mov ah, 02h;
            mov dl, '*';
            int 21h;
            int 21h;
            mov dl, ' ';
            int 21h;
            pop ax;
            jmp histogramm_output_string_cycle_continue;

            histogramm_output_string_cycle_skip_element:
            push ax;
            mov ah, 02h;
            mov dl, ' ';
            int 21h;
            int 21h;
            int 21h;
            pop ax;

            histogramm_output_string_cycle_continue:
            inc si;
        loop histogramm_output_string_cycle
        pop cx;
        endl;

        dec cx;
        cmp cx, -1
    jne histogramm_output_cycle;


    xor cx, cx;
    mov cl, [num_array_size];
    mov ax, 0;
    mov dx, 4;
    call setw;
    xor ax, ax;
    mov dx, 3;
    cycle_last_line_output:

        push ax;
        call Unsigned16Num_output;
        pop ax;
        call setw;

        inc ax;
    loop cycle_last_line_output;



exit:

        mov ax,4C00h ; exit
        int 21h

main endp


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
         
        enter_str       NumBuf16;
        mov     CL,     NumSize16;
        
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
        jmp end_16SI;

               
        undefined_16SI:
        xor     AX,     AX;
        jmp     end_16SI;

        end_16SI:
        pop     DX;
        pop     SI;
        pop     DI;
        pop     CX;
        pop     BX;
        ret;

Unsigned16Input           endp;

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