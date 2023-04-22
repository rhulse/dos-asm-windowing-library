;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnhide.asm                                                      ;
;                                                                              ;
;  Description :  Contains functions to Hide and unhide single windows.        ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;    void WnHide ( WINDOW *ptr );                                              ;
;    void WnUnHide ( WINDOW *ptr );                                            ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnHide
public  _WnUnHide
extrn   ModLog:near
extrn   _active_win:word

.CODE
_WnHide         PROC
        push    bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

;        cmp     si , _active_win  ; dont hide it if it is active !
 ;       je      short dont_hide

        mov     ax , TRUE
        mov     [si].W_HIDE , ax
dont_hide:
        call    near ptr ModLog
        pop     si
        pop     bp
        ret     
_WnHide         ENDP

_WnUnHide       PROC
        push    bp
        mov     bp , sp
        push    si
        mov     si , ARG_1

        xor     ax , ax
        mov     [si].W_HIDE , ax

        call    near ptr ModLog
        pop     si
        pop     bp
        ret     
_WnUnHide       ENDP
                END

