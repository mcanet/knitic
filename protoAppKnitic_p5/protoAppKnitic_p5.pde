/*
Prototipe Knitic
*/
import javax.swing.JOptionPane;
import controlP5.*;
import processing.serial.*;

String _16Selenoids = "1010101010101010";
// The serial port:
Serial myPort;  
String selected;
PImage kniticLogo;
PFont laurentFont;
int current_row = 200;
int stich = 200;
int section = 200;
boolean endLineStarted = false;
int leftStick = 100;
int rightStick = 100;
int headDirection = 0;
String direction = "-";
String status = "";
boolean loadPattern = false;

PImage img;
int cols = 0;
int rows = 0;
int[][] pixelArray; 
float threshold = 127;
String lastSerialData;

ControlP5 controlP5;
boolean usbConected = false;

scrollBar myScrollBar;

int lastConnection;
int lastMessageReceivedFromSerial;

void setup(){
  size(1060,800);
  // List all the available serial ports:
  println(Serial.list());
  setupSerialConnection();
  
  kniticLogo = loadImage("logo_knitic.png");
  laurentFont = loadFont("LaurenScript-20.vlw");
  addButtonsInSetup();
  if(frame != null) {
    frame.setTitle("Knitic pattern manager v.01");
    frame.setResizable(false);
  }
  frameRate(30);
  myScrollBar = new scrollBar();
  lastMessageReceivedFromSerial = millis();
  lastConnection = millis();
}

void draw(){
  frame.setTitle("Knitic pattern manager v.01 F:"+Float.toString(frameRate));
  background(200,200,200);
  sendAndReceiveSerial();
  display();
  drawPatternGrid();
  if(loadPattern) drawPattern();
  myScrollBar.mouseMoveScroll();
  
}

void keyPressed(){
  if(key=='n'){
    startknitting();
  }
  if(key=='s'){
    stopknitting();
  }
  if(key=='o'){
    openknittingPattern();
  }
}

void drawPattern(){
  pushMatrix();
  translate(230+((100-leftStick)*3),0);
  int cubSize = 3;
  for(int x=0;x<cols;x++){
     for(int y=0;y<rows;y++){
       if(pixelArray[x][y]==1){
         fill(255);
       }else{
         fill(0);
       }
       /*
       if(insertingPixelsPattern && rowtPixelPointer==y && columntPixelPointer==x ){
         fill(255,0,0);
       }
       */
       rect(x*cubSize, y*cubSize, cubSize,cubSize);
       
     }
   }
   popMatrix();
}

void fillArrayWithImage(String imgPath){ 
  img = loadImage(imgPath);
  cols = img.width;
  if(cols>200){
    JOptionPane.showMessageDialog(frame, "The image have more than 200 pixels","Alert from Knitic",2);
  }else{
    
    rows = img.height;
    if(cols>0 && rows>0) loadPattern = true;
    pixelArray = new int[cols][rows];
    myScrollBar.setupScrollBar();
    int restPixels = 200-cols;
    leftStick = 100-(restPixels/2);
    rightStick = 100-(restPixels/2);
    if( (100-leftStick)+cols+(100-rightStick) !=200){
      rightStick +=1;
    }
    
    String userStartStick="";
    if(cols!=200) {
      
      userStartStick = JOptionPane.showInputDialog(frame, "Do you want to start from left " +Integer.toString(leftStick)+"?",Integer.toString(leftStick));
      if(!userStartStick.equals(Integer.toString(leftStick))){
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
        }else{
          pixelArray[x][y] = 0;
        }
      }
    }
  }
}


void brain(){
  if( endLineStarted ){
    
  }
}

