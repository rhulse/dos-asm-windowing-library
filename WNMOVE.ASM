;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnmove.asm                                                      ;
;                                                                              ;
;  Description : Moves the position of a WINDOW on the screen.                 ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;            void    WnMove ( WINDOW *ptr  ,  int x , int y )                  ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnMove
extrn   ModLog:near

.CODE
_WnMove 	PROC
	push	bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

        call    near ptr ModLog  ; must be called to log OLD position of window

        mov     ax , ARG_2
        mov     [si].W_X , ax   ; ptr -> x = x
        mov     ax , ARG_3
        mov     [si].W_Y , ax   ; ptr -> y = y

        cmp     [si].W_OPEN , 0 ; if its not open
        je      short move1     ; jump

        call    near ptr ModLog
move1:
        pop     si
        pop     bp
	ret	
_WnMove 	ENDP

		END
