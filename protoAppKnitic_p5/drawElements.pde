//------------------------------------------------------------------------------------

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
  rect(15, 90, 190, 35);
  rect(15, 140, 190, 35);
  rect(15, 190, 190, 35);
  rect(15, 240, 190, 35);
  rect(15, 290, 190, 35);
  rect(15, 340, 190, 35);
  rect(15, 390, 190, 35);
  rect(15, 440, 190, 35);

  fill(255); 
  // columne left
  if (usbConected) {    
    text("USB: connected", 20, 120);
  }
  else { 
    text("USB: disconnected", 20, 120);
  }
  if (current_row<0) { 
    text("Row:-", 20, 170);
  }
  else { 
    text("Row:"+Integer.toString(current_row), 20, 170);
  }
  if (stitch==-999) {
    text("Stitch: -", 20, 220);
  }
  else {
    text("Stitch: "+Integer.toString(stitch), 20, 220);
  }
  if (cols<0) {
    text("Width: -", 20, 320);
  }
  else {
    text("Width: "+Integer.toString(cols), 20, 320);
  } 
  if (rows<0) {
    text("Height: -", 20, 370);
  }
  else {
    text("Height: "+Integer.toString(rows), 20, 370);
  }
  if (leftStick<0) {
    text("Left Stick: -", 20, 420);
  }
  else {
    text("Left Stick: "+Integer.toString(leftStick), 20, 420);
  }
  if (rightStick<0) {
    text("Right Stick: -", 20, 470);
  }
  else {
    text("Right Stick: "+Integer.toString(rightStick), 20, 470);
  } 

  fill(255);
  if (headDirection==0) { 
    text("Direction: none", 20, 270);
  }
  else if (headDirection==1) { 
    text("Direction: left", 20, 270);
  }
  else if (headDirection==-1) { 
    text("Direction: right", 20, 270);
  }
  noStroke();
  // scroll bar
  fill(16, 62, 104);
  rect(buttonWithBar-9, 0, 9, height);
  rect(width-buttonWithBar, 0, 9, height);
  // show small lines for rail of visualization knitles 
  noStroke();
  fill(255);
  rect(buttonWithBar-9, 26*3+1, 9, 2);
  rect((width-buttonWithBar), 26*3+1, 9, 2);
  stroke(255);
}

//------------------------------------------------------------------------------------

void drawDebugVariables() {
  rect(15, 490, 190, 35);
  if (endLineStarted) { 
    text("Started", 20, 520);
  }
  else { 
    text("Not started", 20, 520);
  }

  stroke(255);
  noFill();
  rect(855, 140, 180, 35);
  fill(255);
  text("Status: "+status+"/"+statusMachine, 865, 170);

  int n = round(counterMessagesReceive/(millis()*0.001)) ;
  text("M per Sec: "+Integer.toString(n), 30, 550);

  text("MouseX:"+Integer.toString(patternMouseX), 855, 510);
  text("MouseY:"+Integer.toString(patternMouseY), 855, 550); 
  text("Available buffer:"+Integer.toString(serialAvailableBuffer), 855, 600);

  if (repedPatternMode) {
    text("Repeat: true", 30, 500);
  }
  else {
    text("Repeat: false", 30, 500);
  } 
  text("Left pixel: "+Integer.toString(((100-leftStick)/8)), 30, 590);
  text("Right pixel: "+Integer.toString(((100+rightStick)/8)), 30, 630);
  text(Integer.toString( -((section-1)*8)+(cols)+(100-rightStick)-16 ), 30, 700);
  text("lastChangeHead:"+lastChangeHead, 30, 740);
  if (section==-999) {
    text("Section: -", 30, 170);
  }
  else {
    text("Section: "+Integer.toString(section), 30, 170);
  }
  text(_16Solenoids, 840, 310);
}

//------------------------------------------------------------------------------------

void drawPattern() {
  pushMatrix();
  translate(buttonWithBar+((100-leftStick)*sizePixel)+(cols*sizePixel), ((27-rows)+current_row)*sizePixel);
  noSmooth();
  scale(-1, 1);
  image(img, 0, 0, img.width*sizePixel, img.height*sizePixel);
  smooth();
  // draw grid
  for (int x=0;x<cols+1;x++) {
    stroke(0);
    line(x*sizePixel, 0, x*sizePixel, rows*sizePixel);
  }
  for (int y=0;y<rows+1;y++) {
    stroke(0);
    line(0, y*sizePixel, cols*sizePixel, y*sizePixel);
  }
  popMatrix();
}

//------------------------------------------------------------------------------------

void drawPatternThumbnail() {
  text("Thumbnail:", 855, 370);
  if (loadPattern) {
    noSmooth();
    int h = img.height/4;
    image(img, width-205, 400, img.width/4, h);
    smooth();
  }
}

//------------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------------

void drawAndSetSelectedGrid() {
  int stitchViz = stitch;
  int startStitch  = 24;
  int totalCub = 16;
  _16Solenoids = "";
  // LEFT visualization

  if (stitch<startStitch && headDirection==1) { 
    stitchViz = 0;
    if (stitch>8) {
      totalCub = (stitch-8);
    }
    else {
      totalCub =0;
    }
  }
  else if (headDirection==1) {
    stitchViz = stitch-startStitch;
    if (stitch>208) {
      totalCub = 16-(stitch-208);
    }
  }
  // RIGHT visualization
  if (stitch>176 && headDirection==-1) { 
    stitchViz = 200;
    if (stitch<192) {
      totalCub = 192-stitch;
      //println("First part :"+Integer.toString(totalCub));
    }
    else {
      totalCub =0;
    }
  }
  else if (headDirection==-1) {
    stitchViz = stitch+startStitch;
    //println("Second part");
    if (stitch<-8) {
      totalCub = 16+(stitch+8);
    }
  }
  for (int i=0;i<16;i++) {
    _16SolenoidsAr[i]='9';
  }
  // Draw 

  if (totalCub>0) {
    pushMatrix();
    translate(buttonWithBar+sizePixel*199, 0);
    int y = 26;          
    // Color direction
    int width16Solenoids = sizePixel*totalCub;
    int rightStickOffset = 100-rightStick;
    try {
      if (headDirection==1) {
        fill(255, 0, 0, 150);
        rect(-((stitchViz-1)*sizePixel)-width16Solenoids, y*sizePixel, width16Solenoids, sizePixel);
        for (int i=(stitchViz-1);i<(stitchViz+totalCub);i++) {
          int solenoidId = ((i)%16);
          int pixelId = getReadPixelsFromPosition(i+rightStickOffset);
          if (pixelId==0 && solenoidId<16 && solenoidId>=0 ) {
            _16SolenoidsAr[solenoidId] = '1';
          }
          else if (pixelId==1 && solenoidId<16 && solenoidId>=0) {
            _16SolenoidsAr[solenoidId] = '0';
          }
          else if (pixelId==9 && solenoidId<16 && solenoidId>=0 && stitchViz<(201) ) {
            _16SolenoidsAr[solenoidId] = '9';
          }
          else if (stitchViz>=201 ) {
            _16SolenoidsAr[solenoidId] = '0';
          }
        }
      }
      else {
        fill(0, 255, 0, 150);
        rect(-((stitchViz-1)*sizePixel), y*sizePixel, width16Solenoids, sizePixel);
        for (int i=(stitchViz-1);i>((stitchViz-1)-totalCub);i--) {
          int solenoidId = ((i)%16);
          int pixelId = getReadPixelsFromPosition(i+rightStickOffset);
          if (pixelId==0 && solenoidId<16 && solenoidId>=0) {
            _16SolenoidsAr[solenoidId] = '1';
          }
          else if (pixelId==1 && solenoidId<16 && solenoidId>=0) {
            _16SolenoidsAr[solenoidId] = '0';
          }
          else if (pixelId==9 && solenoidId<16 && solenoidId>=0 && stitchViz>-1) {
            _16SolenoidsAr[solenoidId] = '9';
          }
          else if (stitchViz<=-1 ) {
            _16SolenoidsAr[solenoidId] = '0';
          }
        }
      }
    }
    catch(Exception e) {
    }
    popMatrix();
  }
  // pass from array to string to send to arduino
  convertSolenoidsToBinary();
  // solenoids to string
  try {
    for (int i=0;i<16;i++) {
      if (totalCub>0) {
        _16Solenoids +=_16SolenoidsAr[i];
      }
      else {
        _16Solenoids +="0";
      }
    }
  }
  catch(Exception e) {
  }
}

//------------------------------------------------------------------------------------

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
      // draw red active stich 
      if (  isCurrentStich_1(i) ) {
        fill(255, 0, 0);
        rect(2+((15*10)-(i*10))-1, 3-1, 8, 8);
      }
      // Define the colors depending if is "1", "0" or "9" (9 this means pin not defined yet )
      if ( _16Solenoids.substring(i, i+1).equals("1") ) {
        stroke(0);
        fill(255, 255, 255);
      }
      else if ( _16Solenoids.substring(i, i+1).equals("0") ) {
        stroke(0);
        fill(0, 0, 0);
      }
      else if ( _16Solenoids.substring(i, i+1).equals("9") ) {
        noStroke();
        stroke(73, 202, 250);
        fill(73, 202, 250);
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
//------------------------------------------------------------------------------------
// this method tell active stich
boolean isCurrentStich(int i) {
  return (  (stitch<=176 && stitch>=-24 && headDirection==-1) && ((stitch+7+(i*headDirection))%16)==0 ) || ( (stitch>=24 && stitch<=224 &&  headDirection==1)  && ((stitch+8-(i*headDirection))%16)==0 );
}
//------------------------------------------------------------------------------------
// this method tell active stich
boolean isCurrentStich_1(int i) {
  return (  (stitch<=176 && stitch>=-24 && headDirection==-1) && ((stitch+7+(i*headDirection))%16)==1 ) || ( (stitch>=24 && stitch<=224 &&  headDirection==1)  && ((stitch+8-(i*headDirection))%16)==1 );
}
//------------------------------------------------------------------------------------
void drawReceivedPixelsVsSend() {
  try {
    for (int i=0;i<200;i++) {
      if (pixelSend[i]==0) {
        fill(255, 0, 255);
      }
      else {
        fill(255, 255, 255);
      }
      rect(i*5, height-5, 5, 5);
    }
    for (int i=0;i<200;i++) {
      if (pixelReceived[i]==0) {
        fill(255, 0, 255);
      }
      else {
        fill(255, 255, 255);
      }
      rect(i*5, height-10, 5, 5);
    }
  }
  catch(Exception e) {
  }
}
//------------------------------------------------------------------------------------

