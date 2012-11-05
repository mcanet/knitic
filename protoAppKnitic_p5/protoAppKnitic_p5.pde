/*
Prototipe Knitic
 */
import javax.swing.JOptionPane;
import controlP5.*;
import processing.serial.*;

String _16Selenoids = "9999999999999999";
// The serial port:
Serial myPort;  
String selected;
PImage kniticLogo;
PFont laurentFont;
int current_row = -1;
int stitch = -1;
int section = -1;
int lastSection = -1;
boolean endLineStarted = false;
boolean lastEndLineStarted = false;
int leftStick = -1;
int rightStick = -1;
int headDirection = 0;
int headDirectionForNewPixels;
String direction = "-";
String status = "off";
boolean loadPattern = false;
boolean repedPatternMode = true;
int sizePixel = 3;

PImage img;
int cols = -1;
int rows = -1;
int[][] pixelArray; 
float threshold = 127;
String lastSerialData;
String lastChangeHead;

ControlP5 controlP5;
boolean usbConected = false;

scrollBar myScrollBar;

int lastConnection;
int lastMessageReceivedFromSerial;
int lastMessageSendFromSerial;
String last16Selenoids;


int [] currentPixels;

int lastsection = -1;
int posYOffSetPattern = 0;

void setup() {
  size(1060, 800);
  // List all the available serial ports:
  println(Serial.list());
  setupSerialConnection();

  kniticLogo = loadImage("logo_knitic.png");
  laurentFont = loadFont("LaurenScript-20.vlw");
  addButtonsInSetup();
  if (frame != null) {
    frame.setTitle("Knitic pattern manager v.01");
    frame.setResizable(false);
  }
  frameRate(30);
  myScrollBar = new scrollBar();
  lastMessageReceivedFromSerial = millis();
  lastConnection = millis();

  currentPixels = new int[200];
}

void draw() {
  frame.setTitle("Knitic pattern manager v.01 F:"+Float.toString(frameRate));
  background(200, 200, 200);
  sendAndReceiveSerial();
  display();
  drawPatternGrid();
  if (loadPattern) { 
    drawPattern();
    drawSelectedGrid();
  }
  //drawPatternThumbnail();
  myScrollBar.mouseMoveScroll();
  brain();
}

void keyPressed() {
  if (key=='w') {
    section=1;
    stitch=1;
    current_row = -1;
    headDirection=1;
    endLineStarted = true;
    lastEndLineStarted = false;
  }
  if (key=='q') {
    current_row = -1;
    section=25;
    stitch=200;
    headDirection=-1;
    endLineStarted = true;
    lastEndLineStarted = false;
  }
  if (key=='s' && endLineStarted) {
    stitch-=1;
    if (stitch<1) { 
      stitch=1;
    }
    else {
      headDirection =-1;
    }
    section = ceil(float(stitch)/8.0f);
  }
  if (key=='a' && endLineStarted) {
    stitch+=1;
    if (stitch>200) { 
      stitch=200;
    }
    else {
      headDirection =1;
    }
    section = ceil(float(stitch)/8.0f);
  }
  if (key=='o') {
    openknittingPattern();
  }
  /*
  if (key=='1') {
   _16Selenoids = "1000000000000000";
   }
   if (key=='2') {
   _16Selenoids = "0100000000000000";
   }
   if (key=='3') {
   _16Selenoids = "0000000000000000";
   }
   if (key=='4') {
   _16Selenoids = "0001000000000000";
   }
   if (key=='5') {
   _16Selenoids = "0000100000000000";
   }
   if (key=='6') {
   _16Selenoids = "0000010000000000";
   }
   if (key=='7') {
   _16Selenoids = "0000001000000000";
   }
   if (key=='8') {
   _16Selenoids = "0000000100000000";
   }
   if (key=='9') {
   _16Selenoids = "0000000010000000";
   }
   if (key=='0') {
   _16Selenoids = "0000000001000000";
   }
   if (key=='r') {
   _16Selenoids = "0000000000100000";
   }
   if (key=='t') {
   _16Selenoids = "0000000000010000";
   }
   if (key=='y') {
   _16Selenoids = "0000000000001000";
   }
   if (key=='u') {
   _16Selenoids = "0000000000000100";
   }
   if (key=='i') {
   _16Selenoids = "0000000000000010";
   }
   if (key=='o') {
   _16Selenoids = "0000000000000001";
   }
   */
}

void fillArrayWithImage(String imgPath) { 
  img = loadImage(imgPath);
  cols = img.width;
  if (cols>200) {
    JOptionPane.showMessageDialog(frame, "The image have more than 200 pixels", "Alert from Knitic", 2);
  }
  else {
    lastsection = -1;
    section = -1;
    rows = img.height;
    if (img.height>750) { 
      posYOffSetPattern = (img.height*sizePixel)-750;
    }
    else { 
      posYOffSetPattern = 0;
    }
    endLineStarted = false;
    lastEndLineStarted = false;
    if (cols>0 && rows>0) loadPattern = true;
    pixelArray = new int[cols][rows];
    myScrollBar.setupScrollBar();
    int restPixels = 200-cols;
    leftStick = 100-(restPixels/2);
    rightStick = 100-(restPixels/2);
    if ( (100-leftStick)+cols+(100-rightStick) !=200) {
      rightStick +=1;
    }

    String userStartStick="";
    if (cols!=200) {

      userStartStick = JOptionPane.showInputDialog(frame, "Do you want to start from left " +Integer.toString(leftStick)+"?", Integer.toString(leftStick));
      if (!userStartStick.equals(Integer.toString(leftStick))) {
        leftStick = Integer.valueOf(userStartStick);
        rightStick = (cols+(100-leftStick))-100;
      }
    }

    img.loadPixels(); 
    for (int y = 0; y <rows; y++) {
      for (int x = 0; x <  cols; x++) {
        int loc = /*(cols-1)-*/x + y*cols;
        if (brightness(img.pixels[loc]) > threshold) {
          pixelArray[x][y] = 0;
        }
        else {
          pixelArray[x][y] = 1;
        }
      }
    }
  }
}

void brain() {
  // start position
  if (endLineStarted && !lastEndLineStarted) {
    current_row = -1;
    status = "knitting";
    lastChangeHead = "";
  }
  // put new pixels
  if ( endLineStarted ) {
    // found expected direction
    if ( lastChangeHead != "right" && ( stitch==1 /*|| (int((100+rightStick)/8)>section && headDirection==1)*/ ) ) {
      headDirectionForNewPixels=+1;
      current_row += 1;
      lastChangeHead = "right";
    }
    if ( lastChangeHead != "left" &&  (stitch==200 /*|| (int((rightStick)/8)<section && headDirection==-1)*/ ) ) { 
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "left";
      if (current_row>rows && repedPatternMode==true) rows=0;
    }

    if (lastSection != section && headDirectionForNewPixels==headDirection) {
      println("ADVANCING");
      //
      /*
      print(section);
       print(">=");
       print(floor((100-leftStick)/8));
       print(" && ");
       print(section);
       print("=<");
       println(ceil(float(100+rightStick)/8));
       */

      //if (current_row<rows && section>= floor(float(100-leftStick)/8) && section <= ceil(float(100+rightStick)/8) ) {
      if (section!=lastsection) {
        _16Selenoids = "";
        if (headDirection==-1)RightDirection();
        if (headDirection==1)leftDirection();
        //pixelFillToSelenoids();
        //getCurrent200pixels();
        println(_16Selenoids);
        lastsection = section;
      }
      //end rows if
    }
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
}

void getCurrent200pixels() {
  for (int i=0;i<200;i++) {
    if (current_row<rows && i>(100-leftStick)  && i<((100-leftStick)+cols)) {
      int posXPixel = i-(100-leftStick);
      currentPixels[i] = pixelArray[posXPixel][(rows-1)-current_row];
    }
    else {
      currentPixels[i] = -1;
    }
  }
}


void RightDirection() {
  println("rightDirection");
  if ((section%2)!=1) {
    println("section 1");
    for (int _x=-8;_x<8;_x++) {
      //int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      // -(8-1)*8-x
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Selenoids =_16Selenoids+'1';
        }
        else {
          _16Selenoids =_16Selenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids =_16Selenoids+'9';
      }
    }
  }
  else {
    println("section 0");
    for (int _x=0;_x<8;_x++) {
      //int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Selenoids =_16Selenoids+'1';
        }
        else {
          _16Selenoids =_16Selenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids =_16Selenoids+'9';
      }
    }
    for (int _x=-8;_x<0;_x++) {
      //int posXPixel = ((section-2)*8)+_x-(100-leftStick);
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Selenoids =_16Selenoids+'1';
        }
        else {
          _16Selenoids =_16Selenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids =_16Selenoids+'9';
      }
    }
  }
}

void leftDirection() {
  println("leftDirection");
  if ((section%2)!=1) {

    println("section0");
    for (int _x=8;_x<16;_x++) {
      //int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Selenoids = _16Selenoids+'1';
        }
        else {
          _16Selenoids =_16Selenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids =_16Selenoids+'9';
      }
    }
    for (int _x=0;_x<8;_x++) {
      //int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Selenoids = _16Selenoids+'1';
        }
        else {
          _16Selenoids =_16Selenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids =_16Selenoids+'9';
      }
    }
  }
  else {
    println("section1");
    //print("section1-8firstNext-8second later");
    for (int _x=0;_x<16;_x++) {
      //int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Selenoids = _16Selenoids+'1';
        }
        else {
          _16Selenoids =_16Selenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids =_16Selenoids+'9';
      }
    }
  }
}

