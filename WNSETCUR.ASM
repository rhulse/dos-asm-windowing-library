;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnsetcur.asm                                                    ;
;                                                                              ;
;  Description : Contains WINDOW function to set a windows cursor position.    ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;         void    WnSetCurs ( WINDOW *ptr , int x , int y )                    ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnSetCurs

.CODE
_WnSetCurs      PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1
 
        mov     ax , ARG_2      ; ptr -> cursx = x
        mov     [si].W_CURSX , ax

        mov     ax , ARG_3      ; ptr -> cursy = y
        mov     [si].W_CURSY , ax

        pop     si
	pop	bp
	ret	
_WnSetCurs      ENDP
                END
