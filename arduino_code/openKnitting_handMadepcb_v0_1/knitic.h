/*
 Knitic classes for operating open knitting machine
 
 Copyright 2013 Mar Canet <mar.canet@gmail.com> and Varvara Guljajeva <varvarag@gmail.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

*/
#ifndef KNITIC_H_
#define KNITIC_H_
#include "arduino.h"

inline void digitalWriteDirect(int pin, boolean val){
  if(val) g_APinDescription[pin].pPort -> PIO_SODR = g_APinDescription[pin].ulPin;
  else    g_APinDescription[pin].pPort -> PIO_CODR = g_APinDescription[pin].ulPin;
}

inline int digitalReadDirect(int pin){
  return !!(g_APinDescription[pin].pPort -> PIO_PDSR & g_APinDescription[pin].ulPin);
}

#include "encoders.h"
#include "sound_alerts.h"
#include "solenoids.h"
#include "endLines.h"
#include "communication.h"

#endif /* KNITIC_H_ */
