class communication{
private:
  encoders* myEncoders;
  endLines* myEndlines;
  solenoids* mysolenoids;
  char buf[48];
  unsigned long lastSendTimeStamp;
  int readCnt;
  unsigned int received;
  unsigned int lastReceived;
  boolean changedsolenoids;
  unsigned int bitRegister16Solenoid[16];

public:
  String _status;
  communication(){
  }
  ~communication(){
  }

  void setup(encoders* _myEncoders, endLines* _myEndlines, solenoids* _mysolenoids){
    myEncoders = _myEncoders;
    myEndlines = _myEndlines;
    mysolenoids = _mysolenoids;
    lastSendTimeStamp = millis();
    readCnt = 0;
    // table - bit encoding
    unsigned int bitRegister16SolenoidTemp[16] = 
    {
      32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1                        };
    for(int i=0; i<16; i++){
      bitRegister16Solenoid[i] = bitRegister16SolenoidTemp[i];
    }
  }

  // send data to processing

  void sendSerialToComputer(){
    if((myEncoders->last8segmentEncoder!=myEncoders->_8segmentEncoder) || (myEncoders->lastEncoder0Pos!=myEncoders->encoder0Pos) || (millis()-lastSendTimeStamp)>200 ){
      lastSendTimeStamp = millis();
      Serial.print(",s,");
      Serial.print(myEncoders->segmentPosition);
      Serial.print(",");
      Serial.print(myEncoders->encoder0Pos/4);
      Serial.print(",");
      if(myEndlines->started){ 
        Serial.print('1');
      }
      else{ 
        Serial.print('0'); 
      }
      Serial.print(",");
      Serial.print(myEncoders->headDirection);
      Serial.print(",");
      Serial.print(_status);
      Serial.println(",e,");

      //
      myEncoders->lastEncoder0Pos = myEncoders->encoder0Pos;
    }
  }
#ifdef arduinoTypeDUE
  void checkSolenoid(int i){
    mysolenoids->solenoidstateChanged[i] = false;
    if( bitRegister16Solenoid[i] == (received & bitRegister16Solenoid[i])){
      if(mysolenoids->solenoidstate[i] !=true){
        changedsolenoids = true;
        mysolenoids->solenoidstateChanged[i] = true;
        mysolenoids->solenoidstate[i] = true;
      }
    }
    else{
      if(mysolenoids->solenoidstate[i] !=false){
        changedsolenoids = true;
        mysolenoids->solenoidstateChanged[i] = true;
        mysolenoids->solenoidstate[i] = false;
      }
    }
  }

  void set16Solenoids(){
    if(lastReceived != received){
      changedsolenoids = false;
      lastReceived = received;
      for(int i=0; i<16; i++){
        checkSolenoid(i);
      }
      if(changedsolenoids){
        mysolenoids->changedsolenoids = true;
      }
    }
  }
#endif

  // get data from processing
  void receiveSerialFromComputer(){
    if (Serial.available() > 0) {
      char buffer[2];
      Serial.readBytesUntil(',', &buffer[0], 4);
      received = 0;
      received = buffer[0] <<8;
      received = received | buffer[1];

#ifdef arduinoTypeDUE
      set16Solenoids();
#endif

#ifdef arduinoTypeUNO
      mysolenoids->dataSector1 = buffer[0];
      mysolenoids->dataSector2 = buffer[1];
#endif

    }
  }

};
