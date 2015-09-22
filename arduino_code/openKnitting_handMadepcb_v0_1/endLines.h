#ifndef ENDLINES_H_
#define ENDLINES_H_

#include "arduino.h"
#include "sound_alerts.h"
#include "defined_knitic.h"

class endLines{
private:
  soundAlerts* mySoundAlerts;
  encoders* myEncoders;
  int filterValueLeftMin;
  int filterValueRightMin;
  int filterValueLeftMax;
  int filterValueRightMax;

public:
  int valueEndLineLeft;
  int valueEndLineRight;
  int phase;
  endLines(){
  }
  ~endLines(){
  }

  void setup(){
  
  }

  void setPosition(encoders* _myEncoders){
    myEncoders = _myEncoders;
  }

  void loop(){
    valueEndLineLeft  = analogRead(endLineLeftAPin);
    valueEndLineRight = analogRead(endLineRightAPin);
    // Left end of line - looking change phase
    if( myEncoders->headDirection==1){
      if( valueEndLineLeft <FILTER_VALUE_LEFT_MIN || analogRead(endLineLeftAPin) >FILTER_VALUE_LEFT_MAX){ 
        if(myEncoders->_8segmentEncoder){
          phase = 1;
        }
        else{
          phase = 0;
        }
      }
    }
    // Right end of line - looking change phase
    if( myEncoders->headDirection==-1){ 
      if( valueEndLineRight <FILTER_VALUE_RIGHT_MIN || analogRead(endLineRightAPin) >FILTER_VALUE_RIGHT_MAX){
        if(myEncoders->_8segmentEncoder){
          phase = 0;
        }
        else{
          phase = 1;
        }
      }
    }
    /*if( valueEndLineLeft <FILTER_VALUE_LEFT_MIN){
      myEncoders->encoder1Pos=END_LEFT + 28;
      myEncoders->stitch=END_LEFT;
    }
    if( valueEndLineRight <FILTER_VALUE_RIGHT_MIN){
      myEncoders->encoder1Pos=END_RIGHT - 28;
      myEncoders->stitch=END_RIGHT;
    }*/
  }

};
#endif

