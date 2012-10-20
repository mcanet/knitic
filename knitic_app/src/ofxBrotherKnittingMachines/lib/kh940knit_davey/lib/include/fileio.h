// Header for disk image file I/O
//
// senseitg@gmail.com 2012-May-22
#pragma once
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
#define PATH_SEPARATOR '\\'
#else
#define PATH_SEPARATOR '/'
#endif

// write out a disk image or floppy emulator folder
// pass path to read folder, file to read disk image
bool disk_write(char *path,uint8_t *data, uint8_t *sids);

// read in a disk image or floppy emulator folder
// pass path to read folder, file to read disk image
bool disk_read(char *path,uint8_t *data,uint8_t *sids);

#ifdef __cplusplus
}
#endif
