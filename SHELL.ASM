;------------------------------------------------------------------------------;
;                                                                              ;
;  File Name :                                                                 ;
;                                                                              ;
;  Description :                                                               ;
;                                                                              ;
;                                                                              ;
;  C Prototypes                                                                ;
;  ------------                                                                ;
;                                                                              ;
;  void AllocError ( void );                                                   ;
;                                                                              ;
;------------------------------------------------------------------------------;
;------------------------------------------------------------------------------;
;                                                                              ;
;  Contains             window function.                                       ;
;                                                                              ;
;------------------------------------------------------------------------------;
_TEXT   SEGMENT BYTE    PUBLIC  'CODE'
_TEXT	ENDS
_DATA   SEGMENT WORD    PUBLIC  'DATA'
_DATA	ENDS

DGROUP  GROUP     _DATA
	ASSUME	CS: _TEXT , DS: DGROUP , SS: DGROUP , ES: DGROUP

include window.inc

