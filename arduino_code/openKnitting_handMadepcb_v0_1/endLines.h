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
  int lastLeft;
  int lastRight;
  int maxLeft;
  int maxRight;
  int valuesLastThreeStitches[3];
  int idLastThreeStitches;
  int filterBetween;
public:
  int valueEndLineLeft;
  int valueEndLineRight;
  boolean started;
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
    filterValueLeftMax = 460;
    filterValueRightMax = 460;
    filterBetween = 10;
    row = 0;
    started = false;
    lastRight = false;
    lastLeft = false;
  }

  void setPosition(encoders* _myEncoders, soundAlerts* _mySoundAlerts){
    myEncoders = _myEncoders;
    mySoundAlerts = _mySoundAlerts;
  }

  void loop(){
    valueEndLineLeft  = analogRead(endLineLeftAPin);
    valueEndLineRight = analogRead(endLineRightAPin);
    
    /*
    if( (valueEndLineLeft > filterValueLeftMax) && idLastThreeStitches!=myEncoders->stitch ){
      idLastThreeStitches=myEncoders->stitch;
      valuesLastThreeStitches[2] = valuesLastThreeStitches[1];
      valuesLastThreeStitches[1] = valuesLastThreeStitches[0];
      valuesLastThreeStitches[0] = valueEndLineLeft;
      if( (valuesLastThreeStitches[1]-valuesLastThreeStitches[2])>filterBetween && (valuesLastThreeStitches[1]-valuesLastThreeStitches[0])>filterBetween){
        myEncoders->encoder0Pos = 201*4;
        Serial.println("LEFT ENDLINE");
      }
    }
    
    if( (valueEndLineRight > filterValueRightMax) && idLastThreeStitches!=myEncoders->stitch ){
      idLastThreeStitches=myEncoders->stitch;
      valuesLastThreeStitches[2] = valuesLastThreeStitches[1];
      valuesLastThreeStitches[1] = valuesLastThreeStitches[0];
      valuesLastThreeStitches[0] = valueEndLineRight;
      if( (valuesLastThreeStitches[1]-valuesLastThreeStitches[2])>filterBetween && (valuesLastThreeStitches[1]-valuesLastThreeStitches[0])>filterBetween){
        myEncoders->encoder0Pos = -1*4;
        Serial.println("RIGHT ENDLINE");
      }
    }
    */
    
    if( valueEndLineLeft <filterValueLeftMin || analogRead(endLineLeftAPin) >filterValueLeftMax){ 
      if(!lastLeft){
        
        //myEncoders->lastEncoder0Pos =(200*4)-1;
        //myEncoders->encoder1Pos = 228;
        //myEncoders->stitch = 200;
        
        started = true;
      }
      lastLeft = true;
    }
    else{
      lastLeft = false;
    }

    if( valueEndLineRight <filterValueRightMin || analogRead(endLineRightAPin) >filterValueRightMax){
      if(!lastRight){
        
        //myEncoders->lastEncoder0Pos =-1;
        //myEncoders->encoder1Pos = 27;
        //myEncoders->stitch = 0;
        
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
