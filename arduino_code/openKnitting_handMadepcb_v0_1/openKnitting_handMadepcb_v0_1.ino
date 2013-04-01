/*
 *
 * OPEN KNITTING
 * @Description: Code for open source machine
 * @Authors: Mar Canet & Varvara Guljajeva 
 * @Versions:0.1v 
 *
 */

#define arduinoTypeDUE "due"
//#define arduinoTypeUNO uno
#define totalArrayFromSelenoids 16

//---------------------------------------------------------------------------------
// Controled by Toshiva
class solenoids{
private:
  int dataSector1;
  int dataSector2;
  int dataArray[8];
  int dataArraypos[8];
  byte myDataOut;
#ifdef arduinoTypeDUE
  int amegaPinsArray[16];
  int ledArray[16];
#endif
  unsigned long lastArrayWrite;
  //Pin connected to ST_CP of 74HC595
  int latchPin;
  //Pin connected to SH_CP of 74HC595
  int clockPin;
  //Pin connected to DS of 74HC595
  int dataPin;
  //--- Important: All Pins must be 8 or higher (in PORTB range)
  int latchPinPORTB;
  int clockPinPORTB;
  int dataPinPORTB;
public:
#ifdef arduinoTypeDUE
  boolean solenoidstateChanged[16];
#endif
  boolean changedsolenoids;
  boolean solenoidstate[16];
  String _16solenoids;
  solenoids(){
    changedsolenoids = true;
#ifdef arduinoTypeDUE  
    int ledArrayTemp[totalArrayFromSelenoids] =       {
      38,40,42,44,46,48,50,52,39,41,43,45,47,49,51,53                                    };
    int amegaPinsArrayTemp[totalArrayFromSelenoids] = {
      22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23                                    };
    for(int i=0; i<16; i++){
      amegaPinsArray[i] = amegaPinsArrayTemp[i];
      ledArray[i] = ledArrayTemp[i];
      pinMode(amegaPinsArrayTemp[i], OUTPUT);
      pinMode(ledArrayTemp[i], OUTPUT);
    }
#endif
  }

  ~solenoids(){
  }

  void setup(){
    //Pin connected to ST_CP of ULN2803A
    latchPin = 8;
    //Pin connected to SH_CP of 74HC595
    clockPin = 12;
    //Pin connected to DS of 74HC595
    dataPin = 11;

    //set pins to output because they are addressed in the main loop
    pinMode(latchPin, OUTPUT);
    pinMode(clockPin, OUTPUT);
    pinMode(dataPin, OUTPUT);

    _16solenoids = "0000000000000000";

    // Holds the actual order in which the bits have to be shifted in
    dataArraypos[0] = 0x07;
    dataArraypos[1] = 0x06;
    dataArraypos[2] = 0x05;
    dataArraypos[3] = 0x04;
    dataArraypos[4] = 0x03;
    dataArraypos[5] = 0x02;
    dataArraypos[6] = 0x01;
    dataArraypos[7] = 0x00;

    //Arduino doesn't seem to have a way to write binary straight into the code 
    //so these values are in HEX.  Decimal would have been fine, too. 
    dataArray[0] = 0x80; //10000000
    dataArray[1] = 0x40; //01000000
    dataArray[2] = 0x20; //00100000
    dataArray[3] = 0x10; //00010000
    dataArray[4] = 0x08; //00001000
    dataArray[5] = 0x04; //00000100
    dataArray[6] = 0x02; //00000010
    dataArray[7] = 0x01; //00000001

      for(int i=0;i<16;i++){
      solenoidstate[i] = (_16solenoids[i] != '0');
      solenoidstateChanged[i] = true;
    }

    lastArrayWrite = millis();
    changedsolenoids=true;
    //setupSPI();
  }

  void loop(){
    if(/*(millis()-lastArrayWrite > 1000) || */ changedsolenoids==true /*&& (millis()-lastArrayWrite > 150)*/ ){
      changedsolenoids = false;
#ifdef arduinoTypeDUE
      setArduinoMegaPins();
#endif

#ifdef arduinoTypeUNO
      dataSector1 = 0x00;
      dataSector2 = 0x00;
      for (int j = 0; j < 8; ++j) {
        //load the light sequence you want from array
        if(solenoidstate[j]==true){
          dataSector1 = dataSector1 ^ dataArray[dataArraypos[j]];
        }
        if(solenoidstate[j+8]==true){
          dataSector2 = dataSector2 ^ dataArray[dataArraypos[j]];
        }  
      }
      sendValuesToShifOut(dataSector1, dataSector2);//classic ShiftOut
      //iProcess(dataSector1, dataSector2);// fast ShiftOut
#endif
      lastArrayWrite = millis();
    }
  }

#ifdef arduinoTypeDUE
  void setArduinoMegaPins(){
    for(int i=0;i<16;i++){
      if(solenoidstateChanged[i]==true){
        if(solenoidstate[i]==true){
          digitalWrite(amegaPinsArray[i], HIGH);
          digitalWrite(ledArray[i], HIGH);
        }
        else{
          digitalWrite(amegaPinsArray[i], LOW);
          digitalWrite(ledArray[i], LOW);
        }
        solenoidstateChanged[i]=false;
      }
    }
  }
#endif

#ifdef arduinoTypeUNO
  // fast shiftOut ----------------------------------------------------------
  void setupSPI(){
    //--- Using standard shiftOut:
    // at 2 Shift Registers - 225 fails, 275 works ..
    //--- Using shiftOutFast:
    // at 2 Shift Register - 50 fails, 75 works
    latchPinPORTB = latchPin - 8;
    clockPinPORTB = clockPin - 8;
    dataPinPORTB = dataPin - 8;

    digitalWrite(latchPin,LOW);
    digitalWrite(dataPin,LOW);
    digitalWrite(clockPin,LOW);
    byte clr;
    SPCR |= ( (1<<SPE) | (1<<MSTR) ); // enable SPI as master
    //SPCR |= ( (1<<SPR1) | (1<<SPR0) ); // set prescaler bits
    SPCR &= ~( (1<<SPR1) | (1<<SPR0) ); // clear prescaler bits
    clr=SPSR; // clear SPI status reg
    clr=SPDR; // clear SPI data reg
    SPSR |= (1<<SPI2X); // set prescaler bits
    //SPSR &= ~(1<<SPI2X); // clear prescaler bits
    delay(10); 
  }

  void iProcess(byte data1, byte data2){
    //--- This code can run using a 20 timer delay! :)
    latchOff();     
    //spi_transfer(data2); 
    //spi_transfer(data1); 
    shiftOutFast(dataPin,clockPin,data2); 
    shiftOutFast(dataPin,clockPin,data1);    
    latchOn();
  }

  //--- shiftOutFast - Shiftout method done in a faster way .. needed for tighter timer process
  void shiftOutFast(int myDataPin, int myClockPin, byte myDataOut) {
    //=== This function shifts 8 bits out MSB first much faster than the normal shiftOut function by writing directly to the memory address for port
    //--- clear data pin
    dataOff();

    //Send each bit of the myDataOut byte MSBFIRST
    for (int i=7; i>=0; i--)  {
      clockOff();
      //--- Turn data on or off based on value of bit
      if ( bitRead(myDataOut,i) == 1) {
        dataOn();
      }
      else {      
        dataOff();
      }
      //register shifts bits on upstroke of clock pin  
      clockOn();
      //zero the data pin after shift to prevent bleed through
      dataOff();
    }
    //stop shifting
    digitalWrite(myClockPin, 0);
  }

  void dataOff(){
    bitClear(PORTB,dataPinPORTB);
  }

  void clockOff(){
    bitClear(PORTB,clockPinPORTB);
  }

  void clockOn(){
    bitSet(PORTB,clockPinPORTB);
  }

  void dataOn(){
    bitSet(PORTB,dataPinPORTB);
  }

  void latchOn(){
    bitSet(PORTB,latchPinPORTB);
  }

  void latchOff(){
    bitClear(PORTB,latchPinPORTB);
  }
  /*
  byte spi_transfer(byte data)
   {
   SPDR = data;            // Start the transmission
   loop_until_bit_is_set(SPSR, SPIF); 
   return SPDR;                    // return the received byte, we don't need that
   }
   */
  // classic shiftOut -----------------------------------------------------
  void sendValuesToShifOut(byte data1, byte data2){

    // clear registers
    digitalWrite(latchPin, 0);
    setShiftOut(dataPin, clockPin, 0x00);   
    setShiftOut(dataPin, clockPin, 0x00);
    digitalWrite(latchPin, 1);

    //ground latchPin and hold low for as long as you are transmitting
    digitalWrite(latchPin, 0);
    //move 'em out
    setShiftOut(dataPin, clockPin, data2);   
    setShiftOut(dataPin, clockPin, data1);
    //return the latch pin high to signal chip that it 
    //no longer needs to listen for information
    digitalWrite(latchPin, 1);
  }

  void setShiftOut(int myDataPin, int myClockPin, byte myDataOut){
    // This shifts 8 bits out MSB first, 
    //on the rising edge of the clock,
    //clock idles low

    //internal function setup
    int i=0;
    int pinState;
    //pinMode(myClockPin, OUTPUT);
    //pinMode(myDataPin, OUTPUT);

    //clear everything out just in case to
    //prepare shift register for bit shifting
    digitalWrite(myDataPin, 0);
    digitalWrite(myClockPin, 0);

    //for each bit in the byte myDataOut
    //NOTICE THAT WE ARE COUNTING DOWN in our for loop
    //This means that %00000001 or "1" will go through such
    //that it will be pin Q0 that lights. 
    for (i=7; i>=0; i--)  {
      digitalWrite(myClockPin, 0);

      //if the value passed to myDataOut and a bitmask result 
      // true then... so if we are at i=6 and our value is
      // %11010100 it would the code compares it to %01000000 
      // and proceeds to set pinState to 1.
      if ( myDataOut & (1<<i) ) {
        pinState= 1;
      }
      else {	
        pinState= 0;
      }

      //Sets the pin to HIGH or LOW depending on pinState
      digitalWrite(myDataPin, pinState);

      //register shifts bits on upstroke of clock pin  
      digitalWrite(myClockPin, 1);
    }

    //stop shifting
    digitalWrite(myClockPin, 0);
  }

#endif
};
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
class encoders{
private:
  // digital pins
  int encoder0PinA;
  int encoder0PinB;
  int encoder0PinC;
  int encoder0PinALast;
  int encoder0PinBLast;
  int encoder0PinCLast;
  String directionEncoders;
  String lastDirectionEncoders;
  int headDirectionAverage;
public:
  String _8segmentEncoder;   
  String last8segmentEncoder;
  int segmentPosition;
  int encoder0Pos;
  int lastEncoder0Pos;
  int headDirection;
  encoders(){
#ifdef arduinoTypeUNO
    encoder0PinA = 2;
    encoder0PinB = 3;
    encoder0PinC = 4;
#endif
#ifdef arduinoTypeDUE
    encoder0PinA = 2;
    encoder0PinB = 3;
    encoder0PinC = 4;
#endif
    headDirection = 0;
    encoder0Pos = -1000;
    lastEncoder0Pos = -1;
    segmentPosition = -1;
    _8segmentEncoder = "";
    last8segmentEncoder = "";
    lastDirectionEncoders = "";
    headDirectionAverage = 0;
  }

  ~encoders(){
  }

  void setup(){
    pinMode(encoder0PinA,INPUT);
    pinMode(encoder0PinB,INPUT);
    pinMode(encoder0PinC,INPUT);
  }

  void loop(){
    directionEncoders = "";
    if(digitalRead(encoder0PinA)== HIGH){ 
      directionEncoders += "ON"; 
    }
    else{ 
      directionEncoders += "OFF"; 
    }
    directionEncoders += "-";
    if(digitalRead(encoder0PinB)== HIGH){ 
      directionEncoders += "ON"; 
    }
    else{ 
      directionEncoders += "OFF"; 
    }
    last8segmentEncoder = _8segmentEncoder;
    _8segmentEncoder = "";
    if(digitalRead(encoder0PinC)== HIGH){ 
      _8segmentEncoder += "ON"; 
    }
    else{ 
      _8segmentEncoder += "OFF"; 
    }
    //directionEncoders +=_8segmentEncoder;
    // head direction
    if(lastDirectionEncoders!=directionEncoders){
      if( 
      (lastDirectionEncoders=="OFF-OFF" && directionEncoders=="OFF-OFF") || 
        (lastDirectionEncoders=="OFF-OFF" && directionEncoders=="ON-OFF") || 
        (lastDirectionEncoders=="ON-OFF" && directionEncoders=="ON-ON") || 
        (lastDirectionEncoders=="ON-ON" && directionEncoders=="OFF-ON") || 
        (lastDirectionEncoders=="OFF-ON" && directionEncoders=="OFF-OFF") 
        ){
        headDirectionAverage +=1;
        //Serial.println(directionEncoders+"-Left");
        if((encoder0Pos != -1000) && (encoder0Pos/4 > -31)){
          encoder0Pos--;
        }
      }
      else if( 
      (lastDirectionEncoders=="OFF-ON" && directionEncoders=="ON-ON") || 
        (lastDirectionEncoders=="ON-ON" && directionEncoders=="ON-ON") || 
        (lastDirectionEncoders=="ON-ON" && directionEncoders=="ON-OFF") || 
        (lastDirectionEncoders=="ON-OFF" && directionEncoders=="OFF-OFF") || 
        (lastDirectionEncoders=="OFF-OFF" && directionEncoders=="OFF-ON") 
        ){
        headDirectionAverage -=1;
        //Serial.println(directionEncoders+"-Right");
        if((encoder0Pos != -1000) && (encoder0Pos/4 < 231)){
          encoder0Pos++;
        }
      }
    }

    // know when head changer from one 8 knidles segment 
    if(_8segmentEncoder!=last8segmentEncoder ){ 
      //
      if(headDirectionAverage>2){
        headDirection =+1;
        //Serial.println("d:+1");
      }
      else if(headDirectionAverage<-2){
        headDirection =-1;
        //Serial.println("d:-1");
      }
      else{
        headDirection = headDirection*-1;
        //Serial.println("change direction"+String(headDirection));
      }
      headDirectionAverage = 0;
      segmentPosition +=headDirection;
      //encoder0Pos = segmentPosition*8;
      /*
       Serial.print(",s,");
       Serial.print(headDirection);
       Serial.print(",");
       Serial.print(segmentPosition);
       Serial.println(",e,");
       */
    }
    lastDirectionEncoders = directionEncoders;

  }
};
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
class soundAlerts{
private:
  // analog pin
  int piezoPin;
public:
  soundAlerts(){
  }
  ~soundAlerts(){
  }

  void setup(){
    piezoPin = 3;
  }

  void startMachine(){
    int delayms = 50;
    for(int i=0;i<3;i++){
      analogWrite(piezoPin, 20);      // Almost any value can be used except 0 and 255
      // experiment to get the best tone
      delay(delayms);          // wait for a delayms ms
      analogWrite(piezoPin, 0);       // 0 turns it off
      delay(delayms);          // wait for a delayms ms 
    }
  }

  void endPattern(){
    int delayms = 50;
    for(int i=0;i<5;i++){
      analogWrite(piezoPin, 20);      // Almost any value can be used except 0 and 255
      // experiment to get the best tone
      delay(delayms);          // wait for a delayms ms
      analogWrite(piezoPin, 0);       // 0 turns it off
      delay(delayms);          // wait for a delayms ms 
    }
  }
};
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
class endLines{
private:
  soundAlerts* mySoundAlerts;
  // analog arduino pin
  int endLineLeftAPin;
  int endLineRightAPin;
  int * encoderPos; 
  int filterValueLeftMin;
  int filterValueRightMin;
  int filterValueLeftMax;
  int filterValueRightMax;
  int lastLeft;
  int lastRight;
  int maxLeft;
  int maxRight;
public:
  boolean started;
  int * segmentPosition;
  int row;
  endLines(){
  }
  ~endLines(){
  }

  void setup(){
    maxLeft = 0;
    maxRight= 0;
    endLineLeftAPin = 1;
    endLineRightAPin = 0;
    filterValueLeftMin = 10;
    filterValueRightMin = 10;
    filterValueLeftMax = 730;
    filterValueRightMax = 730;
    row = 0;
    started = false;
  }

  void setPosition(int * _encoderPos, int * _segmentPosition, soundAlerts* _mySoundAlerts){
    encoderPos = _encoderPos;
    segmentPosition = _segmentPosition;
    mySoundAlerts = _mySoundAlerts;
  }

  void loop(){
    int valueEndLineLeft = analogRead(endLineLeftAPin);
    int valueEndLineRight = analogRead(endLineRightAPin);
    /*
    if(maxLeft<=valueEndLineLeft){ 
     maxLeft = valueEndLineLeft; 
     //Serial.println(maxLeft);
     }
     
     if(maxRight<valueEndLineRight){ 
     maxRight = valueEndLineRight; 
     //Serial.println(maxRight);
     }
     */
    if( analogRead(endLineLeftAPin) <filterValueLeftMin || analogRead(endLineLeftAPin) >filterValueLeftMax){ 
      if(!lastLeft){
        *encoderPos = 200*4;
        *segmentPosition = 25;
        started = true;
      }
      lastLeft = true;
    }
    else{
      lastLeft = false;
    }

    if( valueEndLineRight <filterValueRightMin || analogRead(endLineRightAPin) >filterValueRightMax){
      if(!lastRight){
        *encoderPos = 0;
        *segmentPosition = 1;
        //Serial.print("inside right:");
        //Serial.print("change encoder0Pos:");
        //Serial.println(*encoderPos);
        started = true;
      }
      lastRight = true;
    }
    else{
      lastRight = false;
    }
  }

};
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
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
      32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1                };
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

  void setSolenoids(){
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

  // get data from processing
  void receiveSerialFromComputer(){
    if (Serial.available() > 0) {
      char buffer[2];
      Serial.readBytesUntil(',', &buffer[0], 4);
      received = 0;
      received = buffer[0] <<8;
      received = received | buffer[1];
      setSolenoids();
    }
  }

};
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
// class declaration
encoders myEncoders;
endLines myEndlines;
solenoids mysolenoids;
soundAlerts mySoundAlerts;
communication myCommunicator;
int patternLine[200];

void setup()
{ 
  Serial.begin(115200);
  mySoundAlerts.setup();
  mysolenoids.setup();
  myEncoders.setup();
  myEndlines.setup();
  myEndlines.setPosition(&myEncoders.encoder0Pos, &myEncoders.segmentPosition, &mySoundAlerts);
  myCommunicator.setup(&myEncoders,&myEndlines,&mysolenoids);
  myCommunicator._status = "o";
} 

void loop() {
  // receive solenoids from computer
  myCommunicator.receiveSerialFromComputer();
  mysolenoids.loop();
  // get data from sensors and send to computer
  myEncoders.loop();
  myEndlines.loop();
  myCommunicator.sendSerialToComputer();
} 





























