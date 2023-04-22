;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : wncore.asm                                                      ;
;                                                                              ;
;  Description : the central variables, init and exit routines                 ;
;                of the WINDOW module                                          ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void    WnInit( void )                                                       ;
; void    WnExit( void )                                                       ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _WnInit
public  _WnExit
;        SetupVideo

extrn   _WnKillAll:near
extrn   _CursorHide:near
extrn   _DvInit:near
extrn   _InitMouse:near
extrn   CursorSave:near
extrn   SetVideoMode:near
extrn   GetVideoData:near
extrn   CursorRestore:near
extrn   OldScreen:near
extrn   VsBorder:near
extrn   GetVideoConfig:near
extrn   GetVideoData:near
extrn   GetScreenSeg:near
extrn   _in_dv:word


;
; All Variables in this module. Publics are marked as such.
;
public  _hide_cursor    ; hide the cursor off screen ?
public  _save_screen    ; save the screen and cursor at the programmes entry ?
public  _video_method   ; method of screen writes
public  _snow_free      ; do we use snow free on a CGA ?
public  _col_shadow     ; use colour shadowing if colour is available ?
public  _background     ; use old screen as background ?
public  _mode_change    ; do we change to a colour mode if available
public  _mono_attr      ; use mono attributes on a colour system
public  _shadow_char    ; character to use for shadow
public  _shadow_fgc     ; character fgc
public  _shadow_bgc     ; character fgc
public  _shadow_type    ; where the shadow sits
public  _border_type    ; default border type
public  _first_win      ; pointer to first window in linked list
public  _last_win       ; pointer to last window in linked list
public	_active_win
public  _activated_win  ; is there a window activated at present ?
public  _active_win_attr; fg colour to use
public  old_prev
public  old_next

public  _adapter        ; active video adapter
public  _active_adapter         ; active video adapter
public  _inactive_adapter       ; inactive video adapter
public  _active_screen          ; active video screen
public  _inactive_screen        ; inactive video screen
public  _mode           ; current video mode
public  _old_mode       ; holds the video mode current at prog entry
public  _vdu            ; checked by MakeAttr to do attributes
public  _old_screen     ; an area to save the old screen
public  _base_screen    ; an area to assemble the windows on
public  _vpage          ; holds the current video page
public  _old_vpage      ; holds the video page current at prog entry
public  _mod_flag       ; has anything visible changed ?
public  _no_wins        ; number of windows
public  _vsfiller       ; background filler default = WHITE on BLACK space
public  _DISP_addr      ; address of display buffer.

.DATA

_DISP_addr              DW 0B000H  ; address of display memory ( default B & W )
_adapter                DW 0       ; active video adapter
_active_adapter         DW 0       ; active video adapter
_inactive_adapter       DW 0       ; inactive video adapter
_active_screen          DW 0       ; active video screen
_inactive_screen        DW 0       ; inactive video screen
_hide_cursor            DW TRUE    ; hide the cursor off screen ?
_save_screen    DW TRUE    ; save the screen and cursor at the programmes entry
_video_method   DW DMA     ; method of screen writes ( DMA )
_snow_free      DW TRUE    ; do we do snow free on CGA only ??
_col_shadow     DW TRUE    ; use attribute shadowing if colour is available ?
_background     DW FALSE   ; is the old_screen to be used as a background
_mode_change    DW TRUE    ; can we try for a colour text mode ?
_mono_attr      DW FALSE   ; use mono_attributes ??
_vsfiller       DW 0720H   ; WHITE on BLACK ' ' for background
_shadow_char    DB 00B0H   ; coarse block type
_shadow_fgc     DW 0008H   ; grey foreground
_shadow_bgc     DW 0000H   ; black background
_shadow_type    DW 0003H   ; lower right corner
_border_type    DW 0002H   ; single border as default
_first_win      DW 0000H   ; pointer to first window in linked list
_last_win       DW 0000H   ; pointer to last window in linked list
_active_win     DW 0000H   ; pointer to the current active window
_activated_win  DW FALSE   ; was the active window activated ?
_active_win_attr        DW 0FH
old_prev        DW 0
old_next        DW 0

.DATA?

_old_screen     DW 2000 dup (?)    ; an area to save the old screen
_base_screen    DW 2000 dup (?)    ; an area to assemble the windows on
_vpage          DW ?       ; holds the current video page
_old_vpage      DW ?       ; holds the video page current at prog entry
_vdu            DW ?       ; what VDU for attribute mapping
_mode           DW ?       ; current video mode
_old_mode       DW ?       ; holds the video mode current at prog entry
_mod_flag       DW ?       ; has anything visible changed ?
_no_wins        DW ?       ; number of windows

.CODE
;------------------------------------------------------------------------------;
;                                                                              ;
;               Initialises the WINDOWs module.                                ;
;                   void WnInit( void )                                        ;
; WARNING : If this function isnt called first NOTHING will work !!!!!!        ;
;------------------------------------------------------------------------------;
_WnInit    PROC
        call    near ptr _DvInit        ; see if under DESQview
        call    near ptr _InitMouse     ; see if there is a mouse
        call    near ptr SetupVideo     ; set up video variables
        mov     first_win  , 0          ; first_win  = ( WINDOW *)NULL
        mov     last_win  , 0           ; last_win  = ( WINDOW *)NULL
        mov     no_wins , 0             ; no_wins = 0
        mov     mod_flag , TRUE         ; mod_flag = TRUE;
        ret
_WnInit    ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
;       Exits the WINDOWs module and tidies up afterwards.                     ;
;                   void WnExit( void )                                        ;
; WARNING : Do this last or else who knows what might happen !!!!              ;
;------------------------------------------------------------------------------;
_WnExit    PROC
        call    near ptr _WnKillAll     ; Release all memory
        mov     ax , old_mode           ; compare old and new
        cmp     mode , ax
        je      short exit_win1         ; only change if they are different
        call    near ptr SetVideoMode
exit_win1:
        mov     ax , old_vpage          ; compare old and new
        cmp     vpage , ax
        je      short exit_win2         ; only change if they are different
        mov     ah , 5
        int     10H
        jmp     short exit_win4         ; no need to restore old screen
exit_win2:
        cmp     save_screen , FALSE;    ; do we restore old screen
        je      short exit_win3         ; no jump
	call	near ptr GetVideoData	; update mode variable for OldScreen
        call    near ptr CursorRestore  ; restore old cursor
        mov     ax , 2
        push    ax
        call    near ptr OldScreen      ; restore old screen
        pop     ax
        jmp     short exit_win4         ; exit
exit_win3:
        mov     ax , old_mode           ; resetting the mode again does a CLS
        call    near ptr SetVideoMode   ; and homes the cursor
exit_win4:
        mov     dx , 2
        call    near ptr VsBorder       ; restore border colour
        ret
_WnExit    ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
;          Set up the video environment.                                       ;
;                                                                              ;
;------------------------------------------------------------------------------;
SetupVideo	PROC
        call    near ptr GetVideoConfig ; set adapter global variables.
	call	near ptr GetVideoData	; set mode and old_page global

        mov     cx , mode
        mov     old_mode , cx           ; save old mode
        mov     vdu , cx                ; set vdu

        cmp     active_adapter , HGC
        jb      short set_vid1          ; if any hercules graphics card
        mov     bx , MDA                ; is found then change adapter to MDA
        jmp     short set_vid2
set_vid1:
        mov     bx , _active_adapter
set_vid2:
        mov     adapter , bx

        cmp     bx , MDA                ; is it an MDA
        je      short set_vid4          ; only one page so nothing to change

        cmp     in_dv , TRUE            ; are we in DESQview
        jne     short set_vid2a         ; no - jump past next bit
        mov     video_method , DMA      ; force DMA writes.
        jmp     short set_vid3
set_vid2a:
        cmp     snow_free , TRUE        ; does user want snow free screen writes
        jne     short set_vid3          ; no - nothing to change
        cmp     bx , CGA                ; snow free on CGA only allowed
        jne     short set_vid3          ; no - nothing to change
        cmp     video_method , DMA      ; are going direct ?
        jne     short set_vid3          ; no - nothing to change
        mov     video_method , NO_SNOW  ; yes - change method to snow free
set_vid3:
        mov     ax , vpage
        mov     old_vpage , ax
        or      ax , ax                 ; are we on page 0 ??
        jz      short set_vid4          ; yes - no need to change it.
        mov     ax , 0500H              ; function 5 page 0
        int     10H                     ; call bios
        jmp     short set_vid8          ; no need to save screen either
set_vid4:
        cmp     cx , CO80               ; is it any colour TEXT mode ?
        jbe     short set_vid5          ; then we can continue
        cmp     cx , MONO               ; is it mono TEXT mode ?
        je      short set_vid5          ; then we can also continue
        jmp     short set_vid8          ; else its graphics - dont save.
set_vid5:
        cmp     background , FALSE      ; old screen as background ?
        je      short set_vid6          ; no - test for save screen
        cmp     cx , BW80               ; yes - is it an 80 column TEXT mode ?
        jae     short set_vid7          ; yes - then use it - jump to save.
        mov     background , FALSE      ; no - then we cant use it as background
        jmp     short set_vid6          ; so stop it being used!!
set_vid6:
        cmp     save_screen , FALSE     ; check if we have to save it
        je      short set_vid8          ; no - carry on
set_vid7:                               ; save for use as background enters here

        push    cx                      ; save mode
        call    near ptr CursorSave     ; save old cursor position
        mov     ax , 1
        push    ax                      ; push SAVE
        call    near ptr OldScreen      ; call oldscreen
        inc     sp
        inc     sp
        pop     cx                      ; restore mode
set_vid8:
        cmp     adapter , MDA           ; is it an MDA ?
        je      short set_vid10         ; only change attribute shadowing.
        cmp     mode_change , TRUE      ; are we allowed to change mode ?
        je      short set_vid9          ; yes - jump
        cmp     cx , MONO               ; leave if its MONO mode.
        je      short set_vid10         ; but change attribute shadowing
        cmp     cx , BW80               ; is it B & W 80 x 25 text ?
        je      short set_vid11         ; don't turn off attribute shadowing
set_vid9:
        cmp     cx , CO80               ; is it colour 80 x 25 text ?
        je      short set_vid11         ; no need to change anything.

        mov     ax , CO80               ; try to set mode 3
        call    near ptr SetVideoMode   ; call routine
	call	near ptr GetVideoData	; set globals to new data
        cmp     mode , MONO             ; double check mode was changed.
        jne     short set_vid11
set_vid10:
        mov     col_shadow , FALSE      ; turn off colour shadowing
set_vid11:                              ; this is last because a change of mode
                                        ; will unhide the cursor
        cmp     hide_cursor , FALSE     ; do we hide the cursor ?
        je      short set_vid12         ; no
        call    near ptr _CursorHide    ; hide cursor off the screen
set_vid12:
        call    near ptr GetScreenSeg   ; set _DISP_addr to screen buffer.
set_vid13:
        mov     dx , 1
        call    near ptr VsBorder       ; save border colour
set_vid14:                   
        cmp     mono_attr , TRUE        ; do we set for mono attributes ?
        jne     short set_vid15         ; dont change
        mov     vdu , MONO              ; set vdu for mono
        mov     col_shadow , FALSE      ; turn off colour shadowing too
set_vid15:
        ret
SetupVideo      ENDP
                END
