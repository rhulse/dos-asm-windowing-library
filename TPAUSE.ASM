;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : tpause.asm                                                      ;
;                                                                              ;
;  Description : wait for specified number of clock ticks                      ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void    TPause( int )                                                        ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _TPause
extrn   __WaitTick:near

.CODE

_TPause 	PROC
        push    bp
        mov     bp , sp
        push    cx
        mov     cx , [ bp+4 ]
        call    near ptr __WaitTick
        pop     cx
        pop     bp
        ret
_TPause 	ENDP
		END
