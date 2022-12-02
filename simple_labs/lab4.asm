name prog
.model small
.stack 100h
.data
    string1_buf     db 33, 33
    string1         db 33 dup('5');
    db              '$'
    string2_buf     db 44, 44
    string2         db 44 dup('4');
    db              '$'

    sub_string_buf  db 44, ?
    sub_string      db 44 dup('$')
    db              '$'

    fisrt_pos1      dw 5;
    first_pos2      dw 9;
    num             dw 12;

    ENDLstr              db  0Ah, 0Dh, '$';
    string_msg           db "  Two random strings:$"
    result_msg           db "  Result after moving:$"
    enter_msg            db "  Enter symbol for algorithm:$"
    result_2_msg         db "  Symbol is not in string $"
    result_2_msg_c       db "   Times$"
    substr_msg           db "  Enter substring:$"
    substr_found_msg     db "  Substring founded at position $"
    substr_found_msg_c   db "   in second string$"
    substr_not_found_msg db "  Substring not found$"

    seed		dw  234
    seed2		dw	654

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
        mov es,ax;

        mov si, offset string1;
        mov cl, [string1_buf]
        xor ch, ch;
        rnd_str1:

            push si;

            mov si, 41h;
            mov di, 7Ah;
            call random;

            pop si;

            mov [si], al;
            inc si;

        loop rnd_str1

        mov di, offset string2;
        mov cl, [string2_buf]
        xor ch, ch;
        rnd_str2:

            push di;

            mov si, 41h;
            mov di, 7Ah;
            call random;

            pop di;

            mov [di], al;
            inc di;

        loop rnd_str2

        mov si, offset string1;
        add si, fisrt_pos1;
        mov di, offset string2;
        add di, first_pos2;

        output_str string_msg;
        endl;
        output_str string1_buf;
        endl;
        output_str string2_buf;
        endl;
        endl;


        mov cx, [num];
        cld;

        rep movsb;

        output_str result_msg;
        endl;
        output_str string1_buf;
        endl;
        output_str string2_buf;
        endl;
        endl;


        output_str enter_msg;
        endl;
        mov ah, 01h;
        int 21h;
        endl;
        xor ah, ah;
        mov cl, [string2_buf];
        mov di, offset string2;
        xor ah, ah;
        cycle:

            repne scasb
            cmp CX, 0;
            jz break
            inc ah;

        jmp cycle
        break:
        xor ch, ch;
        mov cl, [string2_buf];
        sub cl, ah;
        mov ax, cx;

        output_str result_2_msg;
        call Unsigned16Num_output;
        output_str result_2_msg_c;
        endl;


        output_str substr_msg;
        endl;
        enter_str sub_string_buf;
        endl;

        mov si, offset string2;
        mov di, offset sub_string;
        xor ch, ch;
        mov cl, [sub_string_buf + 1]
        xor ah, ah;
        mov al, offset string2
        add al, [string2_buf]
        sub ax, cx;
        sub_str_cycle:

            push di;
            push si;
            push cx;

            repe cmpsb
            cmp cx, 0;

            pop  cx;
            pop  si;
            pop  di;
            jz sub_str_found

            inc si;

        cmp si, ax;
        jne sub_str_cycle

        output_str substr_not_found_msg;
        endl;
        jmp ex;

        sub_str_found:
        output_str substr_found_msg;
        mov ax, si;
        sub ax, offset string2;
        call Unsigned16Num_output;
        output_str substr_found_msg_c;
        jmp ex;

ex:

        mov ax,4C00h ; exit
        int 21h

main endp

random  proc
	push	cx
	push	dx
	push	di
 
	mov	dx, word [seed]
	or	dx, dx
	jnz	next1
	in	ax, 40h
	mov	dx, ax
next1:	
	mov	ax, word [seed2]
	or	ax, ax
	jnz	next2
	in	ax, 40h
next2:		
	mul	dx
	inc	ax
	mov 	word [seed], dx
	mov	word [seed2], ax
 
	xor	dx, dx
	sub	di, si
	inc	di
	div	di
	mov	ax, dx
	add	ax, si
 
	pop	di
	pop	dx
	pop	cx
	ret
random endp

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