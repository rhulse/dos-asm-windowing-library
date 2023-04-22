;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnsetatt.asm                                                    ;
;                                                                              ;
;  Description : Contains WINDOW function to set a windows attributes.         ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;       void    WnSetAttr ( WINDOW *ptr , int fgc , int bgc )                  ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnSetAttr

.CODE
_WnSetAttr      PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        mov     ax , ARG_2      ; ptr -> fgc = fgc
        mov     [si].W_FGC , ax

        mov     ax , ARG_3      ; ptr -> bgc = bgc
        mov     [si].W_BGC , ax

        pop     si
	pop	bp
	ret	
_WnSetAttr      ENDP
                END
