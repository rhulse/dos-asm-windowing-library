;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnshoff.asm                                                     ;
;                                                                              ;
;  Description : turn the shadow of the specified window off.                  ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void WnShadowOff ( WINDOW *ptr );                                           ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnShadowOff
extrn   ModLog:near
extrn   _MakeAttr:near

.CODE

_WnShadowOff    PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        call    near ptr ModLog ; if shadow is changed - stops bits being left

        mov     [si].W_SHADCHAR , 32    ; ptr -> shadchar = 0x20
        mov     [si].W_SHADOW , ax      ; ptr -> shadow = FALSE

        call    near ptr ModLog

	pop	si
	pop	bp
	ret	
_WnShadowOff    ENDP
                END
