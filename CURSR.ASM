;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : cursr.asm                                                       ;
;                                                                              ;
;  Description : Save and restore the cursor with the BIOS                     ;
;     Internal function used by WINDOW modules.                                ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include screen.inc

public   CursorSave
public   CursorRestore
extrn   _adapter:word
extrn   BiosGetCursInfo:near
extrn   BiosSetCurSize:near
extrn   BiosSetCursPos:near

.DATA

old_position    dw      0       ; old cursor position
old_size        dw      0       ; old cursor size

.CODE
;------------------------------------------------------------------------------;
;  Cursor function .. Save old values to variables.                            ;
;------------------------------------------------------------------------------;
CursorSave     PROC
        call    near ptr BiosGetCursInfo
        mov     old_position , dx
        cmp     _adapter , MDA    ; is it an MDA ?
        jne     short csave_end         ; nope
        cmp     cx , 0607H              ; has the wrong size been returned
        jne     short csave_end         ; nope
        mov     cx , 1112H              ; replace buggy bios returned data
csave_end:
        mov     old_size , cx
        ret
CursorSave     ENDP
;------------------------------------------------------------------------------;
;  Cursor function .. Restore cursor to variables.                             ;
;------------------------------------------------------------------------------;
CursorRestore  PROC
        mov     cx , old_size
        call    near ptr BiosSetCurSize
        mov     dx , old_position
        call    near ptr BiosSetCursPos
        ret
CursorRestore   ENDP
                END
