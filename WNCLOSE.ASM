;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnclose.asm                                                     ;
;                                                                              ;
;  Description : WINDOW functions to close a window and remove from linked list;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;  void WnClose ( WINDOW * ptr );                                              ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnClose
public   KClose
extrn   ModLog:near
extrn   _WnDeActivate:near
extrn   _first_win:word
extrn   _last_win:word
extrn   _no_wins:word
extrn   _active_win:word
extrn   old_prev:word
extrn   old_next:word

.CODE
_WnClose	PROC
	push	bp
        mov     bp , sp
	push	si
        mov     si , ARG_1

        cmp     [si].W_OPEN , FALSE     ; if its closed then exit
        je      short close_end

        cmp     si , active_win         ; if active and ...
        jne     short close1
        call    near ptr _WnDeActivate  ; ... open then deactivate first
close1:
        call    near ptr KClose         ; just close it
        call    near ptr ModLog         ; and log the changes
close_end:
	pop	si
	pop	bp
	ret	
_WnClose	ENDP


KClose  PROC
;
;       at entry si points to the window structure.
;
        push    di

        mov     di , [si].W_NEXT        ; on_ptr = ptr -> on_link
        mov     bx , [si].W_PREV        ; back_ptr = ptr -> back_link

        cmp     si , old_prev           ; is it old prev
        jne     short kc1               ; no - jump
        mov     old_prev , bx           ; yes - replace with W_PREV
kc1:
        cmp     si , old_next           ; is it old next
        jne     short kc2               ; no - jump
        mov     old_next , di           ; yes - replace with W_NEXT
kc2:
        or      bx , bx                 ; if ( back_ptr EQ (WINDOW *)NULL )
        jne     short kc3
        mov     first_win  , di         ; first_win  = on_ptr
        jmp     short kc4
kc3:
        mov     [bx].W_NEXT , di        ; else back_ptr -> on_link = on_ptr
kc4:
        or      di , di                 ;if ( on_ptr EQ (WINDOW *)NULL )
        jne     short kc5

        mov     last_win , bx           ; else { last_win = back_ptr }
        mov     active_win , bx         ; previous is now active window too
        push    si
        mov     si , bx
        call    near ptr ModLog         ; log new active window position
        pop     si
        jmp     short kc6
kc5:
        mov     [di].W_PREV , bx        ; on_ptr -> back_link = back_ptr;
kc6:
;        call    near ptr ModLog         ; log old active window position
        mov     [si].W_OPEN , 0         ; ptr -> open = FALSE;
        dec     no_wins                 ; one less window open

        pop     di
        ret
KClose  ENDP
        END
