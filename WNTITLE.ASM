;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wntitle.asm                                                     ;
;                                                                              ;
;  Description : set the string to display as the title in the border.	       ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;    void WnTitle ( WINDOW *ptr , char *static text )			       ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public	_WnTitle

.CODE
_WnTitle	PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

	mov	ax , ARG_2
	mov	[si].W_TITLE , ax

        pop     si
	pop	bp
	ret	
_WnTitle	ENDP
                END
