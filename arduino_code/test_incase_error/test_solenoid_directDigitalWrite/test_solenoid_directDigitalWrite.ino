int amegaPinsArray[16];

void setup() {
  int amegaPinsArrayTemp[16] = {
    37,35,33,31,29,27,25,23,22,24,26,28,30,32,34,36        
  };                                      
  // put your setup code here, to run once:
  for(int i=0; i<16; i++){
    amegaPinsArray[i] = amegaPinsArrayTemp[i];
    pinMode(amegaPinsArray[i], OUTPUT);
    digitalWrite(amegaPinsArray[i], LOW);
  }
  
  digitalWrite(amegaPinsArray[0], HIGH);
}

void loop() {
 
}

