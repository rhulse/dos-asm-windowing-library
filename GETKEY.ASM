;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name : getkey.asm                                                      ;
;                                                                              ;
;  Description : keyboard routines + mouse init                                ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; int     GetKey( void )                                                       ;
; int     KeyPressed( void )                                                   ;
; void    InitMouse( void )                                                    ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public  _GetKey
public  _KeyPressed
public  _InitMouse

;------------------------------------------------------------------------------;
;                                                                              ;
;      Get a key or translate mouse actions to a key if mouse installed.       ;
;                                                                              ;
;------------------------------------------------------------------------------;
;
; defines for getkey
K_ENTER         equ     000DH
K_ESC           equ     001BH
U_ARROW         equ     4800H
D_ARROW         equ     5000H
L_ARROW         equ     4B00H
R_ARROW         equ     4D00H
K_F1            equ     3B00H
POSCOUNT        equ     34
NEGCOUNT        equ     -34

.DATA

mouse   db      0       ; is there a mouse available

.CODE
_GetKey 	PROC
        push    bp
        push    si
        push    di

        cmp     mouse , TRUE    ; if a mouse is active then do a loop
        je      short startloop
        jmp     a_key           ; get a key if not
startloop:
        mov     ax , 11         ; clear any extraneous counts
        int     33H
        mov     ax , 5          ; and button presses
        int     33H             ; Mouse interrupt
        xor     si , si
        xor     di , di
mainloop:
        mov     ah , 0Bh
        int     21H
        or      al , al
        jnz     short a_key

        mov     ax , 11
        int     33H
        mov     ax , si         ; Accumulate vertical mouse motion counts
        add     ax , dx
        mov     si , ax
        mov     ax , di         ; Accumulate horizontal mouse motion counts
        add     ax , cx
        mov     di , ax
ucheck:
        cmp     si , NEGCOUNT   ; check up motion
        jge     short dcheck    ; Not enough up motion
        mov     ax , U_ARROW    ; Return U_ARROW if enough mouse motion
        jmp     short key_exit  ; exit

dcheck:
        cmp     si , POSCOUNT   ; check down motion
        jle     short lcheck    ; go and check buttons
        mov     ax , D_ARROW    ; Return D_ARROW if enough mouse motion
        jmp     short key_exit  ; exit
lcheck:
        cmp     di , NEGCOUNT   ; check left motion
        jge     short rcheck    ; Not enough left motion
        mov     ax , L_ARROW    ; Return L_ARROW if enough mouse motion
        jmp     short key_exit  ; exit
rcheck:
        cmp     di , POSCOUNT   ; check right motion
        jle     short chkbuttons; Not enough right motion..check buttons
        mov     ax , R_ARROW    ; Return R_ARROW if enough mouse motion
        jmp     short key_exit
chkbuttons:
        mov     ax , 5          ; Mouse Function 5
        xor     bx , bx         ; Get left button press information
        int     33H             ; Mouse interrupt
        or      bx , bx
        jz      short chkright
        mov     ax , K_ENTER    ; if left button return ENTER
        jmp     short key_exit
chkright:
        mov     ax , 5          ; Mouse Function 5
        mov     bx , 1          ; Get right button press information
        int     33H             ; Mouse interrupt
        or      bx , bx
        jz      short chkmid
        mov     ax , K_ESC      ; if right button return ESC
        jmp     short key_exit
chkmid:
        mov     ax , 5          ; Mouse Function 5
        mov     bx , 2          ; Get middle button press information
        int     33H             ; Mouse interrupt
        or      bx , bx
        jz      short doloop
        mov     ax , K_F1       ; if middle button return F1
        jmp     short key_exit
doloop:
        jmp     short mainloop  ; Loop back until anything is done !
a_key:
        mov     ah , 07H
        int     21H
        xor     ah , ah
        or      al , al
        jnz     short key_exit

        mov     ah , 07H
        int     21H             ; get extended key
        mov     ah , al         ; shift left 8 <<
        xor     al , al
key_exit:
        pop     di
        pop     si
        pop     bp
	ret	
_GetKey         ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;      See if a keypress is available. Returns TRUE if there is.               ;
;                                                                              ;
;------------------------------------------------------------------------------;
_KeyPressed	PROC
        mov     ah , 0Bh
        int     21H
        xor     ah , ah
        or      al , al         ; a 0 means no key
        jz      short kp_end
        mov     ax , TRUE
kp_end:
        ret
_KeyPressed     ENDP

;------------------------------------------------------------------------------;
;                                                                              ;
;          Initialise the mouse if there is one.                               ;
;                                                                              ;
;------------------------------------------------------------------------------;
_InitMouse	PROC
        xor     ax , ax
        int     33H
        or      al , al
        jz      short mouse_exit
        mov     al , 01
mouse_exit:
        mov     mouse , al      ; set mouse flag to true or false
        ret
_InitMouse      ENDP
		END
