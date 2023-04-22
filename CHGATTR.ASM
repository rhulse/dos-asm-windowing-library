;
;  File Name    :       chgattr.asm
;
;  Description  :       Contains WINDOW function to change a window attributes
;
;  C Prototypes :
; void WnChgAttr ( WINDOW *ptr, int x, int y, int fgc, int bgc, int count )
;    Changes the onscreen colours at x , y for a 'count'.
;

.MODEL SMALL

include window.inc

.CODE

WnChgAttr       PROC    C
        ARG     ptr:WORD , x:WORD , y:WORD , fgc:WORD , bgc:WORD , count:WORD
        USES    di , si

        mov     si , ARG_1              ; pointer to window in si
;
;       attr = (char)MakeAttr ( fgc , bgc );
;
        push    ARG_5
        push    ARG_4
        call    MakeAttr
        add     sp , 4
        mov     bl , al                 ; save attribute in bl for later
        mov     cx , ARG_6              ; count in cx

chgattr0:
        or      cx , cx                 ; if count EQ 0 then loop ends
        jz      short chgattr6
;
;       attr_ptr = (char *)( ptr -> ptr ) + 2 * ( ( y * wid ) + x ) + 1;
;
        mov     ax , ARG_3              ; y
        mov     dx , [si].W_WID         ; wid
        imul    dl                      ; * wid
        add     ax , ARG_2              ; + x
        shl     ax , 1                  ; * 2
        mov     di , [si].W_PTR         ; [ ptr
        add     di , ax                 ; + ax ]
        inc     di                      ; + 1...leave in di for later.

        mov     dx , [si].W_WID            ; attr_count = wid - x;
        sub     dx , ARG_2              ; leave in dx for later

chgattr1:
;
;       while ( ( attr_count ) AND ( count ) )
;       bl = attribute
;       cx = count to change
;       dx = attr_count
;       di = attr_ptr
;
chgattr2:
        or      dx , dx
        jz      short chgattr3
        mov     byte ptr [di] , bl      ; *attr_ptr = attr
        inc     di
        inc     di                      ; attr_ptr += 2
        dec     dx                      ; attr_count--
        loop    short chgattr2          ; count-- + cmp cx , 0
chgattr3:
        mov     ARG_2 , 0               ; x = 0;
;
;     y = ( y EQ ( hgt ) ) ? 0 : y + 1
;
        mov     ax , [si].W_HGT
        cmp     ax , ARG_3
        jne     short chgattr5
        mov     ARG_3 , 0
        jmp     short chgattr0
chgattr5:
        inc     ARG_3
        jmp     short chgattr0
chgattr6:
        cmp     [si].W_OPEN , 0         ; if the window is not open
        je      short chgattr7          ; jump
        call    ModLog
chgattr7:
	ret	
WnChgAttr       ENDP
		END
