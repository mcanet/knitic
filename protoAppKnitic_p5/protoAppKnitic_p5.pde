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
String status = "0";
int current_row = 200;
int stich = 200;
int section = 200;
int leftStick = 0;
int rightStick = 200;
String direction = "-";
String action = "";
boolean loadPattern = false;

PImage img;
int cols = 60;
int rows = 60;
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
  frameRate(25);
  myScrollBar = new scrollBar();
  lastMessageReceivedFromSerial = millis();
  lastConnection = millis();
}

void draw(){
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
  translate(230+(leftStick*3),0);
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
    leftStick = (restPixels/2);
    rightStick = (restPixels/2);
    if(leftStick+cols+rightStick !=200){
      rightStick +=1;
    }
    String userStartStick="";
    if(cols!=200) {
      userStartStick = JOptionPane.showInputDialog(frame, "Do you want to start from left " +Integer.toString(leftStick)+"?",Integer.toString(leftStick));
      if(userStartStick!=Integer.toString(leftStick)){
        leftStick = Integer.valueOf(userStartStick);
        rightStick = 200 - leftStick;
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




