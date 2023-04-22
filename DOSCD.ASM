;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : doscd.asm                                                       ;
;                                                                              ;
;  Description : use DOS to change directory.                                  ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;   int     DosCD ( char *path )                                               ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _DosCD

.CODE

_DosCD		PROC
        push    bp
        mov     bp , sp
        mov     dx , word ptr [bp + 4]
        mov     ah , 3BH        ; function #
        int     21H             ; call DOS
        jb      short cderror   ; branch on error
        xor     ax , ax         ; return 0 if OK
cderror:
        pop     bp
        ret
_DosCD		ENDP
		END
