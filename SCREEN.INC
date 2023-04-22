;------------------------------------------------------------------------------;
;                                                                              ;
;    This INCLUDE file contains EQU's to make asm modules easier to read       ;
;                                                                              ;
;------------------------------------------------------------------------------;
; Includes for C file.
;
; #include "screen.h"      function and structure declarations.
;
;  ENTRY ROUTINE TO USE SCREEN MODULE
;
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
ON              equ     1
OFF             equ     0
NULL            equ     0
;
; used for the shadow column offsets and data.
;

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
