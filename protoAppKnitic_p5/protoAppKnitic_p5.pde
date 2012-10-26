/*
 Prototipe Knitic
 */
import javax.swing.JOptionPane;
import controlP5.*;
import processing.serial.*;

String _16Selenoids = "0000000000000000";
// The serial port:
Serial myPort;  
String selected;
PImage kniticLogo;
PFont laurentFont;
int current_row = -1;
int stich = -1;
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
}

void draw() {
  frame.setTitle("Knitic pattern manager v.01 F:"+Float.toString(frameRate));
  background(200, 200, 200);
  sendAndReceiveSerial();
  display();
  drawPatternGrid();
  if (loadPattern) drawPattern();
  myScrollBar.mouseMoveScroll();
  brain();
}

void keyPressed() {
  if (key=='q') {
    section=0;
    endLineStarted = true;
  }
  if (key=='w') {
    section=25;
    endLineStarted = true;
  }
  if (key=='a') {
    section-=1;
    headDirection =-1; 
    if (section<1) section=1;
  }
  if (key=='s') {
    section+=1;
    headDirection =1; 
    if (section>25) section=25;
  }
  if (key=='o') {
    openknittingPattern();
  }
}

void drawPattern() {
  pushMatrix();
  translate(230+((100-leftStick)*3), 0);
  int cubSize = 3;
  for (int x=0;x<cols;x++) {
    for (int y=0;y<rows;y++) {
      if (pixelArray[x][y]==1) {
        fill(255);
      }
      else {
        fill(0);
      }
      /*
       if(insertingPixelsPattern && rowtPixelPointer==y && columntPixelPointer==x ){
       fill(255,0,0);
       }
       */
      rect(x*cubSize, y*cubSize, cubSize, cubSize);
    }
  }
  popMatrix();
}

void fillArrayWithImage(String imgPath) { 
  img = loadImage(imgPath);
  cols = img.width;
  if (cols>200) {
    JOptionPane.showMessageDialog(frame, "The image have more than 200 pixels", "Alert from Knitic", 2);
  }
  else {

    rows = img.height;
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
        int loc = (cols-1)-x + y*cols;
        if (brightness(img.pixels[loc]) > threshold) {
          pixelArray[x][y] = 1;
        }
        else {
          pixelArray[x][y] = 0;
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
    if ( lastChangeHead != "right" && ( section==25 /*|| (int((100+rightStick)/8)>section && headDirection==1)*/ ) ) {
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "right";
    }
    if ( lastChangeHead != "left" &&  (section==1 /*|| (int((rightStick)/8)<section && headDirection==-1)*/ ) ) { 
      headDirectionForNewPixels=+1;
      current_row += 1;
      lastChangeHead = "left";
    }

    if (lastSection != section && headDirectionForNewPixels==headDirection) {
      println("ADVANCING");
      //
      print(section);
      print(">=");
      print(floor((100-leftStick)/8));
      print(" && ");
      print(section);
      print("=<");
      println(ceil(float(100+rightStick)/8));

      if (current_row<rows && section>= floor(float(100-leftStick)/8) && section <= ceil(float(100+rightStick)/8) ) {
        _16Selenoids = "";

        if (headDirection==-1)leftDirection();
        if (headDirection==1)RightDirection();
        println(_16Selenoids);
      }//end rows if
    }
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
}

void leftDirection() {
  if ((section%2)!=1) {
    for (int _x=0;_x<16;_x++) {
      int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][current_row]==1) {
          _16Selenoids +='1';
        }
        else {
          _16Selenoids +='0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids +='0';
      }
    }
  }
  else {
    for (int _x=0;_x<8;_x++) {
      int posXPixel = ((section-1)*8)+_x-(100-leftStick);
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][current_row]==1) {
          _16Selenoids +='1';
        }
        else {
          _16Selenoids +='0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids +='0';
      }
    }
    for (int _x=-8;_x<0;_x++) {
      int posXPixel = ((section-2)*8)+_x-(100-leftStick);
      println(posXPixel);
      try {
        if (pixelArray[posXPixel][current_row]==1) {
          _16Selenoids +='1';
        }
        else {
          _16Selenoids +='0';
        }
      }
      catch(Exception e) {
        println("ERROR in pixels to selenoids");
        _16Selenoids +='0';
      }
    }
  }
}

void RightDirection() {
}

