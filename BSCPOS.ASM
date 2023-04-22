;
;  File Name    :       bscpos.asm
;
;  Description  :       Bios Set Cursor Position.
;
;       caller  : dl = column number   [ x coordinate ]
;                 dh = row  number     [ y coordinate ]
;       returns : nothing

.MODEL SMALL

public   BiosSetCursPos

.CODE
BiosSetCursPos  PROC
        mov     ah , 2
        xor     bh , bh         ; always page 0
        push    bp
        int     10H
        pop     bp
        ret
BiosSetCursPos  ENDP
                END
