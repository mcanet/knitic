import java.io.*;
import java.util.*;

int BAUD_RATE = 115200;
byte lf = 0x40;
byte footer = 126;

//------------------------------------------------------------------------------------

void setupSerialConnection(String devicePath) {
  if(devicePath!="Select usb port"){
    try {
      println("try to connect");
      
      println("Device path:"+devicePath);
      myPort = new Serial(this, devicePath, BAUD_RATE);
      myPort.bufferUntil(lf);
      delay(2000);
      myPort.clear();
      lastConnection = millis();
    } 
    catch (Exception e) {
      /*
      if (e.getMessage().contains("<init>")) {
       println("port in use, trying again later...");
       }
       */
    }
  }
  else{
    println("setup the port");
  }
}

//------------------------------------------------------------------------------------

void autoConnectAndReceiveSerial(Serial p) {
  try {
    // knowing if is connected
    if (abs(millis()-lastMessageReceivedFromSerial)>2000) {

      if (abs(lastConnection-millis())>5000) {
        usbConected = false;
        /*
        if ( myPort != null) {
         myPort.clear();
         myPort.stop();
         }
         myPort = null;
         setupSerialConnection();
         */
      }
    }
    else {
      usbConected = true;
    }
    receiveSerial(p);
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

void sendtoKnittingMachine() {
  if (current_row>=0) {
    lastSerialPixelSend = millis();
    try {
      for (int i=0; i<200; i++) {
        pixelSend[i] = 1;
      }
      for (int i=0; i<200; i++) {
        int rightStickOffset = 100-rightStick;
        int posXPixel = 199-(i+rightStickOffset);
        int posYPixel = (rows-1)-current_row;
        try {
           // test existence
          if (posXPixel<cols && posXPixel>=0){
            if (pixelArray[posXPixel][posYPixel]==1) {
              // pixels black
              if (my_brother.getIDKnittingTypeSelected()==0) {
                pixelSend[i] = 0;
              }
              if (my_brother.getIDKnittingTypeSelected()==1) {
                switch(my_brother.getPassDoubleBed()) {
                case 0:
                  pixelSend[i] = 1;
                  break;
                case 1:
                  pixelSend[i] = 0;
                  break;
                case 2:
                  pixelSend[i] = 0;
                  break;
                case 3:
                  pixelSend[i] = 1;
                  break;
                }
              }
            }
            else {
              // pixels white
              if (my_brother.getIDKnittingTypeSelected()==0) {
                pixelSend[i] = 1;
              }
              if (my_brother.getIDKnittingTypeSelected()==1) {
                switch(my_brother.getPassDoubleBed()) {
                case 0:
                  pixelSend[i] = 0;
                  break;
                case 1:
                  pixelSend[i] = 1;
                  break;
                case 2:
                  pixelSend[i] = 1;
                  break;
                case 3:
                  pixelSend[i] = 0;
                  break;
                }
              }
            }
          }
        }
        catch(Exception e) {
          println("Error in pixels => x:"+posXPixel+" y:"+posYPixel);
          pixelSend[i] = 1;
        }
      }
      println("send to machine:"+Integer.toString((rows-1)-current_row));
      String pixToSend ="";
      for (int i=0; i<200; i++) {
        pixToSend +=Integer.toString(pixelSend[i]);
        myPort.write(pixelSend[i]);
      }
      pixToSend +=footer;
      println("send:"+pixToSend);
      myPort.write(footer);
      waitingMessageFromKnitting = true;
      pixSendAreReceived = false;
    }
    catch(Exception e) {
    }
  }
}

//------------------------------------------------------------------------------------
// not used at the moment
/*
void sendSerial16() {
 try {
 if ( (millis()-lastMessageSendFromSerial)>500  || !last16Solenoids.equals(_16Solenoids) ) {
 String _16SolenoidsNew = _16Solenoids.replace('9', '1');
 if (headDownSelenoid || isPatternFinishKnitting() ) {
 _16SolenoidsNew ="00000000000000";
 dataToSolenoidHex = 0;
 }
 // new method send data
 char c1 = char(dataToSolenoidHex >> 8);
 char c2 = char(dataToSolenoidHex & 0xFF);
 myPort.write(c1);
 // lower 8 bits
 myPort.write(c2);
 myPort.write(',');
 lastMessageSendFromSerial = millis();
 }
 last16Solenoids = _16Solenoids;
 }
 catch(Exception e) {
 println("Error in send serial");
 }
 }
 */
//------------------------------------------------------------------------------------

// From arduino we receive two type messages
// A: sensors
// B: pixels
void receiveSerial(Serial p) {
  try {
    int timeStart = millis();
    myString = p.readString();
    // PIXELS stored now in Arduino
    try {
      if (myString != null && myString.length()>200) {
        println("Recieved new pixels:"+myString);
        receiveMessageTypeB(myString);
      }
    }
    catch(Exception e) {
      println("Error receiving pixels:"+myString);
    }
    // Data sensors from arduino (encoders, endlines)
    try {
      if (myString != null && myString.length()<200) {
        //println("Recieved new sensors:"+myString);
        receiveMessageTypeA(myString);
      }
    }
    catch(Exception e) {
      println("Error Sensors:"+myString);
    }
  }
  catch(Exception e) {
    println("ERROR in Receive serial "+e.getMessage()+"|");
  }
}

//------------------------------------------------------------------------------------
// Data sensors from arduino (encoders, endlines)
void receiveMessageTypeA(String myString) {
  String[] args = myString.split(",");
  if (args.length>=2) {
    stitch = Integer.valueOf(args[1]);
    //println(stitch);
    headDirection = Integer.valueOf(args[2]);
    //endLineStarted = !args[3].equals("0");
    endLineStarted = true;
    shift = !args[3].equals("0");
    /*//statusMachine 
     if(args.length>=6) solenoidsFromArduino = args[4];
     if(args.length>=7) currentSolenoidIDSetup = Integer.valueOf(args[5]);
     println("Solenoids from arduino "+solenoidsFromArduino);
     println("Current solenoid "+currentSolenoidIDSetup);
     //if(args.length>=8) stitchSetupArduino = Integer.valueOf(args[7]);
     //if(args.length>=9) pixStateArduino = Integer.valueOf(args[8]);
     */
    lastMessageReceivedFromSerial = millis();
    checkBetweenSendAndReceived();
  }
}
//------------------------------------------------------------------------------------
//
void receiveMessageTypeB(String myString) {
  println("received 1:"+myString);
  println(myString.length());
  if (myString.length()>201) {
    println("substring to receive");
    myString = myString.substring(myString.length()-201, myString.length()-1);
  }
  println("received clean:"+myString);
  for (int i=0; i<200; i++) {
    if (myString.substring(i, i+1).equals("0")) {
      pixelReceived[i] = 0;
    }
    else {
      pixelReceived[i] = 1;
    }
  }
  //checkBetweenSendAndReceived();
  waitingMessageFromKnitting = false;
}
//------------------------------------------------------------------------------------

int hexToInt(String hexValue) {
  return Integer.parseInt(hexValue.substring(2), 16);
}

//------------------------------------------------------------------------------------

void convertSolenoidsToBinary() {
  int dataSector = 0;
  // IF IS NOT EQUAL TO 0 PLACE "1" IN EACH BYTE
  for (int i=0;i<16;i++) { 
    if (_16SolenoidsAr[i]!='0') dataSector = dataSector ^ bitRegister16SolenoidTemp[i];
  }
  dataToSolenoidHex  = dataSector;
} 

//------------------------------------------------------------------------------------

void checkBetweenSendAndReceived() {
  try {
    boolean correct = true;

    for (int i=0; i<200; i++) {
      if (pixelSend[i]!=pixelReceived[i] ) {
        if (!waitingMessageFromKnitting || (millis()-lastSerialPixelSend)>100 ) {
          println("Find differents");
          sendtoKnittingMachine();
        }
        correct = false;
        break;
      }
    }
    if (correct && !pixSendAreReceived) {
      sent.trigger();
      pixSendAreReceived = true;
      println("Check and all correct SEND/RECEIVE");
      println("-------------------------------------------");
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------
