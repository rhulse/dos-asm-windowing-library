;
;  File Name    :       allocerr.asm
;
;  Description  :       Window module memory allocation error handler.
;                       Handles memory allocation error...
;                       Releases all memory and prints message
;
;  C Prototypes :       void AllocError ( void );
;
;
.MODEL SMALL

include window.inc

public  C AllocError
extrn	_WnExit:near

.DATA

message1        DB      0DH , 0AH                       ; cr and lf
                DB      'PROGRAMME ABORTED...'
                DB      'Unable to allocate enough memory to continue.'
                DB      0DH , 0AH                       ; cr and lf
msg_len         EQU     $ - message1

.CODE

AllocError      PROC    C
        call    near ptr _WnExit   ; clean up
;
;   use DOS to write message to screen
;
        mov     ah , 40H        ; write to file or device
        mov     bx , 2          ; handle for standard error
        mov     cx , msg_len    ; length of the message
        mov     dx , OFFSET DGROUP:message1
        int     21H
;
;   use DOS to exit. Stops any exit routine being executed and over-
;   writeing the message.
;
        mov     ax , 4C01H      ; Function 4CH   return code = 1
        int     21H
        ret                     ; not really needed !!
AllocError      ENDP
                END
