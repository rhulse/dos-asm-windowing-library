        name    curfat
        title   CURFAT.ASM - makes the cursor FAT...uses the BIOS

.MODEL SMALL
;
;  C prototype : void CursorFat ( void )
;

include window.inc

public  _CursorFat
extrn   _adapter:word
extrn   BiosSetCurSize:near

.CODE
;
;  Cursor function .. Makes the cursor fat.
;
;       caller  : nothing
;       returns : nothing
;
_CursorFat	PROC
        mov     cx , 000DH      ; mono size of cursor
        cmp     adapter , MDA   ; is it an MDA ?
        je      short make_fat
        mov     cx , 0007H      ; colour size of cursor
make_fat:
        call    near ptr BiosSetCurSize
        ret
_CursorFat      ENDP
                END
