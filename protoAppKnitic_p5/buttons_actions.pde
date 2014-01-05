//------------------------------------------------------------------------------------

void addButtonsInSetup() {
  controlP5 = new ControlP5(this);
  controlP5.addButton("Open", 4, 855, 45, 40, 30).setId(3);
  controlP5.addToggle("Repeating pattern mode", true, 855, 210, 20, 20).setId(4);
  //controlP5.addToggle("UDP live pattern mode", true, 855, 255, 20, 20).setId(8);
  controlP5.addButton("Go to row", 4, 855, 90, 80, 30).setId(5);
  controlP5.addButton("Move pattern", 4, 855, 130, 80, 30).setId(6);
  controlP5.addButton("Start edit image", 4, 855, 170, 80, 30).setId(7);
  usbList = controlP5.addDropdownList("usbList", 855, 300, 150, 300).setId(8);
  fillListUSB(usbList);
  machineList = controlP5.addDropdownList("machine", 855, 350, 150, 300).setId(9);
  fillListMachines(machineList);
  controlP5.addButton("Create parametric sweater", 4, 855, 400, 150, 30).setId(10);
} 

//------------------------------------------------------------------------------------

void fillListUSB(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ArrayList<String> usbListName = new ArrayList<String>();
  for (int i=0;i<Serial.list().length;i++) {
    if (Serial.list()[i].toLowerCase().lastIndexOf("bluetooth")==-1) {
      usbListName.add(Serial.list()[i]);
    }
  }
  if (usbListName.size()>0) {
    ddl.captionLabel().set("Select usb port");
  }
  else {
    ddl.captionLabel().set("No devices connected");
  }
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i=0;i<usbListName.size();i++) {
    ddl.addItem(usbListName.get(i), i);
  }
  ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

//------------------------------------------------------------------------------------

void fillListMachines(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ArrayList<String> usbListName = new ArrayList<String>();
  usbListName.add("Brother 930 / 940");
  usbListName.add("Openknit");
  //usbListName.add("Brother 910");
  //usbListName.add("Brother 950");

  ddl.captionLabel().set("Select kind machine");

  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i=0;i<usbListName.size();i++) {
    ddl.addItem(usbListName.get(i), i);
  }
  ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

//------------------------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id());
  if (theEvent.controller().id()==3) openknittingPattern();
  if (theEvent.controller().id()==4) repedPatternMode = !repedPatternMode;
  if (theEvent.controller().id()==5) jumpToRow();
  if (theEvent.controller().id()==6) howMuchPatternToLeft("");
  if (theEvent.controller().id()==7) changeEditPixels();
  if (theEvent.controller().id()==8) setupSerialConnection();
  if (theEvent.controller().id()==9) setupTypeMachine();
  if (theEvent.controller().id()==10) createParametricSweater();
}

//------------------------------------------------------------------------------------

void createParametricSweater() {
}

//------------------------------------------------------------------------------------

void setupTypeMachine() {
}

//------------------------------------------------------------------------------------

void jumpToRow() {
  String new_current_row = JOptionPane.showInputDialog(frame, "To whish row you want to jump ?", Integer.toString(current_row));
  if ( !Integer.toString(current_row).equals(new_current_row) ) {
    current_row = Integer.valueOf(new_current_row);
    sendtoKnittingMachine();
  }
}

//------------------------------------------------------------------------------------

void changeEditPixels() {
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

void updateEditPixels() {
  if (editPixels) {
  } 
  else {
  }
}

//------------------------------------------------------------------------------------

void openknittingPattern() {  
  selectInput("Select a file to process:", "fileSelected");  // Opens file chooser
}

//------------------------------------------------------------------------------------

void fileSelected(File selection) {
  try {
    if (selection != null) {
      fillArrayWithImage(selection.getAbsolutePath());
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

void fillArrayWithImage(String imgPath) {
  noLoop(); 
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
          if (brightness(img.pixels[loc]) > threshold && alpha(img.pixels[loc])==1) {
            pixelArray[x][y] = 0;
          }
          else if(alpha(img.pixels[loc])==1) {
            pixelArray[x][y] = 1;
          }else{
            pixelArray[x][y] = 2;
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
  loop();
}

//------------------------------------------------------------------------------------

void howMuchPatternToLeft(String message) {
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
