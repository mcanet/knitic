const int totalArrayFromSolenoid = 16;

byte solenoidPinsArray[totalArrayFromSolenoid] = 
{
  22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23};
  
byte statusSolenoidArray[totalArrayFromSolenoid] = 
{
  1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

int inByte = 0;

void setup(){
  for(int i=0; i<16; i++){
    pinMode(solenoidPinsArray[i], OUTPUT);
  }
    Serial.begin(115200);
      for(int i=0; i<16; i++){
    digitalWrite(solenoidPinsArray[i],  1);
  }
  while (! Serial);
  Serial.println("Solenoid 1 to 16");
}

void loop(){
  if(Serial.available()) {
    // get incoming byte:
    inByte = Serial.parseInt();
    if (inByte>0)  Serial.println(inByte); 
    else inByte = 18;
  }
  digitalWrite(solenoidPinsArray[inByte-1],  0);
  delay(500);
  digitalWrite(solenoidPinsArray[inByte-1],  1);
}
