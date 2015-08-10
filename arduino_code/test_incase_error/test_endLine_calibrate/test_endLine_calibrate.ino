int endLineLeftAPin = 1;
int endLineRightAPin = 0;

int maxL = 0;
int minL = 9999;
int maxR = 0;
int minR = 9999;

void setup(){
  Serial.begin(115200);
}

void loop(){
  int valueEndLineLeft  = analogRead(endLineLeftAPin);
  int valueEndLineRight = analogRead(endLineRightAPin);
  // getting data left max-min
  if(valueEndLineLeft>maxL){
    maxL=valueEndLineLeft;
  }
  if(valueEndLineLeft<minL){
    minL=valueEndLineLeft;
  }
  // getting data right max-min
  if(valueEndLineRight>maxR){
    maxR=valueEndLineRight;
  }
  if(valueEndLineRight<minR){
    minR=valueEndLineRight;
  }
  Serial.print("valueL:");
  Serial.print(valueEndLineLeft);
  Serial.print(" | maxL:");
  Serial.print(maxL);
  Serial.print(" | minL:");
  Serial.print(minL);
  Serial.print("-");
  Serial.print("valueR:");
  Serial.print(valueEndLineRight);
  Serial.print(" | maxR:");
  Serial.print(maxR);
  Serial.print(" | minR:");
  Serial.println(minR);
}


