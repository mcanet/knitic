// C++ wrapper class for library functions
//
// Requires inclusion of lib/src/*.c in project
//
// senseitg@gmail.com 2012-May-22

#include "knit.h"

knit::knit() {
	machine_init();
    machine_model = 0;
}

machine_t *knit::driver_get(uint8_t index) {
	return machine_get(index);
}

 // load img
bool knit::memory_load(char *path) {
	return machine_load(path);
}

 // save img
bool knit::memory_save(char *path) {
	return machine_save(path);
}

// start to send memory with patterns added to machine by serial 
void knit::emulate_start(char *device,bool verbose) {
	machine_emulate(device,verbose?stdout:NULL);
}

// stop to serial comunication to machine 
void knit::emulate_stop() {
	emulate_stop();
}

// select machine model 
// 0 = kh940
// 1 = kh930
void knit::set_machine_model(uint8_t) {
	emulate_stop();
}

// Add pattern to machine memory
int knit::add_pattern(uint8_t *p_img,uint16_t w,uint16_t h){
    p_mach = driver_get(machine_model);
    uint16_t ptn_id;
    ptndesc_t desc;
    bool halt=false;
    // verify machine capability
    if(p_mach->size_check(w,h)) {
        if(p_img) {
            // add pattern to memory
            ptn_id=p_mach->add_pattern(p_img,w,h);
            if(ptn_id==0) {
                printf("Not enough memory to store pattern\n");
                if(halt) {
                    free(p_img);
                    //exit(1);
                }
                return 1;
            }
            if(find_pattern(&desc,ptn_id) ) {
                printf("added pattern %i as %ix%i @0x%04X\n",desc.id,desc.width,desc.height,desc.pattern);
            } else {
                printf("pattern was added but can not be found\n");
                printf("memory may be corrupted, format suggested\n");
                return 2;
            }
            // free loaded data
            free(p_img);
        } else {
            printf("file does not have the correct format\n");
            //if(halt) exit(1);
            return 3;
        }
    } else {
        printf("pattern is too big for this machine\n");
        //if(halt) exit(1);
        return 4;
    }
    return 0;
}

// find and read pattern with specific pattern number/id
// return true if found
bool knit::find_pattern(ptndesc_t *p_desc,uint32_t ptn_id) {
	uint8_t n;
	for(n=0;n<=p_mach->pattern_max-p_mach->pattern_min;n++) {
		if(p_mach->decode_header(p_desc,n)){
			if(p_desc->id==ptn_id) return true;
		}
	}
	return false;
}

//format memory machine to clear all patterns and prepare to add new ones
void knit::format_memory(){
	// will return NULL if machine index not available
    p_mach=machine_get(0); // put in index for different machine 0 is kh940 1 is kh930
    // do format
    p_mach->format();
    // change track
    p_mach->set_track(0);
}

unsigned char* knit::getMachineMemory(){
    return ;
}

int knit::getTotalPatterns(){
    //p_mach->track_count;
    return 0;
}

int knit::getTotalMemoryUsed(){
    return 0;//p_mach->memory_used;
}

int knit::getTotalMemory(){

}
