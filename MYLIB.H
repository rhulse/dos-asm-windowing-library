/*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
 *                        MYLIB.H                                           *
 *  This header provides function prototypes for the asm functions in       *
 *  my library.                                                             *
 *                                                                          *
 *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  */
#if !defined(MYLIB_H)
#define MYLIB_H


/*
 *    HARDWARE BEEPER PORT FUNCTIONS
 *    Beep makes a noise of freq , duration in ticks
 */

void    Beep( int , int );

/*
 *        PAUSE FUNCTIONS
 */

/* waits for specified number of seconds */

void    SPause( int );

/* waits for specified number of ticks */

void    TPause( int );

/* all functions setup for printer # 1 */

void    BiosPrintInit( void );

int     BiosPrintStatus( void );

int     BiosPrintChar( char );

/*
 *        MY DOS FUNCTIONS
 */

struct dta {
    char reserved[21];
    char attrib;
    unsigned wr_time;
    unsigned wr_date;
    long size;
    char name[13];
    };

int     DosGetDrive ( void );

int     DosSetDrive ( int );

int     DosCD ( char * );

int     DosFindFirst ( char * , int , struct dta * );

int     DosFindNext ( struct dta * );

long    DosGetTime ( char * , char * , char * , char * );

long    DosGetFreeSpace ( int );

#endif
