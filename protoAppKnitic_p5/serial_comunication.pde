void setupSerialConnection() {
  try {
    println("try to connect");
    println(Serial.list()[0]);
    // Open the port you are using at the rate you want:
    myPort = new Serial(this, Serial.list()[0], 115200);
    lastConnection = millis();
  }
  catch(Exception e) {
  }
}

void autoConnectAndReceiveSerial() {
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
    
    receiveSerial();
  }
  catch(Exception e) {
  }
}

void sendSerial() {
  try {
    if ( (millis()-lastMessageSendFromSerial)>500  || !last16Solenoids.equals(_16Solenoids) ) {
      String _16SolenoidsNew = _16Solenoids.replace('9', '0');
      String message = ",s,"+_16SolenoidsNew+","+status+",e,";
      //println(_16SolenoidsNew);
      myPort.write(message);
      String filler = "";
      for (int i = message.length(); i<46; i++) {
        filler += "e";
      }
      myPort.write(filler);
      //println("send serial");
      lastMessageSendFromSerial = millis();
    }
    last16Solenoids = _16Solenoids;
  }
  catch(Exception e) {
    println("Error in send serial");
  }
}

void receiveSerial() {
  try {
    while(myPort!=null && myPort.available()>0 ) {
      println("Receive Serial___"+Integer.toString(myPort.available()));
      String all = "";
      // read from buffer, but only if there's no end-of-message to be processed
      while ( (myPort.available ()>0) && !((lastSerialData+all).contains("e") && (lastSerialData+all).contains("s") ) ) {
        all += myPort.readChar();
      }
      //myPort.clear();
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
      if (_start!=-1) {
        for (int i=_start;i<values.length;i++) {
          if (values[i].equals("e")) {
            _end =i;
            break;
          }
        }
      }
      //println("end:"+Integer.toString(_end));
      // when we find start and end then take out variables
      if ( _start!=-1 && _end!=-1  && _end > _start+5 ) {
        println("Receive Serial_WITH ALL MESSAGE");
        lastMessageReceivedFromSerial = millis();
        //section = Integer.valueOf(values[_start+1]);
        
        //println(section);
        stitch = Integer.valueOf(values[_start+2]);
        section = int(stitch/8);
        endLineStarted = !values[_start+3].equals("0");
        headDirection = -Integer.valueOf(values[_start+4]);
        status = values[_start+4];
        println("end of getting values");
        if (status=="reset_initialpos" && endLineStarted) {
          status="knitting";
          if (stitch==0) startRightSide();
          if (stitch==200) startLeftSide();
        }
        // get part message to other
        if (_end+1<values.length) {
          lastSerialData = "";
          for (int i=_end+1;i<values.length;i++) {
            lastSerialData +=","+values[i];
          }
        }
        // calculate with new data
        brain();
        println("call brain");
      }
      else {
        lastSerialData +=all;
      }
    }
  }
  catch(Exception e) {
    println("ERROR in receive serial");
  }
}
/*
void receiveSerial() {
  try {
    //println("try to Receive Serial___"+Integer.toString(myPort.available()));
    if (myPort!=null && myPort.available()>0) {
      println("Receive Serial___");
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
      if (_start!=-1) {
        for (int i=_start;i<values.length;i++) {
          if (values[i].equals("e")) {
            _end =i;
            break;
          }
        }
      }
      //println("end:"+Integer.toString(_end));
      // when we find start and end then take out variables
      if ( _start!=-1 && _end!=-1  && _end > _start+5 ) {
        println("Receive Serial_WITH ALL MESSAGE");
        lastMessageReceivedFromSerial = millis();
        //section = Integer.valueOf(values[_start+1]);
        //print("section:");
        //println(section);
        stitch = Integer.valueOf(values[_start+2]);
        section = int(stitch/8);
        endLineStarted = !values[_start+3].equals("0");
        headDirection = -Integer.valueOf(values[_start+4]);
        status = values[_start+4];
        if (status=="r" && endLineStarted) {
          status="knitting";
          if (stitch==0) startRightSide();
          if (stitch==200) startLeftSide();
        }
        // get part message to other
        if (_end+1<values.length) {
          for (int i=_end+1;i<values.length;i++) {
            lastSerialData =","+values[i];
          }
        }
      }
      else {
        lastSerialData +=all;
      }
    }
  }
  catch(Exception e) {
    println("ERROR in receive serial");
  }
}
*/
