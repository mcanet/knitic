import java.io.*;
import java.util.*;

int BAUD_RATE = 115200; //--57600
byte lf = 0x40;
byte footer = 126;

void setupSerialConnection() {
  try {
    println("try to connect");
    println(Serial.list()[0]);
    myPort = new Serial(this, Serial.list()[0], BAUD_RATE);
    delay(2000);
    myPort.clear();
    lastConnection = millis();
  } 
  catch (Exception e) {
    if (e.getMessage().contains("<init>")) {
      println("port in use, trying again later...");
    }
  }
}

//------------------------------------------------------------------------------------

void autoConnectAndReceiveSerial() {
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
         //setupSerialConnection();
         */
      }
    }
    else {
      usbConected = true;
    }

    receiveSerial();
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

void sendtoKnittingMachine() {
  try {
    for (int i=0; i<200; i++) {
      pixelSend[i] = 1;
    }
    for (int i=0; i<200; i++) {
      try {
        int rightStickOffset = 100-rightStick;
        int posXPixel = i+rightStickOffset;
        int pixelId = pixelArray[199-posXPixel][(rows-1)-current_row];
        if (pixelId==1) {
          pixelSend[i] = 0;
        }
        else {
          pixelSend[i] = 1;
        }
      }
      catch(Exception e) {
        //println("Error in pixels:"+Integer.toString(i));
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

//------------------------------------------------------------------------------------
// not used at the moment

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

//------------------------------------------------------------------------------------

void receiveSerial() {
  try {
    int timeStart = millis();
    serialAvailableBuffer = myPort.available();
    while (myPort!=null && myPort.available ()>0  && (millis()-timeStart<5 )) {
      //println("Receive Serial___"+Integer.toString(myPort.available()));
      myString = myPort.readStringUntil(lf);
      // PIXELS stored now in Arduino
      try {
        if (myString != null && myString.length()>200) {
          //println("received 1:"+myString);
          if (myString.length()>201) {
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
          //chechBetweenSendAndReceived();
        }
      }
      catch(Exception e) {
      }
      try {
        // Data sensors from arduino (encoders, endlines)
        if (myString != null && myString.length()<200) {
          String[] args = myString.split(",");
          if (args.length>=2) {
            stitch = Integer.valueOf(args[1]);
            headDirection = Integer.valueOf(args[2]);
            endLineStarted = !args[3].equals("0");
            shift = !args[4].equals("0");
            //statusMachine 
            /*
            if(args.length>=6) solenoidsFromArduino = args[5];
             if(args.length>=7) currentSolenoidIDSetup = Integer.valueOf(args[6]);
             if(args.length>=8) stitchSetupArduino = Integer.valueOf(args[7]);
             if(args.length>=9) pixStateArduino = Integer.valueOf(args[8]);
             */
            lastMessageReceivedFromSerial = millis();
            checkBetweenSendAndReceived();
          }
        }
      }
      catch(Exception e) {
        println("Error sensors:"+myString);
      }
    }
  }
  catch(Exception e) {
    println("ERROR in receive serial "+e.getMessage()+"|");
  }
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
        sendtoKnittingMachine();
        println("find differents");
        correct = false;
        break;
      }
    }
    if (correct && !pixSendAreReceived) {
      sent.trigger();
      pixSendAreReceived = true;
      println("Check and all correct SEND/RECEIVE");
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

