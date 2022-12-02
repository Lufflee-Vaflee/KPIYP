name prog
.model small
.stack 100h
.data

    ; first variant
    x1 db ?, ?
    db 3, 3, 3;
    x3 dw 1234h;
    dw ?
    x5 dd ?, ?;
    x6 dq 1122334455663454h, 1122334455663454h;
    dt 1ABBCCDDEEFF84714311h;
    string db "qwefwtv3wef23rf", "wdvberfasdcer"
    symbol db 'E'

    alphabet db "abcdefghijklmnopqrstuvwxyz"
                ;01234567890123456789012345
    second_name db 64, ?, 62 DUP('$')

    ENDLstr         db  0Ah, 0Dh, '$';
    array_msg       db  "  Array:$"
    result_msg      db  "  Result:$"

    array dw 10 dup(?)

    seed		dw  234
    seed2		dw	654

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

    endl        macro

        push    AX;
        push    DX;

        mov     AH,     09h;
        lea     DX,     ENDLstr;
        int     21h; 

        pop     DX;
        pop     AX;

    endm



main proc far

    start:


        mov ax,@data;           register adressation
        mov ds,ax

        mov ax, 42;             direct adressation

        mov al, byte ptr x1;    straight adressation

        mov di, offset x5;
        mov ax, [di];           base adressation

        mov di, 5;
        mov al, string[di];     base adressation with offset


        xor AX, AX;


        ;create OSTROVSKIY second name from alphabet;
        mov second_name[1], 1
        mov di, offset second_name;
        mov al, alphabet[14];
        mov [di + 2], al
        mov al, alphabet[18]
        mov [di + 3], al
        mov al, alphabet[19]
        mov [di + 4], al
        mov al, alphabet[17]
        mov [di + 5], al
        mov al, alphabet[14]
        mov [di + 6], al
        mov al, alphabet[21]
        mov [di + 7], al
        mov al, alphabet[18]
        mov [di + 8], al
        mov al, alphabet[10]
        mov [di + 9], al
        mov al, alphabet[8]
        mov [di + 10], al
        mov al, alphabet[24]
        mov [di + 11], al

        output_str second_name;
        endl;


        mov bx, offset array;       ;array creation and output
        mov cx, 10;
        xor ax, ax;

        output_str array_msg;
        endl;
        cycle:

            mov si, 0;
            mov di, 10;
            call random

            mov bx, offset array;
            mov si, cx;
            ;dec si;
            mov [bx][si], al;

            xor ah, ah;
            call Unsigned16Num_output;
            mov al, ' ';
            mov dl, al;
            mov ah, 06h;
            int 21h;

        loop cycle
        endl;

        mov cx, 10;
        mov bx, offset array;
        xor dx, dx;
        even_num_calc:

            mov si, cx;
            mov al, [bx][si];

            shr ax, 1;
            jb continue
            inc dx;

        continue:
        loop even_num_calc

        output_str result_msg;
        endl;
        add dl, '0';
        mov al, dl;
        mov ah, 06h;
        int 21h;

        call Unsigned16Num_output

exit:

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