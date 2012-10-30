void display() {  
  noStroke();
  fill(73, 202, 250);
  rect(0, 0, 230, 80);
  fill(155, 155, 155);
  rect(width-230, 0, 230, height);
  rect(0, 80, 230, height);
  fill(100, 100, 100);
  rect(width-230, 0, 230, 80);

  image(kniticLogo, 0, -10);
  draw16selenoids();
  fill(255);
  textFont(laurentFont); 
  stroke(255);
  noFill();
  rect(25, 90, 180, 35);
  rect(25, 140, 180, 35);
  rect(25, 190, 180, 35);
  rect(25, 240, 180, 35);
  rect(25, 290, 180, 35);
  rect(25, 340, 180, 35);
  rect(25, 390, 180, 35);
  rect(25, 440, 180, 35);
  rect(25, 490, 180, 35);
  fill(255); 
  // columne left
  if (current_row<0) { 
    text("Row:-", 30, 120);
  }
  else { 
    text("Row:"+Integer.toString(current_row), 30, 120);
  }
  if (section<0) {
    text("Section: -", 30, 170);
  }
  else {
    text("Section: "+Integer.toString(section), 30, 170);
  }
  if (stitch<0) {
    text("Stitch: -", 30, 220);
  }
  else {
    text("Stitch: "+Integer.toString(stitch), 30, 220);
  }
  if (cols<0) {
    text("Width: -", 30, 320);
  }
  else {
    text("Width: "+Integer.toString(cols), 30, 320);
  } 
  if (rows<0) {
    text("Height: -", 30, 370);
  }
  else {
    text("Height: "+Integer.toString(rows), 30, 370);
  }
  if (leftStick<0) {
    text("Left Stick: -", 30, 420);
  }
  else {
    text("Left Stick: "+Integer.toString(leftStick), 30, 420);
  }
  if (rightStick<0) {
    text("Right Stick: -", 30, 470);
  }
  else {
    text("Right Stick: "+Integer.toString(rightStick), 30, 470);
  } 
  if (endLineStarted) { 
    text("Started", 30, 520);
  }
  else { 
    text("Not started", 30, 520);
  }
  text("Left pixel: "+Integer.toString(((100-leftStick)/8)), 30, 570);
  text("Right pixel: "+Integer.toString(((100+rightStick)/8)), 30, 630);
  // columne right
  stroke(255);
  noFill();
  rect(855, 140, 180, 35);
  rect(855, 90, 180, 35);
  fill(255);
  if (headDirection==0) { 
    text("Direction: none", 30, 270);
  }
  else if (headDirection==1) { 
    text("Direction: right", 30, 270);
  }
  else if (headDirection==-1) { 
    text("Direction: left", 30, 270);
  }
  if (usbConected) {    
    text("USB: conected", 865, 120);
  }
  else { 
    text("USB: disconected", 865, 120);
  }
  text("Status: "+status, 865, 170);
  noStroke();
  // scroll bar
  fill(16, 62, 104);
  rect(width-230, 0, 15, height);  
  rect(width-230, myScrollBar.posYscrollBar, 15, myScrollBar.heightYScrollBar);
}

void drawPatternGrid() {
  try {
    int sizePixel = 3;
    for (int j=0;j<200;j++) {
      stroke(255, 0, 0);
      line(230+j*sizePixel, 0, 230+j*sizePixel, height);
    }
    for (int g=0;g<400;g++) {
      stroke(255, 0, 0);
      line(230, g*sizePixel, width-231, g*sizePixel);
    } 
    noStroke();
    stroke(30, 30, 30);
  }
  catch(Exception e) {
  }
}

void drawSelectedGrid() {
  pushMatrix();
  translate(230, 0);
  int cubSize = 3;
  try {
    int y = (rows-1)-current_row;
    for (int x=0;x<200;x++) {
      if (x<16) {
        println("comparation");
        print((section-1)*8);
        print(">=");
        println(x);
        print(section*8);
        print("<=");
        println(x);
      }
      if ( x>=((section-1)*8) && x<=((section+1)*8)) {
        fill(243, 243, 1, 100);
        rect(x*cubSize, y*cubSize, cubSize, cubSize);
      }
    }
  }
  catch(Exception e) {
  }
  popMatrix();
}

void draw16selenoids() {
  pushMatrix();
  translate(30, 65);
  fill(255);
  stroke(255);
  strokeWeight(1);
  rect(0, 0, 16*10, 10);
  noStroke();
  try {
    for (int i=0;i<16;i++) {
      if ( _16Selenoids.substring(i, i+1).equals("0") ) {
        fill(73, 202, 250);
      }
      else {
        fill(0, 0, 0);
      }
      rect(2+i*10, 3, 5, 5);
    }
  }
  catch(Exception e) {
    _16Selenoids.length();
  }
  popMatrix();
}

