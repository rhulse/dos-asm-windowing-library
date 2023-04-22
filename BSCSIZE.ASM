;
;  File Name    :       bscsize.asm
;
;  Description  :       Bios Set Cursor Size.
;
;       caller  : cx = size
;       returns : nothing
;

.MODEL SMALL

public   BiosSetCurSize

.CODE

BiosSetCurSize  PROC
        mov     ah , 1
        xor     bh , bh         ; always page 0
        push    bp
        int     10H
        pop     bp
        ret
BiosSetCurSize  ENDP
                END
