;что такое ассемблер, как он отличается от двоичного кода

.model small
.stack 256
.data

    hellow dw 0;

.code

zero_ax MACRO               ;этот код целиком вставиться на место вызова макроса

    mov ax, 0;

ENDM

    start:

        mov ax, 0;          1: текстовый формат двочиных команд

        zero_ax;            2: макросные конструкции

        jmp exit;           3: метки, как относительная адрессация на этапе компиляции

        exit:
        mov ax, 4C00h;
        int 21h;

end start