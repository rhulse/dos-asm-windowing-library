;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description : Kills all windows by closeing and then freeing their memory.  ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                      void   WnKillAll( void )                                ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnKillAll
extrn   _first_win:word
extrn   _WnKill:near

.CODE
_WnKillAll PROC
;
;        while ( first_win  NE (WINDOW *)NULL )
;                WnKill ( first_win  );
;
killall1:
        cmp     first_win  , 0
        je      short killall2
        push    first_win
        call    near ptr _WnKill
        inc     sp
        inc     sp
        jmp     short killall1
killall2:
	ret	
_WnKillAll	ENDP
		END
