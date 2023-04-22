;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wngetatt.asm                                                    ;
;                                                                              ;
;  Description : Contains WINDOW function to get a windows attributes.         ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;       void    WnGetAttr ( WINDOW *ptr , int *fgc , int *bgc )                ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnGetAttr

.CODE
_WnGetAttr	PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        mov     ax , [si].W_FGC
        mov     bx , ARG_2
        mov     WORD PTR [bx] , ax      ; *fgc = ptr -> fgc

        mov     ax , [si].W_BGC
        mov     bx , ARG_3
        mov     WORD PTR [bx] , ax      ; *bgc = ptr -> bgc

	pop	si
	pop	bp
	ret	
_WnGetAttr	ENDP
		END
