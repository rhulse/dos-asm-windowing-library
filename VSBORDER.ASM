;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : vsborder.asm                                                    ;
;                                                                              ;
;  Description : controls the hardware border control functions                ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;         void VsBorderCol ( int colour )                                      ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public	 VsBorder
public  _VsBorderCol
extrn   _vdu:word

;------------------------------------------------------------------------------;
;                                                                              ;
;  This saves or restores the overscan colour.                                 ;
;    called by setupvideo and WnExit                                           ;
;------------------------------------------------------------------------------;
.DATA

old_border_col  DB      0       ; old colour of overscan

.CODE
VsBorder      PROC
        ; action is in dx
        cmp     vdu , MONO      ;  if mono vdu no border
        je      short vsb2
        mov     ah , 10H        ; function 10H
        cmp     dx , 1          ; is it 1 ( save )
        jne     short vsb1

        mov     al , 8          ; sub function 8 get border colour
        int     10H
        mov     old_border_col , bh
        jmp     short  vsb2
vsb1:
        cmp     dx , 2          ; is it 2 ( restore )
        jne     short vsb2      ; exit if not

        mov     al , 1          ; sub function 1 set border colour
        mov     bh , old_border_col
        int     10H
vsb2:
        ret
VsBorder        ENDP
         
;------------------------------------------------------------------------------;
;                                                                              ;
;                This alters the overscan colour.                              ;
;                                                                              ;
;------------------------------------------------------------------------------;
_VsBorderCol	PROC
        push    bp
        mov     bp , sp

        cmp     vdu , MONO      ;  if mono vdu no bordercol
        je      short vsbcol1

        mov     ax , ARG_1
        mov     bh , al         ; set bh to colour
        mov     ah , 10H        ; function 10H
        mov     al , 1          ; sub function 1 set border colour
        int     10H
vsbcol1:
        pop     bp
        ret
_VsBorderCol    ENDP
		END
