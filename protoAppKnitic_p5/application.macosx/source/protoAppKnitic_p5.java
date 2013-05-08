import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.JOptionPane; 
import javax.swing.ImageIcon; 
import controlP5.*; 
import processing.serial.*; 
import sojamo.drop.*; 
import ddf.minim.*; 
import java.io.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class protoAppKnitic_p5 extends PApplet {

/*
Prototipe Knitic
 */
//------------------------------------------------------------------------------------
// libraries
//------------------------------------------------------------------------------------





//------------------------------------------------------------------------------------
// Global variables
//------------------------------------------------------------------------------------
ControlP5 controlP5;
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
char[] _16SolenoidsAr;
String _16Solenoids = "9999999999999999";
String solenoidsFromArduino= "9999999999999999";
int lastSolenoidChange;
boolean headDownSelenoid = false;
float threshold = 127;
int counterMessagesReceive=0;
int sizePixel = 3;
int cols = -1;
int rows = -1;
int[][] pixelArray; 
int [] currentPixels;
int current_row = -1;
int stitch = -999;
int _lastStitch;
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
boolean waitingMessageFromKnitting;
int dataToSolenoidHex;
int bitRegister16SolenoidTemp[];
SDrop drop;
String myString;
boolean pixSendAreReceived = true;
int pixStateArduino;
int stitchSetupArduino;
int currentSolenoidIDSetup;
int[] pixelSend;
int[] pixelReceived;
boolean shift;
//------------------------------------------------------------------------------------
public void setup() {
  size(1060, 700);
  //frameRate(35);
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
  currentPixels = new int[200];
  _16SolenoidsAr = new char[16]; 
  lastMessageReceivedFromSerial = millis();
  lastConnection = millis();
  setupAudio();

  bitRegister16SolenoidTemp = new int[16];
  bitRegister16SolenoidTemp[0] =  32768;   // 1000000000000000
  bitRegister16SolenoidTemp[1] =  16384;   // 0100000000000000
  bitRegister16SolenoidTemp[2] =  8192;    // 0010000000000000
  bitRegister16SolenoidTemp[3] =  4096;    // 0001000000000000
  bitRegister16SolenoidTemp[4] =  2048;    // 0000100000000000
  bitRegister16SolenoidTemp[5] =  1024;    // 0000010000000000
  bitRegister16SolenoidTemp[6] =  512;     // 0000001000000000
  bitRegister16SolenoidTemp[7] =  256;     // 0000000100000000
  bitRegister16SolenoidTemp[8] =  128;     // 0000000010000000
  bitRegister16SolenoidTemp[9] =  64;      // 0000000001000000
  bitRegister16SolenoidTemp[10] =  32;     // 0000000000100000
  bitRegister16SolenoidTemp[11] =  16;     // 0000000000010000
  bitRegister16SolenoidTemp[12] =  8;      // 0000000000001000
  bitRegister16SolenoidTemp[13] =  4;      // 0000000000000100
  bitRegister16SolenoidTemp[14] =  2;      // 0000000000000010
  bitRegister16SolenoidTemp[15] =  1;      // 0000000000000001

  drop = new SDrop(this);
  pixelSend = new int[200];
  pixelReceived = new int[200];
  for (int i=0; i<200; i++) {
    pixelSend[i] = 0;
    pixelReceived[i] = 0;
  }
}

//------------------------------------------------------------------------------------

public void draw() {
  frame.setTitle("Knitic pattern manager v.01 F:"+Integer.toString(round(frameRate)));
  background(200, 200, 200);
  autoConnectAndReceiveSerial();
  display();
  drawPatternGrid();
  if (loadPattern) { 
    drawPattern();
    drawAndSetSelectedGrid();
  }
  brain();
  showCursorPosition();
  updateEditPixels();
  // For debug
  drawReceivedPixelsVsSend();
}

//------------------------------------------------------------------------------------

public void brain() {
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
      if (isPatternFinishKnitting() && repedPatternMode==true) { 
        current_row=0;
      }
      else {
        setOFFSolenoids();
        done.trigger();
      }
      println("endLine left:"+Integer.toString(stitch));
      sendtoKnittingMachine();
    }
    if ( lastChangeHead != "right" &&  (stitch>=(224) || ((100+leftStick+offsetKeedles)<stitch && lastChangeHead != "right") ) ) { 
      headDirectionForNewPixels=-1;
      current_row += 1;
      lastChangeHead = "right";
      if (isPatternFinishKnitting() && repedPatternMode==true) { 
        current_row=0;
      }
      else {
        setOFFSolenoids();
        done.trigger();
      }
      println("endLine right:"+Integer.toString(stitch));
      sendtoKnittingMachine();
    }
  }
  lastEndLineStarted = endLineStarted;
  lastSection = section;
  //checkNotOnSolenoidsForLongTime();
  //sendSerial16();
}

//------------------------------------------------------------
public int getReadPixelsFromPosition(int posXPixel) {
  try {
    return pixelArray[199-posXPixel][(rows-1)-current_row];
  }
  catch(Exception e) {
    //println("ERROR in pixels to solenoids");
  }
  return 9;
}

//------------------------------------------------------------

public void setOFFSolenoids() {
  for (int i=0;i<16;i++) {
    _16SolenoidsAr[i] ='1';
  }
}

//------------------------------------------------------------

public boolean isPatternFinishKnitting() {
  return current_row>=rows;
}

//------------------------------------------------------------

public boolean isPatternOnKnitting() {
  return current_row>-1 && current_row<rows;
}

//------------------------------------------------------------

public void dropEvent(DropEvent theDropEvent) {
  if ( theDropEvent.isImage() && theDropEvent.isFile() ) {
    //theDropEvent.file()
    //theDropEvent.toString()
  }
}

//------------------------------------------------------------



Minim minim;
AudioSample ready;
AudioSample sent;
AudioSample done;
AudioSample reset;
AudioSample error;

public void setupAudio(){
  minim = new Minim(this);
  ready = minim.loadSample("ready.aif", 512);
  sent = minim.loadSample("sent.aif", 512);
  done = minim.loadSample("done.aif", 1024);
  reset = minim.loadSample("reset.aif", 1024);  
  error = minim.loadSample("error.aif", 512);
}
//------------------------------------------------------------------------------------

public void addButtonsInSetup() {
  controlP5 = new ControlP5(this);
  controlP5.addButton("Open", 4, 855, 45, 40, 30).setId(3);
  controlP5.addToggle("Repeating pattern mode", true, 855, 210, 20, 20).setId(4);
  //controlP5.addToggle("UDP live pattern mode", true, 855, 255, 20, 20).setId(8);
  controlP5.addButton("Go to row", 4, 855, 90, 80, 30).setId(5);
  controlP5.addButton("Move pattern", 4, 855, 130, 80, 30).setId(6);
  controlP5.addButton("Start edit image", 4, 855, 170, 80, 30).setId(7);
}

//------------------------------------------------------------------------------------

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id());
  if (theEvent.controller().id()==3) openknittingPattern();
  if (theEvent.controller().id()==4) repedPatternMode = !repedPatternMode;
  if (theEvent.controller().id()==5) jumpToRow();
  if (theEvent.controller().id()==6) howMuchPatternToLeft("");
  if (theEvent.controller().id()==7) changeEditPixels();
  if (theEvent.controller().id()==8) UDP_LivePatternMode();
}

//------------------------------------------------------------------------------------

public void jumpToRow() {
  String new_current_row = JOptionPane.showInputDialog(frame, "To whish row you want to jump ?", Integer.toString(current_row));
  if ( !Integer.toString(current_row).equals(new_current_row) ) {
    current_row = Integer.valueOf(new_current_row);
    sendtoKnittingMachine();
  }
}

//------------------------------------------------------------------------------------

public void UDP_LivePatternMode() {
}

//------------------------------------------------------------------------------------

public void changeEditPixels() {
  editPixels =! editPixels;
  if (editPixels) {
    cursor(CROSS);
    controlP5.controller("Start edit image").captionLabel().set("Stop edit image");
  } 
  else {
    controlP5.controller("Start edit image").captionLabel().set("Start edit image");
    cursor(ARROW);
  }
}

//------------------------------------------------------------------------------------

public void updateEditPixels() {
  if (editPixels) {
  } 
  else {
  }
}

//------------------------------------------------------------------------------------

public void openknittingPattern() {  
  selectInput("Select a file to process:", "fileSelected");  // Opens file chooser
}

//------------------------------------------------------------------------------------

public void fileSelected(File selection) {
  if (selection != null) {
    fillArrayWithImage(selection.getAbsolutePath());
  }
}

//------------------------------------------------------------------------------------

public void fillArrayWithImage(String imgPath) { 
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

      int restPixels = (200-cols);
      leftStick = (100-(restPixels/2));
      rightStick = 100-(restPixels/2);
      if ( (100-leftStick)+cols+(100-rightStick) !=200) {
        rightStick +=1;
      }

      if (cols!=200) {
        howMuchPatternToLeft("");
      }
      
      img.loadPixels(); 
      for (int y = 0; y <rows; y++) {
        for (int x = 0; x <  cols; x++) {
          int loc = (cols-1)-x + y*cols;
          if (brightness(img.pixels[loc]) > threshold) {
            pixelArray[x][y] = 0;
          }
          else {
            pixelArray[x][y] = 1;
          }
        }
      }
      status = "r";
      // send first line
      sendtoKnittingMachine();
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

public void howMuchPatternToLeft(String message) {
  try {
    String userStartStick="";
    if (message=="") {
      userStartStick = JOptionPane.showInputDialog(frame, "Do you want to start from left " +Integer.toString(leftStick)+"?", Integer.toString(leftStick));
    }
    else {
      userStartStick = JOptionPane.showInputDialog(frame, message, Integer.toString(cols-100));
    }
    if (!userStartStick.equals(Integer.toString(leftStick))) {
      if ((100-(Integer.valueOf(userStartStick)))+cols>200 ) {  
        howMuchPatternToLeft("Is not possible to put that right. The maxium is "+Integer.toString((cols-100)));
      }
      else {
        leftStick = Integer.valueOf(userStartStick);
        rightStick = (cols+(100-leftStick))-100;
      }
    }
    sendtoKnittingMachine();
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------

public void display() {  
  noStroke();
  fill(73, 202, 250);
  rect(0, 0, buttonWithBar, 80);
  fill(155, 155, 155);
  rect(width-buttonWithBar, 0, buttonWithBar, height);
  rect(0, 80, buttonWithBar, height);
  fill(100, 100, 100);
  rect(width-buttonWithBar, 0, buttonWithBar, 80);
  image(kniticLogo, 0, -10);
  draw16selenoids();
  fill(255);
  textFont(laurentFont); 
  stroke(255);
  noFill();
  rect(15, 90, 190, 35);
  rect(15, 140, 190, 35);
  rect(15, 190, 190, 35);
  rect(15, 240, 190, 35);
  rect(15, 290, 190, 35);
  rect(15, 340, 190, 35);
  rect(15, 390, 190, 35);
  rect(15, 440, 190, 35);

  fill(255); 
  // columne left
  if (usbConected) {    
    text("USB: connected", 20, 120);
  }
  else { 
    text("USB: disconnected", 20, 120);
  }
  if (current_row<0) { 
    text("Row:-", 20, 170);
  }
  else { 
    text("Row:"+Integer.toString(current_row), 20, 170);
  }
  if (stitch==-999) {
    text("Stitch: -", 20, 220);
  }
  else {
    text("Stitch: "+Integer.toString(stitch), 20, 220);
  }
  if (cols<0) {
    text("Width: -", 20, 320);
  }
  else {
    text("Width: "+Integer.toString(cols), 20, 320);
  } 
  if (rows<0) {
    text("Height: -", 20, 370);
  }
  else {
    text("Height: "+Integer.toString(rows), 20, 370);
  }
  if (leftStick<0) {
    text("Left Stich: -", 20, 420);
  }
  else {
    text("Left Stich: "+Integer.toString(leftStick), 20, 420);
  }
  if (rightStick<0) {
    text("Right Stich: -", 20, 470);
  }
  else {
    text("Right Stich: "+Integer.toString(rightStick), 20, 470);
  } 

  fill(255);
  if (headDirection==0) { 
    text("Direction: none", 20, 270);
  }
  else if (headDirection==1) { 
    text("Direction: left", 20, 270);
  }
  else if (headDirection==-1) { 
    text("Direction: right", 20, 270);
  }
  noStroke();
  // scroll bar
  fill(16, 62, 104);
  rect(buttonWithBar-9, 0, 9, height);
  rect(width-buttonWithBar, 0, 9, height);
  // show small lines for rail of visualization knitles 
  noStroke();
  fill(255);
  rect(buttonWithBar-9, 26*3+1, 9, 2);
  rect((width-buttonWithBar), 26*3+1, 9, 2);
  stroke(255);
  
  text(solenoidsFromArduino, 10, 500);
  text("state: "+pixStateArduino, 20, 550);
  text("stitch: "+stitchSetupArduino, 20, 600);
  text("solenoid: "+currentSolenoidIDSetup, 20, 650);
  
  if(!shift && headDirection==-1 || shift  && headDirection==1){
    text("shift-A", 20, 680);
  }else{
    text("shift-B", 20, 680);
  }
}

//------------------------------------------------------------------------------------

public void drawDebugVariables() {
  rect(15, 490, 190, 35);
  if (endLineStarted) { 
    text("Started", 20, 520);
  }
  else { 
    text("Not started", 20, 520);
  }

  stroke(255);
  noFill();
  rect(855, 140, 180, 35);
  fill(255);
  text("Status: "+status+"/"+statusMachine, 865, 170);

  int n = round(counterMessagesReceive/(millis()*0.001f)) ;
  text("M per Sec: "+Integer.toString(n), 30, 550);

  text("MouseX:"+Integer.toString(patternMouseX), 855, 510);
  text("MouseY:"+Integer.toString(patternMouseY), 855, 550); 
  text("Available buffer:"+Integer.toString(serialAvailableBuffer), 855, 600);

  if (repedPatternMode) {
    text("Repeat: true", 30, 500);
  }
  else {
    text("Repeat: false", 30, 500);
  } 
  text("Left pixel: "+Integer.toString(((100-leftStick)/8)), 30, 590);
  text("Right pixel: "+Integer.toString(((100+rightStick)/8)), 30, 630);
  text(Integer.toString( -((section-1)*8)+(cols)+(100-rightStick)-16 ), 30, 700);
  text("lastChangeHead:"+lastChangeHead, 30, 740);
  if (section==-999) {
    text("Section: -", 30, 170);
  }
  else {
    text("Section: "+Integer.toString(section), 30, 170);
  }
  text(_16Solenoids, 840, 310);
 
}

//------------------------------------------------------------------------------------

public void drawPattern() {
  pushMatrix();
  translate(buttonWithBar+((100-leftStick)*sizePixel)+(cols*sizePixel), ((27-rows)+current_row)*sizePixel);
  noSmooth();
  scale(-1, 1);
  image(img, 0, 0, img.width*sizePixel, img.height*sizePixel);
  smooth();
  // draw grid
  for (int x=0;x<cols+1;x++) {
    stroke(0);
    line(x*sizePixel, 0, x*sizePixel, rows*sizePixel);
  }
  for (int y=0;y<rows+1;y++) {
    stroke(0);
    line(0, y*sizePixel, cols*sizePixel, y*sizePixel);
  }
  popMatrix();
}

//------------------------------------------------------------------------------------

public void drawPatternThumbnail() {
  text("Thumbnail:", 855, 370);
  if (loadPattern) {
    noSmooth();
    int h = img.height/4;
    image(img, width-205, 400, img.width/4, h);
    smooth();
  }
}

//------------------------------------------------------------------------------------

public void drawPatternGrid() {
  try {
    stroke(7, 146, 253);
    for (int j=0;j<200;j++) {
      line(buttonWithBar+j*sizePixel, 0, buttonWithBar+j*sizePixel, height);
    }
    for (int g=0;g<267;g++) {
      line(buttonWithBar, g*sizePixel, width-231, g*sizePixel);
    } 
    noStroke();
    stroke(30, 30, 30);
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

public void drawAndSetSelectedGrid() {
  int stitchViz = stitch;
  int startStitch  = 24;
  int totalCub = 16;
  _16Solenoids = "";
  // LEFT visualization

  if (stitch<startStitch && headDirection==1) { 
    stitchViz = 0;
    if (stitch>8) {
      totalCub = (stitch-8);
    }
    else {
      totalCub =0;
    }
  }
  else if (headDirection==1) {
    stitchViz = stitch-startStitch;
    if (stitch>208) {
      totalCub = 16-(stitch-208);
    }
  }
  // RIGHT visualization
  if (stitch>176 && headDirection==-1) { 
    stitchViz = 200;
    if (stitch<192) {
      totalCub = 192-stitch;
      //println("First part :"+Integer.toString(totalCub));
    }
    else {
      totalCub =0;
    }
  }
  else if (headDirection==-1) {
    stitchViz = stitch+startStitch;
    //println("Second part");
    if (stitch<-8) {
      totalCub = 16+(stitch+8);
    }
  }
  for (int i=0;i<16;i++) {
    _16SolenoidsAr[i]='9';
  }
  // Draw 

  if (totalCub>0) {
    pushMatrix();
    translate(buttonWithBar+sizePixel*199, 0);
    int y = 26;          
    // Color direction
    int width16Solenoids = sizePixel*totalCub;
    int rightStickOffset = 100-rightStick;
    try {
      if (headDirection==1) {
        fill(255, 0, 0, 150);
        rect(-((stitchViz-1)*sizePixel)-width16Solenoids, y*sizePixel, width16Solenoids, sizePixel);
        for (int i=(stitchViz-1);i<(stitchViz+totalCub);i++) {
          int solenoidId = ((i)%16);
          int pixelId = getReadPixelsFromPosition(i+rightStickOffset);
          if (pixelId==0 && solenoidId<16 && solenoidId>=0 ) {
            _16SolenoidsAr[solenoidId] = '1';
          }
          else if (pixelId==1 && solenoidId<16 && solenoidId>=0) {
            _16SolenoidsAr[solenoidId] = '0';
          }
          else if (pixelId==9 && solenoidId<16 && solenoidId>=0 && stitchViz<(201) ) {
            _16SolenoidsAr[solenoidId] = '9';
          }
          else if (stitchViz>=201 ) {
            _16SolenoidsAr[solenoidId] = '0';
          }
        }
      }
      else {
        fill(0, 255, 0, 150);
        rect(-((stitchViz-1)*sizePixel), y*sizePixel, width16Solenoids, sizePixel);
        for (int i=(stitchViz-1);i>((stitchViz-1)-totalCub);i--) {
          int solenoidId = ((i)%16);
          int pixelId = getReadPixelsFromPosition(i+rightStickOffset);
          if (pixelId==0 && solenoidId<16 && solenoidId>=0) {
            _16SolenoidsAr[solenoidId] = '1';
          }
          else if (pixelId==1 && solenoidId<16 && solenoidId>=0) {
            _16SolenoidsAr[solenoidId] = '0';
          }
          else if (pixelId==9 && solenoidId<16 && solenoidId>=0 && stitchViz>-1) {
            _16SolenoidsAr[solenoidId] = '9';
          }
          else if (stitchViz<=-1 ) {
            _16SolenoidsAr[solenoidId] = '0';
          }
        }
      }
    }
    catch(Exception e) {
    }
    popMatrix();
  }
  // pass from array to string to send to arduino
  convertSolenoidsToBinary();
  // solenoids to string
  try {
    for (int i=0;i<16;i++) {
      if (totalCub>0) {
        _16Solenoids +=_16SolenoidsAr[i];
      }
      else {
        _16Solenoids +="0";
      }
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

public void draw16selenoids() {
  pushMatrix();
  translate(30, 65);
  fill(255);
  stroke(255);
  strokeWeight(1);
  rect(0, 0, 16*10, 10);
  noStroke();
  try {
    for (int i=0;i<16;i++) {
      // draw red active stich 
      if (  isCurrentStich_1(i) ) {
        fill(255, 0, 0);
        rect(2+((15*10)-(i*10))-1, 3-1, 8, 8);
      }
      // Define the colors depending if is "1", "0" or "9" (9 this means pin not defined yet )
      if ( _16Solenoids.substring(i, i+1).equals("1") ) {
        stroke(0);
        fill(255, 255, 255);
      }
      else if ( _16Solenoids.substring(i, i+1).equals("0") ) {
        stroke(0);
        fill(0, 0, 0);
      }
      else if ( _16Solenoids.substring(i, i+1).equals("9") ) {
        noStroke();
        stroke(73, 202, 250);
        fill(73, 202, 250);
      }
      rect(2+((15*10)-(i*10)), 3, 5, 5);
      noStroke();
    }
  }
  catch(Exception e) {
    _16Solenoids.length();
  }
  popMatrix();
}
//------------------------------------------------------------------------------------
// this method tell active stich
public boolean isCurrentStich(int i) {
  return (  (stitch<=176 && stitch>=-24 && headDirection==-1) && ((stitch+7+(i*headDirection))%16)==0 ) || ( (stitch>=24 && stitch<=224 &&  headDirection==1)  && ((stitch+8-(i*headDirection))%16)==0 );
}
//------------------------------------------------------------------------------------
// this method tell active stich
public boolean isCurrentStich_1(int i) {
  return (  (stitch<=176 && stitch>=-24 && headDirection==-1) && ((stitch+7+(i*headDirection))%16)==1 ) || ( (stitch>=24 && stitch<=224 &&  headDirection==1)  && ((stitch+8-(i*headDirection))%16)==1 );
}
//------------------------------------------------------------------------------------
public void drawReceivedPixelsVsSend() {
  try {
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
  }
  catch(Exception e) {
  }
}
//------------------------------------------------------------------------------------

public void showCursorPosition() {
  if ( mouseX>buttonWithBar && mouseX<(width-buttonWithBar) ) {
    patternMouseX = cols -(((mouseX-buttonWithBar)/sizePixel)-(100-leftStick))-1 ;
    patternMouseY = (mouseY/sizePixel)-(27-rows)+current_row+1;
  }
}

public void mouseReleased() {
  try {
    if (editPixels) {
      println(pixelArray[patternMouseX][patternMouseY]);
      if (pixelArray[patternMouseX][patternMouseY]==0 ) {
        pixelArray[patternMouseX][patternMouseY]=1;
      }
      else {
        pixelArray[patternMouseX][patternMouseY]=0;
      }
      // pass to image
      img.loadPixels();
      int loc = patternMouseX + patternMouseY*img.width;
      if (pixelArray[patternMouseX][patternMouseY]==0) {
        img.pixels[loc] = color(0, 0, 0);
      }
      else {
        img.pixels[loc] = color(255, 255, 255);
      }
      img.updatePixels();
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------
public void keyPressed() {
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
    section = ceil(PApplet.parseFloat(stitch)/8.0f);
  }
  if (key=='a' && endLineStarted) {
    stitch+=1;
    if (stitch>232) { 
      stitch=232;
    }
    else {
      headDirection =1;
    }
    section = ceil(PApplet.parseFloat(stitch)/8.0f);
  }
  if (key=='z') {
    stitch=176;
    headDirection =-1;
  }
  if (key=='x') {
    stitch=24;
    headDirection =1;
  }
  if (key=='m') {
    sendtoKnittingMachine();
  }
}
//------------------------------------------------------------------------------------
public void startRightSide() {
  current_row = 0;
  headDirectionForNewPixels=+1;
  endLineStarted = true;
  //lastEndLineStarted = false;
  lastChangeHead = "left";
}
//------------------------------------------------------------------------------------
public void startLeftSide() {
  current_row = 0;
  headDirectionForNewPixels=-1;
  endLineStarted = true;
  //lastEndLineStarted = false;
  lastChangeHead = "right";
}
//------------------------------------------------------------------------------------



int BAUD_RATE = 115200; //--57600
byte lf = 0x40;
byte footer = 126;

public void setupSerialConnection() {
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

public void autoConnectAndReceiveSerial() {
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

public void sendtoKnittingMachine() {
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

public void sendSerial16() {
  try {
    if ( (millis()-lastMessageSendFromSerial)>500  || !last16Solenoids.equals(_16Solenoids) ) {
      String _16SolenoidsNew = _16Solenoids.replace('9', '1');
      if (headDownSelenoid || isPatternFinishKnitting() ) {
        _16SolenoidsNew ="00000000000000";
        dataToSolenoidHex = 0;
      }
      // new method send data
      char c1 = PApplet.parseChar(dataToSolenoidHex >> 8);
      char c2 = PApplet.parseChar(dataToSolenoidHex & 0xFF);
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

public void receiveSerial() {
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

public int hexToInt(String hexValue) {
  return Integer.parseInt(hexValue.substring(2), 16);
}

//------------------------------------------------------------------------------------

public void convertSolenoidsToBinary() {
  int dataSector = 0;
  // IF IS NOT EQUAL TO 0 PLACE "1" IN EACH BYTE
  for (int i=0;i<16;i++) { 
    if (_16SolenoidsAr[i]!='0') dataSector = dataSector ^ bitRegister16SolenoidTemp[i];
  }
  dataToSolenoidHex  = dataSector;
} 

//------------------------------------------------------------------------------------

public void checkBetweenSendAndReceived() {
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

/*
void checkNotOnSolenoidsForLongTime() {
  // Check if the head did move
  if (stitch !=_lastStitch) {
    _lastStitch = stitch;
    lastSolenoidChange = millis();
  }
  // Check if the solenoids stay on for more than a minute
  if (millis()-lastSolenoidChange>60000 && _16Solenoids !="00000000000000" && isPatternOnKnitting() ) {
    headDownSelenoid = true;
    sendSerial16();
    try {
      JOptionPane.showMessageDialog(frame, "The carriage is left without finish line and can heat up solenoid. Accept and continue knitting.", "Alert from Knitic", 2);
      lastSolenoidChange = millis();
    }
    catch(Exception e) {
    }
  }
  else {
    headDownSelenoid = false;
  }
}
*/
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "protoAppKnitic_p5" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
