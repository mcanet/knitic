/*
Prototipe Knitic
 */
import javax.swing.JOptionPane;
import controlP5.*;
import processing.serial.*;

String _16Solenoids = "9999999999999999";
// The serial port:
Serial myPort;  
String selected;
PImage kniticLogo;
PFont laurentFont;
int current_row = -1;
int stitch = -999;
int section = -999;
int lastSection = -999;
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
String last16Solenoids;

int [] currentPixels;

int laststitch = -1;
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
    section=-4;
    stitch=-32;
    current_row = 0;
    headDirection=1;
    endLineStarted = true;
    lastEndLineStarted = false;
  }
  if (key=='q') {
    current_row = 0;
    section=29;
    stitch=232;
    headDirection=-1;
    endLineStarted = true;
    lastEndLineStarted = false;
  }
  if (key=='s' && endLineStarted) {
    stitch-=1;
    if (stitch<1) { 
      stitch=32;
    }
    else {
      headDirection =-1;
    }
    section = ceil(float(stitch)/8.0f);
  }
  if (key=='a' && endLineStarted) {
    stitch+=1;
    if (stitch>232) { 
      stitch=232;
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
   _16Solenoids = "1000000000000000";
   }
   if (key=='2') {
   _16Solenoids = "0100000000000000";
   }
   if (key=='3') {
   _16Solenoids = "0000000000000000";
   }
   if (key=='4') {
   _16Solenoids = "0001000000000000";
   }
   if (key=='5') {
   _16Solenoids = "0000100000000000";
   }
   if (key=='6') {
   _16Solenoids = "0000010000000000";
   }
   if (key=='7') {
   _16Solenoids = "0000001000000000";
   }
   if (key=='8') {
   _16Solenoids = "0000000100000000";
   }
   if (key=='9') {
   _16Solenoids = "0000000010000000";
   }
   if (key=='0') {
   _16Solenoids = "0000000001000000";
   }
   if (key=='r') {
   _16Solenoids = "0000000000100000";
   }
   if (key=='t') {
   _16Solenoids = "0000000000010000";
   }
   if (key=='y') {
   _16Solenoids = "0000000000001000";
   }
   if (key=='u') {
   _16Solenoids = "0000000000000100";
   }
   if (key=='i') {
   _16Solenoids = "0000000000000010";
   }
   if (key=='o') {
   _16Solenoids = "0000000000000001";
   }
   */
}

void fillArrayWithImage(String imgPath) { 
  try {
    img = loadImage(imgPath);
    cols = img.width;
    if (cols>200) {
      JOptionPane.showMessageDialog(frame, "The image have more than 200 pixels", "Alert from Knitic", 2);
    }
    else {
      laststitch = -1;
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
  catch(Exception e) {
  }
}

// right 32
// left  32
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
    if ( lastChangeHead != "right" && ( stitch==(-32) /*|| (int((100+rightStick)/8)>section && headDirection==1)*/ ) ) {
      headDirectionForNewPixels=+1;
      current_row += 1;
      lastChangeHead = "right";
    }
    if ( lastChangeHead != "left" &&  (stitch==(232) /*|| (int((rightStick)/8)<section && headDirection==-1)*/ ) ) { 
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "left";
      if (current_row>rows && repedPatternMode==true) rows=0;
    }

    //if (lastSection != section ) {

    if (stitch!=laststitch && headDirectionForNewPixels==headDirection ) {
      println("ADVANCING");
      _16Solenoids = "";
      //if (headDirection==-1)rightDirection();
      if (headDirection==1)leftDirection();
      laststitch = stitch;
    }
    //end rows if
    //}
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
}
/*
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
 */
void rightDirection() {
  println("rightDirection");
  if ((section%2)!=1) {
    println("section 1");
    for (int _x=-8;_x<8;_x++) {
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      if (posXPixel<(stitch-168) && posXPixel<=168) {
        posXPixel = posXPixel+16;
        print("pixel modify:");
        println(posXPixel);
      }
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0 ) {
          _16Solenoids =_16Solenoids+'1';
        }
        else {
          _16Solenoids =_16Solenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to solenoids");
        _16Solenoids =_16Solenoids+'9';
      }
    }
  }
  else {
    println("section 0");
    for (int _x=0;_x<8;_x++) {
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      print(posXPixel);
      print("<");
      print((stitch-168));
      if (posXPixel<(stitch-168) && posXPixel<=168) {
        posXPixel = posXPixel+16;
        print("pixel modify:");
        println(posXPixel);
      }
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Solenoids =_16Solenoids+'1';
        }
        else {
          _16Solenoids =_16Solenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to solenoids");
        _16Solenoids =_16Solenoids+'9';
      }
    }
    for (int _x=-8;_x<0;_x++) {
      int posXPixel =  -((section-1)*8)+(cols-1-_x)+(100-rightStick);
      if (posXPixel<(stitch-168) && posXPixel<=168) {
        posXPixel = posXPixel+16;
        print("pixel modify:");
        println(posXPixel);
      }
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Solenoids =_16Solenoids+'1';
        }
        else {
          _16Solenoids =_16Solenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to solenoids");
        _16Solenoids =_16Solenoids+'9';
      }
    }
  }
}
//------------------------------------------------------------
void leftDirection() {
  println("leftDirection");
  if ((section%2)!=1) {
    println("section0");
    for (int _x=8;_x<16;_x++) {
      int posXPixel =  -((section)*8)+(cols-1-_x)+(100-rightStick);
      if (posXPixel>(232-stitch)) {
        posXPixel = posXPixel-16;
        print("pixel modify:");
        println(posXPixel);
      }
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Solenoids = _16Solenoids+'1';
        }
        else {
          _16Solenoids =_16Solenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to solenoids");
        _16Solenoids =_16Solenoids+'9';
      }
    }
    for (int _x=0;_x<8;_x++) {
      int posXPixel =  -((section)*8)+(cols-1-_x)+(100-rightStick);
      if (posXPixel>(232-stitch)) {
        posXPixel = posXPixel-16;
        print("pixel modify:");
        println(posXPixel);
      }
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Solenoids = _16Solenoids+'1';
        }
        else {
          _16Solenoids =_16Solenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to solenoids");
        _16Solenoids =_16Solenoids+'9';
      }
    }
  }
  else {
    println("section1");
    for (int _x=0;_x<16;_x++) {
      int posXPixel =  -((section)*8)+(cols-1-_x)+(100-rightStick)+32;
      print(posXPixel);
      print(">");
      println(232-stitch);
      if ( int(posXPixel)>int(232-stitch) ) {
        posXPixel = posXPixel-16;
        print("pixel modify:");
        println(posXPixel);
      }
      print("pixelX:");
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][(rows-1)-current_row]==0) {
          _16Solenoids = _16Solenoids+'1';
        }
        else {
          _16Solenoids =_16Solenoids+'0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to solenoids");
        _16Solenoids =_16Solenoids+'9';
      }
    }
  }
}

