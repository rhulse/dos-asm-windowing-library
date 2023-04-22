;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : vsdisp.asm                                                      ;
;                                                                              ;
;  Description : WINDOW function to assemble and copy virtual screens          ;
;                on to the real screen                                         ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void VsDisp ( void );                                                       ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public	_VsDisp
;        Shadow
;        DmaDisp
;        PointerSet
public   GetScreenSeg
public   OldScreen
;	 NoSnowDisp
;        BiosDisp
;        BiosWriteScreen
;        BiosSaveScreen
;        BiosRestoreScreen
;        SetupBios
;        ResetBios
extrn    BiosSetCursPos:near
extrn    BiosGetCursInfo:near
extrn    BiosSetCurSize:near
extrn    BiosSetCursPos:near
extrn    BiosSetCurSize:near
extrn    DrawBox:near
extrn    _MakeAttr:near
extrn   _mod_flag:word
extrn   _base_screen:word
extrn   _background:word
extrn   _vsfiller:word
extrn   _old_screen:word
extrn   _first_win:word
extrn   _mod_flag:word
extrn   _video_method:word

extrn   _col_shadow:word
extrn   _DISP_addr:word
extrn    log_start_x:word
extrn    log_start_y:word
extrn    log_end_x:word
extrn    log_end_y:word
extrn   _mode:word
extrn    port_address:word
extrn   _in_dv:word
extrn   _active_win:word
extrn   _active_win_attr:word

.CODE
;------------------------------------------------------------------------------;
;                                                                              ;
;  This does the assembling of the screen in memory and copies                 ;
;  to the physical screen                                                      ;
;                                                                              ;
;------------------------------------------------------------------------------;
_VsDisp     PROC
        push    bp              ; used for width of window in words
	push	si
	push	di
	push	es
	push	ds
        mov     bx , SEG DGROUP
	mov	es , bx
	mov	ds , bx

        cmp     mod_flag , FALSE        ; See if anything to do
        jne     short vs_disp1
        jmp     short disp_end          ; If not, leave
vs_disp1:
        mov     di , base_screen
        mov     cx , 2000               ; 2000 words to initialise
        cmp     background , TRUE       ; do we use old screen as a background
        je      short behind            ; yes - do this
        mov     ax , vsfiller           ; else clear with set filler
        rep     stosw                   ;
        jmp     short flag
behind:
        mov     si , old_screen         ; old screen -> base screen
        rep     movsw                   ; fast !!
flag:
        mov     si , first_win          ; Store first win ptr address in si
        mov     mod_flag , FALSE        ; Indicate screen update started
;
; See if ptr at NULL yet
;
merge_loop:
        cmp     si , NULL               ; if the last one then do_active window
	je	short copy_screen	; and then print the screen

        cmp     [si].W_HIDE , TRUE      ; is this one hidden ?
        jne     short carry_on          ; no - carry on !

        mov     bx , [si].W_NEXT        ; yes - load the next one
        mov     si , bx                 ; into si and go round again.
        jmp     merge_loop
carry_on:
        call    near ptr CopyWindow     ; copy it to the virtual screen
        cmp     [si].W_BDR , FALSE      ; do we have to draw a border ?
        je      try_shadow              ; no - try doing a shadow
        call    near ptr DrawBorders
        or      ax , ax                 ; did DrawBorder fail
        jz      dont_shadow             ; cant shadow either
try_shadow:
        cmp     [si].W_SHADOW , FALSE   ; do we shadow ?
        je      dont_shadow             ; no - dont do it
        call    near ptr DrawShadow
dont_shadow:
;
; Get on_link for current window into si
;
next_win:
        xchg    bx , si                 ; swap si and bx
        mov     si , [bx].W_NEXT        ; si = current win -> next.
        jmp     short merge_loop        ; Loop till it hits a NULL
;
; When all screens merged, copy result to real screen
;
copy_screen:
        mov     ax , video_method
        dec     ax                      ; is it bios
        jne     short snow_check        ; no
        call    near ptr BiosDisp       ; yes - call bios routine
        jmp     short disp_end          ; exit
snow_check:
        push    ax
        call    near ptr PointerSet     ; set up pointers for DMA
        pop     ax
        dec     ax                      ; is it NO_SNOW
        jne     short direct            ; no - straight DMA
        call    near ptr NoSnowDisp     ; yes - call no snow routine
        jmp     short disp_end          ; exit
direct:
        call    near ptr DmaDisp        ; DMA - Copy screen fast !!
disp_end:
	pop	ds
	pop	es
	pop	di
	pop	si
	pop	bp
        ret
_VsDisp    ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;    This is called by VsDisp and draws the border and put a title on it.      ;
;                                                                              ;
;------------------------------------------------------------------------------;
DrawBorders     PROC
        push    bp
        mov     ax , [si].W_X
        mov     bx , [si].W_Y
        mov     cx , [si].W_WID
        mov     dx , [si].W_HGT

        cmp     ax , 1                  ; does the window go outside the area
        jl      short dont_draw         ; 1 , 1 to 79 , 24
        cmp     bx , 1                  ; if it does then there is no room 
        jl      short dont_draw         ; for the border to be drawn.
        add     ax , cx
        cmp     ax , 79
        jg     short dont_draw
        add     bx , dx
        cmp     bx , 24
        jg     short dont_draw

        push    cx
        push    dx                      ; save for later

        mov     ax , [si].W_BDR_ATTR
        cmp     si , active_win         ; is it the active window ?
        jne     short no_bcol           ; no - use specified colours
        cmp     [si].W_BDR_CHG , TRUE   ; are we allowed to change the border ?
        jne     short no_bcol           ; no - same again

        shr     ax , 1                  ; move BGC into low byte and loose
        shr     ax , 1                  ; the FGC
        shr     ax , 1
        shr     ax , 1
        push    ax                      ; push the BGC

        xor     al , 0FH                ; clear FGC
        push    _active_win_attr        ; push the active FGC


        call    near ptr _MakeAttr
        add     sp , 4
no_bcol:
        pop     dx                      ; restore
        pop     cx

        push    ax                      ; new attribute

        inc     dx
        inc     dx
        push    dx

        inc     cx
        inc     cx
        push    cx

        mov     ax , [si].W_Y
        dec     ax
        push    ax

        mov     ax , [si].W_X
        dec     ax
        push    ax

        push    [si].W_BDR

        call    near ptr DrawBox
        add     sp , 12

;       call    near ptr DoTitle

        mov     ax , TRUE
        jmp     short was_drawn
dont_draw:
        xor     ax , ax         ; make ax FALSE
was_drawn:
        pop     bp
        ret
DrawBorders     ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
;    This is called by VsDisp and copys the window specified by si to the      ;
;         virtual screen.                                                      ;
;                                                                              ;
;------------------------------------------------------------------------------;
CopyWindow   PROC
        push    bp
;
; Sets es:di to point to the top left corner of the current window
; It restores di at exit.
;
        mov     di , base_screen        ; starting address of base screen
        mov     ax , [si].W_Y           ; y
        mov     cl , 5                  ; Multiply by 160 ONLY !!!
        shl     ax , cl                 ; this way only 38 cycles
        mov     bx , ax                 ; imul would be 128 - 154
        shl     ax , 1
        shl     ax , 1
        add     ax , bx
        mov     bx , [si].W_X           ; x
        shl     bx , 1                  ; x * 2
        add     ax , bx                 ; count from top left
        add     di , ax                 ; above + base_screen address
        push    di                      ; save for later use by shadow routine

        mov     bp , [si].W_WID
        shl     bp , 1                  ; width times 2 for use later
;
; Set up variables for copying one line from virtual to base screen
;  and copy all lines from virtual screens to base screen
;
        mov     bx , [si].W_PTR ; Get window pointer to virtual screen
        mov     cx , [si].W_HGT
        mov     dx , ONE_LINE
        sub     dx , bp         ; set up  amount to subtract to get next line
        xchg    bx , si         ; swap si and bx
        shr     bp , 1          ; restore width to char count
copy_lines:
        mov     ax , bp         ; W_WID
        xchg    cx , ax         ; width in cx ...hgt saved in ax
        rep     movsw           ; do one line
        mov     cx , ax         ; hgt back in cx for loop
        add     di , dx         ; set di to start of next line
        loop    short copy_lines        ; Loop till all lines copied

        xchg    bx , si         ; swap si and bx back again

        pop     di              ; restore start position of window
        pop     bp
        ret
CopyWindow   ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
;    This is called by VsDisp and draws the shadow
;                                                                              ;
;------------------------------------------------------------------------------;
DrawShadow      PROC
        mov     ax , [si].W_X
        mov     bx , [si].W_Y
        mov     cx , [si].W_WID
        mov     dx , [si].W_HGT

        cmp     [si].W_BDR , FALSE
        je      short smaller

        dec     ax
        dec     bx
        inc     cx
        inc     cx
        inc     dx
        inc     dx
smaller:
        push    [si].W_SHADCHAR
        push    dx
        push    cx
        push    bx
        push    ax
        call    near ptr Shadow
        add     sp , 10

        ret
DrawShadow      ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by VsDisp and creates the shadowing effects                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
Shadow	PROC
        push    bp
        mov     bp , sp
        push    di
        push    si

        mov     ax , [si].W_SHADOW      ; get shadow type
        dec     ax                      ; make enumerated from 0
        mov     bx , ax                 ; save a copy

;SHADOW_LIMITS   label word
;                DW  02H  , 01H , 04FH , 18H , type1
;                DW  00H  , 01H , 04CH , 17H , type2
;                DW  00H  , 00H , 04CH , 17H , type3
;                DW  02H  , 00H , 04fH , 18H , type4

        shl     bx , 1          ; *2
        shl     bx , 1          ; *4
        add     bx , ax         ; +1
        shl     bx , 1          ; *2   =  word offset into table

        mov     si , OFFSET DGROUP : SHADOW_LIMITS
        add     si , bx

        lodsw
        cmp     ARG_1 , ax
        jge     short S1
        jmp     goback
S1:
        lodsw
        cmp     ARG_2 , ax
        jge     short S2
        jmp     goback
S2:
        lodsw
        cmp     ARG_3 , ax
        jle     short S3
        jmp     goback
S3:
        lodsw
        cmp     ARG_4 , ax
        jle     short S4
        jmp     goback
S4:
        lodsw
        push    ax

        mov     di , base_screen        ; starting address of base screen
        mov     ax , ARG_2              ; y
        mov     cl , 5                  ; Multiply by 160 ONLY !!!
        shl     ax , cl                 ; this way only 38 cycles
        mov     bx , ax                 ; imul would be 128 - 154
        shl     ax , 1
        shl     ax , 1
        add     ax , bx
        mov     bx , ARG_1              ; x
        shl     bx , 1                  ; x * 2
        add     ax , bx                 ; count from top left
        add     di , ax                 ; above + base_screen address
        mov     bx , di
        pop     ax

        jmp     ax

; works out the starting points of the shadows.
;
; di used as starting point for row x
; bx used as starting point for row y
;
; XXXXXXXXXXX      XXXXXXXXXX  ÚÄÄÄÄÄÄÄÄ¿         ÚÄÄÄÄÄÄÄÄ¿
; XX ÚÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄ¿XX  ³        ³XX    XX ³        ³
; XX ³        ³  ³        ³XX  ³  III   ³XX    XX ³   IV   ³
; XX ³   I    ³  ³  II    ³XX  ÀÄÄÄÄÄÄÄÄÙXX    XX ÀÄÄÄÄÄÄÄÄÙ
;    ÀÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÙ       XXXXXXXXX    XXXXXXXXX
;

type1:
        sub     di , Offset3
        sub     bx , Offset2
        jmp     short make
type2:
        sub     di , Offset4
        mov     ax , ARG_3
        shl     ax , 1
        add     bx , ax
        jmp     short make
type3:
        mov     ax , ARG_3
        shl     ax , 1
        add     bx , ax
        add     bx , ONE_LINE
        mov     ax , ARG_4
        mov     cl , 5                  ; Multiply by 160 ONLY !!!
        shl     ax , cl                 ; this way only 38 cycles
        mov     dx , ax                 ; imul would be 128 - 154
        shl	ax , 1
        shl	ax , 1
        add     ax , dx
        add     ax , Offset2
        add     di , ax                 ; add above to base_screen address
        jmp     short make
type4:
        add     bx , Offset4
        mov     ax , ARG_4              ; Multiply by 160 ONLY !!!
        mov     cl , 5                  ; this way only 38 cycles
        shl     ax , cl                 ; imul would be 128 - 154
        mov     dx , ax                 ;
        shl     ax , 1                  ;
        shl     ax , 1                  ;
        add     ax , dx                 ;
        sub     ax , Offset2            ;
        add     di , ax                 ; add above to base_screen address
make:
        mov     cx , ARG_3              ; these two used in the sub-routines
        mov     ax , ARG_5              ; the shadow character
        cmp     col_shadow , 1          ; colour shadow ?? TRUE ?
        je      short makeatt           ; if its is then jump and call routine

;
;  This routine creates a shadow of characters
;        ie. one of these. ' ' ° ± ² Û
;
sdo_x:
;
;   cx = WID
;   ax = SHADCHAR
;   di = destination start point
;
        rep     stosw
sdo_y:                                  ; row y in bx
        mov     cx , ARG_4              ; Get height
        dec     cx
side:
        mov     word ptr [bx] , ax
        mov     word ptr [bx + Offset1] , ax
        add     bx , ONE_LINE           ; Point di to start of next line
        loop    side                    ; do the shadow on the side
        jmp     short goback
makeatt:
;
; This routine creates a shadow using attribute forcing. It forces the
; fgc and bgc to the selected shadow attribute. It leaves the onscreen
; character alone.
;
attdo_x:
        inc     di              ; inc bx and di to point
        inc     bx              ; to first attrbute.
;
;   cx = WIN_WID
;   ax = WIN_SHADCHAR...  this function ignores character in al
;   di = destination start point
;
attnext:
	mov	byte ptr [di] , ah	; move our attribute to it
        add     di , Offset1
        loop    attnext
attdo_y:                        ; row y in bx
        mov     cx , ARG_4      ; Get height
        dec     cx
attside:
        mov     byte ptr [bx] , ah              ; moves our colour to it
        mov     byte ptr [bx + Offset1] , ah    ; does adjacent word too

        add     bx , ONE_LINE   ; Point di to start of next line
        loop    attside         ; do the shadow on the side
goback:
        pop     si                      ; restore window pointer
        pop     di              ; restore original di.
        pop     bp
        ret                     ; return
Shadow          ENDP

.DATA

SHADOW_LIMITS   DW  02H  , 01H , 04FH , 18H , type1
                DW  00H  , 01H , 04CH , 17H , type2
                DW  00H  , 00H , 04CH , 17H , type3
                DW  02H  , 00H , 04fH , 18H , type4
;               DW  2  , 1 , 79 , 24 , type1
;               DW  0  , 1 , 77 , 23 , type2
;               DW  0  , 0 , 77 , 23 , type3
;               DW  2  , 0 , 79 , 24 , type4

.CODE

;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by VsDisp and sets up pointers for direct screen writes.      ;
;   It calculates the number of WORDS to move.                                 ;
;                                                                              ;
;------------------------------------------------------------------------------;
PointerSet	PROC
; set ds:si and es:di point to source and destination.
; set cx to the number of words per line to do.
; set bx to the number of lines.
; set bp to the number to add to si and di to get to the next line.
        mov     es , _DISP_addr         ; set es to point at screen buffer.

        cmp     log_start_y , 0         ; cant be less than 0
        jg      ps1
        mov     log_start_y , 0
ps1:
        mov     ax , log_start_y        ; set up place to start

        mov     cl , 5                  ; Multiply by 160 ONLY !!!
        shl	ax , cl
        mov	bx , ax
        shl	ax , 1
        shl	ax , 1
        add	ax , bx

        cmp     log_start_x , 0
        jg      ps2
        mov     log_start_x , 0         ; cant be less than 0
ps2:
        mov     bx , log_start_x        ; place to start

        shl     bx , 1
        add     bx , ax
        mov     di , bx

        mov     si , base_screen        ; pointer to base_screen
        add     si , bx                 ; add offset

        cmp     log_end_x , 80          ; set up length of line
        jle     ps3                     ; cant be more than 80 ( 50H )
        mov     log_end_x , 80
ps3:
        mov     cx , log_end_x
        sub     cx , log_start_x

        cmp     log_end_y , 25          ; set up hgt to do
        jle     ps4                     ; cant be more than 25
        mov     log_end_y , 25
ps4:
        mov     bx , log_end_y
        sub     bx , log_start_y

        mov     bp , ONE_LINE
        mov     ax , cx
        shl     ax , 1
        sub     bp , ax

        ret
PointerSet      ENDP
;------------------------------------------------------------------------------;
;  This is called to set up the screen segment in DISP_addr...DESQview aware.  ;
;------------------------------------------------------------------------------;
GetScreenSeg    PROC NEAR
        mov     ax , COL_addr   ; where the screen is !!!
        cmp     mode , MONO     ; leave colour address if not MODE 7.
        jne     short scr_seg1  ; jump if it is not MONO.
        mov     ax , MDA_addr   ; Else set segment for mono screen.
scr_seg1:
        cmp     in_dv , TRUE    ; are we under DESQview ?
        jne     short scr_seg2  ; no then jump.

        push    es              ; save es
        push    di              ; save di
        mov     es , ax         ; segment in es
        xor     di , di         ; clear di to 0000 offset
        mov     ah , 0FEH       ; get buffer function
        int     10H             ; DV steals int 10H !!
        mov     ax , es         ; new segment in ax
        pop     di              ; restore di
        pop     es
scr_seg2:
        mov     _DISP_addr , ax ; move segment into DISP_addr
        ret
GetScreenSeg    ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by VsDisp and does DMA fast screen updates.                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
DmaDisp 	PROC
        xchg    bx , cx
dmadisp1:
        mov     ax , bx         ; width of area to do.
        xchg    cx , ax         ; width in cx ...hgt saved in ax
        rep     movsw           ; do one line
        mov     cx , ax         ; hgt back in cx for loop
        add     di , bp         ; set di to start of next line
        add     si , bp         ; set si to start of next line
        loop    short dmadisp1  ; Loop till all lines copied
        ret
DmaDisp         ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;          Saves or restores the old screen                                    ;
;                                                                              ;
;------------------------------------------------------------------------------;
OldScreen      PROC
        push    bp
	mov	bp , sp
	push	si
	push	di
	push	es
	push	ds

        mov     ax , video_method
        dec     ax
        jnz     short os2
        cmp     ARG_1 , 1       ; is it SAVE
        jne     short os1
        call    near ptr BiosSaveScreen
        jmp     short os_end
os1:
        call    near ptr BiosRestoreScreen
        jmp     short os_end            
os2:                                    ; start DMA routines here by deciding
        call    near ptr GetScreenSeg   ; set _DISP_addr to screen buffer.
os3:
        mov     bx , SEG DGROUP         ; load DGROUP segment into bx
        mov     cx , 2000               ; count to do
        cmp     ARG_1 , 1               ; action is save ?
        jne     short os4

        mov     ds , _DISP_addr          ; Set up ds:si as string source.
        mov     es , bx
        xor     si , si                 ; set di to 0
        mov     di , old_screen         ; pointer to old_screen
        jmp     short os5
os4:
        mov     es , _DISP_addr          ; Set up es:di as string dest.
        mov     ds , bx
        xor     di , di                 ; set di to 0
        mov     si , old_screen         ; pointer to old_screen
os5:
        dec     ax
        jne     short os6
        mov     cx , 80                 ; set up length of line
        mov     bx , 25                 ; set up hgt to do
        xor     bp , bp                 ; add nothing in loop !!!!
        call    near ptr NoSnowDisp
        jmp     short os_end
os6:
        rep     movsw                   ; Copy screen.
os_end:
        pop     ds
	pop	es
	pop	di
	pop	si
	pop	bp
        ret
OldScreen      ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by VsDisp and does CGA snow free screen updates.              ;
;                                                                              ;
;------------------------------------------------------------------------------;
.CONST

BIT_MASK        EQU     1       ; bit mask for test of status register
VBcount         EQU     240     ; count to do in vertical retrace
TIMEOUT         EQU     6       ; timeout for checking retrace

.CODE

NoSnowDisp	PROC
;
; ds:si and es:di point to source and destination
; cx set to the number of words per line to do
; bx the number of lines.
; bp set to the number to add to si and di to get to the next line.
; the set up routine gets the actual status register address. It does NOT assume
; that its a colour card.
;
;
        push    ds                      ; save destination
        mov     ax , SEG DGROUP         ; load segment of dgroup
        mov     ds , ax                 ; ds point to DATA
        mov     dx , port_address       ; port address from SetupVideo
        pop     ds                      ; restore destination

        push    bx              ; push count of lines to do
        push    cx              ; push count of words per line to do
nsd0:
        pop     cx              ; restore count word count
        pop     bx              ; restore line count
        or      bx , bx         ; all lines done ?
        jz      short nsd11     ; all done - exit
        dec     bx              ; decrement line count
        push    bx              ; save it on stack again
        push    cx              ; save on stack again
nsd1:
;
;       write during remaining vertical blanking interval
;
        mov     bx , cx         ; save length in cx
        mov     cx , TIMEOUT    ; horizontal timeout
        cli                     ; disable interupts during loop
nsd2:
        in      al , dx         ; get video status
        test    al , BIT_MASK   ; test bit
        loopnz  short nsd2      ; loop while display enable inactive
        jz      short nsd3      ; jump if loop did not time out

        movsw                   ; copy one word
        sti                     ; re-enable interupts
        mov     cx , bx         ; restore count to do
        loop    nsd1
        jmp     short nsd10     ; entire line copied

;
;       write during horizontal blanking intervals
;
nsd3:
        sti
        mov     cx , bx         ; count in cx
nsd4:
        lodsw                   ; AL = charcter code   AH = attribute
        mov     bx , ax         ; move them to bx
        push    cx              ; preserve word loop counter
        mov     cx , TIMEOUT    ; horizontal timeout limit
        cli                     ; clear interupts
nsd5:
        in      al , dx
        test    al , BIT_MASK   ; loop during horizontal blanking
        loopnz  nsd5            ; until timeout occurs
        jnz     nsd7            ; jump if timed out ( vertical blanking begun )
nsd6:
        in      al , dx
        test    al , BIT_MASK
        jz      nsd6            ; loop while display enable is active
        xchg    ax , bx         ; char and attrib in ax
        stosw                   ; copy two bytes to display buffer
        sti                     ; restore interupts
        pop     cx              ; restore counter
        loop    nsd4
        jmp     short nsd10     ; whole line done
;
;       write during entire vertical blanking interval
;
nsd7:
        pop     bx              ; word loop counter in bx
        dec     si              ; no stosw so we have to manually
        dec     si              ; increment source pointer

        mov     cx , VBcount    ; # of words to copy
        cmp     bx , cx
        jnb     nsd8            ; jump if more than VBcount words to go

        mov     cx , bx         ; number of words to go
        xor     bx , bx         ; bx = 0
        jmp     short nsd9
nsd8:
        sub     bx , cx         ; bx = words to go ( < VBcount )
nsd9:
        rep     movsw           ; copy to video buffer
        mov     cx , bx         ; # to go in cx again
        or      cx , cx         ; are we at 0 yet ??
        jnz     nsd1            ; jump if more to do
nsd10:
        add     di , bp         ; set di to start of next line
        add     si , bp         ; set si to start of next line
        jmp     nsd0            ; jump to do next line
nsd11:
        ret
NoSnowDisp       ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by VsDisp and does the BIOS compatable screen writes.         ;
;                                                                              ;
;------------------------------------------------------------------------------;
;
; ds:si and es:di point to source and destination
; cx set to the number of words per line to do
; bx the number of lines.
; bp set to the number to add to si and di to get to the next line.
;
BiosDisp      PROC
        call    near ptr SetupBios

        push    cx
        push    dx                      ; save bios data
        call    near ptr PointerSet     ; set up pointer ds:si for later

        mov     dl , byte ptr log_start_x       ; position of cursor to start
        mov     dh , byte ptr log_start_y
        dec     bp
        dec     bp

        call    near ptr BiosWriteScreen

        pop     dx
        pop     cx              ; restore bios data
        call    near ptr ResetBios

        ret
BiosDisp      ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by BiosDisp and BiosRestoreScreen. Bios calls to screen write.;
;                                                                              ;
;------------------------------------------------------------------------------;
BiosWriteScreen        PROC

        mov     cx , 1                  ; character count
; cursor set ( dx ) at start of modified section
dw1:
        call    near ptr BiosSetCursPos  ; set cursor position
        mov     al , [si]               ; character
        inc     si
        mov     bl , [si]               ; attribute
        inc     si
        mov     ah , 9
        push    bp              ; save bp as int 10H doesn't
        int     10H
        pop     bp              ; restore bp
        inc     dl              ; are we at the end of the modified section ?
        cmp     dl , byte ptr log_end_x
        jle     short dw1
        mov     dl , byte ptr log_start_x
        inc     dh              ; are we at the end of the modified section ?
        add     si , bp         ; move si to start of next line.
        cmp     dh , byte ptr log_end_y
        jle     short dw1

        ret
BiosWriteScreen        ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by OldScreen saves the old screen with bios calls.            ;
;                                                                              ;
;------------------------------------------------------------------------------;
BiosSaveScreen	       PROC
        push    si
        push    di

        call    near ptr SetupBios

        xor     dx , dx                 ; cursor at 0,0
        mov     si , old_screen         ; pointer to old screen
ds1:
        call    near ptr BiosSetCursPos  ; set cursor position
        mov     ah , 8
        int     10H
        mov     [si] , al              ; character
        inc     si
        mov     [si] , ah              ; attribute
        inc     si
        inc     dl
        cmp     dl , 79
        jne     short ds1
        xor     dl , dl
        inc     dh
        cmp     dh , 24
        jne     short ds1

        call    near ptr ResetBios

        pop     di
        pop     si
        ret
BiosSaveScreen         ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;      This is called by OldScreen. It uses the Bios instead of DMA.           ;
;                                                                              ;
;------------------------------------------------------------------------------;
BiosRestoreScreen      PROC
        push    si
        mov     si , old_screen         ; pointer to base screen

        call    near ptr SetupBios

        push    cx
        push    dx                      ; save bios data
        xor     bp , bp                 ; no count to add in function below
        xor     dx , dx                 ; start at 0 , 0
        mov     log_start_x , 0
        mov     log_start_y , 0
        mov     log_end_x , 79
        mov     log_end_y , 24          ; end at 80 , 25
        call    near ptr BiosWriteScreen

        pop     dx
        pop     cx              ; restore bios data
        call    near ptr ResetBios

        pop     si
        ret
BiosRestoreScreen     ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
; This is called by BiosDisp and BiosRestoreScreen. Bios calls to screen write.;
;                                                                              ;
;------------------------------------------------------------------------------;
SetupBios	PROC
        call    near ptr BiosGetCursInfo
        push    cx
        mov     cx , 2000H              ; make cursor invisible
        call    near ptr BiosSetCurSize
        pop     cx
        ret
SetupBios       ENDP
;------------------------------------------------------------------------------;
;                                                                              ;
;          Resests Cursor after Bios calls.                                    ;
;                                                                              ;
;------------------------------------------------------------------------------;
ResetBios	PROC
        call    near ptr BiosSetCursPos
        call    near ptr BiosSetCurSize
        ret
ResetBios       ENDP
		END
