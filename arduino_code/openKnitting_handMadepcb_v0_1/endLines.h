#ifndef ENDLINES_H_
#define ENDLINES_H_

#include "arduino.h"
#include "sound_alerts.h"

class endLines{
private:
  soundAlerts* mySoundAlerts;
  // analog arduino pin
  int endLineLeftAPin;
  int endLineRightAPin;
  int * encoderPos; 
  int filterValueLeftMin;
  int filterValueRightMin;
  int filterValueLeftMax;
  int filterValueRightMax;
  int lastLeft;
  int lastRight;
  int maxLeft;
  int maxRight;
public:
  boolean started;
  int * segmentPosition;
  int row;
  endLines(){
  }
  ~endLines(){
  }

  void setup(){
    maxLeft = 0;
    maxRight= 0;
    endLineLeftAPin = 1;
    endLineRightAPin = 0;
    filterValueLeftMin = 10;
    filterValueRightMin = 10;
    filterValueLeftMax = 485;
    filterValueRightMax = 485;
    row = 0;
    started = false;
  }

  void setPosition(int * _encoderPos, int * _segmentPosition, soundAlerts* _mySoundAlerts){
    encoderPos = _encoderPos;
    segmentPosition = _segmentPosition;
    mySoundAlerts = _mySoundAlerts;
  }

  void loop(){
    int valueEndLineLeft = analogRead(endLineLeftAPin);
    int valueEndLineRight = analogRead(endLineRightAPin);
    /*
    if(maxLeft<=valueEndLineLeft){ 
     maxLeft = valueEndLineLeft; 
     //Serial.println(maxLeft);
     }
     
     if(maxRight<valueEndLineRight){ 
     maxRight = valueEndLineRight; 
     //Serial.println(maxRight);
     }
     */
    if( analogRead(endLineLeftAPin) <filterValueLeftMin || analogRead(endLineLeftAPin) >filterValueLeftMax){ 
      if(!lastLeft){
        *encoderPos = 200*4;
        *segmentPosition = 25;
        started = true;
      }
      lastLeft = true;
    }
    else{
      lastLeft = false;
    }

    if( valueEndLineRight <filterValueRightMin || analogRead(endLineRightAPin) >filterValueRightMax){
      if(!lastRight){
        *encoderPos = 0;
        *segmentPosition = 1;
        //Serial.print("inside right:");
        //Serial.print("change encoder0Pos:");
        //Serial.println(*encoderPos);
        started = true;
      }
      lastRight = true;
    }
    else{
      lastRight = false;
    }
  }

};
#endif
