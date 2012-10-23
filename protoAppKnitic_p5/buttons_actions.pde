void addButtonsInSetup(){
  controlP5 = new ControlP5(this);
  controlP5.addButton("Start",10,855,45,40,30).setId(1);
  controlP5.addButton("Stop",4,905,45,40,30).setId(2);
  controlP5.addButton("Open",4,955,45,40,30).setId(3);
  //controlP5.
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id());
  if(theEvent.controller().id()==1) startknitting();
  if(theEvent.controller().id()==2) stopknitting();
  if(theEvent.controller().id()==3) openknittingPattern();
}

void startknitting(){
  status = "1";
}

void stopknitting(){
  status = "0";
}

void openknittingPattern(){  
  selectInput("Select a file to process:", "fileSelected");  // Opens file chooser
}

void fileSelected(File selection) {
  if (selection != null) {
    fillArrayWithImage(selection.getAbsolutePath());
  }
}
