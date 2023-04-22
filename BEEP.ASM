;
;
;  File Name    :       Beep.asm
;
;  Description  :       Makes the hardware BEEP
;
;  C Prototypes :       void Beep ( int Hz , int ticks );
;

.MODEL SMALL

public  C Beep
extrn   __WaitTick:near

TIMER_DATA      EQU     42H
TIMER_CONTROL   EQU     43H
PORT_B          EQU     61H

.CODE

Beep    PROC    C
        ARG     freq:word , ticks:word
        USES    bx , cx , dx

        mov     bx , [freq]     ; get frequency
        mov     dx , 12H        ; divide frequency
        xor     ax , ax
        div     bx
        mov     bx , ax

        mov     al , 10110110B  ; set up port
        out     TIMER_CONTROL , al
        mov     ax , bx
        out     TIMER_DATA , al ; output LSB to port
        mov     al , ah         ; ready for MSB
        out     TIMER_DATA , al ; output MSB to port
        in      al , PORT_B     ; get status of potr B
        or      al , 03H        ; turn the speaker on
        out     PORT_B , al     ; send it

        mov     cx , [ticks]    ; number of ticks in cx
        call    near ptr __WaitTick     ; wait
        in      al , PORT_B     ; get status of potr B
        and     al , 0FEH       ; turn the speaker off
        out     PORT_B , al     ; send it

        ret
Beep    ENDP
        END
