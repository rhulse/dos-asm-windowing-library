;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnpxya.asm                                                      ;
;                                                                              ;
;  Description : Contains WINDOW function to print at x , y with attributes.   ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void WnPrintxya( WINDOW *ptr, int x, int y, char *string, int fgc, int bgc ) ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnPrintxya
extrn   _WnPrint:near

.CODE
_WnPrintxya     PROC
	push	bp
        mov     bp , sp
	push	si
	push	di
        mov     si , ARG_1
                                        ; save values on the stack
        push    [si].W_CURSX            ; oldx = ptr -> cursx
        push    [si].W_CURSY            ; oldy = ptr -> cursy
        push    [si].W_FGC              ; old_fgc = ptr -> fgc
        push    [si].W_BGC              ; old_bgc = ptr -> bgc

        mov     ax , ARG_2              ; x
        mov     [si].W_CURSX , ax       ; ptr -> cursx = x

        mov     ax , ARG_3              ; y
        mov     [si].W_CURSY , ax       ; ptr -> cursy = y

        mov     ax , ARG_5              ; fgc
        mov     [si].W_FGC , ax         ; ptr -> fgc = fgc

        mov     ax , ARG_6              ; bgc
        mov     [si].W_BGC , ax         ; ptr -> bgc = bgc
;
;        WnPrint ( ptr  ,  string );
;
        push    ARG_4
	push	si
        call    near ptr _WnPrint
        add     sp , 4
                                ; restore values from the stack
        pop     [si].W_BGC      ; ptr -> bgc = old_bgc
        pop     [si].W_FGC      ; ptr -> fgc = old_fgc
        pop     [si].W_CURSY    ; ptr -> cursy = oldy
        pop     [si].W_CURSX    ; ptr -> cursx = oldx

        pop     di
	pop	si
	pop	bp
	ret	
_WnPrintxya     ENDP
                END
