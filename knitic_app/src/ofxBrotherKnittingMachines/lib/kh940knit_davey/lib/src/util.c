// Source file for utility functions

// This is mostly bit, nibble and big-endian memory access
//
// senseitg@gmail.com 2012-May-22

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "util.h"

void print_hex(FILE *output,uint8_t* mem,uint32_t length) {
	uint8_t count=0;
	while(length--) {
		fprintf(output,"%02X",*mem++);
		count=(count+1)&0x0F;
		if(count) {
			fprintf(output," ");
		} else {
			fprintf(output,"\n");
		}
	}
	if(count) fprintf(output,"\n");
}

void print_slim_hex(FILE *output,uint8_t* mem,uint32_t length) {
	while(length--) fprintf(output,"%02X",*mem++);
}

void bit_set(uint8_t *p_data,uint32_t bp) {
	p_data[bp>>3]|=0x80>>(bp&7);
}

void bit_clr(uint8_t *p_data,uint32_t bp) {
	p_data[bp>>3]&=~(0x80>>(bp&7));
}

bool bit_get(uint8_t *p_mem,uint32_t bp) {
	return (p_mem[bp>>3]&(0x80>>(bp&7)))!=0;
}

uint8_t nib_get(uint8_t *p_data,uint32_t np) {
	uint8_t byte=p_data[np>>1];
	return (np&1)?LSN(byte):MSN(byte);
}

void nib_set(uint8_t *p_data,uint32_t np,uint8_t val) {
	if(np&1) {
		p_data[np>>1]=(p_data[np>>1]&0xF0)|(val);
	} else {
		p_data[np>>1]=(p_data[np>>1]&0x0F)|(val<<4);
	}
}

uint16_t int_get(uint8_t *p_data,uint32_t p) {
	return (p_data[p+0]<<8)|(p_data[p+1]<<0);
}

void int_set(uint8_t *p_data,uint32_t p,uint32_t val) {
	p_data[p+0]=(val>>8)&0x00FF;
	p_data[p+1]=(val>>0)&0x00FF;
}

bool sample(uint8_t *p_image,uint8_t w,uint8_t x,uint8_t y) {
	return p_image[y*w+x]<0x80;
}

uint8_t bcd_get(uint16_t n,uint16_t value) {
	return (n/value)%10;
}