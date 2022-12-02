name prog
.model small
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
.code
    ;---------------------
main proc far

    start:

        mov ax,@data
        mov ds,ax

exit:

        mov ax,4C00h ; exit
        int 21h

main endp
;---------------------
    end start