;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnopen.asm                                                      ;
;                                                                              ;
;  Description : WINDOW functions to open a window and add to linked list      ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void    WnOpen ( WINDOW *ptr )                                              ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnOpen
public  KOpen

extrn   KClose:near
extrn   ModLog:near
extrn   _WnDeActivate:near
extrn   _first_win:word
extrn   _last_win:word
extrn   _active_win:word
extrn   _no_wins:word

.CODE
_WnOpen 	PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1              ; WINDOW *ptr

        call    near ptr _WnDeActivate  ; any ACTIVATED window must be deactivated first

        cmp     [si].W_OPEN , TRUE      ; is it open ?
        jne      short open1            ; no .. jump
        call    near ptr KClose         ; yes .. close it first
open1:
        call    near ptr KOpen          ; link this one on to end of list
        call    near ptr ModLog         ; log changes

        pop     si
	pop	bp
	ret	
_WnOpen ENDP


KOpen   PROC
;
;       at entry si points to the window structure.
;
        push    di

	mov	ax , last_win		; ptr -> back_link = last_win
        mov     [si].W_PREV , ax ; get last window in list and tack this one on

        mov     [si].W_NEXT , 0         ; ptr -> on_link = ( WINDOW *)NULL

        cmp     first_win  , 0          ; if ( first_win  EQ (WINDOW *)NULL )
	jne	short kop1		; if others open then make it last
        mov     first_win  , si         ; else make it first
	jmp	short kop2		; first_win  = ptr
kop1:
        mov     di , [si].W_PREV        ; else { temp_ptr = ptr -> back_link }
        mov     [di].W_NEXT , si        ; temp_ptr -> on_link = ptr
kop2:
        mov     last_win , si           ; make this one the last one
        mov     active_win , si         ; and the active window
	mov	[si].W_HIDE , FALSE	; ptr -> hide = FALSE
	mov	[si].W_OPEN , TRUE	; ptr -> open = TRUE
        inc     no_wins                 ; one more window

        pop     di
        ret
KOpen   ENDP
        END
