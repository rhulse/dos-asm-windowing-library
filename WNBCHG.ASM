;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnbchg.asm                                                      ;
;                                                                              ;
;  Description : WINDOW function to stop or let the border colour be changed   ;
;                 if the window is active.                                     ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;      void    WnBorderChg( WINDOW *ptr  ,  int allow )                        ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnBorderChg
extrn   ModLog:near

.CODE
_WnBorderChg      PROC
	push	bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

        cmp     [si].W_BDR , 0          ; is there really a border ?
        je      short bchg_end          ; if not end

        mov     ax , ARG_2
        mov     [si].W_BDR_CHG , ax     ; is there really a border ?

        call    near ptr ModLog
bchg_end:
        pop     si
	pop	bp
	ret	
_WnBorderChg    ENDP
                END
