import processing.serial.*;

int[] pixelReceived = {
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0
};

int[] pixelSend = {
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0
};

int[] pixelLine1 = {
  1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0
};

int[] pixelLine2 = {
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1
};

byte lf = 0x40;
byte footer = 126;
byte startChar = 4;
Serial myPort;
String myString;

int stitch;
boolean endLineStarted;
int headDirection;
String statusMachine;

void setup(){
  size(1200,200);
  String portName = Serial.list()[0];
  println(portName);
  myPort = new Serial(this, portName,115200);
  myPort.clear();
}

void draw(){
  // draw
  
  for (int i=0;i<200;i++) {
    if (pixelSend[i]==0) {
      fill(255, 0, 255);
    }
    else {
      fill(255, 255, 255);
    }
    rect(i*5, height-5, 5, 5);
  }
  for (int i=0;i<200;i++) {
    if (pixelReceived[i]==0) {
      fill(255, 0, 255);
    }
    else {
      fill(255, 255, 255);
    }
    rect(i*5, height-10, 5, 5);
  }
  
  // receive serial
  receiveSerial();
  
}

void chechBetweenSendAndReceived(){
  for (int i=0; i<200; i++) {
    if(pixelSend[i]!=pixelReceived[i] ){
      sendtoKnittingMachine();
      break;
    }
  }
}

void receiveSerial() {
  try {
    int timeStart = millis();
    //serialAvailableBuffer = myPort.available();
    while (myPort!=null && myPort.available ()>0  && (millis()-timeStart<300 )) {
      //println("Receive Serial___"+Integer.toString(myPort.available()));
      myString = myPort.readStringUntil(lf);
      // PIXELS stored now in arduino
      try {
        if (myString != null && myString.length()>200) {
          println("received:"+myString);
          for (int i=0; i<200; i++) {
            if (myString.substring(i, i+1).equals("0")) {
              pixelReceived[i] = 0;
            }
            else {
              pixelReceived[i] = 1;
            }
          }
          
          for (int i=0; i<200; i++) {
            if (pixelReceived[i]!=pixelSend[i]) {
              sendtoKnittingMachine();
              break;
            }
          }
        }
      }
      catch(Exception e) {
      }
      // Data sensors from arduino (encoders, endlines)
      if (myString != null && myString.length()<200) {
          //println("received small:"+myString);
          String[] args = myString.split(",");
          if (args.length>2) {
            stitch = Integer.valueOf(args[0]);
            endLineStarted = !args[1].equals("0");
            headDirection = Integer.valueOf(args[2]);
            statusMachine = args[3];
          }
        }
    }
  }
  catch(Exception e) {
    println("ERROR in receive serial "+e.getMessage());
  }
}

void keyPressed(){
  if(key=='1'){ 
    sendtoKnittingMachine();
    for (int i=0;i<200;i++) {
      pixelSend[i] = pixelLine1[i];
    }
  }
  if(key=='2'){ 
    sendtoKnittingMachine();
    for (int i=0;i<200;i++) {
      pixelSend[i] = pixelLine2[i];
    }
  }
}
// send to arduino
void sendtoKnittingMachine() {
  myPort.clear();
  println("send to machine");
  for (int i=0; i<200; i++) {
    myPort.write(pixelSend[i]);
  }
  myPort.write(footer);
}
