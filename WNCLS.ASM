;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description :                                                               ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void AllocError ( void );                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
;------------------------------------------------------------------------------;
;                                                                              ;
;  Contains the cls window function.                                           ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnCls
extrn   _MakeAttr:near
extrn   ModLog:near

.CODE
;------------------------------------------------------------------------------;
;                                                                              ;
;    Clears the WINDOW at row start for count y                                ;
;        void    WnCls ( WINDOW *window  ,  int start  ,  int ycount )         ;
;                           + 4              + 6          + 8                  ;
;------------------------------------------------------------------------------;
_WnCls	  PROC
	push	bp
        mov     bp , sp
	push	si
	push	di
        mov     si , ARG_1

        mov     dx , [si].W_WID            ; int xcount = window -> wid;
        mov     di , [si].W_PTR            ; int *ptr = window -> ptr;
        mov     ax , dx
        mov     cx , ARG_2
        imul    cl
        shl     ax , 1
        add     di , ax                 ; ptr += wid * start;
;
;        attr = MakeAttr ( window -> fgc  ,  window -> bgc ) * 256;
;
        push    [si].W_BGC
        push    [si].W_FGC
	call	near ptr _MakeAttr
        add     sp , 4
        mov     ah , al
        mov     al , 32         ; set up an ' ' in the current colour in ax

;
;        while ( ycount-- )
;            for ( n = xcount ; n GT 0 ; n-- )
;       ax =  attribute + ' '
;       cx = holds x & y counts at different points in the loop.
;       dx = xcount from earlier
;       di = destination for ax
;
        mov     cx , ARG_3  ; ycount
cls2:
        push    cx                      ; push y count
        mov     cx , dx                 ; xcount
        rep     stosw                   ; do a row
        pop     cx                      ; pop y count
        loop    short cls2              ; dec ycount..loop if not 0....
cls3:
        cmp     [si].W_OPEN , 0            ; if its not open
        je      short cls4              ; jump
        call    near ptr ModLog
cls4:
        pop     di
	pop	si
	pop	bp
	ret	
_WnCls	ENDP

	END


