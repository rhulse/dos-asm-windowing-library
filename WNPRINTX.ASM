;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description :      Prints a string at the specified cursor position.        ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void    WnPrintxy ( WINDOW *ptr , int x , int y , char *string )            ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnPrintxy
extrn   _WnPrint:near
extrn   _MakeAttr:near

.CODE
_WnPrintxy      PROC
	push	bp
        mov     bp , sp
	push	si
	push	di
        mov     si , ARG_1
                                        ; save values on the stack
        push    [si].W_CURSX            ; oldx = ptr -> cursx
        push    [si].W_CURSY            ; oldy = ptr -> cursy

        mov     ax , ARG_2              
        mov     [si].W_CURSX , ax       ; ptr -> cursx = x

        mov     ax , ARG_3              
        mov     [si].W_CURSY , ax       ; ptr -> cursy = y

        push    ARG_4                   ; WnPrint ( ptr  ,  string );
	push	si
        call    near ptr _WnPrint
        add     sp , 4
;
;        WnSetCurs ( ptr  ,  oldx  ,  oldy );
;                                       ; restore values from the stack
        pop     [si].W_CURSY            ; oldx
        pop     [si].W_CURSX            ; oldy

        pop     di
	pop	si
	pop	bp
	ret	
_WnPrintxy      ENDP
                END
