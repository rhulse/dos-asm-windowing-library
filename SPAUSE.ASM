;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : spause.asm                                                      ;
;                                                                              ;
;  Description : wait for specified number of seconds                          ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void    SPause( int )                                                        ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _SPause
extrn   __WaitTick:near

.CODE

_SPause 	PROC
        push    bp
        mov     bp , sp
        push    cx
        mov     ax , [ bp+4 ]
        mov     cx , 18
        imul    cl
        mov     cx , ax
        call    near ptr __WaitTick
        pop     cx
        pop     bp
        ret

_SPause 	ENDP
		END
