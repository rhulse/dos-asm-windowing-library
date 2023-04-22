;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wndeact.asm                                                     ;
;                                                                              ;
;  Description : WINDOW module function to Deactivate an ACTIVATED window.     ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void WnDeActivate ( WINDOW *ptr )                                           ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnDeActivate

extrn   ModLog:near
extrn   KClose:near
extrn   old_prev:word
extrn   old_next:word
extrn   _first_win:word
extrn   _last_win:word
extrn   _active_win:word
extrn   _activated_win:word

.CODE


_WnDeActivate   PROC
        push    si
        push    di

        mov     si , active_win
        or      si , si
        jz      deact7          ; cant close a null window ptr

        cmp     activated_win , FALSE
        je      short deact6
deact1:
        call    near ptr KClose

        mov     bx , old_prev
        mov     [si].W_PREV , bx
        mov     di , old_next
        mov     [si].W_NEXT , di

        or      bx , bx         ; is it a NULL
        jne     short deact2    ; no
        mov     first_win , si  ; yes then this one is first
        jmp     short deact3
deact2:
        mov     [bx].W_NEXT , si  ; make prev window point on to this one
deact3:
        or      di , di         ; is it a NULL
        jne     short deact4    ; no
        mov     last_win , si   ; yes - then this one is last.
        mov     active_win , si ; and active one.
        jmp     short deact5
deact4:
        mov     [di].W_PREV , si ; make next window point back to this one
deact5:
        mov     [si].W_OPEN , TRUE      ; make it open on the list !!
        mov     [si].W_HIDE , FALSE     ; and unhide it.
        mov     activated_win , FALSE
deact6:
        call    near ptr ModLog         ; log the deactivated window

deact7:
        pop     di
        pop     si
        ret
_WnDeActivate   ENDP
                END
