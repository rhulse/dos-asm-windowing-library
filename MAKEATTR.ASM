;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : makeattr.asm                                                    ;
;                                                                              ;
;  Description : WINDOW function to make an attribute from a FGC and BGC       ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;              int MakeAttr ( int fgc , int bgc )                              ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public	_MakeAttr
extrn   _vdu:word

.CODE

_MakeAttr       PROC
        push    bp
        mov     bp , sp

        cmp     vdu , 7         ; do we use mono attributes ?
        jne     short att_col
        cmp     ARG_2 , 0       ; does bgc EQ black ?
        je      short att1      ; yes - jump
        mov     ax , 70H        ; else inverse attribute
        jmp     short att_end
att1:
        cmp     ARG_1 , 8       ; is fgc LT GREY
        jle     short att2      ; jump
        mov     ax , 0AH        ; bright attribute
        jmp     short att_end
att2:
        mov     ax , 2          ; normal attribute
        jmp     short att_end
att_col:
;
;       attr = bgc * 16 + fgc;
;
        mov     ax , ARG_2      ; bgc
        mov     cl , 4
        shl     ax , cl
        add     ax , ARG_1      ; fgc
att_end:
	pop	bp
	ret	
_MakeAttr	ENDP
		END
