;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnbcol.asm                                                      ;
;                                                                              ;
;  Description : sets the attribute for vsdisp to use on the border.           ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;      void    WnBorderCol( WINDOW *ptr  ,  int fgc  ,  int bgc )              ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnBorderCol
extrn   _MakeAttr:near
extrn   ModLog:near

.CODE
_WnBorderCol	  PROC
	push	bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

        cmp     [si].W_BDR , 0          ; is there really a border ?
        je      short bcol_end          ; if not end
;
;       attr = MakeAttr ( fgc  ,  bgc );
;
        push    ARG_3
        push    ARG_2
	call	near ptr _MakeAttr
        add     sp , 4
        mov     [si].W_BDR_ATTR , ax     ; save attribute

        call    near ptr ModLog
bcol_end:
        pop     si
	pop	bp
	ret	
_WnBorderCol	ENDP
		END
