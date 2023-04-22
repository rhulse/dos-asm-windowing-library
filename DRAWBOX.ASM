;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :  drawbox.asm                                                    ;
;                                                                              ;
;  Description :  function draws a box on base screen as specified.            ;
;     Internal function used by WINDOW modules.                                ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
; void DrawBox( int type, int x, int y, int wid, int hgt, int attr )           ;
;                                                                              ;
;------------------------------------------------------------------------------;
        .MODEL SMALL

include window.inc

public DrawBox
extrn   _base_screen:word

.DATA
; Data for the different border types
EDGE_CHARS      label word
           DB  20H,  20H,  20H,  20H,  20H,  20H,  20H,  20H ; No border.
           DB  20H,  20H,  20H,  20H,  20H,  20H,  20H,  20H ; spaces.
           DB 0DAH, 0C4H, 0BFH, 0B3H, 0B3H, 0C0H, 0C4H, 0D9H ; slg line.
;              Ú      Ä    ¿     ³     ³     À      Ä    Ù

           DB 0C9H, 0CDH, 0BBH, 0BAH, 0BAH, 0C8H, 0CDH, 0BCH ; dbl line.
;              É     Í     »     º     º     È     Í     ¼

           DB 0D5H, 0CDH, 0B8H, 0B3H, 0B3H, 0D4H, 0CDH, 0BEH ; Dtop , Sside.
;              Õ     Í     ¸     ³     ³     Ô     Í     ¾

           DB 0D6H, 0C4H, 0B7H, 0BAH, 0BAH, 0D3H, 0C4H, 0BDH ; Stop ,  Dside.
;              Ö     Ä     ·     º     º     Ó      Ä    ½

           DB 0DCH, 0DCH, 0DCH, 0DDH, 0DEH, 0DFH, 0DFH, 0DFH ; Block.
;              Ü     Ü     Ü     Ý     Þ     ß     ß     ß

.CODE
DrawBox         PROC
	push	bp
        mov     bp , sp
        push    di
        push    si
;
;   Set up the destination first
;
        mov     di , base_screen        ; starting address of base screen
        mov     ax , ARG_3              ; y
        mov     cl , 5                  ; Multiply by 160 ONLY !!!
        shl     ax , cl                 ; this way only 38 cycles
        mov     bx , ax                 ; imul would be 128 - 154
        shl     ax , 1
        shl     ax , 1
        add     ax , bx
        mov     bx , ARG_2              ; x
        shl     bx , 1                  ; x * 2
        add     ax , bx                 ; count from top left
        add     di , ax                 ; above + base_screen address
;
;   Set up the source characters
;
        mov     bx , ARG_1      ; type in bx
        shl     bx , 1          ; type * 8
        shl     bx , 1
        shl     bx , 1          ;
        mov     si , offset EDGE_CHARS ; starting address of chars to use.
        add     si , bx         ; offset to start of type to use.
;
;  Set up the amount to add to get to the start of the next line
;
        mov     dx , ONE_LINE   ; one line in bytes
        mov     ax , ARG_4
        shl     ax , 1          ; minus width in bytes
        sub     dx , ax

        mov     ax , ARG_6      ; attribute
        mov     ah , al         ; mov into high byte

        lodsb                   ; top left corner
        stosw

        lodsb                   ; top line
        mov     cx , ARG_4      ; wid - 2 in cx
        dec     cx
        dec     cx
        rep     stosw

        lodsb                   ; top right corner
        stosw
;        mov     [ di ] , ax

        add     di , dx         ; next line

        lodsb                   ; left side
        push    dx              ; save dx
        mov     dx , ax         ; mov into dx for loop

        lodsb                   ; right side in ax

        mov     bx , ARG_4      ; ( wid - minus 1 ) * 2 [ word count ]
        dec     bx
        shl     bx , 1

        mov     cx , ARG_5      ; count in cx
        dec     cx
        dec     cx

draw1:
        mov     [di] , dx       ; copy left side char to box
        mov     [bx + di] , ax  ; copy right side char to box
        add     di , ONE_LINE   ; get to next line
        loop    short draw1

        pop     dx              ; restore dx

        lodsb                   ; bottom left corner
        stosw

        lodsb                   ; bottom line
        mov     cx , ARG_4      ; wid - 2 in cx
        dec     cx
        dec     cx
        rep     stosw

        lodsb                   ; bottom right corner
        stosw

        pop     si
        pop     di
	pop	bp
	ret	
DrawBox         ENDP
                END
