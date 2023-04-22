;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : gettime.asm                                                     ;
;                                                                              ;
;  Description : Get the time from DOS                                         ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; long DosGetTime ( char *hours, char *min, char *secs, char *hund )           ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _DosGetTime

.CODE

_DosGetTime     PROC
        push    bp
        mov     bp , sp

        mov     ah , 2CH        ; get time function
        int     21H             ; call DOS

        mov     bx , [bp + 4]   ; hour
        mov     [bx] , ch
        mov     bx , [bp + 6]   ; min
        mov     [bx] , cl
        mov     bx , [bp + 8]   ; sec
        mov     [bx] , dh
        mov     bx , [bp + 10]  ; hundredths
        mov     [bx] , dl
        mov     ax , dx         ; pack time into long
        mov     dx , cx

        pop     bp
        ret
_DosGetTime     ENDP
                END
