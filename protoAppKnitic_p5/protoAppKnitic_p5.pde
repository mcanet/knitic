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
String status = "o";
String statusMachine = "o"; 
String lastSerialData;
String lastChangeHead;
String _16Solenoids = "9999999999999999";
float threshold = 127;
int counterMessagesReceive=0;
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
int offsetKeedles = 24;
int serialAvailableBuffer;
boolean usbConected = false;
boolean loadPattern = false;
boolean repedPatternMode = true;
boolean editPixels = false;
boolean endLineStarted = false;
boolean lastEndLineStarted = false;
//------------------------------------------------------------------------------------
void setup() {
  size(1060, 800);
  frameRate(35);
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
  autoConnectAndReceiveSerial();
  display();
  drawPatternGrid();
  if (loadPattern) { 
    drawPattern();
    if (status=="k") drawSelectedGrid();
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
    section=-4;
    stitch=-32;
  }
  if (key=='q') {
    startLeftSide();
    section=29;
    stitch=232;
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
  if (key=='1') {
    _16Solenoids = "1100000000000000";
  }
  if (key=='2') {
    _16Solenoids = "1010000100000001";
  }
  if (key=='3') {
    _16Solenoids = "1111111100000000";
  }
  if (key=='4') {
    _16Solenoids = "1111111111111111";
  }
}
//------------------------------------------------------------------------------------
void startRightSide() {
  current_row = 0;
  headDirectionForNewPixels=+1;
  endLineStarted = true;
  //lastEndLineStarted = false;
  lastChangeHead = "left";
}
//------------------------------------------------------------------------------------
void startLeftSide() {
  current_row = 0;
  headDirectionForNewPixels=-1;
  endLineStarted = true;
  //lastEndLineStarted = false;
  lastChangeHead = "right";
}
//------------------------------------------------------------------------------------
void brain() {
  // start position
  if ( status=="r" && endLineStarted && ( stitch>=200 || stitch<=0) ) {
    current_row = -1;
    status = "k";
    lastChangeHead = "";
    if (stitch<=0) startRightSide();
    if (stitch>=200) startLeftSide();
  }
  // put new pixels
  if ( endLineStarted ) {
    // END of LINE
    if ( lastChangeHead != "left" && ( stitch<=(-24) || ((100-rightStick-offsetKeedles)>stitch && headDirection==1) ) ) {
      headDirectionForNewPixels=+1;
      current_row += 1;
      lastChangeHead = "left";
      println("endLine left");
    }
    if ( lastChangeHead != "right" &&  (stitch>=(224) || ((100+leftStick+offsetKeedles)<stitch && headDirection==-1) ) ) { 
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "right";
      if (current_row>rows && repedPatternMode==true) rows=0;
      println("endLine right");
    }
    // ADVANCING IN THE LINE
    if (stitch!=laststitch && headDirectionForNewPixels==headDirection ) {
      println("ADVANCING");
      _16Solenoids = "";
      if (headDirection == 1)   leftDirection();
      if (headDirection == -1)  rightDirection(); 
      laststitch = stitch;
    }
    else {
      //println("not ADVANCING");
    }
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
  sendSerial();
}
//------------------------------------------------------------
// THIS IS OK
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
//------------------------------------------------------------------------------------
// NEED TO FIX
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
int leftPixelPosCalculator(int section, int cols, int _x, int rightStick ) {
  int posXPixel = -((section)*8)+(cols-1-_x)+(100-rightStick)+8+offsetKeedles; 
  print(" | ");
  print(posXPixel);
  print("<");
  print((200+offsetKeedles)-stitch);
  if ( int(posXPixel)>=int((200+offsetKeedles)-stitch)  ) {
    posXPixel = posXPixel-16;
    print(" | pixel modify ");
  }
  print(" | pixelX:");
  return posXPixel;
}
//------------------------------------------------------------
int rightPixelPosCalculator(int section, int cols, int _x, int rightStick ) {
  int posXPixel =  -((section-1)*8)+(cols+_x)+(100-rightStick)-offsetKeedles-16;
  print(posXPixel);
  print(" | ");
  print(posXPixel);
  print("<");
  print(((16-offsetKeedles)+(199-stitch)));
  if (posXPixel<((16-offsetKeedles-16)+(199-stitch)) && posXPixel>=0 ) {
    posXPixel = posXPixel+16;
    print(" | pixel modify ");
  }
  print(" | pixelX:");
  //println(posXPixel);
  return posXPixel;
}
/*
int rightPixelPosCalculator(int section, int cols, int _x, int rightStick ) {
 int posXPixel =  -((section-1)*8)+(cols+_x)+(100-rightStick)-offsetKeedles+16;
 print(posXPixel);
 print(" | ");
 print(posXPixel);
 print("<");
 print(-(stitch-(200-offsetKeedles)));
 if (posXPixel<-(16+stitch-(200-(offsetKeedles))) && posXPixel>=0 ) {
 posXPixel = posXPixel+16;
 print(" | pixel modify ");
 }
 print(" | pixelX:");
 //println(posXPixel);
 return posXPixel;
 }
 */
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

