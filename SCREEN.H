//  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
//                           SCREEN.H                                       *
//    This include file contains definitions and function declarations      *
//               for the screen  module.                                    *
//                                                                          *
//  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
#if !defined(SCREEN_H)
#define SCREEN_H
//
//   type of video screen access
//
#define BIOS        1   // Use only bios functions for screen access
#define NO_SNOW     2   // Snow Free direct access
#define DMA         3   // Direct writes to screen memory ( fastest )
//
//   video defines .. adapter types
//

#define MDA     0x01    //  Monochrome Display Adapter
#define CGA     0x02    //  Colour Graphics Adapter
#define EGA     0x03    //  Enhanced Graphics Adapter
#define MCGA    0x04    //  Multi Colour Graphics Array
#define VGA     0x05    //  Video Graphics Array
#define PGA     0x06    //  Profesional Graphics Adapter
#define HGC     0x80    //  Hercules Graphics Card
#define HG_P    0x81    //  Hecules Graphics Plus Card
#define HG_COL  0x82    //  Hercules InColour Card

//
//   screen types
//
#define MDA_display 0x01
#define CGA_display 0x02
#define EGA_colour  0x03
#define PS2_mono    0x04
#define PS2_colour  0x05
#define PGA_display 0x06

//
//   video modes
//
#define BW40                0x00
#define CO40                0x01
#define BW80                0x02
#define CO80                0x03
#define LORES_4CO           0x04
#define LORES_BW            0x05
#define LORES_2CO           0x06
#define MONO                0x07
#define PCJR_LORES          0x08
#define PCJR_MIDRES         0x09
#define PCJR_HIRES          0x0A
#define EGA_LORES_16CO      0x0D
#define EGA_MIDRES_16CO     0x0E
#define EGA_HIRES_BW        0x0F
#define EGA_HIRES_16CO      0x10
#define VGA_HIRES_2CO       0x11
#define VGA_HIRES_16CO      0x12
#define VGA_LORES_256CO     0x13
//
//   SCREEN module function definations for type checking.
//
void    CursorHome( void );
void    CursorHide( void );
void    CursorThin( void );
void    CursorFat( void );
void    VsBorderCol ( int );
void    VsBackground ( int , int , unsigned char );
void    VsDisp( void );

#endif
