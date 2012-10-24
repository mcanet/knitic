void setupSerialConnection() {
  try {
    println("try to connect");
    println(Serial.list()[0]);
    // Open the port you are using at the rate you want:
    myPort = new Serial(this, Serial.list()[0], 28800);
    lastConnection = millis();
  }catch(Exception e) {
  }
}

void sendAndReceiveSerial() {
  try {
    // knowing if is connected
    if (abs(millis()-lastMessageReceivedFromSerial)>2000) {
      if (abs(lastConnection-millis())>1500) {
        usbConected = false;
        myPort.clear();
        myPort.stop();
        myPort = null;
        setupSerialConnection();
      }
    }
    else {
      usbConected = true;
    }
    sendSerial();
    receiveSerial();
  }catch(Exception e) {
  }
}

void sendSerial() {
  try {
    if( (millis()-lastMessageSendFromSerial)>200  || !last16Selenoids.equals(_16Selenoids) ){
      String message = ",s,"+_16Selenoids+","+status+",e,";
      myPort.write(message);
      println("send serial");
      lastMessageSendFromSerial = millis();
    }
    last16Selenoids = _16Selenoids;
  }
  catch(Exception e) {
  }
}

void receiveSerial() {
  try {
    if(myPort!=null && myPort.available()>0) {
      //println("Receive Serial___");
      String all = "";
      while (myPort.available()>0) {
        all += myPort.readChar();
      }
      myPort.clear();
      //println(lastSerialData+all);
      // get data from serial
      String[] values = split(lastSerialData+all, ',');
      
      int _start =-1;
      int _end =-1;
      // look for start inside string received
      for (int i=0;i<values.length;i++) {
        if (values[i].equals("s")) {
          _start =i;
          break;
        }
      }
      //println("start:"+Integer.toString(_start));
      // look for end inside string received
      if(_start!=-1){
        for(int i=_start;i<values.length;i++) {
          if(values[i].equals("e")) {
            _end =i;
            break;
          }
        }
      }
      //println("end:"+Integer.toString(_end));
      // when we find start and end then take out variables
      if( _start!=-1 && _end!=-1  && _end > _start+4 ){
        //println("parsed");
        lastMessageReceivedFromSerial = millis();
        section = Integer.valueOf(values[_start+1]);
        //print("section:");
        //println(section);
        endLineStarted = Integer.valueOf(values[_start+2]).equals("0");
        headDirection = Integer.valueOf(values[_start+3]);
        status = values[_start+4];
        
        // get part message to other
        if(_end+1<values.length){
          for(int i=_end+1;i<values.length;i++){
            lastSerialData =","+values[i];
          }
        }
      }else {
        lastSerialData +=all;
      }
    }
  }
  catch(Exception e) {
     println("ERROR in receive serial");
  }
}

