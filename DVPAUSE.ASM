;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : dvpause.asm                                                     ;
;                                                                              ;
;  Description : gives up the rest of the programmes time slice in DESQview    ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void    DvPause( void )                                                     ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

public  _DvPause

extrn   api_call:near
extrn   _in_dv:word

.CODE

_DvPause	PROC
; This routine gives up the rest of your programme's time slice. It takes
; no parameters and returns nothing.

	cmp	word ptr _in_dv , 1	; See if running under DESQview
        jne     short dvp_x             ; If not, do nothing
	push	bx
	mov	bx , 1000H		; Else this is pause function call
        call    near ptr api_call
	pop	bx
dvp_x:
	ret
_DvPause        ENDP
		END
