// Source file for disk image file I/O
//
// Supports proprietary disk image format and
// Steve Conclin's floppy emulator data folders
//
// senseitg@gmail.com 2012-May-22

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include "fileio.h"

// write out a disk image or floppy emulator folder
bool disk_write(char *path,uint8_t *data, uint8_t *sids) {
	uint8_t n;
	char fn[256];
	uint32_t temp;
	FILE *f;
  temp=strlen(path)-1;
  if(path[temp]==PATH_SEPARATOR) {
  	//folder
  	path[temp+3]=0;
  	for(n=0;n<80;n++) {
    	path[temp+1]='0'+(n/10);
    	path[temp+2]='0'+(n%10);
  		//read id
    	strcpy(fn,path);
    	strcat(fn,".id");
  	  f=fopen(fn,"wb");
  	  if(f) {
  	  	fwrite(&sids[n*12],1,12,f);
  	  	fclose(f);
  		} else break;
  		//read sector
    	strcpy(fn,path);
    	strcat(fn,".dat");
  	  f=fopen(fn,"wb");
  	  if(f) {
  	  	fwrite(&data[n<<10],1,1024,f);
  	  	fclose(f);
  		} else break;
  	}
  	if(n==80) return true;
  } else {
  	f=fopen(path,"wb");
  	if(f) {
  		fwrite(data,1,81920,f);
  		fwrite(sids,1,960,f);
  		return true;
  	}
  }
  return false;
}

// read in a disk image or floppy emulator folder
bool disk_read(char *path,uint8_t *data,uint8_t *sids) {
	uint8_t n;
	uint32_t ptn_id;
	char fn[256];
	uint32_t temp;
	FILE *f;
  temp=strlen(path)-1;
  if(path[temp]==PATH_SEPARATOR) {
  	//folder
  	path[temp+3]=0;
  	for(n=0;n<80;n++) {
	  	path[temp+1]='0'+(n/10);
	  	path[temp+2]='0'+(n%10);
  		//read id
	  	strcpy(fn,path);
	  	strcat(fn,".id");
		  f=fopen(fn,"rb");
		  if(f) {
		  	fread(&sids[n*12],1,12,f);
		  	fclose(f);
			} else break;
  		//read sector
	  	strcpy(fn,path);
	  	strcat(fn,".dat");
		  f=fopen(fn,"rb");
		  if(f) {
		  	fread(&data[n<<10],1,1024,f);
		  	fclose(f);
			} else break;
  	}
		if(n==80) return true;
  } else {
	  f=fopen(path,"rb");
	  if(f) {
	  	fseek(f,0,SEEK_END);
	  	if(ftell(f)==81920+960) {
	  		fseek(f,0,0);
	  		fread(data,1,81920,f);
  			fread(sids,1,960,f);
	  		fclose(f);
	  		return true;
	  	}
	  	fclose(f);
	  }
	}
	return false;
}