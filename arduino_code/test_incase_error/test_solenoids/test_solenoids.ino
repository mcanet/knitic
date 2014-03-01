const int totalArrayFromSelenoids = 16;

short amegaPinsArray[totalArrayFromSelenoids] = 
{
  22,24,26,28,30,32,34,36,37,35,33,31,29,27,25,23};


void setup(){
  for(int i=0; i<16; i++){
    pinMode(amegaPinsArray[i], OUTPUT);
  }
}

void loop(){
   for(int i=0; i<16; i++){
    digitalWrite(amegaPinsArray[i],  HIGH);
  }
  delay(1); 
}
