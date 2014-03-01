int stitch =0;
int headDirection = 1;
int phase =1;
unsigned long long lastSendTimeStamp;
char lf = '@';

void setup(){
  Serial.begin(115200);
}

void loop(){
  if( (millis()-lastSendTimeStamp)>50 ){ 
    stitch +=headDirection; 
    if(stitch>255 || stitch<0){ 
      headDirection = (headDirection*-1); 
      stitch +=headDirection; 
    }  
    sendSerialToComputer();
    lastSendTimeStamp = millis();
  }
}

void sendSerialToComputer(){

  
  Serial.print(",");
  Serial.print(stitch);
  Serial.print(",");
  Serial.print(headDirection);
  Serial.print(",");
  if(phase){
    Serial.print("1");
  }
  else{
    Serial.print("0");
  }
  Serial.println(lf);
}

