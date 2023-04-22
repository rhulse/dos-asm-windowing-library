;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnshadow.asm                                                    ;
;                                                                              ;
;  Description :  Sets the colour and type of shadow.                          ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void  WnShadow( WINDOW *ptr , int type , int fill , int fgc , int bgc )      ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnShadow
extrn   ModLog:near
extrn   _MakeAttr:near

.DATA
FILL_CHARS      DB    020H, 0B0H, 0B1H, 0B2H, 0DBH
;                      ' '   '°'   '±'   '²'   'Û'

.CODE
_WnShadow   PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        call    near ptr ModLog ; if shadow is changed - stops bits being left

        push    ARG_5
        push    ARG_4
	call	near ptr _MakeAttr
        add     sp , 4
        mov     dh , al         ; save attribute in dh
;
;       fillchar = chars[fill] + attr;
;
        mov     bx , ARG_3
        mov     dl , BYTE PTR DGROUP:FILL_CHARS[bx]
;
; if type is 0 or false then there is no shadowing.
;
        mov     ax , ARG_2
        mov     [si].W_SHADOW , ax      ; ptr -> shadow = type
        mov     [si].W_SHADCHAR , dx    ; ptr -> shadchar = fillchar

        call    near ptr ModLog

	pop	si
	pop	bp
	ret	
_WnShadow       ENDP
                END
