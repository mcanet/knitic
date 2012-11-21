class scrollBar {
  int posYDragScroll;
  int posYscrollBar;
  int heightYScrollBar;
  boolean notDragScroll;

  scrollBar() {
    posYscrollBar = 0;
    heightYScrollBar = 0;
    posYDragScroll = 0;
  }

  void setupScrollBar() {
    posYscrollBar = 0;
    heightYScrollBar = height*((rows*3)/height);
    notDragScroll = false;
  }

  void mouseMoveScroll() {
    if (mouseX > (width-buttonWithBar) && mouseX < ((width-buttonWithBar)+15) && mouseY> posYscrollBar && mouseY<(posYscrollBar+heightYScrollBar) && mousePressed && notDragScroll ) {
      notDragScroll = false;
      posYDragScroll = posYscrollBar-mouseY;
    }
    if (notDragScroll && mousePressed) {
      posYscrollBar = mouseY + posYDragScroll;
    }
    else {
      notDragScroll = false;
    }
  }
}

