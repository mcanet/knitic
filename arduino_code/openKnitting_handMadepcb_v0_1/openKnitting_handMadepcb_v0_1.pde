 /*
 *
 * OPEN KNITTING
 * @Description: Code for open source machine
 * @Authors: Mar Canet & Varvara Guljajeva 
 * @Versions:0.1v 
 *
 */

//---------------------------------------------------------------------------------
// Controled by Toshiva
class selenoids{
  private:	
    byte dataSector1;
    byte dataSector2;
    byte dataArray1[8];
    byte dataArray2[8];
    byte dataArraypos1[8]; 
    byte dataArraypos2[8];  
    
    boolean selenoidState[16];
    
    //Pin connected to ST_CP of 74HC595
    int latchPin;
    //Pin connected to SH_CP of 74HC595
    int clockPin;
    //Pin connected to DS of 74HC595
    int dataPin;
  public:
    selenoids(){
      //Pin connected to SH_CP of 74HC595
      latchPin = 8;
      //Pin connected to SH_CP of 74HC595
      clockPin = 12;
      //Pin connected to DS of 74HC595
      dataPin = 11;
    }
    
    ~selenoids(){
    }
    
    void setShiftOut(int myDataPin, int myClockPin, byte myDataOut){
      // This shifts 8 bits out MSB first, 
      //on the rising edge of the clock,
      //clock idles low

      //internal function setup
      int i=0;
      int pinState;
      pinMode(myClockPin, OUTPUT);
      pinMode(myDataPin, OUTPUT);

      //clear everything out just in case to
      //prepare shift register for bit shifting
      digitalWrite(myDataPin, 0);
      digitalWrite(myClockPin, 0);

      //for each bit in the byte myDataOut�
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
        }else {	
          pinState= 0;
        }

        //Sets the pin to HIGH or LOW depending on pinState
        digitalWrite(myDataPin, pinState);
        //register shifts bits on upstroke of clock pin  
        digitalWrite(myClockPin, 1);
        //zero the data pin after shift to prevent bleed through
        digitalWrite(myDataPin, 0);
      }

      //stop shifting
      digitalWrite(myClockPin, 0);
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
      Serial.begin(9600);
      
      // 
      dataArraypos1[0] = 0x06;
      dataArraypos1[1] = 0x05;
      dataArraypos1[2] = 0x04;
      dataArraypos1[3] = 0x03;
      dataArraypos1[4] = 0x02;
      dataArraypos1[5] = 0x01;
      dataArraypos1[6] = 0x00;
      dataArraypos1[7] = 0x07;
      
      dataArraypos2[0] = 0x06;
      dataArraypos2[1] = 0x05;
      dataArraypos2[2] = 0x04;
      dataArraypos2[3] = 0x03;
      dataArraypos2[4] = 0x02;
      dataArraypos2[5] = 0x01;
      dataArraypos2[6] = 0x00;
      dataArraypos2[7] = 0x07;

      //Arduino doesn't seem to have a way to write binary straight into the code 
      //so these values are in HEX.  Decimal would have been fine, too. 
      dataArray1[0] = 0x80; //10000000
      dataArray1[1] = 0x40; //01000000
      dataArray1[2] = 0x20; //00100000
      dataArray1[3] = 0x10; //00010000
      dataArray1[4] = 0x08; //00001000
      dataArray1[5] = 0x04; //00000100
      dataArray1[6] = 0x02; //00000010
      dataArray1[7] = 0x01; //00000001


      //Arduino doesn't seem to have a way to write binary straight into the code 
      //so these values are in HEX.  Decimal would have been fine, too. 
      dataArray2[0] = 0x80; //10000000
      dataArray2[1] = 0x40; //01000000
      dataArray2[2] = 0x20; //00100000
      dataArray2[3] = 0x10; //00010000
      dataArray2[4] = 0x08; //00001000
      dataArray2[5] = 0x04; //00000100
      dataArray2[6] = 0x02; //00000010
      dataArray2[7] = 0x01; //00000001

      for(int i=0;i<16;i++){
        selenoidState[i] = false;
      }
    }
    
    void loop(){
      for (int j = 0; j < 8; j++) {
        //load the light sequence you want from array
        dataSector1 = 0x00;
        if(j==selenoidState[j]){
          dataSector1 = dataSector1 ^ dataArray1[int(dataArraypos1[j])];
        }
        if(j==selenoidState[j+8]){
          dataSector2 = dataSector2 ^ dataArray2[int(dataArraypos2[j])];
        }
        //ground latchPin and hold low for as long as you are transmitting
        digitalWrite(latchPin, 0);
        //move 'em out
        setShiftOut(dataPin, clockPin, dataSector2);   
        setShiftOut(dataPin, clockPin, dataSector1);
        //return the latch pin high to signal chip that it 
        //no longer needs to listen for information
        digitalWrite(latchPin, 1);
      }
    }
   
};
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
                String _8segmentEncoder;   
                String last8segmentEncoder;
                
                int headDirection;
	public:
                int segmentPosition;
                int encoder0Pos;
		encoders(){
			encoder0PinA = 2;
			encoder0PinB = 3;
			encoder0PinC = 4;
                        headDirection = 0;
                        encoder0Pos = -1;
                        segmentPosition = -1;
                        _8segmentEncoder = "";
                        last8segmentEncoder = "";
                        lastDirectionEncoders = "";
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
                        if(digitalRead(encoder0PinA)== HIGH){ directionEncoders += "ON"; }else{ directionEncoders += "OFF"; }
                        directionEncoders += "-";
                        if(digitalRead(encoder0PinB)== HIGH){ directionEncoders += "ON"; }else{ directionEncoders += "OFF"; }
                        directionEncoders += "-";
                        _8segmentEncoder = "";
                        if(digitalRead(encoder0PinC)== HIGH){ _8segmentEncoder += "ON"; }else{ _8segmentEncoder += "OFF"; }
                        //directionEncoders +=_8segmentEncoder;
                        // head direction
                        if(lastDirectionEncoders!=directionEncoders){
                          Serial.println(directionEncoders);
                          if( 
                            (lastDirectionEncoders=="OFF-OFF" && directionEncoders=="OFF-OFF") || 
                            (lastDirectionEncoders=="OFF-OFF" && directionEncoders=="ON-OFF") || 
                            (lastDirectionEncoders=="ON-OFF" && directionEncoders=="ON-ON") || 
                            (lastDirectionEncoders=="ON-ON" && directionEncoders=="OFF-ON") || 
                            (lastDirectionEncoders=="OFF-ON" && directionEncoders=="OFF-OFF") 
                          ){
                            headDirection =+1;
                          }else if( 
                            (lastDirectionEncoders=="OFF-ON" && directionEncoders=="ON-ON") || 
                            (lastDirectionEncoders=="ON-ON" && directionEncoders=="ON-ON") || 
                            (lastDirectionEncoders=="ON-ON" && directionEncoders=="ON-OFF") || 
                            (lastDirectionEncoders=="ON-OFF" && directionEncoders=="OFF-OFF") || 
                            (lastDirectionEncoders=="OFF-OFF" && directionEncoders=="OFF-ON") 
                          ){
                            headDirection =-1;
                          }
                        }
                        // know when head changer from one 8 knidles segment 
                        if(_8segmentEncoder!=last8segmentEncoder && segmentPosition != -1){ 
                            segmentPosition +=headDirection;
                            encoder0Pos = segmentPosition*8;
                            Serial.print("Encoder0Pos-");
                            Serial.print(_8segmentEncoder);
                            Serial.print(":");
                            Serial.println(encoder0Pos);
                        }
                        lastDirectionEncoders = directionEncoders;
                        last8segmentEncoder = _8segmentEncoder;
                        
		}

                int getPosition(){
                  return encoder0Pos;
                }
	
};
//---------------------------------------------------------------------------------
class soundAlerts{
private:
  // analog pin
  int piezoPin;
public:
  soundAlerts(){}
  ~soundAlerts(){}
  
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
class endLines{
private:
  // analog arduino pin
  int endLineLeftAPin;
  int endLineRightAPin;
  int * encoderPos;
  int * segmentPosition;
  int filterValue;
  int lastLeft;
  int lastRight;
public:
  endLines(){}
  ~endLines(){}
  
  void setup(){
     endLineLeftAPin = 0;
     endLineRightAPin = 1;
     filterValue = 760;
  }
  
  void setPosition(int * _encoderPos, int * _segmentPosition){
    encoderPos = _encoderPos;
    segmentPosition = _segmentPosition;
  }
  
  void loop(){
     if( analogRead(endLineLeftAPin) > filterValue  ){
       if(!lastLeft){
         *encoderPos = 0;
         *segmentPosition = 0;
         Serial.print("inside left:");
         Serial.print("change encoder0Pos:");
         Serial.println(*encoderPos);
       }
       lastLeft = true;
     }else{
       lastLeft = false;
     }
     
     if( analogRead(endLineRightAPin) > filterValue ){
       if(!lastRight){
         *encoderPos = 200;
         *segmentPosition = 25;
         Serial.print("inside right:");
         Serial.print("change encoder0Pos:");
         Serial.println(*encoderPos);
       }
       lastRight = true;
     }else{
       lastRight = false;
     }
  }
  
};
//---------------------------------------------------------------------------------
class communication{
public:
   communication(){}
   ~communication(){}
};
//---------------------------------------------------------------------------------
// class declaration
encoders myEncoders;
endLines myEndlines;
selenoids mySelenoids;
soundAlerts mySoundAlerts;
communication myCommunicator;

int row;
int val;

byte myDataOut;

//int selenoidPins[16] = {4,5,6,7,8,9,10,11,12,13,14,15,16};
//char state = '';

void setup()
{ 
  //mySoundAlerts.setup();
  //mySelenoids.setup();
  myEncoders.setup();
  myEndlines.setup();
  myEndlines.setPosition(&myEncoders.encoder0Pos, &myEncoders.segmentPosition);
  myEncoders.encoder0Pos = 200;
  Serial.begin(28800);
} 

void loop() {
  //mySoundAlerts.loop();
  //mySelenoids.loop();
  myEncoders.loop();
  myEndlines.loop();
  serialToComputer();
} 

void serialToComputer(){
  /*
  Serial.print("@");
  Serial.print(state);
  Serial.print("|");
  Serial.print(encoder0Pos);
  Serial.print("|");
  Serial.print(row);
  */
}
/*
void endLine(){
  if(analogRead(endLineLeftAPin)){
    encoder0Pos = 0;
  }else if(analogRead(endLineLeftAPin)){
    encoder0Pos = encoderEndPos;
  } 
}
*/



