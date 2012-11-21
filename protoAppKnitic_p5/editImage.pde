void showCursorPosition() {
  if ( mouseX>buttonWithBar && mouseX<(width-buttonWithBar) ) {
    patternMouseX = (mouseX-buttonWithBar)/sizePixel;
    patternMouseY = (mouseY/sizePixel);
  }
}

void mouseReleased() {
  try {
    if (editPixels) {
      println(pixelArray[patternMouseX][patternMouseY]);
      if (pixelArray[patternMouseX][patternMouseY]==0 ) {
        pixelArray[patternMouseX][patternMouseY]=1;
      }
      else {
        pixelArray[patternMouseX][patternMouseY]=0;
      }
      // pass to image
      img.loadPixels();
      int loc = patternMouseX + patternMouseY*img.width;
      if (pixelArray[patternMouseX][patternMouseY]==0) {
        img.pixels[loc] = color(0, 0, 0);
      }
      else {
        img.pixels[loc] = color(255, 255, 255);
      }
      img.updatePixels();
    }
  }
  catch(Exception e) {
  }
}

