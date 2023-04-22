;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnkill.asm                                                      ;
;                                                                              ;
;  Description :  Kills a Window by closing it and freeing its memory.         ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;     void WnKill ( WINDOW *ptr )                                              ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnKill
extrn   _WnClose:near
extrn   _free:near      ; c library function

.CODE
_WnKill 	PROC
	push	bp
        mov     bp , sp

        push    ARG_1
        call    near ptr _WnClose   ; WnClose ( ptr )
        call    near ptr _free          ; free ( ptr )
        inc     sp
        inc     sp

        pop     bp
	ret	
_WnKill 	ENDP
		END
