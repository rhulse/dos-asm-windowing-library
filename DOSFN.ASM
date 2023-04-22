;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : dosfn.asm                                                       ;
;                                                                              ;
;  Description : DOS find next  file function                                  ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; int     DosFindNext  ( struct find_t *DTA )                                  ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

Public  _DosFindNext

.CODE

_DosFindNext	PROC
        push    bp
        mov     bp , sp
        push    dx                                    

        mov     dx , word ptr [bp + 4]  ; set up our own DTA
        mov     ah , 1AH                ; function #
        int     21H                     ; call DOS

        mov     ah , 4FH        ; function #
        int     21H             ; call DOS ax = error code
        jc      short dfn1      ; jump if error
        xor     ax , ax         ; no error return ax = 0
dfn1:
        pop     dx
        pop     bp
        ret
_DosFindNext	ENDP
		END
