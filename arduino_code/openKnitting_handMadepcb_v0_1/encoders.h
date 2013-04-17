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

class encoders{
private:
  // digital pins
  int encoder0PinA;
  int encoder0PinB;
  int encoder0PinC;
  int encoder0PinALast;
  int encoder0PinBLast;
  int encoder0PinCLast;
  
  short directionEncoders;
  short lastDirectionEncoders;
  
  int headDirectionAverage;
public:
  String _8segmentEncoder;   
  String last8segmentEncoder;
  int segmentPosition;
  int encoder0Pos; 
  int lastEncoder0Pos;
  int headDirection;
  encoders(){
#ifdef arduinoTypeUNO
    encoder0PinA = 2;
    encoder0PinB = 3;
    encoder0PinC = 4;
#endif
#ifdef arduinoTypeDUE
    encoder0PinA = 2;
    encoder0PinB = 3;
    encoder0PinC = 4;
#endif
    headDirection = 0;
    encoder0Pos = -1000;
    lastEncoder0Pos = -1;
    segmentPosition = -1;
    _8segmentEncoder = "";
    last8segmentEncoder = "";
    lastDirectionEncoders = 0;
    headDirectionAverage = 0;
  }

  ~encoders(){
  }

  void setup(){
    pinMode(encoder0PinA,INPUT);
    pinMode(encoder0PinB,INPUT);
    pinMode(encoder0PinC,INPUT);
  }

  void loop(){
    directionEncoders = 0;
    if(digitalRead(encoder0PinA)== HIGH){ 
      // directionEncoders is ON for encoder A
      directionEncoders += 1; 
    }
    else{ 
      // directionEncoders is OFF for encoder A
      directionEncoders += 0;  
    }
    if(digitalRead(encoder0PinB)== HIGH){ 
      // directionEncoders is ON for encoder B
      directionEncoders +=3; 
    }
    else{ 
      // directionEncoders is OFF for encoder B
      directionEncoders +=5;
    }
    /*
    last8segmentEncoder = _8segmentEncoder;
    _8segmentEncoder = "";
    if(digitalRead(encoder0PinC)== HIGH){ 
      _8segmentEncoder += "ON"; 
    }
    else{ 
      _8segmentEncoder += "OFF"; 
    }
    */
    // head direction
    if(lastDirectionEncoders!=directionEncoders){
      if( 
      (lastDirectionEncoders==OFF_OFF && directionEncoders==OFF_OFF)  || 
        (lastDirectionEncoders==OFF_OFF && directionEncoders==ON_OFF) || 
        (lastDirectionEncoders==ON_OFF && directionEncoders==ON_ON)   || 
        (lastDirectionEncoders==ON_ON && directionEncoders==OFF_ON)   || 
        (lastDirectionEncoders==OFF_ON && directionEncoders==OFF_OFF) 
       
        ){
        headDirectionAverage +=1;
        headDirection =+1;
        //Serial.println(headDirection+"-Left");
        if((encoder0Pos != -1000) && (encoder0Pos/4 > -31)){
          encoder0Pos--;
        }
      }
      else if( 
        (lastDirectionEncoders==OFF_ON && directionEncoders==ON_ON)  || 
        (lastDirectionEncoders==ON_ON && directionEncoders==ON_ON)   || 
        (lastDirectionEncoders==ON_ON && directionEncoders==ON_OFF)  || 
        (lastDirectionEncoders==ON_OFF && directionEncoders==OFF_OFF)|| 
        (lastDirectionEncoders==OFF_OFF && directionEncoders==OFF_ON) 
      
        ){
        headDirectionAverage -=1;
        headDirection =-1;
        //Serial.println(headDirection+"-Right");
        if((encoder0Pos != -1000) && (encoder0Pos/4 < 231)){
          encoder0Pos++;
        }
      }
    }
    lastDirectionEncoders = directionEncoders;
    /*
    // know when head changer from one 8 knidles segment 
    if(_8segmentEncoder!=last8segmentEncoder ){ 
      //
      if(headDirectionAverage>2){
        headDirection =+1;
        //Serial.println("d:+1");
      }
      else if(headDirectionAverage<-2){
        headDirection =-1;
        //Serial.println("d:-1");
      }
      else{
        headDirection = headDirection*-1;
        //Serial.println("change direction"+String(headDirection));
      }
      headDirectionAverage = 0;
      segmentPosition +=headDirection;
    }
    
    */
  }
};
#endif
