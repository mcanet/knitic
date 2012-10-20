// Header for platform independant serial communications
//
// senseitg@gmail.com 2012-May-22
#pragma once
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

// open serial port
// device has system dependant form
// returns true if successful
bool sopen(char* device);

// configure serial port
// fmt has form "baud,parity,databits,stopbit", ie: "9600,N,8,1"
// returns true if successful
bool sconfig(char* fmt);

// read from serial port
// returns bytes actually read
int32_t sread(void *p_read,uint16_t i_read);

// write to serial port
int32_t swrite(void* p_write,uint16_t i_write);

// close serial port
bool sclose();

#ifdef __cplusplus
}
#endif
