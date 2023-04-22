;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : scrcore.asm                                                     ;
;                                                                              ;
;  Description : the central variables, and initialisation routines            ;
;                of the SCREEN module                                          ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void    InitScreen( void )                                                   ;
; void    ExitScreen( void )                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include screen.inc
include window.inc
;
;       Public functions ( to C or ASM )
;
public  _InitScreen
public  _ExitScreen
public  _GetVideoMode
public  _SetVideoMode
;
;       Public Data
;
public  _base_screen    ; an area to assemble the windows on
public  vsfiller       ; background filler default = WHITE on BLACK space
public  _DISP_addr      ; address of display buffer.

.DATA?
;
;       data structure for the video configuration at the programmes entry
;
OLD_VDATA       STRUC
ram_addr        DW      ?
mode            DW      ?
vpage           DW      ?
curs_pos        DW      ?
curs_size       DW      ?
numlines        DW      ?
numcols         DW      ?
OLD_VDATA       ENDS
;
;       data structure for the current video configuration
;
NEW_VDATA       STRUC
ram_addr        DW      ?
mode            DW      ?
vpage           DW      ?
curs_pos        DW      ?
curs_size       DW      ?
numlines        DW      ?
numcols         DW      ?
NEW_VDATA       ENDS

;
;       All Variables in this the screen module. These are all private
;       but they can be accessed via the appropriate functions.
;
.DATA
;
;       Hardware variables
;
active_adapter          DW 0       ; active video adapter
inactive_adapter        DW 0       ; inactive video adapter
active_screen           DW 0       ; active video screen
inactive_screen         DW 0       ; inactive video screen
port_address            DW 0       ; address to check for retrace
;
;       Init control variables
;
save_old_screen         DW TRUE    ; save the old screen and cursor
hide_cursor             DW TRUE    ; hide the cursor off screen ?
try_colour_mode         DW TRUE    ; can we try for a colour text mode ?
mono_attr               DW FALSE   ; force use of mono attributes ??
;
;       Misc variable..best set at INIT but can change any time
;
video_method            DW DMA     ; method of screen writes ( DMA )
desktop                 DW ON      ; the desktop type OFF / ON / POPUP
desktop_fill            DW 0720H   ; default is WHITE on BLACK ' '

.DATA?

_old_screen     DW 2000 dup (?)    ; an area to save the old screen
_screen_buffer  DW 2000 dup (?)    ; an area to assemble the windows on
.CODE
;------------------------------------------------------------------------------;
;                                                                              ;
;          Set up the video environment.                                       ;
;                                                                              ;
;------------------------------------------------------------------------------;
_InitScreen      PROC
        call    near ptr GetVideoConfig ; set adapter global variables.
        call    near ptr GetVideoData   ; set mode and old_page global

        mov     cx , mode
        mov     old_mode , cx           ; save old mode
        mov     vdu , cx                ; set vdu

        cmp     active_adapter , HGC
        jb      short init_scr1         ; if any hercules graphics card
        mov     bx , MDA                ; is found then change adapter to MDA
        jmp     short init_scr2
init_scr1:
        mov     bx , _active_adapter
init_scr2:
        mov     adapter , bx

        cmp     bx , MDA                ; is it an MDA
        je      short init_scr4         ; only one page so nothing to change

        cmp     in_dv , TRUE            ; are we in DESQview
        jne     short init_scr2a        ; no - jump past next bit
        mov     video_method , DMA      ; force DMA writes.
        jmp     short init_scr3
init_scr2a:
        cmp     snow_free , TRUE        ; does user want snow free screen writes
        jne     short init_scr3         ; no - nothing to change
        cmp     bx , CGA                ; snow free on CGA only allowed
        jne     short init_scr3         ; no - nothing to change
        cmp     video_method , DMA      ; are going direct ?
        jne     short init_scr3         ; no - nothing to change
        mov     video_method , NO_SNOW  ; yes - change method to snow free
init_scr3:
        mov     ax , vpage
        mov     old_vpage , ax
        or      ax , ax                 ; are we on page 0 ??
        jz      short init_scr4         ; yes - no need to change it.
        mov     ax , 0500H              ; function 5 page 0
        int     10H                     ; call bios
        jmp     short init_scr8         ; no need to save screen either
init_scr4:
        cmp     cx , CO80               ; is it any colour TEXT mode ?
        jbe     short init_scr5         ; then we can continue
        cmp     cx , MONO               ; is it mono TEXT mode ?
        je      short init_scr5         ; then we can also continue
        jmp     short init_scr8         ; else its graphics - dont save.
init_scr5:
        cmp     background , FALSE      ; old screen as background ?
        je      short init_scr6         ; no - test for save screen
        cmp     cx , BW80               ; yes - is it an 80 column TEXT mode ?
        jae     short init_scr7         ; yes - then use it - jump to save.
        mov     background , FALSE      ; no - then we cant use it as background
        jmp     short init_scr6         ; so stop it being used!!
init_scr6:
        cmp     save_screen , FALSE     ; check if we have to save it
        je      short init_scr8         ; no - carry on
init_scr7:                              ; save for use as background enters here

        push    cx                      ; save mode
        call    near ptr CursorSave     ; save old cursor position
        mov     ax , 1
        push    ax                      ; push SAVE
        call    near ptr OldScreen      ; call oldscreen
        inc     sp
        inc     sp
        pop     cx                      ; restore mode
init_scr8:
        cmp     adapter , MDA           ; is it an MDA ?
        je      short init_scr10        ; only change attribute shadowing.
        cmp     mode_change , TRUE      ; are we allowed to change mode ?
        je      short init_scr9         ; yes - jump
        cmp     cx , MONO               ; leave if its MONO mode.
        je      short init_scr10        ; but change attribute shadowing
        cmp     cx , BW80               ; is it B & W 80 x 25 text ?
        je      short init_scr11        ; don't turn off attribute shadowing
init_scr9:
        cmp     cx , CO80               ; is it colour 80 x 25 text ?
        je      short init_scr11        ; no need to change anything.

        mov     ax , CO80               ; try to set mode 3
        call    near ptr SetVideoMode   ; call routine
        call    near ptr GetVideoData   ; set globals to new data
        cmp     mode , MONO             ; double check mode was changed.
        jne     short init_scr11
init_scr10:
        mov     col_shadow , FALSE      ; turn off colour shadowing
init_scr11:                             ; this is last because a change of mode
                                        ; will unhide the cursor
        cmp     hide_cursor , FALSE     ; do we hide the cursor ?
        je      short init_scr12        ; no
        call    near ptr _CursorHide    ; hide cursor off the screen
init_scr12:
        call    near ptr GetScreenSeg   ; set _DISP_addr to screen buffer.
init_scr13:
        mov     dx , 1
        call    near ptr VsBorder       ; save border colour
init_scr14:
        cmp     mono_attr , TRUE        ; do we set for mono attributes ?
        jne     short init_scr15        ; dont change
        mov     vdu , MONO              ; set vdu for mono
        mov     col_shadow , FALSE      ; turn off colour shadowing too
init_scr15:
        ret
_InitScreen     ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;       Exits the SCREEN module and tidies up afterwards.                      ;
;                                                                              ;
; WARNING : Do this last or else who knows what might happen !!!!              ;
;------------------------------------------------------------------------------;
_ExitScreen     PROC
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
_ExitScreen     ENDP
;------------------------------------------------------------------------------;
;    Gets data on video systems and displays.                                  ;
; Look for the various video subsytems using various subroutines whose         ;
; addresses are tabulated in TestSequence each subroutine sets flags to        ;
; indicate whether subsequent subroutines need to be called.                   ;
;------------------------------------------------------------------------------;
GetVideoConfig	PROC
        push    bp
        push    si

        mov     cx , OFFSET DGROUP:NumberOfTests
        mov     si , OFFSET DGROUP:TestSequence
vidcon1:
        lodsb                           ; AL = flag
        test    al , al
        lodsw                           ; AX = subroutine address
        jz      short vidcon2           ; skip subroutine if flag is FALSE

        push    si
        push    cx
        call    ax                      ; call subroutine
        pop     cx
        pop     si
vidcon2:
        loop    vidcon1

        call    FindActive              ; determine which subsystem is active

        pop     si                      ; exit routine
        pop     bp
        ret
GetVideoConfig ENDP

;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
; This calls int 10H func 1AH to determine the video bios combination code     ;
; ( DCC ) for each present video subsystem                                     ;
;------------------------------------------------------------------------------;
FindPS2 	PROC
        mov     ax , 1A00H
        int     10H
        cmp     al , 1AH
        jne     short find_ps4  ; exit if not supported ie. no VGA or MCGA

; convert BIOS DCCs into specific subsystems & displays

        mov     cx , bx
        xor     bh , bh                 ; BX = DCC for active subsystem
        or      ch , ch
        jz      short find_ps1          ; jump if only one subsystem present

        mov     bl , ch                 ; BX = inactive DCC
        add     bx , bx
        mov     ax , [bx + OFFSET DGROUP: DCCTable]

        mov     inactive_adapter , al
        mov     inactive_screen , ah

        mov     bl , cl
        xor     bh , bh                 ; BX = active DCC
find_ps1:
        add     bx , bx
        mov     ax , [bx + OFFSET DGROUP: DCCTable]

        mov     active_adapter , al
        mov     active_screen , ah

; reset flags for subsystems that have been ruled out

        mov     byte ptr EGAFlag , FALSE
        mov     byte ptr CGAFlag , FALSE

        cmp     active_screen , MDA     ; if there is an MDA present then
        jne     short find_ps2          ; a hercules card cant be ruled out
        mov     active_screen , 0       ; reset data
        mov     active_adapter , 0
        jmp     short find_ps4  ; dont reset flag.
find_ps2:
        cmp     inactive_screen , MDA   ; same as above
        jne     short find_ps3  ;
        mov     inactive_screen , 0
        mov     inactive_adapter , 0
        jmp     short find_ps4  ; dont reset flag.
find_ps3:
        mov     byte ptr MonoFlag , FALSE
find_ps4:
        ret

FindPS2         ENDP

;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
; Look for an EGA . This is done by calling an EGA BIOS function that          ;
; doesn't exist in the default ( CGA , MDA ) BIOS                              ;
; caller: ah = flags                                                           ;
; returns: ah = flags                                                          ;
; VideoOType & display updated                                                 ;
;------------------------------------------------------------------------------;
FindEGA 	PROC
        mov     bl , 10H                ; subfunction 10h ( return EGA info )
        mov     ah , 12H                ; function number
        int     10H                     ; call BIOS for info
                                        ; if not present then BL != 10H
                                        ; CL = switch setting
        cmp     bl , 10H
        je      short find_ega2         ; jump if no EGA

        mov     al , cl
        shr     al , 1                  ; check switches / 2
        mov     bx , OFFSET DGROUP: EGADisplays
        xlat                            ; determine type from switches
        mov     ah , al                 ; AH = display type
        mov     al , EGA                ; AL = Card type
        call    FoundDevice

        cmp     ah , MDA_display
        je      short find_ega1         ; jump if EGA has MONO monitor
        mov     byte ptr CGAFlag , FALSE; no CGA if EGA has colour display
        jmp     short find_ega2
find_ega1:
        mov     byte ptr MonoFlag , FALSE       ; EGA has a mono display so
                                                ; MDA and HERC ruled out
find_ega2:
        ret

FindEGA         ENDP
;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
; FindCGA is done by looking for the CGA's 6845 CRTC at I/O port 3D4H.         ;
;                                                                              ;
;------------------------------------------------------------------------------;
FindCGA 	PROC

        mov     dx , 3D4H               ; DX = CRTC address port
        call    Find6845
        jc      short find_cga1         ; jump if not present

        mov     al , CGA
        mov     ah , CGA_display
        call    FoundDevice
find_cga1:
        ret
FindCGA         ENDP

;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
;                                                                              ;
;                                                                              ;
;  This is done by looking for the MDA 6845 CRTC at I/O port 3B4H  .           ;
; If a 6845 is found , the subroutine distinguishes between an MDA             ;
; and A HERC card by monitoring bit 7 of the CRT status byte.                  ;
; This bit chinges on HERC adapters only . HERC cards are identified by        ;
; bits 4 - 6 of the CRT Status Value : 001B = HGC+                             ;
;                                      101B = HGC InColor card                 ;
; returns with variables updated                                               ;
;------------------------------------------------------------------------------;
FindMono	PROC
        mov     dx , 3B4H               ; DX = CRTC address port
        call    Find6845
        jc      short find_m4

        mov     dl ,0BAH                ; DX = 3BAH ( status port )
        in      al , dx
        and     al , 80H
        mov     ah , al                 ; AH = bit 7 ( vertical sync on HGC )
        mov     cx , 8000H              ; do this 32768 times !!!
find_m1:
        in      al , dx
        and     al , 80H                ; isolate bit 7
        cmp     ah , al
        loope   short find_m1           ; wait for bit 7 to change
        jne     short find_m2           ; if bit 7 changes its a Hercules

        mov     al , MDA                ; if bit 7 didn't change its an MDA
        mov     ah , MDA_display
        call    FoundDevice
        jmp     short find_m4
find_m2:
        in      al , dx
        mov     dl , al                 ; DL = value from status port
        and     dl , 01110000B          ; mask off bits 4 - 6

        mov     ah , MDA_display        ; assume a mono display

        mov     al , HG_P               ; look for HERC+
        cmp     dl , 00010000B
        je      short find_m3

        mov     al , HG_COL             ; look for an Incolor Card
        mov     ah , EGA_colour
        cmp     dl , 01010000B
        je      short find_m3

        mov     al , HGC                ; must be an HGC
        mov     ah , MDA_display
find_m3:
        call    FoundDevice
find_m4:
        ret

FindMono         ENDP

;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
; This routine detects the precense of the CRTC on an MDA , CGA , or HGC       ;
; the technique is to write to and read register 0FH of the chip               ;
; ( Cursor Location Low ). If the same value is read as writen it assumes      ;
; the chip is present at the specified address                                 ;
; callers: DX = port address                                                   ;
; returns: cf set if not present                                               ;
;------------------------------------------------------------------------------;
Find6845	PROC
        mov     al , 0FH
        out     dx , al                 ; select 6845 register 0FH
        inc     dx

        in      al , dx                 ; get cuurent cursor low value
        mov     ah , al                 ; save in ah
        mov     al , 66H                ; arbitrary value
        out     dx , al                 ; try to write it

        mov     cx , 100H
find_port1:
        loop    find_port1              ; short loop to wait for 6845 to respond

        in      al , dx
        xchg    ah , al                 ; AH = returned value
                                        ; AL = original value
        out     dx , al                 ; restore original value

        cmp     ah , 66H                ; has 6845 responded ?
        je      short find_port2        ; jump if it did.. cf is reset

        stc                             ; set cf if no 6845 present
find_port2:
        ret

Find6845        ENDP

;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
; This routine stores the active data as active_adapter and active_screen.     ;
; The current video mode allways determines which subsystem is active.         ;
;------------------------------------------------------------------------------;
FindActive	PROC

        cmp     inactive_adapter , 0
        je      short  find_ac3         ; exit if only one subsystem

        cmp     active_adapter , 4      ; exit if MCGA or VGA present
        jge     short find_ac3

        cmp     inactive_adapter , 4    ; int 10H / 1aH has already done
        jge     short find_ac3          ; the work

        push    es
        xor     ax , ax                 ; check bios area for mode
        mov     es , ax                 ; segment into es
        mov     al , es:[449H]          ; check location
        pop     es

        and     al , 7
        cmp     al , 7                  ; jump if mono
        je      short find_ac1          ; ( mode 7 or 0FH )

        cmp     active_screen , MDA_display
        jne     short find_ac3          ; exit if display0 is colour
        jmp     short find_ac2
find_ac1:
        cmp     active_screen , MDA_display
        je      short find_ac3          ; exit if active_screen is MONO
find_ac2:
        mov     al , active_screen      ; swap data for 1 and 2
        xchg    al , inactive_screen    ; make active_adapter currently active
        mov     active_screen , al
        mov     ah , active_adapter
        xchg    ah , inactive_adapter
        mov     active_adapter , ah
find_ac3:
        ret

FindActive      ENDP

;------------------------------------------------------------------------------;
;    Subroutine called by GetVideoConfig.                                      ;
; This routine updates the list of subsystems                                  ;
; Caller: ah = display #                                                       ;
;         al = subsystem #                                                     ;
; destroys bx                                                                  ;
;------------------------------------------------------------------------------;
FoundDevice	PROC
        cmp     active_adapter , 0
        jne     short find_d1           ; jump if not first subsystem
        mov     active_screen , ah
        mov     active_adapter , al
        jmp     short find_d2           ; jump if first subsystem
find_d1:
        mov     inactive_screen , ah
        mov     inactive_adapter , al   ; must be second system
find_d2:
        ret
FoundDevice     ENDP

_TEXT           ENDS
;------------------------------------------------------------------------------;
;  Data used by GetVideoConfig.                                                ;
;------------------------------------------------------------------------------;
.DATA
EGADisplays     DB      CGA_display
                DB      EGA_colour
                DB      MDA_display
                DB      CGA_display
                DB      EGA_colour
                DB      MDA_display

DCCTable        DB      0 , 0
                DB      MDA , MDA_display
                DB      CGA , CGA_display
                DB      0 , 0
                DB      EGA , EGA_colour
                DB      EGA , MDA_display
                DB      PGA , PGA_display
                DB      VGA ,  PS2_mono
                DB      VGA ,  PS2_colour
                DB      0 , 0
                DB      MCGA , EGA_colour
                DB      MCGA , PS2_mono
                DB      MCGA , PS2_colour

TestSequence    DB      TRUE            ; all flags set to true
                DW      FindPS2

EGAFlag         DB      TRUE
                DW      FindEGA

CGAFlag         DB      TRUE
                DW      FindCGA

MonoFlag        DB      TRUE
                DW      FindMono

NumberOfTests   EQU     ($-TestSequence) / 3

;------------------------------------------------------------------------------;
;                                                                              ;
;Gets the current video mode and page from the BIOS data area and stores them. ;
;                                                                              ;
;------------------------------------------------------------------------------;

.CODE
GetVideoData	PROC
;
;       adapter data already set at entry
;
        push    es

        xor     ax , ax                 ; check bios area...
        mov     es , ax                 ; segment into es

        mov     al , es:[449H]          ; check mode location
        mov     [OLD_VDATA].mode , ax     ; Set mode  MONO or COLour */

        mov     al , es:[462H]          ; get current page
        mov     [OLD_VDATA].vpage , ax    ; save it

        mov     ax , es:[463H]          ; setup CRTC base address of active card
        add     ax , 6                  ; add 6 to get status register
        mov     port_address , ax       ; save address

        mov     ax , active_adapter
        xor     ah , ah                 ; isolate Herc cards
        cmp     ax , EGA                ; q. does adapter support GT 25 lines ?
        mov     ax , 25                 ; assume 25 lines
        jl      set_lines               ; a. no not ega or better so 25
        mov     ax , es:[484H]          ; get line count
set_lines:
        mov     [OLD_VDATA].numlines , ax ; save line count

        mov     ax , es:[44AH]          ; get column count
        mov     [OLD_VDATA].numcols , ah  ; column count in ahsave line count

        pop     es                      ; restore old es
        ret
GetVideoData	    ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;          Restore the old video environment before exiting.                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
SetVideoMode	    PROC
; mode required is in al
        xor     ah , ah         ; function 0
        int     10H             ; call bios
	ret	
SetVideoMode	ENDP
                END
