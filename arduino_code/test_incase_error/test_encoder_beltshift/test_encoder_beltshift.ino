const int enc1 = 2;
const int enc2 = 3;
const int enc3 = 4;
const int LEnd = 1;   //endLineLeft for analog in
const int REnd = 0;   //endLineRight for analog in

boolean enc2State;

int leftEndLine = 0;       //left end switch value  
int rightEndLine = 0;      //right end switch value
int  lastEndLine = -1;  
int beltShift = 0;

int pos = 0;
int lastPos = 0;
int carDirection = 0;  //direction of carriage　0:unknown　1:right　2:left
const byte totalArrayFromSolenoid =16;
byte solenoidPinsArray[totalArrayFromSolenoid] = 
{
  22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23};
  
byte statusSolenoidArray[totalArrayFromSolenoid] = 
{
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  
void setup() {
  for(int i=0; i<16; i++){
    pinMode(solenoidPinsArray[i], OUTPUT);
  }
  attachInterrupt(enc1, rotaryEncodeHIGH, RISING);
  Serial.begin(115200);
}

void loop() {
  /*
  if(pos !=lastPos){
    Serial.print("pos:");
    Serial.print(pos);
    Serial.print(" | enc3:");
    Serial.println(digitalRead(enc3) ? "0" : "1");
    lastPos = pos;
  }
  */
  
  leftEndLine = (analogRead(LEnd) > 475) ? 1 : 0;
  rightEndLine = (analogRead(REnd) > 475) ? 1 : 0;
  
  //Serial.println(lastEndLine);
  if(leftEndLine && lastEndLine!=0 && carDirection == 2 ){
    beltShift = digitalRead(enc3) ? 1 : 0; // regular = 0 , shifted=1
    Serial.print("left ");
    lastPos = pos;
    debugEndOfLine();
    lastEndLine = 0;
  }
   
  if(rightEndLine && lastEndLine!=1 && carDirection == 1 ){
    beltShift = digitalRead(enc3) ? 0 : 1; // regular = 0 , shifted=1
    Serial.print("right ");
    lastPos = pos;
    debugEndOfLine();
    lastEndLine = 1;
  } 
  
  setSolenoids();
}

void debugEndOfLine(){
  Serial.print(" | enc3:");
  Serial.print(digitalRead(enc3) ? "0" : "1");
  Serial.print("| beltShift:");
  Serial.print(beltShift);
  Serial.print(beltShift?" regular" : " shifted");
  Serial.print(" | pos:");
  Serial.println(pos);
}

void rotaryEncodeHIGH(){
  enc2State = digitalRead(enc2);
  if(!enc2State) {
    pos++;
    carDirection = 1;
  }else if(enc2State){
    pos--;
    carDirection = 2;
  }
}

void setSolenoids(){
  for(int i=0; i<16; i++){
    digitalWrite(solenoidPinsArray[i],  statusSolenoidArray[i]);
  }
  delay(1);
}






