/*
 *
 * KNITIC: OPEN KNITTING MACHINE
 * @Description: Code for open source machine
 * @Authors: Mar Canet <mar.canet@gmail.com> & Varvara Guljajeva <varvarag@gmail.com> 
 * @Versions:0.1v 
 *
 */

#define arduinoTypeDUE "due"
//#define arduinoTypeUNO "uno"
#define totalArrayFromSelenoids 16
// Important! This four values need to be calibrate in each machine
// Use code at: "arduino code/test_incase_error/test_endLine_calibrate" 
// When you execute you will find values in the arduino terminal and change the right values for your machine
#define FILTER_VALUE_LEFT_MIN 100
#define FILTER_VALUE_RIGHT_MIN 100
#define FILTER_VALUE_LEFT_MAX 460
#define FILTER_VALUE_RIGHT_MAX 460
#define attachInterrupEncoders interrupEncoders

#include "defined_knitic.h"
#include "knitic.h"

//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
// Class declaration
encoders myEncoders;
endLines myEndlines;
solenoids mysolenoids;
soundAlerts mySoundAlerts;
communication myCommunicator;

void setup()
{ 
  Serial.begin(115200);
  mySoundAlerts.setup();
  myEncoders.setup();
  //myEndlines.setup();
  myEndlines.setPosition(&myEncoders);
  mysolenoids.setup(&myEndlines,&myEncoders);
  myCommunicator.setup(&myEncoders,&myEndlines,&mysolenoids);
  myCommunicator._status = "o";
#ifdef attachInterrupEncoders
  attachInterrupt(digitalPinToInterrupt(encoder0PinA), encoderChange, CHANGE);
#endif
} 

void loop() {
  // Receive solenoids from computer
  serialEvent();
  // Get data from sensors and send to computer in case solenoids not move
#ifndef attachInterrupEncoders
  myEncoders.loopNormal();
  myEndlines.loop();
  mysolenoids.loop();
#endif

  
  // Set all solenoids OFF when end of line
  if(myEncoders.encoder1Pos==0 || myEncoders.encoder1Pos==255  ){
    mysolenoids.setAllSolOff();
  }
  myCommunicator.sendSerialToComputer();
  
}

void serialEvent(){
  myCommunicator.receiveAllLine();
}

#ifdef attachInterrupEncoders
void encoderChange(){
  myEncoders.loopAttachInterrupt();
  myEndlines.loop();
  mysolenoids.loop();
}
#endif



























