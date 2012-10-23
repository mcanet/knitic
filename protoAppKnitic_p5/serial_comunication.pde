void setupSerialConnection() {
  try {
    // Open the port you are using at the rate you want:
    myPort = new Serial(this, Serial.list()[0], 28800);
    lastConnection = millis();
  }
  catch(Exception e) {
  }
}

void sendAndReceiveSerial() {
  try {
    // knowing if is connected
    if (abs(lastMessageReceivedFromSerial-millis())>2000) {
      if (abs(lastConnection-millis())>1000) {
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
  }
  catch(Exception e) {
  }
}

void sendSerial() {
  try {
    String message = "-s-"+_16Selenoids+"-"+status+"-e-";
    myPort.write(message);
    println("send serial");
  }
  catch(Exception e) {
  }
}

void receiveSerial() {
  try {
    if (myPort!=null && myPort.available()>=40) {
      String all = "";
      int j=0;
      while (j < 40) {
        all += myPort.readChar();
        j+=1;
      }
      myPort.clear();
      println(all);
      // get data from serial
      String[] values = split(lastSerialData+all, '-');

      int start =-1;
      int end =-1;

      // look for start inside string received
      for (int i=0;i<values.length;i++) {
        if (values[i].equals("s")) {
          start =i;
          break;
        }
      }

      // look for end inside string received
      for (int i=0;i<values.length;i++) {
        if (values[i].equals("e")) {
          end =i;
          break;
        }
      }
      // when we find start and end then take out variables
      if (start!=-1 && end!=-1  && end > start+5) {
        section = Integer.valueOf(values[start+1]);
        current_row = Integer.valueOf(values[start+2]);
        rows = Integer.valueOf(values[start+3]);
        _16Selenoids = values[start+4];
        action = values[start+5];
        lastSerialData = "";
        lastMessageReceivedFromSerial = millis();
      }
      else {
        lastSerialData +=all;
      }
    }
  }
  catch(Exception e) {
  }
}

