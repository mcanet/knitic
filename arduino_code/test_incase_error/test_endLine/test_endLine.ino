int endLineLeftAPin = 1;
int endLineRightAPin = 0;

void setup(){
  Serial.begin(115200);
}

void loop(){
  int valueEndLineLeft  = analogRead(endLineLeftAPin);
  int valueEndLineRight = analogRead(endLineRightAPin);
  Serial.print(valueEndLineLeft);
  Serial.print("-");
  Serial.println(valueEndLineRight);
}
