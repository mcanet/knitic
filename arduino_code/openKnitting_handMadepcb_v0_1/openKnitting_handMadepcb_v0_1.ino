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

#include "defined_knitic.h"
#include "knitic.h"

#define attachInterrupEncoders interrupEncoders
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
// Class declaration
encoders myEncoders;
endLines myEndlines;
solenoids mysolenoids;
soundAlerts mySoundAlerts;
communication myCommunicator;
int patternLine[200];

void setup()
{ 
  Serial.begin(115200);//
  mySoundAlerts.setup();
  myEncoders.setup();
  myEndlines.setup();
  myEndlines.setPosition(&myEncoders, &mySoundAlerts);
  mysolenoids.setup(&myEndlines,&myEncoders);
  myCommunicator.setup(&myEncoders,&myEndlines,&mysolenoids);
  myCommunicator._status = "o";
#ifdef attachInterrupEncoders
  attachInterrupt(encoder0PinA, encoderChange, CHANGE);
#endif
} 

void loop() {
  // Receive solenoids from computer
  //myCommunicator.receiveRealtimeFromComputer();
  myCommunicator.receiveAllLine();
  // Get data from sensors and send to computer in case solenoids not move
#ifndef attachInterrupEncoders
  myEncoders.loopNormal();
  myEndlines.loop();
  mysolenoids.loop();
#endif
  myCommunicator.sendSerialToComputer();
}

#ifdef attachInterrupEncoders
void encoderChange(){
  myEncoders.loopAttachInterrupt();
  myEndlines.loop();
  mysolenoids.loop();
  myCommunicator.sendSerialToComputer();
}
#endif



























