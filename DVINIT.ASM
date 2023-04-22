;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : Contains the DESQview Init and api functions.                 ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; int     DvInit( void );     /* return DESQview version */                    ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

public  _DvInit
public  api_call

public  _in_dv

.DATA

_in_dv  DW 00H           ; are we in desqview

.CODE

_DvInit PROC
; This routine returns the DESQview major/minor number in ax, and sets up the
; _IN_DV variable for later use by other DESQview I/F programmes

	push	bx
	push	cx
	push	dx
	mov	cx , 'DE'		; Set cx, dx to an invalid date
	mov	dx , 'SQ'
	mov	ax , 2B01H		; DOS's Set Date function
	int	21H			; Call DOS
	cmp	al , 0FFH		; Did DOS recognize it?
        je      short no_desqview       ; If not, DESQview isn't running
	mov     ax , bx                 ; Else get version number
	mov	word ptr _in_dv , 1	; Indicate we're running under DESQview
        jmp     short dv_end
no_desqview:
        xor     ax , ax                 ; Return no DESQview ( version 0 )
dv_end:
	pop	dx
	pop	cx
	pop	bx
	ret
_DvInit ENDP

api_call	PROC
; This routine takes a programme interface function in bx, and makes that
; call to DESQview after switching onto a stack that DESQview provides.

	push	ax
	mov	ax , 101AH		; this function to switch to DV's stack
	int	15H
	mov	ax , bx			; Move the desired function into ax
	int	15H			; Make the call
	mov	ax , 1025H		; Function to turn off DV's stack
	int	15H			; Make that call
	pop	ax
	ret
api_call	ENDP
		END
