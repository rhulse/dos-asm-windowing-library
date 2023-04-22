;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : Scroll the WINDOW up or down.                                 ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;    void WnScroll ( WINDOW *ptr , int dir , int start_line , int count )      ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnScroll
extrn	ModLog:near
extrn   BiosSetCursPos:near

.CODE
_WnScroll       PROC
	push	bp
        mov     bp , sp
        push    si
	push	di

        mov     si , ARG_1
        mov     cx , [si].W_WID ; int wid = ptr -> wid;

        mov     ax , ARG_4      ; count *= wid;
        imul    cx
        mov     ARG_4 , ax
        shl     cx , 1
;
;            src_ptr = ptr -> ptr + start_line * wid;
;
        mov     ax , ARG_3
        imul    cx
        add     ax , [si].W_PTR
        mov     bx , ax

        cmp     ARG_2 , 1       ; are we going up ?
        jne     short scroll2   ; no...jump

        mov     di , bx         ; dst_ptr = src_ptr - wid;
        sub     di , cx
        jmp     short scroll3   ; do scroll
scroll2:
;
;             going DOWN  !!
;   src_ptr = ptr -> ptr + start_line * wid  ( bx )  + count - 1;
;
        mov     ax , ARG_4
        shl     ax , 1
        add     ax , 65534
        add     bx , ax
        mov     di , bx         ; dst_ptr = src_ptr + wid;
        add     di , cx
        std                     ; set direction flag on ( dec si & di )
scroll3:
        xchg    bx , si         ; swap source from bx to si

;
;        while ( count-- )
;            *dst_ptr++ = *src_ptr++;  if DF = 0
;            *dst_ptr-- = *src_ptr--;  if DF = 1
;              in di        in si
;
        mov     cx , ARG_4      ; count in dx
        rep     movsw           ; do the transfer
        cld                     ; clear the direction flag

        xchg    bx , si         ; swap WINDOW from bx to si
        cmp     [si].W_OPEN , 0
        je      short scroll4   ; dont change mod_flag

        call    near ptr ModLog
scroll4:
	pop	di
        pop     si
	pop	bp
	ret	
_WnScroll       ENDP
                END
