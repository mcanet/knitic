#ifndef ENCODERS_H_
#define ENCODERS_H_
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
// table created to get combinations
/*
table encoder position an values id
 OFF_ON  = 0+3 = 3
 ON_OFF  = 1+5 = 6
 ON_ON   = 1+3 = 4
 OFF_OFF = 0+5 = 5 
 */

#define OFF_ON 3
#define ON_OFF 6
#define ON_ON 4
#define OFF_OFF 5

#include "arduino.h"
#include "defined_knitic.h"

class encoders{
private:
  short directionEncoders;
  short lastDirectionEncoders;
  int encoder4Pos;
  int lastencoder4Pos;
  //boolean last_8segmentEncoder;
public:
  int encoder1Pos; 
  int lastencoder1Pos;
  int stitch;
  int lastStitch;
  int headDirection;
  boolean _8segmentEncoder;
  
  encoders(){
  }
  ~encoders(){
  }

  void setup(){
    pinMode(encoder0PinA,INPUT);
    pinMode(encoder0PinB,INPUT);
    pinMode(encoder0PinC,INPUT);
    headDirection = 0;
    encoder1Pos = -2000;
    lastencoder1Pos = -1;
    encoder4Pos = 0;
    lastencoder4Pos = -1;
    lastDirectionEncoders = 0;
    lastStitch=0;
    stitch=-1;
    _8segmentEncoder = 0;
    //last_8segmentEncoder = 0;
  }

  
  // Use call from normal loop
  void loopNormal(){
    calculateDirection();
    if(lastDirectionEncoders!=directionEncoders){
      if((lastDirectionEncoders==OFF_OFF && directionEncoders==OFF_OFF)  || 
        (lastDirectionEncoders==OFF_OFF && directionEncoders==ON_OFF) || 
        (lastDirectionEncoders==ON_OFF && directionEncoders==ON_ON)   || 
        (lastDirectionEncoders==ON_ON && directionEncoders==OFF_ON)   || 
        (lastDirectionEncoders==OFF_ON && directionEncoders==OFF_OFF)){
        headDirection =-1;
        if( encoder1Pos==-2000){ 
          encoder4Pos = 1020;//255 * 4
          encoder1Pos = 255;
        }
        encoder4Pos-=1;
        if(encoder4Pos<0){
          encoder4Pos=0;
        }
      }
      else if((lastDirectionEncoders==OFF_ON && directionEncoders==ON_ON)  || 
        (lastDirectionEncoders==ON_ON && directionEncoders==ON_ON)   || 
        (lastDirectionEncoders==ON_ON && directionEncoders==ON_OFF)  || 
        (lastDirectionEncoders==ON_OFF && directionEncoders==OFF_OFF)|| 
        (lastDirectionEncoders==OFF_OFF && directionEncoders==OFF_ON)){
        headDirection =+1;
        if( encoder1Pos==-2000){ 
          encoder4Pos = 0;
          encoder1Pos = 0;
        }
        encoder4Pos+=1;
        if(encoder4Pos>1020){//255 * 4
          encoder4Pos=1020;
        }
      }
    }
    
    if( encoder4Pos !=0 ){ 
      encoder1Pos = encoder4Pos/4;
      stitch = (encoder1Pos)-28; 
    }
    else{
      encoder1Pos = 0;
      stitch = -28;
    }
  }
  
  //-------------------------------------------------------------------------
  boolean get8segmentEncoder(){
     _8segmentEncoder = (digitalReadDirect(encoder0PinC)==HIGH);
     return _8segmentEncoder;
  }

  //-------------------------------------------------------------------------
  
  void calculateDirection(){
    lastDirectionEncoders = directionEncoders;
    directionEncoders = 0;
    
    if(digitalReadDirect(encoder0PinA)== HIGH){ directionEncoders += 1;}
    else{ directionEncoders += 0;}
    if(digitalReadDirect(encoder0PinB)== HIGH){ directionEncoders +=3;}
    else{ directionEncoders +=5;}
    
    //last_8segmentEncoder = _8segmentEncoder;
    //_8segmentEncoder = (digitalRead(encoder0PinC)==HIGH);
  }

  
  //-------------------------------------------------------------------------
  // Use called by attachInterrupt(encoder0PinA, encoderChange, CHANGE);
  void loopAttachInterrupt(){  
    calculateDirection();
    if(lastDirectionEncoders!=directionEncoders){
      if(lastDirectionEncoders==OFF_ON || directionEncoders==ON_OFF){
        headDirection =-1;
        encoder1Pos-=1;
        if(encoder1Pos<0){
          encoder1Pos=0;
        }
        stitch = (encoder1Pos)-28;
      }
      else if(lastDirectionEncoders==ON_ON || directionEncoders==OFF_OFF){
        headDirection =1;
        encoder1Pos+=1;
        if(encoder1Pos>255){
          encoder1Pos=255;
        }
        stitch = (encoder1Pos)-28;
      }
    }
    lastDirectionEncoders = directionEncoders;
  }
};
#endif





