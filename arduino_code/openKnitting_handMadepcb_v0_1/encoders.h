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
public:
    short directionEncoders;
  short lastDirectionEncoders;
  int encoder1Pos; 
  int encoder4Pos;
  int lastencoder1Pos;
  int lastencoder4Pos;
  int stitch;
  int lastStitch;
  int headDirection;
  //boolean lastState8segmentEncoder;
  //boolean state8segmentEncoder;
  boolean _8segmentEncoder;
  boolean last_8segmentEncoder;
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
    last_8segmentEncoder = 0;
  }

  void calculateDirection(){
    lastDirectionEncoders = directionEncoders;
    directionEncoders = 0;
    if(digitalRead(encoder0PinA)== HIGH){ 
      // directionEncoders is ON for encoder A
      //Serial.println("A:HIGH ENCODER");
      directionEncoders += 1; 
    }
    else{ 
      // directionEncoders is OFF for encoder A
      directionEncoders += 0;  
      //Serial.println("A:LOW ENCODER");
    }
    if(digitalRead(encoder0PinB)== HIGH){ 
      // directionEncoders is ON for encoder B
      directionEncoders +=3;
      //Serial.println("B:HIGH ENCODER");
    }
    else{ 
      directionEncoders +=5;
      //Serial.println("B:LOW ENCODER");
    }
    last_8segmentEncoder = _8segmentEncoder;
    _8segmentEncoder = (digitalRead(encoder0PinC)==HIGH);
    /*
    Serial.print(lastDirectionEncoders);
    Serial.print("-");
    Serial.println(directionEncoders);
    Serial.print("-");
    Serial.println(_8segmentEncoder);
    */
  }

  // Use call from normal loop
  void loopNormal(){
    calculateDirection();
    if(lastDirectionEncoders!=directionEncoders){
      //Serial.print(lastDirectionEncoders);
      //Serial.print("-");
      //Serial.println(directionEncoders);
      if( 
      ( lastDirectionEncoders==OFF_OFF && directionEncoders==OFF_OFF)  || 
        (lastDirectionEncoders==OFF_OFF && directionEncoders==ON_OFF) || 
        (lastDirectionEncoders==ON_OFF && directionEncoders==ON_ON)   || 
        (lastDirectionEncoders==ON_ON && directionEncoders==OFF_ON)   || 
        (lastDirectionEncoders==OFF_ON && directionEncoders==OFF_OFF) 

      ){
        headDirection =-1;
        if( encoder1Pos==-2000){ 
          encoder4Pos = 1020;//255 * 4
          encoder1Pos = 255;
          //Serial.print("start value");
        }
        encoder4Pos-=1;
        if(encoder4Pos<0){
          encoder4Pos=0;
        }
        /*
        Serial.print(headDirection);
        Serial.print("-Left:");
        Serial.println(encoder4Pos);
        Serial.println(encoder1Pos);
        */
      }
      else if( 
      (lastDirectionEncoders==OFF_ON && directionEncoders==ON_ON)  || 
        (lastDirectionEncoders==ON_ON && directionEncoders==ON_ON)   || 
        (lastDirectionEncoders==ON_ON && directionEncoders==ON_OFF)  || 
        (lastDirectionEncoders==ON_OFF && directionEncoders==OFF_OFF)|| 
        (lastDirectionEncoders==OFF_OFF && directionEncoders==OFF_ON) 

      ){
        headDirection =+1;
        if( encoder1Pos==-2000){ 
          encoder4Pos = 0;
          encoder1Pos = 0;
          //Serial.print("start value");
        }
        encoder4Pos+=1;
        if(encoder4Pos>1020){//255 * 4
          encoder4Pos=1020;
        }
        /*
        Serial.print(headDirection);
        Serial.print("-Right:");
        Serial.println(encoder4Pos);
        Serial.println(encoder1Pos);
        */
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
  // Use called by attachInterrupt(encoder0PinA, encoderChange, CHANGE);
  void loopAttachInterrupt(){  
    calculateDirection();

    if(lastDirectionEncoders!=directionEncoders){
      if( 
      lastDirectionEncoders==OFF_ON || directionEncoders==ON_OFF 
        ){
        headDirection =-1;
        //Serial.print(encoder1Pos);
        //Serial.println("-Left");
        if( encoder1Pos==-2000){ 
          encoder1Pos = 255;
        }
        encoder1Pos-=1;
        if(encoder1Pos<0){
          encoder1Pos=0;
        }
      }
      else if(
      lastDirectionEncoders==ON_ON || directionEncoders==OFF_OFF
        ){
        headDirection =1;
        //Serial.print(headDirection);
        //Serial.println("-Right");
        if( encoder1Pos==-2000){ 
          encoder1Pos = 0;
        }
        encoder1Pos+=1;
        if(encoder1Pos>255){
          encoder1Pos = 255;
        }
      }
    }
    lastDirectionEncoders = directionEncoders;
    // encoder position had changed
    if(encoder1Pos!=lastencoder1Pos){
      if( encoder1Pos !=0 ){ 
        stitch = (encoder1Pos)-28; 
      }
      else{
        stitch = -28;
      }
    }
  }



};
#endif





