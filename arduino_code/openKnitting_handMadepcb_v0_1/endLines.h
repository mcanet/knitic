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
  encoders* myEncoders;
  int filterValueLeftMin;
  int filterValueRightMin;
  int filterValueLeftMax;
  int filterValueRightMax;
  int maxLeft;
  int maxRight;

public:
  int valueEndLineLeft;
  int valueEndLineRight;
  int phase;
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
    filterValueLeftMax = 460;
    filterValueRightMax = 460;
  }

  void setPosition(encoders* _myEncoders, soundAlerts* _mySoundAlerts){
    myEncoders = _myEncoders;
    mySoundAlerts = _mySoundAlerts;
  }

  void loop(){
    // Left end of line - looking change phase
    if( myEncoders->headDirection==-1){
      valueEndLineLeft  = analogRead(endLineLeftAPin);
      if( valueEndLineLeft <filterValueLeftMin || analogRead(endLineLeftAPin) >filterValueLeftMax){ 
        if(myEncoders->_8segmentEncoder){
          phase = 1;
        }
        else{
          phase = 0;
        }
      }
    }
    // Right end of line - looking change phase
    if( myEncoders->headDirection==1){ 
      valueEndLineRight = analogRead(endLineRightAPin);
      if( valueEndLineRight <filterValueRightMin || analogRead(endLineRightAPin) >filterValueRightMax){
        if(myEncoders->_8segmentEncoder){
          phase = 1;
        }
        else{
          phase = 0;
        }
      }
    }
  }

};
#endif

