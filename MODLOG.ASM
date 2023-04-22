;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : modlog.asm                                                      ;
;                                                                              ;
;  Description : logs the boundries of changes on the screen.                  ;
;     Internal function used by WINDOW modules.                                ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  ModLog
public  log_start_x
public  log_start_y
public  log_end_x
public  log_end_y
extrn   _mod_flag:word

.DATA

log_start_x    DW      0
log_start_y    DW      0
log_end_x    DW      80       ; set to do whole sceen
log_end_y    DW      25       ; first time through.

.CODE
ModLog	PROC
;
;    at entry si points to the WINDOW structure
;
        push    bp              ; si set to point at WINDOW structure

        mov     ax , [si].W_X   ; ax used for dec checking of shadow types
        mov     bx , [si].W_Y
        mov     cx , [si].W_WID
        mov     dx , [si].W_HGT

        cmp     [si].W_BDR , FALSE ; if there is a border expand to include it
        je      short leave_alone
        dec     ax
        dec     bx
        inc     cx
        inc     cx
        inc     dx
        inc     dx
leave_alone:
        cmp     mod_flag , TRUE
        je      short do_mods
        mov     log_start_x , ax        ; if first time through then set these
        mov     log_start_y , bx        ; to the first WINdows x & y
        mov     log_end_x , ax
        mov     log_end_y , bx
        mov     mod_flag , TRUE
do_mods:
        mov     bp , [si].W_SHADOW      ; if there is a shadow then we have to
        or      bp , bp                 ; expand the size of the log data to
        jnz     short modtype1          ; include its cast.
        jmp     short mod_log1
modtype1:
        inc     cx              ; all shadows require these three.
        inc     cx
        inc     dx

        dec     bp
        jnz     short modtype2
        dec     ax
        dec     ax
        dec     bx
        jmp     short mod_log1
modtype2:
        dec     bp
        jnz     short modtype3
        dec     bx
        jmp     short mod_log1

modtype3:
        dec     bp
        jnz     short modtype4
        jmp     short mod_log1
modtype4:                       ; nothing needed
        dec     bp
        jnz     short mod_log1
        dec     ax
        dec     ax
mod_log1:
        cmp     ax , log_start_x
        jge     short mod_log2
        mov     log_start_x , ax
mod_log2:
        cmp     bx , log_start_y
        jge     short mod_log3
        mov     log_start_y , bx
mod_log3:
        add     cx , ax                 ; add x + WID
        cmp     cx , log_end_x
        jle     short mod_log4
        mov     log_end_x , cx
mod_log4:
        add     dx , bx                 ; add y + HGT
        cmp     dx , log_end_y
        jle     short mod_log_end
        mov     log_end_y , dx
mod_log_end:
;        mov     log_start_x , 0         ; debugging
;        mov     log_start_y , 0
;        mov     log_end_x , 80
;        mov     log_end_y , 25
        pop     bp
        ret
ModLog		ENDP
		END
