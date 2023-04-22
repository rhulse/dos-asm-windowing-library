;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description :  Window module int 24 ( critical error ) handler.             ;
;                                                                              ;
;------------------------------------------------------------------------------;

.MODEL SMALL

include window.inc

public  _wnint24
public  _WnStealInt24
public  _WnRestoreInt24
public  _critical_error
extrn   _WnKill:near
extrn   _WnPrint:near
extrn   _WnMake:near
extrn   _VsDisp:near
extrn   _GetKey:near
extrn   _WnOpen:near
extrn   _WnBorder:near
extrn   _WnShadow:near
extrn	_WnChgAttr:near
extrn   _Beep:near


.DATA
err0            DB      'Write protected disk',0
err1            DB      'Drive not known',0
err2            DB      'Drive not ready',0
err3            DB      'Invalid command',0
err4            DB      'CRC data error',0
err5            DB      'Structure length error',0
err6            DB      'Disk seek error',0
err7            DB      'Non - MS DOS disk',0
err8            DB      'Sector not found',0
errA            DB      'Write fault',0
errB            DB      'Read fault',0
errC            DB      'General failure',0
errF            DB      'Invalid disk change',0
errZ            DB      'Try again or Quit ?',0
errG            DB      'Error accessing drive ',0
errU            DB      'Unknown error',0
error_strings   DW      err0
                DW      err1
                DW      err2
                DW      err3
                DW      err4
                DW      err5
                DW      err6
                DW      err7
                DW      err8
                DW      errU
                DW      errA
                DW      errB
                DW      errC
                DW      errU
                DW      errU
                DW      errF

keys            DB      'tTqQ'
keys_len        equ     $ - keys
codes           DB      1, 1, 3, 3
_critical_error DW      FALSE
old24           DD      0
drive           DB      0
                DB      0       ; null terminater for drive

.DATA?
dos_version     LABEL   WORD
minorversion    DB      ?
majorversion    DB      ?


.CODE
;
; Set int 24 vector to point to my routine
;
_WnStealInt24   PROC
        push    ds
        push    es

        mov     ah , 30H        ; get dos version
        int     21H             ; call DOS
        xchg    ah , al         ; ah = major ver  al = minor ver.
        mov     word ptr dos_version , ax       ; save it

        mov     ax , 3524H      ; get vector
        int     21H

        mov     word ptr old24 , bx     ; save it
        mov     word ptr old24 + 2 , es

        push    cs
        pop     ds
        mov     dx , offset _TEXT:_wnint24
        mov     ax , 2524H      ; change vector
        int     21H

        pop     es
        pop     ds
        ret
_WnStealInt24   ENDP
;
; Restore original int 24 vector
;
_WnRestoreInt24 PROC
        push    ds
        lds     dx , old24
        mov     ax , 2524H
        int     21H

        pop     ds
        ret
_WnRestoreInt24 ENDP

_wnint24         PROC   FAR
        sti             ; restore interupts
        push    bp
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        push    ax      ; save code
        mov     ax , DGROUP
        mov     ds , ax
        mov     es , ax

        mov     ax , 5
        push    ax
        mov     ax , 150
        push    ax
        call    near ptr _Beep
        add     sp , 4

        mov     ax , 3
        push    ax
        mov     ax , 300
        push    ax
        call    near ptr _Beep
        add     sp , 4

        xor     ax , ax         ; bgc BLACK
        push    ax
        mov     ax , 0FH        ; fgc LTWHITE
        push    ax
        mov     ax , 9          ; y
        push    ax
        mov     ax , 17         ; x
        push    ax
        mov     ax , 3          ; height
        push    ax
        mov     ax , 44         ; width
        push    ax

        call    near ptr _WnMake ; make the window
        add     sp , 12
        mov     si , ax         ; ptr to win in si

        mov     ax , 3          ; double line border.
        push    ax
        push    si
        call    near ptr _WnBorder
        add     sp , 4

        mov     [si].W_FGC , 5     ; change colours of window
        mov     [si].W_BGC , 0

        push    si
        call    near ptr _WnOpen
        inc     sp
        inc     sp

        pop     ax              ; restore data
        and     ah , 80H        ; disk error ?
        jne     short no_disk_err

        add     al , 'A'        ; add the drive letter on the end.
        mov     byte ptr drive , al

        mov     [si].W_CURSX , 9   ; set up cursor position to write at
        mov     [si].W_CURSY , 0
        
        mov     ax , offset errG
        push    ax
        push    si
        call    near ptr _WnPrint
        add     sp , 4

        mov     ax , offset drive
        push    ax
        push    si
        call    near ptr _WnPrint
        add     sp , 4
no_disk_err:
        mov     [si].W_CURSX , 7  ; set up cursor position to write at
        mov     [si].W_CURSY , 1

        and     di , 0FFH       ; clear high nibble
        shl     di , 1          ; convert to word pointer
        mov     bx , offset error_strings       ; get pointer to strings
        mov     ax , [ bx + di ]        ; point to appropriate one
        push    ax                      ; push address
        push    si                      ; push win
        call    near ptr _WnPrint       ; print it
        add     sp , 4

        mov     [si].W_CURSX , 9   ; set up cursor position to write at
        mov     [si].W_CURSY , 2
        mov     ax , offset errZ        ; Retry or Quit message
	push	ax
	push	si
        call    near ptr _WnPrint       ; print it
        add     sp , 4

        ;       highlight T and Q in message.

	mov	ax , 1		; count
	push	ax
	xor	ax , ax 	; bgc BLACK
        push    ax
	mov	ax , 0EH	; fgc YELLOW
	push	ax
	mov	ax , 2		; y
	push	ax
        mov     ax , 9          ; x
        push    ax
	push	si		; win
	call	near ptr _WnChgAttr
        add     sp , 12

        mov     ax , 1          ; count
	push	ax
	xor	ax , ax 	; bgc BLACK
        push    ax
	mov	ax , 0EH	; fgc YELLOW
	push	ax
	mov	ax , 2		; y
	push	ax
        mov     ax , 22         ; x
        push    ax
	push	si		; win
	call	near ptr _WnChgAttr
        add     sp , 12

        call    near ptr _VsDisp        ; display it all !!
try_again:
        call    near ptr _GetKey

        mov     di , offset keys
        mov     cx , keys_len
        cld
        repne   scasb
        jnz     short try_again

        mov     al , [di + keys_len - 1]
        cmp     al , 3
        jne     short not_fail
        cmp     byte ptr majorversion , 3  ; fail on version 3.x
        je      short no_change
        xor     al , al         ; ignore if version 2.x
no_change:
        mov     word ptr _critical_error , TRUE
not_fail:
        push    ax              ; save action
        push    si
        call    near ptr _WnKill
        inc     sp
        inc     sp
        pop     ax              ; restore action

        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     bp
        iret
_wnint24        ENDP
                END
