
/*
Prototipe Knitic
 */
//------------------------------------------------------------------------------------
// libraries
//------------------------------------------------------------------------------------
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.ImageIcon;
import controlP5.*;
import processing.serial.*;
import sojamo.drop.*;
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
boolean nowKnitting_openKnit;

m_brother my_brother;

//------------------------------------------------------------------------------------
void setup() {
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
  showHideFeaturesOpenKnit();
  nowKnitting_openKnit = false;
}

//------------------------------------------------------------------------------------

void draw() {
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

void serialEvent(Serial p) { 
  autoConnectAndReceiveSerial(p);
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
int getReadPixelsFromPosition(int posXPixel) {
  try {
    return pixelArray[199-posXPixel][(rows-1)-current_row];
  }
  catch(Exception e) {
    //println("ERROR in pixels to solenoids");
  }
  return 9;
}

//------------------------------------------------------------

void setOFFSolenoids() {
  for (int i=0;i<16;i++) {
    _16SolenoidsAr[i] ='1';
  }
}

//------------------------------------------------------------

boolean isPatternFinishKnitting() {
  return current_row>=rows;
}

//------------------------------------------------------------

boolean isPatternOnKnitting() {
  return current_row>-1 && current_row<rows;
}

//------------------------------------------------------------

void dropEvent(DropEvent theDropEvent) {
  if ( theDropEvent.isImage() && theDropEvent.isFile() ) {
    try {
      fillArrayWithImagePath(theDropEvent.toString());
    }
    catch(Exception e) {
    }
  }
}

//------------------------------------------------------------
