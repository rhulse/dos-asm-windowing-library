;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnact.asm                                                       ;
;                                                                              ;
;  Description : make specified window active.                                 ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void WnActivate ( WINDOW *ptr )                                             ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnActivate
extrn   _WnDeactivate:near
extrn   _WnOpen:near
extrn   KOpen:near
extrn   KClose:near
extrn   KClose:near
extrn   ModLog:near
extrn   _active_win:word
extrn   _activated_win:word
extrn   old_prev:word
extrn   old_next:word

.CODE
_WnActivate     PROC
        push    bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

        or      si , si
        jz      short no_way            ; cant do anything with a NULL !!!!

        cmp     si , active_win         ; is it already active ?
        je      short no_way            ; yes - then exit.

        cmp     [si].W_OPEN , TRUE      ; if its open then carry on
        je      short carry_on

        push    si                      ; if it is closed then just open
        call    near ptr _WnOpen        ; it in the ordinary way
        inc     sp
        inc     sp
        jmp     short no_way
carry_on:
        call    near ptr _WnDeactivate  ; deactivate old one.
        mov     ax , [si].W_PREV        ; save old pointers for later
        mov     old_prev , ax

        mov     ax , [si].W_NEXT        ; save old pointers for later
        mov     old_next , ax

        call    near ptr KClose         ; must be open - remove it first.
        call    near ptr KOpen          ; then bring to the top
        call    near ptr ModLog         ; and log changes
        mov     activated_win , TRUE    ; let deactivate function know
no_way:
        pop     si
        pop     bp
        ret     
_WnActivate     ENDP
                END
