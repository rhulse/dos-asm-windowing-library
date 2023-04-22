        name    curthin
        title   CURTHIN.ASM - makes the cursor THIN..uses the BIOS

.MODEL SMALL
;
;  C prototype : void CursorThin ( void )
;
include window.inc

public  _CursorThin
extrn   _adapter:word
extrn   BiosSetCurSize:near

.CODE
;
;  Cursor function .. Makes the cursor thin
;
;       caller  : nothing
;       returns : nothing
;
_CursorThin     PROC
        mov     cx , 0C0DH      ; mono size of cursor
        cmp     adapter , MDA   ; is it an MDA ?
        je      short make_thin
        mov     cx , 0607H      ; colour size of cursor
make_thin:
        call    near ptr BiosSetCurSize
        ret
_CursorThin     ENDP
                END
