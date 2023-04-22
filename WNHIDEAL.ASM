;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description :                                                               ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void AllocError ( void );                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
;------------------------------------------------------------------------------;
;                                                                              ;
;  Contains functions to Hide and Unhide all windows.                          ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnHideAll
public  _WnUnHideAll
extrn   ModLog:near

.CODE
_WnHideAll      PROC
        push    si
        mov     si , ARG_1

        mov     ax , TRUE
hideall1:
        mov     [si].W_HIDE , ax
        mov     bx , [si].W_NEXT
        or      bx , bx
        jz      hideall2
        jmp     hideall1
hideall2:
        call    near ptr ModLog
        pop     si
        ret     
_WnHideAll      ENDP


_WnUnHideAll    PROC
        push    si
        mov     si , ARG_1

        xor     ax , ax
unhideall1:
        mov     [si].W_HIDE , ax
        mov     bx , [si].W_NEXT
        or      bx , bx
        jz      unhideall2
        jmp     unhideall1
unhideall2:
        call    near ptr ModLog
        pop     si
        ret     
_WnUnHideAll    ENDP
                END

