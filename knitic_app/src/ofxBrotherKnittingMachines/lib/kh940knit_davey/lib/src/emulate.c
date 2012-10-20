// Source file for Tandy PDD1 floppy drive emulator
//
// Supports only a limited subset of actual drive
//   Sector size locked to 1024
//   In operation mode:
//     Switch to FDC emulation mode
//   In FDC emulation mode
//     Format (only to sector size 1024)
//     Read/write sector ID
//     Read/write sector DATA
//     Search for sector with ID
//
// senseitg@gmail.com 2012-May-22

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include "serial.h"
#include "emulate.h"

uint8_t *p_sect, *p_sids;

bool stop=false;
FILE* p_out=NULL;

// serial write with error printing
static int32_t eswrite(void* p_write,uint16_t i_write) {
	if(swrite(p_write,i_write)!=i_write) if(p_out)fprintf(p_out,"unable to write to serial port\n");
}

// op mode command executer
void exec_op(uint8_t cmd[]) {
	if(cmd[0]==0x08) {
		if(p_out)fprintf(p_out,"[op mode] recv 0x08 [fdc mode  ]\n");
	} else {
		if(p_out)fprintf(p_out,"[op mode] recv 0x%02X bad/unsupported command\n",cmd[0]);
	}
}

// returns pointer to name of fdc command
static const char* fdc_name(uint8_t cmd) {
	switch(cmd) {
		case 'A':           return "read id   ";
		case 'R':           return "read sect ";
		case 'S':           return "find sect ";
		case 'B': case 'C': return "write id  ";
		case 'W': case 'X': return "write sect";
		default: return "?";
	}
}

// make hex char
static char hexchar(uint8_t c) {
  if(c<10)return '0'+c;
  return 'A'+c-10;
}

// sets successful response code
static void fdc_ok(char *p_ret,uint8_t sect) {
  strcpy(p_ret,"00000000");
  p_ret[2]=hexchar(sect>>4);
  p_ret[3]=hexchar(sect&0xF);
}

// fdc mode command executer
static uint16_t exec_fdc(uint8_t cmd[0]) {
	char ret[9]="80000000";
	uint16_t count=0;
	uint8_t n;
	if(cmd[0]=='F'||cmd[0]=='G') {
		// check length code (but format anyways)
		if(cmd[1]!=5) if(p_out)fprintf(p_out,"recv %02X [format    ] unsupported length code 0x%02X\n",cmd[0],cmd[1]);
		// format memory
		memset(p_sect,0x00,80*1024);
		for(n=0;n<80;n++) memset(&p_sids[n*12],0x00,12);
		// respond ok
		strcpy(ret,"00000000");
		if(p_out)fprintf(p_out,"[fdc emu] exec 0x%02X [format    ] resp: %s\n",cmd[0],ret);
	} else {
		if(cmd[1]==0xFF)cmd[1]=0; // physical sector default
		if(cmd[2]==0xFF)cmd[2]=1; // logical sector default
		// check sector validity
		if(cmd[1]<80&&cmd[2]==1) {
			// respond ok
			fdc_ok(ret,cmd[1]);
			// return
			switch(cmd[0]) {
				case 'A': case 'R':           count=   1; break;
				case 'S': case 'B': case 'C': count=  12; break;
				case 'W': case 'X':           count=1024; break;
			}
			if(p_out)fprintf(p_out,"[fdc emu] recv 0x%02X [%s] resp: %s expect %i bytes\n",cmd[0],fdc_name(cmd[0]),ret,count);
		} else if(p_out)fprintf(p_out,"[fdc emu] recv 0x%02X [%s] resp: %s bad sector %i\\%i\n",cmd[0],fdc_name(cmd[0]),ret,cmd[1],cmd[2]);
	}
	// send response
	eswrite(ret,8);
	return count;
}

// fdc mode command+data executer
static void exec_fdc_data(uint8_t *cmd) {
	char ret[9];
	uint8_t *p_data=&cmd[4];
	uint8_t n;
	switch(cmd[0]) {
		case 'A': 					// read sector id
			if(*p_data=='\x0D') eswrite(&p_sids[cmd[1]*12],12);
			if(p_out)fprintf(p_out,"[fdc emu] exec 0x%02X [%s]\n",cmd[0],fdc_name(cmd[0]));
			return;
		case 'R': 					// read sector data
			if(*p_data=='\x0D') eswrite(&p_sect[(uint16_t)(cmd[1])<<10],1024);
			if(p_out)fprintf(p_out,"[fdc emu] exec 0x%02X [%s]\n",cmd[0],fdc_name(cmd[0]));
			return;
		case 'S': 					// find sector
			strcpy(ret,"40000000"); // fail
			for(n=0;n<80;n++) {
				if(memcmp(&p_sids[n*12],p_data,12)==0) {
					fdc_ok(ret,n); // success
					break;
				}
			}
			break;
		case 'B': case 'C': // write sector id
			memcpy(&p_sids[cmd[1]*12],p_data,12);
			fdc_ok(ret,cmd[1]);
			break;
		case 'W': case 'X': // write sector data
			memcpy(&p_sect[(uint16_t)(cmd[1])<<10],p_data,1024);
			fdc_ok(ret,cmd[1]);
			break;
	}
	if(p_out)fprintf(p_out,"[fdc emu] exec 0x%02X [%s] resp: %s\n",cmd[0],fdc_name(cmd[0]),ret);
	eswrite(ret,8);
}

// stop emulator
void emulate_stop() {
	stop=true;
}

// ctrl^c handler
static void sigint(int z) {
  emulate_stop();
}

// start emulator
void emulate(char *device,uint8_t *p_sect_data,uint8_t *p_sids_data,FILE *verbose) {
  uint8_t byte;
  uint8_t state,csum;
  uint16_t count;
 	uint8_t buf[1028],*p_buf;
 	uint8_t rx[1024],*p_rx;
 	char fmt[]="9600,N,8,1";
 	p_sect=p_sect_data;
 	p_sids=p_sids_data;
 	p_out=verbose;
	if(sopen(device)) {
	  if(p_out)fprintf(p_out,"serial port open\n");
	  if(!sconfig(fmt)) {
	    if(p_out)fprintf(p_out,"unable to configure serial port - ignoring\n");
	  }
    if(p_out)fprintf(p_out,"serial port listening... (ctrl)^C/SIGINT to stop\n");
  	// listen for ctrl^C
  	stop=false;
  	signal(SIGINT,sigint);
    while(!stop) {
      if(sread(&byte,1)==1) {
        switch(state) {
          case 0:
            if(byte=='Z') state=1;
            else if(byte!=0x00&&strchr("FGARSBCWX",byte)!=NULL) {
            	p_buf=buf;
            	*p_buf++=csum=byte;
            	buf[1]=buf[2]=0xFF;
            	state=6;
            } else if(byte!=0x0D) { // ignore blank commands
              if(p_out)fprintf(p_out,"[general] recv 0x%02X bad/unsupported command\n",byte);
            }
            break;
          case 1: // opmode second preamble
            if(byte=='Z') state=2;
           	else if(p_out)fprintf(p_out,"[op mode] recv 0x%02X expected preamble 0x5A\n",byte);
           	break;
          case 2: // opmode block format
          	p_buf=buf;
          	*p_buf++=csum=byte;
          	state=3;
          	break;
          case 3: // opmode length of data block
          	state=(count=byte)?4:5;
          	csum+=byte;
          	break;
          case 4: // opmode data block (ignored)
        		csum+=byte;
          	if(--count==0) state=5;
          	break;
          case 5: // opmode checksum
          	if((csum^0xFF)==byte) exec_op(buf);
          	else if(p_out)fprintf(p_out,"[op mode] recv 0x%02X expected checksum 0x%02X\n",byte,csum^0xFF);
          	state=0;
          	break;
          case 6: // fdc params
        		if(byte=='\x0D'||byte=='\x0A') {
        			if(*p_buf==0xFF) p_buf--;
        			count=exec_fdc(buf);
        			state=count?7:0;
        			p_buf=&buf[4];
        		} else if(byte==',') {
        			if(++p_buf>&buf[3]) {
        				if(p_out)fprintf(p_out,"[fdc emu] recv too many parameters\n");
        				state=0;
        			}
        		} else if(byte>='0'&&byte<='9') {
        			if(*p_buf==0xFF)*p_buf=0;
        			*p_buf*=10;
        			*p_buf+=byte-'0';
        		} else if(byte!=' ') {
        			if(p_out)fprintf(p_out,"[fdc emu] recv 0x%02X expected parameter data\n",byte);
        			state=0;
        		}
          	break;
          case 7: // fdc data
          	*p_buf++=byte;
          	if(--count==0) {
          		exec_fdc_data(buf);
          		state=0;
          	}
          	break;
        }
      }
    }
	  if(sclose()) {
	    if(p_out)fprintf(p_out,"serial port closed\n");
	  } else  {
	    if(p_out)fprintf(p_out,"unable to close serial port\n");
	  }
	} else {
	  if(p_out)fprintf(p_out,"unable to open serial port\n");
  }
}
