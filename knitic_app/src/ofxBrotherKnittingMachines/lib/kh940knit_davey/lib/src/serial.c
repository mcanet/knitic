// Source file for platform independant serial communications
//
// Currently supports windows and posix(unix, mac)
//
// senseitg@gmail.com 2012-May-22

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "serial.h"

#ifdef _WIN32

#include <stdio.h>
#include <windows.h>

static HANDLE h_serial;
static COMMTIMEOUTS restore;

// windows - open serial port
// device has form "COMn"
bool sopen(char* device) {
  h_serial=CreateFile(device,GENERIC_READ|GENERIC_WRITE,0,0,OPEN_EXISTING,0,0);
  return h_serial!=INVALID_HANDLE_VALUE;
}

// windows - configure serial port
bool sconfig(char* fmt) {
  DCB dcb;
  COMMTIMEOUTS cmt;
  // clear dcb  
  memset(&dcb,0,sizeof(DCB));
  dcb.DCBlength=sizeof(DCB);
  // configure serial parameters
  if(!BuildCommDCB(fmt,&dcb)) return false;
  dcb.fOutxCtsFlow=0;
  dcb.fOutxDsrFlow=0;
  dcb.fDtrControl=0;
  dcb.fOutX=0;
  dcb.fInX=0;
  dcb.fRtsControl=0;
  if(!SetCommState(h_serial,&dcb)) return false;
  // configure buffers
  if(!SetupComm(h_serial,1024,1024)) return false;
  // configure timeouts 
  GetCommTimeouts(h_serial,&cmt);
  memcpy(&restore,&cmt,sizeof(cmt));
  cmt.ReadIntervalTimeout=100;
  cmt.ReadTotalTimeoutMultiplier=100;
  cmt.ReadTotalTimeoutConstant=100;
  cmt.WriteTotalTimeoutConstant=100;
  cmt.WriteTotalTimeoutMultiplier=100;
  if(!SetCommTimeouts(h_serial,&cmt)) return false;
  return true;
}

// windows - read from serial port
int32_t sread(void *p_read,uint16_t i_read) {
  DWORD i_actual=0;
  if(!ReadFile(h_serial,p_read,i_read,&i_actual,NULL)) return -1;
  return (int32_t)i_actual;
}

// windows - write to serial port
int32_t swrite(void* p_write,uint16_t i_write) {
  DWORD i_actual=0;
  if(!WriteFile(h_serial,p_write,i_write,&i_actual,NULL)) return -1;
  return (int32_t)i_actual;
}

// windows - close serial port
bool sclose() {
  // politeness: restore (some) original configuration
  SetCommTimeouts(h_serial,&restore);
  return CloseHandle(h_serial)!=0;
}

#else

#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

static int h_serial;
static struct termios restore;

// posix - open serial port
// device has form "/dev/ttySn"
bool sopen(char* device) {
  h_serial=open(device,O_RDWR|O_NOCTTY|O_NDELAY|O_NONBLOCK);
  return h_serial>=0;
}

// posix - configure serial port
bool sconfig(char* fmt) {
  struct termios options;
  char* argv[4];
  unsigned char argc;
  char* p_parse;
  // quick and dirty parser
  p_parse=fmt;
  argc=1;
  argv[0]=fmt;
  while(*p_parse!=0) {
    if(*p_parse==',') {
      *p_parse=0;
      if(argc>3) return false;
      argv[argc++]=++p_parse;
    } else p_parse++;
  }
  // get current settings
  tcgetattr(h_serial,&options);
  memcpy(&restore,&options,sizeof(options));
  // configure baudrate
  switch(atoi(argv[0])) {
    case   1200: cfsetispeed(&options,  B1200); cfsetospeed(&options,  B1200); break;
    case   2400: cfsetispeed(&options,  B2400); cfsetospeed(&options,  B2400); break;
    case   4800: cfsetispeed(&options,  B4800); cfsetospeed(&options,  B4800); break;
    case   9600: cfsetispeed(&options,  B9600); cfsetospeed(&options,  B9600); break;
    case  19200: cfsetispeed(&options, B19200); cfsetospeed(&options, B19200); break;
    case  38400: cfsetispeed(&options, B38400); cfsetospeed(&options, B38400); break;
    case  57600: cfsetispeed(&options, B57600); cfsetospeed(&options, B57600); break;
    case 115200: cfsetispeed(&options,B115200); cfsetospeed(&options,B115200); break;
    default: return false;
  }
  // configure parity
  switch(argv[1][0]) {
    case 'n': case 'N': options.c_cflag&=~PARENB;                           break;
    case 'o': case 'O': options.c_cflag|= PARENB; options.c_cflag|= PARODD; break;
    case 'e': case 'E': options.c_cflag|= PARENB; options.c_cflag&=~PARODD; break;
    default: return false;
  }
  // configure data bits
  options.c_cflag&=~CSIZE;
  switch(argv[2][0]) {
    case '8': options.c_cflag&=~CSIZE; options.c_cflag|=CS8; break;
    case '7': options.c_cflag&=~CSIZE; options.c_cflag|=CS7; break;
    default: return false;
  }
  // configure stop bits
  switch(argv[3][0]) {
    case '1': options.c_cflag&=~CSTOPB; break;
    case '2': options.c_cflag|= CSTOPB; break;
    default: return false;
  } 
  // configure timeouts
  options.c_lflag &= 0;      // local
  options.c_iflag &= 0;      // input
  options.c_oflag &= ~OPOST; // output
  options.c_cc[VMIN ]=0;
  options.c_cc[VTIME]=1;
  options.c_cflag|=CLOCAL|CREAD;
  fcntl(h_serial,F_SETFL,0);
  return tcsetattr(h_serial,TCSANOW,&options)==0;
}

// posix - read from serial port
int32_t sread(void* p_read,uint16_t i_read) {
  return (int32_t)read(h_serial,p_read,(int)i_read);
}

// posix - write to serial port
int32_t swrite(void* p_write,uint16_t i_write) {
  return (int32_t)write(h_serial,p_write,(int)i_write);
}

// posix - close serial port
bool sclose() {
  if(h_serial>=0) {
    // politeness: restore original configuration
    tcsetattr(h_serial,TCSANOW,&restore);
    return close(h_serial)==0;
  }
  return false;
}

#endif