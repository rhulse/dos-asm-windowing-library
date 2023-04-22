;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : Returns the ammount of free space on the specified drive      ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; long DosGetFreeSpace ( int drive_number )                                    ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _DosGetFreeSpace

.CODE

_DosGetFreeSpace        PROC
        push    bp
        mov     bp , sp
        mov     dx , word ptr [bp + 4]
        mov     ah , 19H        ; function #
        int     21H             ; call DOS
        cbw                     ; clear the high byte of ax for return
        pop     bp
        ret
_DosGetFreeSpace        ENDP
                        END
