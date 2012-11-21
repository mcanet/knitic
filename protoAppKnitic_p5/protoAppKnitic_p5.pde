/*
Prototipe Knitic
 */
//------------------------------------------------------------------------------------
// libraries
//------------------------------------------------------------------------------------
import javax.swing.JOptionPane;
import controlP5.*;
import processing.serial.*;
//------------------------------------------------------------------------------------
// Global variables
//------------------------------------------------------------------------------------
ControlP5 controlP5;
scrollBar myScrollBar;
Serial myPort;  
PImage kniticLogo;
PImage img;
PFont laurentFont;
String last16Solenoids;
String selected;
String direction = "-";
String status = "off";
String lastSerialData;
String lastChangeHead;
String _16Solenoids = "9999999999999999";
float threshold = 127;
int sizePixel = 3;
int cols = -1;
int rows = -1;
int[][] pixelArray; 
int [] currentPixels;
int current_row = -1;
int stitch = -999;
int section = -999;
int lastSection = -999;
int leftStick = -1;
int rightStick = -1;
int headDirection = 0;
int headDirectionForNewPixels;
int lastConnection;
int lastMessageReceivedFromSerial;
int lastMessageSendFromSerial;
int laststitch = -1;
int posYOffSetPattern = 0;
int patternMouseX;
int patternMouseY;
int buttonWithBar = 230;
boolean usbConected = false;
boolean loadPattern = false;
boolean repedPatternMode = true;
boolean editPixels = false;
boolean endLineStarted = false;
boolean lastEndLineStarted = false;
//------------------------------------------------------------------------------------

void setup() {
  size(1060, 800);
  frameRate(30);
  if (frame != null) {
    frame.setTitle("Knitic pattern manager v.01");
    frame.setResizable(false);
  }
  // List all the available serial ports:
  println(Serial.list());
  setupSerialConnection();
  addButtonsInSetup();
  kniticLogo = loadImage("logo_knitic.png");
  laurentFont = loadFont("LaurenScript-20.vlw");
  myScrollBar = new scrollBar();
  currentPixels = new int[200];
  lastMessageReceivedFromSerial = millis();
  lastConnection = millis();
}
//------------------------------------------------------------------------------------
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
  showCursorPosition();
  updateEditPixels();
}
//------------------------------------------------------------------------------------
void keyPressed() {
  if (key=='o') {
    openknittingPattern();
  }
  // key for debug program
  if (key=='w') {
    startRightSide();
  }
  if (key=='q') {
    startLeftSide();
  }
  if (key=='s' && endLineStarted) {
    stitch-=1;
    if (stitch<-32) { 
      stitch=-32;
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
}
//------------------------------------------------------------------------------------
void startRightSide() {
  section=-4;
  stitch=-32;
  current_row = 0;
  headDirection=1;
  endLineStarted = true;
  lastEndLineStarted = false;
  lastChangeHead = "right";
}
//------------------------------------------------------------------------------------
void startLeftSide() {
  current_row = 0;
  section=29;
  stitch=232;
  headDirection=-1;
  endLineStarted = true;
  lastEndLineStarted = false;
  lastChangeHead = "left";
}
//------------------------------------------------------------------------------------
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
    if ( lastChangeHead != "right" && ( stitch==(-30) || ((100-rightStick-32)>stitch && headDirection==1) ) ) {
      headDirectionForNewPixels=+1;
      current_row += 1;
      lastChangeHead = "right";
      println("endLine right");
    }
    if ( lastChangeHead != "left" &&  (stitch==(229) || ((100+leftStick+32)<stitch && headDirection==-1) ) ) { 
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "left";
      if (current_row>rows && repedPatternMode==true) rows=0;
      println("endLine left");
    }
    if (stitch!=laststitch && headDirectionForNewPixels==headDirection ) {
      println("ADVANCING");
      _16Solenoids = "";
      if (headDirection == -1)  rightDirection(); 
      if (headDirection == 1)   leftDirection();
      laststitch = stitch;
    }
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
  sendSerial();
}
//------------------------------------------------------------------------------------
void rightDirection() {
  println("rightDirection");
  if ((section%2)!=1) {
    println("section 1");
    for (int _x=-8;_x<8;_x++) {
      int posXPixel =  rightPixelPosCalculator(section, cols, _x, rightStick );//-((section-1)*8)+(cols-1-_x)+(100-rightStick);
      println(posXPixel);
      getPixelsFromPosition(posXPixel);
    }
  }
  else {
    println("section 0");
    for (int _x=0;_x<8;_x++) {
      int posXPixel =  rightPixelPosCalculator(section, cols, _x, rightStick );//-((section-1)*8)+(cols-1-_x)+(100-rightStick);
      println(posXPixel);
      getPixelsFromPosition(posXPixel);
    }
    for (int _x=-8;_x<0;_x++) {
      int posXPixel =  rightPixelPosCalculator(section, cols, _x, rightStick );//-((section-1)*8)+(cols-1-_x)+(100-rightStick);
      println(posXPixel);
      getPixelsFromPosition(posXPixel);
    }
  }
}
//------------------------------------------------------------
void leftDirection() {
  println("leftDirection");
  if ((section%2)!=0) {
    println("section0");
    for (int _x=8;_x<16;_x++) {
      int posXPixel =  leftPixelPosCalculator(section, cols, _x, rightStick );//-((section)*8)+(cols-1-_x)+(100-rightStick);
      println(posXPixel);
      getPixelsFromPosition(posXPixel);
    }
    for (int _x=0;_x<8;_x++) {
      int posXPixel =  leftPixelPosCalculator(section, cols, _x, rightStick );//-((section)*8)+(cols-1-_x)+(100-rightStick);
      println(posXPixel);
      getPixelsFromPosition(posXPixel);
    }
  }
  else {
    println("section1");
    for (int _x=0;_x<16;_x++) {
      int posXPixel =  leftPixelPosCalculator(section, cols, _x, rightStick );//-((section)*8)+(cols-1-_x)+(100-rightStick)+32;
      println(posXPixel);
      getPixelsFromPosition(posXPixel);
    }
  }
}
//------------------------------------------------------------
int rightPixelPosCalculator(int section, int cols, int _x, int rightStick ) {
  int posXPixel =  -((section-1)*8)+(cols+_x)+(100-rightStick)-32;
  print(posXPixel);
  print(" | ");
  print(posXPixel);
  print("<");
  print(-(stitch-168));
  if (posXPixel<-(stitch-168) && posXPixel>=0 ) {
    posXPixel = posXPixel+16;
    print(" | pixel modify ");
  }
  print(" | pixelX:");
  //println(posXPixel);
  return posXPixel;
}
//------------------------------------------------------------
int leftPixelPosCalculator(int section, int cols, int _x, int rightStick ) {
  int posXPixel = -((section)*8)+(cols-1-_x)+(100-rightStick)+32+8; 
  print(" | ");
  print(posXPixel);
  print("<");
  print(232-stitch);
  if ( int(posXPixel)>=int(232-stitch) ) {
    posXPixel = posXPixel-16;
    print(" | pixel modify ");
  }
  print(" | pixelX:");
  return posXPixel;
}
//------------------------------------------------------------
void getPixelsFromPosition(int posXPixel) {
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
//------------------------------------------------------------

