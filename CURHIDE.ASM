;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : curhide.asm                                                     ;
;                                                                              ;
;  Description : hide the curser with the BIOS                                 ;
;     Internal function used by WINDOW modules.                                ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _CursorHide
extrn   BiosSetCursPos:near

.CODE
;------------------------------------------------------------------------------;
;  Cursor function .. Hide cursor off bottom off screen.                       ;
;------------------------------------------------------------------------------;
_CursorHide	PROC
        mov     dx , 2500H
        call    near ptr BiosSetCursPos
        ret
_CursorHide     ENDP
                END


