;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wngetcur.asm                                                    ;
;                                                                              ;
;  Description : Contains WINDOW function to get a windows cursor position.    ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;          void    WnGetCurs ( WINDOW *ptr , int *x , int *y )                 ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnGetCurs

.CODE
_WnGetCurs	PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        mov     ax , [si].W_CURSX
        mov     bx , ARG_2
        mov     WORD PTR [bx] , ax      ; *x = ptr -> cursx

        mov     ax , [si].W_CURSY
        mov     bx , ARG_3
        mov     WORD PTR [bx] , ax      ; *y = ptr -> cursy

	pop	si
	pop	bp
	ret	
_WnGetCurs	ENDP
		END
