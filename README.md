# MS Dos Windowing Library

This library was written around 1990, and was inspired by Radio New Zelaland technician Phil Gibbs' C library, which did essentially the same thing.

The library creates a screen buffer and text windows can be created, layered and moved around. When a window is moved, the library rewrites the windows to the screen buffer from top to bottom, and then flushes the buffer directlt to screen memory. Back in the day, this was the fastest way to update the screen.

The library does include an option to use the BIOS to update the screen, but this is much slower (or was on 4-8 meghertz XT and AT grade PCs).

The library was used for a number of small personal projects, and should still compile and be usable. (Feedback on this welcome)

The main reason I have posted this here is for historical reference, but also so anyone can study or use it. For many years I thought the 1.44 floppy containing this code was lost, but I recently found a copy in a corner of my current machine's hard drive.

I would be happy to take pull requests for documentation, as it has been many years since a looked at this, and while the individual files have some documentation, I am a but busy these days to trawl through it all.

## DOCS

**WnInit**

this must be called first to allocate all the buffers and do the required setup.

**WINDOW \*WnMake ( int , int , int , int , v_col , v_col );**

This function creates a window at the position and size states with foreground and background colours.
The pointer that is returned can be passed to other functions to change position.

Windows can be hidden, moved, edited, and have their colours changed.

Windows can also cast a shadow on any content below.
