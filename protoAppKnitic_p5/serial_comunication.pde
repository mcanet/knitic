void sendAndReceiveSerial(){
  // Send a capital A out the serial port:
  //try{
  sendSerial();
  receiveSerial();
  usbConected = true;
  //}catch(exceptions e){usbConected = false;}
}

void sendSerial(){
  String message = "-s-"+_16Selenoids+"-"+status+"-e-";
  myPort.write(message);
}

void receiveSerial(){
  if(myPort.available()>=40){
        String all = "";
        int j=0;
        while (j > 40) {
          all += myPort.read();
          j+=1;
        }
        myPort.clear();
        
        println("rebut ::"+all);
        // get data from serial
        String[] values = split(lastSerialData+all, '-');
        
        int start =-1;
        int end =-1;
        
        // look for start inside string received
        for(int i=0;i<values.length;i++){
            if(values[i]=="s"){
                start =i;
                break;
            }
        }
        
        // look for end inside string received
        for(int i=0;i<values.length;i++){
            if(values[i]=="e"){
                end =i;
                break;
            }
        }
        // when we find start and end then take out variables
        if(start!=-1 && end!=-1  && end > start+5){
            println("dins rebut");
            section = Integer.valueOf(values[start+1]);
            current_row = Integer.valueOf(values[start+2]);
            rows = Integer.valueOf(values[start+3]);
            _16Selenoids = values[start+4];
            action = values[start+5];
            //cout << " section:" << section << " row:" << row << " rowEnd:" << rowEnd  << " _16Selenoids:" << _16Selenoids << endl;
            lastSerialData = "";
        }else{
            lastSerialData +=all;
        }
          
  }
  
}
