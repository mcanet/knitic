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

#include "knitic.h"

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
  Serial.begin(115200);
  mySoundAlerts.setup();
  mysolenoids.setup();
  myEncoders.setup();
  myEndlines.setup();
  myEndlines.setPosition(&myEncoders.encoder0Pos, &myEncoders.segmentPosition, &mySoundAlerts);
  myCommunicator.setup(&myEncoders,&myEndlines,&mysolenoids);
  myCommunicator._status = "o";
} 

void loop() {
  // Receive solenoids from computer
  myCommunicator.receiveSerialFromComputer();
  mysolenoids.loop();
  // get data from sensors and send to computer
  myEncoders.loop();
  myEndlines.loop();
  myCommunicator.sendSerialToComputer();
} 































