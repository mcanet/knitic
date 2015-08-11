/*
table encoder position an values id
 OFF_ON  = 0+3 = 3
 ON_OFF  = 1+5 = 6
 ON_ON   = 1+3 = 4
 OFF_OFF = 0+5 = 5 
 */
 
 //left:3,6
// right: 4,5
const int encoder0PinA = 2;
const int encoder0PinB = 3;
const int encoder0PinC = 4; // not used
short directionEncoders;
short lastDirectionEncoders;
void setup() {// put your setup code here, to run once:
    pinMode(encoder0PinA,INPUT);
    pinMode(encoder0PinB,INPUT);
    pinMode(encoder0PinC,INPUT);
    
    Serial.begin(115200);
    directionEncoders = 0;
    lastDirectionEncoders = -1;
}

void loop() {
   directionEncoders = 0;
    if(digitalRead(encoder0PinA)== HIGH){ 
      // directionEncoders is ON for encoder A
      directionEncoders += 1; 
    }
    else{ 
      // directionEncoders is OFF for encoder A
      directionEncoders += 0;  
    }
    if(digitalRead(encoder0PinB)== HIGH){ 
      // directionEncoders is ON for encoder B
      directionEncoders +=3; 
    }
    else{ 
      // directionEncoders is OFF for encoder B
      directionEncoders +=5;
    } 
    
    // print when is different
    if(lastDirectionEncoders != directionEncoders){
      lastDirectionEncoders = directionEncoders;
      Serial.println(directionEncoders);
    }
    
   
}
