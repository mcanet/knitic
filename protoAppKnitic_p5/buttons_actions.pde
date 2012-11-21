void addButtonsInSetup() {
  controlP5 = new ControlP5(this);
  controlP5.addButton("Start", 10, 855, 45, 40, 30).setId(1);
  controlP5.addButton("Stop", 4, 905, 45, 40, 30).setId(2);
  controlP5.addButton("Open", 4, 955, 45, 40, 30).setId(3);
  controlP5.addToggle("Repeating pattern mode", true, 855, 205, 20, 20).setId(4);
  controlP5.addButton("Go to row", 4, 855, 255, 80, 30).setId(5);
  controlP5.addButton("Start edit image", 4, 855, 455, 80, 30).setId(6);
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id());
  //if (theEvent.controller().id()==1) startknitting();
  //if (theEvent.controller().id()==2) stopknitting();
  if (theEvent.controller().id()==3) openknittingPattern();
  if (theEvent.controller().id()==4) repedPatternMode = !repedPatternMode;
  if (theEvent.controller().id()==5) {
    String new_current_row = JOptionPane.showInputDialog(frame, "To whish row you want to jump ?", Integer.toString(current_row));
    if ( !Integer.toString(current_row).equals(new_current_row) ) {
      current_row = Integer.valueOf(new_current_row);
    }
  }
  if (theEvent.controller().id()==6) {
    editPixels =!editPixels;
  }
}

void updateEditPixels() {
  if (editPixels) {
    cursor(CROSS);
    //controlP5.getId(6).setText("Stop edit image");
  } 
  else {
    cursor(ARROW);
    //controlP5.getId(6).setText("Start edit image");
  }
}
/*
void startknitting() {
  status = "1";
}

void stopknitting() {
  status = "0";
}
*/
void openknittingPattern() {  
  selectInput("Select a file to process:", "fileSelected");  // Opens file chooser
}

void fileSelected(File selection) {
  if (selection != null) {
    fillArrayWithImage(selection.getAbsolutePath());
  }
}

void fillArrayWithImage(String imgPath) { 
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
      myScrollBar.setupScrollBar();
      int restPixels = 200-cols;
      leftStick = 100-(restPixels/2);
      rightStick = 100-(restPixels/2);
      if ( (100-leftStick)+cols+(100-rightStick) !=200) {
        rightStick +=1;
      }

      String userStartStick="";
      if (cols!=200) {

        userStartStick = JOptionPane.showInputDialog(frame, "Do you want to start from left " +Integer.toString(leftStick)+"?", Integer.toString(leftStick));
        if (!userStartStick.equals(Integer.toString(leftStick))) {
          leftStick = Integer.valueOf(userStartStick);
          rightStick = (cols+(100-leftStick))-100;
        }
      }

      img.loadPixels(); 
      for (int y = 0; y <rows; y++) {
        for (int x = 0; x <  cols; x++) {
          int loc = /*(cols-1)-*/x + y*cols;
          if (brightness(img.pixels[loc]) > threshold) {
            pixelArray[x][y] = 0;
          }
          else {
            pixelArray[x][y] = 1;
          }
        }
      }
      status = "reset_initialpos";
    }
  }
  catch(Exception e) {
  }
}

