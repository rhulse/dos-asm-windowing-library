;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : getdrive.asm                                                    ;
;                                                                              ;
;  Description : returns the current DOS drive number                          ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;   int DosGetDrive ( void )                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _DosGetDrive

.CODE

_DosGetDrive	PROC
        mov     ah , 19H        ; function #
        int     21H             ; call DOS
        cbw                     ; clear the high byte of ax for return
        ret
_DosGetDrive	ENDP
		END
