;------------------------------------------------------------------------------;
;                                                                              ;
;    This INCLUDE file contains EQU's to make asm modules easier to read       ;
;                                                                              ;
;------------------------------------------------------------------------------;
; Includes for C file.
;
; #include "window.h"      function and structure declarations.
; #include "keycodes.h"    keycodes returned by ketpress
; #include "easyc.h"       use this to make C code easier to read.
;
;  ENTRY ROUTINE TO USE WINDOW MODULE
;
; These globals tell WnInit what to do. They must be set BEFORE
; WnInit is called. Only video_method can be changed during run-time.
; These are sugested values and are the defaults.ie  no need to enter them
; unless you want to change one to a value other than the ones shown.
;
;  hide_cursor = TRUE;  /* hides the cursor off screen   */
;  save_screen = TRUE;  /* save the screen and cursor at the programmes entry */
;  video_method = DMA;  /* use direct screen writes */
;  snow_free = TRUE;    /* if a CGA is active then do snow free screen writes */
;  shadow_attr = TRUE;  /* use attribute shadowing if colour is available */
;  mode_change = TRUE;  /* if false then use any 80 x 25 text mode */
;                       /* otherwise try for 80 x 25 colour text */
;  mono_attr = FALSE    /* use monochrome attributes on colour system */
;
;  WnInit(); /* set up window module variables */
;            /* MUST be called betore any window functions are called */
;  InitMouse();   /* initialise the mouse if there is one */
;
;       After WnInit the variable `vdu' can be set to a value other than 7
;       to force dof to use monochrome attributes. Use to provide a better
;       display on Laptops.
;
;  EXIT ROUTINE
;
; ExitWindow resets and restores anything that was changed
; in WnInit automatically.
;
;  WnExit();       this must always be the last function in a programme
;
;       If malloc is used the the function AllocError(); can be used
;       to exit the programme if there is an allocation error. This
;       fuction does a proper tidy up before exiting.

;
; WINDOW STRUCTURE ....coresponds with the structure in window.h
;
WINDOW    STRUC

W_WID        DW  ?        ; [reg + 0 ]  width of window
W_HGT        DW  ?        ; [reg + 2 ]  height of window
W_X          DW  ?        ; [reg + 4 ]  x position on screen
W_Y          DW  ?        ; [reg + 6 ]  y position on screen
W_FGC        DW  ?        ; [reg + 8 ]  fg colour of window
W_BGC        DW  ?        ; [reg + 10]  bg colour of window
W_CURSX      DW  ?        ; [reg + 12]  x position of cursor
W_CURSY      DW  ?        ; [reg + 14]  y position of cursor
W_SHADOW     DW  ?        ; [reg + 16]  shadow type
W_SHADCHAR   DW  ?        ; [reg + 18]  shadow character
W_BDR        DW  ?        ; [reg + 20]  border type
W_BDR_ATTR   DW  ?        ; [reg + 22]  colour of border
W_BDR_CHG    DW  ?        ; [reg + 24]  change bdr colour if active
W_OPEN       DW  ?        ; [reg + 26]  window open ???
W_HIDE       DW  ?        ; [reg + 28]  is it hidden ??
W_PREV       DW  ?        ; [reg + 30]  ptr to previous win
W_NEXT       DW  ?        ; [reg + 32]  ptr to next window
W_SELF       DW  ?        ; [reg + 34]  ptr to self for checking
W_COPT       DW  ?        ; [reg + 36]  use this for anything
W_PTR        DW  ?        ; [reg + 38]  ptr to virtual screen
W_TITLE      DW  ?        ; [reg + 40]  the windows title
W_RES        DW  ?        ; [reg + 42]  resource pointer

WINDOW    ENDS

SIZEOF_WINDOW   equ     44
;
; these make the code easier to read
;
ARG_1           equ     word ptr [bp + 4]       ; Argument 1
ARG_2           equ     word ptr [bp + 6]       ; Argument 2
ARG_3           equ     word ptr [bp + 8]       ; Argument 3
ARG_4           equ     word ptr [bp + 10]      ; Argument 4
ARG_5           equ     word ptr [bp + 12]      ; Argument 5
ARG_6           equ     word ptr [bp + 14]      ; Argument 6
VAR_1           equ     word ptr [bp - 2]       ; Variable 1
VAR_2           equ     word ptr [bp - 4]       ; Variable 2
VAR_3           equ     word ptr [bp - 6]       ; Variable 3
VAR_4           equ     word ptr [bp - 8]       ; Variable 4
TRUE            equ     1
FALSE           equ     0
NULL            equ     0
;
; used for the shadow column offsets and data.
;
ONE_LINE        equ     160     ; Length of a line in BYTES !
Offset1         equ     2       ; Offset of ONE column ( 2 bytes )
Offset2         equ     4       ; Offset of TWO columns ( 4 bytes )
Offset3         equ     164     ;
Offset4         equ     156     ;

;
; video adapter definitions
;
MDA     equ     01H     ; Monochrome Display adapter
CGA     equ     02H     ; Colour Graphics Adapter
EGA     equ     03H     ; Enhanced Graphics Adapter
MCGA    equ     04H     ; Memory Controller Gate Array
VGA     equ     05H     ; Video Graphics Array
PGA     equ     06H     ; Pofessional Graphics Adapter
HGC     equ     80H     ; Hercules Graphics Adapter
HG_P    equ     81H     ; Hercules Graphics Plus
HG_COL  equ     82H     ; Hercules Graphics InColour Card
;
; types of video display
;
MDA_display     equ     01H
CGA_display     equ     02H
EGA_colour      equ     03H
PS2_mono        equ     04H
PS2_colour      equ     05H
PGA_display     equ     06H
;
; video adapter mode ....
;
BW40              equ 00H
CO40              equ 01H
BW80              equ 02H
CO80              equ 03H
LORES_4CO         equ 04H
LORES_BW          equ 05H
LORES_2CO         equ 06H
MONO              equ 07H
PCJR_LORES        equ 08H
PCJR_MIDRES       equ 09H
PCJR_HIRES        equ 0AH
EGA_LORES_16CO    equ 0DH
EGA_MIDRES_16CO   equ 0EH
EGA_HIRES_BW      equ 0FH
EGA_HIRES_16CO    equ 10H
VGA_HIRES_2CO     equ 11H
VGA_HIRES_16CO    equ 12H
VGA_LORES_256CO   equ 13H
;
; address of start of video memory
;
MDA_addr        equ     0B000H  ; Start of Monochrome adapter
COL_addr        equ     0B800H  ; Start of a colour adapter
;
; type of screen accesses
;
BIOS            equ     01H  ; Use only bios functions for screen access
NO_SNOW         equ     02H  ; Snow Free direct access
DMA             equ     03H  ; Direct writes to screen memory ( fastest )


old_screen        equ     <OFFSET   DGROUP: _old_screen>
base_screen       equ     <OFFSET   DGROUP: _base_screen>
hide_cursor       equ     <word ptr DGROUP: _hide_cursor>
save_screen       equ     <word ptr DGROUP: _save_screen>
video_method      equ     <word ptr DGROUP: _video_method>
snow_free         equ     <word ptr DGROUP: _snow_free>
mod_flag          equ     <word ptr DGROUP: _mod_flag>
vpage             equ     <word ptr DGROUP: _vpage>
old_vpage         equ     <word ptr DGROUP: _old_vpage>
vdu               equ     <word ptr DGROUP: _vdu>
mode              equ     <word ptr DGROUP: _mode>
old_mode          equ     <word ptr DGROUP: _old_mode>
no_wins           equ     <word ptr DGROUP: _no_wins>
col_shadow        equ     <word ptr DGROUP: _col_shadow>
first_win         equ     <word ptr DGROUP: _first_win>
last_win          equ     <word ptr DGROUP: _last_win>
background        equ     <word ptr DGROUP: _background>
mode_change       equ     <word ptr DGROUP: _mode_change>
mono_attr         equ     <word ptr DGROUP: _mono_attr>
vsfiller          equ     <word ptr DGROUP: _vsfiller>
adapter           equ     <word ptr DGROUP: _adapter>
active_adapter    equ     <byte ptr DGROUP: _active_adapter>
inactive_adapter  equ     <byte ptr DGROUP: _inactive_adapter>
active_screen     equ     <byte ptr DGROUP: _active_screen>
inactive_screen   equ     <byte ptr DGROUP: _inactive_screen>
in_dv             equ     <word ptr DGROUP: _in_dv>
last_win          equ     <word ptr DGROUP: _last_win>
active_win        equ     <word ptr DGROUP: _active_win>
activated_win     equ     <word ptr DGROUP: _activated_win>
active_win_attr   equ     <word ptr DGROUP: _active_win_attr>
inactive_win_attr equ     <word ptr DGROUP: _inactive_win_attr>
;old_prev          equ     word ptr DGROUP: old_prev
;old_next          equ     word ptr DGROUP: old_next
shadow_char       equ     <word ptr DGROUP: _shadow_char>
shadow_attr       equ     <word ptr DGROUP: _shadow_attr>
shadow_type       equ     <word ptr DGROUP: _shadow_type>

; global functions

GLOBAL  C   WnChgAttr : PROC
GLOBAL  C   MakeAttr  : PROC
GLOBAL      ModLog    : PROC



