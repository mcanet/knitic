// Source file for the command line disk image manager
// See README for HOW TO USE
//
// senseitg@gmail.com 2012-May-17

//== DECLARATIONS ====================================================

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "machine.h"
#include "image.h"

// command memory
static char cmds[8192]={0};
static char cmd[256];

// flags
static bool halt=false;

// machine
static machine_t *p_mach;

//== UTIL FUNCTIONS ==================================================

// command input routine that handles several
// commands in one input as well as strings
static bool read_cmd(const char *fail) {
	char *ret;
	char *p_src,*p_dst;
	uint16_t len;
	bool out=false;
	if(strlen(cmds)==0) {
		if(fgets(cmds,sizeof(cmds),stdin)==NULL) {
		  strcpy(cmds,fail);
		  out=true;
		} else {
		  len=strlen(cmds);
		  if(cmds[len-1]=='\n') cmds[len-1]=0;
		}
		//count leading spaces
		p_src=cmds;
		while(*p_src==' ') p_src++;
		if(*p_src==0) {
			//just spaces
			cmds[0]=0;
		} else {
			//trim leading spaces
			memmove(cmds,p_src,strlen(p_src)+1);
			//trim trailing spaces
			p_src=cmds+strlen(cmds)-1;
			while(*p_src==' ')*p_src--=0;
		}
	} else {
		out=true;
	}
	//have nothing
	if(strlen(cmds)==0) return false;
	p_dst=cmd;
	p_src=cmds;
	while(*p_src==' ') p_src++;
	if(*p_src=='"') {
		p_src++;
		while(*p_src!='"'&&*p_src!=0) *p_dst++=*p_src++;
		if(*p_src=='"')p_src++;
	} else {
		while(*p_src!=' '&&*p_src!=0) *p_dst++=*p_src++;
	}
	*p_dst=0;
	if(out)puts(cmd);
	memmove(cmds,p_src,strlen(p_src)+1);
	return true;
}

// convert pattern id as string to int
static uint16_t str_to_id(char *str) {
	uint16_t out=0;
	while(*str!=0){
		if(*str<'0'||*str>'9') return 0;
		out=out*10+*str++-'0';
		if(out>p_mach->pattern_max) return 0;
	}
	if(out<p_mach->pattern_min) return 0;
	return(out);
}

// convert track id as string to int
static uint8_t trk_to_id(char *str) {
	uint8_t out=0;
	while(*str!=0){
		if(*str<'0'||*str>'9') return 0;
		out=out*10+*str++-'0';
		if(out>p_mach->track_count) return 0;
	}
	if(out<1) return 0;
	return(out);
}


// format with printout
void cmd_format() {
  p_mach->format();
  p_mach->set_track(0);
	printf("memory initialized, track is 1\n");
}

// prompt for set current track
static void cmd_track() {
	uint8_t trk_id;
	printf("current track is %i\n",p_mach->get_track()+1);
	printf("track> ");
	if(read_cmd("")) {
		trk_id=trk_to_id(cmd);
		if(trk_id) {
		  p_mach->set_track(trk_id-1);
		  printf("track is now %s\n",cmd);
		} else {
			printf("need number between 1 and %i\n",p_mach->track_count);
		  if(halt) exit(1);
		}
	}
}

// print image to screen
static void image_print(uint8_t *p_img,uint16_t w,uint16_t h) {
	uint16_t x,y;
	for(y=0;y<h;y++) {
		for(x=0;x<w;x++) {
			putchar(image_sample(p_img,w,x,y)?'X':'-');
		}
		printf("\n");
	}
}

// display patterns contained in memory
static void cmd_show() {
	uint8_t n;
	uint16_t ptn_id;
	ptndesc_t desc;
	uint8_t *p_img;
	for(n=0;n<98;n++) {
		if(p_mach->decode_header(&desc,n)) {
			printf("pattern %i is %ix%i @0x%04X\n",desc.id,desc.width,desc.height,desc.pattern);
		}
	}
	while(1) {
		printf("pattern> ");
		if(!read_cmd("")) break;
		if(strcmp(cmd,"d")==0||strcmp(cmd,"done")==0) break;
		ptn_id=str_to_id(cmd);
		if(ptn_id) {
			if(machine_find_pattern(&desc,ptn_id)){
				p_img=image_alloc(desc.width,desc.height);
				p_mach->decode_pattern(&desc,p_img);
				image_print(p_img,desc.width,desc.height);
				free(p_img);
			} else {
				printf("pattern number %i does not exist\n",ptn_id);
        if(halt) exit(1);
			}
		} else {
			printf("need done or number between %i and %i\n",p_mach->pattern_min,p_mach->pattern_max);
		  if(halt) exit(1);
		}
	}
}

// add pattern from file
static void cmd_add() {	
	uint8_t *p_img;
	uint16_t w,h;
	FILE *f;
	uint16_t ptn_id;
	ptndesc_t desc;
	printf("filename> ");
	if(read_cmd("")) {
	  f=fopen(cmd,"rb");
	  if(f) {
      // read image file
      p_img=(uint8_t*)image_read(f,&w,&h);
	  	fclose(f);
	  	// verify machine capability
	  	if(p_mach->size_check(w,h)) {
	      if(p_img) {
	      	// display
	      	image_print(p_img,w,h);
					// add pattern to memory
					ptn_id=p_mach->add_pattern(p_img,w,h);
					if(ptn_id==0) {
	      	  printf("not enough memory to store pattern\n");
		  		  if(halt) {
		  		  	free(p_img);
		  		  	exit(1);
		  		  }
					}
	      	if(find_pattern(&desc,ptn_id) ) {
	      		printf("added pattern %i as %ix%i @0x%04X\n",desc.id,desc.width,desc.height,desc.pattern);
	      	} else {
	      		printf("pattern was added but can not be found\n");
	      		printf("memory may be corrupted, format suggested\n");
	      	}
	      	// free loaded data
	      	free(p_img);
	  		} else {
	  		  printf("file does not have the correct format\n");
	  		  if(halt) exit(1);
	  		}
	  	} else {
		  	printf("pattern is too big for this machine\n",cmd);
			  if(halt) exit(1);
	  	}
	  } else {
	  	printf("unable to open file %s\n",cmd);
		  if(halt) exit(1);
	  }
	}
}

void cmd_read() {
	printf("file/directory> ");
	if(read_cmd("")) {
		if(machine_load(cmd)) {
			printf("disk image loaded\n");
		} else {
			printf("unable to read specified file/directory\n");
			printf("memory may be corrupted, format suggested\n");
		}
	}	
}

void cmd_write() {
	printf("file/directory> ");
	if(read_cmd("")) {
		if(machine_save(cmd)) {
			printf("disk image saved\n");
		} else {
			printf("unable to write specified file/directory\n");
		}
	}	
}

void cmd_emulate() {
	printf("device> ");
	if(read_cmd("")) {
		machine_emulate(cmd,stdout);
	}
}

void cmd_machine() {
	uint8_t n;
	machine_t *p_machtemp;
	printf("current machine is %s\n",p_mach->name);
	for(n=0;n<255;n++) {
		p_machtemp=machine_get(n);
		if(p_machtemp==NULL)break;
		printf("machine %s is %s\n",p_machtemp->code,p_machtemp->name);
	}
	printf("machine> ");
	if(read_cmd("")) {
		for(n=0;n<255;n++) {
			p_machtemp=machine_get(n);
			if(p_machtemp==NULL)break;
			if(strcmp(p_machtemp->code,cmd)==0) {
				p_mach=p_machtemp;
				printf("machine is now %s\n",p_mach->name);
				return;
			}
		}
	}
	printf("machine %s not found\n",cmd);
	if(halt) exit(1);
}

/*
// do the nasty
int main(int argc,char**argv) {
	uint8_t n;
	uint8_t *hdr;
	uint32_t ptn_id;
	FILE *f;
	// skip executable
	if(argc) {
		argc--;
		argv++;
	}
	// fetch arguments
	while(argc--) {
		strcat(cmds,*argv++);
		if(argc)strcat(cmds," ");
	}
	// initialize machine
	machine_init();
	p_mach=machine_get(0);
	// show machine
	printf("machine is %s\n",p_mach->name);
	// init memory
	cmd_format();
	while(1) {
		printf("> ");
		if(read_cmd("q")) {
			if(strcmp(cmd,"help")==0||strcmp(cmd,"?")==0) {
				printf("?/help      show this\n");
				printf("r/read      read in data from file\n");
				printf("w/write     write out data to file\n");
				printf("m/machine   select knitting machine\n");
				printf("f/format    clear all tracks\n");
				printf("t/track     set working track\n");
				printf("a/add       add pattern to track\n");
				printf("s/show      display content of track\n");
				printf("i/info      additional track info\n");
				printf("e/emulate   emulate floppy\n");
				printf("q/quit      end program\n");
				printf("x/halt      halt on errors\n");
			} else if(strcmp(cmd,"x")==0||strcmp(cmd,"halt")==0) {
	  		halt=!halt;
	  		printf("halt on errors: %s\n",halt?"yes":"no");
			} else if(strcmp(cmd,"quit")==0||strcmp(cmd,"q")==0) {
				printf("See you!\n");
				exit(0);
			} else if(strcmp(cmd,"r")==0||strcmp(cmd,"read")==0) {
				cmd_read();
			} else if(strcmp(cmd,"w")==0||strcmp(cmd,"write")==0) {
				cmd_write();
			} else if(strcmp(cmd,"m")==0||strcmp(cmd,"machine")==0) {
				cmd_machine();
			} else if(strcmp(cmd,"t")==0||strcmp(cmd,"track")==0) {
	  		cmd_track();
			} else if(strcmp(cmd,"f")==0||strcmp(cmd,"format")==0) {
	  		cmd_format();
			} else if(strcmp(cmd,"a")==0||strcmp(cmd,"add")==0) {
	  		cmd_add();
			} else if(strcmp(cmd,"i")==0||strcmp(cmd,"info")==0) {
	  		p_mach->info(stdout);
			} else if(strcmp(cmd,"s")==0||strcmp(cmd,"show")==0) {
				cmd_show();
			} else if(strcmp(cmd,"e")==0||strcmp(cmd,"emulate")==0) {
        cmd_emulate();
			} else {
				printf("Unrecognized command: %s\n",cmd);
  		  if(halt) exit(1);
			}
		}
	}
}
 
*/