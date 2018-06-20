class Tab {
  PVector pos=new PVector();
  PGraphics tab;
  boolean dragging;
  Tab(float posX, float posY, int w, int h) {
    pos.x=posX;
    pos.y=posY;
    tab=createGraphics(w, h);
  }
  void update() {
    tab.beginDraw();
    tab.fill(100, 100, 255);
    tab.rect(0, 0, tab.width, 20);
    tab.fill(0, 0);
    tab.stroke(55);
    tab.rect(1, 1, tab.width-2, tab.height-2);
    tab.endDraw();
    if(cursorRect(pos.x, pos.y, tab.width, 20)) {
      dragging=true;
    }
    if(!mousePressed) {
      dragging=false;
    }
    if(dragging) {
      pos.x+=mouseX-pmouseX;
      pos.y+=mouseY-pmouseY;
    }
    image(tab, pos.x, pos.y);
  }
}