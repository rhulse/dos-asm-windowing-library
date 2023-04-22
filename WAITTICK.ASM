;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : waittick.asm                                                    ;
;                                                                              ;
;  Description : waits for one timer tick to tick over !                       ;
;                called by SPause and TPause                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  __WaitTick

.CODE

;       call with cx set to number of ticks to  wait

__WaitTick	PROC
        push    es
        push    ax
        push    dx

        xor     ax , ax
        mov     es , ax
wt1:
        mov     ax , WORD PTR es:[46CH]
        mov     dx , WORD PTR es:[46EH]
wt2:
        cmp     ax , WORD PTR es:[46CH] ; is MSB different ?
        jne     short wt3               ; yes jump and reload
        cmp     dx , WORD PTR es:[46EH] ; is LSB different ?
        je      short wt2               ; no - compare again
wt3:
        loop    short wt1

        pop     dx
        pop     ax
        pop     es
        ret
__WaitTick	ENDP
		END
