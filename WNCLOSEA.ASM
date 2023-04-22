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
;  Contains WnCloseAll window functions.                                       ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnCloseAll
extrn   _first_win:word
extrn   _WnClose:near


.CODE

;------------------------------------------------------------------------------;
;                                                                              ;
;                         Closes All windows.                                  ;
;                      void   WnCloseAll  ( void )                             ;
;                                                                              ;
;------------------------------------------------------------------------------;
_WnCloseAll	PROC
;
;        while ( first_win  NE (WINDOW *)NULL )
;                WnClose ( first_win  );
;
closeall1:
        cmp     first_win  , 0
        je      short closeall2
        push    first_win
        call    near ptr _WnClose
        inc     sp
        inc     sp
        jmp     short closeall1
closeall2:
	ret	
_WnCloseAll	ENDP

		END

