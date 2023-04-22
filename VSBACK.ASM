;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : vsback.asm                                                      ;
;                                                                              ;
;  Description : Set the character to use a fill for the background.           ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;      void VsBackground ( int fgc , int bgc , unsigned char fill );           ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public	_VsBackground
extrn	_MakeAttr:near
extrn   _vsfiller:word
extrn   log_start_x:word
extrn   log_start_y:word
extrn   log_end_x:word
extrn   log_end_y:word

.CODE
_VsBackground   PROC
        push    bp
        mov     bp , sp
;        attr = MakeAttr ( fgc , bgc ) * 256;
;
        push    ARG_2
        push    ARG_1
	call	near ptr _MakeAttr
        add     sp , 4
	mov	ah , al 		; attribute in ah
        mov     al , byte ptr [bp + 8]  ; Argument 3  + 'x'
        mov     vsfiller , ax

        mov     log_start_x , 0
        mov     log_start_y , 0
        mov     log_end_x , 80       ; set mod log to do whole sceen
        mov     log_end_y , 25       ; to show the change.

        pop     bp
        ret
_VsBackground   ENDP
		END
