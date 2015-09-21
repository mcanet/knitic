//---------------------------------------------------------------------------------
// SOLENOIDS
//---------------------------------------------------------------------------------
// Controled by Toshiva

#ifndef SOLENOIDS_H_
#define SOLENOIDS_H_

#include "arduino.h"
#include "encoders.h"
#include "endLines.h"

int pixelBin[256] = {
  1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

class solenoids{
private:
  encoders* myEncoders;
  endLines* myEndlines;
#ifdef arduinoTypeDUE
  int amegaPinsArray[16];
#endif
public:
  int currentPixState;
  int currentStitchSetup;
  boolean solenoidstate[16];
  boolean solenoidstateOn[16];
  
  solenoids(){
#ifdef arduinoTypeDUE  
    int amegaPinsArrayTemp[totalArrayFromSelenoids] = {
      22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23};
    for(int i=0; i<16; i++){
      amegaPinsArray[i] = amegaPinsArrayTemp[i];
      pinMode(amegaPinsArrayTemp[i], OUTPUT);
    }
#endif   
}
  ~solenoids(){}

  void setup(endLines* _myEndlines,encoders* _myEncoders){
    myEndlines = _myEndlines;
    myEncoders = _myEncoders;
#ifdef arduinoTypeDUE
    for(int i=0;i<16;i++){
      //amegaPinsArray[i] = amegaPinsArrayTemp[i];
      //pinMode(amegaPinsArrayTemp[i], OUTPUT);
      solenoidstate[i] =0;
      solenoidstateOn[i] =0;
    }
#endif
  }

  void loop(){
    //if the stitch Changes
    if( myEncoders->lastStitch!=myEncoders->stitch){
      myEncoders->lastStitch = myEncoders->stitch;
      int pos = myEncoders->stitch;
      int i = abs(pos)%16;// was 0, means no +8
      // RIGHT direction 
      if(myEncoders->headDirection==-1){
        if(pos >= 0 && pos <= 200){
          currentStitchSetup = pos+8;
        }
      }
      // LEFT direction
      else if(myEncoders->headDirection==1 ){
        if(pos <= 200 && pos >= 0){
          currentStitchSetup = pos-8; 
        }
      }
      if(currentStitchSetup>=0 && currentStitchSetup<200){  //IF the head is within the switches....no. 200 is the left switch
        currentPixState = pixelBin[currentStitchSetup];     //Pixel Bin is an array of 256 values. It pulls values from the Serial Port
        if(solenoidstateOn[i] != (currentPixState==1) ){    //if the current solenoid is different from the pixelBin value
          digitalWrite(amegaPinsArray[i], currentPixState); //the that state to the Indexed Solenoid
          solenoidstateOn[i] = (currentPixState==1);        //update array of current solenoid States
        }
      }
    }
  }
  
  void setAllSolOff(){
    for(int i=0;i<16;i++){
          digitalWrite(amegaPinsArray[i], LOW);
          solenoidstateOn[i] = false; 
    }
  }
};
#endif



















