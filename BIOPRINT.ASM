;
;  File Name    :       bioprint.asm
;
;  Description  :       fuctions to use the BIOS to access the printer
;
;  C Prototypes :
;  void BiosPrintInit ( void );                // Initialises printer 0
;  int  BiosPrintStatus ( void );              // status of printer 0
;  int  BiosPrintChar ( char character );      // print a char on printer 0
;

        .MODEL SMALL

Public  C BiosPrintInit
Public  C BiosPrintStatus
Public  C BiosPrintChar

.CODE

;------------------------------------------------------------------------------;
;        Initialises printer 0 ( LPT1 )                                        ;
;------------------------------------------------------------------------------;
BiosPrintInit   PROC
        mov     ah , 1          ; fuction 1
        xor     dx , dx         ; printer 0 ( LPT1 )
        int     17H             ; call bios
        mov     al , ah
        xor     ah , ah         ; return status in ax
        ret
BiosPrintInit   ENDP

;------------------------------------------------------------------------------;
;        Gets the status of printer LPT1.                                      ;
;------------------------------------------------------------------------------;
BiosPrintStatus PROC
        mov     ah , 2          ; fuction 2
        xor     dx , dx         ; printer 0 ( LPT1 )
        int     17H             ; call bios
        mov     al , ah
        xor     ah , ah         ; return status in ax
        ret
BiosPrintStatus ENDP

;------------------------------------------------------------------------------;
;        Sends a character to  printer LPT1.                                   ;
;------------------------------------------------------------------------------;
BiosPrintChar   PROC    C
        ARG     character : BYTE:1
        mov     al , [character] ; Argument 1 - the character
        xor     ah ,  ah        ; fuction 0
        xor     dx , dx         ; printer 0 ( LPT1 )
        int     17H             ; call bios
        mov     al , ah
        xor     ah , ah         ; return status in ax
        ret
BiosPrintChar   ENDP
                END
