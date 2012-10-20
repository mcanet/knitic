// Header file for utility functions
//
// senseitg@gmail.com 2012-May-22
#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

// nibble access convenience macros
#define MSN(B) (((unsigned char)B)>>4)
#define LSN(B) (((unsigned char)B)&0x0F)

// prints hex data in traditional 16 column format
void print_hex(FILE *output,uint8_t* mem,uint32_t length);

// prints hex data in slim format
void print_slim_hex(FILE *output,uint8_t* mem,uint32_t length);

// set bit in *p_data @ bit pointer bp
void bit_set(uint8_t *p_data,uint32_t bp);

// clear bit in *p_data @ bit pointer bp
void bit_clr(uint8_t *p_data,uint32_t bp);

// get bit in *p_data @ bit pointer bp
bool bit_get(uint8_t *p_mem,uint32_t bp);

// get nibble in *p_data @ nibble pointer np
uint8_t nib_get(uint8_t *p_data,uint32_t np);

// set nibble in *p_data @ nibble pointer np
void nib_set(uint8_t *p_data,uint32_t np,uint8_t val);

// get big-endian int16 in *p_data @ byte pointer p
uint16_t int_get(uint8_t *p_data,uint32_t p);

// set big-endian int16 in *p_data @ byte pointer p
void int_set(uint8_t *p_data,uint32_t p,uint32_t val);

// returns bcd number of column with specified value (ie 1, 10, 100, etc)
uint8_t bcd_get(uint16_t n,uint16_t value);

#ifdef __cplusplus
}
#endif
