name prog
.model small
.stack 100h
.data

    ENDLstr         db  0Ah, 0Dh, '$';
    enter_str_msg   db  "  Enter string:$"

    num             dw  ?;
    sign_flag       db  ?;  0 - unsigned, not zero - signed;


    string_buf      db 255;
    string_size     db ?
    string          db 256 dup('$')

.code

     enter_str   macro   enterAdress;

        push    AX;
        push    DX;

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



main proc far

    start:


        mov ax,@data;           register adressation
        mov ds,ax
        mov es, ax;

        mov al, 'S';
        call output_symbol;
        call output_symbol;
        call output_symbol;
        call output_symbol;
        call output_symbol;
        endl;

        mov ax, 9438;
        mov [sign_flag], 1;
        mov [num], ax;
        call num16_output;
        endl;


        output_str enter_str_msg;
        endl;
        enter_str string_buf;
        endl;

        mov ax, offset string;
        push ax;
        xor ax, ax;
        mov al, [string_size];
        push ax;
        xor ax, ax;
        mov al, '$';
        push ax;
        call string_output;
        endl;

ex:

        mov ax,4C00h ; exit
        int 21h

main endp

output_symbol   proc;           al - symbol

    push ax;
    push dx;

        mov dl, al;
        mov ah, 06h;
        int 21h;
    
    pop dx;
    pop ax;
    ret;

output_symbol   endp;

num16_output            proc;

    push ax;
    mov ax, 0;
    cmp al, [sign_flag];
    mov ax, [num];
    jz uns_mark;

    call Signed16Num_output;
    jmp  exit_16num_output;

    uns_mark:
    call Unsigned16Num_output;

    exit_16num_output:
    pop ax;
    ret;

num16_output            endp;

Unsigned16Num_output    proc ;

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

Signed16Num_output      proc 

    push ax;
    push dx;

    shl ax, 1;
    jae not_negative;

    push ax;
    mov dl, '-';
    mov al, dl;
    mov ah, 06h;
    int 21h;
    pop ax;
    not ax;
    inc ax;

    not_negative:
    shr ax, 1;
    call Unsigned16Num_output;

    pop ax;
    pop dx;
    ret;

Signed16Num_output      endp 

string_output           proc;       [SP + 6] - adress of buffer to output, [SP + 4] - size of buffer, [SP + 4] - terminate symbol

    push bp;                        [BP + 8]                               [BP + 6]                   [BP + 4]
    mov bp, sp;
    push ax;
    push bx;
    push cx;
    push dx;
    push si;

    mov si, [BP + 8];
    mov cx, [BP + 6];
    mov ax, [BP + 4];

    xor bx, bx;
    strO_cycle:

        mov dl, [si];
        cmp dl, al;
        je strO_ex;
        push ax;
        mov al, dl;
        mov ah, 06h;
        int 21h;
        pop ax;

        inc si;
        inc bx;

    cmp bx, cx;
    jne strO_cycle;

    strO_ex:
    pop si;
    pop dx;
    pop cx;
    pop bx;
    pop ax;
    pop bp;
    ret 4;

string_output           endp;

    end start