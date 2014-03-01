//Test of 

int signalPin1 = 3;
int signalPin2 = 4;
int signalPin3 = 5;

void setup()
{
  pinMode(signalPin1, INPUT);
  pinMode(signalPin2, INPUT);
  pinMode(signalPin3, INPUT);
  Serial.begin(9600);
}

void loop(){
  if(digitalRead(signalPin1)){
    Serial.println("A:ON");
  }else{
    Serial.println("A:OFF");
  }
  
  if(digitalRead(signalPin2)){
    Serial.println("B:ON");
  }else{
    Serial.println("B:OFF");
  }
  
  if(digitalRead(signalPin3)){
    Serial.println("C:ON");
  }else{
    Serial.println("C:OFF");
  }
  
}
