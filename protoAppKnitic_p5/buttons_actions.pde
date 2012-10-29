void addButtonsInSetup() {
  controlP5 = new ControlP5(this);
  controlP5.addButton("Start", 10, 855, 45, 40, 30).setId(1);
  controlP5.addButton("Stop", 4, 905, 45, 40, 30).setId(2);
  controlP5.addButton("Open", 4, 955, 45, 40, 30).setId(3);
  controlP5.addToggle("Repeating pattern mode", true, 855, 205, 20, 20).setId(4);
  controlP5.addButton("Go to row", 4, 855, 255, 80, 30).setId(5);
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id());
  if (theEvent.controller().id()==1) startknitting();
  if (theEvent.controller().id()==2) stopknitting();
  if (theEvent.controller().id()==3) openknittingPattern();
  if (theEvent.controller().id()==4) repedPatternMode = !repedPatternMode;
  if (theEvent.controller().id()==5) {
    String new_current_row = JOptionPane.showInputDialog(frame, "To whish row you want to jump ?", Integer.toString(current_row));
    if ( !Integer.toString(current_row).equals(new_current_row) ) {
      current_row = Integer.valueOf(new_current_row);
    }
  }
}

void startknitting() {
  status = "1";
}

void stopknitting() {
  status = "0";
}

void openknittingPattern() {  
  selectInput("Select a file to process:", "fileSelected");  // Opens file chooser
}

void fileSelected(File selection) {
  if (selection != null) {
    fillArrayWithImage(selection.getAbsolutePath());
  }
}

