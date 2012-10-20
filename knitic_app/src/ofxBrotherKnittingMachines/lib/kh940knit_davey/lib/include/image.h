// Header file for image management functions
//
// senseitg@gmail.com 2012-May-22
#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

// allocate memory for image
uint8_t *image_alloc(uint16_t width,uint16_t height);

// get pixel from image
bool image_sample(uint8_t *p_image,uint16_t width,uint16_t x,uint16_t y);

// set pixel in image
void image_pset(uint8_t *p_image,uint16_t width,uint16_t x,uint16_t y,bool pixel);

// read image file
uint8_t *image_read(FILE *f,uint16_t *width,uint16_t *height);

#ifdef __cplusplus
}
#endif
