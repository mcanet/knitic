
class parametricSweater {
  PShape s;
  float factor = 1;
  float factorX = 0.8;
  float factorY = 1;
  float alt =  160;//160
  float ample = 80;//80
  float maniga = 25;//25
  float llargM = 190 ;//190
  float collAmple = 39;
  float collAlt = 70; // no la faig servir
  float sisa = 0;
  float sisaMarge =0; 

  int dif = 10;
  PImage img;
  float widthSweater;
  float heightSweater;

  public parametricSweater() {
  }

  void generateSweater() {
    S();
  }

  void jersei(float alt, float ample, float maniga, float collAmple, float collAlt, float llargM, float sisa) {
    float agulla = 5;
    float halfAmple = ample*0.5;
    sisa = collAlt*0.5;
    sisaMarge = sisa*0.5;
    fill(255);
    noStroke();
    s = createShape();
    s.beginShape(); 
    s.vertex((collAmple*0.5)*factorX, 0);
    s.vertex((halfAmple+agulla+maniga)*factorX, (sisa-sisaMarge)*factorY);
    s.vertex((halfAmple+agulla+maniga)*factorX, llargM*factorY);
    s.vertex((halfAmple+agulla)*factorX, llargM*factorY); 
    s.vertex((halfAmple+agulla)*factorX, sisa*factorY);
    s.vertex(halfAmple*factorX, sisa*factorY);
    s.vertex(halfAmple*factorX, alt*factorY);
    s.vertex(-halfAmple*factorX, alt*factorY);
    s.vertex(-halfAmple*factorX, sisa*factorY);
    s.vertex((-halfAmple-agulla)*factorX, sisa*factorY);
    s.vertex((-halfAmple-agulla)*factorX, llargM*factorY);
    s.vertex((-halfAmple-agulla-maniga)*factorX, llargM*factorY);
    s.vertex((-halfAmple-agulla-maniga)*factorX, (sisa-sisaMarge)*factorY);
    s.vertex((-collAmple*0.5)*factorX, 0);
    s.endShape(CLOSE);

    widthSweater = (ample+(maniga*2));
    if ((alt) >(llargM)) {
      heightSweater = alt;
    }
    else {
      heightSweater = llargM;
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
    PGraphics buffer = createGraphics(int(widthSweater), int(heightSweater), P2D);
    img = new PImage(int(widthSweater), int(heightSweater));
    //buffer.shape(s, (widthSweater/2), 0);
    shape(s, (widthSweater/2), 0);
    img = buffer.get(0, 0, buffer.width, buffer.height);
    img.updatePixels();
  }
}

//------------------------------------------------------------------------------------
void setupGUIParametricSweater() {
  //Height body
  alt = controlP5.addTextfield("Height body").setLabel("")
    .setValue("160" )
      .setPosition(300, 400)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(20);
  ;
  alt.setVisible(false);
  //Width body
  ample = controlP5.addTextfield("Width body").setLabel("")
    .setValue("80" )
      .setPosition(600, 400)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(21);
  ;
  ample.setVisible(false);
  //Width sleeve
  maniga = controlP5.addTextfield("Width sleeve").setLabel("")
    .setValue("25" )
      .setPosition(300, 480)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(22);
  ;
  maniga.setVisible(false);
  //Height sleeve
  llargM = controlP5.addTextfield("Height sleeve").setLabel("")
    .setValue("190" )
      .setPosition(600, 480)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(23)
                ;
  ;
  llargM.setVisible(false);

  collAmple = controlP5.addTextfield("Width neck").setLabel("")
    .setValue("39" )
      .setPosition(300, 560)
        .setSize(200, 40)
          .setFont(laurentFont14)
            .setFocus(true)
              .setColor(color(255, 255, 255))
                .setId(24);
  ;

  collAmple.setVisible(false);
  saveParametricSweaterButton = controlP5.addButton("Save as image pattern", 4)
  .setPosition(600, 640)
  .setSize(200, 30)
  .setId(11);
  saveParametricSweaterButton.setVisible(false);
  applyParametricSweaterButton = controlP5.addButton("Apply changes", 4)
  .setPosition(600, 560)
  .setSize(200, 30)
  .setId(12);
  applyParametricSweaterButton.setVisible(false);
  loadParametricSweaterButton = controlP5.addButton("Load as pattern to knit", 4)
  .setPosition(600, 600)
  .setSize(200, 30)
  .setId(13);
  loadParametricSweaterButton.setVisible(false);
  
}
//------------------------------------------------------------------------------------
void applyParametricSweater() {
  ns.alt = Integer.parseInt(alt.getText());
  ns.ample = Integer.parseInt(ample.getText());
  ns.maniga = Integer.parseInt(maniga.getText());
  ns.llargM = Integer.parseInt(llargM.getText());
  ns.collAmple = Integer.parseInt(collAmple.getText());
  ns.generateSweater();
}
//------------------------------------------------------------------------------------

void createParametricSweater() {
  if (!createSweater) {
    ample.setVisible(true);
    alt.setVisible(true);
    maniga.setVisible(true);
    llargM.setVisible(true);
    collAmple.setVisible(true);
    createSweater = true;
    parametricSweaterButton.setLabel("Close parametric sweater");
    saveParametricSweaterButton.setVisible(true);
    applyParametricSweaterButton.setVisible(true);
    loadParametricSweaterButton.setVisible(true);
  }
  else {
    ample.setVisible(false);
    alt.setVisible(false);
    maniga.setVisible(false);
    llargM.setVisible(false);
    collAmple.setVisible(false);
    createSweater = false;
    parametricSweaterButton.setLabel("Open parametric sweater");
    saveParametricSweaterButton.setVisible(false);
    applyParametricSweaterButton.setVisible(false);
    loadParametricSweaterButton.setVisible(false); 
  }
}
//------------------------------------------------------------------------------------

void setupSweater() {
  ns = new parametricSweater();
  ns.generateSweater();
}

//------------------------------------------------------------------------------------

void drawSweater() {
  fill(73, 202, 250);
  rect(230, 0, 600, height);
  fill(255);
  //text("Set values for create a parametric sweater", 300, 380);
  pushMatrix();
  translate(530, 20);
  shape(ns.s, 0, 0);
  noFill();
  //stroke(255, 0, 0);
  rect((-ns.widthSweater/2), 0, ns.widthSweater-1, ns.heightSweater);
  image(ns.img, -ns.widthSweater/2, 0);
  //fill(0);
  //line(-300, 0, 300, 0);
  //line(0, 0, 0, 400);
  popMatrix();
  
  text("Height body:", 300, 390);
  text("Width body:", 600, 390);
  text("Width sleeve:", 300, 470);
  text("Height sleeve:", 600, 470);
  text("Width neck:", 300, 550);
}
//------------------------------------------------------------------------------------

void saveSweaterAsInputImage() {
  fillArrayWithImage(ns.img);
  println(ns.img.height);
}
//------------------------------------------------------------------------------------

class MyFilter extends javax.swing.filechooser.FileFilter {
  public boolean accept(File file) {
    String filename = file.getName();
    return filename.endsWith(".png");
  }

  public String getDescription() {
    return "*.png";
  }
}

//------------------------------------------------------------------------------------

void saveImagePattern() {
  JFileChooser fileChooser = new JFileChooser();
  fileChooser.setDialogTitle("Save As");
  fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
  int userSelection = fileChooser.showSaveDialog(null);

  MyFilter wordExtDesc = new MyFilter();
  fileChooser.setAcceptAllFileFilterUsed(false);
  fileChooser.setMultiSelectionEnabled(false);
  //fileChooser.setFileFilter(new FileNameExtensionFilter(wordExtDesc, ".png"));

  if (userSelection == JFileChooser.APPROVE_OPTION) {
    File fileToSave = fileChooser.getSelectedFile();
    System.out.println("Save as file: " + fileToSave.getAbsolutePath());
    ns.img.save(fileToSave.getAbsolutePath());
  }
}

//------------------------------------------------------------------------------------

void showHideFeaturesOpenKnit(String machineType) {
  println(machineType);
  if (machineType.equals("Openknit") == true) {
    startOpenKnit.setVisible(true); 
  }
  else {
    startOpenKnit.setVisible(false); 
  }
}

//------------------------------------------------------------------------------------