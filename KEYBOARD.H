//  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
//                          KEYBOARD.H                                      *
//    This include file contains definitions and function declarations      *
//               for the keyboard module.                                   *
//                                                                          *
//  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
#if !defined(KEYBOARD_H)
#define KEYBOARD_H

// miscelaneous defines

#define NULL         0
#define SOH          1
#define BS           8
#define TAB          9
#define LF           0x0A
#define FF           0x0C
#define CR           0x0D
#define ENTER        0x0D
#define CTRLZ        0x1A
#define ESC          0x1B
#define SPACEBAR     0x20
#define SPACE        0x20

// Extended Codes

#define ALT_0  0x8100
#define ALT_1  0x7800
#define ALT_2  0x7900
#define ALT_3  0x7A00
#define ALT_4  0x7B00
#define ALT_5  0x7C00
#define ALT_6  0x7D00
#define ALT_7  0x7E00
#define ALT_8  0x7F00
#define ALT_9  0x8000

#define ALT_MI 0x8200   // Alt_-
#define ALT_EQ 0x8300   // Alt_=

#define ALT_A  0x1E00
#define ALT_B  0x3000
#define ALT_C  0x2E00
#define ALT_D  0x2000
#define ALT_E  0x1200
#define ALT_F  0x2100
#define ALT_G  0x2200
#define ALT_H  0x2300
#define ALT_I  0x1700
#define ALT_J  0x2400
#define ALT_K  0x2500
#define ALT_L  0x2600
#define ALT_M  0x3200
#define ALT_N  0x3100
#define ALT_O  0x1800
#define ALT_P  0x1900
#define ALT_Q  0x1000
#define ALT_R  0x1300
#define ALT_S  0x1F00
#define ALT_T  0x1400
#define ALT_U  0x1600
#define ALT_V  0x2F00
#define ALT_W  0x1100
#define ALT_X  0x2D00
#define ALT_Y  0x1500
#define ALT_Z  0x2E00

#define F1  0x3B00
#define F2  0x3C00
#define F3  0x3D00
#define F4  0x3E00
#define F5  0x3F00
#define F6  0x4000
#define F7  0x4100
#define F8  0x4200
#define F9  0x4300
#define F10 0x4400

// shifted function key codes

#define SF1     0x5400
#define SF2     0x5500
#define SF3     0x5600
#define SF4     0x5700
#define SF5     0x5800
#define SF6     0x5900
#define SF7     0x5A00
#define SF8     0x5B00
#define SF9     0x5C00
#define SF10    0x5D00

// ctrl funct key codes

#define CF1     0x5E00
#define CF2     0x5F00
#define CF3     0x6000
#define CF4     0x6100
#define CF5     0x6200
#define CF6     0x6300
#define CF7     0x6400
#define CF8     0x6500
#define CF9     0x6600
#define CF10    0x6700

// alt funct key codes

#define AF1     0x6800
#define AF2     0x6900
#define AF3     0x6A00
#define AF4     0x6B00
#define AF5     0x6C00
#define AF6     0x6D00
#define AF7     0x6E00
#define AF8     0x6F00
#define AF9     0x7000
#define AF10    0x7100


#define HOME        0x4700
#define U_ARROW     0x4800
#define PG_UP       0x4900
#define L_ARROW     0x4B00
#define R_ARROW     0x4D00
#define END         0x4F00
#define D_ARROW     0x5000
#define PG_DN       0x5100
#define INS         0x5200
#define DEL         0x5300
#define CTL_HOME    0x7700
#define CTL_UARROW  0x8D00
#define CTL_PG_UP   0x8400
#define CTL_LARROW  0x7300
#define CTL_RARROW  0x7400
#define CTL_END     0x7500
#define CTL_DARROW  0x9100
#define CTL_PG_DN   0x7600
#define BACKTAB     0x0F00

//
//      Function prototypes
//
int     GetKey( void );
int     KeyPressed( void );

#endif
