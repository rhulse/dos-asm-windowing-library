;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnprint.asm                                                     ;
;                                                                              ;
;  Description : Contains WINDOW function to print at the                      ;
;                    current cursor position.                                  ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;             void    WnPrint ( WINDOW *ptr , char *string )                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

newline EQU     0AH     ; newline character

public  _WnPrint
extrn   _MakeAttr:near
extrn   ModLog:near

.CODE
_WnPrint        PROC
        push    bp
        mov     bp , sp
        push    di
        push    si

        mov     bx , ARG_1      ; WINDOW *ptr
	mov	si , ARG_2	; move string ptr into si.

        push    [bx].W_BGC
        push    [bx].W_FGC
        call    near ptr _MakeAttr
        add     sp , 4
        mov     ah , al         ; mov attribute into ah for loop
        mov     cx , [bx].W_CURSX
        mov     dx , [bx].W_CURSY
print1:
;          cursor = ( ptr -> ptr ) + ( cursy * ( ptr -> wid ) ) + cursx
        push    ax              ; save attribute
        push    cx              ; and cursx
        mov     ax , dx
        mov     cx , [bx].W_WID
        imul    cl
        shl     ax , 1
        mov     di , [bx].W_PTR
        add     di , ax
        pop     cx              ; restore cursx
        mov     ax , cx
        shl     ax , 1
        add     di , ax
        pop     ax              ; restore attribute
print2:
        lodsb                   ; mov char into al
        or      al , al         ; is it \0
        jz      short print4
        cmp     al , newline    ; it a \n
        je      short print3
        stosw                   ; mov ax into [di]
        inc     cx              ; cursx ++
        cmp     cx , [bx].W_WID
        jl      short print2
        xor     cx , cx
        inc     dx
        cmp     dx , [bx].W_HGT
        jl      short print2
        xor     dx , dx
        jmp     short print1    ; wrap around so update destination pointer
print3:
        xor     cx , cx         ; routine for newline
        inc     dx
        cmp     dx , [bx].W_HGT
        jl      short print1
        xor     dx , dx
        jmp     short print1
print4:
        mov     [bx].W_CURSX , cx
        mov     [bx].W_CURSY , dx
        cmp     [bx].W_OPEN , FALSE     ; if the window is not open
        je      short print_end         ; jump
	xchg	si , bx 		; modlog requires WINDOW ptr in si
        call    near ptr ModLog
print_end:
	pop	si
        pop     di
        pop     bp
	ret	
_WnPrint        ENDP
                END
