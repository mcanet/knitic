//------------------------------------------------------------------------------------
void keyPressed() {
  if (key=='o') {
    openknittingPattern();
  }
  // key for debug program
  if (key=='w') {
    startRightSide();
    section=-4;
    stitch=-32;
    headDirection =-1;
  }
  if (key=='q') {
    startLeftSide();
    section=29;
    stitch=232;
    headDirection =1;
  }
  if (key=='s' && endLineStarted) {
    stitch-=1;
    if (stitch<-32) { 
      stitch=-32;
    }
    else {
      headDirection =-1;
    }
    section = ceil(float(stitch)/8.0f);
  }
  if (key=='a' && endLineStarted) {
    stitch+=1;
    if (stitch>232) { 
      stitch=232;
    }
    else {
      headDirection =1;
    }
    section = ceil(float(stitch)/8.0f);
  }
  if (key=='z') {
    stitch=176;
    headDirection =-1;
  }
  if (key=='x') {
    stitch=24;
    headDirection =1;
  }
  if (key=='m') {
    sendtoKnittingMachine();
  }
}
//------------------------------------------------------------------------------------
void startRightSide() {
  current_row = 0;
  headDirectionForNewPixels=+1;
  endLineStarted = true;
  //lastEndLineStarted = false;
  lastChangeHead = "left";
}
//------------------------------------------------------------------------------------
void startLeftSide() {
  current_row = 0;
  headDirectionForNewPixels=-1;
  endLineStarted = true;
  //lastEndLineStarted = false;
  lastChangeHead = "right";
}
//------------------------------------------------------------------------------------
