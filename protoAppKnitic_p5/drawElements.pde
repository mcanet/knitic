void display(){  
  noStroke();
  fill(73,202,250);
  rect(0,0,230,80);
  fill(155,155,155);
  rect(width-230,0,230,height);
  rect(0,80,230,height);
  fill(100,100,100);
  rect(width-230,0,230,80);
 
  image(kniticLogo,0,-10);
  draw16selenoids();
  fill(255);
  textFont(laurentFont); 
  stroke(255);
  noFill();
  rect(25,90,180,35);
  rect(25,140,180,35);
  rect(25,190,180,35);
  rect(25,240,180,35);
  rect(25,290,180,35);
  rect(25,340,180,35);
  rect(25,390,180,35);
  rect(25,440,180,35);
  fill(255); 
  // columne left
  text("Row:"+Integer.toString(current_row),30,120);
  text("Section: 200",30,170);
  text("Stich: 200",30,220);
  text("Width: "+Integer.toString(cols),30,320);  
  text("Height: "+Integer.toString(rows),30,370); 
  text("Left Stick: "+Integer.toString(leftStick),30,420);
  text("Right Stick: "+Integer.toString(rightStick),30,470);  
  // columne right
  stroke(255);
  noFill();
  rect(855,140,180,35);
  rect(855,90,180,35);
  fill(255);
  if(direction=="-"){ text("Direction: none",30,270); }else if(direction=="1"){ text("Direction: right",30,270); }else if(direction=="-1"){ text("Direction: left",650,30); }
  if(usbConected){    text("USB: conected",865,120);}else{ text("USB: disconected",865,120); }
  if(status=="0"){    text("Status: stop",865,170); }else if(status=="1"){ text("Status: knitting",870,170); }
  noStroke();
  // scroll bar
  fill(16,62,104);
  rect(width-230,0,15,height);  
  rect(width-230,myScrollBar.posYscrollBar,15,myScrollBar.heightYScrollBar);  
}

void drawPatternGrid(){
  int sizePixel = 3;
  for(int j=0;j<200;j++){
     stroke(255,0,0);
     line(230+j*sizePixel,0,230+j*sizePixel,height);
  }
  for(int g=0;g<400;g++){
       stroke(255,0,0);
       line(230,g*sizePixel,width-231,g*sizePixel);
  } 
  noStroke();
  stroke(30,30,30);
}

void draw16selenoids(){
  pushMatrix();
  translate(30,65);
  fill(255);
  stroke(255);
  strokeWeight(1);
  rect(0,0,16*10,10);
  noStroke();
  for(int i=0;i<16;i++){
    if( _16Selenoids.substring(i,i+1).equals("0") ){
      fill(73,202,250);
    }else{
      fill(0,0,0);
    }
    rect(2+i*10,3,5,5);
  }
  popMatrix();
}
