;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : setdrive.asm                                                    ;
;                                                                              ;
;  Description : use DOS to change drives                                      ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
; void DosSetDrive ( int drive_number )                                        ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _DosSetDrive

.CODE

_DosSetDrive	PROC
        push    bp
        mov     bp , sp
        mov     dx , word ptr [bp + 4]
        mov     ah , 0EH        ; function #
        int     21H             ; call DOS
        cbw                     ; clear the high byte of ax for return
        pop     bp
        ret
_DosSetDrive	ENDP
		END
