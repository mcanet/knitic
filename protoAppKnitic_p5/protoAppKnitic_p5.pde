/*
Prototipe Knitic
 */
//------------------------------------------------------------------------------------
// libraries
//------------------------------------------------------------------------------------
import javax.swing.JOptionPane;
import javax.swing.ImageIcon;
import controlP5.*;
import processing.serial.*;
//------------------------------------------------------------------------------------
// Global variables
//------------------------------------------------------------------------------------
ControlP5 controlP5;
scrollBar myScrollBar;
Serial myPort = null;  
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
String[] _16SolenoidsAr;
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
    ImageIcon titlebaricon = new ImageIcon(loadBytes("knitic_icon.gif"));
    frame.setIconImage(titlebaricon.getImage());
  }
  // List all the available serial ports:
  println(Serial.list());
  setupSerialConnection();
  addButtonsInSetup();
  kniticLogo = loadImage("logo_knitic.png");
  laurentFont = loadFont("Quantico-Regular-20.vlw");
  myScrollBar = new scrollBar();
  currentPixels = new int[200];
  _16SolenoidsAr = new String[16]; 
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
    drawAndSetSelectedGrid();
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
    headDirection =-1;
  }
  if (key=='q') {
    startLeftSide();
    section=29;
    stitch=232;
    headDirection =1;
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
  /*
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
  */
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
    if ( lastChangeHead != "left" && ( stitch<=(-24) || ((100-rightStick-offsetKeedles)>stitch && lastChangeHead != "left") ) ) {
      headDirectionForNewPixels=+1;
      current_row += 1;
      lastChangeHead = "left";
      if (current_row>=rows && repedPatternMode==true) current_row=0;
      println("endLine left");
    }
    if ( lastChangeHead != "right" &&  (stitch>=(224) || ((100+leftStick+offsetKeedles)<stitch && lastChangeHead != "right") ) ) { 
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "right";
      if (current_row>=rows && repedPatternMode==true) current_row=0;
      println("endLine right");
    }
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
  sendSerial();
}

//------------------------------------------------------------
int getReadPixelsFromPosition(int posXPixel) {
  try {
    return pixelArray[199-posXPixel][(rows-1)-current_row];
  }
  catch(Exception e) {
    println("ERROR in pixels to solenoids");
  }
  return 9;
}
//------------------------------------------------------------

