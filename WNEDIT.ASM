;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : A simple editor..returns TRUE if any changes are made.        ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; int WnEdit ( WINDOW *win , int size , int x , int y , char *buffer )         ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

; Readability helpers
K_BS            equ     0008H
K_ENTER         equ     000DH
K_ESC           equ     001BH
L_ARROW         equ     4B00H
R_ARROW         equ     4D00H
K_DEL           equ     5300H

include window.inc

public  _WnEdit

extrn   _CursorFat:near
extrn	_WnPrintxy:near
extrn	_WnSetCurs:near
extrn	_WnCursOn:near
extrn	_VsDisp:near
extrn	_GetKey:near
extrn   BiosSetCursPos:near
extrn	__ctype:byte	; c library function

.CODE
_WnEdit 	PROC
	push	bp
        mov     bp , sp
        dec     sp
        dec     sp
	push	si
	push	di
;
;        int     loop = TRUE , result = TRUE , n = 0 , z , key;
; no loop variable needed ...
; if loop not needed then key routine jumps to edit_end

        mov     VAR_1 , TRUE
        xor     si , si
        call    near ptr _CursorFat
;
;  while ( loop )
;            WnPrintxy ( win , x , y , buffer );
;
edit0:
        push    ARG_5
        push    ARG_4
        push    ARG_3
        push    ARG_1
        call    near ptr _WnPrintxy
        add     sp , 8
;
;            WnSetCurs ( win , x + n , y );
;
        push    ARG_4
        mov     ax , ARG_3
        add     ax , si
	push	ax
        push    ARG_1
        call    near ptr _WnSetCurs
        add     sp , 6

;
;    WnCursOn ( win );
;
        push    ARG_1
        call    near ptr _WnCursOn
        inc     sp
        inc     sp
;
;            while ( kbhit() EQ 0 )
;                    VsDisp();
;        NB. DOS func 0BH used instead of kbhit.
edit1:
        call    near ptr _VsDisp
        mov     ah , 0Bh
        int     21H
        or      al , al
        je      short edit1
;
;            key = GetKey();
;
	call	near ptr _GetKey
        mov     dx , ax
;
;            switch( key )
;
        mov     cx , 6
        mov     bx , offset KEY_TABLE
edit2:
        mov     ax , word ptr cs:[bx]
        cmp     ax , dx
        je      short edit3
	inc	bx
	inc	bx
        loop    short edit2
        jmp     short edit9
edit3:
        jmp     word ptr cs:[bx + 12]

;------------------------------------------------------------------------

edit_larrow:    ; case L_ARROW : n = ( n ) ? n - 1 : n; break;

        or      si , si
        jne     short edit4
        jmp     edit14
edit4:
        mov     ax , si
	dec	ax
        jmp     edit15


;------------------------------------------------------------------------

edit_rarrow:    ; case R_ARROW : n = ( n LT ( size - 1 ) ) ? n + 1 : n; break;

        mov     ax , ARG_2
	dec	ax
        cmp     ax , si
        jle     short edit7
        jmp     short edit13
edit7:
        jmp     short edit14

;------------------------------------------------------------------------

edit_del:       ; case DEL

        mov     di , si         ; z = n
        mov     cx , ARG_2
        dec     cx
edit8:
        cmp     cx , di
        jge     short edit8@
;
;        while ( z LT ( size - 1 ) )
;            buffer[z++] = buffer[z + 1];
;
        mov     bx , ARG_5
        mov     al , byte ptr [bx + di + 1]
        mov     byte ptr [bx + di] , al
	inc	di
        jmp     short edit8
edit8@:
        mov     bx , ARG_5
        mov     byte ptr [bx + di] , 32 ; buffer[z] = ' ';

        jmp     edit0                   ; break

;------------------------------------------------------------------------

edit_bs:        ; case BS     : if ( n )

        or      si , si                 ; if n = 0
        je      short edit_break        ; jump
;
;       buffer[--n] = ' ';
;
	dec	si
        mov     bx , ARG_5
        mov     byte ptr [bx + si] , 32
edit_break:
        jmp     edit0                   ; break;


;------------------------------------------------------------------------

edit_enter:     ; case ENTER  : buffer[n] = '\0'; loop = FALSE; break;

        mov     bx , ARG_5
        mov     byte ptr [bx + si] , 0

        jmp     short edit_end  ; no need to loop..go to end

;------------------------------------------------------------------------

edit_esc:       ; case ESC    : result = FALSE; break;

        mov     VAR_1 , FALSE
        jmp     short edit_end  ; no need to go to loop test !!

;------------------------------------------------------------------------

edit9:          ; default     : if ( isprint ( key BAND 0x00FF ) )

        mov     bx , dx
        and     bx , 00FFH
        test    byte ptr DGROUP:__ctype[bx + 1] , 87
        jne     short edit10
        jmp     edit0
;
;              key = toupper ( key );
;
edit10:
        test    byte ptr DGROUP:__ctype[bx + 1] , 2     ; is it upper
        je      short edit11    ; yes..jump
        mov     ax , dx         ; else convert to upper
        and     ax , 000FFH
        add     ax , 0FFE0H
        jmp     short edit12
edit11:
        mov     ax , dx
        and     ax , 00FFH
edit12:
        mov     bx , ARG_5
        mov     byte ptr [bx + si] , al         ; buffer[n] = ( char )( key )
;
;       n = ( n LT ( size - 1 ) ) ? n + 1 : n;
;
        mov     ax , ARG_2
	dec	ax
        cmp     ax , si
        jle     short edit14

edit13:
        mov     ax , si
	inc	ax
        jmp     short edit15
edit14:
        mov     ax , si
edit15:
        mov     si , ax         
        jmp     edit0           ; break
edit_end:
;
;    Cursor ( C_HIDE );
;
        mov     dx , 2500H
        call    near ptr BiosSetCursPos
;
;        return ( result );
;
        mov     ax , VAR_1

        pop     di
	pop	si
        mov     sp , bp
	pop	bp
	ret	
_WnEdit         ENDP
        DW      (?)
KEY_TABLE       LABEL   WORD
        DW      K_BS
        DW      K_ENTER
        DW      K_ESC
        DW      L_ARROW
        DW      R_ARROW
        DW      K_DEL
        DW      edit_bs
        DW      edit_enter
        DW      edit_esc
        DW      edit_larrow
        DW      edit_rarrow
        DW      edit_del
	END
