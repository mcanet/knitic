void display() {  
  noStroke();
  fill(73, 202, 250);
  rect(0, 0, buttonWithBar, 80);
  fill(155, 155, 155);
  rect(width-buttonWithBar, 0, buttonWithBar, height);
  rect(0, 80, buttonWithBar, height);
  fill(100, 100, 100);
  rect(width-buttonWithBar, 0, buttonWithBar, 80);
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
  if (section==-999) {
    text("Section: -", 30, 170);
  }
  else {
    text("Section: "+Integer.toString(section), 30, 170);
  }
  if (stitch==-999) {
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
  int n = round(counterMessagesReceive/(millis()*0.001)) ;
  text("M per Sec: "+Integer.toString(n), 30, 550);
  text("Left pixel: "+Integer.toString(((100-leftStick)/8)), 30, 590);
  text("Right pixel: "+Integer.toString(((100+rightStick)/8)), 30, 630);
  text(Integer.toString( -((section-1)*8)+(cols)+(100-rightStick)-16 ), 30, 700);
  text("lastChangeHead:"+lastChangeHead, 30, 740);
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
    text("Direction: left", 30, 270);
  }
  else if (headDirection==-1) { 
    text("Direction: right", 30, 270);
  }
  if (usbConected) {    
    text("USB: conected", 865, 120);
  }
  else { 
    text("USB: disconected", 865, 120);
  }
  text("Status: "+status+"/"+statusMachine, 865, 170);
  text(_16Solenoids, 840, 310);
  noStroke();
  // scroll bar
  fill(16, 62, 104);
  rect(width-buttonWithBar, 0, 15, height);  
  rect(width-buttonWithBar, myScrollBar.posYscrollBar, 15, myScrollBar.heightYScrollBar);
  text("MouseX:"+Integer.toString(patternMouseX), 855, 510);
  text("MouseY:"+Integer.toString(patternMouseY), 855, 550); 
  text("Available buffer:"+Integer.toString(serialAvailableBuffer), 855, 600); 
}

void drawPattern() {
  pushMatrix();
  translate(buttonWithBar+((100-leftStick)*sizePixel), 0);
  if (img.height>800) { 
    translate(0, (current_row*sizePixel)-posYOffSetPattern);
  }
  noSmooth();
  image(img, 0, 0, img.width*sizePixel, img.height*sizePixel);
  smooth();
  for (int x=0;x<cols;x++) {
    stroke(0);
    line(x*sizePixel, 0, x*sizePixel, rows*sizePixel);
  }
  for (int y=0;y<rows;y++) {
    stroke(0);
    line(0, y*sizePixel, cols*sizePixel, y*sizePixel);
  }
  popMatrix();
}

void drawPatternThumbnail() {
  text("Thumbnail:", 855, 370);
  if (loadPattern) {
    noSmooth();
    int h = img.height/4;
    image(img, width-205, 400, img.width/4, h);
    smooth();
  }
}

void drawPatternGrid() {
  try {
    stroke(7, 146, 253);
    for (int j=0;j<200;j++) {
      line(buttonWithBar+j*sizePixel, 0, buttonWithBar+j*sizePixel, height);
    }
    for (int g=0;g<267;g++) {
      line(buttonWithBar, g*sizePixel, width-231, g*sizePixel);
    } 
    noStroke();
    stroke(30, 30, 30);
  }
  catch(Exception e) {
  }
}

void drawSelectedGrid() {
  int sectionM = section;
  if (headDirection==-1) sectionM +=4;
  if (headDirection==1)  sectionM -=4;
  if (sectionM>25) sectionM =25;
  if (sectionM<1)  sectionM =1; 
  pushMatrix();
  int cubSize = 3;
  translate(buttonWithBar+cubSize*199, 0);
  if (img.height>800) { 
    translate(0, (current_row*sizePixel)-posYOffSetPattern);
  }
  try {
    int y = (rows-1)-current_row;
    for (int x=0;x<200;x++) {
      if ( (headDirection==-1 && x>=((sectionM-2)*8) && x<((sectionM)*8)) 
        || (headDirection==1 && x>=((sectionM-1)*8) && x<((sectionM+1)*8)) 
        || (sectionM==25 && x>=((sectionM-2)*8) && x<((sectionM)*8)) 
        || (sectionM==1 && x>=((sectionM)*8) && x<((sectionM+1)*8)) 
        ) {
        fill(255, 0, 0, 150);
        if (lastChangeHead == "left") {
          rect(-(x*cubSize), y*cubSize, cubSize, cubSize);
        }
        else {
          if (sectionM<5) {
            rect(-(x*cubSize), y*cubSize, cubSize, cubSize);
          }
          else {
            rect(-(x*cubSize-(32*cubSize)), y*cubSize, cubSize, cubSize);
          }
        }
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
      // Define the colors depending if is "1", "0" or "9" (9 this means pin not defined yet )
      if ( _16Solenoids.substring(i, i+1).equals("1") ) {
        if (getSelectedSelenoid(i)) {
          stroke(255, 0, 0);
        }
        else {
          stroke(0);
        }
        fill(255, 255, 255);
      }
      else if ( _16Solenoids.substring(i, i+1).equals("0") ) {
        if (getSelectedSelenoid(i)) {
          stroke(255, 0, 0);
        }
        else {
          stroke(0);
        }
        fill(0, 0, 0);
      }
      else if ( _16Solenoids.substring(i, i+1).equals("9") ) {
        noStroke();
        if (getSelectedSelenoid(i)) {
          stroke(255, 0, 0);
          fill(73, 202, 250);
        }
        else {
          stroke(73, 202, 250);
          fill(73, 202, 250);
        }
      }
      
      rect(2+((15*10)-(i*10)), 3, 5, 5);
      noStroke();
    }
  }
  catch(Exception e) {
    _16Solenoids.length();
  }
  popMatrix();
}

boolean getSelectedSelenoid(int i) {
  //return stitch%16==i+1 || stitch%16==0 && i==15;
  return false;
}

