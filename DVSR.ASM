;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : Critical process control for under DESQview                   ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void    DvSeize( void )                                                     ;
;  void    DvRelease( void )                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

public  _DvSeize
public  _DvRelease

extrn   api_call:near
extrn   _in_dv:word

.CODE

_DvSeize	PROC
; This routine tells DESQview not to slice away from your programme until
; you make a _DvRelease call. It takes no parameters and returns nothing.

	cmp	word ptr _in_dv , 1	; See if running under DESQview
        jne     short dvs_x             ; If not, do nothing
	push	bx
	mov	bx , 101BH		; This is Begin Critical function call
        call    near ptr api_call
	pop	bx
dvs_x:
	ret
_DvSeize	ENDP
	
_DvRelease	PROC	NEAR
; This routine tells DESQview that it is OK to not to slice away from your
; programme again. It takes no parameters and returns nothing.

	cmp	word ptr _in_dv , 1	; See if running under DESQview
        jne     short dvr_x             ; If not, do nothing
	push	bx
	mov	bx , 101CH		; This is End Critical function call
        call    near ptr api_call
	pop	bx
dvr_x:
	ret
_DvRelease	ENDP
		END
