// Header file for machine definitions
//
// senseitg@gmail.com 2012-May-22
#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

// pattern info
typedef struct {
	uint16_t id;
	uint32_t location;
	uint16_t width;
	uint16_t height;
	uint32_t pattern;
} ptndesc_t;

// machine descriptor
typedef struct {
	char code[16];
  char *name;
  uint16_t (*memory_used)(ptndesc_t* p_desc);
  bool (*decode_header)(ptndesc_t* p_desc,uint8_t index);
  void (*decode_pattern)(ptndesc_t* p_desc,uint8_t *p_image);
  void (*format)(void);
  void (*set_track)(uint8_t track);
  uint8_t (*get_track)(void);
  bool (*size_check)(uint16_t width,uint16_t height);
  uint16_t (*add_pattern)(uint8_t *p_image,uint16_t width,uint16_t height);
  void (*info)(FILE *output);
  uint16_t pattern_min;
  uint16_t pattern_max;
  uint16_t track_count;
} machine_t;

// Initialize all machines
// Must be called before machine_Get
void machine_init();

// Get machine descriptor with specific index
// Returns NULL if not found
machine_t *machine_get(uint8_t index);

// Load machine memory from disk
bool machine_load(char *path);

// Save machine memory to disk
bool machine_save(char *path);

// Start floppy drive emulator
void machine_emulate(char *device,FILE *verbose);
        
#ifdef __cplusplus
}
#endif
