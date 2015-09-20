
int lastTimeMove_openKnit;
int direction_openKnit=1;
// continue to move the bed when no connexion
void drawOpenKnit(){
  if(millis()-lastTimeMove_openKnit>100){
    stitch += direction_openKnit;
    if(stitch>200){
      direction_openKnit = direction_openKnit*-1;
    }
    if(stitch<0){
      direction_openKnit = direction_openKnit*-1;
    }
    lastTimeMove_openKnit = millis();
  }
}
