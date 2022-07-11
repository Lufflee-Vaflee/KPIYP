name prog
.model small
.stack 100h
.data

    mask_size       db 14
    input_mask      db "0123456789+-*/"

    alphabet db "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ"
                ;01234567890123456789012345

    input_buf       db 254, ?, 254 dup('$')

    ENDLstr         db  0Ah, 0Dh, '$';
    Input_msg       db  "  Enter string:$"
    result_msg      db  "  Result:$"

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

        output_str Input_msg;
        endl;

        part_1:

            mov ah,08h ; no echo
            int 21h
            cmp al, 1Bh
            je to_part_2 ; sym = ESC

            xor ch, ch;
            mov cl, [mask_size];
            mask_cycle:

                mov si, cx;
                cmp al, [input_mask + si]
                je output_symbol;

            loop mask_cycle
            jmp part_1;

            output_symbol:
            mov dl, al;
            mov ah, 02h;
            int 21h;

        jmp part_1;

        to_part_2:
        endl;
        clearBuf input_buf;
        output_str Input_msg;
        endl;

        part_2:

            mov ah,08h ; no echo
            int 21h
            cmp al, 1Bh
            je ex; sym = ESC

            cmp al, 'A'
            jb output_symbol_2
            cmp al, 'Z'
            ja output_symbol_2
            add al, 20h;

            output_symbol_2:
            mov dl, al;
            mov ah, 02h;
            int 21h;

        jmp part_2;


ex:

        mov ax,4C00h ; exit
        int 21h

main endp

    end start