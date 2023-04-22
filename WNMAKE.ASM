;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wnmake.asm                                                      ;
;                                                                              ;
;  Description : Makes A Window. Sets up structure and allocate memory.        ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; WINDOW  *WnMake ( int wid , int hgt , int x , int y , int fgc , int bgc )    ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnMake
extrn   _malloc:near
extrn   _AllocError:near
extrn   _MakeAttr:near
extrn   _shadow_char:byte    ; character to use for shadow
extrn   _shadow_fgc:word    ; character fgc
extrn   _shadow_bgc:word    ; character bgc
extrn   _shadow_type:word    ; where the shadow sits
extrn   _border_type:word    ; the default border

.CODE
_WnMake 	PROC
	push	bp
        mov     bp , sp
        push    si
	push	di
;
; ptr = (WINDOW *)malloc ( sizeof ( WINDOW ) + ( wid * hgt * sizeof ( int ) ) );
;
        mov     ax , ARG_1              ; wid
        mov     cx , ARG_2              ; hgt
        cmp     ax , 80                 ; maximun width
        jle     short check_hgt         ; exceeding 80 * 25 causes big
        mov     ax , 80                 ; problems !!!!!!!!!
check_hgt:                              ;
        cmp     cx , 25                 ; maximum hgt
        jle     short size_ok
        mov     cx , 25
size_ok:
        imul    cl
        push    ax                      ; save hgt * wid for later
        shl     ax , 1                  ; * 2
        add     ax , SIZEOF_WINDOW      ; sizeof WINDOW
        push    ax
	call	near ptr _malloc
        inc     sp
        inc     sp
        mov     si , ax                 ; ptr

        or      ax , ax                 ; if ( ptr EQ NULL )
        jne     short alloc_ok
        call    near ptr _AllocError    ; releases all window memory
                                        ; and exits via dos.
alloc_ok:
        mov     [si].W_SELF , si        ; used for checking

        mov     ax , ARG_1              ; si = start of memory block
        mov     [si].W_WID , ax         ; ptr -> wid = wid
        mov     ax , ARG_2
        mov     [si].W_HGT , ax         ; ptr -> hgt = hgt

        mov     ax , ARG_3              
        mov     [si].W_X , ax           ; ptr -> x = x
        mov     ax , ARG_4
        mov     [si].W_Y , ax           ; ptr -> y = y

        mov     ax , ARG_5
        mov     [si].W_FGC , ax         ; ptr -> fgc = fgc
        mov     ax , ARG_6
        mov     [si].W_BGC , ax         ; ptr -> bgc = bgc

        xor     ax , ax                 ; 0 or FALSE

        mov     [si].W_CURSX , ax       ; ptr -> cursx = 0
        mov     [si].W_CURSY , ax       ; ptr -> cursy = 0

        mov     [si].W_COPT , ax        ; ptr -> copt = 0
        mov     [si].W_OPEN , ax        ; ptr -> open = FALSE
        mov     [si].W_HIDE , ax        ; ptr -> hide = FALSE
        mov     [si].W_TITLE , ax       ; ptr -> title = NULL
        mov     [si].W_BDR_CHG , TRUE   ; ptr -> bdr_chg = TRUE

        mov     ax , _border_type       ; ptr -> bdr = border_type
        mov     [si].W_BDR , ax         ; save it

        or      ax , ax                 ; if there is no border , then check
        jnz     short not_too_small     ; to see if the window is too small
        cmp     [si].W_WID , 1          ; is it 1 wide
        jle     short too_small         ; dont do a shadow
        cmp     [si].W_HGT , 1          ; or 1 high
        jg      short not_too_small     ; dont do a shadow
too_small:
        mov     [si].W_SHADCHAR , 32    ; ptr -> shadchar = 0x20
        mov     [si].W_SHADOW , FALSE   ; ptr -> shadow = FALSE
        jmp     short alot_pointer
not_too_small:
        push    _shadow_bgc
        push    _shadow_fgc
        call    near ptr _MakeAttr
        add     sp , 4

        mov     ah , al                 ; save attribute in ah
        mov     al , _shadow_char
        mov     [si].W_SHADCHAR , ax    ; ptr -> shadchar = default settings
        mov     ax , _shadow_type
        mov     [si].W_SHADOW , ax      ; ptr -> shadow = default
alot_pointer:
;
;        ptr -> ptr = (int *)( (int)ptr + (int)sizeof ( WINDOW ) );
;
        mov     ax , si
        add     ax , SIZEOF_WINDOW
        mov     [si].W_PTR , ax
        mov     di , [si].W_PTR         ; screen_ptr = ptr -> ptr;
;
;        attr = MakeAttr ( fgc , bgc ) * 256;
;
        push    ARG_6
        push    ARG_5
	call	near ptr _MakeAttr
        add     sp , 4

        mov     [si].W_BDR_ATTR , ax    ; save current attribute for the border

	mov	ah , al 		; attribute in ah
        mov     al , 32                 ; + ' '
;
;        for ( n = ( hgt * wid ) ; n GT 0 ; n-- )
;
        pop     cx              ; get size of screen off stack
        rep     stosw           ; *screen_ptr++ = ax (attr + ' ')

        mov     ax , si         ; return ( ptr );
        pop     di
	pop	si
        pop     bp
	ret	
_WnMake 	ENDP
		END
