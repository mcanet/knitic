// C++ wrapper class for library functions
//
// senseitg@gmail.com 2012-May-22
#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "machine.h"
#include "emulate.h"

class knit {
private:
    machine_t *p_mach;
    uint8_t machine_model;
    
    // Get machine pointer 
    machine_t *driver_get(uint8_t index);
    
public:
    knit();
	
    // load img
    bool memory_load(char *path);
	
    // save img
    bool memory_save(char *path);
	
    // start to send memory with patterns added to machine by serial 
    void emulate_start(char *device,bool verbose);
    
    // stop to serial comunication to machine 
	void emulate_stop();

    // Add pattern to machine memory
    int add_pattern(uint8_t *p_img,uint16_t w,uint16_t h);

    // find and read pattern with specific pattern number/id
    // return true if found
    bool find_pattern(ptndesc_t *p_desc,uint32_t ptn_id) ;

    //format memory machine to clear all patterns and prepare to add new ones
    void format_memory();
    
    // select machine model 
    // 0 = kh940
    // 1 = kh930
    void set_machine_model(uint8_t);
    
    unsigned char* getMachineMemory();
    
    int getTotalPatterns();
    int getTotalMemoryUsed();
    int getTotalMemory();
};

