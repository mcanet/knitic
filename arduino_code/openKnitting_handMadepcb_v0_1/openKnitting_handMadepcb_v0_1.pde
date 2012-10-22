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
    int dataSector1;
    int dataSector2;
    int dataArray1[8];
    int dataArray2[8];
    int dataArraypos1[8]; 
    int dataArraypos2[8]; 
    
    //Pin connected to ST_CP of 74HC595
    int latchPin;
    //Pin connected to SH_CP of 74HC595
    int clockPin;
    //Pin connected to DS of 74HC595
    int dataPin;
    
  public:
    boolean selenoidState[16];
    String _16selenoids;
    selenoids(){
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
      
      _16selenoids = "0110101010101011";

      //set pins to output because they are addressed in the main loop
      pinMode(latchPin, OUTPUT);
      
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
        selenoidState[i] = true;
      }
    }
    
    void loop(){
      Serial.write("loop_selenoids\n");
      dataSector1 = 0x00;
      dataSector2 = 0x00;
      
      for (int j = 0; j < 8; ++j) {
        //load the light sequence you want from array
        if(selenoidState[j]==true){
          dataSector1 = dataSector1 ^ dataArray1[dataArraypos1[j]];
        }
        if(selenoidState[j+8]==true){
          dataSector2 = dataSector2 ^ dataArray2[dataArraypos2[j]];
        }  
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
                        //directionEncoders += "-";
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
  soundAlerts* mySoundAlerts;
  // analog arduino pin
  int endLineLeftAPin;
  int endLineRightAPin;
  int * encoderPos; 
  int filterValue;
  int lastLeft;
  int lastRight;
public:
  int * segmentPosition;
  int row;
  endLines(){}
  ~endLines(){}
  
  void setup(){
     endLineLeftAPin = 0;
     endLineRightAPin = 1;
     filterValue = 760;
     row = 0;
  }
  
  void setPosition(int * _encoderPos, int * _segmentPosition, soundAlerts* _mySoundAlerts){
    encoderPos = _encoderPos;
    segmentPosition = _segmentPosition;
    mySoundAlerts = _mySoundAlerts;
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
private:
  encoders* myEncoders;
  endLines* myEndlines;
  selenoids* mySelenoids;
  int* rowEnd;
  String* _status;
  char buf[24];
public:
   communication(){}
   ~communication(){}
   
   void setup(encoders* _myEncoders, endLines* _myEndlines, selenoids* _mySelenoids,int* _rowEnd, String* __status){
     myEncoders = _myEncoders;
     myEndlines = _myEndlines;
     mySelenoids = _mySelenoids;
     _status = __status;
     rowEnd = _rowEnd;
   }
   
   void loop(){
     //sendSerialToComputer();
     receiveSerialFromComputer();
   }
   
   // send data to OF
   void sendSerialToComputer(){
    Serial.print("-s-");
    Serial.print(myEncoders->segmentPosition);
    Serial.print("-");
    Serial.print(myEndlines->row);
    Serial.print("-");
    Serial.print(*rowEnd);
    Serial.print("-");
    Serial.print(mySelenoids->_16selenoids);
    Serial.print("-");
    Serial.print(*_status);
    Serial.println("-e-");
  }
  
  // get data from OF
  void receiveSerialFromComputer(){
    //if(myEncoders->encoder0Pos==-1) return;
    GetString(buf, sizeof(buf));
    
    int start = -1;
    int _end  = -1;
    
    // look for start inside string received
    for(int i=0;i<sizeof(buf);i++){
        if(buf[i]=='s'){
            start =i;
            break;
        }
    }
    
    // look for end inside string received
    for(int i=sizeof(buf);i>0;i--){
        if(buf[i]=='e'){
            _end =i;
            break;
        }
    }
    
    if(start!=-1 && _end!=-1 )
    {
        Serial.write("found\n");
        bool foundStart = false; 
        int id =0;
        char * pch;
        pch = strtok (buf," ,.-");
        while (pch != NULL)
        {
            if(foundStart)  id +=1;
            if( pch != NULL && *pch=='s') foundStart = true;
            // get selenoids
            if(id==1){
                //printf ("int:%s\n",pch);
                for(int i=0; i<16;i++){
                    if(pch[i]=='0'){
                        mySelenoids->selenoidState[i] = false;
                    }else{
                        mySelenoids->selenoidState[i] = true;
                    }
                }
            }
            // get status
            if(id=2){
               _status = *pch;
            }
            pch = strtok(NULL, " ,.-");
        }
        
    }

  }
  
  void GetString(char *buf, int bufsize)
  {
      int i;
      for (i=0; i<bufsize; ++i){
          while(Serial.available() == 0);
          buf[i] = Serial.read();
          // stay until we found start message
          if(buf[i] == 's'){
            buf[0] = '-';
            buf[1] = 's';
            i=1; 
          }
          if(buf[i] == 'e') break;// is it the terminator byte?
      }
      for (i=0; i<bufsize; ++i){
        Serial.write(buf[i]);
      }
      Serial.flush();
      Serial.write("received\n");
  }
};
//---------------------------------------------------------------------------------
// class declaration
encoders myEncoders;
endLines myEndlines;
selenoids mySelenoids;
soundAlerts mySoundAlerts;
communication myCommunicator;

//int val;
int rowEnd;
String _status;
byte myDataOut;

void setup()
{ 
  //mySoundAlerts.setup();
  mySelenoids.setup();
  //myEncoders.setup();
  //myEndlines.setup();
  //myEndlines.setPosition(&myEncoders.encoder0Pos, &myEncoders.segmentPosition, &mySoundAlerts);
  myCommunicator.setup(&myEncoders,&myEndlines,&mySelenoids, &rowEnd, &_status);
  Serial.begin(9600);
} 

void loop() {
  //mySoundAlerts.loop();
  //myEncoders.loop();
  //myEndlines.loop();
  myCommunicator.loop();
  mySelenoids.loop();
  delay(100);
} 




