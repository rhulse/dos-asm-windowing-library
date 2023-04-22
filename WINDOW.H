//  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
//                           WINDOW.H                                       *
//    This include file contains definitions and function declarations      *
//               for the windows module.                                    *
//                                                                          *
//  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
#if !defined(WINDOW_H)
#define WINDOW_H

#define NORMAL       0x07    // std. white on black
#define BRIGHT       0x0A    // Bright white on black.
#define REVERSE      0x70    // reverse video

//
//      Colours definitions
//
typedef enum
{
        V_BLACK,       // 0x00
        V_BLUE,        // 0x01
        V_GREEN,       // 0x02
        V_CYAN,        // 0x03
        V_RED,         // 0x04
        V_MAGENTA,     // 0x05
        V_BROWN,       // 0x06
        V_WHITE,       // 0x07
        V_GREY,        // 0x08
        V_LTBLUE,      // 0x09    light blue
        V_LTGREEN,     // 0x0A    light green
        V_LTCYAN,      // 0x0B    light cyan
        V_LTRED,       // 0x0C    light red
        V_LTMAGENTA,   // 0x0D    light magenta
        V_YELLOW,      // 0x0E
        V_LTWHITE      // 0x0F    bright white
}v_col;

//
//   defines for shadow type
//
typedef enum
{
        NO_SHADOW,      // 0
        UPPER_LEFT,     // 1
        UPPER_RIGHT,    // 2
        LOWER_RIGHT,    // 3
        LOWER_LEFT      // 4
}vshad_type;

//
//   defines for type of shadow character
//
typedef enum
{
        COARSE=1,       // `°'
        MEDIUM,         // `±'
        FINE,           // `²'
        SOLID           // `Û'
}vshad_char;

//
//  defines for border types
//
typedef enum
{
        NO_BDR,         // 0   No border
        SPACES,         // 1   Spaces.
        SINGLE,         // 2   Single line.
        DOUBLE,         // 3   Double line.
        DTOP_SSIDE,     // 4   Double top , Single side.
        STOP_DSIDE,     // 5   Single top , Double side.
        BLOCK           // 6   Block.
}vbdr_type;

//
//   oldscreen function control defines
//
#define SAVE         1
#define RESTORE      2

//
//   Scroll Window Directions
//
#define UP          1
#define DOWN        2

//
//   definition of WINDOW structure
//
typedef struct WINDOW
{
    int wid;                    // width of window
    int hgt;                    // height of window
    int x;                      // x position on screen
    int y;                      // y position on screen
    v_col fgc;                  // fg colour of window
    v_col bgc;                  // bg colour of window
    int cursx;                  // x position of cursor
    int cursy;                  // y position of cursor
    int shadow;                 // shadow type
    int shadchar;               // shadow character
    int bdr;                    // border type
    int bdr_attr;               // border attribute
    int bdr_chg;                // change border colour ?
    int open;                   // window open ???
    int hide;                   // is the window hidden
    struct  WINDOW  *back_link; // ptr to previous win
    struct  WINDOW  *on_link;   // ptr to next window
    struct  WINDOW  *self;      // ptr to self
    int copt;                   // integer resource
    int *ptr;                   // ptr to virtual screen
    char *title;                // a title for the border
    void *resource;             // resource pointer
}WINDOW;

//
//   WINDOW module function definations for type checking.
//
void	WnInit( void );
void	WnExit( void );
WINDOW *WnMake ( int , int , int , int , v_col , v_col );
void    WnActivate ( WINDOW * );
void    WnBorder( WINDOW * , vbdr_type );
void    WnBorderChg( WINDOW * , int );
void    WnBorderCol( WINDOW * , int , int );
void    WnChgAttr( WINDOW * , int , int , v_col , v_col , int );
void    WnClose( WINDOW * );
void    WnCloseAll( void );
void    WnCls( WINDOW * , int , int );
void    WnCursOn( WINDOW * );
void    WnDeactivate ( void );
int     WnEdit ( WINDOW * , int , int , int , char * );
void    WnGetActColours ( int * , int * );
void    WnGetAttr( WINDOW * , int * , int * );
void    WnGetCurs( WINDOW * , int * , int * );
void    WnHide ( WINDOW * );
void    WnHideAll ( WINDOW * );
void    WnKill( WINDOW * );
void    WnKillAll( void );
void    WnMove( WINDOW * , int , int );
void    WnOpen( WINDOW * );
void    WnPrint( WINDOW * , char * );
void    WnPrintxy( WINDOW * , int , int , char * );
void    WnPrintxya( WINDOW * , int , int , char * , v_col , v_col );
void    WnRestoreInt24( void );
void    WnScroll( WINDOW * , int , int , int );
void    WnSetActColours ( v_col , v_col );
void    WnSetAttr( WINDOW * , v_col , v_col );
void    WnSetCurs( WINDOW * , int , int );
void    WnShadow( WINDOW * , vshad_type , vshad_char , v_col , v_col );
void    WnShadowOff( WINDOW * );
void    WnStealInt24( void );
void    WnTitle( WINDOW * , char * );
void    WnUnHide ( WINDOW * );
void    WnUnHideAll ( WINDOW * );
void    AllocError( void );
int     MakeAttr( v_col , v_col );

#endif
