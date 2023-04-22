;
;
;  File Name    :       bginfo.asm
;
;  Description  :       Bios Get Cursor Information.
;
;       caller  : nothing
;       returns : cx = size
;               : dx = position
;
.MODEL SMALL

public   BiosGetCursInfo

.CODE

BiosGetCursInfo PROC
        mov     ah , 3
        xor     bh , bh         ; always page 0
        push    bp
        int     10H
        pop     bp
        ret
BiosGetCursInfo ENDP
                END
