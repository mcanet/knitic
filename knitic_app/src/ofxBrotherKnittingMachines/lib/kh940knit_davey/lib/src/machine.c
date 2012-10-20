// Source file for machine definitions
//
// Currently supports:
// * Brother Electroknit KH-940
// * Brother Electroknit KH-930
//
// senseitg@gmail.com 2012-May-22

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "machine.h"
#include "emulate.h"
#include "fileio.h"

#define MACHINE_COUNT 2

static machine_t mach[MACHINE_COUNT];
static machine_t *p_mach=mach;
static uint8_t data[81920];
static uint8_t sids[960];

// Machine initialisers
void kh930_init(machine_t *p_machine,uint8_t *p_disk_data,uint8_t *p_disk_sids);
void kh940_init(machine_t *p_machine,uint8_t *p_disk_data,uint8_t *p_disk_sids);

// Initialize machine and add it to list of machines 
static void machine_add(const char *p_code,void(*fp_init)(machine_t*,uint8_t*,uint8_t*)) {
	strcpy(p_mach->code,p_code);
	fp_init(p_mach++,data,sids);
}

// Initialize all machines
void machine_init() {
	machine_add("kh940",kh940_init);
	machine_add("kh930",kh930_init);
}

// Retrieve machine descriptor
machine_t *machine_get(uint8_t index) {
	if(index<MACHINE_COUNT)return &mach[index];
	return NULL;
}

// Load machine memory from disk
bool machine_load(char *path) {
	return disk_read(path,data,sids);
}

// Save machine memory to disk
bool machine_save(char *path) {
	return disk_write(path,data,sids);
}

// Start the emulator
void machine_emulate(char *device,FILE *verbose) {
	emulate(device,data,sids,verbose);
}


