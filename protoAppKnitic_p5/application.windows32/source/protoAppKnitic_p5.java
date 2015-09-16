import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.JFileChooser; 
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
PFont laurentFont14;
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
int lastRowCorrect = -1;
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
int lastSerialPixelSend;
int laststitch = -1;
int posYOffSetPattern = 0;
int patternMouseX;
int patternMouseY;
int buttonWithBar = 230;
int offsetKeedles = 24;
boolean usbConected = false;
boolean loadPattern = false;
boolean repedPatternMode = true;
boolean editPixels = false;
boolean endLineStarted = false;
boolean lastEndLineStarted = false;
boolean waitingMessageFromKnitting=false;

int dataToSolenoidHex;
int bitRegister16SolenoidTemp[];
//SDrop drop;
String myString;
boolean pixSendAreReceived = true;
int pixStateArduino;
int stitchSetupArduino;
int currentSolenoidIDSetup;
int[] pixelSend;
int[] pixelReceived;
boolean shift;
ScrollableList usbList;
ArrayList<String> machinesListName = new ArrayList<String>();
ScrollableList machineList;
ScrollableList knittingTypeList;
int knittingType = 0;
JSONObject json;
parametricSweater ns;
controlP5.Textfield alt;
controlP5.Textfield ample;
controlP5.Textfield maniga;
controlP5.Textfield llargM;
controlP5.Textfield collAmple;
PFont font;
Boolean createSweater;

controlP5.Button parametricSweaterButton;
controlP5.Button saveParametricSweaterButton;
controlP5.Button applyParametricSweaterButton;
controlP5.Button loadParametricSweaterButton; 
controlP5.Button startOpenKnit;
//controlP5.Button refreshUsb;

boolean nowKnitting_openKnit;

m_brother my_brother;

//------------------------------------------------------------------------------------
public void setup() {
  size(1060, 700, P2D);
  noSmooth();
  if (frame != null) {
    frame.setTitle("Knitic pattern manager v.01");
    frame.setResizable(false);
    ImageIcon titlebaricon = new ImageIcon(loadBytes("knitic_icon.gif"));
    frame.setIconImage(titlebaricon.getImage());
  }
  // load fonts
  laurentFont = loadFont("Quantico-Regular-20.vlw");
  laurentFont14 = loadFont("Quantico-Regular-14.vlw");

  my_brother = new m_brother();
  setupSweater();
  // List all the available serial ports:
  setupSettings();
  addButtonsInSetup();
  //setupSerialConnection("0");
  kniticLogo = loadImage("logo_knitic.png");
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

  //drop = new SDrop(this);
  pixelSend = new int[200];
  pixelReceived = new int[200];
  for (int i=0; i<200; i++) {
    pixelSend[i] = 0;
    pixelReceived[i] = 0;
  }
  createSweater = false;
  //showHideFeaturesOpenKnit();
  nowKnitting_openKnit = false;
}

//------------------------------------------------------------------------------------

public void draw() {
  frame.setTitle("Knitic pattern manager v.01 F:"+Integer.toString(round(frameRate)));
  background(200, 200, 200);
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

  if ( machineList.getCaptionLabel().getText().equals("Openknit") && nowKnitting_openKnit) drawOpenKnit();

  if (createSweater) {
    drawSweater();
  }
}

//------------------------------------------------------------------------------------

public void serialEvent(Serial p) { 
  autoConnectAndReceiveSerial(p);
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
      if (my_brother.getIDKnittingTypeSelected()==0) {
        current_row += 1;
      }
      if (my_brother.getIDKnittingTypeSelected()==1) {
        my_brother.nextPassDoubleBed();
        if (my_brother.getPassDoubleBed()==0 || my_brother.getPassDoubleBed()==2) { 
          current_row += 1;
          println("add row double bed");
        }
      }
      if (my_brother.getIDKnittingTypeSelected()==2) {
      }
      lastChangeHead = "left";
      if (isPatternFinishKnitting() && repedPatternMode==true) { 
        current_row=0;
      }
      else {
        setOFFSolenoids();
        done.trigger();
      }
      println("endLine left:"+Integer.toString(stitch));
      //if (lastRowCorrect!=current_row && loadPattern) {
      sendtoKnittingMachine();
      //lastRowCorrect = current_row;
      //}
    }
    if ( lastChangeHead != "right" &&  (stitch>=(224) || ((100+leftStick+offsetKeedles)<stitch && lastChangeHead != "right") ) ) { 
      headDirectionForNewPixels=-1;
      if (my_brother.getIDKnittingTypeSelected()==0) {
        current_row += 1;
      }
      if (my_brother.getIDKnittingTypeSelected()==1) {
        my_brother.nextPassDoubleBed();
        if (my_brother.getPassDoubleBed()==0 || my_brother.getPassDoubleBed()==2) { 
          current_row += 1;
          println("add row double bed");
        }
      }
      if (my_brother.getIDKnittingTypeSelected()==2) {
      }
      lastChangeHead = "right";
      if (isPatternFinishKnitting() && repedPatternMode==true) { 
        current_row=0;
      }
      else {
        setOFFSolenoids();
        done.trigger();
      }
      println("endLine right:"+Integer.toString(stitch));
      //if (lastRowCorrect!=current_row && loadPattern) {
      sendtoKnittingMachine();
      //lastRowCorrect = current_row;
      //}
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
    try {
      fillArrayWithImagePath(theDropEvent.toString());
    }
    catch(Exception e) {
    }
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
  controlP5.setFont(createFont("Quantico-Regular",12));
  controlP5.addButton("Open", 4, 855, 45, 70, 30).setId(3);
  controlP5.addToggle("Repeating pattern mode", true, 855, 210, 20, 20).setId(4);

  //controlP5.addToggle("UDP live pattern mode", true, 855, 255, 20, 20).setId(8);
  controlP5.addButton("Go to row", 4, 855, 90, 110, 30).setId(5);
  controlP5.addButton("Move pattern", 4, 855, 130, 130, 30).setId(6);
  controlP5.addButton("Start edit image", 4, 855, 170, 160, 30).setId(7);
  
  parametricSweaterButton = controlP5.addButton("Open parametric sweater", 4, 855, 460, 205, 30).setId(10);
  startOpenKnit = controlP5.addButton("Start knitting", 4, 855, 500, 120, 30).setId(14);
  startOpenKnit.setVisible(false); 
  setupGUIParametricSweater();
  
  controlP5.addButton("Refresh", 4, 855, 270, 90, 25).setId(17);
  usbList = controlP5.addScrollableList("usbList", 855, 300, 200, 300).setId(8);
  fillListUSB(usbList);
  machineList = controlP5.addScrollableList("machine", 855, 380, 200, 300).setId(9);
  fillListMachines(machineList);
  machineList.update();
  knittingTypeList = controlP5.addScrollableList("knittingType", 855, 550, 200, 300).setId(16);
  fillListKnittingType(knittingTypeList);
} 

//------------------------------------------------------------------------------------

public void fillListUSB(ScrollableList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  ddl.clear();
  
  if (Serial.list().length==0) {
    ddl.setCaptionLabel("No devices connected");
  }
  else if (Serial.list().length==1) {
    ddl.addItem(Serial.list()[0], 0);
    ddl.setValue(0);
  }
  else if (Serial.list().length>1) {
    for (int i=0;i<Serial.list().length;i++) {
      ddl.addItem(Serial.list()[i], i);
    }
    // try to found in list one usb selected
    Boolean usbSelected = false;
    for (int i=0;i<Serial.list().length;i++) {      ///////////// to preselect usb uncomment that block
      if (Serial.list()[i].equals(getUSBSelected())) {
        ddl.setValue(i);
        usbSelected = true;
      }
    }
    if (!usbSelected) ddl.setCaptionLabel("Select usb port");
  }
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.getCaptionLabel().getStyle().setMarginLeft(3);
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  
  ddl.close();
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
}

//------------------------------------------------------------------------------------

public void fillListMachines(ScrollableList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  machinesListName.add("Brother 930 / 940");
  machinesListName.add("Openknit");
  //usbListName.add("Brother 910");
  //usbListName.add("Brother 950");
  for (int i=0;i<machinesListName.size();i++) {
    ddl.addItem(machinesListName.get(i), i);
  }
  
  Boolean machineSelected = false;
  for (int i=0;i<machinesListName.size();i++) {        ///////////// to preselect machine uncomment that block
    if (machinesListName.get(i).equals(getMachineMode())) {
      ddl.setValue(i);
      machineSelected = true;
    }
  }
  if (!machineSelected) ddl.setCaptionLabel("Select Machine");
  
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.getCaptionLabel().getStyle().setMarginLeft(3);
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.close();
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
}

//------------------------------------------------------------------------------------

public void fillListKnittingType(ScrollableList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);

  for (int i=0;i< my_brother.knittingTypeListName.size();i++) {
    ddl.addItem( my_brother.knittingTypeListName.get(i), i);
  }
  
  Boolean knittingTypeSelected = false;
  for (int i=0;i< my_brother.knittingTypeListName.size();i++) {
    if ( my_brother.knittingTypeListName.get(i).equals(getKnittingType())) {
      ddl.setValue(i);
      knittingTypeSelected = true;
    }
  }

  if (!knittingTypeSelected) ddl.setCaptionLabel("Select kind machine");
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.getCaptionLabel().getStyle().setMarginLeft(3);
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.close();
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
}

//------------------------------------------------------------------------------------
public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getId()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println(theEvent.controller().getId());

    if (theEvent.controller().getId()==3) openknittingPattern();
    if (theEvent.controller().getId()==4) repedPatternMode = !repedPatternMode;
    if (theEvent.controller().getId()==5) jumpToRow();
    if (theEvent.controller().getId()==6) howMuchPatternToLeft("");
    if (theEvent.controller().getId()==7) changeEditPixels();
    if (theEvent.controller().getId()==8) { 
      String devicePath = Serial.list()[(int)theEvent.getValue()];
      saveUSBSelected(devicePath);
      setupSerialConnection(devicePath);
    }
    if (theEvent.controller().getId()==9) { 
      String machineType=machinesListName.get((int)theEvent.getValue());
      saveModelSelected(machineType);
      setupTypeMachine(machineType);
      showHideFeaturesOpenKnit(machineType);
    }
    if (theEvent.controller().getId()==10) { 
      createParametricSweater();
    }
    if (theEvent.controller().getId()==11)saveImagePattern();
    if (theEvent.controller().getId()==12)applyParametricSweater();
    if (theEvent.controller().getId()==13)saveSweaterAsInputImage();
    if (theEvent.controller().getId()==14) {
      if (nowKnitting_openKnit) { 
        startOpenKnit.setLabel("Start knitting");
        stitch = 0;
        current_row = 0;
        status="r";
        endLineStarted = true;
        lastChangeHead = "left";
      }
      else {
        startOpenKnit.setLabel("Pause");
      }
      nowKnitting_openKnit =!nowKnitting_openKnit;
    }
    if (theEvent.controller().getId()==16) { 
      saveKnittingType((String)my_brother.knittingTypeListName.get((int)theEvent.getValue()));
    }
    if (theEvent.controller().getId()==17) fillListUSB(usbList);
  }

  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );
    //ns.generateSweater();
  }
}

//------------------------------------------------------------------------------------

public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}

//------------------------------------------------------------------------------------

public void setupTypeMachine(String machineType) {
}

//------------------------------------------------------------------------------------

public void jumpToRow() {
  String new_current_row = JOptionPane.showInputDialog(frame, "To whish row you want to jump ?", Integer.toString(current_row));
  if ( !Integer.toString(current_row).equals(new_current_row) ) {
    current_row = Integer.valueOf(new_current_row);
    sendtoKnittingMachine();
  }
  
  my_brother.jumpToRow();
}

//------------------------------------------------------------------------------------

public void changeEditPixels() {
  editPixels =! editPixels;
  if (editPixels) {
    cursor(CROSS);
    controlP5.getController("Start edit image").setCaptionLabel("Stop edit image");
  } 
  else {
    controlP5.getController("Start edit image").setCaptionLabel("Start edit image");
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
  try {
    if (selection != null) {
      fillArrayWithImagePath(selection.getAbsolutePath());
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

public void fillArrayWithImagePath(String imgPath) {
  noLoop(); 
  try {
    PImage imgTemp = loadImage(imgPath);
    fillArrayWithImage(imgTemp);
  }
  catch(Exception e) {
  }
  loop();
}

//------------------------------------------------------------------------------------

public void fillArrayWithImage(PImage imgTemp) {
  noLoop(); 
  try {
    img = imgTemp;
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
          if (brightness(img.pixels[loc]) > threshold ) { //&& alpha(img.pixels[loc])==1
            pixelArray[x][y] = 0;
          }
          else {//if (alpha(img.pixels[loc])==1)
            pixelArray[x][y] = 1;
          }
          /*
          else {
           pixelArray[x][y] = 2;
           }
           */
        }
      }
      status = "r";
      // send first line
      sendtoKnittingMachine();
      my_brother.resetPassDoubleBed();
    }
  }
  catch(Exception e) {
    println("error filling array");
  }
  loop();
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

//void (){}
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
  /*
  debugVariables();
   */
}

//------------------------------------------------------------------------------------
public void debugVariables() {
  text(solenoidsFromArduino, 10, 500);
  text("state: "+pixStateArduino, 20, 550);
  text("stitch: "+stitchSetupArduino, 20, 600);
  text("solenoid: "+currentSolenoidIDSetup, 20, 650);

  if (shift==false) { // equal 1
    text("shift-B", 20, 680);
  }
  else {// equal 0
    text("shift-A", 20, 680);
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
  //
  //smooth(2);
  scale(-1, 1);
  fill(250, 250, 250, 50);
  rect( 0, 0, img.width*sizePixel, img.height*sizePixel);
  fill(250, 250, 250, 250);
  image(img, 0, 0, img.width*sizePixel, img.height*sizePixel);

  noSmooth();
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
    int h = img.height/4;
    image(img, width-205, 400, img.width/4, h);
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
      else if (pixelSend[i]==1) {
        fill(255, 255, 255);
      }
      else {
        fill(73, 202, 250);
      }
      rect(i*5, height-5, 5, 5);
    }
    for (int i=0;i<200;i++) {
      if (pixelReceived[i]==0) {
        fill(255, 0, 255);
      }
      else if (pixelSend[i]==1) {
        fill(255, 255, 255);
      }
      else {
        fill(73, 202, 250);
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
class m_brother{
ArrayList<String> knittingTypeListName;
int passDoubleBed;
m_brother(){
  setupKnittingType();
  passDoubleBed = 0;
}

 
public void setupKnittingType(){
  knittingTypeListName = new ArrayList<String>();
  knittingTypeListName.add("Single bed");
  knittingTypeListName.add("Double bed - 2 colors");
  knittingTypeListName.add("Double bed - 3 colors");
}

public int getIDKnittingTypeSelected(){
  int out = 0;
  for(int i=0;i<knittingTypeListName.size();i++){
    if(knittingTypeListName.get(i).equals(knittingTypeList.getCaptionLabel().getText())){
      out = i;
    }
  }
  return out;
}

public void resetPassDoubleBed(){
  passDoubleBed = 0;
}

public void nextPassDoubleBed(){
  passDoubleBed+=1;
  if(passDoubleBed==4) passDoubleBed=0;
}

public int getPassDoubleBed(){
  return passDoubleBed;
}

public void jumpToRow(){
  resetPassDoubleBed();
}

}

int lastTimeMove_openKnit;
int direction_openKnit=1;

public void drawOpenKnit(){
  if(millis()-lastTimeMove_openKnit>100){
    stitch += direction_openKnit;
    if(stitch>200){
      direction_openKnit = direction_openKnit*-1;
    }
    if(stitch<0){
      direction_openKnit = direction_openKnit*-1;
    }
    lastTimeMove_openKnit = millis();
  }
}

class parametricSweater {
  PShape s;
  float factor = 1;
  float factorX = 0.8f;
  float factorY = 1;
  float alt =  160;//160
  float ample = 80;//80
  float maniga = 25;//25
  float llargM = 190 ;//190
  float collAmple = 39;
  float collAlt = 70; // no la faig servir
  float sisa = 0;
  float sisaMarge =0; 

  int dif = 10;
  PImage img;
  float widthSweater;
  float heightSweater;

  public parametricSweater() {
  }

  public void generateSweater() {
    S();
  }

  public void jersei(float alt, float ample, float maniga, float collAmple, float collAlt, float llargM, float sisa) {
    float agulla = 5;
    float halfAmple = ample*0.5f;
    sisa = collAlt*0.5f;
    sisaMarge = sisa*0.5f;
    fill(255);
    noStroke();
    s = createShape();
    s.beginShape(); 
    s.vertex((collAmple*0.5f)*factorX, 0);
    s.vertex((halfAmple+agulla+maniga)*factorX, (sisa-sisaMarge)*factorY);
    s.vertex((halfAmple+agulla+maniga)*factorX, llargM*factorY);
    s.vertex((halfAmple+agulla)*factorX, llargM*factorY); 
    s.vertex((halfAmple+agulla)*factorX, sisa*factorY);
    s.vertex(halfAmple*factorX, sisa*factorY);
    s.vertex(halfAmple*factorX, alt*factorY);
    s.vertex(-halfAmple*factorX, alt*factorY);
    s.vertex(-halfAmple*factorX, sisa*factorY);
    s.vertex((-halfAmple-agulla)*factorX, sisa*factorY);
    s.vertex((-halfAmple-agulla)*factorX, llargM*factorY);
    s.vertex((-halfAmple-agulla-maniga)*factorX, llargM*factorY);
    s.vertex((-halfAmple-agulla-maniga)*factorX, (sisa-sisaMarge)*factorY);
    s.vertex((-collAmple*0.5f)*factorX, 0);
    s.endShape(CLOSE);

    widthSweater = (ample+(maniga*2));
    if ((alt) >(llargM)) {
      heightSweater = alt;
    }
    else {
      heightSweater = llargM;
    }
    // save image
    createPixelPattern();
  }

  public void L() {
    jersei(alt, ample, maniga, collAmple, collAlt, llargM, sisa);
  }

  public void ML() {
    jersei(alt-dif, ample-dif, maniga-dif, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
  }

  public void M() {
    dif= dif*2;
    jersei(alt-dif, ample-dif, maniga-dif/2, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
    dif = 10;
  }

  public void SM() {
    dif= dif*3;
    jersei(alt-dif, ample-dif, maniga-dif/2, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
    dif = 10;
  }

  public void S() {
    dif= dif*4;
    jersei(alt-dif, ample-dif, maniga-dif/2, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
    dif = 10;
  }

  public void createPixelPattern() {
    PGraphics buffer = createGraphics(PApplet.parseInt(widthSweater), PApplet.parseInt(heightSweater), JAVA2D);
    img = new PImage(PApplet.parseInt(widthSweater), PApplet.parseInt(heightSweater));
    buffer.shape(s, (widthSweater/2), 0);
    img = buffer.get(0, 0, buffer.width, buffer.height);
    img.updatePixels();
  }
}

//------------------------------------------------------------------------------------
public void setupGUIParametricSweater() {
  //Height body
  alt = controlP5.addTextfield("Height body").setLabel("")
    .setValue("160" )
      .setPosition(300, 400)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(20);
  ;
  alt.setVisible(false);
  //Width body
  ample = controlP5.addTextfield("Width body").setLabel("")
    .setValue("80" )
      .setPosition(600, 400)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(21);
  ;
  ample.setVisible(false);
  //Width sleeve
  maniga = controlP5.addTextfield("Width sleeve").setLabel("")
    .setValue("25" )
      .setPosition(300, 480)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(22);
  ;
  maniga.setVisible(false);
  //Height sleeve
  llargM = controlP5.addTextfield("Height sleeve").setLabel("")
    .setValue("190" )
      .setPosition(600, 480)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(23)
                ;
  ;
  llargM.setVisible(false);

  collAmple = controlP5.addTextfield("Width neck").setLabel("")
    .setValue("39" )
      .setPosition(300, 560)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(24);
  ;

  collAmple.setVisible(false);
  saveParametricSweaterButton = controlP5.addButton("Save as image pattern", 4, 600, 640, 200, 30).setId(11);
  saveParametricSweaterButton.setVisible(false);
  applyParametricSweaterButton = controlP5.addButton("Apply changes", 4, 600, 560, 200, 30).setId(12);
  applyParametricSweaterButton.setVisible(false);
  loadParametricSweaterButton = controlP5.addButton("Load as pattern to knit", 4, 600, 600, 200, 30).setId(13);
  loadParametricSweaterButton.setVisible(false);
  
}
//------------------------------------------------------------------------------------
public void applyParametricSweater() {
  ns.alt = Integer.parseInt(alt.getText());
  ns.ample = Integer.parseInt(ample.getText());
  ns.maniga = Integer.parseInt(maniga.getText());
  ns.llargM = Integer.parseInt(llargM.getText());
  ns.collAmple = Integer.parseInt(collAmple.getText());
  ns.generateSweater();
}
//------------------------------------------------------------------------------------

public void createParametricSweater() {
  if (!createSweater) {
    ample.setVisible(true);
    alt.setVisible(true);
    maniga.setVisible(true);
    llargM.setVisible(true);
    collAmple.setVisible(true);
    createSweater = true;
    parametricSweaterButton.setLabel("Close parametric sweater");
    saveParametricSweaterButton.setVisible(true);
    applyParametricSweaterButton.setVisible(true);
    loadParametricSweaterButton.setVisible(true);
  }
  else {
    ample.setVisible(false);
    alt.setVisible(false);
    maniga.setVisible(false);
    llargM.setVisible(false);
    collAmple.setVisible(false);
    createSweater = false;
    parametricSweaterButton.setLabel("Open parametric sweater");
    saveParametricSweaterButton.setVisible(false);
    applyParametricSweaterButton.setVisible(false);
    loadParametricSweaterButton.setVisible(false); 
  }
}
//------------------------------------------------------------------------------------

public void setupSweater() {
  ns = new parametricSweater();
  ns.generateSweater();
}

//------------------------------------------------------------------------------------

public void drawSweater() {
  fill(73, 202, 250);
  rect(230, 0, 600, height);
  fill(255);
  //text("Set values for create a parametric sweater", 300, 380);
  pushMatrix();
  translate(530, 20);
  shape(ns.s, 0, 0);
  noFill();
  //stroke(255, 0, 0);
  rect((-ns.widthSweater/2), 0, ns.widthSweater-1, ns.heightSweater);
  image(ns.img, -ns.widthSweater/2, 0);
  //fill(0);
  //line(-300, 0, 300, 0);
  //line(0, 0, 0, 400);
  popMatrix();
  
  text("Height body:", 300, 390);
  text("Width body:", 600, 390);
  text("Width sleeve:", 300, 470);
  text("Height sleeve:", 600, 470);
  text("Width neck:", 300, 550);
}
//------------------------------------------------------------------------------------

public void saveSweaterAsInputImage() {
  fillArrayWithImage(ns.img);
  println(ns.img.height);
}
//------------------------------------------------------------------------------------

class MyFilter extends javax.swing.filechooser.FileFilter {
  public boolean accept(File file) {
    String filename = file.getName();
    return filename.endsWith(".png");
  }

  public String getDescription() {
    return "*.png";
  }
}

//------------------------------------------------------------------------------------

public void saveImagePattern() {
  JFileChooser fileChooser = new JFileChooser();
  fileChooser.setDialogTitle("Save As");
  fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
  int userSelection = fileChooser.showSaveDialog(this);

  MyFilter wordExtDesc = new MyFilter();
  fileChooser.setAcceptAllFileFilterUsed(false);
  fileChooser.setMultiSelectionEnabled(false);
  //fileChooser.setFileFilter(new FileNameExtensionFilter(wordExtDesc, ".png"));

  if (userSelection == JFileChooser.APPROVE_OPTION) {
    File fileToSave = fileChooser.getSelectedFile();
    System.out.println("Save as file: " + fileToSave.getAbsolutePath());
    ns.img.save(fileToSave.getAbsolutePath());
  }
}

//------------------------------------------------------------------------------------

public void showHideFeaturesOpenKnit(String machineType) {
  println(machineType);
  if (machineType.equals("Openknit") == true) {
    startOpenKnit.setVisible(true); 
  }
  else {
    startOpenKnit.setVisible(false); 
  }
}

//------------------------------------------------------------------------------------
class scrollBar {
  int posYDragScroll;
  int posYscrollBar;
  int heightYScrollBar;
  boolean notDragScroll;

  scrollBar() {
    posYscrollBar = 0;
    heightYScrollBar = 0;
    posYDragScroll = 0;
  }

  public void setupScrollBar() {
    posYscrollBar = 0;
    heightYScrollBar = height*((rows*3)/height);
    notDragScroll = false;
  }

  public void mouseMoveScroll() {
    if (mouseX > (width-buttonWithBar) && mouseX < ((width-buttonWithBar)+15) && mouseY> posYscrollBar && mouseY<(posYscrollBar+heightYScrollBar) && mousePressed && notDragScroll ) {
      notDragScroll = false;
      posYDragScroll = posYscrollBar-mouseY;
    }
    if (notDragScroll && mousePressed) {
      posYscrollBar = mouseY + posYDragScroll;
    }
    else {
      notDragScroll = false;
    }
  }
}




int BAUD_RATE = 115200;
byte lf = 0x40;
byte footer = 126;

//------------------------------------------------------------------------------------

public void setupSerialConnection(String devicePath) {
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

public void autoConnectAndReceiveSerial(Serial p) {
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

public void sendtoKnittingMachine() {
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
          int pixelId = pixelArray[posXPixel][posYPixel];
          if (pixelId==1) {
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
public void receiveSerial(Serial p) {
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
public void receiveMessageTypeA(String myString) {
  String[] args = myString.split(",");
  if (args.length>=2) {
    stitch = Integer.valueOf(args[1]);
    headDirection = Integer.valueOf(args[2]);
    //endLineStarted = !args[3].equals("0");
    endLineStarted = true;
    shift = !args[3].equals("0");
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
//------------------------------------------------------------------------------------
//
public void receiveMessageTypeB(String myString) {
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

public void setupSettings() {
  json = loadJSONObject("data/settings.json");
}

public void saveUSBSelected(String devicePath) {
  println("save:"+devicePath);
  json.setString("usbDevice", devicePath);
  saveJSONObject(json, "data/settings.json");
}

public void saveModelSelected(String machineType) {
  println("save:"+machineType);
  json.setString("kniticModel", machineType);
  saveJSONObject(json, "data/settings.json");
}

public void saveKnittingType(String knittingType) {
  println("save:"+knittingType);
  json.setString("knittingType", knittingType);
  saveJSONObject(json, "data/settings.json");
}

public String getKnittingType(){
  return json.getString("knittingType");
}

public String getUSBSelected() {
  return json.getString("usbDevice");
}

public String getMachineMode() {
  return json.getString("kniticModel");
}
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
