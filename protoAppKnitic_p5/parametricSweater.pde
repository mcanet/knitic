
class parametricSweater {

  PShape s;
  float factor = 1;
  float factorX = 0.8;
  float factorY = 1;
  float alt =  380;
  float ample = 260;
  float maniga = 100;
  float llargM = 410;
  float collAmple = 100;
  float collAlt = 0;
  float sisa = 160;
  float sisaMarge = 10;
  int dif = 10;
  PImage img;
  float widthSweater;
  float heightSweater;

  public parametricSweater() {
  }

  void jersei(float alt, float ample, float maniga, float collAmple, float collAlt, float llargM, float sisa) {
    float marge = 0; 
    float base = alt;
    int agulla = 5;
    float halfAmple = ample*0.5;
    sisaMarge = sisa*0.4;
    fill(#1783BC);
    noStroke();
    s = createShape();
    s.beginShape(); 
    s.vertex((collAmple*0.5)*factorX, 0);
    s.vertex((halfAmple+maniga)*factorX, sisa-sisaMarge*factorY);
    s.vertex((halfAmple+maniga)*factorX, llargM*factorY);
    s.vertex((halfAmple+agulla)*factorX, llargM*factorY); 
    s.vertex((halfAmple+agulla)*factorX, sisa*factorY);
    s.vertex(halfAmple*factorX, sisa*factorY);
    s.vertex(halfAmple*factorX, alt*factorY);
    s.vertex(-halfAmple*factorX, alt*factorY);
    s.vertex(-halfAmple*factorX, sisa*factorY);
    s.vertex((-halfAmple-agulla)*factorX, sisa*factorY);
    s.vertex((-halfAmple-agulla)*factorX, llargM*factorY);
    s.vertex((-halfAmple-maniga)*factorX, llargM*factorY);
    s.vertex((-halfAmple-maniga)*factorX, sisa-sisaMarge*factorY);
    s.vertex((-collAmple*0.5)*factorX, 0);
    s.endShape(CLOSE);
    
    widthSweater = ((halfAmple+maniga)*factorX *2);
    if((alt*factorY) >(llargM*factorY)){
      heightSweater = (alt*factorY);
    }else{
      heightSweater = (llargM*factorY);
    }
    // save image
    createPixelPattern();
  }

  void L() {
    jersei(alt, ample, maniga, collAmple, collAlt, llargM, sisa);
  }

  void ML() {
    jersei(alt-dif, ample-dif, maniga-dif, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
  }

  void M() {
    dif= dif*2;
    jersei(alt-dif, ample-dif, maniga-dif/2, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
    dif = 10;
  }

  void SM() {
    dif= dif*3;
    jersei(alt-dif, ample-dif, maniga-dif/2, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
    dif = 10;
  }

  void S() {
    dif= dif*4;
    jersei(alt-dif, ample-dif, maniga-dif/2, collAmple-dif, collAlt-dif, llargM-dif, sisa-dif);
    dif = 10;
  }

  void createPixelPattern() {
    PGraphics buffer = createGraphics(int(widthSweater), int(heightSweater), JAVA2D);
    img = new PImage(int(widthSweater), int(heightSweater));
    buffer.shape(s, (widthSweater/2), 0);
    img = buffer.get(0, 0, buffer.width, buffer.height);
    img.updatePixels();
  }
}

void setupSweater() {
  ns = new parametricSweater();
  ns.S();
}

void drawSweater() {
  pushMatrix();
  translate(530, 0);
  //shape(ns.s, 0, 0);
  noFill();
  stroke(255,0,0);
  rect(-ns.widthSweater/2,0,ns.widthSweater,ns.heightSweater);
  image(ns.img,-ns.widthSweater/2,0);
  fill(0);
  //
  line(-300,0,300,0);
  line(0,0,0,400);
  popMatrix();
}

void saveSweaterAsInputImage() {
  fillArrayWithImage(ns.img);
  println(ns.img.height);
}
