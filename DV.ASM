;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : dv.asm                                                          ;
;                                                                              ;
;  Description : Routines to interface with DESQview.                          ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void AllocError ( void );                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

public  _DvInit
public	_DvSeize
public	_DvRelease
public  _DvPause
public  _DvGetVidBuffer
public  _DvAppNum
public  _DvSound
public  _DvNoSound

public  _in_dv

TRUE    EQU     1
FALSE	EQU	0

.DATA

_in_dv  DW 00H          ; are we in desqview

.CODE
; The following routines deal with the DESQview interface
_DvInit PROC    NEAR
; This routine returns the DESQview major/minor number in ax, and sets up the
; _IN_DV variable for later use by other DESQview I/F programmes

	push	bx
	push	cx
	push	dx
	mov	word ptr _in_dv , 0	; Assume DESQview not running
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

api_call        PROC    NEAR
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

_DvPause        PROC    NEAR
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

_DvSeize	PROC	NEAR
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

; void far *DVshadow_start(int *rows,int *cols)

_DvGetVidBuffer    proc near
; This routine returns the Segment of th video buffer
        push    es
        cmp     word ptr _in_dv , 1     ; See if running under DESQview
        jne     short gcb_x             ; If not, do nothing

        mov     ah , 0FEH               ; fuction #
        int     10H                     ; call DESQview
        mov     ax , es                 ; put segment in ax
        pop     es                      ; restore es
gcb_x:
        ret

_DvGetVidBuffer    endp

_DvAppNum       proc near
        mov     ax , 0DE07H
        int     15H     ; number of aplication in the
        ret             ; ax register
_DvAppNum       endp

_DvSound        proc near
; Gets DESQview to beep.
;
        push    bp
        mov     bp , bp
        push    bx
        push    cx

        mov     bx , [bp + 4]   ; frequency in hertz
        mov     cx , [bp + 6]   ; time in ticks
        mov     ax , 1019H      ; DESQview function #
        int     15H

        pop     cx
        pop     bx
        pop     bp
        ret
_DvSound        endp

_DvNoSound      proc near
        ret
_DvNoSound      endp

_TEXT   ENDS
	END

