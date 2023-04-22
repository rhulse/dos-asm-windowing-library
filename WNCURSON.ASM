;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wncuson.asm                                                     ;
;                                                                              ;
;  Description : Turns the hardware cursor on in the specified WINDOW.         ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                 void    WnCursOn ( WINDOW *ptr )                             ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnCursOn
extrn   BiosSetCursPos:near

.CODE
_WnCursOn	PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        mov     dl , BYTE PTR [si].W_X      ; x = ptr -> x + ptr -> cursx
        add     dl , BYTE PTR [si].W_CURSX
        mov     dh , BYTE PTR [si].W_Y      ; y = ptr -> y + ptr -> cursy
        add     dh , BYTE PTR [si].W_CURSY  

        call    near ptr BiosSetCursPos ; set cursor position. dl is x. dh is y

	pop	si
	pop	bp
	ret	
_WnCursOn	ENDP
                END
