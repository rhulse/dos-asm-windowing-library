;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : dosff.asm                                                       ;
;                                                                              ;
;  Description : DOS find first file function                                  ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; int     DosFindFirst ( char *filespec, int attributes, struct find_t *DTA )  ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL
;
; these make the code easier to read
;
ARG_1           equ     word ptr [bp + 4]       ; Argument 1
ARG_2           equ     word ptr [bp + 6]       ; Argument 2
ARG_3           equ     word ptr [bp + 8]       ; Argument 3

Public  _DosFindFirst

.CODE

_DosFindFirst	PROC
        push    bp
        mov     bp , sp
        push    cx
        push    dx

        mov     dx , ARG_3      ; set up our own DTA
        mov     ah , 1AH        ; function #
        int     21H

        mov     dx , ARG_1      ; pointer to filespec to look for
        mov     cx , ARG_2      ; attributes to use
        mov     ah , 4EH        ; function #
        int     21H             ; call DOS ax = error code
        jc      short dff1      ; jump if error
        xor     ax , ax         ; no error return ax = 0
dff1:
        pop     dx
        pop     cx
        pop     bp
        ret
_DosFindFirst	ENDP
		END
