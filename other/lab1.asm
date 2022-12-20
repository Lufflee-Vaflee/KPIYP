name prog
.model small
.stack 100h
.data

    ENDLstr                 db  0Ah, 0Dh, '$';
    enter_str_msg           db  "  Enter string:$";
    enter_searching_word    db  "  Enter word to search:$";
    error_msg               db  "  INCORRECT string$";
    example                 db  "ABC";

    string_buf              db 200;
    string_size             db ?;
    string                  db 201 dup('$');
    string_size_cutted      db ?;

    search_buf              db 200;
    search_size             db ?;
    search                  db 201 dup('$')

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

    output_str  enter_str_msg;
    endl;
    enter_str   string_buf;
    endl;
    output_str  enter_searching_word;
    endl;
    enter_str search_buf;
    endl;

    call CutSub_string;

    xor cx, cx;
    xor dx, dx;
    xor ax, ax;
    mov cl, [string_size_cutted];
    mov al, ' ';
    mov di, offset string;
    cmp al, [string];
    jne CYCLE_DEL_symbol_START;
    jmp CYCLE_DEL_space_START;
    CYCLE_DEL_WORD_STRING:

        inc cl;
        CYCLE_DEL_symbol_START:
        ;di - начало слова
        repne scasb;
        dec di;
        inc cl;
        ;di - первый пробел после слова

        CYCLE_DEL_space_START:
        repe scasb;
        ;di - начало слова
        dec di;

    cmp cx, 0;
    jne CYCLE_DEL_WORD_STRING;


    output_str string_buf;
    endl;
    mov di, si;
    sub di, offset string;
    mov cx, dx;
    call DeleteSubString;
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

CutSub_string        proc;

    mov di, offset string;
    mov si, offset search;

    xor cx, cx;
    mov cl, [string_size];
    mov al, ' ';
    mov di, offset string;
    cmp al, [string];
    jne CYCLE_SEARCH_SYMBOL_START;
    jmp CYCLE_SEARCH_SPACE_START;
    CYCLE_SEARCH_SUB_STRING:

        CYCLE_SEARCH_SYMBOL_START:
        mov si, offset search;
        push cx;
        push di
        xor cx, cx;
        mov cl, [search_size];
        repe cmpsb;
        cmp cx, 0;
        je CYCLE_SEARCH_FOUND;
        pop di;
        pop cx
        repne scasb;
        dec di;
        inc cl;

        CYCLE_SEARCH_SPACE_START:
        repe scasb;
        dec di
        inc cl;

    loop CYCLE_SEARCH_SUB_STRING
    jmp exit_proc;

    CYCLE_SEARCH_FOUND:
    pop di;
    pop cx;
    mov cx, di;
    sub cx, offset string;
    mov [string_size_cutted], cl;

    exit_proc:

    ret;

CutSub_string        endp;

    end start