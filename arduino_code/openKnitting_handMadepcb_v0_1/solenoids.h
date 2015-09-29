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
  1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,//16
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//32
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//48
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//64
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//80
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//96
  1,1,1,1,1,0,0,0,1,1,1,1,1,1,0,0,//112
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//128
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//144
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//160
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//176
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//192
  0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,
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
#ifdef arduinoTypeDUE
    int amegaPinsArrayTemp[totalArrayFromSelenoids] = {
      22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23};
#endif
  
  solenoids(){
  }

  ~solenoids(){
  }

  void setup(endLines* _myEndlines,encoders* _myEncoders){
    myEndlines = _myEndlines;
    myEncoders = _myEncoders;
#ifdef arduinoTypeDUE
    for(int i=0;i<16;i++){
      amegaPinsArray[i] = amegaPinsArrayTemp[i];
      pinMode(amegaPinsArrayTemp[i], OUTPUT);
      solenoidstate[i] =0;
      solenoidstateOn[i] =0;
    }
#endif
  }

  void loop(){
    //if the stitch Changes
    if( myEncoders->lastStitch!=myEncoders->encoder1Pos){
      myEncoders->lastStitch = myEncoders->encoder1Pos;
      
      int m_position = myEncoders->encoder1Pos;
      int m_solenoidToSet = abs(m_position)%16;// was 0, means no +8
      
      // RIGHT direction 
      if(myEncoders->headDirection==-1){
        if(m_position <= (END_LEFT - START_OFFSET_L)){
          currentStitchSetup = m_position - START_OFFSET_R;
          #ifdef machineType940
            if(myEndlines->phase==0){
              m_solenoidToSet = abs(m_position-8)%16; // maybe +8
            }else{
              // validated
              m_solenoidToSet = abs(m_position)%16;
            }      
          #endif    
          #ifdef cariageTypeL
            currentStitchSetup = currentStitchSetup+8;
          #endif
        }
      }
      // LEFT direction
      else if(myEncoders->headDirection==1 ){
        if(m_position >= START_OFFSET_R){
          currentStitchSetup = m_position - START_OFFSET_L;
          #ifdef machineType940         
            if(myEndlines->phase==0){
              // validated
              m_solenoidToSet = abs(m_position)%16;// was 0, means no +8
            }else{
              m_solenoidToSet = abs(m_position+8)%16;// -8
            }    
          #endif      
          #ifdef cariageTypeL
            currentStitchSetup = currentStitchSetup-16;
          #endif
        }
      }
      
      if(currentStitchSetup>=(0-END_OF_LINE_OFFSET_R) && currentStitchSetup<(200+END_OF_LINE_OFFSET_L)){  //IF the head is within the switches....no. 200 is the left switch
        currentPixState = pixelBin[currentStitchSetup];     //Pixel Bin is an array of 256 values. It pulls values from the Serial Port
        if(solenoidstateOn[m_solenoidToSet] != (currentPixState==1) ){    //if the current solenoid is different from the pixelBin value
          digitalWrite(amegaPinsArray[m_solenoidToSet], currentPixState); //the that state to the Indexed Solenoid
          solenoidstateOn[m_solenoidToSet] = (currentPixState==1);        //update array of current solenoid States
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



















