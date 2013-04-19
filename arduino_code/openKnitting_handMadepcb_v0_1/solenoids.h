//---------------------------------------------------------------------------------
// SOLENOIDS
//---------------------------------------------------------------------------------
// Controled by Toshiva

#ifndef SOLENOIDS_H_
#define SOLENOIDS_H_

#include "arduino.h"
#include "encoders.h"

class solenoids{
private:
  encoders* myEncoders;
#ifdef arduinoTypeUNO
  //int dataArray[8];
  //int dataArraypos[8];
#endif
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
#ifdef arduinoTypeUNO
  int dataSector1;
  int dataSector2;
#endif  
  boolean changedsolenoids;
  boolean solenoidstate[16];
  String _16solenoids;
  solenoids(){
    changedsolenoids = true;
#ifdef arduinoTypeDUE  
    int ledArrayTemp[totalArrayFromSelenoids] =       {
      38,40,42,44,46,48,50,52,39,41,43,45,47,49,51,53                                            };
    int amegaPinsArrayTemp[totalArrayFromSelenoids] = {
      22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23                                            };
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
  
  boolean isCurrentStich(int i){
    int stitch = myEncoders->encoder0Pos;
    int headDirection = myEncoders->headDirection;
    return (  (stitch<=176 && stitch>=-24 && headDirection==-1) && ((stitch+7+(i*headDirection))%16)==0 ) || ( (stitch>=24 && stitch<=224 &&  headDirection==1)  && ((stitch+8-(i*headDirection))%16)==0 );
  }

  void setup(encoders* _myEncoders){
    myEncoders = _myEncoders;
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
#ifdef arduinoTypeUNO
    /*
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
    */
#endif
#ifdef arduinoTypeDUE
      for(int i=0;i<16;i++){
      solenoidstate[i] = (_16solenoids[i] != '0');
      solenoidstateChanged[i] = true;
    }
#endif
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
      /*
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
      */
      sendValuesToShifOut(dataSector1, dataSector2);//classic ShiftOut
      //iProcess(dataSector1, dataSector2);// fast ShiftOut
#endif
      lastArrayWrite = millis();
    }
  }

#ifdef arduinoTypeDUE
  
  void setArduinoMegaPins(){
    for(int i=0;i<16;i++){
      if( solenoidstateChanged[i]==true || myEncoders->encoder0Pos != myEncoders->lastEncoder0Pos){ 
        if(isCurrentStich(i) && solenoidstate[i]==true )
        {                      // right
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
  
  /*
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
  */
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
#endif

