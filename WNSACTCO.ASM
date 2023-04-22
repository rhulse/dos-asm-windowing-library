;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : Contains functions to set and return the WINDOW modules       ;
;                Active border colours                                         ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;   void WnSetActColours ( int fgc , int bgc )                                 ;
;   void WnGetActColours ( int *fgc , int *bgc )                               ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnSetActColours
public  _WnGetActColours
extrn   _MakeAttr:near
extrn   _active_win_attr:word

.CODE
_WnSetActColours        PROC
	push	bp
        mov     bp , sp

        push    ARG_2
        push    ARG_1

        call    near ptr _MakeAttr
        add     sp , 4

        mov     active_win_attr , ax
 
	pop	bp
	ret	
_WnSetActColours        ENDP


_WnGetActColours        PROC
	push	bp
        mov     bp , sp

        mov     ax , active_win_attr
        mov     cx , ax

        or      cx , 00F0H
        mov     bx , ARG_2
        mov     WORD PTR [bx] , cx

        mov     cl , 4
        shr     ax , cl
        mov     bx , ARG_1
        mov     WORD PTR [bx] , ax

	pop	bp
	ret	
_WnGetActColours        ENDP
                        END
