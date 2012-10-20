// Header for Tandy PDD1 floppy drive emulator
//
// senseitg@gmail.com 2012-May-22
#pragma once
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdio.h>

// start emulate floppy drive
// device specifies device for sopen, see serial.c/h
// verbose specifies FILE* for verbose output, such as stdout
// emulate is blocking
void emulate(char *device,uint8_t *p_sect_data,uint8_t *p_sids_data,FILE *verbose);

// stop emulating floppy drive
// since emulate is blocking, this must be called from a separate process
void emulate_stop();

#ifdef __cplusplus
}
#endif
