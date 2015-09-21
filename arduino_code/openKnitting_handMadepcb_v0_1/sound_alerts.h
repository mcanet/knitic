#ifndef SOUNDALERTS_H_
#define SOUNDALERTS_H_

#include "defined_knitic.h"

class soundAlerts{
public:
  soundAlerts(){
  }
  ~soundAlerts(){
  }

  void setup(){
    pinMode(piezoPin, OUTPUT);
  }

  void startMachine(){
    for(int i=0;i<3;i++){
      beep();
    }
  }

  void endPattern(){
    for(int i=0;i<5;i++){
      beep();
    }
  }
  void beep(){
    int delayms = 50;
    analogWrite(piezoPin, 20);      // Almost any value can be used except 0 and 255
    // experiment to get the best tone
    delay(delayms);          // wait for a delayms ms
    analogWrite(piezoPin, 0);       // 0 turns it off
    delay(delayms);          // wait for a delayms ms 
  }
};
#endif 


