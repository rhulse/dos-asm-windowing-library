;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : vconfig.asm                                                     ;
;                                                                              ;
;  Description : WINDOW module video configuration functions                   ;
;     Internal functions used by WINDOW modules.                               ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public	 GetVideoConfig
;	 FindPS2
;	 FindEGA
;	 FindCGA
;        FindMono
;        Find6845
;	 FindActive
;	 FoundDevice
public	 GetVideoData
public	 SetVideoMode
public   port_address   ; address to check for retrace
extrn    _mode:word
extrn    _vpage:word
extrn    _inactive_adapter:word
extrn    _active_adapter:word
extrn    _active_screen:word
extrn    _inactive_screen:word

.CODE
;------------------------------------------------------------------------------;
;    Gets data on video systems and displays.                                  ;
; look for the various video subsytems using various subroutines whose         ;
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

port_address    DW      0       ; address to check for retrace

.CODE
GetVideoData	PROC
        push    es

        xor     ax , ax
        mov     es , ax         ; check bios area for mode .. segment into es

	mov	al , es:[449H]	; check location
        mov     mode , ax       ; Set mode  MONO or COLour */

	mov	al , es:[462H]	; get current page
        mov     vpage , ax      ; save it

        mov     ax , es:[463H]          ; setup CRTC base address of active card
        add     ax , 6                  ; add 6 to get status register
        mov     port_address , ax       ; save address

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
