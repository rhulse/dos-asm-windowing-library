;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description :                                                               ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void AllocError ( void );                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
;------------------------------------------------------------------------------;
;                                                                              ;
;           This module contains a function to write on the bottom row of a box;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnBorderPrint
extrn   _WnPrintxy:near

;------------------------------------------------------------------------------;
;                                                                              ;
;      Sets text over the top of the  top edge in a window                     ;
;void WnBorderPrint(WINDOW *ptr, int edge, int x, char *text );                ;
;                         arg1    arg2   arg3     arg4                         ;
;                arg2 sets top or bottom  arg3 set distance                    ;
;------------------------------------------------------------------------------;
.CODE

_WnBorderPrint  PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        cmp     [si].W_BDR , 0          ; is there really a border to write on ?
        je      short title_end         ; if not end

        push    [si].W_BDR              ; save old border type
        mov     [si].W_BDR , 0          ; turn off border

                                        ; push arguments
        push    ARG_4                   ; text pointer

        mov     ax , 0                  ; set for TOP row
        cmp     ARG_2 , 0               ; is it the TOP row ?
        je      top_row                 ; don't change
        mov     ax , [si].W_HGT         ; mov height in
        dec     ax
top_row:
        push    ax                      ; top or bottom row
        push    ARG_3                   ; x position
        push    ARG_1                   ; *WINDOW

        call    _WnPrintxy              ; print it

        add     sp , 8

        pop     [si].W_BDR              ; restore old border type
title_end:
        pop     si
	pop	bp
	ret	
_WnBorderPrint  ENDP
                END
