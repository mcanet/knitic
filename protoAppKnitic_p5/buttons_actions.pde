//------------------------------------------------------------------------------------

void addButtonsInSetup() {
  controlP5 = new ControlP5(this);
  controlP5.setFont(createFont("Quantico-Regular",12));
  controlP5.addButton("Open", 4, 855, 45, 70, 30).setId(3);
  controlP5.addToggle("Repeating pattern mode", true, 855, 210, 20, 20).setId(4);

  //controlP5.addToggle("UDP live pattern mode", true, 855, 255, 20, 20).setId(8);
  controlP5.addButton("Go to row", 4, 855, 90, 110, 30).setId(5);
  controlP5.addButton("Move pattern", 4, 855, 130, 130, 30).setId(6);
  controlP5.addButton("Start edit image", 4, 855, 170, 160, 30).setId(7);
  usbList = controlP5.addDropdownList("usbList", 855, 300, 200, 300).setId(8);
  fillListUSB(usbList);
  machineList = controlP5.addDropdownList("machine", 855, 350, 200, 300).setId(9);
  machineList.setHeight(50 );
  fillListMachines(machineList);
  machineList.update();
  knittingTypeList = controlP5.addDropdownList("knittingType", 855, 550, 200, 300).setId(16);
  fillListKnittingType(knittingTypeList);

  parametricSweaterButton = controlP5.addButton("Open parametric sweater", 4, 855, 400, 205, 30).setId(10);
  startOpenKnit = controlP5.addButton("Start knitting", 4, 855, 440, 120, 30).setId(14);
  startOpenKnit.setVisible(false); 
  setupGUIParametricSweater();
} 

//------------------------------------------------------------------------------------

void fillListUSB(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  ArrayList<String> usbListName = new ArrayList<String>();
  for (int i=0;i<Serial.list().length;i++) {
    //if (Serial.list()[i].toLowerCase().lastIndexOf("bluetooth")==-1 && Serial.list()[i].toLowerCase().lastIndexOf("tty")!=-1) {
      usbListName.add(Serial.list()[i]);
    //}
  }
  if (usbListName.size()==0) {
    ddl.setCaptionLabel("No devices connected");
  }
  else  if (usbListName.size()==1) {
    ddl.setCaptionLabel(usbListName.get(0));
  }
  else  if (usbListName.size()>1) {
    // try to found in list one usb selected
    Boolean usbSelected = false;
    for (int i=0;i<usbListName.size();i++) {
      if (usbListName.get(i).equals(getUSBSelected())) {
        ddl.setCaptionLabel(getUSBSelected());
        usbSelected = true;
      }
    }
    if (!usbSelected) ddl.setCaptionLabel("Select usb port");
  }
  ddl.getCaptionLabel().getStyle().setPadding(10, 30, 10, 30);  
  /*
  ddl.captionLabel().setHeight(30 );
   ddl.captionLabel().setLineHeight(30 );
   ddl.captionLabel().setFixedSize(false );
   ddl.captionLabel().setControlFontSize(10 );
   */
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.getCaptionLabel().getStyle().setMarginLeft(3);
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  for (int i=0;i<usbListName.size();i++) {
    ddl.addItem(usbListName.get(i), i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
}

//------------------------------------------------------------------------------------

void fillListMachines(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  ArrayList<String> machinesListName = new ArrayList<String>();
  machinesListName.add("Openknit");
  machinesListName.add("Brother 930 / 940");
  //usbListName.add("Brother 910");
  //usbListName.add("Brother 950");

  Boolean machineSelected = false;
  for (int i=0;i<machinesListName.size();i++) {
    if (machinesListName.get(i).equals(getMachineMode())) {
      ddl.setCaptionLabel(getMachineMode());
      machineSelected = true;
    }
  }

  if (!machineSelected) ddl.setCaptionLabel("Select kind machine");
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.getCaptionLabel().getStyle().setMarginLeft(3);
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  for (int i=0;i<machinesListName.size();i++) {
    ddl.addItem(machinesListName.get(i), i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

//------------------------------------------------------------------------------------

void fillListKnittingType(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  

  Boolean machineSelected = false;
  for (int i=0;i< my_brother.knittingTypeListName.size();i++) {
    if ( my_brother.knittingTypeListName.get(i).equals(getKnittingType())) {
      ddl.setCaptionLabel(getKnittingType());
      machineSelected = true;
    }
  }

  if (!machineSelected) ddl.setCaptionLabel("Select kind machine");
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  ddl.getCaptionLabel().getStyle().setMarginLeft(3);
  ddl.getCaptionLabel().getStyle().setMarginTop(3);
  for (int i=0;i< my_brother.knittingTypeListName.size();i++) {
    ddl.addItem( my_brother.knittingTypeListName.get(i), i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

//------------------------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getId()+" from "+theEvent.getGroup());
    if (theEvent.getGroup().getId()==8) { 
      saveUSBSelected();
      setupSerialConnection();
    }
    if (theEvent.getGroup().getId()==9) { 
      saveModelSelected();
      setupTypeMachine();
      showHideFeaturesOpenKnit();
    }
    if (theEvent.getGroup().getId()==16) { 
      saveKnittingType();
    }
  } 
  else if (theEvent.isController()) {
    println(theEvent.controller().getId());

    if (theEvent.controller().getId()==3) openknittingPattern();
    if (theEvent.controller().getId()==4) repedPatternMode = !repedPatternMode;
    if (theEvent.controller().getId()==5) jumpToRow();
    if (theEvent.controller().getId()==6) howMuchPatternToLeft("");
    if (theEvent.controller().getId()==7) changeEditPixels();
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

void setupTypeMachine() {
}

//------------------------------------------------------------------------------------

void jumpToRow() {
  String new_current_row = JOptionPane.showInputDialog(frame, "To whish row you want to jump ?", Integer.toString(current_row));
  if ( !Integer.toString(current_row).equals(new_current_row) ) {
    current_row = Integer.valueOf(new_current_row);
    sendtoKnittingMachine();
  }
  
  my_brother.jumpToRow();
}

//------------------------------------------------------------------------------------

void changeEditPixels() {
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
      fillArrayWithImagePath(selection.getAbsolutePath());
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

void fillArrayWithImagePath(String imgPath) {
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

void fillArrayWithImage(PImage imgTemp) {
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

//------------------------------------------------------------------------------------

//void (){}
