;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :  wnborder.asm                                                   ;
;                                                                              ;
;  Description :  WINDOW function to set border type for a window.             ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;    void    WnBorder ( WINDOW *win_ptr  ,  int type )                         ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnBorder
extrn   _MakeAttr:near
extrn   ModLog:near
; BORDER TYPES                #     CALL FROM C
;
; None.                       0       FALSE
; Spaces.                     1       SPACES
; Single line.                2       SINGLE
; Double line.                3       DOUBLE
; Double top , Single side.   4       DTOP_SSIDE
; Single top , Double side.   5       STOP_DSIDE
; Block.                      6       BLOCK
;
.CODE
_WnBorder PROC
	push	bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

        mov     ax , ARG_2              ; type in ax
        or      ax , ax                 ; if there is no border , then check
        jnz     short not_too_small     ; to see if the window is too small
        cmp     [si].W_WID , 1          ; is it 1 wide
        jle     short too_small         ; dont do a shadow
        cmp     [si].W_HGT , 1          ; or 1 high
        jg      short not_too_small     ; dont do a shadow
too_small:
        mov     [si].W_SHADCHAR , 32    ; ptr -> shadchar = 0x20
        mov     [si].W_SHADOW , FALSE   ; ptr -> shadow = FALSE
not_too_small:
        mov     [si].W_BDR , ax ; win_ptr -> bdr = type;

        call    near ptr ModLog

        pop     si
	pop	bp
	ret	
_WnBorder	ENDP
		END
