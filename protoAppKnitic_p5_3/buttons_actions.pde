//------------------------------------------------------------------------------------

void addButtonsInSetup() {
  controlP5 = new ControlP5(this);
  controlP5.setFont(createFont("Quantico-Regular",12));
  // debug things
  controlP5.enableShortcuts();
  myTextarea = controlP5.addTextarea("txt")
                  .setPosition(230, 400)
                  .setSize(600, 290)
                  .setFont(createFont("", 10))
                  .setLineHeight(14)
                  .setColor(color(200))
                  .setColorBackground(color(50, 55, 100))
                  .setColorForeground(color(255));
  ;
  myTextarea.setVisible(false);
  console = controlP5.addConsole(myTextarea);//
  debugButton = controlP5.addButton("Debug", 4)
  .setPosition(40, 600)
  .setSize(100, 30)
  .setId(19);
  
  controlP5.addButton("Open", 4)
  .setPosition(855, 45)
  .setSize(70, 30)
  .setId(3);
  
  controlP5.addToggle("Repeating pattern mode", true)
  .setPosition(855, 210)
  .setSize(20, 20)
  .setId(4);

  //controlP5.addToggle("UDP live pattern mode", true, 855, 255, 20, 20).setId(8);
  controlP5.addButton("Go to row", 4)
  .setPosition(855, 90)
  .setSize(110, 30)
  .setId(5);
  controlP5.addButton("Move pattern", 4)
  .setPosition(855, 130)
  .setSize(130, 30)
  .setId(6);
  controlP5.addButton("Start edit image", 4)
  .setPosition(855, 170)
  .setSize(160, 30)
  .setId(7);
  
  parametricSweaterButton = controlP5.addButton("Open parametric sweater", 4)
  .setPosition(855, 460)
  .setSize(205, 30)
  .setId(10);
  startOpenKnit = controlP5.addButton("Start knitting", 4)
  .setPosition(855, 500)
  .setSize(120, 30)
  .setId(14);
  startOpenKnit.setVisible(false); 
  setupGUIParametricSweater();
  
  controlP5.addButton("Refresh", 4)
  .setPosition(855, 270)
  .setSize(80, 25)
  .setId(17);
  controlP5.addButton("Close", 4)
  .setPosition(955, 270)
  .setSize(80, 25)
  .setId(18);
  usbList = controlP5.addScrollableList("usbList", 855, 300, 200, 300).setId(8);
  fillListUSB(usbList);
  machineList = controlP5.addScrollableList("machine", 855, 380, 200, 300).setId(9);
  fillListMachines(machineList);
  machineList.update();
  knittingTypeList = controlP5.addScrollableList("knittingType", 855, 550, 200, 300).setId(16);
  fillListKnittingType(knittingTypeList);
  // last id : 19
} 

//------------------------------------------------------------------------------------

void fillListUSB(ScrollableList ddl) {
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
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
  ddl.close();
}

//------------------------------------------------------------------------------------

void fillListMachines(ScrollableList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  ddl.clear();
  
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
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
  ddl.close();
}

//------------------------------------------------------------------------------------

void fillListKnittingType(ScrollableList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(30);
  ddl.clear();
  
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
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setHeight(400 );
  ddl.close();
}

//------------------------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getId()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println(theEvent.getController().getId());

    if (theEvent.getController().getId()==3) openknittingPattern();
    if (theEvent.getController().getId()==4) repedPatternMode = !repedPatternMode;
    if (theEvent.getController().getId()==5) jumpToRow();
    if (theEvent.getController().getId()==6) howMuchPatternToLeft("");
    if (theEvent.getController().getId()==7) changeEditPixels();
    if (theEvent.getController().getId()==8) { 
      String devicePath = Serial.list()[(int)theEvent.getValue()];
      saveUSBSelected(devicePath);
      setupSerialConnection(devicePath);
    }
    if (theEvent.getController().getId()==9) { 
      String machineType=machinesListName.get((int)theEvent.getValue());
      saveModelSelected(machineType);
      setupTypeMachine(machineType);
      showHideFeaturesOpenKnit(machineType);
    }
    if (theEvent.getController().getId()==10) { 
      createParametricSweater();
    }
    if (theEvent.getController().getId()==11)saveImagePattern();
    if (theEvent.getController().getId()==12)applyParametricSweater();
    if (theEvent.getController().getId()==13)saveSweaterAsInputImage();
    if (theEvent.getController().getId()==14) {
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
    if (theEvent.getController().getId()==16) { 
      saveKnittingType((String)my_brother.knittingTypeListName.get((int)theEvent.getValue()));
    }
    if (theEvent.getController().getId()==17) fillListUSB(usbList);   //refresh
    if (theEvent.getController().getId()==18) {
      myPort.clear();
      myPort.stop();
    }
    if (theEvent.getController().getId()==19) {
      showHideFeaturesDebug();
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

void setupTypeMachine(String machineType) {
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
      /*if (img.height>750) {  //not in use??
        posYOffSetPattern = (img.height*sizePixel)-750;
      }
      else { 
        posYOffSetPattern = 0;
      }*/
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

void showHideFeaturesDebug() {
  if (debugMode == false) {
    myTextarea.setVisible(true);
    debugButton.setLabel("Close Debug");
    debugMode = true;
  }
  else {
    myTextarea.setVisible(false);
    debugButton.setLabel("Debug");
    debugMode = false;
  }
}

//------------------------------------------------------------------------------------