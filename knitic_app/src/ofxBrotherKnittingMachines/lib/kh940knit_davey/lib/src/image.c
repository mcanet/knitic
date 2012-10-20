// Source file for image management functions
//
// Currently supports only proprietary RAW format
//
// senseitg@gmail.com 2012-May-22

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include "image.h"
#include "string.h"

// allocate memory for image
uint8_t *image_alloc(uint16_t w,uint16_t h) {
	uint8_t *p_image=(uint8_t*)malloc(w*h);
	memset(p_image,0x00,w*h);
	return p_image;
}

// get pixel from image
bool image_sample(uint8_t *p_image,uint16_t w,uint16_t x,uint16_t y) {
	return p_image[y*w+x]<0x80;
}

// set pixel in image
void image_pset(uint8_t *p_image,uint16_t w,uint16_t x,uint16_t y,bool p) {
	p_image[y*w+x]=p?0x00:0xFF;
}

// read image file
uint8_t *image_read(FILE *f,uint16_t *w,uint16_t *h) {
  uint8_t *p_img;
  size_t bytes;
  uint8_t temp[4];
  // get fle size
  fseek(f,0,SEEK_END);
  bytes=ftell(f);
  fseek(f,0,0);
  // ensure header
  if(bytes<4) return NULL;
  // read header - 4 bytes
  fread(temp,1,4,f);
  // get size
  *w=(temp[0]<<8)|temp[1];
  *h=(temp[2]<<8)|temp[3];
  // ensure valid size
  if(*w==0||*h==0) return NULL;
  // ensure correct size
  if(bytes!=4+*w**h) return NULL;
  // read picture - w*h bytes: top-down, left-right, 8bpp grayscale
  p_img=image_alloc(*w,*h);
  fread(p_img,1,*w**h,f);
  return p_img;
}