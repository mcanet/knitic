// Source file for the Brother Electroknit KH-930 machine specifics
//
// senseitg@gmail.com 2012-May-22

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "machine.h"
#include "util.h"
#include "image.h"

static uint8_t *p_data; //81920
static uint8_t *p_sids; //960
static uint8_t *p_track;

static char name[]="Brother Electroknit KH-930 (BETA)";

// return nof bytes used (excl header) by currently loaded pattern
static uint16_t get_size(ptndesc_t *p_desc) {
	return ((p_desc->height+1)>>1)+(((((p_desc->width+3)>>2)*p_desc->height)+1)>>1);
}

// decode header and store in global ptn
// return pattern number if successful
static bool decode_header(ptndesc_t *p_desc,uint8_t index) {
	uint8_t *p_hdr=&p_track[index*7];
	if(p_hdr[0]!=0x00) {
		p_desc->location = 0x7FF-(index*7);
		p_desc->pattern =p_hdr[0]<<8;			
		p_desc->pattern|=p_hdr[1];					
		p_desc->height =MSN(p_hdr[2])*100;
		p_desc->height+=LSN(p_hdr[2])*10; 
		p_desc->height+=MSN(p_hdr[3])*1;  
		p_desc->width  =LSN(p_hdr[3])*100;
		p_desc->width +=MSN(p_hdr[4])*10; 
		p_desc->width +=LSN(p_hdr[4])*1;
		if(p_desc->width==0&&p_desc->height==0) return false;
		if(MSN(p_hdr[5])!=0) return false;
		p_desc->id =LSN(p_hdr[5])*100;
		p_desc->id+=MSN(p_hdr[6])*10; 
		p_desc->id+=LSN(p_hdr[6])*1;
		if(p_desc->id==0) return false;
		if(p_desc->id>=901&&p_desc->id<=998) return true;
	}
	return false;
}

// decode a pattern from memory
// caller must make sure p_image can hold image by using image_alloc
static void decode_pattern(ptndesc_t *p_desc,uint8_t *p_image) {
	uint32_t stride,memo,nptr;
	uint32_t x,y;
	
	stride=(p_desc->width+3)>>2; // nof nibbles per row
	memo=(p_desc->height+1)&~1;  // nof nibbles for memo
	
	// calculate nibble pointer
  nptr = 0xFFF-(p_desc->pattern<<1)-(memo+stride*(p_desc->height-1));
	
  // decode pattern
  for(y=0;y<p_desc->height;y++) {
  	for(x=0;x<p_desc->width;x++) {
  		image_pset(p_image,p_desc->width,x,y,(nib_get(p_track,nptr-(x>>2))&(1<<(x&3))));
  	}
  	nptr+=stride;
  }
}

// format memory
static void format() {
	uint8_t n;
	uint8_t *p_trk;
	// set sector ids
	for(n=0;n<80;n++){
		memset(&p_sids[n*12],0,12);
		p_sids[n*12]=n<64?(n/2)+1:0;
	}
	for(n=0;n<2;n++) {
  	p_trk=&p_data[n<<11];
  	// clear data
  	memset(p_trk,0x00,2048);
  	p_trk[0x005]=0x09; // pattern 901 partial header data
  	p_trk[0x006]=0x01;
  	p_trk[0x700]=0x01; // next offset
    p_trk[0x701]=0x20;
  	p_trk[0x710]=0x07; // pointer1
  	p_trk[0x711]=0xF9;
    p_trk[0x7EA]=0x10; // 1xxx BCD (000=no pattern)
  }
}

// set current track
static void set_track(uint8_t track) {
  p_track=&p_data[(track)<<11];
}

// get current track
static uint8_t get_track() {
  return (p_track-p_data)>>11;
}

// return true if machine can handle this size pattern
static bool size_check(uint16_t w,uint16_t h) {
	// TODO: return w<?&&h<?;
	return true;
}

// add pattern to memory
// p_image must have width*height bytes
static uint16_t add_pattern(uint8_t *p_image,uint16_t w,uint16_t h) {
	uint8_t   n;
	uint16_t  ptn_id;
	uint32_t  temp;
	uint16_t  x,y;
	uint8_t  *p_memory;
	uint16_t  b_stride;
	uint32_t  bp_last,bp_line,bp_this;
	uint16_t  memo_bytes,data_bytes;
	uint16_t  o_bottom;
	uint8_t   hdr_index;
	ptndesc_t desc;

	// find index&id
	ptn_id=901;
	hdr_index=0;
	for(n=0;n<98;n++) {
		if(decode_header(&desc,n)) {
		  hdr_index=n+1;
			if(desc.id>=ptn_id) ptn_id=desc.id+1;
	  }
	}

  // remember bottom offset
	o_bottom=int_get(p_track,0x700);

  // calculate bytes needed to store pattern
	memo_bytes=(h+1)>>1;
	data_bytes=((((w+3)>>2)*h)+1)>>1;
	
	// Check memory availability (should be 0x2AE, but leave some to be sure)
	if(0x7FF-(o_bottom+memo_bytes+data_bytes)>=0x02B0&&ptn_id<999) {

  	// make memo data
  	p_memory=(uint8_t*)malloc(memo_bytes);
  	memset(p_memory,0,memo_bytes);
  	// set memo data
  	memset(p_memory,0,memo_bytes);
  	// insert into memory @ PATTERN_PTR1
  	memcpy(&p_track[0x800-int_get(p_track,0x700)-memo_bytes],p_memory,memo_bytes);
  	// update PATTERN_PTR1
  	int_set(p_track,0x700,int_get(p_track,0x700)+memo_bytes);
    // free memo data
    free(p_memory);	  	
  	
  	// make pattern data
  	p_memory=(uint8_t*)malloc(data_bytes);
  	memset(p_memory,0,data_bytes);
  	// stride (bits per row)
  	b_stride=(w+3)&~3;
  	// calculate index of last bit in pattern
  	bp_last=(data_bytes<<3)-1;
		// set pattern data
		for(y=0;y<h;y++) {
      // calculate index of last bit on line
      bp_line=bp_last-b_stride*(h-y-1);
      for(x=0;x<w;x++) {
        // calculate index of the current bit
        bp_this=bp_line-x;
        // sample image
        if(image_sample(p_image,w,x,y)) bit_set(p_memory,bp_this);
      }
    }
  	// insert into memory @ PATTERN_PTR1
  	memcpy(&p_track[0x0800-int_get(p_track,0x700)-data_bytes],p_memory,data_bytes);
  	// update PATTERN_PTR1
  	int_set(p_track,0x700,int_get(p_track,0x700)+data_bytes);
    // free pattern data 
  	free(p_memory);

  	// write header
  	p_track[hdr_index*7+0]=o_bottom>>8;						  // byte 0
  	p_track[hdr_index*7+1]=o_bottom&0x00FF;					// byte 1
		nib_set(p_track,hdr_index*14+ 4,bcd_get(h,100));			// byte 2
		nib_set(p_track,hdr_index*14+ 5,bcd_get(h, 10));
		nib_set(p_track,hdr_index*14+ 6,bcd_get(h,  1));  		// byte 3
		nib_set(p_track,hdr_index*14+ 7,bcd_get(w,100));
		nib_set(p_track,hdr_index*14+ 8,bcd_get(w, 10));			// byte 4
		nib_set(p_track,hdr_index*14+ 9,bcd_get(w,  1));
		nib_set(p_track,hdr_index*14+10,0);							 			// byte 5
		nib_set(p_track,hdr_index*14+11,bcd_get(ptn_id,100));
		nib_set(p_track,hdr_index*14+12,bcd_get(ptn_id, 10)); // byte 6
		nib_set(p_track,hdr_index*14+13,bcd_get(ptn_id,  1));

		// write FINHDR
		hdr_index++;
		nib_set(p_track,hdr_index*14+10,0);								 			// byte 5
		nib_set(p_track,hdr_index*14+11,bcd_get(ptn_id+1,100));
		nib_set(p_track,hdr_index*14+12,bcd_get(ptn_id+1, 10)); // byte 6
		nib_set(p_track,hdr_index*14+13,bcd_get(ptn_id+1,  1));

		// write LOADED_PATTERN 
		nib_set(p_track,(0x7EA<<1)+0,0x01);
		nib_set(p_track,(0x7EA<<1)+1,bcd_get(ptn_id,100));
		nib_set(p_track,(0x7EA<<1)+2,bcd_get(ptn_id, 10));
		nib_set(p_track,(0x7EA<<1)+3,bcd_get(ptn_id, 1));

		// write UNK1
		int_set(p_track,0x702,0x0001);
		
		// copy PATTERN_PTR1 to PATTERN_PTR2
		int_set(p_track,0x704,int_get(p_track,0x700));

		// write LAST_BOTTOM
		int_set(p_track,0x706,o_bottom);

		// write LAST_TOP
		int_set(p_track,0x70A,int_get(p_track,0x704)-2);

		// write UNK3
		int_set(p_track,0x70E,0x8100);

		// write HEADER_PTR
		int_set(p_track,0x710,0x7FF-(hdr_index+1)*7+1);

		// return id
		return ptn_id;
	}
	return 0;
}

// print out and validate non-pattern information
static void info(FILE *output) {
	uint16_t last_pattern,sel_pattern;
	uint8_t n;
	uint8_t rep[5];
	uint16_t addr;
	ptndesc_t desc, temp;
	
	// read selected pattern
	sel_pattern = LSN(p_track[0x7EA]) * 100
	            + MSN(p_track[0x7EB]) * 10
	            + LSN(p_track[0x7EB]) * 1;

	// find last pattern
	desc.location=0x806; // if no header is found
	desc.width=0;
	desc.height=0;
	desc.pattern=0x120;
	desc.id=901;
	for(n=0;n<98;n++) {
	  if(decode_header(&temp,n)) desc=temp;
	}
	last_pattern=desc.id;
	
	// Check CONTROL_DATA
	fprintf(output,"ADDRESS FORMAT     CONTENT         VALUE\n");
	fprintf(output,"0x700  0x0120     write pointer : 0x%04X     ",int_get(p_track,0x700));
	if(int_get(p_track,0x700)==desc.pattern+get_size(&desc)) fprintf(output,"OK\n"); else fprintf(output,"FAIL %04X\n",desc.pattern+get_size(&desc));
	fprintf(output,"0x702  0x0000     0x0001        : 0x%04X     ",int_get(p_track,0x702));
	if(int_get(p_track,0x702)==1) fprintf(output,"OK\n"); else fprintf(output,"FAIL\n");
	fprintf(output,"0x704  0x0000     unk. pointer  : 0x%04X     ",int_get(p_track,0x704));
	fprintf(output,"?\n");
	fprintf(output,"0x706  0x0000     unknown       : 0x%04X     ",int_get(p_track,0x706));
	fprintf(output,"?\n");
	fprintf(output,"0x708  0x0000     0x0000        : 0x%04X     ",int_get(p_track,0x708));
	if(int_get(p_track,0x708)==0) fprintf(output,"OK\n"); else fprintf(output,"FAIL\n");
	fprintf(output,"0x70A  0x0000     loaded head   : 0x%04X     ",int_get(p_track,0x70A));
	if(int_get(p_track,0x70A)==desc.pattern+get_size(&desc)-2) fprintf(output,"OK\n"); else fprintf(output,"FAIL %04X\n",desc.pattern+get_size(&desc)-2);
	fprintf(output,"0x70C  0x00000000 0x00008100    : 0x%04X%04X ",int_get(p_track,0x70C),int_get(p_track,0x70E));
	if(int_get(p_track,0x70C)==0&&int_get(p_track,0x70E)==0x8100) fprintf(output,"OK\n"); else fprintf(output,"FAIL\n");
	fprintf(output,"0x710  0x07F9     pointer 1     : 0x%04X     ",int_get(p_track,0x710));
	if(int_get(p_track,0x710)==desc.location-13) fprintf(output,"OK\n"); else fprintf(output,"FAIL %04X\n",desc.location-13);
	fprintf(output,"0x714  0x0000     pointer 2     : 0x%04X     ",int_get(p_track,0x712));
	fprintf(output,"?\n");
	fprintf(output,"0x712  0x000000   0x000000      : 0x%04X%02X   ",int_get(p_track,0x714),p_track[0x716]);
	if(int_get(p_track,0x714)==0&&p_track[0x716]==0) fprintf(output,"OK\n"); else fprintf(output,"FAIL\n");
	fprintf(output,"0x7EA  0x1000     loaded pattern: 0x%04X     ",int_get(p_track,0x7EA));
	if(last_pattern==sel_pattern&&MSN(p_track[0x7EA])==1) fprintf(output,"OK\n"); else fprintf(output,"FAIL\n");
	fprintf(output,"0x7FF  0x00       unknown       : 0x%02X       ", p_track[0x7FF]);
	fprintf(output,"?\n");
	
	fprintf(output,"\n");

	// Just print AREA2 - don't know how to check, seems to not matter
	fprintf(output,"AREA2   ");
	print_slim_hex(output,&p_track[0x717],25);
	fprintf(output,"\n");

	// Check AREA3
	for(addr=0x730;addr<0x730+186;addr++) if(p_track[addr]!=00) break;
	if(addr==0x730+186) {
		fprintf(output,"AREA3   0x00 * 186                           OK\n",rep[0]);
	} else {
		fprintf(output,"AREA3                                        FAIL\n");
		print_hex(output,&p_track[0x7E0],7);
	}

	// Check AREA4
	for(addr=0x7EC;addr<0x7EC+19;addr++) if(p_track[addr]!=00) break;
	if(addr==0x7EC+19&&(rep[0]==0x00)) {
		fprintf(output,"AREA4   0x00 * 19                            OK\n",rep[0]);
	} else {
		fprintf(output,"AREA4                                        FAIL\n");
		print_hex(output,&p_track[0x7EC],19);
	}
	
	fprintf(output,"\n");
	
	// Check FINHDR
	fprintf(output,"FINHDR  ");
	print_slim_hex(output,&p_track[0x7FF-desc.location+7],7);
	for(n=0;n<5;n++) {
		if(p_track[0x7FF-desc.location+7+n]!=0x00) break;
	}
	if(n==5
	&& MSN(p_track[0x7FF-desc.location+7+5])==0
	&& LSN(p_track[0x7FF-desc.location+7+5])==(((desc.id+1)/100)%10)
	&& MSN(p_track[0x7FF-desc.location+7+6])==(((desc.id+1)/ 10)%10)
	&& LSN(p_track[0x7FF-desc.location+7+6])==(((desc.id+1)/  1)%10)) {
		fprintf(output,"                       OK\n");
	} else {
		fprintf(output,"                       FAIL\n");
	}
}

// init and set up descriptor for kh930 machine
void kh930_init(machine_t *p_machine,uint8_t *p_disk_data,uint8_t *p_disk_sids) {
  p_data=p_disk_data;
  p_sids=p_disk_sids;
  p_track=p_data;
  p_machine->name=name;
  p_machine->memory_used=get_size;
  p_machine->decode_header=decode_header;
  p_machine->decode_pattern=decode_pattern;
  p_machine->format=format;
  p_machine->set_track=set_track;
  p_machine->get_track=get_track;
  p_machine->size_check=size_check;
  p_machine->add_pattern=add_pattern;
  p_machine->info=info;
  p_machine->pattern_min=901;
  p_machine->pattern_max=998;
  p_machine->track_count=28;
}