;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : curhome.asm                                                     ;
;                                                                              ;
;  Description : Moves the cursor to 0,0 with the BIOS                         ;
;     Internal function used by WINDOW modules.                                ;
;                                                                              ;
;------------------------------------------------------------------------------;
	DOSSEG
        .MODEL SMALL

include window.inc

public  _CursorHome
extrn   BiosSetCursPos:near

.CODE
;------------------------------------------------------------------------------;
;  Cursor function .. Move cursor to top left corner of the screen.            ;
;------------------------------------------------------------------------------;
_CursorHome	PROC
        mov     dx , 0000H
        call    near ptr BiosSetCursPos
        ret
_CursorHome     ENDP
                END
