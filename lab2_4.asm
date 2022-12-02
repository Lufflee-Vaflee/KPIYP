name prog
.model small
.stack 100h
.data

    ENDLstr                 db  0Ah, 0Dh, '$';
    enter_str_msg           db  "  Enter string:$"

    pos_len_pair_array      dw  200 DUP(0);
    array_size              db  0;

    string_buf              db 200;
    string_size             db ?
    string                  db 201 dup('$')

    sorted_string_buf       db 255;
    sorted_string_size      db ?
    sorted_string           db 256 dup('$')

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

    output_str enter_str_msg;
    endl;
    enter_str string_buf;
    endl;



    mov si, offset string_size;
    mov cl, [si];
    mov si, offset string;
    push si;
    add si, cx;
    mov [si + 1], '$';
    pop si;
    mov di, offset pos_len_pair_array;
    xor bx, bx;
    cycle:

        mov al, [si];
        cmp al, ' ';
        je not_symbol;

        cmp bx, 0;
        jne add_length;           second or more not ' ' symbol - add length
        ;found start of word block;
        mov bx, si;
        sub bx, offset string;
        mov [di], bl;           set word adress
        inc di;                 set di to length
        mov [di], 1;            set length to one
        mov bx, 1;              in word now
        jmp continue;           leave block, continue iterration

        not_symbol:
        cmp bx, 1;
        jne continue;           second or more ' ' symbol - skip
        ;found end of word block
        inc di;                 leave pos_length pair
        xor bx, bx;              set not in word flag
        jmp continue;           skiping add length block

        add_length:    
        xor bx, bx;
        mov bl, [di];           increasing length if another one symbol was found
        inc bl;
        mov [di], bl;
        mov bx, 1;

        continue:
        mov al, [si];           iterrate throw string
        inc si;
        cmp al, ''
    loop cycle
    inc di;


    mov si, offset array_size;
    sub di, offset pos_len_pair_array;
    shr di, 1;
    mov [si], di;

    mov cx, di;
    xor ax, ax;
    mov si, offset pos_len_pair_array;
    check_cycle:

        mov al, [si];
        call Unsigned16Num_output;
        endl;
        xor ax, ax;
        mov al, [si + 1];
        call Unsigned16Num_output;
        xor ax, ax;
        endl;

        inc si;
        inc si;
    loop check_cycle;


    mov si, offset array_size;
    xor cx, cx;
    mov cl, [si];
    mov si, offset string;
    mov di, offset pos_len_pair_array;
    xor bx, bx;
    sort_cycle:


        push cx;
        dec cx;
        jz out_of_cycle;
        mov si, di;
        add si, 2;
        find_min_cycle:

            mov bl, [di + 1];                   get length of first word
            mov al, [si + 1];
            cmp bl, al;
            jb continue_fm_cycle;
            mov [di + 1], al;
            mov [si + 1], bl;
            mov bl, [di];
            mov al, [si];
            mov [di], al;
            mov [si], bl;

            continue_fm_cycle:
            add si, 2;
        loop find_min_cycle;
        out_of_cycle:
        pop cx;


        add di, 2
    loop sort_cycle;


    endl;
    mov di, offset array_size;
    mov cx, [di];
    xor ax, ax;
    mov si, offset pos_len_pair_array;
    check_cycle_2:

        mov al, [si];
        call Unsigned16Num_output;
        endl;
        xor ax, ax;
        mov al, [si + 1];
        call Unsigned16Num_output;
        xor ax, ax;
        endl;

        inc si;
        inc si;
    loop check_cycle_2;


    mov si, offset array_size;
    xor cx, cx;
    mov cl, [si];
    mov si, offset pos_len_pair_array
    output_str string_buf;
    endl;
    mov di, offset string;
    xor bx, bx;
    xor ax, ax;
    cycle_output:

        push di;
        mov al, [si];
        add di, ax;
        push di;
        mov al, [si + 1];
        add di, ax;
        mov al, [di];
        mov [di], '$';
        pop di;

        mov ah, 09h;
        mov dx, di;
        int 21h;

        xor ah, ah;
        mov bl, [si + 1];
        add di, bx;
        mov [di], ' ';
        pop di;
        mov ah, 02h;
        mov dl, ' ';
        int 21h;
        xor ax, ax;

        inc si;
        inc si;
    loop cycle_output;

    endl;
    output_str string_buf;
    endl;

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

    end start